Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id B37236B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 07:08:49 -0400 (EDT)
Received: by mail-pa0-f53.google.com with SMTP id kq14so8810581pab.26
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:08:49 -0700 (PDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so8653846pbb.33
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 04:08:46 -0700 (PDT)
Date: Tue, 15 Oct 2013 04:08:28 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: mm: fix BUG in __split_huge_page_pmd
Message-ID: <alpine.LNX.2.00.1310150358170.11905@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Occasionally we hit the BUG_ON(pmd_trans_huge(*pmd)) at the end of
__split_huge_page_pmd(): seen when doing madvise(,,MADV_DONTNEED).

It's invalid: we don't always have down_write of mmap_sem there:
a racing do_huge_pmd_wp_page() might have copied-on-write to another
huge page before our split_huge_page() got the anon_vma lock.

Forget the BUG_ON, just go back and try again if this happens.
    
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org
---

 mm/huge_memory.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

--- 3.12-rc5/mm/huge_memory.c	2013-09-16 17:37:56.811072270 -0700
+++ linux/mm/huge_memory.c	2013-10-15 03:40:02.044138488 -0700
@@ -2697,6 +2697,7 @@ void __split_huge_page_pmd(struct vm_are
 
 	mmun_start = haddr;
 	mmun_end   = haddr + HPAGE_PMD_SIZE;
+again:
 	mmu_notifier_invalidate_range_start(mm, mmun_start, mmun_end);
 	spin_lock(&mm->page_table_lock);
 	if (unlikely(!pmd_trans_huge(*pmd))) {
@@ -2719,7 +2720,14 @@ void __split_huge_page_pmd(struct vm_are
 	split_huge_page(page);
 
 	put_page(page);
-	BUG_ON(pmd_trans_huge(*pmd));
+
+	/*
+	 * We don't always have down_write of mmap_sem here: a racing
+	 * do_huge_pmd_wp_page() might have copied-on-write to another
+	 * huge page before our split_huge_page() got the anon_vma lock.
+	 */
+	if (unlikely(pmd_trans_huge(*pmd)))
+		goto again;
 }
 
 void split_huge_page_pmd_mm(struct mm_struct *mm, unsigned long address,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
