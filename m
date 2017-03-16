Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59D036B038B
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 03:13:13 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g2so76444046pge.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 00:13:13 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id k124si4374304pgk.356.2017.03.16.00.13.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 00:13:11 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH kernel v8 2/4] virtio-balloon: VIRTIO_BALLOON_F_CHUNK_TRANSFER
Date: Thu, 16 Mar 2017 15:08:45 +0800
Message-Id: <1489648127-37282-3-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
References: <1489648127-37282-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, dave.hansen@intel.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com

From: Liang Li <liang.z.li@intel.com>

The implementation of the current virtio-balloon is not very
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

This optimization requires the negotiation of a new feature bit,
VIRTIO_BALLOON_F_CHUNK_TRANSFER.

With this new feature, the above ballooning process takes ~590ms
resulting in an improvement of ~85%.

TODO: optimize stage 1) by allocating/freeing a chunk of pages
instead of a single page each time.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_balloon.c     | 371 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |   9 +
 2 files changed, 353 insertions(+), 27 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f59cb4f..3f4a161 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -42,6 +42,10 @@
 #define OOM_VBALLOON_DEFAULT_PAGES 256
 #define VIRTBALLOON_OOM_NOTIFY_PRIORITY 80
 
+#define PAGE_BMAP_SIZE	(8 * PAGE_SIZE)
+#define PFNS_PER_PAGE_BMAP	(PAGE_BMAP_SIZE * BITS_PER_BYTE)
+#define PAGE_BMAP_COUNT_MAX	32
+
 static int oom_pages = OOM_VBALLOON_DEFAULT_PAGES;
 module_param(oom_pages, int, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
@@ -50,6 +54,14 @@ MODULE_PARM_DESC(oom_pages, "pages to free on OOM");
 static struct vfsmount *balloon_mnt;
 #endif
 
+#define BALLOON_CHUNK_BASE_SHIFT 12
+#define BALLOON_CHUNK_SIZE_SHIFT 12
+struct balloon_page_chunk {
+	__le64 base;
+	__le64 size;
+};
+
+typedef __le64 resp_data_t;
 struct virtio_balloon {
 	struct virtio_device *vdev;
 	struct virtqueue *inflate_vq, *deflate_vq, *stats_vq;
@@ -67,6 +79,31 @@ struct virtio_balloon {
 
 	/* Number of balloon pages we've told the Host we're not using. */
 	unsigned int num_pages;
+	/* Pointer to the response header. */
+	struct virtio_balloon_resp_hdr *resp_hdr;
+	/* Pointer to the start address of response data. */
+	resp_data_t *resp_data;
+	/* Size of response data buffer. */
+	unsigned int resp_buf_size;
+	/* Pointer offset of the response data. */
+	unsigned int resp_pos;
+	/* Bitmap used to record pages */
+	unsigned long *page_bmap[PAGE_BMAP_COUNT_MAX];
+	/* Number of split page bmaps */
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
 	/*
 	 * The pages we've told the Host we're not using are enqueued
 	 * at vb_dev_info->pages list.
@@ -110,20 +147,187 @@ static void balloon_ack(struct virtqueue *vq)
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
+static void send_resp_data(struct virtio_balloon *vb, struct virtqueue *vq,
+			   bool busy_wait)
 {
 	struct scatterlist sg;
+	struct virtio_balloon_resp_hdr *hdr = vb->resp_hdr;
 	unsigned int len;
 
-	sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+	len = vb->resp_pos * sizeof(resp_data_t);
+	hdr->data_len = cpu_to_le32(len);
+	len += sizeof(struct virtio_balloon_resp_hdr);
+	sg_init_table(&sg, 1);
+	sg_set_buf(&sg, hdr, len);
+
+	if (!virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL)) {
+		virtqueue_kick(vq);
+		if (busy_wait)
+			while (!virtqueue_get_buf(vq, &len) &&
+			       !virtqueue_is_broken(vq))
+				cpu_relax();
+		else
+			wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+		vb->resp_pos = 0;
+		free_extended_page_bmap(vb);
+	}
+}
+
+/* Calculate how many resp_data does one chunk need */
+#define RESP_POS_ADD_CHUNK (sizeof(struct balloon_page_chunk) / \
+			    sizeof(resp_data_t))
+static void add_one_chunk(struct virtio_balloon *vb, struct virtqueue *vq,
+			  unsigned long base, int size)
+{
+	struct balloon_page_chunk *chunk =
+				(struct balloon_page_chunk *)(vb->resp_data +
+								vb->resp_pos);
+		/*
+		 * Not enough resp_data space to hold the next
+		 * chunk?
+		 */
+		if ((vb->resp_pos + RESP_POS_ADD_CHUNK) *
+		    sizeof(resp_data_t) > vb->resp_buf_size)
+			send_resp_data(vb, vq, false);
 
-	/* We should always be able to add one buffer to an empty queue. */
-	virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
-	virtqueue_kick(vq);
+		chunk->base = cpu_to_le64(base << BALLOON_CHUNK_BASE_SHIFT);
+		chunk->size = cpu_to_le64(size << BALLOON_CHUNK_SIZE_SHIFT);
+		vb->resp_pos += RESP_POS_ADD_CHUNK;
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
 
-	/* When host has read buffer, this completes via balloon_ack */
-	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+			zero = find_next_zero_bit(bmap, end, one + 1);
+			if (zero >= end)
+				chunk_size = end - one;
+			else
+				chunk_size = zero - one;
 
+			if (chunk_size)
+				add_one_chunk(vb, vq, pfn_start + one,
+						chunk_size);
+			pos = one + chunk_size;
+		} else
+			break;
+	}
+}
+
+static void tell_host(struct virtio_balloon *vb, struct virtqueue *vq)
+{
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER)) {
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
+		if (vb->resp_pos > 0)
+			send_resp_data(vb, vq, false);
+	} else {
+		struct scatterlist sg;
+		unsigned int len;
+
+		sg_init_one(&sg, vb->pfns, sizeof(vb->pfns[0]) * vb->num_pfns);
+
+		/*
+		 * We should always be able to add one buffer to an
+		 * empty queue
+		 */
+		virtqueue_add_outbuf(vq, &sg, 1, vb, GFP_KERNEL);
+		virtqueue_kick(vq);
+		/* When host has read buffer, this completes via balloon_ack */
+		wait_event(vb->acked, virtqueue_get_buf(vq, &len));
+	}
 }
 
 static void set_page_pfns(struct virtio_balloon *vb,
@@ -138,13 +342,61 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
-static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
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
+}
+
+static unsigned int fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
-	unsigned num_allocated_pages;
+	unsigned int num_allocated_pages;
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_CHUNK_TRANSFER);
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (chunking)
+		init_page_bmap_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -159,7 +411,10 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
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
@@ -168,8 +423,13 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
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
@@ -189,15 +449,20 @@ static void release_pages_balloon(struct virtio_balloon *vb,
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
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_CHUNK_TRANSFER);
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (chunking)
+		init_page_bmap_range(vb);
+	else
+		/* We can only do one array worth at a time. */
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	/* We can't release more pages than taken */
@@ -207,7 +472,10 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (chunking)
+			update_page_bmap_range(vb, page);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -218,8 +486,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
@@ -431,6 +703,12 @@ static int init_vqs(struct virtio_balloon *vb)
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
+static void tell_host_one_page(struct virtio_balloon *vb,
+			       struct virtqueue *vq, struct page *page)
+{
+	add_one_chunk(vb, vq, page_to_pfn(page), 1);
+}
+
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
  *			     a compation thread.     (called under page lock)
