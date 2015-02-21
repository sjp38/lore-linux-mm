Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id B3CBB6B006E
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 23:13:45 -0500 (EST)
Received: by pdev10 with SMTP id v10so12002829pde.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:13:45 -0800 (PST)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id mj6si2614735pab.133.2015.02.20.20.13.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 20:13:45 -0800 (PST)
Received: by pdbfl12 with SMTP id fl12so12086480pdb.2
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 20:13:44 -0800 (PST)
Date: Fri, 20 Feb 2015 20:13:42 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 14/24] huge tmpfs: extend vma_adjust_trans_huge to shmem
 pmd
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502202012270.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Factor out one small part of the shmem pmd handling: the inline function
vma_adjust_trans_huge() (called when vmas are split or merged) contains
a preliminary !anon_vma || vm_ops check to avoid the overhead of
__vma_adjust_trans_huge() on areas which could not possibly contain an
anonymous THP pmd.  But with huge tmpfs, we shall need it to be called
even in those excluded cases.

Before the split pmd ptlocks, there was a nice alternative optimization
to make: avoid the overhead of __vma_adjust_trans_huge() on mms which
could not possibly contain a huge pmd - those with NULL pmd_huge_pte
(using a huge pmd demands the deposit of a spare page table, typically
stored in a list at pmd_huge_pte, withdrawn for use when splitting the
pmd; and huge tmpfs will follow that protocol too).

Still use that optimization when !USE_SPLIT_PMD_PTLOCKS, when
mm->pmd_huge_pte is updated under mm->page_table_lock (but beware:
unlike other arches, powerpc made no use of pmd_huge_pte before, so
this patch hacks it to update pmd_huge_pte as a count).  In common
configs, no equivalent optimization on x86 now: if that's a visible
problem, we can add an atomic count or flag to mm for the purpose.

And looking into the overhead of __vma_adjust_trans_huge(): it is
silly for split_huge_page_pmd_mm() to be calling find_vma() followed
by split_huge_page_pmd(), when it can check the pmd directly first,
and usually avoid the find_vma() call.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 arch/powerpc/mm/pgtable_64.c |    7 ++++++-
 include/linux/huge_mm.h      |    5 ++++-
 mm/huge_memory.c             |    7 ++-----
 3 files changed, 12 insertions(+), 7 deletions(-)

--- thpfs.orig/arch/powerpc/mm/pgtable_64.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/arch/powerpc/mm/pgtable_64.c	2015-02-20 19:34:32.363944978 -0800
@@ -675,9 +675,12 @@ void pgtable_trans_huge_deposit(struct m
 				pgtable_t pgtable)
 {
 	pgtable_t *pgtable_slot;
+
 	assert_spin_locked(&mm->page_table_lock);
+	mm->pmd_huge_pte++;
 	/*
-	 * we store the pgtable in the second half of PMD
+	 * we store the pgtable in the second half of PMD; but must also
+	 * set pmd_huge_pte for the optimization in vma_adjust_trans_huge().
 	 */
 	pgtable_slot = (pgtable_t *)pmdp + PTRS_PER_PMD;
 	*pgtable_slot = pgtable;
@@ -696,6 +699,8 @@ pgtable_t pgtable_trans_huge_withdraw(st
 	pgtable_t *pgtable_slot;
 
 	assert_spin_locked(&mm->page_table_lock);
+	mm->pmd_huge_pte--;
+
 	pgtable_slot = (pgtable_t *)pmdp + PTRS_PER_PMD;
 	pgtable = *pgtable_slot;
 	/*
--- thpfs.orig/include/linux/huge_mm.h	2014-12-07 14:21:05.000000000 -0800
+++ thpfs/include/linux/huge_mm.h	2015-02-20 19:34:32.363944978 -0800
@@ -143,8 +143,11 @@ static inline void vma_adjust_trans_huge
 					 unsigned long end,
 					 long adjust_next)
 {
-	if (!vma->anon_vma || vma->vm_ops)
+#if !USE_SPLIT_PMD_PTLOCKS
+	/* If no pgtable is deposited, there is no huge pmd to worry about */
+	if (!vma->vm_mm->pmd_huge_pte)
 		return;
+#endif
 	__vma_adjust_trans_huge(vma, start, end, adjust_next);
 }
 static inline int hpage_nr_pages(struct page *page)
--- thpfs.orig/mm/huge_memory.c	2015-02-20 19:33:51.492038431 -0800
+++ thpfs/mm/huge_memory.c	2015-02-20 19:34:32.367944969 -0800
@@ -2905,11 +2905,8 @@ again:
 void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,
 		pmd_t *pmd)
 {
-	struct vm_area_struct *vma;
-
-	vma = find_vma(mm, address);
-	BUG_ON(vma == NULL);
-	split_huge_page_pmd(vma, address, pmd);
+	if (unlikely(pmd_trans_huge(*pmd)))
+		__split_huge_page_pmd(find_vma(mm, address), address, pmd);
 }
 
 static void split_huge_page_address(struct mm_struct *mm,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
