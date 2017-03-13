Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C85576B03FF
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:50:28 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so282914427pgc.6
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:50:28 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e3si10487362pgn.333.2017.03.12.22.50.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:27 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 01/26] x86: basic changes into headers for 5-level paging
Date: Mon, 13 Mar 2017 08:49:55 +0300
Message-Id: <20170313055020.69655-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch extends x86 headers to enable 5-level paging support.

It's still based on <asm-generic/5level-fixup.h>. We will get to the
point where we can have <asm-generic/pgtable-nop4d.h> later.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/pgtable-2level_types.h |  1 +
 arch/x86/include/asm/pgtable-3level_types.h |  1 +
 arch/x86/include/asm/pgtable.h              | 26 ++++++++++++++++++++-----
 arch/x86/include/asm/pgtable_64_types.h     |  1 +
 arch/x86/include/asm/pgtable_types.h        | 30 ++++++++++++++++++++++++++++-
 5 files changed, 53 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level_types.h b/arch/x86/include/asm/pgtable-2level_types.h
index 392576433e77..373ab1de909f 100644
--- a/arch/x86/include/asm/pgtable-2level_types.h
+++ b/arch/x86/include/asm/pgtable-2level_types.h
@@ -7,6 +7,7 @@
 typedef unsigned long	pteval_t;
 typedef unsigned long	pmdval_t;
 typedef unsigned long	pudval_t;
+typedef unsigned long	p4dval_t;
 typedef unsigned long	pgdval_t;
 typedef unsigned long	pgprotval_t;
 
diff --git a/arch/x86/include/asm/pgtable-3level_types.h b/arch/x86/include/asm/pgtable-3level_types.h
index bcc89625ebe5..b8a4341faafa 100644
--- a/arch/x86/include/asm/pgtable-3level_types.h
+++ b/arch/x86/include/asm/pgtable-3level_types.h
@@ -7,6 +7,7 @@
 typedef u64	pteval_t;
 typedef u64	pmdval_t;
 typedef u64	pudval_t;
+typedef u64	p4dval_t;
 typedef u64	pgdval_t;
 typedef u64	pgprotval_t;
 
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 1cfb36b8c024..6f6f351e0a81 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -179,6 +179,17 @@ static inline unsigned long pud_pfn(pud_t pud)
 	return (pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT;
 }
 
+static inline unsigned long p4d_pfn(p4d_t p4d)
+{
+	return (p4d_val(p4d) & p4d_pfn_mask(p4d)) >> PAGE_SHIFT;
+}
+
+static inline int p4d_large(p4d_t p4d)
+{
+	/* No 512 GiB pages yet */
+	return 0;
+}
+
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
 static inline int pmd_large(pmd_t pte)
@@ -770,6 +781,16 @@ static inline int pud_large(pud_t pud)
 }
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
+static inline unsigned long pud_index(unsigned long address)
+{
+	return (address >> PUD_SHIFT) & (PTRS_PER_PUD - 1);
+}
+
+static inline unsigned long p4d_index(unsigned long address)
+{
+	return (address >> P4D_SHIFT) & (PTRS_PER_P4D - 1);
+}
+
 #if CONFIG_PGTABLE_LEVELS > 3
 static inline int pgd_present(pgd_t pgd)
 {
@@ -788,11 +809,6 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
 #define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
 
 /* to find an entry in a page-table-directory. */
-static inline unsigned long pud_index(unsigned long address)
-{
-	return (address >> PUD_SHIFT) & (PTRS_PER_PUD - 1);
-}
-
 static inline pud_t *pud_offset(pgd_t *pgd, unsigned long address)
 {
 	return (pud_t *)pgd_page_vaddr(*pgd) + pud_index(address);
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 3a264200c62f..0b2797e5083c 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -13,6 +13,7 @@
 typedef unsigned long	pteval_t;
 typedef unsigned long	pmdval_t;
 typedef unsigned long	pudval_t;
+typedef unsigned long	p4dval_t;
 typedef unsigned long	pgdval_t;
 typedef unsigned long	pgprotval_t;
 
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index 62484333673d..df08535f774a 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -272,9 +272,20 @@ static inline pgdval_t pgd_flags(pgd_t pgd)
 	return native_pgd_val(pgd) & PTE_FLAGS_MASK;
 }
 
-#if CONFIG_PGTABLE_LEVELS > 3
+#if CONFIG_PGTABLE_LEVELS > 4
+
+#error FIXME
+
+#else
 #include <asm-generic/5level-fixup.h>
 
+static inline p4dval_t native_p4d_val(p4d_t p4d)
+{
+	return native_pgd_val(p4d);
+}
+#endif
+
+#if CONFIG_PGTABLE_LEVELS > 3
 typedef struct { pudval_t pud; } pud_t;
 
 static inline pud_t native_make_pud(pmdval_t val)
@@ -318,6 +329,22 @@ static inline pmdval_t native_pmd_val(pmd_t pmd)
 }
 #endif
 
+static inline p4dval_t p4d_pfn_mask(p4d_t p4d)
+{
+	/* No 512 GiB huge pages yet */
+	return PTE_PFN_MASK;
+}
+
+static inline p4dval_t p4d_flags_mask(p4d_t p4d)
+{
+	return ~p4d_pfn_mask(p4d);
+}
+
+static inline p4dval_t p4d_flags(p4d_t p4d)
+{
+	return native_p4d_val(p4d) & p4d_flags_mask(p4d);
+}
+
 static inline pudval_t pud_pfn_mask(pud_t pud)
 {
 	if (native_pud_val(pud) & _PAGE_PSE)
@@ -461,6 +488,7 @@ enum pg_level {
 	PG_LEVEL_4K,
 	PG_LEVEL_2M,
 	PG_LEVEL_1G,
+	PG_LEVEL_512G,
 	PG_LEVEL_NUM
 };
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
