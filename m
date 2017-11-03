Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id ECA166B026A
	for <linux-mm@kvack.org>; Fri,  3 Nov 2017 04:28:28 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id f85so2155038pfe.7
        for <linux-mm@kvack.org>; Fri, 03 Nov 2017 01:28:28 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 64si4262449ply.756.2017.11.03.01.28.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 03 Nov 2017 01:28:27 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v17 4/6] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Fri,  3 Nov 2017 16:13:04 +0800
Message-Id: <1509696786-1597-5-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
References: <1509696786-1597-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, akpm@linux-foundation.org, mawilcox@microsoft.com
Cc: david@redhat.com, penguin-kernel@I-love.SAKURA.ne.jp, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, willy@infradead.org, wei.w.wang@intel.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

Add a new feature, VIRTIO_BALLOON_F_SG, which enables the transfer
of balloon (i.e. inflated/deflated) pages using scatter-gather lists
to the host.

The implementation of the previous virtio-balloon is not very
efficient, because the balloon pages are transferred to the
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
sgs. An sg describes a chunk of guest physically continuous pages.
With this mechanism, step 4) can also be optimized by doing address
translation and madvise() in chunks rather than page by page.

With this new feature, the above ballooning process takes ~492ms
resulting in an improvement of ~88%.

TODO: optimize stage 1) by allocating/freeing a chunk of pages
instead of a single page each time.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 drivers/virtio/virtio_balloon.c     | 232 +++++++++++++++++++++++++++++++++---
 include/uapi/linux/virtio_balloon.h |   1 +
 2 files changed, 215 insertions(+), 18 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 45fe6a8..b31fc25 100644
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
@@ -141,15 +146,130 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
+
+static void kick_and_wait(struct virtqueue *vq, wait_queue_head_t wq_head)
+{
+	unsigned int len;
+
+	virtqueue_kick(vq);
+	wait_event(wq_head, virtqueue_get_buf(vq, &len));
+}
+
+static int add_one_sg(struct virtqueue *vq, void *addr, uint32_t size)
+{
+	struct scatterlist sg;
+	unsigned int len;
+
+	sg_init_one(&sg, addr, size);
+
+	/* Detach all the used buffers from the vq */
+	while (virtqueue_get_buf(vq, &len))
+		;
+
+	return virtqueue_add_inbuf(vq, &sg, 1, vq, GFP_KERNEL);
+}
+
+static void send_balloon_page_sg(struct virtio_balloon *vb,
+				 struct virtqueue *vq,
+				 void *addr,
+				 uint32_t size,
+				 bool batch)
+{
+	int err;
+
+	err = add_one_sg(vq, addr, size);
+	/*
+	 * This is expected to never fail: there is always at least 1 entry
+	 * available on the vq, because when the vq is full the worker thread
+	 * that adds the sg will be put into sleep until at least 1 entry is
+	 * available to use.
+	 */
+	BUG_ON(err);
+
+	/* If batching is requested, we batch till the vq is full */
+	if (!batch || !vq->num_free)
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
+	unsigned long sg_pfn_start, sg_pfn_end;
+	void *sg_addr;
+	uint32_t sg_len, sg_max_len = round_down(UINT_MAX, PAGE_SIZE);
+
+	sg_pfn_start = page_xb_start;
+	while (sg_pfn_start < page_xb_end) {
+		sg_pfn_start = xb_find_next_set_bit(&vb->page_xb, sg_pfn_start,
+						    page_xb_end);
+		if (sg_pfn_start == page_xb_end + 1)
+			break;
+		sg_pfn_end = xb_find_next_zero_bit(&vb->page_xb,
+						   sg_pfn_start + 1,
+						   page_xb_end);
+		sg_addr = (void *)pfn_to_kaddr(sg_pfn_start);
+		sg_len = (sg_pfn_end - sg_pfn_start) << PAGE_SHIFT;
+		while (sg_len > sg_max_len) {
+			send_balloon_page_sg(vb, vq, sg_addr, sg_max_len,
+					     true);
+			sg_addr += sg_max_len;
+			sg_len -= sg_max_len;
+		}
+		send_balloon_page_sg(vb, vq, sg_addr, sg_len, true);
+		sg_pfn_start = sg_pfn_end + 1;
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
+		ret = xb_preload_and_set_bit(&vb->page_xb, pfn, GFP_KERNEL);
+	} while (unlikely(ret == -EAGAIN));
+
+	return ret;
+}
+
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	unsigned num_allocated_pages;
 	unsigned int num_pfns;
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
@@ -164,6 +284,8 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			break;
 		}
 
+		if (use_sg && xb_set_page(vb, page, &pfn_min, &pfn_max) < 0)
+			break;
 		balloon_page_push(&pages, page);
 	}
 
@@ -175,7 +297,8 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
 		vb->num_pfns += VIRTIO_BALLOON_PAGES_PER_PAGE;
 
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (!use_sg)
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -184,8 +307,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
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
@@ -211,9 +338,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
@@ -223,7 +353,13 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_sg) {
+			if (xb_set_page(vb, page, &pfn_min, &pfn_max) < 0)
+				break;
+		} else {
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		}
+
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -234,13 +370,56 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
+		send_balloon_page_sg(vb, vq, page_address(page),
+				     VIRTIO_BALLOON_PAGES_PER_PAGE, true);
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
+
 static inline void update_stat(struct virtio_balloon *vb, int idx,
 			       u16 tag, u64 val)
 {
@@ -380,7 +559,10 @@ static int virtballoon_oom_notify(struct notifier_block *self,
 		return NOTIFY_OK;
 
 	freed = parm;
-	num_freed_pages = leak_balloon(vb, oom_pages);
+	if (virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG))
+		num_freed_pages = leak_balloon_sg_oom(vb);
+	else
+		num_freed_pages = leak_balloon(vb, oom_pages);
 	update_balloon_size(vb);
 	*freed += num_freed_pages;
 
@@ -454,6 +636,7 @@ static int init_vqs(struct virtio_balloon *vb)
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
+
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
  *			     a compation thread.     (called under page lock)
@@ -477,6 +660,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 {
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
+	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
 	unsigned long flags;
 
 	/*
@@ -498,16 +682,24 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
-
+	if (use_sg) {
+		send_balloon_page_sg(vb, vb->inflate_vq, page_address(newpage),
+				     PAGE_SIZE, false);
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
+		send_balloon_page_sg(vb, vb->deflate_vq, page_address(page),
+				     PAGE_SIZE, false);
+	} else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, page);
+		tell_host(vb, vb->deflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	put_page(page); /* balloon reference */
@@ -566,6 +758,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (err)
 		goto out_free_vb;
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
+		xb_init(&vb->page_xb);
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
@@ -682,6 +877,7 @@ static unsigned int features[] = {
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
