Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 89D376B038D
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:13:19 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id o126so73186407pfb.2
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:13:19 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id o71si3130295pfi.195.2017.03.16.00.13.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 00:13:18 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH kernel v8 4/4] virtio-balloon: VIRTIO_BALLOON_F_HOST_REQ_VQ
Date: Thu, 16 Mar 2017 15:08:47 +0800
Message-Id: <1489648127-37282-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
References: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

From: Liang Li <liang.z.li@intel.com>

Add a new vq, host request vq. The host uses the vq to send
requests to the guest. Upon getting a request, the guest responds
what the host needs via this vq.

The patch implements the request of getting the unsed pages from the guest.
The unused guest pages are avoided to migrate in live migration. For an
idle guest with 8GB RAM, this optimization shorterns the total migration
time to 1/4.

Furthermore, it's also possible to drop the guest's page cache before
live migration. This optimization will be implemented on top of this
new feature in the future.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 drivers/virtio/virtio_balloon.c     | 140 ++++++++++++++++++++++++++++++++++--
 include/uapi/linux/virtio_balloon.h |  22 ++++++
 2 files changed, 157 insertions(+), 5 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 3f4a161..bcf2baa 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -64,7 +64,7 @@ struct balloon_page_chunk {
 typedef __le64 resp_data_t;
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *host_req_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -104,6 +104,8 @@ struct virtio_balloon {
 	 * pfn_start & pfn_stop: records the start and stop pfn in each cover
 	 */
 	unsigned long pfn_min, pfn_max, pfn_start, pfn_stop;
+	/* Request header */
+	struct virtio_balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -568,6 +570,81 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	virtqueue_kick(vq);
 }
 
+static void __send_unused_pages(struct virtio_balloon *vb,
+				unsigned long req_id, unsigned int pos,
+				bool done)
+{
+	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
+	struct virtqueue *vq = vb->host_req_vq;
+
+	vb->resp_pos = pos;
+	hdr->cmd = BALLOON_GET_UNUSED_PAGES;
+	hdr->id = cpu_to_le16(req_id);
+	if (!done)
+		hdr->flag = BALLOON_FLAG_CONT;
+	else
+		hdr->flag = BALLOON_FLAG_DONE;
+
+	if (pos > 0 || done)
+		send_resp_data(vb, vq, true);
+
+}
+
+static void send_unused_pages(struct virtio_balloon *vb,
+			      unsigned long req_id)
+{
+	struct scatterlist sg_in;
+	unsigned int pos = 0;
+	struct virtqueue *vq = vb->host_req_vq;
+	int ret, order;
+	struct zone *zone = NULL;
+	bool part_fill = false;
+
+	mutex_lock(&vb->balloon_lock);
+
+	for (order = MAX_ORDER - 1; order >= 0; order--) {
+		ret = record_unused_pages(&zone, order, vb->resp_data,
+					  vb->resp_buf_size / sizeof(__le64),
+					  &pos, part_fill);
+		if (ret == -ENOSPC) {
+			if (pos == 0) {
+				void *new_resp_data;
+
+				new_resp_data = kmalloc(2 * vb->resp_buf_size,
+							GFP_KERNEL);
+				if (new_resp_data) {
+					kfree(vb->resp_data);
+					vb->resp_data = new_resp_data;
+					vb->resp_buf_size *= 2;
+				} else {
+					part_fill = true;
+					dev_warn(&vb->vdev->dev,
+						 "%s: part fill order: %d\n",
+						 __func__, order);
+				}
+			} else {
+				__send_unused_pages(vb, req_id, pos, false);
+				pos = 0;
+			}
+
+			if (!part_fill) {
+				order++;
+				continue;
+			}
+		} else
+			zone = NULL;
+
+		if (order == 0)
+			__send_unused_pages(vb, req_id, pos, true);
+
+	}
+
+	mutex_unlock(&vb->balloon_lock);
+	sg_init_one(&sg_in, &vb->req_hdr, sizeof(vb->req_hdr));
+	virtqueue_add_inbuf(vq, &sg_in, 1, &vb->req_hdr, GFP_KERNEL);
+	virtqueue_kick(vq);
+}
+
 static void virtballoon_changed(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb = vdev->priv;
@@ -667,18 +744,53 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void handle_host_request(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+	struct virtio_balloon_req_hdr *hdr;
+	unsigned long req_id;
+	unsigned int len;
+
+	hdr = virtqueue_get_buf(vb->host_req_vq, &len);
+	if (!hdr || len != sizeof(vb->req_hdr))
+		return;
+
+	switch (hdr->cmd) {
+	case BALLOON_GET_UNUSED_PAGES:
+		req_id = le64_to_cpu(hdr->param);
+		send_unused_pages(vb, req_id);
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: host request %d not supported\n",
+			 __func__, hdr->cmd);
+	}
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
+	struct virtqueue *vqs[4];
+	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack,
+				       stats_request, handle_host_request };
+	static const char * const names[] = { "inflate", "deflate",
+					      "stats", "host_request" };
 	int err, nvqs;
 
 	/*
 	 * We expect two virtqueues: inflate and deflate, and
 	 * optionally stat.
 	 */
-	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ))
+		nvqs = 4;
+	else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		nvqs = 3;
+	else
+		nvqs = 2;
+
+	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
+	}
+
 	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
 	if (err)
 		return err;
