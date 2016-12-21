Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 51F206B0375
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 01:59:00 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 127so7048026pfg.5
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 22:59:00 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id b13si9325132pll.7.2016.12.20.22.58.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 22:58:59 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v6 kernel 5/5] virtio-balloon: tell host vm's unused page info
Date: Wed, 21 Dec 2016 14:52:28 +0800
Message-Id: <1482303148-22059-6-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, mst@redhat.com, david@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>

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
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 144 ++++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h              |   3 +
 mm/page_alloc.c                 | 120 +++++++++++++++++++++++++++++++++
 3 files changed, 261 insertions(+), 6 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 03383b3..b67f865 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -56,7 +56,7 @@
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *req_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -85,6 +85,8 @@ struct virtio_balloon {
 	unsigned int nr_page_bmap;
 	/* Used to record the processed pfn range */
 	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
+	/* Request header */
+	struct virtio_balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -505,6 +507,80 @@ static void update_balloon_stats(struct virtio_balloon *vb)
 				pages_to_bytes(available));
 }
 
+static void __send_unused_pages(struct virtio_balloon *vb,
+	unsigned long req_id, unsigned int pos, bool done)
+{
+	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
+	struct virtqueue *vq = vb->req_vq;
+
+	vb->resp_pos = pos;
+	hdr->cmd = BALLOON_GET_UNUSED_PAGES;
+	hdr->id = req_id;
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
+				unsigned long req_id)
+{
+	struct scatterlist sg_in;
+	unsigned int pos = 0;
+	struct virtqueue *vq = vb->req_vq;
+	int ret, order;
+	struct zone *zone = NULL;
+	bool part_fill = false;
+
+	mutex_lock(&vb->balloon_lock);
+
+	for (order = MAX_ORDER - 1; order >= 0; order--) {
+		ret = mark_unused_pages(&zone, order, vb->resp_data,
+			 vb->resp_buf_size / sizeof(__le64),
+			 &pos, VIRTIO_BALLOON_NR_PFN_BITS, part_fill);
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
 /*
  * While most virtqueues communicate guest-initiated requests to the hypervisor,
  * the stats queue operates in reverse.  The driver initializes the virtqueue
@@ -639,11 +715,38 @@ static void update_balloon_size_func(struct work_struct *work)
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
+		send_unused_pages(vb, ptr_hdr->param);
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
@@ -651,6 +754,18 @@ static int init_vqs(struct virtio_balloon *vb)
 	 * optionally stat.
 	 */
 	nvqs = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ) ? 3 : 2;
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ))
+		nvqs = 4;
+	else if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ))
+		nvqs = 3;
+	else
+		nvqs = 2;
+
+	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_STATS_VQ)) {
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_PAGE_RANGE);
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
+	}
+
 	err = vb->vdev->config->find_vqs(vb->vdev, nvqs, vqs, callbacks, names);
 	if (err)
 		return err;
@@ -671,6 +786,18 @@ static int init_vqs(struct virtio_balloon *vb)
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
 
@@ -802,12 +929,14 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->resp_hdr = kzalloc(sizeof(struct virtio_balloon_resp_hdr),
 				 GFP_KERNEL);
 	/* Clear the feature bit if memory allocation fails */
