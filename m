Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1ADD86B0293
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:55:49 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id g1so737239626pgn.3
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:55:49 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id 201si44787485pfc.120.2016.12.26.17.55.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:55:48 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 18/29] x86/mm: define virtual memory map for 5-level paging
Date: Tue, 27 Dec 2016 04:54:02 +0300
Message-Id: <20161227015413.187403-19-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
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
 Documentation/x86/x86_64/mm.txt         | 33 ++++++++++++++++++++++++++++++---
 arch/x86/Kconfig                        |  1 +
 arch/x86/include/asm/kasan.h            |  9 ++++++---
 arch/x86/include/asm/page_64_types.h    | 10 ++++++++++
 arch/x86/include/asm/pgtable_64_types.h |  6 ++++++
 arch/x86/include/asm/sparsemem.h        |  9 +++++++--
 6 files changed, 60 insertions(+), 8 deletions(-)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 5724092db811..0303a47b82f8 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -4,7 +4,7 @@
 Virtual memory map with 4 level page tables:
 
 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
-hole caused by [48:63] sign extension
+hole caused by [47:63] sign extension
 ffff800000000000 - ffff87ffffffffff (=43 bits) guard hole, reserved for hypervisor
 ffff880000000000 - ffffc7ffffffffff (=64 TB) direct mapping of all phys. memory
 ffffc80000000000 - ffffc8ffffffffff (=40 bits) hole
@@ -23,12 +23,39 @@ ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
 ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
 ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
 
+Virtual memory map with 5 level page tables:
+
+0000000000000000 - 00ffffffffffffff (=56 bits) user space, different per mm
+hole caused by [56:63] sign extension
+ff00000000000000 - ff0fffffffffffff (=52 bits) guard hole, reserved for hypervisor
+ff10000000000000 - ff8fffffffffffff (=55 bits) direct mapping of all phys. memory
+ff90000000000000 - ff91ffffffffffff (=49 bits) hole
+ff92000000000000 - ffd1ffffffffffff (=54 bits) vmalloc/ioremap space
+ffd2000000000000 - ffd3ffffffffffff (=49 bits) hole
+ffd4000000000000 - ffd5ffffffffffff (=49 bits) virtual memory map (512TB)
+... unused hole ...
+ffd8000000000000 - fff7ffffffffffff (=53 bits) kasan shadow memory (8PB)
+... unused hole ...
+fffe000000000000 - fffe007fffffffff (=39 bits) %esp fixup stacks
+... unused hole ...
+ffffffef00000000 - fffffffeffffffff (=64 GB) EFI region mapping space
+... unused hole ...
+ffffffff80000000 - ffffffff9fffffff (=512 MB)  kernel text mapping, from phys 0
+ffffffffa0000000 - ffffffffff5fffff (=1526 MB) module mapping space
+ffffffffff600000 - ffffffffffdfffff (=8 MB) vsyscalls
+ffffffffffe00000 - ffffffffffffffff (=2 MB) unused hole
+
+Architecture defines a 64-bit virtual address. Implementations can support
+less. Currently supported are 48- and 57-bit virtual addresses. Bits 63
+through to the most-significant implemented bit are set to either all ones
+or all zero. This causes hole between user space and kernel addresses.
+
 The direct mapping covers all memory in the system up to the highest
 memory address (this means in some cases it can also include PCI memory
 holes).
 
-vmalloc space is lazily synchronized into the different PML4 pages of
-the processes using the page fault handler, with init_level4_pgt as
+vmalloc space is lazily synchronized into the different PML4/PML5 pages of
+the processes using the page fault handler, with init_top_pgt as
 reference.
 
 Current X86-64 implementations support up to 46 bits of address space (64 TB),
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index e487493bbd47..3d51256a9e61 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -285,6 +285,7 @@ config ARCH_SUPPORTS_DEBUG_PAGEALLOC
 config KASAN_SHADOW_OFFSET
 	hex
 	depends on KASAN
+	default 0xdff8000000000000 if X86_5LEVEL
 	default 0xdffffc0000000000
 
 config HAVE_INTEL_TXT
diff --git a/arch/x86/include/asm/kasan.h b/arch/x86/include/asm/kasan.h
index 1410b567ecde..f527b02a0ee3 100644
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
+ * 56 bits for kernel address -> (56 - 3) bits for shadow
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
index 0b2797e5083c..00dc0c2b456e 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -56,9 +56,15 @@ typedef struct { pteval_t pte; } pte_t;
 
 /* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #define MAXMEM		_AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
+#ifdef CONFIG_X86_5LEVEL
+#define VMALLOC_SIZE_TB _AC(16384, UL)
+#define __VMALLOC_BASE	_AC(0xff92000000000000, UL)
+#define __VMEMMAP_BASE	_AC(0xffd4000000000000, UL)
+#else
 #define VMALLOC_SIZE_TB	_AC(32, UL)
 #define __VMALLOC_BASE	_AC(0xffffc90000000000, UL)
 #define __VMEMMAP_BASE	_AC(0xffffea0000000000, UL)
+#endif
 #ifdef CONFIG_RANDOMIZE_MEMORY
 #define VMALLOC_START	vmalloc_base
 #define VMEMMAP_START	vmemmap_base
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
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
