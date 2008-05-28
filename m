Date: Wed, 28 May 2008 17:00:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] Guarantee that COW faults for a process that called mmap(MAP_PRIVATE) on hugetlbfs will succeed
Message-ID: <20080528160024.GA19349@csn.ul.ie>
References: <20080527185028.16194.57978.sendpatchset@skynet.skynet.ie> <20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080527185128.16194.87380.sendpatchset@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: dean@arctic.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, dwg@au1.ibm.com, apw@shadowen.org, linux-mm@kvack.org, andi@firstfloor.org, kenchen@google.com, agl@us.ibm.com, abh@cray.com, hannes@saeurebad.de
List-ID: <linux-mm.kvack.org>

[PATCH 4/3] Fix prio tree lookup

I spoke too soon. This is a fix to patch 3/3.

If a child unmaps the start of the VMA, the start address is different and
that is perfectly legimite making the BUG_ON check bogus and should be removed.
While page cache lookups are in HPAGE_SIZE, the vma->vm_pgoff is in PAGE_SIZE
units, not HPAGE_SIZE. The offset calculation needs to be in PAGE_SIZE units
to find other VMAs that are mapping the same range of pages. This patch
fixes the offset calculation and adds an explanation comment as to why it
is different from a page cache lookup.

Credit goes to Johannes Weiner for spotting the bogus BUG_ON on IRC which
led to the discovery of the faulty offset calculation.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 mm/hugetlb.c |   12 ++++++++----
 1 file changed, 8 insertions(+), 4 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.26-rc2-mm1-0030-reliable_parent_faults/mm/hugetlb.c linux-2.6.26-rc2-mm1-1010_fix_priotree_lookup/mm/hugetlb.c
--- linux-2.6.26-rc2-mm1-0030-reliable_parent_faults/mm/hugetlb.c	2008-05-28 14:57:51.000000000 +0100
+++ linux-2.6.26-rc2-mm1-1010_fix_priotree_lookup/mm/hugetlb.c	2008-05-28 15:05:32.000000000 +0100
@@ -1035,14 +1035,18 @@ int unmap_ref_private(struct mm_struct *
 {
 	struct vm_area_struct *iter_vma;
 	struct address_space *mapping;
-	pgoff_t pgoff = ((address - vma->vm_start) >> HPAGE_SHIFT)
-		+ (vma->vm_pgoff >> (HPAGE_SHIFT - PAGE_SHIFT));
 	struct prio_tree_iter iter;
+	pgoff_t pgoff;
 
+	/*
+	 * vm_pgoff is in PAGE_SIZE units, hence the different calculation
+	 * from page cache lookup which is in HPAGE_SIZE units.
+	 */
+	pgoff = ((address - vma->vm_start) >> PAGE_SHIFT)
+		+ (vma->vm_pgoff >> PAGE_SHIFT);
 	mapping = (struct address_space *)page_private(page);
-	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		BUG_ON(vma->vm_start != iter_vma->vm_start);
 
+	vma_prio_tree_foreach(iter_vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		/* Do not unmap the current VMA */
 		if (iter_vma == vma)
 			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
