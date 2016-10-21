Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 818E9280250
	for <linux-mm@kvack.org>; Fri, 21 Oct 2016 02:37:14 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e6so44599939pfk.2
        for <linux-mm@kvack.org>; Thu, 20 Oct 2016 23:37:14 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id p16si1246297pfj.117.2016.10.20.23.37.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Oct 2016 23:37:13 -0700 (PDT)
From: Liang Li <liang.z.li@intel.com>
Subject: [RESEND PATCH v3 kernel 4/7] virtio-balloon: speed up inflate/deflate process
Date: Fri, 21 Oct 2016 14:24:37 +0800
Message-Id: <1477031080-12616-5-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
References: <1477031080-12616-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mst@redhat.com
Cc: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, pbonzini@redhat.com, cornelia.huck@de.ibm.com, amit.shah@redhat.com, Liang Li <liang.z.li@intel.com>

The implementation of the current virtio-balloon is not very
efficient, the time spends on different stages of inflating
the balloon to 7GB of a 8GB idle guest:

a. allocating pages (6.5%)
b. sending PFNs to host (68.3%)
c. address translation (6.1%)
d. madvise (19%)

It takes about 4126ms for the inflating process to complete.
Debugging shows that the bottle neck are the stage b and stage d.

If using a bitmap to send the page info instead of the PFNs, we
can reduce the overhead in stage b quite a lot. Furthermore, we
can do the address translation and call madvise() with a bulk of
RAM pages, instead of the current page per page way, the overhead
of stage c and stage d can also be reduced a lot.

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
---
 drivers/virtio/virtio_balloon.c | 233 +++++++++++++++++++++++++++++++++++-----
 1 file changed, 209 insertions(+), 24 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 59ffe5a..c31839c 100644
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
@@ -67,6 +71,13 @@ struct virtio_balloon {
 
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+	/* Pointer of the bitmap header. */
+	void *bmap_hdr;
+	/* Bitmap and bitmap count used to tell the host the pages */
+	unsigned long *page_bitmap[BALLOON_BMAP_COUNT];
+	unsigned int nr_page_bmap;
+	/* Used to record the processed pfn range */
+	unsigned long min_pfn, max_pfn, start_pfn, end_pfn;
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -110,16 +121,66 @@ static void balloon_ack(struct virtqueue *vq)
 	wake_up(&vb->acked);
 }
 
+static inline void init_pfn_range(struct virtio_balloon *vb)
+{
+	vb->min_pfn = ULONG_MAX;
+	vb->max_pfn = 0;
+}
+
+static inline void update_pfn_range(struct virtio_balloon *vb,
+				 struct page *page)
+{
+	unsigned long balloon_pfn = page_to_balloon_pfn(page);
+
+	if (balloon_pfn < vb->min_pfn)
+		vb->min_pfn = balloon_pfn;
+	if (balloon_pfn > vb->max_pfn)
+		vb->max_pfn = balloon_pfn;
+}
+
 static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 {
-	struct scatterlist sg;
-	unsigned int len;
+	struct scatterlist sg, sg2[BALLOON_BMAP_COUNT + 1];
+	unsigned int len, i;
+
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP)) {
+		struct balloon_bmap_hdr *hdr = vb->bmap_hdr;
+		unsigned long bmap_len;
+		int nr_pfn, nr_used_bmap, nr_buf;
+
+		nr_pfn = vb->end_pfn - vb->start_pfn + 1;
+		nr_pfn = roundup(nr_pfn, BITS_PER_LONG);
+		nr_used_bmap = nr_pfn / PFNS_PER_BMAP;
+		bmap_len = nr_pfn / BITS_PER_BYTE;
+		nr_buf = nr_used_bmap + 1;
+
+		/* cmd, reserved and req_id are init to 0, unused here */
+		hdr->page_shift = cpu_to_virtio16(vb->vdev, PAGE_SHIFT);
+		hdr->start_pfn = cpu_to_virtio64(vb->vdev, vb->start_pfn);
+		hdr->bmap_len = cpu_to_virtio64(vb->vdev, bmap_len);
+		sg_init_table(sg2, nr_buf);
+		sg_set_buf(&sg2[0], hdr, sizeof(struct balloon_bmap_hdr));
+		for (i = 0; i < nr_used_bmap; i++) {
+			unsigned int  buf_len = BALLOON_BMAP_SIZE;
+
+			if (i + 1 == nr_used_bmap)
+				buf_len = bmap_len - BALLOON_BMAP_SIZE * i;
+			sg_set_buf(&sg2[i + 1], vb->page_bitmap[i], buf_len);
+		}
 
-	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+		while (vq->num_free < nr_buf)
+			msleep(2);
+		if (virtqueue_add_outbuf(vq, sg2, nr_buf, vb, GFP_KERNEL) == 0)
+			virtqueue_kick(vq);
 
-	/* We should always be able to add one buffer to an empty queue. */
-	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
-	virtqueue_kick(vq);
+	} else {
+		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+
+		/* We should always be able to add one buffer to an empty
+		 * queue. */
+		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
+		virtqueue_kick(vq);
+	}
 
 	/* When host has read buffer, this completes via balloon_ack */
 	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
