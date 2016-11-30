Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 63F496B0266
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:58:29 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g186so10261921pgc.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:58:29 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id 67si7280519pgb.337.2016.11.30.00.58.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 00:58:28 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v5 5/5] virtio-balloon: tell host vm's unused page info
Date: Wed, 30 Nov 2016 16:43:17 +0800
Message-Id: <1480495397-23225-6-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, mst@redhat.com, jasowang@redhat.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, pbonzini@redhat.com, Liang Li <liang.z.li@intel.com>, Mel Gorman <mgorman@techsingularity.net>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

This patch contains two parts:

One is to add a new API to mm go get the unused page information.
The virtio balloon driver will use this new API added to get the
unused page info and send it to hypervisor(QEMU) to speed up live
migration. During sending the bitmap, some the pages may be modified
and are used by the guest, this inaccuracy can be corrected by the
dirty page logging mechanism.

One is to add support the request for vm's unused page information,
QEMU can make use of unused page information and the dirty page
logging mechanism to skip the transportation of some of these unused
pages, this is very helpful to reduce the network traffic and speed
up the live migration process.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 drivers/virtio/virtio_balloon.c | 126 +++++++++++++++++++++++++++++++++++++---
 include/linux/mm.h              |   3 +-
 mm/page_alloc.c                 |  72 +++++++++++++++++++++++
 3 files changed, 193 insertions(+), 8 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index c3ddec3..2626cc0 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -56,7 +56,7 @@
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *req_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -75,6 +75,8 @@ struct virtio_balloon {
 	void *resp_hdr;
 	/* Pointer to the start address of response data. */
 	unsigned long *resp_data;
+	/* Size of response data buffer. */
+	unsigned long resp_buf_size;
 	/* Pointer offset of the response data. */
 	unsigned long resp_pos;
 	/* Bitmap and bitmap count used to tell the host the pages */
@@ -83,6 +85,8 @@ struct virtio_balloon {
 	unsigned int nr_page_bmap;
 	/* Used to record the processed pfn range */
 	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
+	/* Request header */
+	struct virtio_balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -551,6 +555,58 @@ static void update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(available));
 }
 
+static void send_unused_pages_info(struct virtio_balloon *vb,
+				unsigned long req_id)
+{
+	struct scatterlist sg_in;
+	unsigned long pos = 0;
+	struct virtqueue *vq = vb->req_vq;
+	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
+	int ret, order;
+
+	mutex_lock(&vb->balloon_lock);
+
+	for (order = MAX_ORDER - 1; order >= 0; order--) {
+		pos = 0;
+		ret = get_unused_pages(vb->resp_data,
+			 vb->resp_buf_size / sizeof(unsigned long),
+			 order, &pos);
+		if (ret == -ENOSPC) {
+			void *new_resp_data;
+
+			new_resp_data = kmalloc(2 * vb->resp_buf_size,
+						GFP_KERNEL);
+			if (new_resp_data) {
+				kfree(vb->resp_data);
+				vb->resp_data = new_resp_data;
+				vb->resp_buf_size *= 2;
+				order++;
+				continue;
+			} else
+				dev_warn(&vb->vdev->dev,
+					 "%s: omit some %d order pages\n",
+					 __func__, order);
+		}
+
+		if (pos > 0) {
+			vb->resp_pos = pos;
+			hdr->cmd = BALLOON_GET_UNUSED_PAGES;
+			hdr->id = req_id;
+			if (order > 0)
+				hdr->flag = BALLOON_FLAG_CONT;
+			else
+				hdr->flag = BALLOON_FLAG_DONE;
+
+			send_resp_data(vb, vq, true);
+		}
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
@@ -685,18 +741,56 @@ static void update_balloon_size_func(struct work_struct *work)
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
@@ -717,6 +811,18 @@ static int init_vqs(struct virtio_balloon *vb)
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
 
@@ -850,11 +956,13 @@ static int virtballoon_probe(struct virtio_device *vdev)
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
@@ -863,12 +971,15 @@ static int virtballoon_probe(struct virtio_device *vdev)
 			if (!vb->resp_data) {
 				__virtio_clear_bit(vdev,
 						VIRTIO_BALLOON_F_PAGE_BITMAP);
+				__virtio_clear_bit(vdev,
+						VIRTIO_BALLOON_F_HOST_REQ_VQ);
 				kfree(vb->page_bitmap[0]);
 				kfree(vb->resp_hdr);
 			}
 		}
 	}
 	vb->resp_pos = 0;
+	vb->resp_buf_size = BALLOON_BMAP_SIZE;
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -988,6 +1099,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_BITMAP,
+	VIRTIO_BALLOON_F_HOST_REQ_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..e05ca86 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1772,7 +1772,8 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
-
+extern int get_unused_pages(unsigned long *unused_pages, unsigned long size,
+				int order, unsigned long *pos);
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
  * into the buddy system. The freed pages will be poisoned with pattern
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..d5a5952 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4428,6 +4428,78 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+struct page_info_item {
+	__le64 start_pfn : 52; /* start pfn for the bitmap */
+	__le64 page_shift : 6; /* page shift width, in bytes */
+	__le64 bmap_len : 6;  /* bitmap length, in bytes */
+};
+
+static int  mark_unused_pages(struct zone *zone,
+		unsigned long *unused_pages, unsigned long size,
+		int order, unsigned long *pos)
+{
+	unsigned long pfn, flags;
+	unsigned int t;
+	struct list_head *curr;
+	struct page_info_item *info;
+
+	if (zone_is_empty(zone))
+		return 0;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	if (*pos + zone->free_area[order].nr_free > size)
+		return -ENOSPC;
+	for (t = 0; t < MIGRATE_TYPES; t++) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			info = (struct page_info_item *)(unused_pages + *pos);
+			info->start_pfn = pfn;
+			info->page_shift = order + PAGE_SHIFT;
+			*pos += 1;
+		}
+	}
+
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return 0;
+}
+
+/*
+ * During live migration, page is always discardable unless it's
+ * content is needed by the system.
+ * get_unused_pages provides an API to get the unused pages, these
+ * unused pages can be discarded if there is no modification since
+ * the request. Some other mechanism, like the dirty page logging
+ * can be used to track the modification.
+ *
+ * This function scans the free page list to get the unused pages
+ * with the specified order, and set the corresponding element in
+ * the bitmap if an unused page is found.
+ *
+ * return -EINVAL if parameters are invalid
+ * return -ENOSPC when bitmap can't contain the pages
+ * return 0 when sccess
+ */
+int get_unused_pages(unsigned long *unused_pages, unsigned long size,
+		int order, unsigned long *pos)
+{
+	struct zone *zone;
+	int ret = 0;
+
+	if (unused_pages == NULL || pos == NULL || *pos < 0)
+		return -EINVAL;
+
+	for_each_populated_zone(zone) {
+		ret = mark_unused_pages(zone, unused_pages, size, order, pos);
+		if (ret < 0)
+			break;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(get_unused_pages);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
