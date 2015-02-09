Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id E8314900015
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:46:03 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id nt9so28405396obb.3
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:46:03 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id k3si6592952obo.6.2015.02.09.14.46.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:46:03 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 5/7] x86, mm: Support huge KVA mappings on x86
Date: Mon,  9 Feb 2015 15:45:33 -0700
Message-Id: <1423521935-17454-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

Implement huge KVA mapping interfaces on x86.  Select
HAVE_ARCH_HUGE_VMAP when X86_64 or X86_32 with X86_PAE is set.
Without X86_PAE set, the X86_32 kernel has the 2-level page
tables and cannot provide the huge KVA mappings.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/Kconfig      |    1 +
 arch/x86/mm/pgtable.c |   34 ++++++++++++++++++++++++++++++++++
 2 files changed, 35 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0dc9d01..a79e286 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -97,6 +97,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select HAVE_BPF_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
 	select ARCH_HAS_SG_CHAIN
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 6fb6927..e495432 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -481,3 +481,37 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 {
 	__native_set_fixmap(idx, pfn_pte(phys >> PAGE_SHIFT, flags));
 }
+
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+void pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
+{
+	set_pte((pte_t *)pud, pfn_pte(
+		(u64)addr >> PAGE_SHIFT,
+		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
+}
+
+void pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
+{
+	set_pte((pte_t *)pmd, pfn_pte(
+		(u64)addr >> PAGE_SHIFT,
+		__pgprot(pgprot_val(prot) | _PAGE_PSE)));
+}
+
+int pud_clear_huge(pud_t *pud)
+{
+	if (pud_large(*pud)) {
+		pud_clear(pud);
+		return 1;
+	}
+	return 0;
+}
+
+int pmd_clear_huge(pmd_t *pmd)
+{
+	if (pmd_large(*pmd)) {
+		pmd_clear(pmd);
+		return 1;
+	}
+	return 0;
+}
+#endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