@@ -455,6 +733,8 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
 	unsigned long flags;
+	bool chunking = virtio_has_feature(vb->vdev,
+					   VIRTIO_BALLOON_F_CHUNK_TRANSFER);
 
 	/*
 	 * In order to avoid lock contention while migrating pages concurrently
@@ -475,15 +755,23 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
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
+	if (chunking) {
+		tell_host_one_page(vb, vb->deflate_vq, page);
+	} else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, page);
+		tell_host(vb, vb->deflate_vq);
+	}
 
 	mutex_unlock(&vb->balloon_lock);
 
@@ -533,6 +821,30 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	spin_lock_init(&vb->stop_update_lock);
 	vb->stop_update = false;
 	vb->num_pages = 0;
+
+	/*
+	 * By default, we allocate page_bmap[0] only. More page_bmap will be
+	 * allocated on demand.
+	 */
+	vb->page_bmap[0] = kmalloc(PAGE_BMAP_SIZE, GFP_KERNEL);
+	if (!vb->page_bmap[0]) {
+		__virtio_clear_bit(vdev, VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+	} else {
+		vb->page_bmaps = 1;
+		vb->resp_hdr =
+			kmalloc(sizeof(struct virtio_balloon_resp_hdr) +
+				PAGE_BMAP_SIZE, GFP_KERNEL);
+		if (!vb->resp_hdr) {
+			__virtio_clear_bit(vdev,
+					   VIRTIO_BALLOON_F_CHUNK_TRANSFER);
+			kfree(vb->page_bmap[0]);
+		} else {
+			vb->resp_data = (void *)vb->resp_hdr +
+					sizeof(struct virtio_balloon_resp_hdr);
+			vb->resp_pos = 0;
+			vb->resp_buf_size = PAGE_BMAP_SIZE;
+		}
+	}
 	mutex_init(&vb->balloon_lock);
 	init_waitqueue_head(&vb->acked);
 	vb->vdev = vdev;
@@ -578,6 +890,8 @@ static int virtballoon_probe(struct virtio_device *vdev)
 out_del_vqs:
 	vdev->config->del_vqs(vdev);
 out_free_vb:
+	kfree(vb->resp_hdr);
+	free_page_bmap(vb);
 	kfree(vb);
 out:
 	return err;
@@ -611,6 +925,8 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	remove_common(vb);
 	if (vb->vb_dev_info.inode)
 		iput(vb->vb_dev_info.inode);
+	free_page_bmap(vb);
+	kfree(vb->resp_hdr);
 	kfree(vb);
 }
 
@@ -649,6 +965,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_CHUNK_TRANSFER,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 343d7dd..aa0e5f0 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_CHUNK_TRANSFER	3 /* Transfer pages in chunks */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
@@ -82,4 +83,12 @@ struct virtio_balloon_stat {
 	__virtio64 val;
 } __attribute__((packed));
 
+/* Response header structure */
+struct virtio_balloon_resp_hdr {
+	u8 cmd;
+	u8 flag;
+	__le16 id; /* cmd id */
+	__le32 data_len; /* Payload len in bytes */
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
