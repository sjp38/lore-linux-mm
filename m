Message-ID: <485156B8.5070709@gmail.com>
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit
 architectures
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>	<4850070F.6060305@gmail.com>	<20080611121510.d91841a3.akpm@linux-foundation.org>	<485032C8.4010001@gmail.com>	<20080611134323.936063d3.akpm@linux-foundation.org>	<485055FF.9020500@gmail.com>	<20080611155530.099a54d6.akpm@linux-foundation.org>	<4850BE9B.5030504@linux.vnet.ibm.com>	<4850E3BC.308@gmail.com> <20080612020235.29a81d7c.akpm@linux-foundation.org>
In-Reply-To: <20080612020235.29a81d7c.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Jun 2008 19:02:48 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

I've tested the following patch on a i386 box with my usual .config and
everything seems fine. I also tested allmodconfig and some randconfig builds and
I've not seen any evident error.

I'll repeat the tests tonight on a x86_64. Other architectures should be tested
as well...

Patch is against 2.6.25-rc5-mm3.

-Andrea
---
On 32-bit architectures PAGE_ALIGN() truncates 64-bit values to the 32-bit
boundary. For example:

	u64 val = PAGE_ALIGN(size);

always returns a value < 4GB even if size is greater than 4GB.

The problem resides in PAGE_MASK definition (from include/asm-x86/page.h for
example):

#define PAGE_SHIFT      12
#define PAGE_SIZE       (_AC(1,UL) << PAGE_SHIFT)
#define PAGE_MASK       (~(PAGE_SIZE-1))
...
#define PAGE_ALIGN(addr)       (((addr)+PAGE_SIZE-1)&PAGE_MASK)

The "~" is performed on a 32-bit value, so everything in "and" with PAGE_MASK
greater than 4GB will be truncated to the 32-bit boundary. Using the ALIGN()
macro seems to be the right way, because it uses typeof(addr) for the mask.

Also move the PAGE_ALIGN() definitions out of include/asm-*/page.h in
include/linux/mm.h.

See also lkml discussion: http://lkml.org/lkml/2008/6/11/237

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
diff -urpN linux-2.6.25-rc5-mm3/arch/powerpc/boot/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/arch/powerpc/boot/page.h
--- linux-2.6.25-rc5-mm3/arch/powerpc/boot/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/arch/powerpc/boot/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -28,7 +28,4 @@
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 #endif				/* _PPC_BOOT_PAGE_H */
diff -urpN linux-2.6.25-rc5-mm3/arch/sparc64/kernel/iommu_common.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/arch/sparc64/kernel/iommu_common.h
--- linux-2.6.25-rc5-mm3/arch/sparc64/kernel/iommu_common.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/arch/sparc64/kernel/iommu_common.h	2008-06-12 15:26:46.000000000 +0200
@@ -23,7 +23,7 @@
 #define IO_PAGE_SHIFT			13
 #define IO_PAGE_SIZE			(1UL << IO_PAGE_SHIFT)
 #define IO_PAGE_MASK			(~(IO_PAGE_SIZE-1))
-#define IO_PAGE_ALIGN(addr)		(((addr)+IO_PAGE_SIZE-1)&IO_PAGE_MASK)
+#define IO_PAGE_ALIGN(addr)		ALIGN(addr, IO_PAGE_SIZE)
 
 #define IO_TSB_ENTRIES			(128*1024)
 #define IO_TSB_SIZE			(IO_TSB_ENTRIES * 8)
diff -urpN linux-2.6.25-rc5-mm3/drivers/char/random.c linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/char/random.c
--- linux-2.6.25-rc5-mm3/drivers/char/random.c	2008-06-12 12:35:03.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/char/random.c	2008-06-12 15:26:46.000000000 +0200
@@ -236,6 +236,7 @@
 #include <linux/fs.h>
 #include <linux/genhd.h>
 #include <linux/interrupt.h>
+#include <linux/mm.h>
 #include <linux/spinlock.h>
 #include <linux/percpu.h>
 #include <linux/cryptohash.h>
diff -urpN linux-2.6.25-rc5-mm3/drivers/media/video/pvrusb2/pvrusb2-ioread.c linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/media/video/pvrusb2/pvrusb2-ioread.c
--- linux-2.6.25-rc5-mm3/drivers/media/video/pvrusb2/pvrusb2-ioread.c	2008-06-12 12:37:39.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/media/video/pvrusb2/pvrusb2-ioread.c	2008-06-12 17:34:10.000000000 +0200
@@ -22,6 +22,7 @@
 #include "pvrusb2-debug.h"
 #include <linux/errno.h>
 #include <linux/string.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/mutex.h>
 #include <asm/uaccess.h>
