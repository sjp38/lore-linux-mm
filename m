Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id CDC46831F4
	for <linux-mm@kvack.org>; Thu,  4 May 2017 04:55:59 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id s62so6045539pgc.2
        for <linux-mm@kvack.org>; Thu, 04 May 2017 01:55:59 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t188si1518031pgt.331.2017.05.04.01.55.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 01:55:58 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v10 3/6] virtio-balloon: VIRTIO_BALLOON_F_PAGE_CHUNKS
Date: Thu,  4 May 2017 16:50:12 +0800
Message-Id: <1493887815-6070-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
References: <1493887815-6070-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Add a new feature, VIRTIO_BALLOON_F_PAGE_CHUNKS, which enables
the transfer of the ballooned (i.e. inflated/deflated) pages in
chunks to the host.

The implementation of the previous virtio-balloon is not very
efficient, because the ballooned pages are transferred to the
host one by one. Here is the breakdown of the time in percentage
spent on each step of the balloon inflating process (inflating
7GB of an 8GB idle guest).

1) allocating pages (6.5%)
2) sending PFNs to host (68.3%)
3) address translation (6.1%)
4) madvise (19%)

It takes about 4126ms for the inflating process to complete.
The above profiling shows that the bottlenecks are stage 2)
and stage 4).

This patch optimizes step 2) by transferring pages to the host in
chunks. A chunk consists of guest physically continuous pages.
When the pages are packed into a chunk, they are converted into
balloon page size (4KB) pages. A chunk is offered to the host
via a base PFN (i.e. the start PFN of those physically continuous
pages) and the size (i.e. the total number of the 4KB balloon size
pages). A chunk is formatted as below:
--------------------------------------------------------
|                 Base (52 bit)        | Rsvd (12 bit) |
--------------------------------------------------------
--------------------------------------------------------
|                 Size (52 bit)        | Rsvd (12 bit) |
--------------------------------------------------------

By doing so, step 4) can also be optimized by doing address
translation and madvise() in chunks rather than page by page.

With this new feature, the above ballooning process takes ~590ms
resulting in an improvement of ~85%.

TODO: optimize stage 1) by allocating/freeing a chunk of pages
instead of a single page each time.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_balloon.c     | 407 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |  14 ++
 2 files changed, 396 insertions(+), 25 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index ecb64e9..df16912 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -43,6 +43,20 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+/* The size of one page_bmap used to record inflated/deflated pages. */
+#define VIRTIO_BALLOON_PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
+/*
+ * Callulates how many pfns can a page_bmap record. A bit corresponds to a
+ * page of PAGE_SIZE.
+ */
+#define VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP \
+	(VIRTIO_BALLOON_PAGE_BMAP_SIZE * BITS_PER_BYTE)
+
+/* The number of page_bmap to allocate by default. */
+#define VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM	1
+/* The maximum number of page_bmap that can be allocated. */
+#define VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM	32
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -51,6 +65,11 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 static struct vfsmount *balloon_mnt;
 #endif
 
