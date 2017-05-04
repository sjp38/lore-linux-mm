Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 31D7A28035A
	for <linux-mm@kvack.org>; Thu,  4 May 2017 04:56:09 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id b17so5424071pfd.1
        for <linux-mm@kvack.org>; Thu, 04 May 2017 01:56:09 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t188si1518031pgt.331.2017.05.04.01.56.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 01:56:07 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v10 6/6] virtio-balloon: VIRTIO_BALLOON_F_MISC_VQ
Date: Thu,  4 May 2017 16:50:15 +0800
Message-Id: <1493887815-6070-7-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
References: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Add a new vq, miscq, to handle miscellaneous requests between the device
and the driver. Only one request is handled in-flight each time.

This patch implements the VIRTIO_BALLOON_MISCQ_CMD_REPORT_UNUSED_PAGES
request sent from the device. Upon receiving the request from the
miscq, the driver offers to the device the guest unused pages.

Tests have shown that skipping the transfer of unused pages of a 32G
idle guest can get the live migration time reduced to 1/8.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
---
 drivers/virtio/virtio_balloon.c     | 299 +++++++++++++++++++++++++++++++-----
 include/uapi/linux/virtio_balloon.h |  12 ++
 2 files changed, 274 insertions(+), 37 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index df16912..4dcee2c 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -57,6 +57,10 @@
 /* The maximum number of page_bmap that can be allocated. */
 #define VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM	32
 
+/* Types of pages to chunk */
+#define PAGE_CHUNK_TYPE_BALLOON	0	/* Chunk of inflate/deflate pages */
+#define PAGE_CHUNK_TYPE_UNUSED	1	/* Chunk of unused pages */
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -67,16 +71,17 @@ static struct vfsmount *balloon_mnt;
 
 /* Maximum number of page chunks */
 #define VIRTIO_BALLOON_MAX_PAGE_CHUNKS ((8 * PAGE_SIZE - \
-			sizeof(struct virtio_balloon_page_chunk)) / \
-			sizeof(struct virtio_balloon_page_chunk_entry))
+				sizeof(struct virtio_balloon_miscq_msg)) / \
+				sizeof(struct virtio_balloon_page_chunk_entry))
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *miscq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
 	struct work_struct update_balloon_size_work;
+	struct work_struct miscq_handle_work;
 
 	/* Prevent updating balloon when it is being canceled. */
 	spinlock_t stop_update_lock;
@@ -98,6 +103,9 @@ struct virtio_balloon {
 	/* Synchronize access/update to this struct virtio_balloon elements */
 	struct mutex balloon_lock;
 
+	/* Miscq msg buffer for the REPORT_UNUSED_PAGES cmd */
+	struct virtio_balloon_miscq_msg *miscq_msg_rup;
+
 	/* Buffer for chunks of ballooned pages. */
 	struct virtio_balloon_page_chunk *balloon_page_chunk;
 
@@ -200,38 +208,85 @@ static void clear_page_bmap(struct virtio_balloon *vb,
 		memset(vb->page_bmap[i], 0, VIRTIO_BALLOON_PAGE_BMAP_SIZE);
 }
 
-static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq)
+static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq,
+			     int type, bool busy_wait)
 {
 	struct scatterlist sg;
 	struct virtio_balloon_page_chunk *chunk;
-	unsigned int len;
+	void *msg_buf;
+	unsigned int msg_len;
+	uint64_t chunk_num = 0;
+
+	switch (type) {
+	case PAGE_CHUNK_TYPE_BALLOON:
+		chunk = vb->balloon_page_chunk;
+		chunk_num = le64_to_cpu(chunk->chunk_num);
+		msg_buf = vb->balloon_page_chunk;
+		msg_len = sizeof(struct virtio_balloon_page_chunk) +
+			  sizeof(struct virtio_balloon_page_chunk_entry) *
+			  chunk_num;
+		break;
+	case PAGE_CHUNK_TYPE_UNUSED:
+		chunk = &vb->miscq_msg_rup->payload.chunk;
+		chunk_num = le64_to_cpu(chunk->chunk_num);
+		msg_buf = vb->miscq_msg_rup;
+		msg_len = sizeof(struct virtio_balloon_miscq_msg) +
+			  sizeof(struct virtio_balloon_page_chunk_entry) *
+			  chunk_num;
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
+			 __func__, type);
+		return;
+	}
 
