Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id A10E4829CA
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 17:34:35 -0400 (EDT)
Received: by obcva8 with SMTP id va8so22552578obc.8
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 14:34:35 -0700 (PDT)
Received: from g1t5424.austin.hp.com (g1t5424.austin.hp.com. [15.216.225.54])
        by mx.google.com with ESMTPS id cc6si1658834oec.12.2015.03.13.14.34.34
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Mar 2015 14:34:35 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 1/5] mm, x86: Document return values of mapping funcs
Date: Fri, 13 Mar 2015 15:33:37 -0600
Message-Id: <1426282421-25385-2-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
References: <1426282421-25385-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, pebolle@tiscali.nl, Toshi Kani <toshi.kani@hp.com>

Document the return values of KVA mapping functions,
pud_set_huge(), pmd_set_huge, pud_clear_huge() and
pmd_clear_huge().

Simplify the conditions to select HAVE_ARCH_HUGE_VMAP
in the Kconfig, since X86_PAE depends on X86_32.

There is no functional change in this patch.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/x86/Kconfig      |    2 +-
 arch/x86/mm/pgtable.c |   36 ++++++++++++++++++++++++++++--------
 2 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c22526d..3c79a47 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -99,7 +99,7 @@ config X86
 	select IRQ_FORCED_THREADING
 	select HAVE_BPF_JIT if X86_64
 	select HAVE_ARCH_TRANSPARENT_HUGEPAGE
-	select HAVE_ARCH_HUGE_VMAP if X86_64 || (X86_32 && X86_PAE)
+	select HAVE_ARCH_HUGE_VMAP if X86_64 || X86_PAE
 	select ARCH_HAS_SG_CHAIN
 	select CLKEVT_I8253
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 0b97d2c..4891fa1 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -563,14 +563,19 @@ void native_set_fixmap(enum fixed_addresses idx, phys_addr_t phys,
 }
 
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+/**
+ * pud_set_huge - setup kernel PUD mapping
+ *
+ * MTRR can override PAT memory types with 4KB granularity.  Therefore,
+ * it does not set up a huge page when the range is covered by a non-WB
+ * type of MTRR.  0xFF indicates that MTRR are disabled.
+ *
+ * Return 1 on success, and 0 when no PUD was set.
+ */
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
 	u8 mtrr;
 
-	/*
-	 * Do not use a huge page when the range is covered by non-WB type
-	 * of MTRRs.
-	 */
 	mtrr = mtrr_type_lookup(addr, addr + PUD_SIZE);
 	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
 		return 0;
@@ -584,14 +589,19 @@ int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 	return 1;
 }
 
+/**
+ * pmd_set_huge - setup kernel PMD mapping
+ *
+ * MTRR can override PAT memory types with 4KB granularity.  Therefore,
+ * it does not set up a huge page when the range is covered by a non-WB
+ * type of MTRR.  0xFF indicates that MTRR are disabled.
+ *
+ * Return 1 on success, and 0 when no PMD was set.
+ */
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 {
 	u8 mtrr;
 
-	/*
-	 * Do not use a huge page when the range is covered by non-WB type
-	 * of MTRRs.
-	 */
 	mtrr = mtrr_type_lookup(addr, addr + PMD_SIZE);
 	if ((mtrr != MTRR_TYPE_WRBACK) && (mtrr != 0xFF))
 		return 0;
@@ -605,6 +615,11 @@ int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 	return 1;
 }
 
+/**
+ * pud_clear_huge - clear kernel PUD mapping when it is set
+ *
+ * Return 1 on success, and 0 when no PUD map was found.
+ */
 int pud_clear_huge(pud_t *pud)
 {
 	if (pud_large(*pud)) {
@@ -615,6 +630,11 @@ int pud_clear_huge(pud_t *pud)
 	return 0;
 }
 
+/**
+ * pmd_clear_huge - clear kernel PMD mapping when it is set
+ *
+ * Return 1 on success, and 0 when no PMD map was found.
+ */
 int pmd_clear_huge(pmd_t *pmd)
 {
 	if (pmd_large(*pmd)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
