Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C02256B02FA
	for <linux-mm@kvack.org>; Fri,  9 Jun 2017 06:49:10 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id f185so24898744pgc.10
        for <linux-mm@kvack.org>; Fri, 09 Jun 2017 03:49:10 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e67si678181pfg.409.2017.06.09.03.49.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Jun 2017 03:49:09 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v11 6/6] virtio-balloon: VIRTIO_BALLOON_F_CMD_VQ
Date: Fri,  9 Jun 2017 18:41:41 +0800
Message-Id: <1497004901-30593-7-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
References: <1497004901-30593-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Add a new vq, cmdq, to handle requests between the device and driver.

This patch implements two commands send from the device and handled in
the driver.
1) cmd VIRTIO_BALLOON_CMDQ_REPORT_STATS: this command is used to report
the guest memory statistics to the host. The stats_vq mechanism is not
used when the cmdq mechanism is enabled.
2) cmd VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES: this command is used to
report the guest unused pages to the host.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 drivers/virtio/virtio_balloon.c     | 363 ++++++++++++++++++++++++++++++++----
 include/uapi/linux/virtio_balloon.h |  13 ++
 2 files changed, 337 insertions(+), 39 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 0cf945c..4ac90a5 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -51,6 +51,10 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 static struct vfsmount *balloon_mnt;
 #endif
 
+/* Types of pages to chunk */
+#define PAGE_CHUNK_TYPE_BALLOON 0	/* Chunk of inflate/deflate pages */
+#define PAGE_CHNUK_UNUSED_PAGE  1	/* Chunk of unused pages */
+
 /* The size of one page_bmap used to record inflated/deflated pages. */
 #define VIRTIO_BALLOON_PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
 /*
@@ -81,12 +85,25 @@ struct virtio_balloon_page_chunk {
 	unsigned long *page_bmap[VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM];
 };
 
+struct virtio_balloon_cmdq_unused_page {
+	struct virtio_balloon_cmdq_hdr hdr;
+	struct vring_desc *desc_table;
+	/* Number of added descriptors */
+	unsigned int num;
+};
+
+struct virtio_balloon_cmdq_stats {
+	struct virtio_balloon_cmdq_hdr hdr;
+	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
+};
+
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *cmd_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
+	struct work_struct cmdq_handle_work;
 	struct work_struct update_balloon_size_work;
 
 	/* Prevent updating balloon when it is being canceled. */
@@ -115,8 +132,10 @@ struct virtio_balloon {
 	unsigned int num_pfns;
 	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
 
-	/* Memory statistics */
-	struct virtio_balloon_stat stats[VIRTIO_BALLOON_S_NR];
+	/* Cmdq msg buffer for memory statistics */
+	struct virtio_balloon_cmdq_stats cmdq_stats;
+	/* Cmdq msg buffer for reporting ununsed pages */
+	struct virtio_balloon_cmdq_unused_page cmdq_unused_page;
 
 	/* To register callback in oom notifier call chain */
 	struct notifier_block nb;
@@ -208,31 +227,77 @@ static void clear_page_bmap(struct virtio_balloon *vb,
 		       VIRTIO_BALLOON_PAGE_BMAP_SIZE);
 }
 
-static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq)
+static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq,
+			     int type, bool busy_wait)
 {
-	unsigned int len, num;
-	struct vring_desc *desc = vb->balloon_page_chunk.desc_table;
+	unsigned int len, *num, reset_num;
+	struct vring_desc *desc;
+
+	switch (type) {
+	case PAGE_CHUNK_TYPE_BALLOON:
+		desc = vb->balloon_page_chunk.desc_table;
+		num = &vb->balloon_page_chunk.chunk_num;
+		reset_num = 0;
+		break;
+	case PAGE_CHNUK_UNUSED_PAGE:
+		desc = vb->cmdq_unused_page.desc_table;
+		num = &vb->cmdq_unused_page.num;
+		/*
+		 * The first desc is used for the cmdq_hdr, so chunks will be
+		 * added from the second desc.
+		 */
+		reset_num = 1;
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: unknown page chunk type %d\n",
+			 __func__, type);
+		return;
+	}
 
-	num = vb->balloon_page_chunk.chunk_num;
-	if (!virtqueue_indirect_desc_table_add(vq, desc, num)) {
+	if (!virtqueue_indirect_desc_table_add(vq, desc, *num)) {
 		virtqueue_kick(vq);
-		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
-		vb->balloon_page_chunk.chunk_num = 0;
+		if (busy_wait)
+			while (!virtqueue_get_buf(vq, &len) &&
+			       !virtqueue_is_broken(vq))
+				cpu_relax();
+		else
+			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		/*
+		 * Now, the descriptor have been delivered to the host. Reset
+		 * the field in the structure that records the number of added
+		 * descriptors, so that new added descriptor can be re-counted.
+		 */
+		*num = reset_num;
 	}
 }
 
 /* Add a chunk to the buffer. */
 static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
