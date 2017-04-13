Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id E016D6B03A1
	for <linux-mm@kvack.org>; Thu, 13 Apr 2017 05:40:09 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id o123so30529770pga.16
        for <linux-mm@kvack.org>; Thu, 13 Apr 2017 02:40:09 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id q7si23444825pfq.336.2017.04.13.02.40.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Apr 2017 02:40:08 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v9 2/5] virtio-balloon: VIRTIO_BALLOON_F_BALLOON_CHUNKS
Date: Thu, 13 Apr 2017 17:35:05 +0800
Message-Id: <1492076108-117229-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
References: <1492076108-117229-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

Add a new feature, VIRTIO_BALLOON_F_BALLOON_CHUNKS, which enables
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
chunks. A chunk consists of guest physically continuous pages, and
it is offered to the host via a base PFN (i.e. the start PFN of
those physically continuous pages) and the size (i.e. the total
number of the pages). A chunk is formated as below:
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
 drivers/virtio/virtio_balloon.c     | 384 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |  13 ++
 2 files changed, 374 insertions(+), 23 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f59cb4f..5e2e7cc 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -42,6 +42,10 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+#define PAGE_BMAP_SIZE		(8 * PAGE_SIZE)
+#define PFNS_PER_PAGE_BMAP	(PAGE_BMAP_SIZE * BITS_PER_BYTE)
+#define PAGE_BMAP_COUNT_MAX	32
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -50,6 +54,10 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 static struct vfsmount *balloon_mnt;
 #endif
 
