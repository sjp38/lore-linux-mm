Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B185F6B0661
	for <linux-mm@kvack.org>; Thu,  3 Aug 2017 02:48:44 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id y129so5645298pgy.1
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 23:48:44 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id z66si1004619pff.284.2017.08.02.23.48.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Aug 2017 23:48:43 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v13 3/5] virtio-balloon: VIRTIO_BALLOON_F_SG
Date: Thu,  3 Aug 2017 14:38:17 +0800
Message-Id: <1501742299-4369-4-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
References: <1501742299-4369-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, mhocko@kernel.org, mawilcox@microsoft.com, akpm@linux-foundation.org
Cc: virtio-dev@lists.oasis-open.org, david@redhat.com, cornelia.huck@de.ibm.com, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, liliang.opensource@gmail.com, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

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

With this new feature, the above ballooning process takes ~541ms
resulting in an improvement of ~87%.

TODO: optimize stage 1) by allocating/freeing a chunk of pages
instead of a single page each time.

Signed-off-by: Wei Wang <wei.w.wang@intel.com>
Signed-off-by: Liang Li <liang.z.li@intel.com>
Suggested-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/virtio/virtio_balloon.c     | 150 ++++++++++++++++++++++++++++++++----
 include/uapi/linux/virtio_balloon.h |   1 +
 2 files changed, 134 insertions(+), 17 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index f0b3a0b..29aca0c 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -32,6 +32,7 @@
 #include <linux/mm.h>
 #include <linux/mount.h>
 #include <linux/magic.h>
+#include <linux/xbitmap.h>
 
 /*
  * Balloon device works in 4K page units.  So each page is pointed to by
@@ -79,6 +80,9 @@ struct virtio_balloon {
 	/* Synchronize access/update to this struct virtio_balloon elements */
 	struct mutex balloon_lock;
 
+	/* The xbitmap used to record ballooned pages */
+	struct xb page_xb;
+
 	/* The array of pfns we tell the Host about. */
 	unsigned int num_pfns;
 	__virtio32 pfns[VIRTIO_BALLOON_ARRAY_PFNS_MAX];
@@ -141,13 +145,90 @@ static void set_page_pfns(struct virtio_balloon *vb,
 					  page_to_balloon_pfn(page) + i);
 }
 
+static void send_one_sg(struct virtio_balloon *vb, struct virtqueue *vq,
+			void *addr, uint32_t size)
+{
+	struct scatterlist sg;
+	unsigned int len;
+
+	sg_init_one(&sg, addr, size);
+	while (unlikely(virtqueue_add_inbuf(vq, &sg, 1, vb, GFP_KERNEL)
+			== -ENOSPC)) {
+		/*
+		 * It is uncommon to see the vq is full, because the sg is sent
+		 * one by one and the device is able to handle it in time. But
+		 * if that happens, we kick and wait for an entry is released.
+		 */
+		virtqueue_kick(vq);
+		while (!virtqueue_get_buf(vq, &len) &&
+		       !virtqueue_is_broken(vq))
+			cpu_relax();
+	}
+	virtqueue_kick(vq);
+	wait_event(vb->acked, virtqueue_get_buf(vq, &len));
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
+		sg_pfn_start = xb_find_next_bit(&vb->page_xb, sg_pfn_start,
+						page_xb_end, 1);
+		if (sg_pfn_start == page_xb_end + 1)
+			break;
+		sg_pfn_end = xb_find_next_bit(&vb->page_xb, sg_pfn_start + 1,
+					      page_xb_end, 0);
+		sg_addr = pfn_to_kaddr(sg_pfn_start);
+		sg_len = (sg_pfn_end - sg_pfn_start) << PAGE_SHIFT;
+		while (sg_len > sg_max_len) {
+			send_one_sg(vb, vq, sg_addr, sg_max_len);
+			sg_addr += sg_max_len;
+			sg_len -= sg_max_len;
+		}
+		send_one_sg(vb, vq, sg_addr, sg_len);
+		xb_zero(&vb->page_xb, sg_pfn_start, sg_pfn_end);
+		sg_pfn_start = sg_pfn_end + 1;
+	}
+}
+
+static inline void xb_set_page(struct virtio_balloon *vb,
+			       struct page *page,
+			       unsigned long *pfn_min,
+			       unsigned long *pfn_max)
+{
+	unsigned long pfn = page_to_pfn(page);
+
+	*pfn_min = min(pfn, *pfn_min);
+	*pfn_max = max(pfn, *pfn_max);
+	xb_set_bit(&vb->page_xb, pfn);
+}
+
 static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 {
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
 	unsigned num_allocated_pages;
+	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
+	unsigned long pfn_max = 0, pfn_min = ULONG_MAX;
 
 	/* We can only do one array worth at a time. */
-	num = min(num, ARRAY_SIZE(vb->pfns));
+	if (!use_sg)
+		num = min(num, ARRAY_SIZE(vb->pfns));
 
 	mutex_lock(&vb->balloon_lock);
 	for (vb->num_pfns = 0; vb->num_pfns < num;
@@ -162,7 +243,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 			msleep(200);
 			break;
 		}
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+
+		if (use_sg)
+			xb_set_page(vb, page, &pfn_min, &pfn_max);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+
 		vb->num_pages += VIRTIO_BALLOON_PAGES_PER_PAGE;
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
@@ -171,8 +257,12 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 
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
@@ -198,9 +288,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
@@ -210,7 +303,11 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		page = balloon_page_dequeue(vb_dev_info);
 		if (!page)
 			break;
-		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		if (use_sg)
+			xb_set_page(vb, page, &pfn_min, &pfn_max);
+		else
+			set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+
 		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
@@ -221,8 +318,12 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
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
@@ -441,6 +542,7 @@ static int init_vqs(struct virtio_balloon *vb)
 }
 
 #ifdef CONFIG_BALLOON_COMPACTION
