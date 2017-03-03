Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CCB016B0399
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 00:44:31 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id d18so116706036pgh.2
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 21:44:31 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b35si9546908plh.95.2017.03.02.21.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 21:44:30 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v7 kernel 5/5] This patch contains two parts:
Date: Fri,  3 Mar 2017 13:40:30 +0800
Message-Id: <1488519630-89058-6-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Liang Li <liang.z.li@intel.com>, Wei Wang <wei.w.wang@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Michael S . Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>

From: Liang Li <liang.z.li@intel.com>

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
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@techsingularity.net>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Liang Li <liliang324@gmail.com>
Cc: Wei Wang <wei.w.wang@intel.com>
---
 drivers/virtio/virtio_balloon.c | 137 ++++++++++++++++++++++++++++++++++++++--
 include/linux/mm.h              |   3 +
 mm/page_alloc.c                 | 120 +++++++++++++++++++++++++++++++++++
 3 files changed, 255 insertions(+), 5 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 4416370..9b6cf44f 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -66,7 +66,7 @@ struct balloon_page_chunk_ext {
 
 struct virtio_balloon {
 	struct virtio_device *vdev;
-	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
+	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq, *host_req_vq;
 
 	/* The balloon servicing is delegated to a freezable workqueue. */
 	struct work_struct update_balloon_stats_work;
@@ -95,6 +95,8 @@ struct virtio_balloon {
 	unsigned int nr_page_bmap;
 	/* Used to record the processed pfn range */
 	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
+	/* Request header */
+	struct virtio_balloon_req_hdr req_hdr;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -549,6 +551,80 @@ static void stats_handle_request(struct virtio_balloon *vb)
 	virtqueue_kick(vq);
 }
 
+static void __send_unused_pages(struct virtio_balloon *vb,
+	unsigned long req_id, unsigned int pos, bool done)
+{
+	struct virtio_balloon_resp_hdr *hdr = &vb->resp_hdr;
+	struct virtqueue *vq = vb->host_req_vq;
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
+	struct virtqueue *vq = vb->host_req_vq;
+	int ret, order;
+	struct zone *zone = NULL;
+	bool part_fill = false;
+
+	mutex_lock(&vb->balloon_lock);
+
+	for (order = MAX_ORDER - 1; order >= 0; order--) {
+		ret = mark_unused_pages(&zone, order, vb->resp_data,
+			 vb->resp_buf_size / sizeof(__le64),
+			 &pos, VIRTIO_BALLOON_CHUNK_SIZE_SHIFT, part_fill);
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
@@ -648,18 +724,51 @@ static void update_balloon_size_func(struct work_struct *work)
 		queue_work(system_freezable_wq, work);
 }
 
+static void handle_host_request(struct virtqueue *vq)
+{
+	struct virtio_balloon *vb = vq->vdev->priv;
+	struct virtio_balloon_req_hdr *ptr_hdr;
+	unsigned int len;
+
+	ptr_hdr = virtqueue_get_buf(vb->host_req_vq, &len);
+	if (!ptr_hdr || len != sizeof(vb->req_hdr))
+		return;
+
+	switch (ptr_hdr->cmd) {
+	case BALLOON_GET_UNUSED_PAGES:
+		send_unused_pages(vb, ptr_hdr->param);
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: host request %d not supported \n",
+						 __func__, ptr_hdr->cmd);
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
@@ -680,6 +789,20 @@ static int init_vqs(struct virtio_balloon *vb)
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
+		    &vb->req_hdr, GFP_KERNEL) < 0)
+			__virtio_clear_bit(vb->vdev,
+					VIRTIO_BALLOON_F_HOST_REQ_VQ);
+		else
+			virtqueue_kick(vb->host_req_vq);
+	}
+
 	return 0;
 }
 
@@ -812,12 +935,15 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vb->page_bitmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
 	if (!vb->page_bitmap[0]) {
 		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_HOST_REQ_VQ);
 	} else {
 		vb->nr_page_bmap = 1;
 		vb->resp_data = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
 		if (!vb->resp_data) {
 			__virtio_clear_bit(vdev,
 					VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+			__virtio_clear_bit(vdev,
+					VIRTIO_BALLOON_F_HOST_REQ_VQ);
 			kfree(vb->page_bitmap[0]);
 		}
 	}
@@ -944,6 +1070,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
 	VIRTIO_BALLOON_F_CHUNK_TRANSFER,
+	VIRTIO_BALLOON_F_HOST_REQ_VQ,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b84615b..c9ad89c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1764,6 +1764,9 @@ extern void free_area_init(unsigned long * zones_size);
 extern void free_area_init_node(int nid, unsigned long * zones_size,
 		unsigned long zone_start_pfn, unsigned long *zholes_size);
 extern void free_initmem(void);
+extern int mark_unused_pages(struct zone **start_zone, int order,
+		__le64 *pages, unsigned int size, unsigned int *pos,
+		u8 len_bits, bool part_fill);
 
 /*
  * Free reserved pages within range [PAGE_ALIGN(start), end & PAGE_MASK)
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f3e0c69..f0573b1 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4498,6 +4498,126 @@ void show_free_areas(unsigned int filter)
 	show_swap_cache_info();
 }
 
+static int __mark_unused_pages(struct zone *zone, int order,
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
