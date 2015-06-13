Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by kanga.kvack.org (Postfix) with ESMTP id DB739280003
	for <linux-mm@kvack.org>; Sat, 13 Jun 2015 05:49:52 -0400 (EDT)
Received: by wibut5 with SMTP id ut5so35644117wib.1
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:52 -0700 (PDT)
Received: from mail-wg0-x22f.google.com (mail-wg0-x22f.google.com. [2a00:1450:400c:c00::22f])
        by mx.google.com with ESMTPS id hf9si7887062wib.39.2015.06.13.02.49.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 13 Jun 2015 02:49:51 -0700 (PDT)
Received: by wgzl5 with SMTP id l5so12726483wgz.3
        for <linux-mm@kvack.org>; Sat, 13 Jun 2015 02:49:51 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 11/12] x86/mm: Remove pgd_list leftovers
Date: Sat, 13 Jun 2015 11:49:14 +0200
Message-Id: <1434188955-31397-12-git-send-email-mingo@kernel.org>
In-Reply-To: <1434188955-31397-1-git-send-email-mingo@kernel.org>
References: <1434188955-31397-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Waiman Long <Waiman.Long@hp.com>

Nothing uses the pgd_list anymore - remove the list itself and its helpers.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Waiman Long <Waiman.Long@hp.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/include/asm/pgtable.h |  3 ---
 arch/x86/mm/fault.c            |  1 -
 arch/x86/mm/pgtable.c          | 26 --------------------------
 3 files changed, 30 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index fe57e7a98839..7e93438d8b53 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -29,9 +29,6 @@ extern unsigned long empty_zero_page[PAGE_SIZE / sizeof(unsigned long)]
 #define ZERO_PAGE(vaddr) (virt_to_page(empty_zero_page))
 
 extern spinlock_t pgd_lock;
-extern struct list_head pgd_list;
-
-extern struct mm_struct *pgd_page_get_mm(struct page *page);
 
 #ifdef CONFIG_PARAVIRT
 #include <asm/paravirt.h>
diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 366b8232f4b3..14b39c3511fd 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -186,7 +186,6 @@ force_sig_info_fault(int si_signo, int si_code, unsigned long address,
 }
 
 DEFINE_SPINLOCK(pgd_lock);
-LIST_HEAD(pgd_list);
 
 #ifdef CONFIG_X86_32
 static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 0ab56d13f24d..7cca42c01677 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -84,35 +84,9 @@ void ___pud_free_tlb(struct mmu_gather *tlb, pud_t *pud)
 #endif	/* CONFIG_PGTABLE_LEVELS > 3 */
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
-static inline void pgd_list_add(pgd_t *pgd)
-{
-	struct page *page = virt_to_page(pgd);
-
-	list_add(&page->lru, &pgd_list);
-}
-
-static inline void pgd_list_del(pgd_t *pgd)
-{
-	struct page *page = virt_to_page(pgd);
-
-	list_del(&page->lru);
-}
-
 #define UNSHARED_PTRS_PER_PGD				\
 	(SHARED_KERNEL_PMD ? KERNEL_PGD_BOUNDARY : PTRS_PER_PGD)
 
-
-static void pgd_set_mm(pgd_t *pgd, struct mm_struct *mm)
-{
-	BUILD_BUG_ON(sizeof(virt_to_page(pgd)->index) < sizeof(mm));
-	virt_to_page(pgd)->index = (pgoff_t)mm;
-}
-
-struct mm_struct *pgd_page_get_mm(struct page *page)
-{
-	return (struct mm_struct *)page->index;
-}
-
 static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
 {
 	/* If the pgd points to a shared pagetable level (either the
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
