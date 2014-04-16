Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f170.google.com (mail-we0-f170.google.com [74.125.82.170])
	by kanga.kvack.org (Postfix) with ESMTP id D7B6A6B0078
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 07:46:54 -0400 (EDT)
Received: by mail-we0-f170.google.com with SMTP id w61so10855546wes.1
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:54 -0700 (PDT)
Received: from mail-wg0-f48.google.com (mail-wg0-f48.google.com [74.125.82.48])
        by mx.google.com with ESMTPS id ho3si7368161wjb.208.2014.04.16.04.46.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 16 Apr 2014 04:46:53 -0700 (PDT)
Received: by mail-wg0-f48.google.com with SMTP id l18so10904681wgh.19
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 04:46:53 -0700 (PDT)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH V2 2/5] arm: mm: Adjust the parameters for __sync_icache_dcache
Date: Wed, 16 Apr 2014 12:46:40 +0100
Message-Id: <1397648803-15961-3-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
References: <1397648803-15961-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@arm.linux.org.uk, akpm@linux-foundation.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, robherring2@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, gerald.schaefer@de.ibm.com, Steve Capper <steve.capper@linaro.org>

Rather than take a pte_t as an input, break this down to the pfn
and whether or not the memory is executable.

This allows us to use this function for ptes and pmds.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/include/asm/pgtable.h | 6 +++---
 arch/arm/mm/flush.c            | 9 ++++-----
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 5478e5d..3a9c238 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -228,11 +228,11 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 	(pte_valid(pte) && (pte_val(pte) & L_PTE_USER) && pte_young(pte))
 
 #if __LINUX_ARM_ARCH__ < 6
-static inline void __sync_icache_dcache(pte_t pteval)
+static inline void __sync_icache_dcache(unsigned long pfn, int exec);
 {
 }
 #else
-extern void __sync_icache_dcache(pte_t pteval);
+extern void __sync_icache_dcache(unsigned long pfn, int exec);
 #endif
 
 static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
@@ -241,7 +241,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 	unsigned long ext = 0;
 
 	if (addr < TASK_SIZE && pte_valid_user(pteval)) {
-		__sync_icache_dcache(pteval);
+		__sync_icache_dcache(pte_pfn(pteval), pte_exec(pteval));
 		ext |= PTE_EXT_NG;
 	}
 
diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 3387e60..df0d5ca 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -232,16 +232,15 @@ static void __flush_dcache_aliases(struct address_space *mapping, struct page *p
 }
 
 #if __LINUX_ARM_ARCH__ >= 6
-void __sync_icache_dcache(pte_t pteval)
+void __sync_icache_dcache(unsigned long pfn, int exec)
 {
-	unsigned long pfn;
 	struct page *page;
 	struct address_space *mapping;
 
-	if (cache_is_vipt_nonaliasing() && !pte_exec(pteval))
+	if (cache_is_vipt_nonaliasing() && !exec)
 		/* only flush non-aliasing VIPT caches for exec mappings */
 		return;
-	pfn = pte_pfn(pteval);
+
 	if (!pfn_valid(pfn))
 		return;
 
@@ -254,7 +253,7 @@ void __sync_icache_dcache(pte_t pteval)
 	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
 		__flush_dcache_page(mapping, page);
 
-	if (pte_exec(pteval))
+	if (exec)
 		__flush_icache_all();
 }
 #endif
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
