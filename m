From: Andy Whitcroft <apw@shadowen.org>
Subject: [PATCH 3/3] hugetlb-allow-huge-page-mappings-to-be-created-without-reservations
References: <exportbomb.1211929624@pinky>
Date: Wed, 28 May 2008 00:10:06 +0100
Message-Id: <1211929806.0@pinky>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, agl@us.ibm.com, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

By default all shared mappings and most private mappings now
have reservations associated with them.  This improves semantics by
providing allocation guarentees to the mapper.  However a small number of
applications may attempt to make very large sparse mappings, with these
strict reservations the system will never be able to honour the mapping.

This patch set brings MAP_NORESERVE support to hugetlb files.
This allows new mappings to be made to hugetlbfs files without an
associated reservation, for both shared and private mappings.  This allows
applications which want to create very sparse mappings to opt-out of the
reservation system.  Obviously as there is no reservation they are liable
to fault at runtime if the huge page pool becomes exhausted; buyer beware.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mm/hugetlb.c |   60 +++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 files changed, 55 insertions(+), 5 deletions(-)
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 90a7f5f..118dc54 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -88,6 +88,9 @@ static int is_vma_resv_set(struct vm_area_struct *vma, unsigned long flag)
 /* Decrement the reserved pages in the hugepage pool by one */
 static void decrement_hugepage_resv_vma(struct vm_area_struct *vma)
 {
+	if (vma->vm_flags & VM_NORESERVE)
+		return;
+
 	if (vma->vm_flags & VM_SHARED) {
 		/* Shared mappings always use reserves */
 		resv_huge_pages--;
@@ -682,25 +685,67 @@ static long region_truncate(struct list_head *head, long end)
 	return chg;
 }
 
+/*
+ * Determine if the huge page at addr within the vma has an associated
+ * reservation.  Where it does not we will need to logically increase
+ * reservation and actually increase quota before an allocation can occur.
+ * Where any new reservation would be required the reservation change is
+ * prepared, but not committed.  Once the page has been quota'd allocated
+ * an instantiated the change should be committed via vma_commit_reservation.
+ * No action is required on failure.
+ */
+static int vma_needs_reservation(struct vm_area_struct *vma, unsigned long addr)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct inode *inode = mapping->host;
+
+	if (vma->vm_flags & VM_SHARED) {
+		unsigned long idx = ((addr - vma->vm_start) >> HPAGE_SHIFT) +
+				(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+		return region_chg(&inode->i_mapping->private_list,
+							idx, idx + 1);
+
+	} else {
+		if (!is_vma_resv_set(vma, HPAGE_RESV_OWNER))
+			return 1;
+	}
+
+	return 0;
+}
+static void vma_commit_reservation(struct vm_area_struct *vma,
+							unsigned long addr)
+{
+	struct address_space *mapping = vma->vm_file->f_mapping;
+	struct inode *inode = mapping->host;
+
+	if (vma->vm_flags & VM_SHARED) {
+		unsigned long idx = ((addr - vma->vm_start) >> HPAGE_SHIFT) +
+				(vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
+		region_add(&inode->i_mapping->private_list, idx, idx + 1);
+	}
+}
+
 static struct page *alloc_huge_page(struct vm_area_struct *vma,
 				    unsigned long addr, int avoid_reserve)
 {
 	struct page *page;
 	struct address_space *mapping = vma->vm_file->f_mapping;
 	struct inode *inode = mapping->host;
-	unsigned int chg = 0;
+	unsigned int chg;
 
 	/*
 	 * Processes that did not create the mapping will have no reserves and
 	 * will not have accounted against quota. Check that the quota can be
 	 * made before satisfying the allocation
+	 * MAP_NORESERVE mappings may also need pages and quota allocated
+	 * if no reserve mapping overlaps.
 	 */
-	if (!(vma->vm_flags & VM_SHARED) &&
-			!is_vma_resv_set(vma, HPAGE_RESV_OWNER)) {
-		chg = 1;
+	chg = vma_needs_reservation(vma, addr);
+	if (chg < 0)
+		return ERR_PTR(chg);
+	if (chg)
 		if (hugetlb_get_quota(inode->i_mapping, chg))
 			return ERR_PTR(-ENOSPC);
-	}
 
 	spin_lock(&hugetlb_lock);
 	page = dequeue_huge_page_vma(vma, addr, avoid_reserve);
@@ -717,6 +762,8 @@ static struct page *alloc_huge_page(struct vm_area_struct *vma,
 	set_page_refcounted(page);
 	set_page_private(page, (unsigned long) mapping);
 
+	vma_commit_reservation(vma, addr);
+
 	return page;
 }
 
@@ -1519,6 +1566,9 @@ int hugetlb_reserve_pages(struct inode *inode,
 {
 	long ret, chg;
 
+	if (vma && vma->vm_flags & VM_NORESERVE)
+		return 0;
+
 	/*
 	 * Shared mappings base their reservation on the number of pages that
 	 * are already allocated on behalf of the file. Private mappings need

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