@@ -138,13 +199,93 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
-static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
+static void extend_page_bitmap(struct virtio_balloon *vb)
+{
+	int i;
+	unsigned long bmap_len, bmap_count;
+
+	bmap_len = ALIGN(get_max_pfn(), BITS_PER_LONG) / BITS_PER_BYTE;
+	bmap_count = bmap_len / BALLOON_BMAP_SIZE;
+	if (bmap_len % BALLOON_BMAP_SIZE)
+		bmap_count++;
+	if (bmap_count > BALLOON_BMAP_COUNT)
+		bmap_count = BALLOON_BMAP_COUNT;
+
+	for (i = 1; i < bmap_count; i++) {
+		vb->page_bitmap[i] = kmalloc(BALLOON_BMAP_SIZE, GFP_ATOMIC);
+		if (vb->page_bitmap[i])
+			vb->nr_page_bmap++;
+		else
+			break;
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
+static unsigned int fill_balloon(struct virtio_balloon *vb, size_t num,
+				 bool use_bmap)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
-	unsigned num_allocated_pages;
+	unsigned int num_allocated_pages;
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (use_bmap)
+		init_pfn_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -159,7 +300,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_bmap)
+			update_pfn_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -168,8 +312,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
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
@@ -189,15 +338,19 @@ static void release_pages_balloon(struct virtio_balloon *vb,
 	}
 }
 
-static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
+static unsigned int leak_balloon(struct virtio_balloon *vb, size_t num,
+				bool use_bmap)
 {
-	unsigned num_freed_pages;
+	unsigned int num_freed_pages;
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	LIST_HEAD(pages);
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (use_bmap)
+		init_pfn_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	/* We can't release more pages than taken */
@@ -207,7 +360,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_bmap)
+			update_pfn_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -218,8 +374,14 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
+
+		release_pages_balloon(vb, &pages);
+	}
 	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
@@ -354,13 +516,15 @@ static int virtballoon_oom_notify(struct notifier_block *self,
 	struct virtio_balloon *vb;
 	unsigned long *freed;
 	unsigned num_freed_pages;
+	bool use_bmap;
 
 	vb = container_of(self, struct virtio_balloon, nb);
 	if (!virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 		return NOTIFY_OK;
 
 	freed = parm;
-	num_freed_pages = leak_balloon(vb, oom_pages);
+	use_bmap = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+	num_freed_pages = leak_balloon(vb, oom_pages, use_bmap);
 	update_balloon_size(vb);
 	*freed += num_freed_pages;
 
@@ -380,15 +544,19 @@ static void update_balloon_size_func(struct work_struct *work)
 {
 	struct virtio_balloon *vb;
 	s64 diff;
+	bool use_bmap;
 
 	vb = container_of(work, struct virtio_balloon,
 			  update_balloon_size_work);
 	diff = towards_target(vb);
+	use_bmap = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+	if (use_bmap && diff && vb->nr_page_bmap == 1)
+		extend_page_bitmap(vb);
 
 	if (diff > 0)
-		diff -= fill_balloon(vb, diff);
+		diff -= fill_balloon(vb, diff, use_bmap);
 	else if (diff < 0)
-		diff += leak_balloon(vb, -diff);
+		diff += leak_balloon(vb, -diff, use_bmap);
 	update_balloon_size(vb);
 
 	if (diff)
@@ -533,6 +701,17 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
 	vb->num_pages = 0;
+	vb->bmap_hdr = kzalloc(sizeof(struct balloon_bmap_hdr), GFP_KERNEL);
+	/* Clear the feature bit if memory allocation fails */
+	if (!vb->bmap_hdr)
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+	else {
+		vb->page_bitmap[0] = kmalloc(BALLOON_BMAP_SIZE, GFP_KERNEL);
+		if (!vb->page_bitmap[0])
+			__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
+		else
+			vb->nr_page_bmap = 1;
+	}
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -583,9 +762,12 @@ static int virtballoon_probe(struct virtio_device *vdev)
 
 static void remove_common(struct virtio_balloon *vb)
 {
+	bool use_bmap;
+
+	use_bmap = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_PAGE_BITMAP);
 	/* There might be pages left in the balloon: free them. */
 	while (vb->num_pages)
-		leak_balloon(vb, vb->num_pages);
+		leak_balloon(vb, vb->num_pages, use_bmap);
 	update_balloon_size(vb);
 
 	/* Now we reset the device so we can clean up the queues. */
@@ -609,6 +791,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	remove_common(vb);
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
+	kfree_page_bitmap(vb);
+	kfree(vb->bmap_hdr);
 	kfree(vb);
 }
 
@@ -647,6 +831,7 @@ static int virtballoon_restore(struct virtio_device *vdev)
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_PAGE_BITMAP,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
