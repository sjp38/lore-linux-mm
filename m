Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id A8B666B0009
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 14:00:26 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id e95-v6so7343722otb.15
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 11:00:26 -0700 (PDT)
Received: from g9t5009.houston.hpe.com (g9t5009.houston.hpe.com. [15.241.48.73])
        by mx.google.com with ESMTPS id e24-v6si2790987otj.154.2018.04.30.11.00.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 11:00:25 -0700 (PDT)
From: Toshi Kani <toshi.kani@hpe.com>
Subject: [PATCH 2/3] x86/mm: add TLB purge to free pmd/pte page interfaces
Date: Mon, 30 Apr 2018 11:59:24 -0600
Message-Id: <20180430175925.2657-3-toshi.kani@hpe.com>
In-Reply-To: <20180430175925.2657-1-toshi.kani@hpe.com>
References: <20180430175925.2657-1-toshi.kani@hpe.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com, akpm@linux-foundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com
Cc: cpandya@codeaurora.org, linux-mm@kvack.org, x86@kernel.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hpe.com>, Joerg Roedel <joro@8bytes.org>, stable@vger.kernel.org

ioremap() calls pud_free_pmd_page() / pmd_free_pte_page() when it creates
a pud / pmd map.  The following preconditions are met at their entry.
 - All pte entries for a target pud/pmd address range have been cleared.
 - System-wide TLB purges have been peformed for a target pud/pmd address
   range.

The preconditions assure that there is no stale TLB entry for the range.
Speculation may not cache TLB entries since it requires all levels of page
entries, including ptes, to have P & A-bits set for an associated address.
However, speculation may cache pud/pmd entries (paging-structure caches)
when they have P-bit set.

Add a system-wide TLB purge (INVLPG) to a single page after clearing
pud/pmd entry's P-bit.

SDM 4.10.4.1, Operation that Invalidate TLBs and Paging-Structure Caches,
states that:
  INVLPG invalidates all paging-structure caches associated with the
  current PCID regardless of the liner addresses to which they correspond.

Fixes: 28ee90fe6048 ("x86/mm: implement free pmd/pte page interfaces")
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: <stable@vger.kernel.org>
---
 arch/x86/mm/pgtable.c |   32 ++++++++++++++++++++++++++------
 1 file changed, 26 insertions(+), 6 deletions(-)

diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 37e3cbac59b9..816fd41ee854 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -720,24 +720,40 @@ int pmd_clear_huge(pmd_t *pmd)
  * @pud: Pointer to a PUD.
  * @addr: Virtual address associated with pud.
  *
- * Context: The pud range has been unmaped and TLB purged.
+ * Context: The pud range has been unmapped and TLB purged.
  * Return: 1 if clearing the entry succeeded. 0 otherwise.
  */
 int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 {
-	pmd_t *pmd;
+	pmd_t *pmd, *pmd_sv;
+	pte_t *pte;
 	int i;
 
 	if (pud_none(*pud))
 		return 1;
 
 	pmd = (pmd_t *)pud_page_vaddr(*pud);
+	pmd_sv = (pmd_t *)__get_free_page(GFP_KERNEL);
 
-	for (i = 0; i < PTRS_PER_PMD; i++)
-		if (!pmd_free_pte_page(&pmd[i], addr + (i * PMD_SIZE)))
-			return 0;
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		pmd_sv[i] = pmd[i];
+		if (!pmd_none(pmd[i]))
+			pmd_clear(&pmd[i]);
+	}
 
 	pud_clear(pud);
+
+	/* INVLPG to clear all paging-structure caches */
+	flush_tlb_kernel_range(addr, addr + PAGE_SIZE-1);
+
+	for (i = 0; i < PTRS_PER_PMD; i++) {
+		if (!pmd_none(pmd_sv[i])) {
+			pte = (pte_t *)pmd_page_vaddr(pmd_sv[i]);
+			free_page((unsigned long)pte);
+		}
+	}
+
+	free_page((unsigned long)pmd_sv);
 	free_page((unsigned long)pmd);
 
 	return 1;
@@ -748,7 +764,7 @@ int pud_free_pmd_page(pud_t *pud, unsigned long addr)
  * @pmd: Pointer to a PMD.
  * @addr: Virtual address associated with pmd.
  *
- * Context: The pmd range has been unmaped and TLB purged.
+ * Context: The pmd range has been unmapped and TLB purged.
  * Return: 1 if clearing the entry succeeded. 0 otherwise.
  */
 int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
@@ -760,6 +776,10 @@ int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 
 	pte = (pte_t *)pmd_page_vaddr(*pmd);
 	pmd_clear(pmd);
+
+	/* INVLPG to clear all paging-structure caches */
+	flush_tlb_kernel_range(addr, addr + PAGE_SIZE-1);
+
 	free_page((unsigned long)pte);
 
 	return 1;
