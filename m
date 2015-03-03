Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f53.google.com (mail-oi0-f53.google.com [209.85.218.53])
	by kanga.kvack.org (Postfix) with ESMTP id 60D716B0073
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:45:17 -0500 (EST)
Received: by oiba3 with SMTP id a3so884519oib.3
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:45:17 -0800 (PST)
Received: from g1t5425.austin.hp.com (g1t5425.austin.hp.com. [15.216.225.55])
        by mx.google.com with ESMTPS id z1si741241obg.51.2015.03.03.09.45.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:45:16 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 6/6] x86, mm: Support huge KVA mappings on x86
Date: Tue,  3 Mar 2015 10:44:24 -0700
Message-Id: <1425404664-19675-7-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

This patch implements huge KVA mapping interfaces on x86.

On x86, MTRRs can override PAT memory types with a 4KB granularity.
When using a huge page, MTRRs can override the memory type of the
huge page, which may lead a performance penalty.  The processor
can also behave in an undefined manner if a huge page is mapped to
a memory range that MTRRs have mapped with multiple different memory
types.  Therefore, the mapping code falls back to use a smaller page
size toward 4KB when a mapping range is covered by non-WB type of
MTRRs.  The WB type of MTRRs has no affect on the PAT memory types.

pud_set_huge() and pmd_set_huge() call mtrr_type_lookup() to see
if a given range is covered by MTRRs.  MTRR_TYPE_WRBACK indicates
that the range is either covered by WB or not covered and the MTRR
default value is set to WB.  0xFF indicates that MTRRs are disabled.

HAVE_ARCH_HUGE_VMAP is selected when X86_64 or X86_32 with X86_PAE
is set.  X86_32 without X86_PAE is not supported since such config
can unlikey be benefited from this feature, and there was an issue
found in testing.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/Kconfig      |    1 +
 arch/x86/mm/pgtable.c |   65 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 66 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c2fb8a8..ef7d4a6 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -99,6 +99,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select HAVE_BPF_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
 	select ARCH_HAS_SG_CHAIN
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7b22ada..19c897e 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -4,6 +4,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
+#include <asm/mtrr.h>
 
 #define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
 
@@ -485,3 +486,67 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 {
 	__native_set_fixmap(idx, pfn_pte(phys >> PAGE_SHIFT, flags));
 }
+
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
+{
+	u8 mtrr;
+
+	/*
+	 * Do not use a huge page when the range is covered by non-WB type
+	 * of MTRRs.
+	 */
+	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
+	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+		return 0;
+
+	prot = pgprot_4k_2_large(prot);
+
+	set_pte((pte_t *)pud, pfn_pte(
+		(u64)addr >> PAGE_SHIFT,
+		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
+
+	return 1;
+}
+
+int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
+{
+	u8 mtrr;
+
+	/*
+	 * Do not use a huge page when the range is covered by non-WB type
+	 * of MTRRs.
+	 */
+	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
+	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
+		return 0;
+
+	prot = pgprot_4k_2_large(prot);
+
+	set_pte((pte_t *)pmd, pfn_pte(
+		(u64)addr >> PAGE_SHIFT,
+		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
+
+	return 1;
+}
+
+int pud_clear_huge(pud_t *pud)
+{
+	if (pud_large(*pud)) {
+		pud_clear(pud);
+		return 1;
+	}
+
+	return 0;
+}
+
+int pmd_clear_huge(pmd_t *pmd)
+{
+	if (pmd_large(*pmd)) {
+		pmd_clear(pmd);
+		return 1;
+	}
+
+	return 0;
+}
+#endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
