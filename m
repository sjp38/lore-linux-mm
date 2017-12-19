Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 541876B0275
	for <linux-mm@kvack.org>; Tue, 19 Dec 2017 07:34:59 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id x10so4408545pgx.12
        for <linux-mm@kvack.org>; Tue, 19 Dec 2017 04:34:59 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id v8si9119558plg.831.2017.12.19.04.34.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Dec 2017 04:34:57 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v20 4/7] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Tue, 19 Dec 2017 20:17:56 +0800
Message-Id: <1513685879-21823-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
References: <1513685879-21823-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu0@gmail.com, nilal@redhat.com, riel@redhat.com

Add a new feature, VIRTIO_BALLOON_F_SG, which enables the transfer of
balloon (i.e. inflated/deflated) pages using scatter-gather lists to the
host.

The implementation of the previous virtio-balloon is not very efficient,
because the balloon pages are transferred to the host by one array each
time. Here is the breakdown of the time in percentage spent on each step
of the balloon inflating process (inflating 7GB of an 8GB idle guest).

1) allocating pages (6.5%)
2) sending PFNs to host (68.3%)
3) address translation (6.1%)
4) madvise (19%)

It takes about 4126ms for the inflating process to complete. The above
profiling shows that the bottlenecks are stage 2) and stage 4).

This patch optimizes step 2) by transferring pages to host in sgs. An sg
describes a chunk of guest physically continuous pages. With this
mechanism, step 4) can also be optimized by doing address translation and
madvise() in chunks rather than page by page.

With this new feature, the above ballooning process takes ~460ms resulting
in an improvement of ~89%.

TODO:
- optimize stage 1) by allocating/freeing a chunk of pages instead of a
single page each time.
- sort the internal balloon page queue.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/virtio/virtio_balloon.c     | 234 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |   1 +
 2 files changed, 217 insertions(+), 18 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index a1fb52c..fff0a3f 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -32,6 +32,8 @@
 #include <linux/mm.h>
 #include <linux/mount.h>
 #include <linux/magic.h>
+#include <linux/xbitmap.h>
+#include <asm/page.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -79,6 +81,9 @@ struct virtio_balloon {
 	/* Synchronize access/update to this struct virtio_balloon elements */
 	struct mutex balloon_lock;
 
+	/* The xbitmap used to record balloon pages */
+	struct xb page_xb;
+
 	/* The array of pfns we tell the Host about. */
 	unsigned int num_pfns;
 	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