-	chunk = vb->balloon_page_chunk;
-	len = sizeof(__le64) +
-	      le64_to_cpu(chunk->chunk_num) *
-	      sizeof(struct virtio_balloon_page_chunk_entry);
-	sg_init_one(&sg, chunk, len);
+	sg_init_one(&sg, msg_buf, msg_len);
 	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
 		virtqueue_kick(vq);
-		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		if (busy_wait)
+			while (!virtqueue_get_buf(vq, &msg_len) &&
+			       !virtqueue_is_broken(vq))
+				cpu_relax();
+		else
+			wait_event(vb->acked, virtqueue_get_buf(vq, &msg_len));
+		/*
+		 * Now, the chunks have been delivered to the host.
+		 * Reset the filed in the structure that records the number of
+		 * added chunks, so that new added chunks can be re-counted.
+		 */
 		chunk->chunk_num = 0;
 	}
 }
 
 /* Add a chunk entry to the buffer. */
 static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
-			  u64 base, u64 size)
+			  int type, u64 base, u64 size)
 {
-	struct virtio_balloon_page_chunk *chunk = vb->balloon_page_chunk;
+	struct virtio_balloon_page_chunk *chunk;
 	struct virtio_balloon_page_chunk_entry *entry;
-	uint64_t chunk_num = le64_to_cpu(chunk->chunk_num);
-
+	uint64_t chunk_num;
+
+	switch (type) {
+	case PAGE_CHUNK_TYPE_BALLOON:
+		chunk = vb->balloon_page_chunk;
+		chunk_num = le64_to_cpu(vb->balloon_page_chunk->chunk_num);
+		break;
+	case PAGE_CHUNK_TYPE_UNUSED:
+		chunk = &vb->miscq_msg_rup->payload.chunk;
+		chunk_num =
+		le64_to_cpu(vb->miscq_msg_rup->payload.chunk.chunk_num);
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
+			 __func__, type);
+		return;
+	}
 	entry = &chunk->entry[chunk_num];
 	entry->base = cpu_to_le64(base << VIRTIO_BALLOON_CHUNK_BASE_SHIFT);
 	entry->size = cpu_to_le64(size << VIRTIO_BALLOON_CHUNK_SIZE_SHIFT);
 	chunk->chunk_num = cpu_to_le64(++chunk_num);
 	if (chunk_num == VIRTIO_BALLOON_MAX_PAGE_CHUNKS)
-		send_page_chunks(vb, vq);
+		send_page_chunks(vb, vq, type, 0);
 }
 
 static void convert_bmap_to_chunks(struct virtio_balloon *vb,
@@ -259,8 +314,8 @@ static void convert_bmap_to_chunks(struct virtio_balloon *vb,
 		chunk_size = (next_zero - next_one) *
 			     VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (chunk_size) {
-			add_one_chunk(vb, vq, pfn_start + next_one,
-				      chunk_size);
+			add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
+				      pfn_start + next_one, chunk_size);
 			pos += next_zero + 1;
 		}
 	}
@@ -305,7 +360,7 @@ static void tell_host_from_page_bmap(struct virtio_balloon *vb,
 				       pfn_num);
 	}
 	if (le64_to_cpu(vb->balloon_page_chunk->chunk_num) > 0)
