Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id ADB5C6B0518
	for <linux-mm@kvack.org>; Wed, 12 Jul 2017 08:47:27 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p1so22548521pfl.2
        for <linux-mm@kvack.org>; Wed, 12 Jul 2017 05:47:27 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id j10si1876028pfc.13.2017.07.12.05.47.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Jul 2017 05:47:26 -0700 (PDT)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v12 1/8] virtio-balloon: deflate via a page list
Date: Wed, 12 Jul 2017 20:40:14 +0800
Message-Id: <1499863221-16206-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
References: <1499863221-16206-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, qemu-devel@nongnu.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-mm@kvack.org, mst@redhat.com, david@redhat.com, cornelia.huck@de.ibm.com, akpm@linux-foundation.org, mgorman@techsingularity.net, aarcange@redhat.com, amit.shah@redhat.com, pbonzini@redhat.com, wei.w.wang@intel.com, liliang.opensource@gmail.com
Cc: virtio-dev@lists.oasis-open.org, yang.zhang.wz@gmail.com, quan.xu@aliyun.com

From: Liang Li <liang.z.li@intel.com>

This patch saves the deflated pages to a list, instead of the PFN array.
Accordingly, the balloon_pfn_to_page() function is removed.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Wei Wang <wei.w.wang@intel.com>
---
 drivers/virtio/virtio_balloon.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 22caf80..7f38ae6 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -104,12 +104,6 @@ static u32 page_to_balloon_pfn(struct page *page)
 	return pfn * VIRTIO_BALLOON_PAGES_PER_PAGE;
 }
 
-static struct page *balloon_pfn_to_page(u32 pfn)
-{
-	BUG_ON(pfn % VIRTIO_BALLOON_PAGES_PER_PAGE);
-	return pfn_to_page(pfn / VIRTIO_BALLOON_PAGES_PER_PAGE);
-}
-
 static void balloon_ack(struct virtqueue *vq)
 {
 	struct virtio_balloon *vb = vq->vdev->priv;
@@ -182,18 +176,16 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
 	return num_allocated_pages;
 }
 
-static void release_pages_balloon(struct virtio_balloon *vb)
+static void release_pages_balloon(struct virtio_balloon *vb,
+				 struct list_head *pages)
 {
-	unsigned int i;
-	struct page *page;
+	struct page *page, *next;
 
-	/* Find pfns pointing at start of each page, get pages and free them. */
-	for (i = 0; i < vb->num_pfns; i += VIRTIO_BALLOON_PAGES_PER_PAGE) {
-		page = balloon_pfn_to_page(virtio32_to_cpu(vb->vdev,
-							   vb->pfns[i]));
+	list_for_each_entry_safe(page, next, pages, lru) {
 		if (!virtio_has_feature(vb->vdev,
 					VIRTIO_BALLOON_F_DEFLATE_ON_OOM))
 			adjust_managed_page_count(page, 1);
+		list_del(&page->lru);
 		put_page(page); /* balloon reference */
 	}
 }
@@ -203,6 +195,7 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	unsigned num_freed_pages;
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
+	LIST_HEAD(pages);
 
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
@@ -216,6 +209,7 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		if (!page)
 			break;
 		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
 
@@ -227,7 +221,7 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 */
 	if (vb->num_pfns != 0)
 		tell_host(vb, vb->deflate_vq);
-	release_pages_balloon(vb);
+	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
