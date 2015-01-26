Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f174.google.com (mail-ob0-f174.google.com [209.85.214.174])
	by kanga.kvack.org (Postfix) with ESMTP id BD33D6B0071
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:30:00 -0500 (EST)
Received: by mail-ob0-f174.google.com with SMTP id gq1so10651285obb.5
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:30:00 -0800 (PST)
Received: from g5t1627.atlanta.hp.com (g5t1627.atlanta.hp.com. [15.192.137.10])
        by mx.google.com with ESMTPS id 186si5607491oip.98.2015.01.26.15.30.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:30:00 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 3/7] mm: Change ioremap to set up huge I/O mappings
Date: Mon, 26 Jan 2015 16:13:25 -0700
Message-Id: <1422314009-31667-4-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>

Change ioremap_pud_range() and ioremap_pmd_range() to set up
huge I/O mappings when their capability is enabled and their
conditions are met in a given request -- both virtual & physical
addresses are aligned and its range fufills the mapping size.

These changes are only enabled when both CONFIG_HUGE_IOMAP
and CONFIG_HAVE_ARCH_HUGE_VMAP are defined.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/Kconfig                  |    3 +++
 include/asm-generic/pgtable.h |    8 ++++++++
 lib/ioremap.c                 |   16 ++++++++++++++++
 3 files changed, 27 insertions(+)

diff --git a/arch/Kconfig b/arch/Kconfig
index 05d7a8a..55c4440 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -446,6 +446,9 @@ config HAVE_IRQ_TIME_ACCOUNTING
 config HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	bool
 
+config HAVE_ARCH_HUGE_VMAP
+	bool
+
 config HAVE_ARCH_SOFT_DIRTY
 	bool
 
diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 177d597..7dc3838 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -847,4 +847,12 @@ static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
 #define io_remap_pfn_range remap_pfn_range
 #endif
 
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+void pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
+void pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
+#else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
+static inline void pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot) { }
+static inline void pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot) { }
+#endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
+
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/lib/ioremap.c b/lib/ioremap.c
index 0a1ecb6..01b70aa 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -81,6 +81,14 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
+
+		if (ioremap_pmd_enabled() &&
+		    ((next - addr) == PMD_SIZE) &&
+		    !((phys_addr + addr) & (PMD_SIZE-1))) {
+			pmd_set_huge(pmd, phys_addr + addr, prot);
+			continue;
+		}
+
 		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
 			return -ENOMEM;
 	} while (pmd++, addr = next, addr != end);
@@ -99,6 +107,14 @@ static inline int ioremap_pud_range(pgd_t *pgd, unsigned long addr,
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
+
+		if (ioremap_pud_enabled() &&
+		    ((next - addr) == PUD_SIZE) &&
+		    !((phys_addr + addr) & (PUD_SIZE-1))) {
+			pud_set_huge(pud, phys_addr + addr, prot);
+			continue;
+		}
+
 		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
 			return -ENOMEM;
 	} while (pud++, addr = next, addr != end);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
