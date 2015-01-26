Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qc0-f181.google.com (mail-qc0-f181.google.com [209.85.216.181])
	by kanga.kvack.org (Postfix) with ESMTP id D522D6B0072
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 18:30:02 -0500 (EST)
Received: by mail-qc0-f181.google.com with SMTP id l6so9622391qcy.12
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 15:30:02 -0800 (PST)
Received: from g6t1525.atlanta.hp.com (g6t1525.atlanta.hp.com. [15.193.200.68])
        by mx.google.com with ESMTPS id f6si15212408qas.121.2015.01.26.15.30.01
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 15:30:02 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [RFC PATCH 4/7] mm: Change vunmap to tear down huge KVA mappings
Date: Mon, 26 Jan 2015 16:13:26 -0700
Message-Id: <1422314009-31667-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
References: <1422314009-31667-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de, linux-mm@kvack.org
Cc: x86@kernel.org, linux-kernel@vger.kernel.org, Toshi Kani <toshi.kani@hp.com>

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
index 830a4be..c9490fe 100644
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
