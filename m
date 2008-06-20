From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 2/2] hugetlb reservations: fix hugetlb MAP_PRIVATE reservations across vma splits
Date: Fri, 20 Jun 2008 20:17:54 +0100
Message-Id: <1213989474-5586-3-git-send-email-apw@shadowen.org>
In-Reply-To: <1213989474-5586-1-git-send-email-apw@shadowen.org>
References: <1213989474-5586-1-git-send-email-apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jon Tollefson <kniht@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Nishanth Aravamudan <nacc@us.ibm.com>, Adam Litke <agl@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, kernel-testers@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

When a hugetlb mapping with a reservation is split, a new VMA is cloned
from the original.  This new VMA is a direct copy of the original
including the reservation count.  When this pair of VMAs are unmapped
we will incorrect double account the unused reservation and the overall
reservation count will be incorrect, in extreme cases it will wrap.

The problem occurs when we split an existing VMA say to unmap a page in
the middle.  split_vma() will create a new VMA copying all fields from
the original.  As we are storing our reservation count in vm_private_data
this is also copies, endowing the new VMA with a duplicate of the original
VMA's reservation.  Neither of the new VMAs can exhaust these reservations
as they are too small, but when we unmap and close these VMAs we will
incorrect credit the remainder twice and resv_huge_pages will become
out of sync.  This can lead to allocation failures on mappings with
reservations and even to resv_huge_pages wrapping which prevents all
subsequent hugepage allocations.

The simple fix would be to correctly apportion the remaining reservation
count when the split is made.  However the only hook we have vm_ops->open
only has the new VMA we do not know the identity of the preceeding VMA.
Also even if we did have that VMA to hand we do not know how much of the
reservation was consumed each side of the split.

This patch therefore takes a different tack.  We know that the whole of any
private mapping (which has a reservation) has a reservation over its whole
size.  Any present pages represent consumed reservation.  Therefore if
we track the instantiated pages we can calculate the remaining reservation.

This patch reuses the existing regions code to track the regions for which
we have consumed reservation (ie. the instantiated pages), as each page
is faulted in we record the consumption of reservation for the new page.
When we need to return unused reservations at unmap time we simply count
the consumed reservation region subtracting that from the whole of the map.
During a VMA split the newly opened VMA will point to the same region map,
as this map is offset oriented it remains valid for both of the split VMAs.
This map is referenced counted so that it is removed when all VMAs which
are part of the mmap are gone.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/hugetlb.c |  151 ++++++++++++++++++++++++++++++++++++++++++++++++----------
 1 files changed, 126 insertions(+), 25 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index d701e39..ecff986 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -171,6 +171,30 @@ static long region_truncate(struct list_head *head, long end)
 	return chg;
 }
 
+static long region_count(struct list_head *head, long f, long t)
+{
+	struct file_region *rg;
+	long chg = 0;
+
+	/* Locate each segment we overlap with, and count that overlap. */
+	list_for_each_entry(rg, head, link) {
+		int seg_from;
+		int seg_to;
+
+		if (rg->to <= f)
+			continue;
+		if (rg->from >= t)
+			break;
+
+		seg_from = max(rg->from, f);
+		seg_to = min(rg->to, t);
+
+		chg += seg_to - seg_from;
+	}
+
+	return chg;
+}
+
 /*
  * Convert the address within this vma to the page offset within
  * the mapping, in base page units.
@@ -193,9 +217,14 @@ static pgoff_t vma_pagecache_offset(struct hstate *h,
 			(vma->vm_pgoff >> huge_page_order(h));
 }
 
-#define HPAGE_RESV_OWNER    (1UL << (BITS_PER_LONG - 1))
-#define HPAGE_RESV_UNMAPPED (1UL << (BITS_PER_LONG - 2))
+/*
+ * Flags for MAP_PRIVATE reservations.  These are stored in the bottom
+ * bits of the reservation map pointer.
+ */
+#define HPAGE_RESV_OWNER    (1UL << 0)
+#define HPAGE_RESV_UNMAPPED (1UL << 1)
 #define HPAGE_RESV_MASK (HPAGE_RESV_OWNER | HPAGE_RESV_UNMAPPED)
