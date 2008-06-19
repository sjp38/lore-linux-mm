Message-ID: <485A81F7.9010905@gmail.com>
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: [PATCH -mm] PAGE_ALIGN(): correctly handle 64-bit values on 32-bit
 architectures (v3)
References: <1213543436-15254-1-git-send-email-righi.andrea@gmail.com> <18517.39513.867328.171299@cargo.ozlabs.ibm.com>
In-Reply-To: <18517.39513.867328.171299@cargo.ozlabs.ibm.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 19 Jun 2008 17:57:43 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@samba.org>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, Sudhir Kumar <skumar@linux.vnet.ibm.com>, yamamoto@valinux.co.jp, menage@google.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 32-bit architectures PAGE_ALIGN() truncates 64-bit values to the
32-bit boundary. For example:

	u64 val = PAGE_ALIGN(size);

always returns a value < 4GB even if size is greater than 4GB.

The problem resides in PAGE_MASK definition (from include/asm-x86/page.h
for example):

 #define PAGE_SHIFT      12
 #define PAGE_SIZE       (_AC(1,UL) << PAGE_SHIFT)
 #define PAGE_MASK       (~(PAGE_SIZE-1))
 ...
 #define PAGE_ALIGN(addr)       (((addr)+PAGE_SIZE-1)&PAGE_MASK)

The "~" is performed on a 32-bit value, so everything in "and" with
PAGE_MASK greater than 4GB will be truncated to the 32-bit boundary.

Using the ALIGN() macro seems to be the right way, because it uses
typeof(addr) for the mask.

See also lkml discussion: http://lkml.org/lkml/2008/6/11/237

Changelog: (v2 -> v3)
  - do not move PAGE_ALIGN() definition in linux/mm.h, fixing and
    leaving it in each page.h seems to be a safer solution right now

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
diff -urpN linux-2.6.26-rc5-mm3/arch/sparc64/kernel/iommu_common.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/arch/sparc64/kernel/iommu_common.h
--- linux-2.6.26-rc5-mm3/arch/sparc64/kernel/iommu_common.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/arch/sparc64/kernel/iommu_common.h	2008-06-19 17:04:52.000000000 +0200
@@ -23,7 +23,7 @@
 #define IO_PAGE_SHIFT			13
 #define IO_PAGE_SIZE			(1UL << IO_PAGE_SHIFT)
 #define IO_PAGE_MASK			(~(IO_PAGE_SIZE-1))
-#define IO_PAGE_ALIGN(addr)		(((addr)+IO_PAGE_SIZE-1)&IO_PAGE_MASK)
+#define IO_PAGE_ALIGN(addr)		ALIGN(addr, IO_PAGE_SIZE)
 
 #define IO_TSB_ENTRIES			(128*1024)
 #define IO_TSB_SIZE			(IO_TSB_ENTRIES * 8)
diff -urpN linux-2.6.26-rc5-mm3/drivers/pci/intel-iommu.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/drivers/pci/intel-iommu.h
--- linux-2.6.26-rc5-mm3/drivers/pci/intel-iommu.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/drivers/pci/intel-iommu.h	2008-06-19 17:05:22.000000000 +0200
@@ -35,7 +35,7 @@
 #define PAGE_SHIFT_4K		(12)
 #define PAGE_SIZE_4K		(1UL << PAGE_SHIFT_4K)
 #define PAGE_MASK_4K		(((u64)-1) << PAGE_SHIFT_4K)
-#define PAGE_ALIGN_4K(addr)	(((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
+#define PAGE_ALIGN_4K(addr)	ALIGN(addr, PAGE_SIZE_4K)
 
 #define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT_4K)
 #define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
diff -urpN linux-2.6.26-rc5-mm3/include/asm-alpha/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-alpha/page.h
--- linux-2.6.26-rc5-mm3/include/asm-alpha/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-alpha/page.h	2008-06-19 17:07:32.000000000 +0200
@@ -81,7 +81,7 @@ typedef struct page *pgtable_t;
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #define __pa(x)			((unsigned long) (x) - PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long) (x) + PAGE_OFFSET))
diff -urpN linux-2.6.26-rc5-mm3/include/asm-arm/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page.h
--- linux-2.6.26-rc5-mm3/include/asm-arm/page.h	2008-06-12 12:35:36.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page.h	2008-06-19 17:08:04.000000000 +0200
@@ -16,7 +16,7 @@
 #define PAGE_MASK		(~(PAGE_SIZE-1))
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #ifndef __ASSEMBLY__
 
diff -urpN linux-2.6.26-rc5-mm3/include/asm-arm/page-nommu.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page-nommu.h
--- linux-2.6.26-rc5-mm3/include/asm-arm/page-nommu.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-arm/page-nommu.h	2008-06-19 17:08:40.000000000 +0200
@@ -43,7 +43,7 @@ typedef unsigned long pgprot_t;
 #define __pgprot(x)     (x)
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 extern unsigned long memory_start;
 extern unsigned long memory_end;
