Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f170.google.com (mail-qc0-f170.google.com [209.85.216.170])
	by kanga.kvack.org (Postfix) with ESMTP id 23D166B0073
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:30:04 -0500 (EST)
Received: by mail-qc0-f170.google.com with SMTP id p6so9655342qcv.1
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:30:04 -0800 (PST)
Received: from g6t1524.atlanta.hp.com (g6t1524.atlanta.hp.com. [15.193.200.67])
        by mx.google.com with ESMTPS id c6si9859289qan.67.2015.01.26.15.30.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:30:03 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 5/7] x86, mm: Support huge KVA mappings on x86
Date: Mon, 26 Jan 2015 16:13:27 -0700
Message-Id: <1422314009-31667-6-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>

Implement huge KVA mapping interfaces and select
CONFIG_HAVE_ARCH_HUGE_VMAP on x86.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/Kconfig      |    1 +
 arch/x86/mm/pgtable.c |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 33 insertions(+)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 0dc9d01..8150038 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -97,6 +97,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select HAVE_BPF_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
+	select HAVE_ARCH_HUGE_VMAP
 	select ARCH_HAS_SG_CHAIN
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 6fb6927..e113d69 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -481,3 +481,35 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 {
 	__native_set_fixmap(idx, pfn_pte(phys >> PAGE_SHIFT, flags));
 }
+
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