+/* Maximum number of page chunks */
+#define VIRTIO_BALLOON_MAX_PAGE_CHUNKS ((8 * PAGE_SIZE - \
+			sizeof(struct virtio_balloon_page_chunk)) / \
+			sizeof(struct virtio_balloon_page_chunk_entry))
+
 struct virtio_balloon {
 	struct virtio_device *vdev;
 	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
@@ -79,6 +98,12 @@ struct virtio_balloon {
 	/* Synchronize access/update to this struct virtio_balloon elements */
 	struct mutex balloon_lock;
 
+	/* Buffer for chunks of ballooned pages. */
+	struct virtio_balloon_page_chunk *balloon_page_chunk;
+
+	/* Bitmap used to record pages. */
+	unsigned long *page_bmap[VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM];
+
 	/* The array of pfns we tell the Host about. */
 	unsigned int num_pfns;
 	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
@@ -111,6 +136,136 @@ static void balloon_ack(struct virtqueue *vq)
 	wake_up(&vb->acked);
 }
 
+/* Update pfn_max and pfn_min according to the pfn of page */
+static inline void update_pfn_range(struct virtio_balloon *vb,
+				    struct page *page,
+				    unsigned long *pfn_min,
+				    unsigned long *pfn_max)
+{
+	unsigned long pfn = page_to_pfn(page);
+
+	*pfn_min = min(pfn, *pfn_min);
+	*pfn_max = max(pfn, *pfn_max);
+}
+
+static unsigned int extend_page_bmap_size(struct virtio_balloon *vb,
+					  unsigned long pfn_num)
+{
+	unsigned int i, bmap_num, allocated_bmap_num;
+	unsigned long bmap_len;
+
+	allocated_bmap_num = VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM;
+	bmap_len = ALIGN(pfn_num, BITS_PER_LONG) / BITS_PER_BYTE;
+	bmap_len = roundup(bmap_len, VIRTIO_BALLOON_PAGE_BMAP_SIZE);
+	/*
+	 * VIRTIO_BALLOON_PAGE_BMAP_SIZE is the size of one page_bmap, so
+	 * divide it to calculate how many page_bmap that we need.
+	 */
+	bmap_num = (unsigned int)(bmap_len / VIRTIO_BALLOON_PAGE_BMAP_SIZE);
+	/* The number of page_bmap to allocate should not exceed the max */
+	bmap_num = min_t(unsigned int, VIRTIO_BALLOON_PAGE_BMAP_MAX_NUM,
+			 bmap_num);
+
+	for (i = VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i < bmap_num; i++) {
+		vb->page_bmap[i] = kmalloc(VIRTIO_BALLOON_PAGE_BMAP_SIZE,
+					   GFP_KERNEL);
+		if (vb->page_bmap[i])
+			allocated_bmap_num++;
+		else
+			break;
+	}
+
+	return allocated_bmap_num;
+}
+
+static void free_extended_page_bmap(struct virtio_balloon *vb,
+				    unsigned int page_bmap_num)
+{
+	unsigned int i;
+
+	for (i = VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i < page_bmap_num;
+	     i++) {
+		kfree(vb->page_bmap[i]);
+		vb->page_bmap[i] = NULL;
+		page_bmap_num--;
+	}
+}
+
+static void clear_page_bmap(struct virtio_balloon *vb,
+			    unsigned int page_bmap_num)
+{
+	int i;
+
+	for (i = 0; i < page_bmap_num; i++)
+		memset(vb->page_bmap[i], 0, VIRTIO_BALLOON_PAGE_BMAP_SIZE);
+}
+
+static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq)
+{
+	struct scatterlist sg;
+	struct virtio_balloon_page_chunk *chunk;
+	unsigned int len;
+
+	chunk = vb->balloon_page_chunk;
+	len = sizeof(__le64) +
+	      le64_to_cpu(chunk->chunk_num) *
+	      sizeof(struct virtio_balloon_page_chunk_entry);
+	sg_init_one(&sg, chunk, len);
+	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
+		virtqueue_kick(vq);
+		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		chunk->chunk_num = 0;
+	}
+}
+
+/* Add a chunk entry to the buffer. */
+static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
+			  u64 base, u64 size)
+{
+	struct virtio_balloon_page_chunk *chunk = vb->balloon_page_chunk;
+	struct virtio_balloon_page_chunk_entry *entry;
+	uint64_t chunk_num = le64_to_cpu(chunk->chunk_num);
+
+	entry = &chunk->entry[chunk_num];
+	entry->base = cpu_to_le64(base << VIRTIO_BALLOON_CHUNK_BASE_SHIFT);
+	entry->size = cpu_to_le64(size << VIRTIO_BALLOON_CHUNK_SIZE_SHIFT);
+	chunk->chunk_num = cpu_to_le64(++chunk_num);
+	if (chunk_num == VIRTIO_BALLOON_MAX_PAGE_CHUNKS)
+		send_page_chunks(vb, vq);
+}
+
+static void convert_bmap_to_chunks(struct virtio_balloon *vb,
+				   struct virtqueue *vq,
+				   unsigned long *bmap,
+				   unsigned long pfn_start,
+				   unsigned long size)
+{
+	unsigned long next_one, next_zero, chunk_size, pos = 0;
+
+	while (pos < size) {
+		next_one = find_next_bit(bmap, size, pos);
+		/*
+		 * No "1" bit found, which means that there is no pfn
+		 * recorded in the rest of this bmap.
+		 */
+		if (next_one == size)
+			break;
+		next_zero = find_next_zero_bit(bmap, size, next_one + 1);
+		/*
+		 * A bit in page_bmap corresponds to a page of PAGE_SIZE.
+		 * Convert it to be pages of 4KB balloon page size when
+		 * adding it to a chunk.
+		 */
+		chunk_size = (next_zero - next_one) *
+			     VIRTIO_BALLOON_PAGES_PER_PAGE;
+		if (chunk_size) {
+			add_one_chunk(vb, vq, pfn_start + next_one,
+				      chunk_size);
+			pos += next_zero + 1;
+		}
+	}
+}
+
 static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 {
 	struct scatterlist sg;
@@ -124,7 +279,33 @@ static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
 
 	/* When host has read buffer, this completes via balloon_ack */
 	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+}
