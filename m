Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f171.google.com (mail-wi0-f171.google.com [209.85.212.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0FD6B025D
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:24 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so145568178wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:24 -0700 (PDT)
Received: from mail-wi0-x22e.google.com (mail-wi0-x22e.google.com. [2a00:1450:400c:c05::22e])
        by mx.google.com with ESMTPS id gb8si2311wjb.121.2015.09.21.23.24.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:22 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so145567149wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:21 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 10/11] x86/mm: Remove pgd_list leftovers
Date: Tue, 22 Sep 2015 08:23:40 +0200
Message-Id: <1442903021-3893-11-git-send-email-mingo@kernel.org>
In-Reply-To: <1442903021-3893-1-git-send-email-mingo@kernel.org>
References: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

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
index 867da5bbb4a3..8338c8175409 100644
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
index 9322d5ad3811..546fbca9621d 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -189,7 +189,6 @@ force_sig_info_fault(int si_signo, int si_code, unsigned long address,
 }
 
 DEFINE_SPINLOCK(pgd_lock);
-LIST_HEAD(pgd_list);
 
 #ifdef CONFIG_X86_32
 static inline pmd_t *vmalloc_sync_one(pgd_t *pgd, unsigned long address)
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 8a42d54f44ba..cb5b8cbcf96b 100644
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
