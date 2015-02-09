Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id ADE096B0070
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 17:46:02 -0500 (EST)
Received: by mail-ob0-f173.google.com with SMTP id uy5so28466460obc.4
        for <linux-mm@kvack.org>; Mon, 09 Feb 2015 14:46:02 -0800 (PST)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id i1si6586580oep.77.2015.02.09.14.46.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Feb 2015 14:46:01 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v2 4/7] mm: Change vunmap to tear down huge KVA mappings
Date: Mon,  9 Feb 2015 15:45:32 -0700
Message-Id: <1423521935-17454-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
References: <1423521935-17454-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

Change vunmap_pmd_range() and vunmap_pud_range() to tear down
huge KVA mappings when they are set.

These changes are only enabled when CONFIG_HAVE_ARCH_HUGE_VMAP
is defined.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 include/asm-generic/pgtable.h |    4 ++++
 mm/vmalloc.c                  |    4 ++++
 2 files changed, 8 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index 7dc3838..1204ea6 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -850,9 +850,13 @@ static inline void pmdp_set_numa(struct mm_struct *mm, unsigned long addr,
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
 void pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
 void pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
+int pud_clear_huge(pud_t *pud);
+int pmd_clear_huge(pmd_t *pmd);
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
 static inline void pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot) { }
 static inline void pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot) { }
+static inline int pud_clear_huge(pud_t *pud) { return 0; }
+static inline int pmd_clear_huge(pmd_t *pmd) { return 0; }
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 40ea214..dd53a9d 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -75,6 +75,8 @@ static void vunmap_pmd_range(pud_t *pud, unsigned long addr, unsigned long end)
 	pmd = pmd_offset(pud, addr);
 	do {
 		next = pmd_addr_end(addr, end);
+		if (pmd_clear_huge(pmd))
+			continue;
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
 		vunmap_pte_range(pmd, addr, next);
@@ -89,6 +91,8 @@ static void vunmap_pud_range(pgd_t *pgd, unsigned long addr, unsigned long end)
 	pud = pud_offset(pgd, addr);
 	do {
 		next = pud_addr_end(addr, end);
+		if (pud_clear_huge(pud))
+			continue;
 		if (pud_none_or_clear_bad(pud))
 			continue;
 		vunmap_pmd_range(pud, addr, next);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
