Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 655BE6B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 03:58:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id y68so295739962pfb.6
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 00:58:14 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y9si34807188plh.101.2016.11.30.00.58.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 00:58:13 -0800 (PST)
From: Liang Li <liang.z.li@intel.com>
Subject: [PATCH kernel v5 1/5] virtio-balloon: rework deflate to add page to a list
Date: Wed, 30 Nov 2016 16:43:13 +0800
Message-Id: <1480495397-23225-2-git-send-email-liang.z.li@intel.com>
In-Reply-To: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
References: <1480495397-23225-1-git-send-email-liang.z.li@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kvm@vger.kernel.org
Cc: virtualization@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, virtio-dev@lists.oasis-open.org, qemu-devel@nongnu.org, quintela@redhat.com, dgilbert@redhat.com, dave.hansen@intel.com, mst@redhat.com, jasowang@redhat.com, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, mhocko@suse.com, pbonzini@redhat.com, Liang Li <liang.z.li@intel.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>

When doing the inflating/deflating operation, the current virtio-balloon
implementation uses an array to save 256 PFNS, then send these PFNS to
host through virtio and process each PFN one by one. This way is not
efficient when inflating/deflating a large mount of memory because too
many times of the following operations:

    1. Virtio data transmission
    2. Page allocate/free
    3. Address translation(GPA->HVA)
    4. madvise

The over head of these operations will consume a lot of CPU cycles and
will take a long time to complete, it may impact the QoS of the guest as
well as the host. The overhead will be reduced a lot if batch processing
is used. E.g. If there are several pages whose address are physical
contiguous in the guest, these bulk pages can be processed in one
operation.

The main idea for the optimization is to reduce the above operations as
much as possible. And it can be achieved by using a bitmap instead of an
PFN array. Comparing with PFN array, for a specific size buffer, bitmap
can present more pages, which is very important for batch processing.

Using bitmap instead of PFN is not very helpful when inflating/deflating
a small mount of pages, in this case, using PFNs is better. But using
bitmap will not impact the QoS of guest or host heavily because the
operation will be completed very soon for a small mount of pages, and we
will use some methods to make sure the efficiency not drop too much.

This patch saves the deflated pages to a list instead of the PFN array,
which will allow faster notifications using a bitmap down the road.
balloon_pfn_to_page() can be removed because it's useless.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
---
 drivers/virtio/virtio_balloon.c | 22 ++++++++--------------
 1 file changed, 8 insertions(+), 14 deletions(-)

diff --git a/drivers/virtio/virtio_balloon.c b/drivers/virtio/virtio_balloon.c
index 181793f..f59cb4f 100644
--- a/drivers/virtio/virtio_balloon.c
+++ b/drivers/virtio/virtio_balloon.c
@@ -103,12 +103,6 @@ static u32 page_to_balloon_pfn(struct page *page)
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
@@ -181,18 +175,16 @@ static unsigned fill_balloon(struct virtio_balloon *vb, size_t num)
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
@@ -202,6 +194,7 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	unsigned num_freed_pages;
 	struct page *page;
 	struct balloon_dev_info *vb_dev_info = &vb->vb_dev_info;
+	LIST_HEAD(pages);
 
 	/* We can only do one array worth at a time. */
 	num = min(num, ARRAY_SIZE(vb->pfns));
@@ -215,6 +208,7 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 		if (!page)
 			break;
 		set_page_pfns(vb, vb->pfns + vb->num_pfns, page);
+		list_add(&page->lru, &pages);
 		vb->num_pages -= VIRTIO_BALLOON_PAGES_PER_PAGE;
 	}
 
@@ -226,7 +220,7 @@ static unsigned leak_balloon(struct virtio_balloon *vb, size_t num)
 	 */
 	if (vb->num_pfns != 0)
 		tell_host(vb, vb->deflate_vq);
-	release_pages_balloon(vb);
+	release_pages_balloon(vb, &pages);
 	mutex_unlock(&vb->balloon_lock);
 	return num_freed_pages;
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