diff -urpN linux-2.6.26-rc5-mm3/include/asm-avr32/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-avr32/page.h
--- linux-2.6.26-rc5-mm3/include/asm-avr32/page.h	2008-06-12 12:35:36.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-avr32/page.h	2008-06-19 17:09:30.000000000 +0200
@@ -58,7 +58,7 @@ static inline int get_order(unsigned lon
 #endif /* !__ASSEMBLY__ */
 
 /* Align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 /*
  * The hardware maps the virtual addresses 0x80000000 -> 0x9fffffff
diff -urpN linux-2.6.26-rc5-mm3/include/asm-blackfin/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-blackfin/page.h
--- linux-2.6.26-rc5-mm3/include/asm-blackfin/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-blackfin/page.h	2008-06-19 17:09:52.000000000 +0200
@@ -52,7 +52,7 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 extern unsigned long memory_start;
 extern unsigned long memory_end;
diff -urpN linux-2.6.26-rc5-mm3/include/asm-cris/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-cris/page.h
--- linux-2.6.26-rc5-mm3/include/asm-cris/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-cris/page.h	2008-06-19 17:10:08.000000000 +0200
@@ -61,7 +61,7 @@ typedef struct page *pgtable_t;
 #define page_to_phys(page)     __pa((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #ifndef __ASSEMBLY__
 
diff -urpN linux-2.6.26-rc5-mm3/include/asm-frv/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-frv/page.h
--- linux-2.6.26-rc5-mm3/include/asm-frv/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-frv/page.h	2008-06-19 17:10:27.000000000 +0200
@@ -41,7 +41,7 @@ typedef struct page *pgtable_t;
 #define PTE_MASK	PAGE_MASK
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #define devmem_is_allowed(pfn)	1
 
diff -urpN linux-2.6.26-rc5-mm3/include/asm-h8300/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-h8300/page.h
--- linux-2.6.26-rc5-mm3/include/asm-h8300/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-h8300/page.h	2008-06-19 17:10:50.000000000 +0200
@@ -44,7 +44,7 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 extern unsigned long memory_start;
 extern unsigned long memory_end;
diff -urpN linux-2.6.26-rc5-mm3/include/asm-ia64/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-ia64/page.h
--- linux-2.6.26-rc5-mm3/include/asm-ia64/page.h	2008-06-12 12:35:36.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-ia64/page.h	2008-06-19 17:11:09.000000000 +0200
@@ -40,7 +40,7 @@
 
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
diff -urpN linux-2.6.26-rc5-mm3/include/asm-m32r/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m32r/page.h
--- linux-2.6.26-rc5-mm3/include/asm-m32r/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m32r/page.h	2008-06-19 17:11:25.000000000 +0200
@@ -42,7 +42,7 @@ typedef struct page *pgtable_t;
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 /*
  * This handles the memory map.. We could make this a config
diff -urpN linux-2.6.26-rc5-mm3/include/asm-m68k/dvma.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/dvma.h
--- linux-2.6.26-rc5-mm3/include/asm-m68k/dvma.h	2008-06-12 12:38:05.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/dvma.h	2008-06-19 17:11:58.000000000 +0200
@@ -13,7 +13,7 @@
 #define DVMA_PAGE_SHIFT	13
 #define DVMA_PAGE_SIZE	(1UL << DVMA_PAGE_SHIFT)
 #define DVMA_PAGE_MASK	(~(DVMA_PAGE_SIZE-1))
-#define DVMA_PAGE_ALIGN(addr)	(((addr)+DVMA_PAGE_SIZE-1)&DVMA_PAGE_MASK)
+#define DVMA_PAGE_ALIGN(addr)	ALIGN(addr, DVMA_PAGE_SIZE)
 
 extern void dvma_init(void);
 extern int dvma_map_iommu(unsigned long kaddr, unsigned long baddr,
diff -urpN linux-2.6.26-rc5-mm3/include/asm-m68k/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/page.h
--- linux-2.6.26-rc5-mm3/include/asm-m68k/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m68k/page.h	2008-06-19 17:12:57.000000000 +0200
@@ -104,7 +104,7 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #endif /* !__ASSEMBLY__ */
 
diff -urpN linux-2.6.26-rc5-mm3/include/asm-m68knommu/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m68knommu/page.h
--- linux-2.6.26-rc5-mm3/include/asm-m68knommu/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-m68knommu/page.h	2008-06-19 17:12:37.000000000 +0200
@@ -44,7 +44,7 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 extern unsigned long memory_start;
 extern unsigned long memory_end;
diff -urpN linux-2.6.26-rc5-mm3/include/asm-mips/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-mips/page.h
--- linux-2.6.26-rc5-mm3/include/asm-mips/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-mips/page.h	2008-06-19 17:13:17.000000000 +0200
@@ -135,7 +135,7 @@ typedef struct { unsigned long pgprot; }
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 /*
  * __pa()/__va() should be used only during mem init.
diff -urpN linux-2.6.26-rc5-mm3/include/asm-mn10300/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-mn10300/page.h
--- linux-2.6.26-rc5-mm3/include/asm-mn10300/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-mn10300/page.h	2008-06-19 17:13:34.000000000 +0200
@@ -62,7 +62,7 @@ typedef struct page *pgtable_t;
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 /*
  * This handles the memory map.. We could make this a config
diff -urpN linux-2.6.26-rc5-mm3/include/asm-parisc/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-parisc/page.h
--- linux-2.6.26-rc5-mm3/include/asm-parisc/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-parisc/page.h	2008-06-19 17:13:48.000000000 +0200
@@ -120,7 +120,7 @@ extern int npmem_ranges;
 #define PTE_ENTRY_SIZE	(1UL << BITS_PER_PTE_ENTRY)
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 
 #define LINUX_GATEWAY_SPACE     0
diff -urpN linux-2.6.26-rc5-mm3/include/asm-s390/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-s390/page.h
--- linux-2.6.26-rc5-mm3/include/asm-s390/page.h	2008-06-12 12:35:37.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-s390/page.h	2008-06-19 17:14:45.000000000 +0200
@@ -139,7 +139,7 @@ void arch_alloc_page(struct page *page, 
 #endif /* !__ASSEMBLY__ */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)        (((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)        ALIGN(addr, PAGE_SIZE)
 
 #define __PAGE_OFFSET           0x0UL
 #define PAGE_OFFSET             0x0UL
diff -urpN linux-2.6.26-rc5-mm3/include/asm-sh/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-sh/page.h
--- linux-2.6.26-rc5-mm3/include/asm-sh/page.h	2008-06-12 12:38:06.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-sh/page.h	2008-06-19 17:15:01.000000000 +0200
@@ -25,7 +25,7 @@
 #define PTE_MASK	PAGE_MASK
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #if defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
 #define HPAGE_SHIFT	16
diff -urpN linux-2.6.26-rc5-mm3/include/asm-sparc/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-sparc/page.h
--- linux-2.6.26-rc5-mm3/include/asm-sparc/page.h	2008-06-12 12:35:37.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-sparc/page.h	2008-06-19 17:15:18.000000000 +0200
@@ -137,7 +137,7 @@ BTFIXUPDEF_SETHI(sparc_unmapped_base)
 #endif /* !(__ASSEMBLY__) */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)  (((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)  ALIGN(addr, PAGE_SIZE)
 
 #define PAGE_OFFSET	0xf0000000
 #ifndef __ASSEMBLY__
diff -urpN linux-2.6.26-rc5-mm3/include/asm-sparc64/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-sparc64/page.h
--- linux-2.6.26-rc5-mm3/include/asm-sparc64/page.h	2008-06-12 12:35:40.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-sparc64/page.h	2008-06-19 17:15:33.000000000 +0200
@@ -111,7 +111,7 @@ typedef struct page *pgtable_t;
 #endif /* !(__ASSEMBLY__) */
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 /* We used to stick this into a hard-coded global register (%g4)
  * but that does not make sense anymore.
diff -urpN linux-2.6.26-rc5-mm3/include/asm-um/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-um/page.h
--- linux-2.6.26-rc5-mm3/include/asm-um/page.h	2008-06-12 12:38:06.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-um/page.h	2008-06-19 17:15:48.000000000 +0200
@@ -93,7 +93,7 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 extern unsigned long uml_physmem;
 
diff -urpN linux-2.6.26-rc5-mm3/include/asm-x86/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-x86/page.h
--- linux-2.6.26-rc5-mm3/include/asm-x86/page.h	2008-06-12 12:38:07.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-x86/page.h	2008-06-19 17:16:04.000000000 +0200
@@ -32,7 +32,7 @@
 #define HUGE_MAX_HSTATE 2
 
 /* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
diff -urpN linux-2.6.26-rc5-mm3/include/asm-xtensa/page.h linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-xtensa/page.h
--- linux-2.6.26-rc5-mm3/include/asm-xtensa/page.h	2008-04-17 04:49:44.000000000 +0200
+++ linux-2.6.26-rc5-mm3-fix-64-bit-page-align/include/asm-xtensa/page.h	2008-06-19 17:16:28.000000000 +0200
@@ -32,7 +32,7 @@
 #define PAGE_SHIFT		12
 #define PAGE_SIZE		(__XTENSA_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE - 1) & PAGE_MASK)
+#define PAGE_ALIGN(addr)	ALIGN(addr, PAGE_SIZE)
 
 #define PAGE_OFFSET		XCHAL_KSEG_CACHED_VADDR
 #define MAX_MEM_PFN		XCHAL_KSEG_SIZE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