+/* Types of pages to chunk */
+#define PAGE_CHUNK_TYPE_BALLOON 0
+
+#define MAX_PAGE_CHUNKS 4096
 struct virtio_balloon {
 	struct virtio_device *vdev;
 	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
@@ -78,6 +86,32 @@ struct virtio_balloon {
 	/* Synchronize access/update to this struct virtio_balloon elements */
 	struct mutex balloon_lock;
 
+	/*
+	 * Buffer for PAGE_CHUNK_TYPE_BALLOON:
+	 * virtio_balloon_page_chunk_hdr +
+	 * virtio_balloon_page_chunk * MAX_PAGE_CHUNKS
+	 */
+	struct virtio_balloon_page_chunk_hdr *balloon_page_chunk_hdr;
+	struct virtio_balloon_page_chunk *balloon_page_chunk;
+
+	/* Bitmap used to record pages */
+	unsigned long *page_bmap[PAGE_BMAP_COUNT_MAX];
+	/* Number of the allocated page_bmap */
+	unsigned int page_bmaps;
+
+	/*
+	 * The allocated page_bmap size may be smaller than the pfn range of
+	 * the ballooned pages. In this case, we need to use the page_bmap
+	 * multiple times to cover the entire pfn range. It's like using a
+	 * short ruler several times to finish measuring a long object.
+	 * The start location of the ruler in the next measurement is the end
+	 * location of the ruler in the previous measurement.
+	 *
+	 * pfn_max & pfn_min: forms the pfn range of the ballooned pages
+	 * pfn_start & pfn_stop: records the start and stop pfn in each cover
+	 */
+	unsigned long pfn_min, pfn_max, pfn_start, pfn_stop;
+
 	/* The array of pfns we tell the Host about. */
 	unsigned int num_pfns;
 	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
@@ -110,20 +144,201 @@ static void balloon_ack(struct virtqueue *vq)
 	wake_up(&vb->acked);
 }
 
-static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
+static inline void init_page_bmap_range(struct virtio_balloon *vb)
+{
+	vb->pfn_min = ULONG_MAX;
+	vb->pfn_max = 0;
+}
+
+static inline void update_page_bmap_range(struct virtio_balloon *vb,
+					  struct page *page)
+{
+	unsigned long balloon_pfn = page_to_balloon_pfn(page);
+
+	vb->pfn_min = min(balloon_pfn, vb->pfn_min);
+	vb->pfn_max = max(balloon_pfn, vb->pfn_max);
+}
+
+/* The page_bmap size is extended by adding more number of page_bmap */
+static void extend_page_bmap_size(struct virtio_balloon *vb,
+				  unsigned long pfns)
+{
+	int i, bmaps;
+	unsigned long bmap_len;
+
+	bmap_len = ALIGN(pfns, BITS_PER_LONG) / BITS_PER_BYTE;
+	bmap_len = ALIGN(bmap_len, PAGE_BMAP_SIZE);
+	bmaps = min((int)(bmap_len / PAGE_BMAP_SIZE),
+		    PAGE_BMAP_COUNT_MAX);
+
+	for (i = 1; i < bmaps; i++) {
+		vb->page_bmap[i] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
+		if (vb->page_bmap[i])
+			vb->page_bmaps++;
+		else
+			break;
+	}
+}
+
+static void free_extended_page_bmap(struct virtio_balloon *vb)
+{
+	int i, bmaps = vb->page_bmaps;
+
+	for (i = 1; i < bmaps; i++) {
+		kfree(vb->page_bmap[i]);
+		vb->page_bmap[i] = NULL;
+		vb->page_bmaps--;
+	}
+}
+
+static void free_page_bmap(struct virtio_balloon *vb)
+{
+	int i;
+
+	for (i = 0; i < vb->page_bmaps; i++)
+		kfree(vb->page_bmap[i]);
+}
+
+static void clear_page_bmap(struct virtio_balloon *vb)
+{
+	int i;
+
+	for (i = 0; i < vb->page_bmaps; i++)
+		memset(vb->page_bmap[i], 0, PAGE_BMAP_SIZE);
+}
+
+static void send_page_chunks(struct virtio_balloon *vb, struct virtqueue *vq,
+			     int type, bool busy_wait)
 {
 	struct scatterlist sg;
+	struct virtio_balloon_page_chunk_hdr *hdr;
+	void *buf;
 	unsigned int len;
 
-	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	switch (type) {
+	case PAGE_CHUNK_TYPE_BALLOON:
+		hdr = vb->balloon_page_chunk_hdr;
+		len = 0;
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
+			 __func__, type);
+		return;
+	}
 
-	/* We should always be able to add one buffer to an empty queue. */
-	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
-	virtqueue_kick(vq);
+	buf = (void *)hdr - len;
+	len += sizeof(struct virtio_balloon_page_chunk_hdr);
+	len += hdr->chunks * sizeof(struct virtio_balloon_page_chunk);
+	sg_init_table(&sg, 1);
+	sg_set_buf(&sg, buf, len);
+	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
+		virtqueue_kick(vq);
+		if (busy_wait)
+			while (!virtqueue_get_buf(vq, &len) &&
+			       !virtqueue_is_broken(vq))
+				cpu_relax();
+		else
+			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		hdr->chunks = 0;
+	}
+}
+
+static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
+			  int type, u64 base, u64 size)
+{
+	struct virtio_balloon_page_chunk_hdr *hdr;
+	struct virtio_balloon_page_chunk *chunk;
+
+	switch (type) {
+	case PAGE_CHUNK_TYPE_BALLOON:
+		hdr = vb->balloon_page_chunk_hdr;
+		chunk = vb->balloon_page_chunk;
+		break;
+	default:
+		dev_warn(&vb->vdev->dev, "%s: chunk %d of unknown pages\n",
+			 __func__, type);
+		return;
+	}
+	chunk = chunk + hdr->chunks;
+	chunk->base = cpu_to_le64(base << VIRTIO_BALLOON_CHUNK_BASE_SHIFT);
+	chunk->size = cpu_to_le64(size << VIRTIO_BALLOON_CHUNK_SIZE_SHIFT);
+	hdr->chunks++;
+	if (hdr->chunks == MAX_PAGE_CHUNKS)
+		send_page_chunks(vb, vq, type, false);
+}
+
+static void chunking_pages_from_bmap(struct virtio_balloon *vb,
+				     struct virtqueue *vq,
+				     unsigned long pfn_start,
+				     unsigned long *bmap,
+				     unsigned long len)
+{
+	unsigned long pos = 0, end = len * BITS_PER_BYTE;
+
+	while (pos < end) {
+		unsigned long one = find_next_bit(bmap, end, pos);
+
+		if (one < end) {
+			unsigned long chunk_size, zero;
+
+			zero = find_next_zero_bit(bmap, end, one + 1);
+			if (zero >= end)
+				chunk_size = end - one;
+			else
+				chunk_size = zero - one;
+
+			if (chunk_size)
+				add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
+					      pfn_start + one, chunk_size);
+			pos = one + chunk_size;
+		} else
+			break;
+	}
+}
+
+static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
+{
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS)) {
+		int pfns, page_bmaps, i;
+		unsigned long pfn_start, pfns_len;
+
+		pfn_start = vb->pfn_start;
+		pfns = vb->pfn_stop - pfn_start + 1;
+		pfns = roundup(roundup(pfns, BITS_PER_LONG),
+			       PFNS_PER_PAGE_BMAP);
+		page_bmaps = pfns / PFNS_PER_PAGE_BMAP;
+		pfns_len = pfns / BITS_PER_BYTE;
+
+		for (i = 0; i < page_bmaps; i++) {
+			unsigned int bmap_len = PAGE_BMAP_SIZE;
+
+			/* The last one takes the leftover only */
+			if (i + 1 == page_bmaps)
+				bmap_len = pfns_len - PAGE_BMAP_SIZE * i;
+
+			chunking_pages_from_bmap(vb, vq, pfn_start +
+						 i * PFNS_PER_PAGE_BMAP,
+						 vb->page_bmap[i], bmap_len);
+		}
+		if (vb->balloon_page_chunk_hdr->chunks > 0)
+			send_page_chunks(vb, vq, PAGE_CHUNK_TYPE_BALLOON,
+					 false);
+	} else {
+		struct scatterlist sg;
+		unsigned int len;
 
-	/* When host has read buffer, this completes via balloon_ack */
-	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
 
+		/*
+		 * We should always be able to add one buffer to an empty
+		 * queue.
+		 */
+		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
+		virtqueue_kick(vq);
+
+		/* When host has read buffer, this completes via balloon_ack */
+		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+	}
 }
 
 static void set_page_pfns(struct virtio_balloon *vb,
@@ -131,20 +346,73 @@ static void set_page_pfns(struct virtio_balloon *vb,
 {
 	unsigned int i;
 
-	/* Set balloon pfns pointing at this page.
-	 * Note that the first pfn points at start of the page. */
+	/*
+	 * Set balloon pfns pointing at this page.
+	 * Note that the first pfn points at start of the page.
+	 */
 	for (i = 0; i < VIRTIO_BALLOON_PAGES_PER_PAGE; i++)
 		pfns[i] = cpu_to_virtio32(vb->vdev,
 					  page_to_balloon_pfn(page) + i);
 }
 
+static void set_page_bmap(struct virtio_balloon *vb,
+			  struct list_head *pages, struct virtqueue *vq)
+{
+	unsigned long pfn_start, pfn_stop;
+	struct page *page;
+	bool found;
+
+	vb->pfn_min = rounddown(vb->pfn_min, BITS_PER_LONG);
+	vb->pfn_max = roundup(vb->pfn_max, BITS_PER_LONG);
+
+	extend_page_bmap_size(vb, vb->pfn_max - vb->pfn_min + 1);
+	pfn_start = vb->pfn_min;
+
+	while (pfn_start < vb->pfn_max) {
+		pfn_stop = pfn_start + PFNS_PER_PAGE_BMAP * vb->page_bmaps;
+		pfn_stop = pfn_stop < vb->pfn_max ? pfn_stop : vb->pfn_max;
+
+		vb->pfn_start = pfn_start;
+		clear_page_bmap(vb);
+		found = false;
+
+		list_for_each_entry(page, pages, lru) {
+			unsigned long bmap_idx, bmap_pos, balloon_pfn;
+
+			balloon_pfn = page_to_balloon_pfn(page);
+			if (balloon_pfn < pfn_start || balloon_pfn > pfn_stop)
+				continue;
+			bmap_idx = (balloon_pfn - pfn_start) /
+				   PFNS_PER_PAGE_BMAP;
+			bmap_pos = (balloon_pfn - pfn_start) %
+				   PFNS_PER_PAGE_BMAP;
+			set_bit(bmap_pos, vb->page_bmap[bmap_idx]);
+
+			found = true;
+		}
+		if (found) {
+			vb->pfn_stop = pfn_stop;
+			tell_host(vb, vq);
+		}
+		pfn_start = pfn_stop;
+	}
+	free_extended_page_bmap(vb);
+}
+
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	unsigned num_allocated_pages;
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_BALLOON_CHUNKS);
 
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (chunking) {
+		init_page_bmap_range(vb);
+	} else {
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
+	}
 
 	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -159,7 +427,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (chunking)
+			update_page_bmap_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -168,8 +439,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
 	num_allocated_pages = vb->num_pfns;
 	/* Did we get any? */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->inflate_vq);