-			  u64 base_addr, u32 size)
+			  int type, u64 base_addr, u32 size)
 {
-	unsigned int *num = &vb->balloon_page_chunk.chunk_num;
-	struct vring_desc *desc = &vb->balloon_page_chunk.desc_table[*num];
+	unsigned int *num;
+	struct vring_desc *desc;
+
+	switch (type) {
+	case PAGE_CHUNK_TYPE_BALLOON:
+		num = &vb->balloon_page_chunk.chunk_num;
+		desc = &vb->balloon_page_chunk.desc_table[*num];
+		break;
+	case PAGE_CHNUK_UNUSED_PAGE:
+		num = &vb->cmdq_unused_page.num;
+		desc = &vb->cmdq_unused_page.desc_table[*num];
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
+			 __func__, type);
+		return;
+	}
 
 	desc->addr = cpu_to_virtio64(vb->vdev, base_addr);
 	desc->len = cpu_to_virtio32(vb->vdev, size);
 	*num += 1;
 	if (*num == VIRTIO_BALLOON_MAX_PAGE_CHUNKS)
-		send_page_chunks(vb, vq);
+		send_page_chunks(vb, vq, type, false);
 }
 
 static void convert_bmap_to_chunks(struct virtio_balloon *vb,
@@ -264,7 +329,8 @@ static void convert_bmap_to_chunks(struct virtio_balloon *vb,
 		chunk_base_addr = (pfn_start + next_one) <<
 				  VIRTIO_BALLOON_PFN_SHIFT;
 		if (chunk_size) {
-			add_one_chunk(vb, vq, chunk_base_addr, chunk_size);
+			add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
+				      chunk_base_addr, chunk_size);
 			pos += next_zero + 1;
 		}
 	}
@@ -311,7 +377,7 @@ static void tell_host_from_page_bmap(struct virtio_balloon *vb,
 				       pfn_num);
 	}
 	if (vb->balloon_page_chunk.chunk_num > 0)
-		send_page_chunks(vb, vq);
+		send_page_chunks(vb, vq, PAGE_CHUNK_TYPE_BALLOON, false);
 }
 
 static void set_page_pfns(struct virtio_balloon *vb,
@@ -516,8 +582,8 @@ static inline void update_stat(struct virtio_balloon *vb, int idx,
 			       u16 tag, u64 val)
 {
 	BUG_ON(idx >= VIRTIO_BALLOON_S_NR);
-	vb->stats[idx].tag = cpu_to_virtio16(vb->vdev, tag);
-	vb->stats[idx].val = cpu_to_virtio64(vb->vdev, val);
+	vb->cmdq_stats.stats[idx].tag = cpu_to_virtio16(vb->vdev, tag);
+	vb->cmdq_stats.stats[idx].val = cpu_to_virtio64(vb->vdev, val);
 }
 
 #define pages_to_bytes(x) ((u64)(x) << PAGE_SHIFT)
@@ -582,7 +648,8 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	vq = vb->stats_vq;
 	if (!virtqueue_get_buf(vq, &len))
 		return;
-	sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
+	sg_init_one(&sg, vb->cmdq_stats.stats,
+		    sizeof(vb->cmdq_stats.stats[0]) * num_stats);
 	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
 	virtqueue_kick(vq);
 }
