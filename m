Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B81FB4405E3
	for <linux-mm@kvack.org>; Fri, 17 Feb 2017 09:14:10 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id e4so60672786pfg.4
        for <linux-mm@kvack.org>; Fri, 17 Feb 2017 06:14:10 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e11si10355979pgp.351.2017.02.17.06.14.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Feb 2017 06:14:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3 31/33] x86/mm: add support for 5-level paging for KASLR
Date: Fri, 17 Feb 2017 17:13:26 +0300
Message-Id: <20170217141328.164563-32-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
References: <20170217141328.164563-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With 5-level paging randomization happens on P4D level instead of PUD.

Maximum amount of physical memory also bumped to 52-bits for 5-level
paging.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/kaslr.c | 82 ++++++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 63 insertions(+), 19 deletions(-)

diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index 887e57182716..662e5c4b21c8 100644
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
@@ -70,7 +70,8 @@ static __initdata struct kaslr_memory_region {
 	unsigned long *base;
 	unsigned long size_tb;
 } kaslr_regions[] = {
-	{ &page_offset_base, 64/* Maximum */ },
+	{ &page_offset_base,
+		1 << (__PHYSICAL_MASK_SHIFT - TB_SHIFT) /* Maximum */ },
 	{ &vmalloc_base, VMALLOC_SIZE_TB },
 	{ &vmemmap_base, 1 },
 };
@@ -142,7 +143,10 @@ void __init kernel_randomize_memory(void)
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
 
@@ -151,27 +155,21 @@ void __init kernel_randomize_memory(void)
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
@@ -192,3 +190,49 @@ void __meminit init_trampoline(void)
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