@@ -141,15 +146,129 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
+static void kick_and_wait(struct virtqueue *vq, wait_queue_head_t wq_head)
+{
+	unsigned int len;
+
+	virtqueue_kick(vq);
+	wait_event(wq_head, virtqueue_get_buf(vq, &len));
+}
+
+static void add_one_sg(struct virtqueue *vq, unsigned long pfn, uint32_t len)
+{
+	struct scatterlist sg;
+	unsigned int unused;
+	int err;
+
+	sg_init_table(&sg, 1);
+	sg_set_page(&sg, pfn_to_page(pfn), len, 0);
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &unused))
+		;
+
+	err = virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
+	/*
+	 * This is expected to never fail: there is always at least 1 entry
+	 * available on the vq, because when the vq is full the worker thread
+	 * that adds the sg will be put into sleep until at least 1 entry is
+	 * available to use.
+	 */
+	BUG_ON(err);
+}
+
+static void batch_balloon_page_sg(struct virtio_balloon *vb,
+				  struct virtqueue *vq,
+				  unsigned long pfn,
+				  uint32_t len)
+{
+	add_one_sg(vq, pfn, len);
+
+	/* Batch till the vq is full */
+	if (!vq->num_free)
+		kick_and_wait(vq, vb->acked);
+}
+
+/*
+ * Send balloon pages in sgs to host. The balloon pages are recorded in the
+ * page xbitmap. Each bit in the bitmap corresponds to a page of PAGE_SIZE.
+ * The page xbitmap is searched for continuous "1" bits, which correspond
+ * to continuous pages, to chunk into sgs.
+ *
+ * @page_xb_start and @page_xb_end form the range of bits in the xbitmap that
+ * need to be searched.
+ */
+static void tell_host_sgs(struct virtio_balloon *vb,
+			  struct virtqueue *vq,
+			  unsigned long page_xb_start,
+			  unsigned long page_xb_end)
+{
+	unsigned long pfn_start, pfn_end;
+	uint32_t max_len = round_down(UINT_MAX, PAGE_SIZE);
+	uint64_t len;
+
+	pfn_start = page_xb_start;
+	while (pfn_start < page_xb_end) {
+		pfn_start = xb_find_set(&vb->page_xb, page_xb_end + 1,
+					pfn_start);
+		if (pfn_start == page_xb_end + 1)
+			break;
+		pfn_end = xb_find_zero(&vb->page_xb, page_xb_end + 1,
+				       pfn_start);
+		len = (pfn_end - pfn_start) << PAGE_SHIFT;
+		while (len > max_len) {
+			batch_balloon_page_sg(vb, vq, pfn_start, max_len);
+			pfn_start += max_len >> PAGE_SHIFT;
+			len -= max_len;
+		}
+		batch_balloon_page_sg(vb, vq, pfn_start, (uint32_t)len);
+		pfn_start = pfn_end + 1;
+	}
+
+	/*
+	 * The last few sgs may not reach the batch size, but need a kick to
+	 * notify the device to handle them.
+	 */
+	if (vq->num_free != virtqueue_get_vring_size(vq))
+		kick_and_wait(vq, vb->acked);
+
+	xb_clear_bit_range(&vb->page_xb, page_xb_start, page_xb_end);
+}
+
+static inline int xb_set_page(struct virtio_balloon *vb,
+			       struct page *page,
+			       unsigned long *pfn_min,
+			       unsigned long *pfn_max)
+{
+	unsigned long pfn = page_to_pfn(page);
+	int ret;
+
+	*pfn_min = min(pfn, *pfn_min);
+	*pfn_max = max(pfn, *pfn_max);
+
+	do {
+		if (xb_preload(GFP_NOWAIT | __GFP_NOWARN) < 0)
+			return -ENOMEM;
+
+		ret = xb_set_bit(&vb->page_xb, pfn);
+		xb_preload_end();
+	} while (unlikely(ret == -EAGAIN));
+
+	return ret;
+}
+
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	unsigned num_allocated_pages;
 	unsigned num_pfns;
 	struct page *page;
 	LIST_HEAD(pages);
+	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
+	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
 
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (!use_sg)
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	for (num_pfns = 0; num_pfns < num;
 	     num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE) {
@@ -173,8 +292,15 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
 	while ((page = balloon_page_pop(&pages))) {
 		balloon_page_enqueue(&vb->vb_dev_info, page);
+		if (use_sg) {
+			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
+				__free_page(page);
+				continue;
+			}
+		} else {
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		}
 
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -184,8 +310,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
 	num_allocated_pages = vb->num_pfns;
 	/* Did we get any? */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->inflate_vq);
+	if (vb->num_pfns) {
+		if (use_sg)
+			tell_host_sgs(vb, vb->inflate_vq, pfn_min, pfn_max);
+		else
+			tell_host(vb, vb->inflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	return num_allocated_pages;
@@ -211,9 +341,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	LIST_HEAD(pages);
+	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
+	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
 
-	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	/* Traditionally, we can only do one array worth at a time. */
+	if (!use_sg)
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	/* We can't release more pages than taken */
@@ -223,7 +356,14 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_sg) {
+			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0) {
+				balloon_page_enqueue(&vb->vb_dev_info, page);
+				break;
+			}
+		} else {
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		}
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -234,13 +374,55 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 * virtio_has_feature(vdev, VIRTIO_BALLOON_F_MUST_TELL_HOST);
 	 * is true, we *have* to do it in this order
 	 */
-	if (vb->num_pfns != 0)
-		tell_host(vb, vb->deflate_vq);
+	if (vb->num_pfns) {
+		if (use_sg)
+			tell_host_sgs(vb, vb->deflate_vq, pfn_min, pfn_max);
+		else
+			tell_host(vb, vb->deflate_vq);
+	}
 	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
 }
 
