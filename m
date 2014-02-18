Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by kanga.kvack.org (Postfix) with ESMTP id E735D6B0036
	for <linux-mm@kvack.org>; Tue, 18 Feb 2014 10:27:35 -0500 (EST)
Received: by mail-wi0-f180.google.com with SMTP id hm4so3601541wib.13
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:27:35 -0800 (PST)
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
        by mx.google.com with ESMTPS id vg1si14974509wjc.43.2014.02.18.07.27.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Feb 2014 07:27:34 -0800 (PST)
Received: by mail-wi0-f175.google.com with SMTP id hm4so3619855wib.2
        for <linux-mm@kvack.org>; Tue, 18 Feb 2014 07:27:33 -0800 (PST)
From: Steve Capper <steve.capper@linaro.org>
Subject: [PATCH 2/5] arm: mm: Adjust the parameters for __sync_icache_dcache
Date: Tue, 18 Feb 2014 15:27:12 +0000
Message-Id: <1392737235-27286-3-git-send-email-steve.capper@linaro.org>
In-Reply-To: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
References: <1392737235-27286-1-git-send-email-steve.capper@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk, linux-mm@kvack.org
Cc: will.deacon@arm.com, catalin.marinas@arm.com, arnd@arndb.de, dsaxena@linaro.org, robherring2@gmail.com, Steve Capper <steve.capper@linaro.org>

Rather than take a pte_t as an input, break this down to the pfn
and whether or not the memory is executable.

This allows us to use this function for ptes and pmds.

Signed-off-by: Steve Capper <steve.capper@linaro.org>
---
 arch/arm/include/asm/pgtable.h | 6 +++---
 arch/arm/mm/flush.c            | 9 ++++-----
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/arch/arm/include/asm/pgtable.h b/arch/arm/include/asm/pgtable.h
index 7d59b52..9b4ad36 100644
--- a/arch/arm/include/asm/pgtable.h
+++ b/arch/arm/include/asm/pgtable.h
@@ -225,11 +225,11 @@ static inline pte_t *pmd_page_vaddr(pmd_t pmd)
 #define pte_present_user(pte)  (pte_present(pte) && (pte_val(pte) & L_PTE_USER))
 
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
@@ -238,7 +238,7 @@ static inline void set_pte_at(struct mm_struct *mm, unsigned long addr,
 	unsigned long ext = 0;
 
 	if (addr < TASK_SIZE && pte_present_user(pteval)) {
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
