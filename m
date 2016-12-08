Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 756536B027C
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:36 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 3so175162612pgd.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:36 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y3si29494730pfa.215.2016.12.08.08.22.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:35 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 22/28] x86/espfix: support 5-level paging
Date: Thu,  8 Dec 2016 19:21:44 +0300
Message-Id: <20161208162150.148763-24-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

XXX: how to test this?

Not-yet-Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/kernel/espfix_64.c | 41 ++++++++++++++++++++++++++++++++++++++---
 1 file changed, 38 insertions(+), 3 deletions(-)

diff --git a/arch/x86/kernel/espfix_64.c b/arch/x86/kernel/espfix_64.c
index 04f89caef9c4..f0afa0af4237 100644
--- a/arch/x86/kernel/espfix_64.c
+++ b/arch/x86/kernel/espfix_64.c
@@ -70,8 +70,15 @@ static DEFINE_MUTEX(espfix_init_mutex);
 #define ESPFIX_MAX_PAGES  DIV_ROUND_UP(CONFIG_NR_CPUS, ESPFIX_STACKS_PER_PAGE)
 static void *espfix_pages[ESPFIX_MAX_PAGES];
 
-static __page_aligned_bss pud_t espfix_pud_page[PTRS_PER_PUD]
+#if CONFIG_PGTABLE_LEVELS == 5
+static __page_aligned_bss pud_t espfix_pgtable_page[PTRS_PER_PUD]
 	__aligned(PAGE_SIZE);
+#elif CONFIG_PGTABLE_LEVELS == 4
+static __page_aligned_bss pud_t espfix_pgtable_page[PTRS_PER_PUD]
+	__aligned(PAGE_SIZE);
+#else
+#error Unexpected CONFIG_PGTABLE_LEVELS
+#endif
 
 static unsigned int page_random, slot_random;
 
@@ -97,6 +104,8 @@ static inline unsigned long espfix_base_addr(unsigned int cpu)
 #define ESPFIX_PTE_CLONES (PTRS_PER_PTE/PTE_STRIDE)
 #define ESPFIX_PMD_CLONES PTRS_PER_PMD
 #define ESPFIX_PUD_CLONES (65536/(ESPFIX_PTE_CLONES*ESPFIX_PMD_CLONES))
+/* XXX: what should it be? */
+#define ESPFIX_P4D_CLONES PTRS_PER_P4D
 
 #define PGTABLE_PROT	  ((_KERNPG_TABLE & ~_PAGE_RW) | _PAGE_NX)
 
@@ -122,10 +131,21 @@ static void init_espfix_random(void)
 void __init init_espfix_bsp(void)
 {
 	pgd_t *pgd_p;
+	p4d_t *p4d;
 
 	/* Install the espfix pud into the kernel page directory */
 	pgd_p = &init_level4_pgt[pgd_index(ESPFIX_BASE_ADDR)];
-	pgd_populate(&init_mm, pgd_p, (pud_t *)espfix_pud_page);
+	switch (CONFIG_PGTABLE_LEVELS) {
+	case 4:
+		p4d = p4d_offset(pgd_p, ESPFIX_BASE_ADDR);
+		p4d_populate(&init_mm, p4d, (pud_t *)espfix_pgtable_page);
+		break;
+	case 5:
+		pgd_populate(&init_mm, pgd_p, (p4d_t *)espfix_pgtable_page);
+		break;
+	default:
+		BUILD_BUG();
+	}
 
 	/* Randomize the locations */
 	init_espfix_random();
@@ -138,6 +158,7 @@ void init_espfix_ap(int cpu)
 {
 	unsigned int page;
 	unsigned long addr;
+	p4d_t p4d, *p4d_p;
 	pud_t pud, *pud_p;
 	pmd_t pmd, *pmd_p;
 	pte_t pte, *pte_p;
@@ -167,7 +188,21 @@ void init_espfix_ap(int cpu)
 	node = cpu_to_node(cpu);
 	ptemask = __supported_pte_mask;
 
-	pud_p = &espfix_pud_page[pud_index(addr)];
+	if (CONFIG_PGTABLE_LEVELS == 5) {
+		p4d_p = (p4d_t *)espfix_pgtable_page + p4d_index(addr);
+		p4d = *p4d_p;
+		if (!p4d_present(p4d)) {
+			struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
+
+			pud_p = (pud_t *)page_address(page);
+			p4d = __p4d(__pa(pud_p) | (PGTABLE_PROT & ptemask));
+			paravirt_alloc_pud(&init_mm, __pa(pud_p) >> PAGE_SHIFT);
+			for (n = 0; n < ESPFIX_P4D_CLONES; n++)
+				set_p4d(&p4d_p[n], p4d);
+		}
+	} else {
+		pud_p = (pud_t *)espfix_pgtable_page + pud_index(addr);
+	}
 	pud = *pud_p;
 	if (!pud_present(pud)) {
 		struct page *page = alloc_pages_node(node, PGALLOC_GFP, 0);
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