+
 /*
  * virtballoon_migratepage - perform the balloon page migration on behalf of
  *			     a compation thread.     (called under page lock)
@@ -464,6 +566,7 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 {
 	struct virtio_balloon *vb = container_of(vb_dev_info,
 			struct virtio_balloon, vb_dev_info);
+	bool use_sg = virtio_has_feature(vb->vdev, VIRTIO_BALLOON_F_SG);
 	unsigned long flags;
 
 	/*
@@ -485,16 +588,24 @@ static int virtballoon_migratepage(struct balloon_dev_info *vb_dev_info,
 	vb_dev_info->isolated_pages--;
 	__count_vm_event(BALLOON_MIGRATE);
 	spin_unlock_irqrestore(&vb_dev_info->pages_lock, flags);
-	vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
-	set_page_pfns(vb, vb->pfns, newpage);
-	tell_host(vb, vb->inflate_vq);
-
+	if (use_sg) {
+		send_one_sg(vb, vb->inflate_vq, page_address(newpage),
+			    PAGE_SIZE);
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
+		send_one_sg(vb, vb->deflate_vq, page_address(page),
+			    PAGE_SIZE);
+	} else {
+		vb->num_pfns = VIRTIO_BALLOON_PAGES_PER_PAGE;
+		set_page_pfns(vb, vb->pfns, page);
+		tell_host(vb, vb->deflate_vq);
+	}
 	mutex_unlock(&vb->balloon_lock);
 
 	put_page(page); /* balloon reference */
@@ -553,6 +664,9 @@ static int virtballoon_probe(struct virtio_device *vdev)
 	if (err)
 		goto out_free_vb;
 
+	if (virtio_has_feature(vdev, VIRTIO_BALLOON_F_SG))
+		xb_init(&vb->page_xb);
+
 	vb->nb.notifier_call = virtballoon_oom_notify;
 	vb->nb.priority = VIRTBALLOON_OOM_NOTIFY_PRIORITY;
 	err = register_oom_notifier(&vb->nb);
@@ -618,6 +732,7 @@ static void virtballoon_remove(struct virtio_device *vdev)
 	cancel_work_sync(&vb->update_balloon_size_work);
 	cancel_work_sync(&vb->update_balloon_stats_work);
 
+	xb_empty(&vb->page_xb);
 	remove_common(vb);
 #ifdef CONFIG_BALLOON_COMPACTION
 	if (vb->vb_dev_info.inode)
@@ -669,6 +784,7 @@ static unsigned int features[] = {
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
