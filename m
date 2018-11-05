Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id AB31D6B0278
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 16:23:30 -0500 (EST)
Received: by mail-io1-f69.google.com with SMTP id q22-v6so12018782iog.9
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 13:23:30 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id x187-v6si25526654itd.52.2018.11.05.13.23.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 13:23:29 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] hugetlbfs: fix kernel BUG at fs/hugetlbfs/inode.c:444!
Date: Mon,  5 Nov 2018 13:23:15 -0800
Message-Id: <20181105212315.14125-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Michal Hocko <mhocko@kernel.org>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrea Arcangeli <aarcange@redhat.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Prakash Sangappa <prakash.sangappa@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

This bug has been experienced several times by Oracle DB team.
The BUG is in the routine remove_inode_hugepages() as follows:
	/*
	 * If page is mapped, it was faulted in after being
	 * unmapped in caller.  Unmap (again) now after taking
	 * the fault mutex.  The mutex will prevent faults
	 * until we finish removing the page.
	 *
	 * This race can only happen in the hole punch case.
	 * Getting here in a truncate operation is a bug.
	 */
	if (unlikely(page_mapped(page))) {
		BUG_ON(truncate_op);

In this case, the elevated map count is not the result of a race.
Rather it was incorrectly incremented as the result of a bug in the
huge pmd sharing code.  Consider the following:
- Process A maps a hugetlbfs file of sufficient size and alignment
  (PUD_SIZE) that a pmd page could be shared.
- Process B maps the same hugetlbfs file with the same size and alignment
  such that a pmd page is shared.
- Process B then calls mprotect() to change protections for the mapping
  with the shared pmd.  As a result, the pmd is 'unshared'.
- Process B then calls mprotect() again to chage protections for the
  mapping back to their original value.  pmd remains unshared.
- Process B then forks and process C is created.  During the fork process,
  we do dup_mm -> dup_mmap -> copy_page_range to copy page tables.  Copying
  page tables for hugetlb mappings is done in the routine
  copy_hugetlb_page_range.

In copy_hugetlb_page_range(), the destination pte is obtained by:
	dst_pte = huge_pte_alloc(dst, addr, sz);
If pmd sharing is possible, the returned pointer will be to a pte in
an existing page table.  In the situation above, process C could share
with either process A or process B.  Since process A is first in the
list, the returned pte is a pointer to a pte in process A's page table.

However, the following check for pmd sharing is in copy_hugetlb_page_range.
	/* If the pagetables are shared don't copy or take references */
	if (dst_pte == src_pte)
		continue;

Since process C is sharing with process A instead of process B, the above
test fails.  The code in copy_hugetlb_page_range which follows assumes
dst_pte points to a huge_pte_none pte.  It copies the pte entry from
src_pte to dst_pte and increments this map count of the associated page.
This is how we end up with an elevated map count.

To solve, check the dst_pte entry for huge_pte_none.  If !none, this
implies PMD sharing so do not copy.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 mm/hugetlb.c | 23 +++++++++++++++++++----
 1 file changed, 19 insertions(+), 4 deletions(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5c390f5a5207..0b391ef6448c 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3233,7 +3233,7 @@ static int is_hugetlb_entry_hwpoisoned(pte_t pte)
 int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			    struct vm_area_struct *vma)
 {
-	pte_t *src_pte, *dst_pte, entry;
+	pte_t *src_pte, *dst_pte, entry, dst_entry;
 	struct page *ptepage;
 	unsigned long addr;
 	int cow;
@@ -3261,15 +3261,30 @@ int copy_hugetlb_page_range(struct mm_struct *dst, struct mm_struct *src,
 			break;
 		}
 
-		/* If the pagetables are shared don't copy or take references */
-		if (dst_pte == src_pte)
+		/*
+		 * If the pagetables are shared don't copy or take references.
+		 * dst_pte == src_pte is the common case of src/dest sharing.
+		 *
+		 * However, src could have 'unshared' and dst shares with
+		 * another vma.  If dst_pte !none, this implies sharing.
+		 * Check here before taking page table lock, and once again
+		 * after taking the lock below.
+		 */
+		dst_entry = huge_ptep_get(dst_pte);
+		if ((dst_pte == src_pte) || !huge_pte_none(dst_entry))
 			continue;
 
 		dst_ptl = huge_pte_lock(h, dst, dst_pte);
 		src_ptl = huge_pte_lockptr(h, src, src_pte);
 		spin_lock_nested(src_ptl, SINGLE_DEPTH_NESTING);
 		entry = huge_ptep_get(src_pte);
-		if (huge_pte_none(entry)) { /* skip none entry */
+		dst_entry = huge_ptep_get(dst_pte);
+		if (huge_pte_none(entry) || !huge_pte_none(dst_entry)) {
+			/*
+			 * Skip if src entry none.  Also, skip in the
+			 * unlikely case dst entry !none as this implies
+			 * sharing with another vma.
+			 */
 			;
 		} else if (unlikely(is_hugetlb_entry_migration(entry) ||
 				    is_hugetlb_entry_hwpoisoned(entry))) {
-- 
2.17.2
