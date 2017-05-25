Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1CC6B0311
	for <linux-mm@kvack.org>; Thu, 25 May 2017 16:34:30 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id b74so241408469pfd.2
        for <linux-mm@kvack.org>; Thu, 25 May 2017 13:34:30 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id u195si29435729pgc.315.2017.05.25.13.34.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 May 2017 13:34:29 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv1, RFC 6/8] x86/mm: Replace compile-time checks for 5-level with runtime-time
Date: Thu, 25 May 2017 23:33:32 +0300
Message-Id: <20170525203334.867-7-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
References: <20170525203334.867-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This patch converts the of CONFIG_X86_5LEVEL check to runtime checks for
p4d folding.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/ident_map.c       |  2 +-
 arch/x86/mm/init_64.c         | 28 +++++++++++++++++-----------
 arch/x86/mm/kaslr.c           |  6 +++---
 arch/x86/power/hibernate_64.c |  4 ++--
 arch/x86/xen/mmu_pv.c         |  2 +-
 5 files changed, 24 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/ident_map.c b/arch/x86/mm/ident_map.c
index adab1595f4bd..d2df33a2cbfb 100644
--- a/arch/x86/mm/ident_map.c
+++ b/arch/x86/mm/ident_map.c
@@ -115,7 +115,7 @@ int kernel_ident_mapping_init(struct x86_mapping_info *info, pgd_t *pgd_page,
 		result = ident_p4d_init(info, p4d, addr, next);
 		if (result)
 			return result;
-		if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+		if (!p4d_folded) {
 			set_pgd(pgd, __pgd(__pa(p4d) | _KERNPG_TABLE));
 		} else {
 			/*
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index d135c613bf7b..b1b70a79fa14 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -88,12 +88,7 @@ static int __init nonx32_setup(char *str)
 }
 __setup("noexec32=", nonx32_setup);
 
-/*
- * When memory was added make sure all the processes MM have
- * suitable PGD entries in the local PGD level page.
- */
-#ifdef CONFIG_X86_5LEVEL
-void sync_global_pgds(unsigned long start, unsigned long end)
+static void sync_global_pgds_57(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 
@@ -129,8 +124,8 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		spin_unlock(&pgd_lock);
 	}
 }
-#else
-void sync_global_pgds(unsigned long start, unsigned long end)
+
+static void sync_global_pgds_48(unsigned long start, unsigned long end)
 {
 	unsigned long addr;
 
@@ -173,7 +168,18 @@ void sync_global_pgds(unsigned long start, unsigned long end)
 		spin_unlock(&pgd_lock);
 	}
 }
-#endif
+
+/*
+ * When memory was added make sure all the processes MM have
+ * suitable PGD entries in the local PGD level page.
+ */
+void sync_global_pgds(unsigned long start, unsigned long end)
+{
+	if (!p4d_folded)
+		sync_global_pgds_57(start, end);
+	else
+		sync_global_pgds_48(start, end);
+}
 
 /*
  * NOTE: This function is marked __ref because it calls __init function
@@ -632,7 +638,7 @@ phys_p4d_init(p4d_t *p4d_page, unsigned long paddr, unsigned long paddr_end,
 	unsigned long vaddr = (unsigned long)__va(paddr);
 	int i = p4d_index(vaddr);
 
-	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (p4d_folded)
 		return phys_pud_init((pud_t *) p4d_page, paddr, paddr_end, page_size_mask);
 
 	for (; i < PTRS_PER_P4D; i++, paddr = paddr_next) {
@@ -712,7 +718,7 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 					   page_size_mask);
 
 		spin_lock(&init_mm.page_table_lock);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (!p4d_folded)
 			pgd_populate(&init_mm, pgd, p4d);
 		else
 			p4d_populate(&init_mm, p4d_offset(pgd, vaddr), (pud_t *) p4d);
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 55433f2d1957..a691ff07d825 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -134,7 +134,7 @@ void __init kernel_randomize_memory(void)
 		 */
 		entropy = remain_entropy / (ARRAY_SIZE(kaslr_regions) - i);
 		prandom_bytes_state(&rand_state, &rand, sizeof(rand));
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (!p4d_folded)
 			entropy = (rand % (entropy + 1)) & P4D_MASK;
 		else
 			entropy = (rand % (entropy + 1)) & PUD_MASK;
@@ -146,7 +146,7 @@ void __init kernel_randomize_memory(void)
 		 * randomization alignment.
 		 */
 		vaddr += get_padding(&kaslr_regions[i]);
-		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		if (!p4d_folded)
 			vaddr = round_up(vaddr + 1, P4D_SIZE);
 		else
 			vaddr = round_up(vaddr + 1, PUD_SIZE);
@@ -222,7 +222,7 @@ void __meminit init_trampoline(void)
 		return;
 	}
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL))
+	if (!p4d_folded)
 		init_trampoline_p4d();
 	else
 		init_trampoline_pud();
diff --git a/arch/x86/power/hibernate_64.c b/arch/x86/power/hibernate_64.c
index a6e21fee22ea..86696ff275b9 100644
--- a/arch/x86/power/hibernate_64.c
+++ b/arch/x86/power/hibernate_64.c
@@ -66,7 +66,7 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 	 * tables used by the image kernel.
 	 */
 
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		p4d = (p4d_t *)get_safe_page(GFP_ATOMIC);
 		if (!p4d)
 			return -ENOMEM;
@@ -84,7 +84,7 @@ static int set_up_temporary_text_mapping(pgd_t *pgd)
 		__pmd((jump_address_phys & PMD_MASK) | __PAGE_KERNEL_LARGE_EXEC));
 	set_pud(pud + pud_index(restore_jump_address),
 		__pud(__pa(pmd) | _KERNPG_TABLE));
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		set_p4d(p4d + p4d_index(restore_jump_address), __p4d(__pa(pud) | _KERNPG_TABLE));
 		set_pgd(pgd + pgd_index(restore_jump_address), __pgd(__pa(p4d) | _KERNPG_TABLE));
 	} else {
diff --git a/arch/x86/xen/mmu_pv.c b/arch/x86/xen/mmu_pv.c
index d9ee946559c9..e39054fca812 100644
--- a/arch/x86/xen/mmu_pv.c
+++ b/arch/x86/xen/mmu_pv.c
@@ -1214,7 +1214,7 @@ static void __init xen_cleanmfnmap(unsigned long vaddr)
 			continue;
 		xen_cleanmfnmap_p4d(p4d + i, unpin);
 	}
-	if (IS_ENABLED(CONFIG_X86_5LEVEL)) {
+	if (!p4d_folded) {
 		set_pgd(pgd, __pgd(0));
 		xen_cleanmfnmap_free_pgtbl(p4d, unpin);
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
