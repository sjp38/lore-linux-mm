Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3F14A6B0373
	for <linux-mm@kvack.org>; Wed, 21 Dec 2016 01:58:47 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 5so351776147pgi.2
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 22:58:47 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id n6si25552574pla.24.2016.12.20.22.58.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 22:58:46 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH v6 kernel 3/5] virtio-balloon: speed up inflate/deflate process
Date: Wed, 21 Dec 2016 14:52:26 +0800
Message-Id: <1482303148-22059-4-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
References: <1482303148-22059-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, amit.shah@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, pbonzini@redhat.com, mst@redhat.com, david@redhat.com, aarcange@redhat.com, dgilbert@redhat.com, quintela@redhat.com, Liang Li <liang.z.li@intel.com>

The implementation of the current virtio-balloon is not very
efficient, the time spends on different stages of inflating
the balloon to 7GB of a 8GB idle guest:

a. allocating pages (6.5%)
b. sending PFNs to host (68.3%)
c. address translation (6.1%)
d. madvise (19%)

It takes about 4126ms for the inflating process to complete.
Debugging shows that the bottle neck are the stage b and stage d.

If using {pfn|length} array to send the page info instead of the
PFNs, we can reduce the overhead in stage b quite a lot.
Furthermore, we can do the address translation and call madvise()
with a range of memory, instead of the current page per page way,
the overhead of stage c and stage d can also be reduced a lot.

This patch is the kernel side implementation which is intended to
speed up the inflating & deflating process by adding a new feature
to the virtio-balloon device. With this new feature, inflating the
balloon to 7GB of a 8GB idle guest only takes 590ms, the
performance improvement is about 85%.

TODO: optimize stage a by allocating/freeing a chunk of pages
instead of a single page at a time.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
---
 drivers/virtio/virtio_balloon.c | 348 ++++++++++++++++++++++++++++++++++++----
 1 file changed, 320 insertions(+), 28 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f59cb4f..03383b3 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -42,6 +42,10 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+#define BALLOON_BMAP_SIZE	(8 * PAGE_SIZE)
+#define PFNS_PER_BMAP		(BALLOON_BMAP_SIZE * BITS_PER_BYTE)
+#define BALLOON_BMAP_COUNT	32
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -67,6 +71,20 @@ struct virtio_balloon {
 
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+	/* Pointer to the response header. */
+	void *resp_hdr;
+	/* Pointer to the start address of response data. */
+	__le64 *resp_data;
+	/* Size of response data buffer. */
+	unsigned int resp_buf_size;
+	/* Pointer offset of the response data. */
+	unsigned int resp_pos;
+	/* Bitmap used to save the pfns info */
+	unsigned long *page_bitmap[BALLOON_BMAP_COUNT];
+	/* Number of split page bitmaps */
+	unsigned int nr_page_bmap;
+	/* Used to record the processed pfn range */
+	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -110,20 +128,180 @@ static void balloon_ack(struct virtqueue *vq)
 	wake_up(&vb->acked);
 }
 
