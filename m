Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7A25C6B0280
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:40 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id e9so173981890pgc.5
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:40 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id y3si29494730pfa.215.2016.12.08.08.22.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:39 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 26/28] x86/mm: add support for 5-level paging for KASLR
Date: Thu,  8 Dec 2016 19:21:48 +0300
Message-Id: <20161208162150.148763-28-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With 5-level paging randomization happens on P4D level install of PUD.

Maximum amount of physical memory also bumped to 52-bits for 5-level
paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/kaslr.c | 82 ++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 63 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index bda8d5eef04d..c79d52732efa 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -6,12 +6,12 @@
  *
  * Entropy is generated using the KASLR early boot functions now shared in
  * the lib directory (originally written by Kees Cook). Randomization is
- * done on PGD & PUD page table levels to increase possible addresses. The
- * physical memory mapping code was adapted to support PUD level virtual
- * addresses. This implementation on the best configuration provides 30,000
- * possible virtual addresses in average for each memory region. An additional
- * low memory page is used to ensure each CPU can start with a PGD aligned
- * virtual address (for realmode).
+ * done on PGD & P4D/PUD page table levels to increase possible addresses.
+ * The physical memory mapping code was adapted to support P4D/PUD level
+ * virtual addresses. This implementation on the best configuration provides
+ * 30,000 possible virtual addresses in average for each memory region.
+ * An additional low memory page is used to ensure each CPU can start with
+ * a PGD aligned virtual address (for realmode).
  *
  * The order of each memory region is not changed. The feature looks at
  * the available space for the regions based on different configuration
@@ -61,7 +61,8 @@ static __initdata struct kaslr_memory_region {
 	unsigned long *base;
 	unsigned long size_tb;
 } kaslr_regions[] = {
-	{ &page_offset_base, 64/* Maximum */ },
+	{ &page_offset_base,
+		1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT) /* Maximum */ },
 	{ &vmalloc_base, VMALLOC_SIZE_TB },
 };
 
@@ -120,7 +121,10 @@ void __init kernel_randomize_memory(void)
 		 */
 		entropy = remain_entropy / (ARRAY_SIZE(kaslr_regions) - i);
 		prandom_bytes_state(&rand_state, &rand, sizeof(rand));
-		entropy = (rand % (entropy + 1)) & PUD_MASK;
+		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+			entropy = (rand % (entropy + 1)) & P4D_MASK;
+		else
+			entropy = (rand % (entropy + 1)) & PUD_MASK;
 		vaddr += entropy;
 		*kaslr_regions[i].base = vaddr;
 
@@ -129,27 +133,21 @@ void __init kernel_randomize_memory(void)
 		 * randomization alignment.
 		 */
 		vaddr += get_padding(&kaslr_regions[i]);
-		vaddr = round_up(vaddr + 1, PUD_SIZE);
+		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+			vaddr = round_up(vaddr + 1, P4D_SIZE);
+		else
+			vaddr = round_up(vaddr + 1, PUD_SIZE);
 		remain_entropy -= entropy;
 	}
 }
 
-/*
- * Create PGD aligned trampoline table to allow real mode initialization
- * of additional CPUs. Consume only 1 low memory page.
- */
-void __meminit init_trampoline(void)
+static void __meminit init_trampoline_pud(void)
 {
 	unsigned long paddr, paddr_next;
 	pgd_t *pgd;
 	pud_t *pud_page, *pud_page_tramp;
 	int i;
 
-	if (!kaslr_memory_enabled()) {
-		init_trampoline_default();
-		return;
-	}
-
 	pud_page_tramp = alloc_low_page();
 
 	paddr = 0;
@@ -170,3 +168,49 @@ void __meminit init_trampoline(void)
 	set_pgd(&trampoline_pgd_entry,
 		__pgd(_KERNPG_TABLE | __pa(pud_page_tramp)));
 }
+
+static void __meminit init_trampoline_p4d(void)
+{
+	unsigned long paddr, paddr_next;
+	pgd_t *pgd;
+	p4d_t *p4d_page, *p4d_page_tramp;
+	int i;
+
+	p4d_page_tramp = alloc_low_page();
+
+	paddr = 0;
+	pgd = pgd_offset_k((unsigned long)__va(paddr));
+	p4d_page = (p4d_t *) pgd_page_vaddr(*pgd);
+
+	for (i = p4d_index(paddr); i < PTRS_PER_P4D; i++, paddr = paddr_next) {
+		p4d_t *p4d, *p4d_tramp;
+		unsigned long vaddr = (unsigned long)__va(paddr);
+
+		p4d_tramp = p4d_page_tramp + p4d_index(paddr);
+		p4d = p4d_page + p4d_index(vaddr);
+		paddr_next = (paddr & P4D_MASK) + P4D_SIZE;
+
+		*p4d_tramp = *p4d;
+	}
+
+	set_pgd(&trampoline_pgd_entry,
+		__pgd(_KERNPG_TABLE | __pa(p4d_page_tramp)));
+}
+
+/*
+ * Create PGD aligned trampoline table to allow real mode initialization
+ * of additional CPUs. Consume only 1 low memory page.
+ */
+void __meminit init_trampoline(void)
+{
+
+	if (!kaslr_memory_enabled()) {
+		init_trampoline_default();
+		return;
+	}
+
+	if (IS_ENABLED(CONFIG_X86_5LEVEL))
+		init_trampoline_p4d();
+	else
+		init_trampoline_pud();
+}
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
