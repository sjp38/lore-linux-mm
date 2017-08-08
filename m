Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB6C66B02FD
	for <linux-mm@kvack.org>; Tue,  8 Aug 2017 08:54:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 24so31899494pfk.5
        for <linux-mm@kvack.org>; Tue, 08 Aug 2017 05:54:31 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id 77si846787pfn.385.2017.08.08.05.54.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Aug 2017 05:54:30 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 07/14] x86/mm: Make virtual memory layout movable for CONFIG_X86_5LEVEL
Date: Tue,  8 Aug 2017 15:54:08 +0300
Message-Id: <20170808125415.78842-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
References: <20170808125415.78842-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We need to be able to adjust virtual memory layout at runtime to be able
to switch between 4- and 5-level paging at boot-time.

KASLR already has movable __VMALLOC_BASE, __VMEMMAP_BASE and __PAGE_OFFSET.
Let's re-use it.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/include/asm/kaslr.h            | 4 ----
 arch/x86/include/asm/page_64.h          | 4 ++++
 arch/x86/include/asm/page_64_types.h    | 2 +-
 arch/x86/include/asm/pgtable_64_types.h | 2 +-
 arch/x86/kernel/head64.c                | 9 +++++++++
 arch/x86/mm/kaslr.c                     | 8 --------
 6 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/arch/x86/include/asm/kaslr.h b/arch/x86/include/asm/kaslr.h
index 1052a797d71d..683c9d736314 100644
--- a/arch/x86/include/asm/kaslr.h
+++ b/arch/x86/include/asm/kaslr.h
@@ -4,10 +4,6 @@
 unsigned long kaslr_get_random_long(const char *purpose);
 
 #ifdef CONFIG_RANDOMIZE_MEMORY
-extern unsigned long page_offset_base;
-extern unsigned long vmalloc_base;
-extern unsigned long vmemmap_base;
-
 void kernel_randomize_memory(void);
 #else
 static inline void kernel_randomize_memory(void) { }
diff --git a/arch/x86/include/asm/page_64.h b/arch/x86/include/asm/page_64.h
index b4a0d43248cf..a12fb4dcdd15 100644
--- a/arch/x86/include/asm/page_64.h
+++ b/arch/x86/include/asm/page_64.h
@@ -10,6 +10,10 @@
 extern unsigned long max_pfn;
 extern unsigned long phys_base;
 
+extern unsigned long page_offset_base;
+extern unsigned long vmalloc_base;
+extern unsigned long vmemmap_base;
+
 static inline unsigned long __phys_addr_nodebug(unsigned long x)
 {
 	unsigned long y = x - __START_KERNEL_map;
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 3f5f08b010d0..0126d6bc2eb1 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -42,7 +42,7 @@
 #define __PAGE_OFFSET_BASE      _AC(0xffff880000000000, UL)
 #endif
 
-#ifdef CONFIG_RANDOMIZE_MEMORY
+#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
 #define __PAGE_OFFSET           page_offset_base
 #else
 #define __PAGE_OFFSET           __PAGE_OFFSET_BASE
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index 06470da156ba..a9f77ead7088 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -85,7 +85,7 @@ typedef struct { pteval_t pte; } pte_t;
 #define __VMALLOC_BASE	_AC(0xffffc90000000000, UL)
 #define __VMEMMAP_BASE	_AC(0xffffea0000000000, UL)
 #endif
-#ifdef CONFIG_RANDOMIZE_MEMORY
+#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
 #define VMALLOC_START	vmalloc_base
 #define VMEMMAP_START	vmemmap_base
 #else
diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 925b2928f377..aa163bda4a29 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -38,6 +38,15 @@ extern pmd_t early_dynamic_pgts[EARLY_DYNAMIC_PAGE_TABLES][PTRS_PER_PMD];
 static unsigned int __initdata next_early_pgt;
 pmdval_t early_pmd_flags = __PAGE_KERNEL_LARGE & ~(_PAGE_GLOBAL | _PAGE_NX);
 
+#if defined(CONFIG_RANDOMIZE_MEMORY) || defined(CONFIG_X86_5LEVEL)
+unsigned long page_offset_base __read_mostly = __PAGE_OFFSET_BASE;
+EXPORT_SYMBOL(page_offset_base);
+unsigned long vmalloc_base __read_mostly = __VMALLOC_BASE;
+EXPORT_SYMBOL(vmalloc_base);
+unsigned long vmemmap_base __read_mostly = __VMEMMAP_BASE;
+EXPORT_SYMBOL(vmemmap_base);
+#endif
+
 #define __head	__section(.head.text)
 
 static void __head *fixup_pointer(void *ptr, unsigned long physaddr)
diff --git a/arch/x86/mm/kaslr.c b/arch/x86/mm/kaslr.c
index af599167fe3c..e6420b18f6e0 100644
--- a/arch/x86/mm/kaslr.c
+++ b/arch/x86/mm/kaslr.c
@@ -53,14 +53,6 @@ static const unsigned long vaddr_end = EFI_VA_END;
 static const unsigned long vaddr_end = __START_KERNEL_map;
 #endif
 
-/* Default values */
-unsigned long page_offset_base = __PAGE_OFFSET_BASE;
-EXPORT_SYMBOL(page_offset_base);
-unsigned long vmalloc_base = __VMALLOC_BASE;
-EXPORT_SYMBOL(vmalloc_base);
-unsigned long vmemmap_base = __VMEMMAP_BASE;
-EXPORT_SYMBOL(vmemmap_base);
-
 /*
  * Memory regions randomized by KASLR (except modules that use a separate logic
  * earlier during boot). The list is ordered based on virtual addresses. This
-- 
2.13.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
