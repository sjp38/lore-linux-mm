Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id DEF1E6B0022
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 13:03:54 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id n67-v6so176106otn.0
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 10:03:54 -0700 (PDT)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id e70si165471oib.378.2018.03.13.10.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 10:03:53 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 2/2] x86/mm: remove pointless checks in vmalloc_fault
Date: Tue, 13 Mar 2018 11:03:47 -0600
Message-Id: <20180313170347.3829-3-toshi.kani@hpe.com>
In-Reply-To: <20180313170347.3829-1-toshi.kani@hpe.com>
References: <20180313170347.3829-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: bp@alien8.de, luto@kernel.org, gratian.crisan@ni.com, x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>

vmalloc_fault() sets user's pgd or p4d from the kernel page table.
Once it's set, all tables underneath are identical. There is no point
of following the same page table with two separate pointers and makes
sure they see the same with BUG().

Remove the pointless checks in vmalloc_fault(). Also rename the kernel
pgd/p4d pointers to pgd_k/p4d_k so that their names are consistent in
the file.

Suggested-by: Andy Lutomirski <luto@kernel.org>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Gratian Crisan <gratian.crisan@ni.com>
---
 arch/x86/mm/fault.c |   56 +++++++++++++++------------------------------------
 1 file changed, 17 insertions(+), 39 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 25a30b5d6582..e7bc79853538 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -417,11 +417,11 @@ void vmalloc_sync_all(void)
  */
 static noinline int vmalloc_fault(unsigned long address)
 {
-	pgd_t *pgd, *pgd_ref;
-	p4d_t *p4d, *p4d_ref;
-	pud_t *pud, *pud_ref;
-	pmd_t *pmd, *pmd_ref;
-	pte_t *pte, *pte_ref;
+	pgd_t *pgd, *pgd_k;
+	p4d_t *p4d, *p4d_k;
+	pud_t *pud;
+	pmd_t *pmd;
+	pte_t *pte;
 
 	/* Make sure we are in vmalloc area: */
 	if (!(address >= VMALLOC_START && address < VMALLOC_END))
@@ -435,73 +435,51 @@ static noinline int vmalloc_fault(unsigned long address)
 	 * case just flush:
 	 */
 	pgd = (pgd_t *)__va(read_cr3_pa()) + pgd_index(address);
-	pgd_ref = pgd_offset_k(address);
-	if (pgd_none(*pgd_ref))
+	pgd_k = pgd_offset_k(address);
+	if (pgd_none(*pgd_k))
 		return -1;
 
 	if (CONFIG_PGTABLE_LEVELS > 4) {
 		if (pgd_none(*pgd)) {
-			set_pgd(pgd, *pgd_ref);
+			set_pgd(pgd, *pgd_k);
 			arch_flush_lazy_mmu_mode();
 		} else {
-			BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
+			BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_k));
 		}
 	}
 
 	/* With 4-level paging, copying happens on the p4d level. */
 	p4d = p4d_offset(pgd, address);
-	p4d_ref = p4d_offset(pgd_ref, address);
-	if (p4d_none(*p4d_ref))
+	p4d_k = p4d_offset(pgd_k, address);
+	if (p4d_none(*p4d_k))
 		return -1;
 
 	if (p4d_none(*p4d) && CONFIG_PGTABLE_LEVELS == 4) {
-		set_p4d(p4d, *p4d_ref);
+		set_p4d(p4d, *p4d_k);
 		arch_flush_lazy_mmu_mode();
 	} else {
-		BUG_ON(p4d_pfn(*p4d) != p4d_pfn(*p4d_ref));
+		BUG_ON(p4d_pfn(*p4d) != p4d_pfn(*p4d_k));
 	}
 
-	/*
-	 * Below here mismatches are bugs because these lower tables
-	 * are shared:
-	 */
 	BUILD_BUG_ON(CONFIG_PGTABLE_LEVELS < 4);
 
 	pud = pud_offset(p4d, address);
-	pud_ref = pud_offset(p4d_ref, address);
-	if (pud_none(*pud_ref))
+	if (pud_none(*pud))
 		return -1;
 
-	if (pud_none(*pud) || pud_pfn(*pud) != pud_pfn(*pud_ref))
-		BUG();
-
 	if (pud_large(*pud))
 		return 0;
 
 	pmd = pmd_offset(pud, address);
-	pmd_ref = pmd_offset(pud_ref, address);
-	if (pmd_none(*pmd_ref))
+	if (pmd_none(*pmd))
 		return -1;
 
-	if (pmd_none(*pmd) || pmd_pfn(*pmd) != pmd_pfn(*pmd_ref))
-		BUG();
-
 	if (pmd_large(*pmd))
 		return 0;
 
-	pte_ref = pte_offset_kernel(pmd_ref, address);
-	if (!pte_present(*pte_ref))
-		return -1;
-
 	pte = pte_offset_kernel(pmd, address);
-
-	/*
-	 * Don't use pte_page here, because the mappings can point
-	 * outside mem_map, and the NUMA hash lookup cannot handle
-	 * that:
-	 */
-	if (!pte_present(*pte) || pte_pfn(*pte) != pte_pfn(*pte_ref))
-		BUG();
+	if (!pte_present(*pte))
+		return -1;
 
 	return 0;
 }
