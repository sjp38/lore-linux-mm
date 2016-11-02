Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 86FEE6B02B0
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 02:31:00 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id yt9so3532685pac.0
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 23:31:00 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id n7si928119pag.191.2016.11.01.23.30.59
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 01 Nov 2016 23:30:59 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v4 7/7] virtio-balloon: tell host vm's unused page info
Date: Wed,  2 Nov 2016 14:17:27 +0800
Message-Id: <1478067447-24654-8-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
References: <1478067447-24654-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com, dave.hansen@intel.com
Cc: pbonzini@redhat.com, amit.shah@redhat.com, quintela@redhat.com, dgilbert@redhat.com, qemu-devel@nongnu.org, kvm@vger.kernel.org, virtio-dev@lists.oasis-open.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, mgorman@techsingularity.net, cornelia.huck@de.ibm.com, Liang Li <liang.z.li@intel.com>

Support the request for vm's unused page information, response with
a page bitmap. QEMU can make use of this bitmap and the dirty page
logging mechanism to skip the transportation of some of these unused
pages, this is very helpful to reduce the network traffic and  speed
up the live migration process.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 drivers/virtio/virtio_balloon.c | 128 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 121 insertions(+), 7 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index c6c94b6..ba2d37b 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -56,7 +56,7 @@
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *req_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -83,6 +83,8 @@ struct virtio_balloon {
 	unsigned int nr_page_bmap;
 	/* Used to record the processed pfn range */
 	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
+	/* Request header */
+	struct virtio_balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -552,6 +554,63 @@ static void update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(available));
 }
 
+static void send_unused_pages_info(struct virtio_balloon *vb,
+				unsigned long req_id)
+{
+	struct scatterlist sg_in;
+	unsigned long pfn = 0, bmap_len, pfn_limit, last_pfn, nr_pfn;
+	struct virtqueue *vq = vb->req_vq;
+	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
+	int ret = 1, used_nr_bmap = 0, i;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP) &&
+		vb->nr_page_bmap == 1)
+		extend_page_bitmap(vb);
+
+	pfn_limit = PFNS_PER_BMAP * vb->nr_page_bmap;
+	mutex_lock(&vb->balloon_lock);
+	last_pfn = get_max_pfn();
+
+	while (ret) {
+		clear_page_bitmap(vb);
+		ret = get_unused_pages(pfn, pfn + pfn_limit, vb->page_bitmap,
+			 PFNS_PER_BMAP, vb->nr_page_bmap);
+		if (ret < 0)
+			break;
+		hdr->cmd = BALLOON_GET_UNUSED_PAGES;
+		hdr->id = req_id;
+		bmap_len = BALLOON_BMAP_SIZE * vb->nr_page_bmap;
+
+		if (!ret) {
+			hdr->flag = BALLOON_FLAG_DONE;
+			nr_pfn = last_pfn - pfn;
+			used_nr_bmap = nr_pfn / PFNS_PER_BMAP;
+			if (nr_pfn % PFNS_PER_BMAP)
+				used_nr_bmap++;
+			bmap_len = nr_pfn / BITS_PER_BYTE;
+		} else {
+			hdr->flag = BALLOON_FLAG_CONT;
+			used_nr_bmap = vb->nr_page_bmap;
+		}
+		for (i = 0; i < used_nr_bmap; i++) {
+			unsigned int bmap_size = BALLOON_BMAP_SIZE;
+
+			if (i + 1 == used_nr_bmap)
+				bmap_size = bmap_len - BALLOON_BMAP_SIZE * i;
+			set_bulk_pages(vb, vq, pfn + i * PFNS_PER_BMAP,
+				 vb->page_bitmap[i], bmap_size, true);
+		}
+		if (vb->resp_pos > 0)
+			send_resp_data(vb, vq, true);
+		pfn += pfn_limit;
+	}
+
+	mutex_unlock(&vb->balloon_lock);
+	sg_init_one(&sg_in, &vb->req_hdr, sizeof(vb->req_hdr));
+	virtqueue_add_inbuf(vq, &sg_in, 1, &vb->req_hdr, GFP_KERNEL);
+	virtqueue_kick(vq);
+}
+
 /*
  * While most virtqueues communicate guest-initiated requests to the hypervisor,
  * the stats queue operates in reverse.  The driver initializes the virtqueue
@@ -686,18 +745,56 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void misc_handle_rq(struct virtio_balloon *vb)
+{
+	struct virtio_balloon_req_hdr *ptr_hdr;
+	unsigned int len;
+
+	ptr_hdr = virtqueue_get_buf(vb->req_vq, &len);
+	if (!ptr_hdr || len != sizeof(vb->req_hdr))
+		return;
+
+	switch (ptr_hdr->cmd) {
+	case BALLOON_GET_UNUSED_PAGES:
+		send_unused_pages_info(vb, ptr_hdr->param);
+		break;
+	default:
+		break;
+	}
+}
+
+static void misc_request(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+
+	misc_handle_rq(vb);
+}
+
 static int init_vqs(struct virtio_balloon *vb)
 {
-	struct virtqueue *vqs[3];
-	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack, stats_request };
-	static const char * const names[] = { "inflate", "deflate", "stats" };
+	struct virtqueue *vqs[4];
+	vq_callback_t *callbacks[] = { balloon_ack, balloon_ack,
+					 stats_request, misc_request };
+	static const char * const names[] = { "inflate", "deflate", "stats",
+						 "misc" };
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
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
+	}
+
 	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
 	if (err)
 		return err;
@@ -718,6 +815,18 @@ static int init_vqs(struct virtio_balloon *vb)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ)) {
+		struct scatterlist sg_in;
+
+		vb->req_vq = vqs[3];
+		sg_init_one(&sg_in, &vb->req_hdr, sizeof(vb->req_hdr));
+		if (virtqueue_add_inbuf(vb->req_vq, &sg_in, 1,
+		    &vb->req_hdr, GFP_KERNEL) < 0)
+			__virtio_clear_bit(vb->vdev,
+					VIRTIO_BALLOON_F_HOST_REQ_VQ);
+		else
+			virtqueue_kick(vb->req_vq);
+	}
 	return 0;
 }
 
@@ -851,11 +960,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->resp_hdr = kzalloc(sizeof(struct virtio_balloon_resp_hdr),
 				 GFP_KERNEL);
 	/* Clear the feature bit if memory allocation fails */
-	if (!vb->resp_hdr)
+	if (!vb->resp_hdr) {
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
-	else {
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
+	} else {
 		vb->page_bitmap[0] = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
 		if (!vb->page_bitmap[0]) {
+			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
 			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
 			kfree(vb->resp_hdr);
 		} else {
@@ -864,6 +975,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 			if (!vb->resp_data) {
 				__virtio_clear_bit(vdev,
 						VIRTIO_BALLOON_F_PAGE_BITMAP);
+				__virtio_clear_bit(vdev,
+						VIRTIO_BALLOON_F_HOST_REQ_VQ);
 				kfree(vb->page_bitmap[0]);
 				kfree(vb->resp_hdr);
 			}
@@ -987,6 +1100,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_BITMAP,
+	VIRTIO_BALLOON_F_HOST_REQ_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
