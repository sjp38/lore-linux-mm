From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Mon, 25 Jun 2007 15:52:59 -0400
Message-Id: <20070625195259.21210.37267.sendpatchset@localhost>
In-Reply-To: <20070625195224.21210.89898.sendpatchset@localhost>
References: <20070625195224.21210.89898.sendpatchset@localhost>
Subject: [PATCH/RFC 5/11] Shared Policy:  Add hugepage shmem policy vm_ops
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, nacc@us.ibm.com, ak@suse.de, Lee Schermerhorn <lee.schermerhorn@hp.com>, clameter@sgi.com
List-ID: <linux-mm.kvack.org>

Shared Policy Hugetlb Shmem 5/11 Add hugepage shmem policy vm_ops

Against 2.6.22-rc4-mm2

This patch hooks up the hugepage shmem segment's
{set|get}_policy vm_ops so that shmem segments created with
the SHM_HUGETLB flag will install policies specified via the
mbind() syscall into the shared policy of the shared segment.
This capability is possible now that hugetlb pages are faulted
in on demand.

Huge page shmem segments are used by enterprise class data
base managers to achieve better performance.  Same DBMs are
NUMA aware on enterprise unix[tm] systems and will enable that
support on Linux when all of the pieces are in place.  This is 
one of those pieces.

The shared policy infrastructure maintains memory policies on
"base page size" ranges.  To ensure that policies installed on
a hugetlb shmem segment cover entire huge pages, this patch
enhances do_mbind() to enforce huge page alignment if the policy
range starts within a hugetlb segment.  The enforcement is down
in check_range() because we need the vma to determine whether or
not the range starts in a hugetlb segment.

	Note:  we could just silently round the start address
	down to a hugepage alignment.  This would be safe and
	convenient for the application programmer, but 
	inconsistent with the treatement of base page ranges
	which MUST be page aligned.

This patch depends on the numa_maps fixes and related shared
policy infrastructure clean up to prevent hangs when displaying
[via cat] the numa_maps of a task that has attached a huge page
shmem segment.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 mm/hugetlb.c   |    4 ++++
 mm/mempolicy.c |   11 +++++++++++
 2 files changed, 15 insertions(+)

Index: Linux/mm/hugetlb.c
===================================================================
--- Linux.orig/mm/hugetlb.c	2007-06-22 14:33:03.000000000 -0400
+++ Linux/mm/hugetlb.c	2007-06-22 14:34:16.000000000 -0400
@@ -317,6 +317,10 @@ static struct page *hugetlb_vm_op_fault(
 
 struct vm_operations_struct hugetlb_vm_ops = {
 	.fault = hugetlb_vm_op_fault,
+#ifdef CONFIG_NUMA
+	.set_policy	= shmem_set_policy,
+	.get_policy	= shmem_get_policy,
+#endif
 };
 
 static pte_t make_huge_pte(struct vm_area_struct *vma, struct page *page,
Index: Linux/mm/mempolicy.c
===================================================================
--- Linux.orig/mm/mempolicy.c	2007-06-22 14:33:03.000000000 -0400
+++ Linux/mm/mempolicy.c	2007-06-22 16:35:07.000000000 -0400
@@ -344,6 +344,17 @@ check_range(struct mm_struct *mm, unsign
 	first = find_vma(mm, start);
 	if (!first)
 		return ERR_PTR(-EFAULT);
+
+	/*
+	 * need vma for hugetlb check
+	 */
+	if (is_vm_hugetlb_page(first)) {
+		if (start & ~HPAGE_MASK)
+			return ERR_PTR(-EINVAL);
+		if (end < first->vm_end)
+			end = (end + HPAGE_MASK) & HPAGE_MASK;
+	}
+
 	prev = NULL;
 	for (vma = first; vma && vma->vm_start < end; vma = vma->vm_next) {
 		if (!(flags & MPOL_MF_DISCONTIG_OK)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