diff -urpN linux-2.6.25-rc5-mm3/drivers/media/video/videobuf-core.c linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/media/video/videobuf-core.c
--- linux-2.6.25-rc5-mm3/drivers/media/video/videobuf-core.c	2008-06-12 12:35:15.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/media/video/videobuf-core.c	2008-06-12 17:27:11.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/init.h>
 #include <linux/module.h>
 #include <linux/moduleparam.h>
+#include <linux/mm.h>
 #include <linux/slab.h>
 #include <linux/interrupt.h>
 
diff -urpN linux-2.6.25-rc5-mm3/drivers/pci/intel-iommu.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/pci/intel-iommu.h
--- linux-2.6.25-rc5-mm3/drivers/pci/intel-iommu.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/drivers/pci/intel-iommu.h	2008-06-12 15:26:46.000000000 +0200
@@ -35,7 +35,7 @@
 #define PAGE_SHIFT_4K		(12)
 #define PAGE_SIZE_4K		(1UL << PAGE_SHIFT_4K)
 #define PAGE_MASK_4K		(((u64)-1) << PAGE_SHIFT_4K)
-#define PAGE_ALIGN_4K(addr)	(((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
+#define PAGE_ALIGN_4K(addr)	ALIGN(addr, PAGE_SIZE_4K)
 
 #define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT_4K)
 #define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
diff -urpN linux-2.6.25-rc5-mm3/include/asm-alpha/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-alpha/page.h
--- linux-2.6.25-rc5-mm3/include/asm-alpha/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-alpha/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -80,9 +80,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define __pa(x)			((unsigned long) (x) - PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long) (x) + PAGE_OFFSET))
 #ifndef CONFIG_DISCONTIGMEM
diff -urpN linux-2.6.25-rc5-mm3/include/asm-arm/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page.h
--- linux-2.6.25-rc5-mm3/include/asm-arm/page.h	2008-06-12 12:35:36.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -15,9 +15,6 @@
 #define PAGE_SIZE		(1UL << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 
 #ifndef CONFIG_MMU
diff -urpN linux-2.6.25-rc5-mm3/include/asm-arm/page-nommu.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page-nommu.h
--- linux-2.6.25-rc5-mm3/include/asm-arm/page-nommu.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page-nommu.h	2008-06-12 15:26:46.000000000 +0200
@@ -7,6 +7,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
+
 #ifndef _ASMARM_PAGE_NOMMU_H
 #define _ASMARM_PAGE_NOMMU_H
 
@@ -42,9 +43,6 @@ typedef unsigned long pgprot_t;
 #define __pmd(x)        (x)
 #define __pgprot(x)     (x)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff -urpN linux-2.6.25-rc5-mm3/include/asm-avr32/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-avr32/page.h
