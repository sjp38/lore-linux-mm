Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 96420828E4
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 21:31:47 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id h186so17730190pfg.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 18:31:47 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id u87si3439128pfa.1.2016.07.26.18.31.46
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 18:31:46 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v2 repost 7/7] virtio-balloon: tell host vm's free page info
Date: Wed, 27 Jul 2016 09:23:36 +0800
Message-Id: <1469582616-5729-8-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
References: <1469582616-5729-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>, "Michael S. Tsirkin" <mst@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

Support the request for vm's free page information, response with
a page bitmap. QEMU can make use of this free page bitmap to speed
up live migration process by skipping process the free pages.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 104 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 98 insertions(+), 6 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 2d18ff6..5ca4ad3 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -62,10 +62,13 @@ module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 
 extern unsigned long get_max_pfn(void);
+extern int get_free_pages(unsigned long start_pfn, unsigned long end_pfn,
+		unsigned long *bitmap, unsigned long len);
+
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *misc_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -89,6 +92,8 @@ struct virtio_balloon {
 	unsigned long pfn_limit;
 	/* Used to record the processed pfn range */
 	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
+	/* Request header */
+	struct balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -373,6 +378,49 @@ static void update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(available));
 }
 
+static void update_free_pages_stats(struct virtio_balloon *vb,
+				unsigned long req_id)
+{
+	struct scatterlist sg_in, sg_out;
+	unsigned long pfn = 0, bmap_len, max_pfn;
+	struct virtqueue *vq = vb->misc_vq;
+	struct balloon_bmap_hdr *hdr = vb->bmap_hdr;
+	int ret = 1;
+
+	max_pfn = get_max_pfn();
+	mutex_lock(&vb->balloon_lock);
+	while (pfn < max_pfn) {
+		memset(vb->page_bitmap, 0, vb->bmap_len);
+		ret = get_free_pages(pfn, pfn + vb->pfn_limit,
+			vb->page_bitmap, vb->bmap_len * BITS_PER_BYTE);
+		hdr->cmd = cpu_to_virtio16(vb->vdev, BALLOON_GET_FREE_PAGES);
+		hdr->page_shift = cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
+		hdr->req_id = cpu_to_virtio64(vb->vdev, req_id);
+		hdr->start_pfn = cpu_to_virtio64(vb->vdev, pfn);
+		bmap_len = vb->pfn_limit / BITS_PER_BYTE;
+		if (!ret) {
+			hdr->flag = cpu_to_virtio16(vb->vdev,
+							BALLOON_FLAG_DONE);
+			if (pfn + vb->pfn_limit > max_pfn)
+				bmap_len = (max_pfn - pfn) / BITS_PER_BYTE;
+		} else
+			hdr->flag = cpu_to_virtio16(vb->vdev,
+							BALLOON_FLAG_CONT);
+		hdr->bmap_len = cpu_to_virtio64(vb->vdev, bmap_len);
+		sg_init_one(&sg_out, hdr,
+			 sizeof(struct balloon_bmap_hdr) + bmap_len);
+
+		virtqueue_add_outbuf(vq, &sg_out, 1, vb, GFP_KERNEL);
+		virtqueue_kick(vq);
+		pfn += vb->pfn_limit;
+	}
+
+	sg_init_one(&sg_in, &vb->req_hdr, sizeof(vb->req_hdr));
+	virtqueue_add_inbuf(vq, &sg_in, 1, &vb->req_hdr, GFP_KERNEL);
+	virtqueue_kick(vq);
+	mutex_unlock(&vb->balloon_lock);
+}
+
 /*
  * While most virtqueues communicate guest-initiated requests to the hypervisor,
  * the stats queue operates in reverse.  The driver initializes the virtqueue
@@ -511,18 +559,49 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void misc_handle_rq(struct virtio_balloon *vb)
+{
+	struct balloon_req_hdr *ptr_hdr;
+	unsigned int len;
+
+	ptr_hdr = virtqueue_get_buf(vb->misc_vq, &len);
+	if (!ptr_hdr || len != sizeof(vb->req_hdr))
+		return;
+
+	switch (ptr_hdr->cmd) {
+	case BALLOON_GET_FREE_PAGES:
+		update_free_pages_stats(vb, ptr_hdr->param);
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
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ))
+		nvqs = 4;
+	else
+		nvqs = virtio_has_feature(vb->vdev,
+					  VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
 	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
 	if (err)
 		return err;
@@ -543,6 +622,16 @@ static int init_vqs(struct virtio_balloon *vb)
 			BUG();
 		virtqueue_kick(vb->stats_vq);
 	}
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ)) {
+		struct scatterlist sg_in;
+
+		vb->misc_vq = vqs[3];
+		sg_init_one(&sg_in, &vb->req_hdr, sizeof(vb->req_hdr));
+		if (virtqueue_add_inbuf(vb->misc_vq, &sg_in, 1,
+		    &vb->req_hdr, GFP_KERNEL) < 0)
+			BUG();
+		virtqueue_kick(vb->misc_vq);
+	}
 	return 0;
 }
 
@@ -639,8 +728,10 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->bmap_hdr = kzalloc(hdr_len + vb->bmap_len, GFP_KERNEL);
 
 	/* Clear the feature bit if memory allocation fails */
-	if (!vb->bmap_hdr)
+	if (!vb->bmap_hdr) {
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_MISC_VQ);
+	}
 	else
 		vb->page_bitmap = vb->bmap_hdr + hdr_len;
 	mutex_init(&vb->balloon_lock);
@@ -743,6 +834,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_BITMAP,
+	VIRTIO_BALLOON_F_MISC_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