-static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
+static inline void init_bmap_pfn_range(struct virtio_balloon *vb)
 {
-	struct scatterlist sg;
+	vb->min_pfn = ULONG_MAX;
+	vb->max_pfn = 0;
+}
+
+static inline void update_bmap_pfn_range(struct virtio_balloon *vb,
+				 struct page *page)
+{
+	unsigned long balloon_pfn = page_to_balloon_pfn(page);
+
+	vb->min_pfn = min(balloon_pfn, vb->min_pfn);
+	vb->max_pfn = max(balloon_pfn, vb->max_pfn);
+}
+
+static void extend_page_bitmap(struct virtio_balloon *vb,
+				unsigned long nr_pfn)
+{
+	int i, bmap_count;
+	unsigned long bmap_len;
+
+	bmap_len = ALIGN(nr_pfn, BITS_PER_LONG) / BITS_PER_BYTE;
+	bmap_len = ALIGN(bmap_len, BALLOON_BMAP_SIZE);
+	bmap_count = min((int)(bmap_len / BALLOON_BMAP_SIZE),
+				 BALLOON_BMAP_COUNT);
+
+	for (i = 1; i < bmap_count; i++) {
+		vb->page_bitmap[i] = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
+		if (vb->page_bitmap[i])
+			vb->nr_page_bmap++;
+		else
+			break;
+	}
+}
+
+static void free_extended_page_bitmap(struct virtio_balloon *vb)
+{
+	int i, bmap_count = vb->nr_page_bmap;
+
+	for (i = 1; i < bmap_count; i++) {
+		kfree(vb->page_bitmap[i]);
+		vb->page_bitmap[i] = NULL;
+		vb->nr_page_bmap--;
+	}
+}
+
+static void kfree_page_bitmap(struct virtio_balloon *vb)
+{
+	int i;
+
+	for (i = 0; i < vb->nr_page_bmap; i++)
+		kfree(vb->page_bitmap[i]);
+}
+
+static void clear_page_bitmap(struct virtio_balloon *vb)
+{
+	int i;
+
+	for (i = 0; i < vb->nr_page_bmap; i++)
+		memset(vb->page_bitmap[i], 0, BALLOON_BMAP_SIZE);
+}
+
+static void send_resp_data(struct virtio_balloon *vb, struct virtqueue *vq,
+			bool busy_wait)
+{
+	struct scatterlist sg[2];
+	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
 	unsigned int len;
 
-	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	len = hdr->data_len = vb->resp_pos * sizeof(__le64);
+	sg_init_table(sg, 2);
+	sg_set_buf(&sg[0], hdr, sizeof(struct virtio_balloon_resp_hdr));
+	sg_set_buf(&sg[1], vb->resp_data, len);
+
+	if (virtqueue_add_outbuf(vq, sg, 2, vb, GFP_KERNEL) == 0) {
+		virtqueue_kick(vq);
+		if (busy_wait)
+			while (!virtqueue_get_buf(vq, &len)
+				&& !virtqueue_is_broken(vq))
+				cpu_relax();
+		else
+			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		vb->resp_pos = 0;
+		free_extended_page_bitmap(vb);
+	}
+}
 
-	/* We should always be able to add one buffer to an empty queue. */
-	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
-	virtqueue_kick(vq);
+static void do_set_resp_bitmap(struct virtio_balloon *vb,
+		unsigned long base_pfn, int pages)
 
