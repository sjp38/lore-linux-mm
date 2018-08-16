Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 87E2B6B030E
	for <linux-mm@kvack.org>; Thu, 16 Aug 2018 14:43:19 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id t4-v6so3275994plo.0
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 11:43:19 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id i28-v6si50752pfi.105.2018.08.16.11.43.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Aug 2018 11:43:18 -0700 (PDT)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH 4.4 12/13] ioremap: Update pgtable free interfaces with addr
Date: Thu, 16 Aug 2018 20:41:59 +0200
Message-Id: <20180816171629.160523719@linuxfoundation.org>
In-Reply-To: <20180816171628.554317013@linuxfoundation.org>
References: <20180816171628.554317013@linuxfoundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, stable@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Toshi Kani <toshi.kani@hpe.com>, Thomas Gleixner <tglx@linutronix.de>, mhocko@suse.com, akpm@linux-foundation.org, hpa@zytor.com, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Will Deacon <will.deacon@arm.com>, Joerg Roedel <joro@8bytes.org>

4.4-stable review patch.  If anyone has any objections, please let me know.

------------------

From: Chintan Pandya <cpandya@codeaurora.org>

commit 785a19f9d1dd8a4ab2d0633be4656653bd3de1fc upstream.

The following kernel panic was observed on ARM64 platform due to a stale
TLB entry.

 1. ioremap with 4K size, a valid pte page table is set.
 2. iounmap it, its pte entry is set to 0.
 3. ioremap the same address with 2M size, update its pmd entry with
    a new value.
 4. CPU may hit an exception because the old pmd entry is still in TLB,
    which leads to a kernel panic.

Commit b6bdb7517c3d ("mm/vmalloc: add interfaces to free unmapped page
table") has addressed this panic by falling to pte mappings in the above
case on ARM64.

To support pmd mappings in all cases, TLB purge needs to be performed
in this case on ARM64.

Add a new arg, 'addr', to pud_free_pmd_page() and pmd_free_pte_page()
so that TLB purge can be added later in seprate patches.

[toshi.kani@hpe.com: merge changes, rewrite patch description]
Fixes: 28ee90fe6048 ("x86/mm: implement free pmd/pte page interfaces")
Signed-off-by: Chintan Pandya <cpandya@codeaurora.org>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
Cc: mhocko@suse.com
Cc: akpm@linux-foundation.org
Cc: hpa@zytor.com
Cc: linux-mm@kvack.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: Will Deacon <will.deacon@arm.com>
Cc: Joerg Roedel <joro@8bytes.org>
Cc: stable@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: <stable@vger.kernel.org>
Link: https://lkml.kernel.org/r/20180627141348.21777-3-toshi.kani@hpe.com
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 arch/arm64/mm/mmu.c           |    4 ++--
 arch/x86/mm/pgtable.c         |   12 +++++++-----
 include/asm-generic/pgtable.h |    8 ++++----
 lib/ioremap.c                 |    4 ++--
 4 files changed, 15 insertions(+), 13 deletions(-)

--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -699,12 +699,12 @@ void *__init fixmap_remap_fdt(phys_addr_
 }
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
-int pud_free_pmd_page(pud_t *pud)
+int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 {
 	return pud_none(*pud);
 }
 
-int pmd_free_pte_page(pmd_t *pmd)
+int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 {
 	return pmd_none(*pmd);
 }
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -680,11 +680,12 @@ int pmd_clear_huge(pmd_t *pmd)
 /**
  * pud_free_pmd_page - Clear pud entry and free pmd page.
  * @pud: Pointer to a PUD.
+ * @addr: Virtual address associated with pud.
  *
  * Context: The pud range has been unmaped and TLB purged.
  * Return: 1 if clearing the entry succeeded. 0 otherwise.
  */
-int pud_free_pmd_page(pud_t *pud)
+int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 {
 	pmd_t *pmd;
 	int i;
@@ -695,7 +696,7 @@ int pud_free_pmd_page(pud_t *pud)
 	pmd = (pmd_t *)pud_page_vaddr(*pud);
 
 	for (i = 0; i < PTRS_PER_PMD; i++)
-		if (!pmd_free_pte_page(&pmd[i]))
+		if (!pmd_free_pte_page(&pmd[i], addr + (i * PMD_SIZE)))
 			return 0;
 
 	pud_clear(pud);
@@ -707,11 +708,12 @@ int pud_free_pmd_page(pud_t *pud)
 /**
  * pmd_free_pte_page - Clear pmd entry and free pte page.
  * @pmd: Pointer to a PMD.
+ * @addr: Virtual address associated with pmd.
  *
  * Context: The pmd range has been unmaped and TLB purged.
  * Return: 1 if clearing the entry succeeded. 0 otherwise.
  */
-int pmd_free_pte_page(pmd_t *pmd)
+int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 {
 	pte_t *pte;
 
@@ -727,7 +729,7 @@ int pmd_free_pte_page(pmd_t *pmd)
 
 #else /* !CONFIG_X86_64 */
 
-int pud_free_pmd_page(pud_t *pud)
+int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 {
 	return pud_none(*pud);
 }
@@ -736,7 +738,7 @@ int pud_free_pmd_page(pud_t *pud)
  * Disable free page handling on x86-PAE. This assures that ioremap()
  * does not update sync'd pmd entries. See vmalloc_sync_one().
  */
-int pmd_free_pte_page(pmd_t *pmd)
+int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 {
 	return pmd_none(*pmd);
 }
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -770,8 +770,8 @@ int pud_set_huge(pud_t *pud, phys_addr_t
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
 int pud_clear_huge(pud_t *pud);
 int pmd_clear_huge(pmd_t *pmd);
-int pud_free_pmd_page(pud_t *pud);
-int pmd_free_pte_page(pmd_t *pmd);
+int pud_free_pmd_page(pud_t *pud, unsigned long addr);
+int pmd_free_pte_page(pmd_t *pmd, unsigned long addr);
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
 static inline int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
@@ -789,11 +789,11 @@ static inline int pmd_clear_huge(pmd_t *
 {
 	return 0;
 }
-static inline int pud_free_pmd_page(pud_t *pud)
+static inline int pud_free_pmd_page(pud_t *pud, unsigned long addr)
 {
 	return 0;
 }
-static inline int pmd_free_pte_page(pmd_t *pmd)
+static inline int pmd_free_pte_page(pmd_t *pmd, unsigned long addr)
 {
 	return 0;
 }
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -84,7 +84,7 @@ static inline int ioremap_pmd_range(pud_
 		if (ioremap_pmd_enabled() &&
 		    ((next - addr) == PMD_SIZE) &&
 		    IS_ALIGNED(phys_addr + addr, PMD_SIZE) &&
-		    pmd_free_pte_page(pmd)) {
+		    pmd_free_pte_page(pmd, addr)) {
 			if (pmd_set_huge(pmd, phys_addr + addr, prot))
 				continue;
 		}
@@ -111,7 +111,7 @@ static inline int ioremap_pud_range(pgd_
 		if (ioremap_pud_enabled() &&
 		    ((next - addr) == PUD_SIZE) &&
 		    IS_ALIGNED(phys_addr + addr, PUD_SIZE) &&
-		    pud_free_pmd_page(pud)) {
+		    pud_free_pmd_page(pud, addr)) {
 			if (pud_set_huge(pud, phys_addr + addr, prot))
 				continue;
 		}
