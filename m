Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id A8EE06B038E
	for <linux-mm@kvack.org>; Fri,  3 Mar 2017 00:44:17 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 10so32848330pgb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 21:44:17 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id b35si9546908plh.95.2017.03.02.21.44.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 21:44:16 -0800 (PST)
From: Wei Wang <wei.w.wang@intel.com>
Subject: [PATCH v7 kernel 1/5] virtio-balloon: rework deflate to add page to a list
Date: Fri,  3 Mar 2017 13:40:26 +0800
Message-Id: <1488519630-89058-2-git-send-email-wei.w.wang@intel.com>
In-Reply-To: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
References: <1488519630-89058-1-git-send-email-wei.w.wang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: virtio-dev@lists.oasis-open.org, kvm@vger.kernel.org, qemu-devel@nongnu.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, linux-mm@kvack.org
Cc: Liang Li <liang.z.li@intel.com>, "Michael S . Tsirkin" <mst@redhat.com>, Paolo Bonzini <pbonzini@redhat.com>, Cornelia Huck <cornelia.huck@de.ibm.com>, Amit Shah <amit.shah@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, David Hildenbrand <david@redhat.com>, Liang Li <liliang324@gmail.com>, Wei Wang <wei.w.wang@intel.com>

From: Liang Li <liang.z.li@intel.com>

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
much as possible. And it can be achieved by using a {pfn|length} array
instead of a PFN array. Comparing with PFN array, {pfn|length} array can
present more pages and is fit for batch processing.

This patch saves the deflated pages to a list instead of the PFN array,
which will allow faster notifications using the {pfn|length} down the
road. balloon_pfn_to_page() can be removed because it's useless.

Signed-off-by: Liang Li <liang.z.li@intel.com>
Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Cornelia Huck <cornelia.huck@de.ibm.com>
Cc: Amit Shah <amit.shah@redhat.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: David Hildenbrand <david@redhat.com>
Cc: Liang Li <liliang324@gmail.com>
Cc: Wei Wang <wei.w.wang@intel.com>
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
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