-	/* When host has read buffer, this completes via balloon_ack */
-	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+{
+	__le64 *range = vb->resp_data + vb->resp_pos;
 
+	if (pages > (1 << VIRTIO_BALLOON_NR_PFN_BITS)) {
+		/* when the length field can't contain pages, set it to 0 to
+		 * indicate the actual length is in the next __le64;
+		 */
+		*range = cpu_to_le64((base_pfn <<
+				VIRTIO_BALLOON_NR_PFN_BITS) | 0);
+		*(range + 1) = cpu_to_le64(pages);
+		vb->resp_pos += 2;
+	} else {
+		*range = (base_pfn << VIRTIO_BALLOON_NR_PFN_BITS) | pages;
+		vb->resp_pos++;
+	}
+}
+
+static void set_bulk_pages(struct virtio_balloon *vb, struct virtqueue *vq,
+		unsigned long start_pfn, unsigned long *bitmap,
+		unsigned long len, bool busy_wait)
+{
+	unsigned long pos = 0, end = len * BITS_PER_BYTE;
+
+	while (pos < end) {
+		unsigned long one = find_next_bit(bitmap, end, pos);
+
+		if (one < end) {
+			unsigned long pages, zero;
+
+			zero = find_next_zero_bit(bitmap, end, one + 1);
+			if (zero >= end)
+				pages = end - one;
+			else
+				pages = zero - one;
+			if (pages) {
+				if ((vb->resp_pos + 2) * sizeof(__le64) >
+						vb->resp_buf_size)
+					send_resp_data(vb, vq, busy_wait);
+				do_set_resp_bitmap(vb, start_pfn + one,	pages);
+			}
+			pos = one + pages;
+		} else
+			pos = one;
+	}
+}
+
+static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
+{
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_RANGE)) {
+		int nr_pfn, nr_used_bmap, i;
+		unsigned long start_pfn, bmap_len;
+
+		start_pfn = vb->start_pfn;
+		nr_pfn = vb->end_pfn - start_pfn + 1;
+		nr_pfn = roundup(nr_pfn, BITS_PER_LONG);
+		nr_used_bmap = nr_pfn / PFNS_PER_BMAP;
+		if (nr_pfn % PFNS_PER_BMAP)
+			nr_used_bmap++;
+		bmap_len = nr_pfn / BITS_PER_BYTE;
+
+		for (i = 0; i < nr_used_bmap; i++) {
+			unsigned int bmap_size = BALLOON_BMAP_SIZE;
+
+			if (i + 1 == nr_used_bmap)
+				bmap_size = bmap_len - BALLOON_BMAP_SIZE * i;
+			set_bulk_pages(vb, vq, start_pfn + i * PFNS_PER_BMAP,
+				 vb->page_bitmap[i], bmap_size, false);
+		}
+		if (vb->resp_pos > 0)
+			send_resp_data(vb, vq, false);
+	} else {
+		struct scatterlist sg;
+		unsigned int len;
+
+		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+
+		/* We should always be able to add one buffer to an
+		 * empty queue
+		 */
+		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
+		virtqueue_kick(vq);
+		/* When host has read buffer, this completes via balloon_ack */
+		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+	}
 }
 
 static void set_page_pfns(struct virtio_balloon *vb,
@@ -138,13 +316,59 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
-static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
+static void set_page_bitmap(struct virtio_balloon *vb,
+			 struct list_head *pages, struct virtqueue *vq)
+{
+	unsigned long pfn, pfn_limit;
+	struct page *page;
+	bool found;
+	int bmap_idx;
+
+	vb->min_pfn = rounddown(vb->min_pfn, BITS_PER_LONG);
+	vb->max_pfn = roundup(vb->max_pfn, BITS_PER_LONG);
+	pfn_limit = PFNS_PER_BMAP * vb->nr_page_bmap;
+
+	if (vb->nr_page_bmap == 1)
+		extend_page_bitmap(vb, vb->max_pfn - vb->min_pfn + 1);
+	for (pfn = vb->min_pfn; pfn < vb->max_pfn; pfn += pfn_limit) {
+		unsigned long end_pfn;
+
+		clear_page_bitmap(vb);
+		vb->start_pfn = pfn;
+		end_pfn = pfn;
+		found = false;
+		list_for_each_entry(page, pages, lru) {
+			unsigned long pos, balloon_pfn;
+
+			balloon_pfn = page_to_balloon_pfn(page);
+			if (balloon_pfn < pfn || balloon_pfn >= pfn + pfn_limit)
+				continue;
+			bmap_idx = (balloon_pfn - pfn) / PFNS_PER_BMAP;
+			pos = (balloon_pfn - pfn) % PFNS_PER_BMAP;
+			set_bit(pos, vb->page_bitmap[bmap_idx]);
+			if (balloon_pfn > end_pfn)
+				end_pfn = balloon_pfn;
+			found = true;
+		}
+		if (found) {
+			vb->end_pfn = end_pfn;
+			tell_host(vb, vq);
+		}
+	}
+}
+
+static unsigned int fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
-	unsigned num_allocated_pages;
+	unsigned int num_allocated_pages;
+	bool use_bmap = virtio_has_feature(vb->vdev,
+				 VIRTIO_BALLOON_F_PAGE_RANGE);
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (use_bmap)
+		init_bmap_pfn_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -159,7 +383,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_bmap)
+			update_bmap_pfn_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -168,8 +395,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
 	num_allocated_pages = vb->num_pfns;
 	/* Did we get any? */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->inflate_vq);
