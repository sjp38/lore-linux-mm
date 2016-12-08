Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 6F2FA6B0278
	for <linux-mm@kvack.org>; Thu,  8 Dec 2016 11:22:35 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id i88so637796513pfk.3
        for <linux-mm@kvack.org>; Thu, 08 Dec 2016 08:22:35 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id f17si29419981pge.120.2016.12.08.08.22.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Dec 2016 08:22:34 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [RFC, PATCHv1 17/28] x86/mm: define virtual memory map for 5-level paging
Date: Thu,  8 Dec 2016 19:21:39 +0300
Message-Id: <20161208162150.148763-19-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
References: <20161208162150.148763-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The first part of memory map (up to %esp fixup) simply scales existing
map for 4-level paging by factor of 9 -- number of bits addressed by
additional page table level.

The rest of the map is uncahnged.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/x86/x86_64/mm.txt         | 23 ++++++++++++++++++++++-
 arch/x86/Kconfig                        |  1 +
 arch/x86/include/asm/kasan.h            |  9 ++++++---
 arch/x86/include/asm/page_64_types.h    | 10 ++++++++++
 arch/x86/include/asm/pgtable_64_types.h |  6 ++++++
 arch/x86/include/asm/sparsemem.h        |  9 +++++++--
 6 files changed, 52 insertions(+), 6 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 8c7dd5957ae1..d33fb0799b3d 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -12,7 +12,7 @@ ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
 ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
 ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
 ... unused hole ...
-ffffec0000000000 - fffffc0000000000 (=44 bits) kasan shadow memory (16TB)
+ffffec0000000000 - fffffbffffffffff (=44 bits) kasan shadow memory (16TB)
 ... unused hole ...
 ffffff0000000000 - ffffff7fffffffff (=39 bits) %esp fixup stacks
 ... unused hole ...
@@ -23,6 +23,27 @@ ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
 ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
 ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
 
+Virtual memory map with 5 level page tables:
+
+0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
+hole caused by [57:63] sign extension
+ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
+ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
+ff90000000000000 - ff91ffffffffffff (=49 bits) hole
+ff92000000000000 - ffd1ffffffffffff (=54 bits) vmalloc/ioremap space
+ffd2000000000000 - ff93ffffffffffff (=49 bits) virtual memory map (512TB)
+... unused hole ...
+ff96000000000000 - ffb5ffffffffffff (=53 bits) kasan shadow memory (8PB)
+... unused hole ...
+fffe000000000000 - fffeffffffffffff (=49 bits) %esp fixup stacks
+... unused hole ...
+ffffffef00000000 - ffffffff00000000 (=64 GB) EFI region mapping space
+... unused hole ...
+ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from phys 0
+ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
+ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
+ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
+
 The direct mapping covers all memory in the system up to the highest
 memory address (this means in some cases it can also include PCI memory
 holes).
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 2a1f0ce7c59a..df4f1d514ab0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -279,6 +279,7 @@ config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 config KASAN_SHADOW_OFFSET
 	hex
 	depends on KASAN
+	default 0xdfb6000000000000 if X86_5LEVEL
 	default 0xdffffc0000000000
 
 config HAVE_INTEL_TXT
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index 1410b567ecde..2587c6bd89be 100644
--- a/arch/x86/include/asm/kasan.h
+++ b/arch/x86/include/asm/kasan.h
@@ -11,9 +11,12 @@
  * 'kernel address space start' >> KASAN_SHADOW_SCALE_SHIFT
  */
 #define KASAN_SHADOW_START      (KASAN_SHADOW_OFFSET + \
-					(0xffff800000000000ULL >> 3))
-/* 47 bits for kernel address -> (47 - 3) bits for shadow */
-#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (47 - 3)))
+					((-1UL << __VIRTUAL_MASK_SHIFT) >> 3))
+/*
+ * 47 bits for kernel address -> (47 - 3) bits for shadow
+ * 56 bits for kernel address -> (56 - 3) bits fro shadow
+ */
+#define KASAN_SHADOW_END        (KASAN_SHADOW_START + (1ULL << (__VIRTUAL_MASK_SHIFT - 3)))
 
 #ifndef __ASSEMBLY__
 
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index 9215e0527647..3f5f08b010d0 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -36,7 +36,12 @@
  * hypervisor to fit.  Choosing 16 slots here is arbitrary, but it's
  * what Xen requires.
  */
+#ifdef CONFIG_X86_5LEVEL
+#define __PAGE_OFFSET_BASE      _AC(0xff10000000000000, UL)
+#else
 #define __PAGE_OFFSET_BASE      _AC(0xffff880000000000, UL)
+#endif
+
 #ifdef CONFIG_RANDOMIZE_MEMORY
 #define __PAGE_OFFSET           page_offset_base
 #else
@@ -46,8 +51,13 @@
 #define __START_KERNEL_map	_AC(0xffffffff80000000, UL)
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
+#ifdef CONFIG_X86_5LEVEL
+#define __PHYSICAL_MASK_SHIFT	52
+#define __VIRTUAL_MASK_SHIFT	56
+#else
 #define __PHYSICAL_MASK_SHIFT	46
 #define __VIRTUAL_MASK_SHIFT	47
+#endif
 
 /*
  * Kernel image size is limited to 1GiB due to the fixmap living in the
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index d15ca53bd462..034cbca37c91 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -56,9 +56,15 @@ typedef struct { pteval_t pte; } pte_t;
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #define MAXMEM		_AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
+#ifdef CONFIG_X86_5LEVEL
+#define VMALLOC_SIZE_TB _AC(16384, UL)
+#define __VMALLOC_BASE	_AC(0xff92000000000000, UL)
+#define VMEMMAP_START	_AC(0xffd2000000000000, UL)
+#else
 #define VMALLOC_SIZE_TB	_AC(32, UL)
 #define __VMALLOC_BASE	_AC(0xffffc90000000000, UL)
 #define VMEMMAP_START	_AC(0xffffea0000000000, UL)
+#endif
 #ifdef CONFIG_RANDOMIZE_MEMORY
 #define VMALLOC_START	vmalloc_base
 #else
diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index 4517d6b93188..1f5bee2c202f 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -26,8 +26,13 @@
 # endif
 #else /* CONFIG_X86_32 */
 # define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
-# define MAX_PHYSADDR_BITS	44
-# define MAX_PHYSMEM_BITS	46
+# ifdef CONFIG_X86_5LEVEL
+#  define MAX_PHYSADDR_BITS	52
+#  define MAX_PHYSMEM_BITS	52
+# else
+#  define MAX_PHYSADDR_BITS	44
+#  define MAX_PHYSMEM_BITS	46
+# endif
 #endif
 
 #endif /* CONFIG_SPARSEMEM */
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