@@ -686,43 +753,216 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void cmdq_handle_stats(struct virtio_balloon *vb)
+{
+	struct scatterlist sg;
+	unsigned int num_stats;
+
+	spin_lock(&vb->stop_update_lock);
+	if (!vb->stop_update) {
+		num_stats = update_balloon_stats(vb);
+		sg_init_one(&sg, &vb->cmdq_stats,
+			    sizeof(struct virtio_balloon_cmdq_hdr) +
+			    sizeof(struct virtio_balloon_stat) * num_stats);
+		virtqueue_add_outbuf(vb->cmd_vq, &sg, 1, vb, GFP_KERNEL);
+		virtqueue_kick(vb->cmd_vq);
+	}
+	spin_unlock(&vb->stop_update_lock);
+}
+
+/*
+ * The header part of the message buffer is given to the device to send a
+ * command to the driver.
+ */
+static void host_cmd_buf_add(struct virtio_balloon *vb,
+			   struct virtio_balloon_cmdq_hdr *hdr)
+{
+	struct scatterlist sg;
+
+	hdr->flags = 0;
+	sg_init_one(&sg, hdr, VIRTIO_BALLOON_CMDQ_HDR_SIZE);
+
+	if (virtqueue_add_inbuf(vb->cmd_vq, &sg, 1, hdr, GFP_KERNEL) < 0) {
+		__virtio_clear_bit(vb->vdev,
+				   VIRTIO_BALLOON_F_CMD_VQ);
+		dev_warn(&vb->vdev->dev, "%s: add miscq msg buf err\n",
+			 __func__);
+		return;
+	}
+
+	virtqueue_kick(vb->cmd_vq);
+}
+
+static void cmdq_handle_unused_pages(struct virtio_balloon *vb)
+{
+	struct virtqueue *vq = vb->cmd_vq;
+	struct vring_desc *hdr_desc = &vb->cmdq_unused_page.desc_table[0];
+	unsigned long hdr_pa;
+	unsigned int order = 0, migratetype = 0;
+	struct zone *zone = NULL;
+	struct page *page = NULL;
+	u64 pfn;
+	int ret = 0;
+
+	/* Put the hdr to the first desc */
+	hdr_pa = virt_to_phys((void *)&vb->cmdq_unused_page.hdr);
+	hdr_desc->addr = cpu_to_virtio64(vb->vdev, hdr_pa);
+	hdr_desc->len = cpu_to_virtio32(vb->vdev,
+				sizeof(struct virtio_balloon_cmdq_hdr));
+	vb->cmdq_unused_page.num = 1;
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
+						PAGE_CHNUK_UNUSED_PAGE,
+						pfn << VIRTIO_BALLOON_PFN_SHIFT,
+						(u64)(1 << order) *
+						VIRTIO_BALLOON_PAGES_PER_PAGE);
+					}
+				} while (!ret);
+			}
+		}
+	}
+
+	/* Set the cmd completion flag. */
+	vb->cmdq_unused_page.hdr.flags |=
+				cpu_to_le32(VIRTIO_BALLOON_CMDQ_F_COMPLETION);
+	send_page_chunks(vb, vq, PAGE_CHNUK_UNUSED_PAGE, true);
+}
+
+static void cmdq_handle(struct virtio_balloon *vb)
+{
+	struct virtqueue *vq;
+	struct virtio_balloon_cmdq_hdr *hdr;
+	unsigned int len;
+
+	vq = vb->cmd_vq;
+	while ((hdr = (struct virtio_balloon_cmdq_hdr *)
+			virtqueue_get_buf(vq, &len)) != NULL) {
+		switch (hdr->cmd) {
+		case VIRTIO_BALLOON_CMDQ_REPORT_STATS:
+			cmdq_handle_stats(vb);
+			break;
+		case VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES:
+			cmdq_handle_unused_pages(vb);
+			break;
+		default:
+			dev_warn(&vb->vdev->dev, "%s: wrong cmd\n", __func__);
+			return;
+		}
+		/*
+		 * Replenish all the command buffer to the device after a
+		 * command is handled. This is for the convenience of the
+		 * device to rewind the cmdq to get back all the command
+		 * buffer after live migration.
+		 */
+		host_cmd_buf_add(vb, &vb->cmdq_stats.hdr);
+		host_cmd_buf_add(vb, &vb->cmdq_unused_page.hdr);
+	}
+}
+
+static void cmdq_handle_work_func(struct work_struct *work)
+{
+	struct virtio_balloon *vb;
+
+	vb = container_of(work, struct virtio_balloon,
+			  cmdq_handle_work);
+	cmdq_handle(vb);
+}
+
+static void cmdq_callback(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+
+	queue_work(system_freezable_wq, &vb->cmdq_handle_work);
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
+	int nvqs;
+
+	/* Inflateq and deflateq are used unconditionally */
+	nvqs = 2;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CMD_VQ) ||
+	    virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
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
 
 	/*
-	 * We expect two virtqueues: inflate and deflate, and
-	 * optionally stat.
+	 * The stats_vq is used only when cmdq is not supported (or disabled)
+	 * by the device.
 	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
-	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names,
-			NULL);
-	if (err)
-		return err;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CMD_VQ)) {
+		callbacks[2] = cmdq_callback;
+		names[2] = "cmdq";
+	} else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		callbacks[2] = stats_request;
+		names[2] = "stats";
+	}
 
+	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks,
+					 names, NULL);
+	if (err)
+		goto err_find;
 	vb->inflate_vq = vqs[0];
 	vb->deflate_vq = vqs[1];
-	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CMD_VQ)) {
+		vb->cmd_vq = vqs[2];
+		/* Prime the cmdq with the header buffer. */
+		host_cmd_buf_add(vb, &vb->cmdq_stats.hdr);
+		host_cmd_buf_add(vb, &vb->cmdq_unused_page.hdr);
+	} else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
 		struct scatterlist sg;
-		unsigned int num_stats;
-		vb->stats_vq = vqs[2];
 