+
 /*
  * These helpers are used to track how many pages are reserved for
  * faults in a MAP_PRIVATE mapping. Only the process that called mmap()
@@ -205,6 +234,15 @@ static pgoff_t vma_pagecache_offset(struct hstate *h,
  * the reserve counters are updated with the hugetlb_lock held. It is safe
  * to reset the VMA at fork() time as it is not in use yet and there is no
  * chance of the global counters getting corrupted as a result of the values.
+ *
+ * The private mapping reservation is represented in a subtly different
+ * manner to a shared mapping.  A shared mapping has a region map associated
+ * with the underlying file, this region map represents the backing file
+ * pages which have had a reservation taken and this persists even after
+ * the page is instantiated.  A private mapping has a region map associated
+ * with the original mmap which is attached to all VMAs which reference it,
+ * this region map represents those offsets which have consumed reservation
+ * ie. where pages have been instantiated.
  */
 static unsigned long get_vma_private_data(struct vm_area_struct *vma)
 {
@@ -217,22 +255,44 @@ static void set_vma_private_data(struct vm_area_struct *vma,
 	vma->vm_private_data = (void *)value;
 }
 
-static unsigned long vma_resv_huge_pages(struct vm_area_struct *vma)
+struct resv_map {
+	struct kref refs;
+	struct list_head regions;
+};
+
+struct resv_map *resv_map_alloc(void)
+{
+	struct resv_map *resv_map = kmalloc(sizeof(*resv_map), GFP_KERNEL);
+	if (!resv_map)
+		return NULL;
+
+	kref_init(&resv_map->refs);
+	INIT_LIST_HEAD(&resv_map->regions);
+
+	return resv_map;
+}
+
+void resv_map_release(struct kref *ref)
+{
+        struct resv_map *resv_map = container_of(ref, struct resv_map, refs);
+
+	region_truncate(&resv_map->regions, 0);
+	kfree(resv_map);
+}
+
+static struct resv_map *vma_resv_map(struct vm_area_struct *vma)
 {
 	VM_BUG_ON(!is_vm_hugetlb_page(vma));
 	if (!(vma->vm_flags & VM_SHARED))
-		return get_vma_private_data(vma) & ~HPAGE_RESV_MASK;
+		return (struct resv_map *)(get_vma_private_data(vma) &
+							~HPAGE_RESV_MASK);
 	return 0;
 }
 
-static void set_vma_resv_huge_pages(struct vm_area_struct *vma,
-							unsigned long reserve)
+static void set_vma_resv_map(struct vm_area_struct *vma, struct resv_map *map)
 {
-	VM_BUG_ON(!is_vm_hugetlb_page(vma));
-	VM_BUG_ON(vma->vm_flags & VM_SHARED);
-
-	set_vma_private_data(vma,
-		(get_vma_private_data(vma) & HPAGE_RESV_MASK) | reserve);
+	set_vma_private_data(vma, (get_vma_private_data(vma) &
+				HPAGE_RESV_MASK) | (unsigned long)map);
 }
 
 static void set_vma_resv_flags(struct vm_area_struct *vma, unsigned long flags)
@@ -251,11 +311,11 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 }
 
 /* Decrement the reserved pages in the hugepage pool by one */
