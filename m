Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id D8D65280250
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:37:25 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id t25so45012210pfg.3
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:37:25 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id y4si1038614pab.169.2016.10.20.23.37.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 23:37:24 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND PATCH v3 kernel 7/7] virtio-balloon: tell host vm's unused page info
Date: Fri, 21 Oct 2016 14:24:40 +0800
Message-Id: <1477031080-12616-8-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Liang Li <liang.z.li@intel.com>

Support the request for vm's unused page information, response with
a page bitmap. QEMU can make use of this bitmap and the dirty page
logging mechanism to skip the transportation of these unused pages,
this is very helpful to speed up the live migration process.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 143 +++++++++++++++++++++++++++++++++++++---
 1 file changed, 134 insertions(+), 9 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index c31839c..f10bb8b 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -56,7 +56,7 @@
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *misc_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -78,6 +78,8 @@ struct virtio_balloon {
 	unsigned int nr_page_bmap;
 	/* Used to record the processed pfn range */
 	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
+	/* Request header */
+	struct balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -423,6 +425,78 @@ static void update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(available));
 }
 
+static void send_unused_pages_info(struct virtio_balloon *vb,
+				unsigned long req_id)
+{
+	struct scatterlist sg_in, sg_out[BALLOON_BMAP_COUNT + 1];
+	unsigned long pfn = 0, bmap_len, pfn_limit, last_pfn, nr_pfn;
+	struct virtqueue *vq = vb->misc_vq;
+	struct balloon_bmap_hdr *hdr = vb->bmap_hdr;
+	int ret = 1, nr_buf, used_nr_bmap = 0, i;
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
+		hdr->cmd = cpu_to_virtio16(vb->vdev, BALLOON_GET_UNUSED_PAGES);
+		hdr->page_shift = cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
+		hdr->req_id = cpu_to_virtio64(vb->vdev, req_id);
+		hdr->start_pfn = cpu_to_virtio64(vb->vdev, pfn);
+		bmap_len = BALLOON_BMAP_SIZE * vb->nr_page_bmap;
+
+		if (!ret) {
+			hdr->flag = cpu_to_virtio16(vb->vdev,
+						 BALLOON_FLAG_DONE);
+			nr_pfn = last_pfn - pfn;
+			used_nr_bmap = nr_pfn / PFNS_PER_BMAP;
+			if (nr_pfn % PFNS_PER_BMAP)
+				used_nr_bmap++;
+			bmap_len = nr_pfn / BITS_PER_BYTE;
+		} else {
+			hdr->flag = cpu_to_virtio16(vb->vdev,
+							BALLOON_FLAG_CONT);
+			used_nr_bmap = vb->nr_page_bmap;
+		}
+		hdr->bmap_len = cpu_to_virtio64(vb->vdev, bmap_len);
+		nr_buf = used_nr_bmap + 1;
+		sg_init_table(sg_out, nr_buf);
+		sg_set_buf(&sg_out[0], hdr, sizeof(struct balloon_bmap_hdr));
+		for (i = 0; i < used_nr_bmap; i++) {
+			unsigned int buf_len = BALLOON_BMAP_SIZE;
+
+			if (i + 1 == used_nr_bmap)
+				buf_len = bmap_len - BALLOON_BMAP_SIZE * i;
+			sg_set_buf(&sg_out[i + 1], vb->page_bitmap[i], buf_len);
+		}
+
+		while (vq->num_free < nr_buf)
+			msleep(2);
+		if (virtqueue_add_outbuf(vq, sg_out, nr_buf, vb,
+				 GFP_KERNEL) == 0) {
+			virtqueue_kick(vq);
+			while (!virtqueue_get_buf(vq, &i)
+				&& !virtqueue_is_broken(vq))
+				cpu_relax();
+		}
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
@@ -563,18 +637,56 @@ static void update_balloon_size_func(struct work_struct *work)
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
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ))
+		nvqs = 4;
+	else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		nvqs = 3;
+	else
+		nvqs = 2;
+
+	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_MISC_VQ);
+	}
+
 	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
 	if (err)
 		return err;
@@ -595,6 +707,16 @@ static int init_vqs(struct virtio_balloon *vb)
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
 
@@ -703,13 +825,15 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->num_pages = 0;
 	vb->bmap_hdr = kzalloc(sizeof(struct balloon_bmap_hdr), GFP_KERNEL);
 	/* Clear the feature bit if memory allocation fails */
-	if (!vb->bmap_hdr)
+	if (!vb->bmap_hdr) {
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
-	else {
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_MISC_VQ);
+	} else {
 		vb->page_bitmap[0] = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
-		if (!vb->page_bitmap[0])
+		if (!vb->page_bitmap[0]) {
 			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
-		else
+			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_MISC_VQ);
+		} else
 			vb->nr_page_bmap = 1;
 	}
 	mutex_init(&vb->balloon_lock);
@@ -832,6 +956,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_BITMAP,
+	VIRTIO_BALLOON_F_MISC_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