-	if (!vb->resp_hdr)
+	if (!vb->resp_hdr) {
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_RANGE);
-	else {
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
+	} else {
 		vb->page_bitmap[0] = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
 		if (!vb->page_bitmap[0]) {
 			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_RANGE);
+			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
 			kfree(vb->resp_hdr);
 		} else {
 			vb->nr_page_bmap = 1;
@@ -815,6 +944,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 			if (!vb->resp_data) {
 				__virtio_clear_bit(vdev,
 						VIRTIO_BALLOON_F_PAGE_RANGE);
+				__virtio_clear_bit(vdev,
+						VIRTIO_BALLOON_F_HOST_REQ_VQ);
 				kfree(vb->page_bitmap[0]);
 				kfree(vb->resp_hdr);
 			}
@@ -941,6 +1072,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_PAGE_RANGE,
+	VIRTIO_BALLOON_F_HOST_REQ_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 4424784..a80b8f3 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1762,6 +1762,9 @@ static inline spinlock_t *pmd_lock(struct mm_struct *mm, pmd_t *pmd)
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern int mark_unused_pages(struct zone **start_zone, int order,
+		__le64 *pages, unsigned int size, unsigned int *pos,
+		u8 len_bits, bool part_fill);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2c6d5f6..de0e7a4 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4479,6 +4479,126 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+static int  __mark_unused_pages(struct zone *zone, int order,
+		__le64 *pages, unsigned int size, unsigned int *pos,
+		u8 len_bits, bool part_fill)
+{
+	unsigned long pfn, flags;
+	int t, ret = 0;
+	struct list_head *curr;
+	__le64 *range;
+
+	if (zone_is_empty(zone))
+		return 0;
+
+	spin_lock_irqsave(&zone->lock, flags);
+
+	if (*pos + zone->free_area[order].nr_free > size && !part_fill) {
+		ret = -ENOSPC;
+		goto out;
+	}
+	for (t = 0; t < MIGRATE_TYPES; t++) {
+		list_for_each(curr, &zone->free_area[order].free_list[t]) {
+			pfn = page_to_pfn(list_entry(curr, struct page, lru));
+			range = pages + *pos;
+			if (order < len_bits) {
+				if (*pos + 1 > size) {
+					ret = -ENOSPC;
+					goto out;
+				}
+				*range = cpu_to_le64((pfn << len_bits)
+							| 1 << order);
+				*pos += 1;
+			} else {
+				if (*pos + 2 > size) {
+					ret = -ENOSPC;
+					goto out;
+				}
+				*range = cpu_to_le64((pfn << len_bits) | 0);
+				*(range + 1) = cpu_to_le64(1 << order);
+				*pos += 2;
+			}
+		}
+	}
+
+out:
+	spin_unlock_irqrestore(&zone->lock, flags);
+
+	return ret;
+}
+
+/*
+ * During live migration, page is discardable unless it's content
+ * is needed by the system.
+ * mark_unused_pages provides an API to mark the unused pages, these
+ * unused pages can be discarded if there is no modification since
+ * the request. Some other mechanism, like the dirty page logging
+ * can be used to track the modification.
+ *
+ * This function scans the free page list to mark the unused pages
+ * with the specified order, and set the corresponding range element
+ * in the array 'pages' if unused pages are found for the specified
+ * order.
+ *
+ * @start_zone: zone to start the mark operation.
+ * @order: page order to mark.
+ * @pages: array to save the unused page info.
+ * @size: size of array pages.
+ * @pos: offset in the array to save the page info.
+ * @len_bits: bits for the length field of the range.
+ * @part_fill: indicate if partial fill is used.
+ *
+ * return -EINVAL if parameter is invalid
+ * return -ENOSPC when bitmap can't contain the pages
+ * return 0 when sccess
+ */
+int mark_unused_pages(struct zone **start_zone, int order,
+	__le64 *pages, unsigned int size, unsigned int *pos,
+	u8 len_bits, bool part_fill)
+{
+	struct zone *zone;
+	int ret = 0;
+	bool skip_check = false;
+
+	/* make sure all the parameters are valid */
+	if (pages == NULL || pos == NULL || *pos < 0
+		|| order >= MAX_ORDER || len_bits > 64)
+		return -EINVAL;
+	if (*start_zone != NULL) {
+		bool found = false;
+
+		for_each_populated_zone(zone) {
+			if (zone != *start_zone)
+				continue;
+			found = true;
+			break;
+		}
+		if (!found)
+			return -EINVAL;
+	} else
+		skip_check = true;
+
+	for_each_populated_zone(zone) {
+		/* Start from *start_zone if it's not NULL */
+		if (!skip_check) {
+			if (*start_zone != zone)
+				continue;
+			else
+				skip_check = true;
+		}
+		ret = __mark_unused_pages(zone, order, pages, size,
+					pos, len_bits, part_fill);
+		if (ret < 0) {
+			/* record the failed zone */
+			*start_zone = zone;
+			break;
+		}
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(mark_unused_pages);
+
 static void zoneref_set_zone(struct zone *zone, struct zoneref *zoneref)
 {
 	zoneref->zone = zone;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