+	if (vb->num_pfns != 0) {
+		if (use_bmap)
+			set_page_bitmap(vb, &vb_dev_info->pages,
+					vb->inflate_vq);
+		else
+			tell_host(vb, vb->inflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	return num_allocated_pages;
@@ -189,15 +421,20 @@ static void release_pages_balloon(struct virtio_balloon *vb,
 	}
 }
 
-static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
+static unsigned int leak_balloon(struct virtio_balloon *vb, size_t num)
 {
-	unsigned num_freed_pages;
+	unsigned int num_freed_pages;
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	LIST_HEAD(pages);
+	bool use_bmap = virtio_has_feature(vb->vdev,
+			 VIRTIO_BALLOON_F_PAGE_RANGE);
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (use_bmap)
+		init_bmap_pfn_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	/* We can't release more pages than taken */
@@ -207,7 +444,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_bmap)
+			update_bmap_pfn_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -218,8 +458,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->deflate_vq);
+	if (vb->num_pfns != 0) {
+		if (use_bmap)
+			set_page_bitmap(vb, &pages, vb->deflate_vq);
+		else
+			tell_host(vb, vb->deflate_vq);
+	}
 	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
@@ -431,6 +675,18 @@ static int init_vqs(struct virtio_balloon *vb)
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
+static void tell_host_one_page(struct virtio_balloon *vb,
+	struct virtqueue *vq, struct page *page)
+{
+	__le64 *range;
+
+	range = vb->resp_data + vb->resp_pos;
+	*range = cpu_to_le64((page_to_pfn(page) <<
+				VIRTIO_BALLOON_NR_PFN_BITS) | 1);
+	vb->resp_pos++;
+	send_resp_data(vb, vq, false);
+}
+
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
  *			     a compation thread.     (called under page lock)
@@ -455,6 +711,8 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
 	unsigned long flags;
+	bool use_bmap = virtio_has_feature(vb->vdev,
+				 VIRTIO_BALLOON_F_PAGE_RANGE);
 
 	/*
 	 * In order to avoid lock contention while migrating pages concurrently
@@ -475,15 +733,23 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
+	if (use_bmap)
+		tell_host_one_page(vb, vb->inflate_vq, newpage);
+	else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, newpage);
+		tell_host(vb, vb->inflate_vq);
+	}
 
 	/* balloon's page migration 2nd step -- deflate "page" */
 	balloon_page_delete(page);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, page);
-	tell_host(vb, vb->deflate_vq);
+	if (use_bmap)
+		tell_host_one_page(vb, vb->deflate_vq, page);
+	else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, page);
+		tell_host(vb, vb->deflate_vq);
+	}
 
 	mutex_unlock(&vb->balloon_lock);
 
@@ -533,6 +799,29 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
 	vb->num_pages = 0;
+	vb->resp_hdr = kzalloc(sizeof(struct virtio_balloon_resp_hdr),
+				 GFP_KERNEL);
+	/* Clear the feature bit if memory allocation fails */
+	if (!vb->resp_hdr)
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_RANGE);
+	else {
+		vb->page_bitmap[0] = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
+		if (!vb->page_bitmap[0]) {
+			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_RANGE);
+			kfree(vb->resp_hdr);
+		} else {
+			vb->nr_page_bmap = 1;
+			vb->resp_data = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
+			if (!vb->resp_data) {
+				__virtio_clear_bit(vdev,
+						VIRTIO_BALLOON_F_PAGE_RANGE);
+				kfree(vb->page_bitmap[0]);
+				kfree(vb->resp_hdr);
+			}
+		}
+	}
+	vb->resp_pos = 0;
+	vb->resp_buf_size = BALLOON_BMAP_SIZE;
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -611,6 +900,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	remove_common(vb);
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
+	kfree_page_bitmap(vb);
+	kfree(vb->resp_hdr);
 	kfree(vb);
 }
 
@@ -649,6 +940,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_PAGE_RANGE,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