+	if (vb->num_pfns != 0) {
+		if (chunking)
+			set_page_bmap(vb, &vb_dev_info->pages,
+					vb->inflate_vq);
+		else
+			tell_host(vb, vb->inflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	return num_allocated_pages;
@@ -195,6 +471,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	LIST_HEAD(pages);
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_BALLOON_CHUNKS);
+	if (chunking)
+		init_page_bmap_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
@@ -208,6 +491,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		if (!page)
 			break;
 		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (chunking)
+			update_page_bmap_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -218,8 +505,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->deflate_vq);
+	if (vb->num_pfns != 0) {
+		if (chunking)
+			set_page_bmap(vb, &pages, vb->deflate_vq);
+		else
+			tell_host(vb, vb->deflate_vq);
+	}
 	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
@@ -431,6 +722,13 @@ static int init_vqs(struct virtio_balloon *vb)
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
+
+static void tell_host_one_page(struct virtio_balloon *vb,
+			       struct virtqueue *vq, struct page *page)
+{
+	add_one_chunk(vb, vq, PAGE_CHUNK_TYPE_BALLOON, page_to_pfn(page), 1);
+}
+
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
  *			     a compation thread.     (called under page lock)
@@ -454,6 +752,8 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 {
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_BALLOON_CHUNKS);
 	unsigned long flags;
 
 	/*
@@ -475,16 +775,22 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
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
@@ -511,6 +817,32 @@ static struct file_system_type balloon_fs = {
 
 #endif /* CONFIG_BALLOON_COMPACTION */
 