-		send_page_chunks(vb, vq);
+		send_page_chunks(vb, vq, PAGE_CHUNK_TYPE_BALLOON, 0);
 }
 
 static void set_page_pfns(struct virtio_balloon *vb,
@@ -679,43 +734,186 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+/* Add a message buffer for the host to fill in a request */
+static void miscq_msg_inbuf_add(struct virtio_balloon *vb,
+			      struct virtio_balloon_miscq_msg *req_buf)
+{
+	struct scatterlist sg_in;
+
+	sg_init_one(&sg_in, req_buf, sizeof(struct virtio_balloon_miscq_msg));
+	if (virtqueue_add_inbuf(vb->miscq, &sg_in, 1, req_buf, GFP_KERNEL)
+	    < 0) {
+		__virtio_clear_bit(vb->vdev,
+				   VIRTIO_BALLOON_F_MISC_VQ);
+		dev_warn(&vb->vdev->dev, "%s: add miscq msg buf err\n",
+			 __func__);
+		return;
+	}
+	virtqueue_kick(vb->miscq);
+}
+
+static void miscq_report_unused_pages(struct virtio_balloon *vb)
+{
+	struct virtio_balloon_miscq_msg *msg = vb->miscq_msg_rup;
+	struct virtqueue *vq = vb->miscq;
+	int ret = 0;
+	unsigned int order = 0, migratetype = 0;
+	struct zone *zone = NULL;
+	struct page *page = NULL;
+	u64 pfn;
+
+	msg->cmd = cpu_to_le32(VIRTIO_BALLOON_MISCQ_CMD_REPORT_UNUSED_PAGES);
+	msg->flags = 0;
+
+	for_each_populated_zone(zone) {
+		for (order = MAX_ORDER - 1; order > 0; order--) {
+			for (migratetype = 0; migratetype < MIGRATE_TYPES;
+			     migratetype++) {
+				do {
+					ret = report_unused_page_block(zone,
+						order, migratetype, &page);
+					if (!ret) {
+						pfn = (u64)page_to_pfn(page);
+						add_one_chunk(vb, vq,
+							PAGE_CHUNK_TYPE_UNUSED,
+							pfn,
+							(u64)(1 << order) *
+						VIRTIO_BALLOON_PAGES_PER_PAGE);
+					}
+				} while (!ret);
+			}
+		}
+	}
+	/* Set the cmd completion flag */
+	msg->flags |= cpu_to_le32(VIRTIO_BALLOON_MISCQ_F_COMPLETION);
+	send_page_chunks(vb, vq, PAGE_CHUNK_TYPE_UNUSED, true);
+}
+
+static void miscq_handle_func(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+	struct virtio_balloon_miscq_msg *msg;
+	unsigned int len;
+
+	vb = container_of(work, struct virtio_balloon,
+			  miscq_handle_work);
+	msg = virtqueue_get_buf(vb->miscq, &len);
+	if (!msg || len != sizeof(struct virtio_balloon_miscq_msg)) {
+		dev_warn(&vb->vdev->dev, "%s: invalid miscq msg len\n",
+			 __func__);
+		miscq_msg_inbuf_add(vb, vb->miscq_msg_rup);
+		return;
+	}
+	switch (msg->cmd) {
+	case VIRTIO_BALLOON_MISCQ_CMD_REPORT_UNUSED_PAGES:
+		miscq_report_unused_pages(vb);
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: miscq cmd %d not supported\n",
+			 __func__, msg->cmd);
+	}
+	miscq_msg_inbuf_add(vb, vb->miscq_msg_rup);
+}
+
+static void miscq_request(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+
+	queue_work(system_freezable_wq, &vb->miscq_handle_work);
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
-	int err, nvqs;
+	struct virtqueue **vqs;
+	vq_callback_t **callbacks;
+	const char **names;
+	int err = -ENOMEM;
+	int i, nvqs;
+
+	 /* Inflateq and deflateq are used unconditionally */
+	nvqs = 2;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		nvqs++;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ))
+		nvqs++;
+
+	/* Allocate space for find_vqs parameters */
+	vqs = kcalloc(nvqs, sizeof(*vqs), GFP_KERNEL);
+	if (!vqs)
+		goto err_vq;
+	callbacks = kmalloc_array(nvqs, sizeof(*callbacks), GFP_KERNEL);
+	if (!callbacks)
+		goto err_callback;
+	names = kmalloc_array(nvqs, sizeof(*names), GFP_KERNEL);
+	if (!names)
+		goto err_names;
+
+	callbacks[0] = balloon_ack;
+	names[0] = "inflate";
+	callbacks[1] = balloon_ack;
+	names[1] = "deflate";
+
+	i = 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		callbacks[i] = stats_request;
+		names[i] = "stats";
+		i++;
+	}
 
-	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
-	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
-			NULL);
+	if (virtio_has_feature(vb->vdev,
+				      VIRTIO_BALLOON_F_MISC_VQ)) {
+		callbacks[i] = miscq_request;
+		names[i] = "miscq";
+	}
+
+	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks,
+					 names, NULL);
 	if (err)
-		return err;
+		goto err_find;
 
 	vb->inflate_vq = vqs[0];
 	vb->deflate_vq = vqs[1];