+		vb->stats_vq = vqs[2];
 		/*
 		 * Prime this virtqueue with one buffer so the hypervisor can
 		 * use it to signal us later (it can't be broken yet!).
 		 */
-		num_stats = update_balloon_stats(vb);
-
-		sg_init_one(&sg, vb->stats, sizeof(vb->stats[0]) * num_stats);
+		sg_init_one(&sg, vb->cmdq_stats.stats,
+			    sizeof(vb->cmdq_stats.stats));
 		if (virtqueue_add_outbuf(vb->stats_vq, &sg, 1, vb, GFP_KERNEL)
 		    < 0)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
-	return 0;
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
@@ -730,7 +970,8 @@ static int init_vqs(struct virtio_balloon *vb)
 static void tell_host_one_page(struct virtio_balloon *vb,
 			       struct virtqueue *vq, struct page *page)
 {
-	add_one_chunk(vb, vq, page_to_pfn(page) << VIRTIO_BALLOON_PFN_SHIFT,
+	add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
+		      page_to_pfn(page) << VIRTIO_BALLOON_PFN_SHIFT,
 		      VIRTIO_BALLOON_PAGES_PER_PAGE);
 }
 
@@ -865,6 +1106,40 @@ static int balloon_page_chunk_init(struct virtio_balloon *vb)
 	return -ENOMEM;
 }
 
+/*
+ * Each type of command is handled one in-flight each time. So, we allocate
+ * one message buffer for each type of command. The header part of the message
+ * buffer will be offered to the device, so that the device can send a command
+ * using the corresponding command buffer to the driver later.
+ */
+static int cmdq_init(struct virtio_balloon *vb)
+{
+	vb->cmdq_unused_page.desc_table = alloc_indirect(vb->vdev,
+						VIRTIO_BALLOON_MAX_PAGE_CHUNKS,
+						GFP_KERNEL);
+	if (!vb->cmdq_unused_page.desc_table) {
+		dev_warn(&vb->vdev->dev, "%s: failed\n", __func__);
+		__virtio_clear_bit(vb->vdev,
+				   VIRTIO_BALLOON_F_CMD_VQ);
+		return -ENOMEM;
+	}
+	vb->cmdq_unused_page.num = 0;
+
+	/*
+	 * The header is initialized to let the device know which type of
+	 * command buffer it receives. The device will later use a buffer
+	 * according to the type of command that it needs to send.
+	 */
+	vb->cmdq_stats.hdr.cmd = VIRTIO_BALLOON_CMDQ_REPORT_STATS;
+	vb->cmdq_stats.hdr.flags = 0;
+	vb->cmdq_unused_page.hdr.cmd = VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES;
+	vb->cmdq_unused_page.hdr.flags = 0;
+
+	INIT_WORK(&vb->cmdq_handle_work, cmdq_handle_work_func);
+
+	return 0;
+}
+
 static int virtballoon_validate(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = NULL;
@@ -883,6 +1158,11 @@ static int virtballoon_validate(struct virtio_device *vdev)
 			goto err_page_chunk;
 	}
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_CMD_VQ)) {
+		err = cmdq_init(vb);
+		if (err < 0)
+			goto err_vb;
+	}
 	return 0;
 
 err_page_chunk:
@@ -902,7 +1182,10 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		return -EINVAL;
 	}
 
-	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
+	if (!virtio_has_feature(vdev, VIRTIO_BALLOON_F_CMD_VQ) &&
+	    virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		INIT_WORK(&vb->update_balloon_stats_work,
+			  update_balloon_stats_func);
 	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
@@ -980,6 +1263,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	spin_unlock_irq(&vb->stop_update_lock);
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
+	cancel_work_sync(&vb->cmdq_handle_work);
 
 	remove_common(vb);
 	free_page_bmap(vb);
@@ -1029,6 +1313,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_CHUNKS,
+	VIRTIO_BALLOON_F_CMD_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 5ed3c7b..cb66c1a 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_PAGE_CHUNKS	3 /* Inflate/Deflate pages in chunks */
+#define VIRTIO_BALLOON_F_CMD_VQ		4 /* Command virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -83,4 +84,16 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+/* Use the memory of a vring_desc to place the cmdq header */
+#define VIRTIO_BALLOON_CMDQ_HDR_SIZE sizeof(struct vring_desc)
+
+struct virtio_balloon_cmdq_hdr {
+#define VIRTIO_BALLOON_CMDQ_REPORT_STATS	0
+#define VIRTIO_BALLOON_CMDQ_REPORT_UNUSED_PAGES	1
+	__le32 cmd;
+/* Flag to indicate the completion of handling a command */
+#define VIRTIO_BALLOON_CMDQ_F_COMPLETION	1
+	__le32 flags;
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