+static void balloon_page_chunk_init(struct virtio_balloon *vb)
+{
+	void *buf;
+
+	/*
+	 * By default, we allocate page_bmap[0] only. More page_bmap will be
+	 * allocated on demand.
+	 */
+	vb->page_bmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
+	buf = kmalloc(sizeof(struct virtio_balloon_page_chunk_hdr) +
+		      sizeof(struct virtio_balloon_page_chunk) *
+		      MAX_PAGE_CHUNKS, GFP_KERNEL);
+	if (!vb->page_bmap[0] || !buf) {
+		__virtio_clear_bit(vb->vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS);
+		kfree(vb->page_bmap[0]);
+		kfree(vb->balloon_page_chunk_hdr);
+		dev_warn(&vb->vdev->dev, "%s: failed\n", __func__);
+	} else {
+		vb->page_bmaps = 1;
+		vb->balloon_page_chunk_hdr = buf;
+		vb->balloon_page_chunk_hdr->chunks = 0;
+		vb->balloon_page_chunk = buf +
+				sizeof(struct virtio_balloon_page_chunk_hdr);
+	}
+}
+
 static int virtballoon_probe(struct virtio_device *vdev)
 {
 	struct virtio_balloon *vb;
@@ -533,6 +865,10 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
 	vb->num_pages = 0;
+
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_BALLOON_CHUNKS))
+		balloon_page_chunk_init(vb);
+
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -609,6 +945,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
 	remove_common(vb);
+	free_page_bmap(vb);
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
 	kfree(vb);
@@ -649,6 +986,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_BALLOON_CHUNKS,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 343d7dd..be317b7 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_BALLOON_CHUNKS 3 /* Inflate/Deflate pages in chunks */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -82,4 +83,16 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+struct virtio_balloon_page_chunk_hdr {
+	/* Number of chunks in the payload */
+	__le32 chunks;
+};
+
+#define VIRTIO_BALLOON_CHUNK_BASE_SHIFT 12
+#define VIRTIO_BALLOON_CHUNK_SIZE_SHIFT 12
+struct virtio_balloon_page_chunk {
+	__le64 base;
+	__le64 size;
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