+	i = 2;
 	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		struct scatterlist sg;
-		unsigned int num_stats;
-		vb->stats_vq = vqs[2];
 
+		vb->stats_vq = vqs[i++];
 		/*
 		 * Prime this virtqueue with one buffer so the hypervisor can
 		 * use it to signal us later (it can't be broken yet!).
 		 */
-		num_stats = update_balloon_stats(vb);
-
-		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
+		sg_init_one(&sg, vb->stats, sizeof(vb->stats));
 		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
 		    < 0)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ)) {
+		vb->miscq = vqs[i];
+		/*
+		 * Add the msg buf for the REPORT_UNUSED_PAGES request.
+		 * The request is handled one in-flight each time. So, just
+		 * use the response buffer, msicq_msg_rup, for the host to
+		 * fill in a request.
+		 */
+		miscq_msg_inbuf_add(vb, vb->miscq_msg_rup);
+	}
+
+	kfree(names);
+	kfree(callbacks);
+	kfree(vqs);
 	return 0;
+
+err_find:
+	kfree(names);
+err_names:
+	kfree(callbacks);
+err_callback:
+	kfree(vqs);
+err_vq:
+	return err;
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
@@ -723,7 +921,7 @@ static int init_vqs(struct virtio_balloon *vb)
 static void tell_host_one_page(struct virtio_balloon *vb,
 			       struct virtqueue *vq, struct page *page)
 {
-	add_one_chunk(vb, vq, page_to_pfn(page),
+	add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON, page_to_pfn(page),
 		      VIRTIO_BALLOON_PAGES_PER_PAGE);
 }
 
@@ -857,6 +1055,22 @@ static int balloon_page_chunk_init(struct virtio_balloon *vb)
 	return -ENOMEM;
 }
 
+static int miscq_init(struct virtio_balloon *vb)
+{
+	vb->miscq_msg_rup = kmalloc(sizeof(struct virtio_balloon_miscq_msg) +
+			     sizeof(struct virtio_balloon_page_chunk_entry) *
+			     VIRTIO_BALLOON_MAX_PAGE_CHUNKS, GFP_KERNEL);
+	if (!vb->miscq_msg_rup) {
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ);
+		dev_warn(&vb->vdev->dev, "%s: failed\n", __func__);
+		return -ENOMEM;
+	}
+
+	INIT_WORK(&vb->miscq_handle_work, miscq_handle_func);
+
+	return 0;
+}
+
 static int virtballoon_validate(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = NULL;
@@ -874,7 +1088,16 @@ static int virtballoon_validate(struct virtio_device *vdev)
 			goto err_page_chunk;
 	}
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_MISC_VQ)) {
+		err = miscq_init(vb);
+		if (err < 0)
+			goto err_miscq_rup;
+	}
+
 	return 0;
+err_miscq_rup:
+	free_page_bmap(vb);
+	kfree(vb->balloon_page_chunk);
 err_page_chunk:
 	kfree(vb);
 err_vb:
@@ -971,6 +1194,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	spin_unlock_irq(&vb->stop_update_lock);
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
+	cancel_work_sync(&vb->miscq_handle_work);
 
 	remove_common(vb);
 	free_page_bmap(vb);
@@ -1020,6 +1244,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_CHUNKS,
+	VIRTIO_BALLOON_F_MISC_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index d532ed16..ea83b74 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_PAGE_CHUNKS	3 /* Inflate/Deflate pages in chunks */
+#define VIRTIO_BALLOON_F_MISC_VQ	4 /* Virtqueue for misc. requests */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -96,4 +97,15 @@ struct virtio_balloon_page_chunk {
 	struct virtio_balloon_page_chunk_entry entry[];
 };
 
+struct virtio_balloon_miscq_msg {
+#define VIRTIO_BALLOON_MISCQ_CMD_REPORT_UNUSED_PAGES 0
+	__le32 cmd;
+/* Flag to indicate the completion of handling a command */
+#define VIRTIO_BALLOON_MISCQ_F_COMPLETION	1
+	__le32 flags;
+	union {
+		struct virtio_balloon_page_chunk chunk;
+	} payload;
+};
+
 #endif /* _LINUX_VIRTIO_BALLOON_H */
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
