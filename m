Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f170.google.com (mail-ob0-f170.google.com [209.85.214.170])
	by kanga.kvack.org (Postfix) with ESMTP id D63EA6B0071
	for <linux-mm@kvack.org>; Tue,  3 Mar 2015 12:45:13 -0500 (EST)
Received: by obcuy5 with SMTP id uy5so1308665obc.4
        for <linux-mm@kvack.org>; Tue, 03 Mar 2015 09:45:13 -0800 (PST)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id x10si724356oey.80.2015.03.03.09.45.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Mar 2015 09:45:13 -0800 (PST)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v3 4/6] mm: Change vunmap to tear down huge KVA mappings
Date: Tue,  3 Mar 2015 10:44:22 -0700
Message-Id: <1425404664-19675-5-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
References: <1425404664-19675-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, arnd@arndb.de
Cc: linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org, dave.hansen@intel.com, Elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

Changed vunmap_pmd_range() and vunmap_pud_range() to tear down
huge KVA mappings when they are set.  pud_clear_huge() and
pmd_clear_huge() return zero when no-operation is performed,
i.e. huge page mapping was not used.

These changes are only enabled when CONFIG_HAVE_ARCH_HUGE_VMAP
is defined on the architecture.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 include/asm-generic/pgtable.h |    4 ++++
 mm/vmalloc.c                  |    4 ++++
 2 files changed, 8 insertions(+)

diff --git a/include/asm-generic/pgtable.h b/include/asm-generic/pgtable.h
index bf6e86c..b583235 100644
--- a/include/asm-generic/pgtable.h
+++ b/include/asm-generic/pgtable.h
@@ -701,6 +701,8 @@ static inline int pmd_protnone(pmd_t pmd)
 #ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
 int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot);
 int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot);
+int pud_clear_huge(pud_t *pud);
+int pmd_clear_huge(pmd_t *pmd);
 #else	/* !CONFIG_HAVE_ARCH_HUGE_VMAP */
 static inline int pud_set_huge(pud_t *pud, phys_addr_t addr, pgprot_t prot)
 {
@@ -710,6 +712,8 @@ static inline int pmd_set_huge(pmd_t *pmd, phys_addr_t addr, pgprot_t prot)
 {
 	return 0;
 }
+static inline int pud_clear_huge(pud_t *pud) { return 0; }
+static inline int pmd_clear_huge(pmd_t *pmd) { return 0; }
 #endif	/* CONFIG_HAVE_ARCH_HUGE_VMAP */
 
 #endif /* _ASM_GENERIC_PGTABLE_H */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index fe1672d..9184cf7 100644
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