-static void decrement_hugepage_resv_vma(struct hstate *h,
-			struct vm_area_struct *vma)
+static int decrement_hugepage_resv_vma(struct hstate *h,
+			struct vm_area_struct *vma, unsigned long address)
 {
 	if (vma->vm_flags & VM_NORESERVE)
-		return;
+		return 0;
 
 	if (vma->vm_flags & VM_SHARED) {
 		/* Shared mappings always use reserves */
@@ -266,14 +326,19 @@ static void decrement_hugepage_resv_vma(struct hstate *h,
 		 * private mappings.
 		 */
 		if (is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-			unsigned long flags, reserve;
+			unsigned long idx = vma_pagecache_offset(h,
+							vma, address);
+			struct resv_map *reservations = vma_resv_map(vma);
+
 			h->resv_huge_pages--;
-			flags = (unsigned long)vma->vm_private_data &
-							HPAGE_RESV_MASK;
-			reserve = (unsigned long)vma->vm_private_data - 1;
-			vma->vm_private_data = (void *)(reserve | flags);
+
+			/* Mark this page used in the map. */
+			if (region_chg(&reservations->regions, idx, idx + 1) < 0)
+				return -1;
+			region_add(&reservations->regions, idx, idx + 1);
 		}
 	}
+	return 0;
 }
 
 /* Reset counters to 0 and clear all HPAGE_RESV_* flags */
@@ -289,7 +354,7 @@ static int vma_has_private_reserves(struct vm_area_struct *vma)
 {
 	if (vma->vm_flags & VM_SHARED)
 		return 0;
-	if (!vma_resv_huge_pages(vma))
+	if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER))
 		return 0;
 	return 1;
 }
@@ -376,15 +441,16 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 		nid = zone_to_nid(zone);
 		if (cpuset_zone_allowed_softwall(zone, htlb_alloc_mask) &&
 		    !list_empty(&h->hugepage_freelists[nid])) {
+			if (!avoid_reserve &&
+			    decrement_hugepage_resv_vma(h, vma, address) < 0)
+				return NULL;
+
 			page = list_entry(h->hugepage_freelists[nid].next,
 					  struct page, lru);
 			list_del(&page->lru);
 			h->free_huge_pages--;
 			h->free_huge_pages_node[nid]--;
 
-			if (!avoid_reserve)
-				decrement_hugepage_resv_vma(h, vma);
-
 			break;
 		}
 	}
@@ -1456,10 +1522,39 @@ out:
 	return ret;
 }
 
+static void hugetlb_vm_op_open(struct vm_area_struct *vma)
+{
+ 	struct resv_map *reservations = vma_resv_map(vma);
+
+	/*
+	 * This new VMA will share its siblings reservation map.  The open
+	 * vm_op is only called for newly created VMAs which have been made
+	 * from another, still existing VMA.  As that VMA has a reference to
+	 * this reservation map the reservation map cannot disappear until
+	 * after this open completes.  It is therefore safe to take a new
+	 * reference here without additional locking.
+	 */
+	if (reservations)
+		kref_get(&reservations->refs);
+}
+
 static void hugetlb_vm_op_close(struct vm_area_struct *vma)
 {
 	struct hstate *h = hstate_vma(vma);
-	unsigned long reserve = vma_resv_huge_pages(vma);
+ 	struct resv_map *reservations = vma_resv_map(vma);
+	unsigned long reserve = 0;
+	unsigned long start;
+	unsigned long end;
+
+	if (reservations) {
+		start = vma_pagecache_offset(h, vma, vma->vm_start);
+		end = vma_pagecache_offset(h, vma, vma->vm_end);
+
+		reserve = (end - start) -
+			region_count(&reservations->regions, start, end);
+
+		kref_put(&reservations->refs, resv_map_release);
+	}
 
 	if (reserve)
 		hugetlb_acct_memory(h, -reserve);
@@ -1479,6 +1574,7 @@ static int hugetlb_vm_op_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 
 struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
+	.open = hugetlb_vm_op_open,
 	.close = hugetlb_vm_op_close,
 };
 
@@ -2037,8 +2133,13 @@ int hugetlb_reserve_pages(struct inode *inode,
 	if (!vma || vma->vm_flags & VM_SHARED)
 		chg = region_chg(&inode->i_mapping->private_list, from, to);
 	else {
+		struct resv_map *resv_map = resv_map_alloc();
+		if (!resv_map)
+			return -ENOMEM;
+
 		chg = to - from;
-		set_vma_resv_huge_pages(vma, chg);
+
+		set_vma_resv_map(vma, resv_map);
 		set_vma_resv_flags(vma, HPAGE_RESV_OWNER);
 	}
 
-- 
1.5.6.205.g7ca3a

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