@@ -699,6 +811,20 @@ static int init_vqs(struct virtio_balloon *vb)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ)) {
+		struct scatterlist sg_in;
+
+		vb->host_req_vq = vqs[3];
+		sg_init_one(&sg_in, &vb->req_hdr, sizeof(vb->req_hdr));
+		if (virtqueue_add_inbuf(vb->host_req_vq, &sg_in, 1,
+					&vb->req_hdr, GFP_KERNEL) < 0)
+			__virtio_clear_bit(vb->vdev,
+					   VIRTIO_BALLOON_F_HOST_REQ_VQ);
+		else
+			virtqueue_kick(vb->host_req_vq);
+	}
+
 	return 0;
 }
 
@@ -829,6 +955,7 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->page_bmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
 	if (!vb->page_bmap[0]) {
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
 	} else {
 		vb->page_bmaps = 1;
 		vb->resp_hdr =
@@ -837,6 +964,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		if (!vb->resp_hdr) {
 			__virtio_clear_bit(vdev,
 					   VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+			__virtio_clear_bit(vdev,
+					   VIRTIO_BALLOON_F_HOST_REQ_VQ);
 			kfree(vb->page_bmap[0]);
 		} else {
 			vb->resp_data = (void *)vb->resp_hdr +
@@ -966,6 +1095,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_CHUNK_TRANSFER,
+	VIRTIO_BALLOON_F_HOST_REQ_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index aa0e5f0..1f75bee 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -35,6 +35,7 @@
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
 #define VIRTIO_BALLOON_F_CHUNK_TRANSFER	3 /* Transfer pages in chunks */
+#define VIRTIO_BALLOON_F_HOST_REQ_VQ	4 /* Host request virtqueue */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -91,4 +92,25 @@ struct virtio_balloon_resp_hdr {
 	__le32 data_len; /* Payload len in bytes */
 };
 
+enum virtio_balloon_req_id {
+	/* Get unused page information */
+	BALLOON_GET_UNUSED_PAGES,
+};
+
+enum virtio_balloon_flag {
+	/* Have more data for a request */
+	BALLOON_FLAG_CONT,
+	/* No more data for a request */
+	BALLOON_FLAG_DONE,
+};
+
+struct virtio_balloon_req_hdr {
+	/* Used to distinguish different requests */
+	__le16 cmd;
+	/* Reserved */
+	__le16 reserved[3];
+	/* Request parameter */
+	__le64 param;
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