--- linux-2.6.25-rc5-mm3/include/asm-avr32/page.h	2008-06-12 12:35:36.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-avr32/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -57,9 +57,6 @@ static inline int get_order(unsigned lon
 
 #endif /* !__ASSEMBLY__ */
 
-/* Align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * The hardware maps the virtual addresses 0x80000000 -> 0x9fffffff
  * permanently to the physical addresses 0x00000000 -> 0x1fffffff when
diff -urpN linux-2.6.25-rc5-mm3/include/asm-blackfin/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-blackfin/page.h
--- linux-2.6.25-rc5-mm3/include/asm-blackfin/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-blackfin/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -51,9 +51,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff -urpN linux-2.6.25-rc5-mm3/include/asm-cris/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-cris/page.h
--- linux-2.6.25-rc5-mm3/include/asm-cris/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-cris/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -60,9 +60,6 @@ typedef struct page *pgtable_t;
 
 #define page_to_phys(page)     __pa((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 
 #endif /* __ASSEMBLY__ */
diff -urpN linux-2.6.25-rc5-mm3/include/asm-frv/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-frv/page.h
--- linux-2.6.25-rc5-mm3/include/asm-frv/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-frv/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -40,9 +40,6 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 #define PTE_MASK	PAGE_MASK
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 #define devmem_is_allowed(pfn)	1
 
 #define __pa(vaddr)		virt_to_phys((void *) (unsigned long) (vaddr))
diff -urpN linux-2.6.25-rc5-mm3/include/asm-h8300/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-h8300/page.h
--- linux-2.6.25-rc5-mm3/include/asm-h8300/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-h8300/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -43,9 +43,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff -urpN linux-2.6.25-rc5-mm3/include/asm-ia64/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-ia64/page.h
--- linux-2.6.25-rc5-mm3/include/asm-ia64/page.h	2008-06-12 12:35:36.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-ia64/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -40,7 +40,6 @@
 
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
 
 #define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
diff -urpN linux-2.6.25-rc5-mm3/include/asm-m32r/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m32r/page.h
--- linux-2.6.25-rc5-mm3/include/asm-m32r/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m32r/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -41,9 +41,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * This handles the memory map.. We could make this a config
  * option, but too many people screw it up, and too few need
diff -urpN linux-2.6.25-rc5-mm3/include/asm-m68k/dvma.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/dvma.h
--- linux-2.6.25-rc5-mm3/include/asm-m68k/dvma.h	2008-06-12 12:38:05.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/dvma.h	2008-06-12 15:26:46.000000000 +0200
@@ -13,7 +13,7 @@
 #define DVMA_PAGE_SHIFT	13
 #define DVMA_PAGE_SIZE	(1UL << DVMA_PAGE_SHIFT)
 #define DVMA_PAGE_MASK	(~(DVMA_PAGE_SIZE-1))
-#define DVMA_PAGE_ALIGN(addr)	(((addr)+DVMA_PAGE_SIZE-1)&DVMA_PAGE_MASK)
+#define DVMA_PAGE_ALIGN(addr)	ALIGN(addr, DVMA_PAGE_SIZE)
 
 extern void dvma_init(void);
 extern int dvma_map_iommu(unsigned long kaddr, unsigned long baddr,
diff -urpN linux-2.6.25-rc5-mm3/include/asm-m68k/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/page.h
--- linux-2.6.25-rc5-mm3/include/asm-m68k/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -103,9 +103,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #endif /* !__ASSEMBLY__ */
 
 #include <asm/page_offset.h>
diff -urpN linux-2.6.25-rc5-mm3/include/asm-m68knommu/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m68knommu/page.h
--- linux-2.6.25-rc5-mm3/include/asm-m68knommu/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-m68knommu/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -43,9 +43,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff -urpN linux-2.6.25-rc5-mm3/include/asm-mips/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-mips/page.h
--- linux-2.6.25-rc5-mm3/include/asm-mips/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-mips/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -134,9 +134,6 @@ typedef struct { unsigned long pgprot; }
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * __pa()/__va() should be used only during mem init.
  */
diff -urpN linux-2.6.25-rc5-mm3/include/asm-mn10300/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-mn10300/page.h
--- linux-2.6.25-rc5-mm3/include/asm-mn10300/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-mn10300/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -61,9 +61,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * This handles the memory map.. We could make this a config
  * option, but too many people screw it up, and too few need
diff -urpN linux-2.6.25-rc5-mm3/include/asm-parisc/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-parisc/page.h
--- linux-2.6.25-rc5-mm3/include/asm-parisc/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-parisc/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -119,10 +119,6 @@ extern int npmem_ranges;
 #define PMD_ENTRY_SIZE	(1UL << BITS_PER_PMD_ENTRY)
 #define PTE_ENTRY_SIZE	(1UL << BITS_PER_PTE_ENTRY)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
-
 #define LINUX_GATEWAY_SPACE     0
 
 /* This governs the relationship between virtual and physical addresses.
diff -urpN linux-2.6.25-rc5-mm3/include/asm-powerpc/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-powerpc/page.h
--- linux-2.6.25-rc5-mm3/include/asm-powerpc/page.h	2008-06-12 12:35:37.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-powerpc/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -119,9 +119,6 @@ extern phys_addr_t kernstart_addr;
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 /*
  * Don't compare things with KERNELBASE or PAGE_OFFSET to test for
  * "kernelness", use is_kernel_addr() - it should do what you want.
diff -urpN linux-2.6.25-rc5-mm3/include/asm-ppc/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-ppc/page.h
--- linux-2.6.25-rc5-mm3/include/asm-ppc/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-ppc/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -43,10 +43,6 @@ typedef unsigned long pte_basic_t;
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
-
 #undef STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
diff -urpN linux-2.6.25-rc5-mm3/include/asm-s390/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-s390/page.h
--- linux-2.6.25-rc5-mm3/include/asm-s390/page.h	2008-06-12 12:35:37.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-s390/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -138,9 +138,6 @@ void arch_alloc_page(struct page *page, 
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)        (((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define __PAGE_OFFSET           0x0UL
 #define PAGE_OFFSET             0x0UL
 #define __pa(x)                 (unsigned long)(x)
diff -urpN linux-2.6.25-rc5-mm3/include/asm-sh/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-sh/page.h
--- linux-2.6.25-rc5-mm3/include/asm-sh/page.h	2008-06-12 12:38:06.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-sh/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -24,9 +24,6 @@
 #define PAGE_MASK	(~(PAGE_SIZE-1))
 #define PTE_MASK	PAGE_MASK
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #if defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
 #define HPAGE_SHIFT	16
 #elif defined(CONFIG_HUGETLB_PAGE_SIZE_256K)
diff -urpN linux-2.6.25-rc5-mm3/include/asm-sparc/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-sparc/page.h
--- linux-2.6.25-rc5-mm3/include/asm-sparc/page.h	2008-06-12 12:35:37.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-sparc/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -136,9 +136,6 @@ BTFIXUPDEF_SETHI(sparc_unmapped_base)
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)  (((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define PAGE_OFFSET	0xf0000000
 #ifndef __ASSEMBLY__
 extern unsigned long phys_base;
diff -urpN linux-2.6.25-rc5-mm3/include/asm-sparc64/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-sparc64/page.h
--- linux-2.6.25-rc5-mm3/include/asm-sparc64/page.h	2008-06-12 12:35:40.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-sparc64/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -110,9 +110,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 /* We used to stick this into a hard-coded global register (%g4)
  * but that does not make sense anymore.
  */
diff -urpN linux-2.6.25-rc5-mm3/include/asm-um/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-um/page.h
--- linux-2.6.25-rc5-mm3/include/asm-um/page.h	2008-06-12 12:38:06.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-um/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -92,9 +92,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x) ((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long uml_physmem;
 
 #define PAGE_OFFSET (uml_physmem)
diff -urpN linux-2.6.25-rc5-mm3/include/asm-x86/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-x86/page.h
--- linux-2.6.25-rc5-mm3/include/asm-x86/page.h	2008-06-12 12:38:07.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-x86/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -31,9 +31,6 @@
 
 #define HUGE_MAX_HSTATE 2
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
 #endif
diff -urpN linux-2.6.25-rc5-mm3/include/asm-xtensa/page.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-xtensa/page.h
--- linux-2.6.25-rc5-mm3/include/asm-xtensa/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/asm-xtensa/page.h	2008-06-12 15:26:46.000000000 +0200
@@ -26,13 +26,11 @@
 
 /*
  * PAGE_SHIFT determines the page size
- * PAGE_ALIGN(x) aligns the pointer to the (next) page boundary
  */
 
 #define PAGE_SHIFT		12
 #define PAGE_SIZE		(__XTENSA_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE - 1) & PAGE_MASK)
 
 #define PAGE_OFFSET		XCHAL_KSEG_CACHED_VADDR
 #define MAX_MEM_PFN		XCHAL_KSEG_SIZE
diff -urpN linux-2.6.25-rc5-mm3/include/linux/mm.h linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/linux/mm.h
--- linux-2.6.25-rc5-mm3/include/linux/mm.h	2008-06-12 12:38:08.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/include/linux/mm.h	2008-06-12 15:26:46.000000000 +0200
@@ -41,6 +41,9 @@ extern unsigned long mmap_min_addr;
 
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
+/* to align the pointer to the (next) page boundary */
+#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way
diff -urpN linux-2.6.25-rc5-mm3/sound/core/info.c linux-2.6.25-rc5-mm3-fix-64-bit-page-align/sound/core/info.c
--- linux-2.6.25-rc5-mm3/sound/core/info.c	2008-06-12 12:35:49.000000000 +0200
+++ linux-2.6.25-rc5-mm3-fix-64-bit-page-align/sound/core/info.c	2008-06-12 18:26:31.000000000 +0200
@@ -21,6 +21,7 @@
 
 #include <linux/init.h>
 #include <linux/time.h>
+#include <linux/mm.h>
 #include <linux/smp_lock.h>
 #include <linux/string.h>
 #include <sound/core.h>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