+
+static void tell_host_from_page_bmap(struct virtio_balloon *vb,
+				     struct virtqueue *vq,
+				     unsigned long pfn_start,
+				     unsigned long pfn_end,
+				     unsigned int page_bmap_num)
+{
+	unsigned long i, pfn_num;
 
+	for (i = 0; i < page_bmap_num; i++) {
+		/*
+		 * For the last page_bmap, only the remaining number of pfns
+		 * need to be searched rather than the entire page_bmap.
+		 */
+		if (i + 1 == page_bmap_num)
+			pfn_num = (pfn_end - pfn_start) %
+				  VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
+		else
+			pfn_num = VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
+
+		convert_bmap_to_chunks(vb, vq, vb->page_bmap[i], pfn_start +
+				       i * VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP,
+				       pfn_num);
+	}
+	if (le64_to_cpu(vb->balloon_page_chunk->chunk_num) > 0)
+		send_page_chunks(vb, vq);
 }
 
 static void set_page_pfns(struct virtio_balloon *vb,
@@ -141,13 +322,88 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
+/*
+ * Send ballooned pages in chunks to host.
+ * The ballooned pages are recorded in page bitmaps. Each bit in a bitmap
+ * corresponds to a page of PAGE_SIZE. The page bitmaps are searched for
+ * continuous "1" bits, which correspond to continuous pages, to chunk.
+ * When packing those continuous pages into chunks, pages are converted into
+ * 4KB balloon pages.
+ *
+ * pfn_max and pfn_min form the range of pfns that need to use page bitmaps to
+ * record. If the range is too large to be recorded into the allocated page
+ * bitmaps, the page bitmaps are used multiple times to record the entire
+ * range of pfns.
+ */
+static void tell_host_page_chunks(struct virtio_balloon *vb,
+				  struct list_head *pages,
+				  struct virtqueue *vq,
+				  unsigned long pfn_max,
+				  unsigned long pfn_min)
+{
+	/*
+	 * The pfn_start and pfn_end form the range of pfns that the allocated
+	 * page_bmap can record in each round.
+	 */
+	unsigned long pfn_start, pfn_end;
+	/* Total number of allocated page_bmap */
+	unsigned int page_bmap_num;
+	struct page *page;
+	bool found;
+
+	/*
+	 * In the case that one page_bmap is not sufficient to record the pfn
+	 * range, page_bmap will be extended by allocating more numbers of
+	 * page_bmap.
+	 */
+	page_bmap_num = extend_page_bmap_size(vb, pfn_max - pfn_min + 1);
+
+	/* Start from the beginning of the whole pfn range */
+	pfn_start = pfn_min;
+	while (pfn_start < pfn_max) {
+		pfn_end = pfn_start +
+			  VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP * page_bmap_num;
+		pfn_end = pfn_end < pfn_max ? pfn_end : pfn_max;
+		clear_page_bmap(vb, page_bmap_num);
+		found = false;
+
+		list_for_each_entry(page, pages, lru) {
+			unsigned long bmap_idx, bmap_pos, this_pfn;
+
+			this_pfn = page_to_pfn(page);
+			if (this_pfn < pfn_start || this_pfn > pfn_end)
+				continue;
+			bmap_idx = (this_pfn - pfn_start) /
+				   VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
+			bmap_pos = (this_pfn - pfn_start) %
+				   VIRTIO_BALLOON_PFNS_PER_PAGE_BMAP;
+			set_bit(bmap_pos, vb->page_bmap[bmap_idx]);
+
+			found = true;
+		}
+		if (found)
+			tell_host_from_page_bmap(vb, vq, pfn_start, pfn_end,
+						 page_bmap_num);
+		/*
+		 * Start the next round when pfn_start and pfn_end couldn't
+		 * cover the whole pfn range given by pfn_max and pfn_min.
+		 */
+		pfn_start = pfn_end;
+	}
+	free_extended_page_bmap(vb, page_bmap_num);
+}
+
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	unsigned num_allocated_pages;
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_PAGE_CHUNKS);
+	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
 
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (!chunking)
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -162,7 +418,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (chunking)
+			update_pfn_range(vb, page, &pfn_max, &pfn_min);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -171,8 +430,14 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
 	num_allocated_pages = vb->num_pfns;
 	/* Did we get any? */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->inflate_vq);
