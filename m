Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 049BA6B0038
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 18:48:44 -0500 (EST)
Received: by oigi138 with SMTP id i138so2652875oig.6
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 15:48:43 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id w9si1189025oia.43.2015.03.03.15.48.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 15:48:43 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 6/6 UPDATE] x86, mm: Support huge KVA mappings on x86
Date: Tue,  3 Mar 2015 16:48:00 -0700
Message-Id: <1425426480-10600-1-git-send-email-toshi.kani@hp.com>
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
 arch/x86/mm/pgtable.c |   85 +++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 86 insertions(+)

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
index 7b22ada..1916059 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -4,6 +4,7 @@
 #include <asm/pgtable.h>
 #include <asm/tlb.h>
 #include <asm/fixmap.h>
+#include <asm/mtrr.h>
 
 #define PGALLOC_GFP GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO
 
@@ -485,3 +486,87 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 {
 	__native_set_fixmap(idx, pfn_pte(phys >> PAGE_SHIFT, flags));
 }
+
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+/**
+ * pud_set_huge - setup kernel PUD mapping
+ *
+ * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
+ * it does not set up a huge page when the range is covered by non-WB type
+ * of MTRRs.  0xFF indicates that MTRRs are disabled.
+ *
+ * Return 1 on success, and 0 on no-operation.
+ */
+int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
+{
+	u8 mtrr;
+
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
+/**
+ * pmd_set_huge - setup kernel PMD mapping
+ *
+ * MTRRs can override PAT memory types with a 4KB granularity.  Therefore,
+ * it does not set up a huge page when the range is covered by non-WB type
+ * of MTRRs.  0xFF indicates that MTRRs are disabled.
+ *
+ * Return 1 on success, and 0 on no-operation.
+ */
+int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
+{
+	u8 mtrr;
+
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
+/**
+ * pud_clear_huge - clear kernel PUD mapping when it is set
+ *
+ * Return 1 on success, and 0 on no-operation.
+ */
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
+/**
+ * pmd_clear_huge - clear kernel PMD mapping when it is set
+ *
+ * Return 1 on success, and 0 on no-operation.
+ */
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