+/*
+ * The regular leak_balloon() with VIRTIO_BALLOON_F_SG needs memory allocation
+ * for xbitmap, which is not suitable for the oom case. This function does not
+ * use xbitmap to chunk pages, so it can be used by oom notifier to deflate
+ * pages when VIRTIO_BALLOON_F_SG is negotiated.
+ */
+static unsigned int leak_balloon_sg_oom(struct virtio_balloon *vb)
+{
+	unsigned int n;
+	struct page *page;
+	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
+	struct virtqueue *vq = vb->deflate_vq;
+	LIST_HEAD(pages);
+
+	mutex_lock(&vb->balloon_lock);
+	for (n = 0; n < oom_pages; n++) {
+		page = balloon_page_dequeue(vb_dev_info);
+		if (!page)
+			break;
+
+		list_add(&page->lru, &pages);
+		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
+		batch_balloon_page_sg(vb, vb->deflate_vq, page_to_pfn(page),
+				      PAGE_SIZE);
+		release_pages_balloon(vb, &pages);
+	}
+
+	/*
+	 * The last few sgs may not reach the batch size, but need a kick to
+	 * notify the device to handle them.
+	 */
+	if (vq->num_free != virtqueue_get_vring_size(vq))
+		kick_and_wait(vq, vb->acked);
+	mutex_unlock(&vb->balloon_lock);
+
+	return n;
+}
+
 static inline void update_stat(struct virtio_balloon *vb, int idx,
 			       u16 tag, u64 val)
 {
@@ -380,7 +562,10 @@ static int virtballoon_oom_notify(struct notifier_block *self,
 		return NOTIFY_OK;
 
 	freed = parm;
-	num_freed_pages = leak_balloon(vb, oom_pages);
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG))
+		num_freed_pages = leak_balloon_sg_oom(vb);
+	else
+		num_freed_pages = leak_balloon(vb, oom_pages);
 	update_balloon_size(vb);
 	*freed += num_freed_pages;
 
@@ -477,6 +662,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 {
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
+	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
 	unsigned long flags;
 
 	/*
@@ -498,16 +684,24 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
-
+	if (use_sg) {
+		add_one_sg(vb->inflate_vq, page_to_pfn(newpage), PAGE_SIZE);
+		kick_and_wait(vb->inflate_vq, vb->acked);
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
+	if (use_sg) {
+		add_one_sg(vb->deflate_vq, page_to_pfn(page), PAGE_SIZE);
+		kick_and_wait(vb->deflate_vq, vb->acked);
+	} else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, page);
+		tell_host(vb, vb->deflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	put_page(page); /* balloon reference */
@@ -566,6 +760,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (err)
 		goto out_free_vb;
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
+		xb_init(&vb->page_xb);
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
@@ -682,6 +879,7 @@ static unsigned int features[] = {
 	VIRTIO_BALLOON_F_MUST_TELL_HOST,
 	VIRTIO_BALLOON_F_STATS_VQ,
 	VIRTIO_BALLOON_F_DEFLATE_ON_OOM,
+	VIRTIO_BALLOON_F_SG,
 };
 
 static struct virtio_driver virtio_balloon_driver = {
diff --git a/include/uapi/linux/virtio_balloon.h b/include/uapi/linux/virtio_balloon.h
index 343d7dd..37780a7 100644
--- a/include/uapi/linux/virtio_balloon.h
+++ b/include/uapi/linux/virtio_balloon.h
@@ -34,6 +34,7 @@
 #define VIRTIO_BALLOON_F_MUST_TELL_HOST	0 /* Tell before reclaiming pages */
 #define VIRTIO_BALLOON_F_STATS_VQ	1 /* Memory Stats virtqueue */
 #define VIRTIO_BALLOON_F_DEFLATE_ON_OOM	2 /* Deflate balloon on OOM */
+#define VIRTIO_BALLOON_F_SG		3 /* Use sg instead of PFN lists */
 
 /* Size of a PFN in the balloon interface. */
 #define VIRTIO_BALLOON_PFN_SHIFT 12
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
