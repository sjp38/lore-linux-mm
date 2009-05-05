Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 62DD26B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 17:28:33 -0400 (EDT)
Date: Tue, 5 May 2009 17:28:56 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH] x86: 46 bit PAE support
Message-ID: <20090505172856.6820db22@cuia.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, mingo@redhat.com, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

Extend the maximum addressable memory on x86-64 from 2^44 to
2^46 bytes. This requires some shuffling around of the vmalloc
and virtual memmap memory areas, to keep them away from the
direct mapping of up to 64TB of physical memory.

This patch also introduces a guard hole between the vmalloc
area and the virtual memory map space.  There's really no
good reason why we wouldn't have a guard hole there.

Signed-off-by: Rik van Riel <riel@redhat.com>

---
Testing: booted it on an x86-64 system with 6GB RAM.  Did you really think
I had access to a system with 64TB of RAM? :)

diff --git a/Documentation/x86/x86_64/mm.txt b/Documentation/x86/x86_64/mm.txt
index 29b52b1..5394132 100644
--- a/Documentation/x86/x86_64/mm.txt
+++ b/Documentation/x86/x86_64/mm.txt
@@ -6,10 +6,11 @@ Virtual memory map with 4 level page tables:
 0000000000000000 - 00007fffffffffff (=47 bits) user space, different per mm
 hole caused by [48:63] sign extension
 ffff800000000000 - ffff80ffffffffff (=40 bits) guard hole
-ffff880000000000 - ffffc0ffffffffff (=57 TB) direct mapping of all phys. memory
-ffffc10000000000 - ffffc1ffffffffff (=40 bits) hole
-ffffc20000000000 - ffffe1ffffffffff (=45 bits) vmalloc/ioremap space
-ffffe20000000000 - ffffe2ffffffffff (=40 bits) virtual memory map (1TB)
+ffff880000000000 - ffffc8ffffffffff (=64 TB) direct mapping of all phys. memory
+ffffc80000000000 - ffffc8ffffffffff (=40 bits) hole
+ffffc90000000000 - ffffe8ffffffffff (=45 bits) vmalloc/ioremap space
+ffffe90000000000 - ffffe9ffffffffff (=40 bits) hole
+ffffea0000000000 - ffffeaffffffffff (=40 bits) virtual memory map (1TB)
 ... unused hole ...
 ffffffff80000000 - ffffffffa0000000 (=512 MB)  kernel text mapping, from phys 0
 ffffffffa0000000 - fffffffffff00000 (=1536 MB) module mapping space
diff --git a/arch/x86/include/asm/page_64_types.h b/arch/x86/include/asm/page_64_types.h
index d38c91b..786306c 100644
--- a/arch/x86/include/asm/page_64_types.h
+++ b/arch/x86/include/asm/page_64_types.h
@@ -47,7 +47,7 @@
 #define __START_KERNEL		(__START_KERNEL_map + __PHYSICAL_START)
 #define __START_KERNEL_map	_AC(0xffffffff80000000, UL)
 
-/* See Documentation/x86_64/mm.txt for a description of the memory map. */
+/* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #define __PHYSICAL_MASK_SHIFT	46
 #define __VIRTUAL_MASK_SHIFT	48
 
diff --git a/arch/x86/include/asm/pgtable_64_types.h b/arch/x86/include/asm/pgtable_64_types.h
index fbf42b8..766ea16 100644
--- a/arch/x86/include/asm/pgtable_64_types.h
+++ b/arch/x86/include/asm/pgtable_64_types.h
@@ -51,11 +51,11 @@ typedef struct { pteval_t pte; } pte_t;
 #define PGDIR_SIZE	(_AC(1, UL) << PGDIR_SHIFT)
 #define PGDIR_MASK	(~(PGDIR_SIZE - 1))
 
-
+/* See Documentation/x86/x86_64/mm.txt for a description of the memory map. */
 #define MAXMEM		 _AC(__AC(1, UL) << MAX_PHYSMEM_BITS, UL)
-#define VMALLOC_START    _AC(0xffffc20000000000, UL)
-#define VMALLOC_END      _AC(0xffffe1ffffffffff, UL)
-#define VMEMMAP_START	 _AC(0xffffe20000000000, UL)
+#define VMALLOC_START    _AC(0xffffc90000000000, UL)
+#define VMALLOC_END      _AC(0xffffe8ffffffffff, UL)
+#define VMEMMAP_START	 _AC(0xffffea0000000000, UL)
 #define MODULES_VADDR    _AC(0xffffffffa0000000, UL)
 #define MODULES_END      _AC(0xffffffffff000000, UL)
 #define MODULES_LEN   (MODULES_END - MODULES_VADDR)
diff --git a/arch/x86/include/asm/sparsemem.h b/arch/x86/include/asm/sparsemem.h
index e3cc3c0..4517d6b 100644
--- a/arch/x86/include/asm/sparsemem.h
+++ b/arch/x86/include/asm/sparsemem.h
@@ -27,7 +27,7 @@
 #else /* CONFIG_X86_32 */
 # define SECTION_SIZE_BITS	27 /* matt - 128 is convenient right now */
 # define MAX_PHYSADDR_BITS	44
-# define MAX_PHYSMEM_BITS	44 /* Can be max 45 bits */
+# define MAX_PHYSMEM_BITS	46
 #endif
 
 #endif /* CONFIG_SPARSEMEM */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