+	if (vb->num_pfns != 0) {
+		if (chunking)
+			tell_host_page_chunks(vb, &vb_dev_info->pages,
+					      vb->inflate_vq,
+					      pfn_max, pfn_min);
+		else
+			tell_host(vb, vb->inflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	return num_allocated_pages;
@@ -198,9 +463,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	LIST_HEAD(pages);
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_PAGE_CHUNKS);
+	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	/* Traditionally, we can only do one array worth at a time. */
+	if (!chunking)
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	/* We can't release more pages than taken */
@@ -210,7 +479,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (chunking)
+			update_pfn_range(vb, page, &pfn_max, &pfn_min);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -221,8 +493,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->deflate_vq);
+	if (vb->num_pfns != 0) {
+		if (chunking)
+			tell_host_page_chunks(vb, &pages, vb->deflate_vq,
+					      pfn_max, pfn_min);
+		else
+			tell_host(vb, vb->deflate_vq);
+	}
 	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
@@ -442,6 +719,14 @@ static int init_vqs(struct virtio_balloon *vb)
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
+
+static void tell_host_one_page(struct virtio_balloon *vb,
+			       struct virtqueue *vq, struct page *page)
+{
+	add_one_chunk(vb, vq, page_to_pfn(page),
+		      VIRTIO_BALLOON_PAGES_PER_PAGE);
+}
+
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
  *			     a compation thread.     (called under page lock)
@@ -465,6 +750,8 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 {
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_PAGE_CHUNKS);
 	unsigned long flags;
 
 	/*
@@ -486,16 +773,22 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
-
+	if (chunking) {
+		tell_host_one_page(vb, vb->inflate_vq, newpage);
+	} else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, newpage);
+		tell_host(vb, vb->inflate_vq);
+	}
 	/* balloon's page migration 2nd step -- deflate "page" */
 	balloon_page_delete(page);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, page);
