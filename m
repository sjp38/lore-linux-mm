Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 67BB56B0031
	for <linux-mm@kvack.org>; Wed, 20 Nov 2013 08:37:11 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so7394142pde.7
        for <linux-mm@kvack.org>; Wed, 20 Nov 2013 05:37:11 -0800 (PST)
Received: from psmtp.com ([74.125.245.181])
        by mx.google.com with SMTP id ty3si9524856pbc.287.2013.11.20.05.37.09
        for <linux-mm@kvack.org>;
        Wed, 20 Nov 2013 05:37:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH] x86, mm: do not leak page->ptl for pmd page tables
Date: Wed, 20 Nov 2013 15:36:58 +0200
Message-Id: <1384954618-17783-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Wagin <avagin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

There are two code paths how page with pmd page table can be freed:
pmd_free() and pmd_free_tlb().

I've missed the second one and didn't add page table destructor call
there. It leads to leak of page->ptl for pmd page tables, if dynamically
allocated page->ptl is in use.

The patch adds the missed destructor and modifies documentation
accordingly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reported-and-Tested-by: Andrey Vagin <avagin@openvz.org>
---
 Documentation/vm/split_page_table_lock | 6 +++---
 arch/x86/mm/pgtable.c                  | 4 +++-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/split_page_table_lock b/Documentation/vm/split_page_table_lock
index 7521d367f21d..6dea4fd5c961 100644
--- a/Documentation/vm/split_page_table_lock
+++ b/Documentation/vm/split_page_table_lock
@@ -63,9 +63,9 @@ levels.
 PMD split lock enabling requires pgtable_pmd_page_ctor() call on PMD table
 allocation and pgtable_pmd_page_dtor() on freeing.
 
-Allocation usually happens in pmd_alloc_one(), freeing in pmd_free(), but
-make sure you cover all PMD table allocation / freeing paths: i.e X86_PAE
-preallocate few PMDs on pgd_alloc().
+Allocation usually happens in pmd_alloc_one(), freeing in pmd_free() and
+pmd_free_tlb(), but make sure you cover all PMD table allocation / freeing
+paths: i.e X86_PAE preallocate few PMDs on pgd_alloc().
 
 With everything in place you can set CONFIG_ARCH_ENABLE_SPLIT_PMD_PTLOCK.
 
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index a7cccb6d7fec..7be5809754cf 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -61,6 +61,7 @@ void ___pte_free_tlb(struct mmu_gather *tlb, struct page *pte)
 #if PAGETABLE_LEVELS > 2
 void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 {
+	struct page *page = virt_to_page(pmd);
 	paravirt_release_pmd(__pa(pmd) >> PAGE_SHIFT);
 	/*
 	 * NOTE! For PAE, any changes to the top page-directory-pointer-table
@@ -69,7 +70,8 @@ void ___pmd_free_tlb(struct mmu_gather *tlb, pmd_t *pmd)
 #ifdef CONFIG_X86_PAE
 	tlb->need_flush_all = 1;
 #endif
-	tlb_remove_page(tlb, virt_to_page(pmd));
+	pgtable_pmd_page_dtor(page);
+	tlb_remove_page(tlb, page);
 }
 
 #if PAGETABLE_LEVELS > 3
-- 
1.8.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