-	tell_host(vb, vb->deflate_vq);
-
+	if (chunking) {
+		tell_host_one_page(vb, vb->deflate_vq, page);
+	} else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, page);
+		tell_host(vb, vb->deflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	put_page(page); /* balloon reference */
@@ -522,9 +815,75 @@ static struct file_system_type balloon_fs = {
 
 #endif /* CONFIG_BALLOON_COMPACTION */
 
+static void free_page_bmap(struct virtio_balloon *vb)
+{
+	int i;
+
+	for (i = 0; i < VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i++) {
+		kfree(vb->page_bmap[i]);
+		vb->page_bmap[i] = NULL;
+	}
+}
+
+static int balloon_page_chunk_init(struct virtio_balloon *vb)
+{
+	int i;
+
+	vb->balloon_page_chunk = kmalloc(sizeof(__le64) +
+			sizeof(struct virtio_balloon_page_chunk_entry) *
+			VIRTIO_BALLOON_MAX_PAGE_CHUNKS, GFP_KERNEL);
+	if (!vb->balloon_page_chunk)
+		goto err_page_chunk;
+
+	/*
+	 * The default number of page_bmaps are allocated. More may be
+	 * allocated on demand.
+	 */
+	for (i = 0; i < VIRTIO_BALLOON_PAGE_BMAP_DEFAULT_NUM; i++) {
+		vb->page_bmap[i] = kmalloc(VIRTIO_BALLOON_PAGE_BMAP_SIZE,
+					   GFP_KERNEL);
+		if (!vb->page_bmap[i])
+			goto err_page_bmap;
+	}
+
+	return 0;
+err_page_bmap:
+	free_page_bmap(vb);
+	kfree(vb->balloon_page_chunk);
+	vb->balloon_page_chunk = NULL;
+err_page_chunk:
+	__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_PAGE_CHUNKS);
+	dev_warn(&vb->vdev->dev, "%s: failed\n", __func__);
+	return -ENOMEM;
+}
+
+static int virtballoon_validate(struct virtio_device *vdev)
+{
+	struct virtio_balloon *vb = NULL;
+	int err;
+
+	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
+	if (!vb) {
+		err = -ENOMEM;
+		goto err_vb;
+	}
+
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_PAGE_CHUNKS)) {
+		err = balloon_page_chunk_init(vb);
+		if (err < 0)
+			goto err_page_chunk;
+	}
+
+	return 0;
+err_page_chunk:
+	kfree(vb);
+err_vb:
+	return err;
+}
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
-	struct virtio_balloon *vb;
+	struct virtio_balloon *vb = vdev->priv;
 	int err;
 
 	if (!vdev->config->get) {
@@ -533,17 +892,12 @@ static int virtballoon_probe(struct virtio_device *vdev)
 		return -EINVAL;
 	}
 
-	vdev->priv = vb = kmalloc(sizeof(*vb), GFP_KERNEL);
-	if (!vb) {
-		err = -ENOMEM;
-		goto out;
-	}
-
 	INIT_WORK(&vb->update_balloon_stats_work, update_balloon_stats_func);
 	INIT_WORK(&vb->update_balloon_size_work, update_balloon_size_func);
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
 	vb->num_pages = 0;
+
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -590,7 +944,6 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	vdev->config->del_vqs(vdev);
 out_free_vb:
 	kfree(vb);
-out:
 	return err;
 }
 
@@ -620,6 +973,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
 	remove_common(vb);
+	free_page_bmap(vb);
+	kfree(vb->balloon_page_chunk);
 #ifdef CONFIG_BALLOON_COMPACTION
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
@@ -664,6 +1019,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_PAGE_CHUNKS,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
@@ -674,6 +1030,7 @@ static struct virtio_driver virtio_balloon_driver = {
 	.id_table =	id_table,
 	.probe =	virtballoon_probe,
 	.remove =	virtballoon_remove,
+	.validate =	virtballoon_validate,
 	.config_changed = virtballoon_changed,
 #ifdef CONFIG_PM_SLEEP
 	.freeze	=	virtballoon_freeze,
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 343d7dd..d532ed16 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_PAGE_CHUNKS	3 /* Inflate/Deflate pages in chunks */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -82,4 +83,17 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+#define VIRTIO_BALLOON_CHUNK_BASE_SHIFT 12
+#define VIRTIO_BALLOON_CHUNK_SIZE_SHIFT 12
+struct virtio_balloon_page_chunk_entry {
+	__le64 base;
+	__le64 size;
+};
+
+struct virtio_balloon_page_chunk {
+	/* Number of chunks in the payload */
+	__le64 chunk_num;
+	struct virtio_balloon_page_chunk_entry entry[];
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
