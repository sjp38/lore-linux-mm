Message-ID: <4850E3BC.308@gmail.com>
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain> <20080521152948.15001.39361.sendpatchset@localhost.localdomain> <4850070F.6060305@gmail.com> <20080611121510.d91841a3.akpm@linux-foundation.org> <485032C8.4010001@gmail.com> <20080611134323.936063d3.akpm@linux-foundation.org> <485055FF.9020500@gmail.com> <20080611155530.099a54d6.akpm@linux-foundation.org> <4850BE9B.5030504@linux.vnet.ibm.com>
In-Reply-To: <4850BE9B.5030504@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Date: Thu, 12 Jun 2008 10:52:13 +0200 (MEST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> Andrew Morton wrote:
>> #define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
>>
>> ?
>>
>> afaict ALIGN() tries to do the right thing, and if it doesn't, we
>> should fix ALIGN().
>>
> 
> That should do the right thing, provided there are no duplicate ALIGN defintions
> elsewhere
> 
> kernel.h has
> 
> 
> #define ALIGN(x,a)              __ALIGN_MASK(x,(typeof(x))(a)-1)
> #define __ALIGN_MASK(x,mask)    (((x)+(mask))&~(mask))
> 
> Which seems like the correct thing, since we use typeof(x) for (a) - 1.

OK, I'm going to do some builds and tests on my i386 and x86_64 boxes
with the following patch. I'm sure this will break something and I don't
know if moving PAGE_ALIGN() out of asm-*/page.h is the right way.

I'll keep you informed and post an updated version in case I'll find
obvious errors.

-Andrea

---
Properly handle 64-bit values with PAGE_ALIGN() on 32-bit architectures.

For example:

	u64 val = PAGE_ALIGN(size);

is broken on 32-bit architectures if size is greater than 4GB.

The problem resides in PAGE_MASK definition (from include/asm-x86/page.h for
example):

#define PAGE_SHIFT      12
#define PAGE_SIZE       (_AC(1,UL) << PAGE_SHIFT)
#define PAGE_MASK       (~(PAGE_SIZE-1))
...
#define PAGE_ALIGN(addr)       (((addr)+PAGE_SIZE-1)&PAGE_MASK)

The "~" is performed on a 32-bit value, so everything in "and" with PAGE_MASK
greater than 4GB will be truncated to the 32-bit boundary.

Also move the PAGE_ALIGN() definitions out of include/asm-*/page.h in
include/linux/mm.h.

Signed-off-by: Andrea Righi <righi.andrea@gmail.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---
 arch/powerpc/boot/page.h     |    3 ---
 drivers/pci/intel-iommu.h    |    2 +-
 include/asm-alpha/page.h     |    3 ---
 include/asm-arm/page-nommu.h |    4 +---
 include/asm-arm/page.h       |    3 ---
 include/asm-avr32/page.h     |    3 ---
 include/asm-blackfin/page.h  |    3 ---
 include/asm-cris/page.h      |    3 ---
 include/asm-frv/page.h       |    3 ---
 include/asm-h8300/page.h     |    3 ---
 include/asm-ia64/page.h      |    1 -
 include/asm-m32r/page.h      |    3 ---
 include/asm-m68k/page.h      |    3 ---
 include/asm-m68knommu/page.h |    3 ---
 include/asm-mips/page.h      |    3 ---
 include/asm-mn10300/page.h   |    3 ---
 include/asm-parisc/page.h    |    4 ----
 include/asm-powerpc/page.h   |    3 ---
 include/asm-ppc/page.h       |    4 ----
 include/asm-s390/page.h      |    3 ---
 include/asm-sh/page.h        |    3 ---
 include/asm-sparc/page.h     |    3 ---
 include/asm-sparc64/page.h   |    3 ---
 include/asm-um/page.h        |    3 ---
 include/asm-v850/page.h      |    6 ------
 include/asm-x86/page.h       |    3 ---
 include/asm-xtensa/page.h    |    2 --
 include/linux/mm.h           |    4 ++++
 28 files changed, 6 insertions(+), 81 deletions(-)

diff --git a/arch/powerpc/boot/page.h b/arch/powerpc/boot/page.h
index 14eca30..aa42298 100644
--- a/arch/powerpc/boot/page.h
+++ b/arch/powerpc/boot/page.h
@@ -28,7 +28,4 @@
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 #endif				/* _PPC_BOOT_PAGE_H */
diff --git a/drivers/pci/intel-iommu.h b/drivers/pci/intel-iommu.h
index afc0ad9..339da69 100644
--- a/drivers/pci/intel-iommu.h
+++ b/drivers/pci/intel-iommu.h
@@ -35,7 +35,7 @@
 #define PAGE_SHIFT_4K		(12)
 #define PAGE_SIZE_4K		(1UL << PAGE_SHIFT_4K)
 #define PAGE_MASK_4K		(((u64)-1) << PAGE_SHIFT_4K)
-#define PAGE_ALIGN_4K(addr)	(((addr) + PAGE_SIZE_4K - 1) & PAGE_MASK_4K)
+#define PAGE_ALIGN_4K(addr)	ALIGN(addr, PAGE_SIZE_4K)
 
 #define IOVA_PFN(addr)		((addr) >> PAGE_SHIFT_4K)
 #define DMA_32BIT_PFN		IOVA_PFN(DMA_32BIT_MASK)
diff --git a/include/asm-alpha/page.h b/include/asm-alpha/page.h
index 22ff976..0995f9d 100644
--- a/include/asm-alpha/page.h
+++ b/include/asm-alpha/page.h
@@ -80,9 +80,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define __pa(x)			((unsigned long) (x) - PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long) (x) + PAGE_OFFSET))
 #ifndef CONFIG_DISCONTIGMEM
diff --git a/include/asm-arm/page-nommu.h b/include/asm-arm/page-nommu.h
index a1bcad0..ea1cde8 100644
--- a/include/asm-arm/page-nommu.h
+++ b/include/asm-arm/page-nommu.h
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
 
diff --git a/include/asm-arm/page.h b/include/asm-arm/page.h
index 8e05bdb..7c5fc55 100644
--- a/include/asm-arm/page.h
+++ b/include/asm-arm/page.h
@@ -15,9 +15,6 @@
 #define PAGE_SIZE		(1UL << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE-1))
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 
 #ifndef CONFIG_MMU
diff --git a/include/asm-avr32/page.h b/include/asm-avr32/page.h
index cbbc5ca..f805d1c 100644
--- a/include/asm-avr32/page.h
+++ b/include/asm-avr32/page.h
@@ -57,9 +57,6 @@ static inline int get_order(unsigned long size)
 
 #endif /* !__ASSEMBLY__ */
 
-/* Align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * The hardware maps the virtual addresses 0x80000000 -> 0x9fffffff
  * permanently to the physical addresses 0x00000000 -> 0x1fffffff when
diff --git a/include/asm-blackfin/page.h b/include/asm-blackfin/page.h
index c7db022..344f6a8 100644
--- a/include/asm-blackfin/page.h
+++ b/include/asm-blackfin/page.h
@@ -51,9 +51,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-cris/page.h b/include/asm-cris/page.h
index c45bb1e..d19272b 100644
--- a/include/asm-cris/page.h
+++ b/include/asm-cris/page.h
@@ -60,9 +60,6 @@ typedef struct page *pgtable_t;
 
 #define page_to_phys(page)     __pa((((page) - mem_map) << PAGE_SHIFT) + PAGE_OFFSET)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 
 #endif /* __ASSEMBLY__ */
diff --git a/include/asm-frv/page.h b/include/asm-frv/page.h
index c2c1e89..bd9c220 100644
--- a/include/asm-frv/page.h
+++ b/include/asm-frv/page.h
@@ -40,9 +40,6 @@ typedef struct page *pgtable_t;
 #define __pgprot(x)	((pgprot_t) { (x) } )
 #define PTE_MASK	PAGE_MASK
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 #define devmem_is_allowed(pfn)	1
 
 #define __pa(vaddr)		virt_to_phys((void *) (unsigned long) (vaddr))
diff --git a/include/asm-h8300/page.h b/include/asm-h8300/page.h
index d6a3eaf..0b6acf0 100644
--- a/include/asm-h8300/page.h
+++ b/include/asm-h8300/page.h
@@ -43,9 +43,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-ia64/page.h b/include/asm-ia64/page.h
index 36f3932..5f271bc 100644
--- a/include/asm-ia64/page.h
+++ b/include/asm-ia64/page.h
@@ -40,7 +40,6 @@
 
 #define PAGE_SIZE		(__IA64_UL_CONST(1) << PAGE_SHIFT)
 #define PAGE_MASK		(~(PAGE_SIZE - 1))
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
 
 #define PERCPU_PAGE_SHIFT	16	/* log2() of max. size of per-CPU area */
 #define PERCPU_PAGE_SIZE	(__IA64_UL_CONST(1) << PERCPU_PAGE_SHIFT)
diff --git a/include/asm-m32r/page.h b/include/asm-m32r/page.h
index 8a677f3..c933308 100644
--- a/include/asm-m32r/page.h
+++ b/include/asm-m32r/page.h
@@ -41,9 +41,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * This handles the memory map.. We could make this a config
  * option, but too many people screw it up, and too few need
diff --git a/include/asm-m68k/page.h b/include/asm-m68k/page.h
index 880c2cb..a34b8ba 100644
--- a/include/asm-m68k/page.h
+++ b/include/asm-m68k/page.h
@@ -103,9 +103,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #endif /* !__ASSEMBLY__ */
 
 #include <asm/page_offset.h>
diff --git a/include/asm-m68knommu/page.h b/include/asm-m68knommu/page.h
index 1e82ebb..3a1ede4 100644
--- a/include/asm-m68knommu/page.h
+++ b/include/asm-m68knommu/page.h
@@ -43,9 +43,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x)	((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long memory_start;
 extern unsigned long memory_end;
 
diff --git a/include/asm-mips/page.h b/include/asm-mips/page.h
index 8735aa0..dd1cc0a 100644
--- a/include/asm-mips/page.h
+++ b/include/asm-mips/page.h
@@ -134,9 +134,6 @@ typedef struct { unsigned long pgprot; } pgprot_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * __pa()/__va() should be used only during mem init.
  */
diff --git a/include/asm-mn10300/page.h b/include/asm-mn10300/page.h
index 124971b..8288e12 100644
--- a/include/asm-mn10300/page.h
+++ b/include/asm-mn10300/page.h
@@ -61,9 +61,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
 /*
  * This handles the memory map.. We could make this a config
  * option, but too many people screw it up, and too few need
diff --git a/include/asm-parisc/page.h b/include/asm-parisc/page.h
index 27d50b8..c3941f0 100644
--- a/include/asm-parisc/page.h
+++ b/include/asm-parisc/page.h
@@ -119,10 +119,6 @@ extern int npmem_ranges;
 #define PMD_ENTRY_SIZE	(1UL << BITS_PER_PMD_ENTRY)
 #define PTE_ENTRY_SIZE	(1UL << BITS_PER_PTE_ENTRY)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
-
 #define LINUX_GATEWAY_SPACE     0
 
 /* This governs the relationship between virtual and physical addresses.
diff --git a/include/asm-powerpc/page.h b/include/asm-powerpc/page.h
index cffdf0e..e088545 100644
--- a/include/asm-powerpc/page.h
+++ b/include/asm-powerpc/page.h
@@ -119,9 +119,6 @@ extern phys_addr_t kernstart_addr;
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
 /*
  * Don't compare things with KERNELBASE or PAGE_OFFSET to test for
  * "kernelness", use is_kernel_addr() - it should do what you want.
diff --git a/include/asm-ppc/page.h b/include/asm-ppc/page.h
index 37e4756..6a53965 100644
--- a/include/asm-ppc/page.h
+++ b/include/asm-ppc/page.h
@@ -43,10 +43,6 @@ typedef unsigned long pte_basic_t;
 /* align addr on a size boundary - adjust address up if needed */
 #define _ALIGN(addr,size)     _ALIGN_UP(addr,size)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	_ALIGN(addr, PAGE_SIZE)
-
-
 #undef STRICT_MM_TYPECHECKS
 
 #ifdef STRICT_MM_TYPECHECKS
diff --git a/include/asm-s390/page.h b/include/asm-s390/page.h
index 12fd9c4..991ba93 100644
--- a/include/asm-s390/page.h
+++ b/include/asm-s390/page.h
@@ -138,9 +138,6 @@ void arch_alloc_page(struct page *page, int order);
 
 #endif /* !__ASSEMBLY__ */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)        (((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define __PAGE_OFFSET           0x0UL
 #define PAGE_OFFSET             0x0UL
 #define __pa(x)                 (unsigned long)(x)
diff --git a/include/asm-sh/page.h b/include/asm-sh/page.h
index 304c30b..5dc01d2 100644
--- a/include/asm-sh/page.h
+++ b/include/asm-sh/page.h
@@ -22,9 +22,6 @@
 #define PAGE_MASK	(~(PAGE_SIZE-1))
 #define PTE_MASK	PAGE_MASK
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #if defined(CONFIG_HUGETLB_PAGE_SIZE_64K)
 #define HPAGE_SHIFT	16
 #elif defined(CONFIG_HUGETLB_PAGE_SIZE_256K)
diff --git a/include/asm-sparc/page.h b/include/asm-sparc/page.h
index 6aa9e4c..a5029f2 100644
--- a/include/asm-sparc/page.h
+++ b/include/asm-sparc/page.h
@@ -136,9 +136,6 @@ BTFIXUPDEF_SETHI(sparc_unmapped_base)
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)  (((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #define PAGE_OFFSET	0xf0000000
 #ifndef __ASSEMBLY__
 extern unsigned long phys_base;
diff --git a/include/asm-sparc64/page.h b/include/asm-sparc64/page.h
index 93f0881..c36a4ba 100644
--- a/include/asm-sparc64/page.h
+++ b/include/asm-sparc64/page.h
@@ -110,9 +110,6 @@ typedef struct page *pgtable_t;
 
 #endif /* !(__ASSEMBLY__) */
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 /* We used to stick this into a hard-coded global register (%g4)
  * but that does not make sense anymore.
  */
diff --git a/include/asm-um/page.h b/include/asm-um/page.h
index 916e1a6..335c573 100644
--- a/include/asm-um/page.h
+++ b/include/asm-um/page.h
@@ -92,9 +92,6 @@ typedef struct page *pgtable_t;
 #define __pgd(x) ((pgd_t) { (x) } )
 #define __pgprot(x)	((pgprot_t) { (x) } )
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 extern unsigned long uml_physmem;
 
 #define PAGE_OFFSET (uml_physmem)
diff --git a/include/asm-v850/page.h b/include/asm-v850/page.h
index 74a539a..3f4fd57 100644
--- a/include/asm-v850/page.h
+++ b/include/asm-v850/page.h
@@ -16,7 +16,6 @@
 
 #include <asm/machdep.h>
 
-
 #define PAGE_SHIFT	12
 #define PAGE_SIZE       (1UL << PAGE_SHIFT)
 #define PAGE_MASK       (~(PAGE_SIZE-1))
@@ -93,11 +92,6 @@ typedef unsigned long pgprot_t;
 
 #endif /* !__ASSEMBLY__ */
 
-
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr) + PAGE_SIZE - 1) & PAGE_MASK)
-
-
 /* No current v850 processor has virtual memory.  */
 #define __virt_to_phys(addr)	(addr)
 #define __phys_to_virt(addr)	(addr)
diff --git a/include/asm-x86/page.h b/include/asm-x86/page.h
index dc936dd..05da537 100644
--- a/include/asm-x86/page.h
+++ b/include/asm-x86/page.h
@@ -29,9 +29,6 @@
 #define HPAGE_MASK		(~(HPAGE_SIZE - 1))
 #define HUGETLB_PAGE_ORDER	(HPAGE_SHIFT - PAGE_SHIFT)
 
-/* to align the pointer to the (next) page boundary */
-#define PAGE_ALIGN(addr)	(((addr)+PAGE_SIZE-1)&PAGE_MASK)
-
 #ifndef __ASSEMBLY__
 #include <linux/types.h>
 #endif
diff --git a/include/asm-xtensa/page.h b/include/asm-xtensa/page.h
index 80a6ae0..11f7dc2 100644
--- a/include/asm-xtensa/page.h
+++ b/include/asm-xtensa/page.h
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
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c31a9cd..f767a8f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -9,6 +9,7 @@
 #include <linux/list.h>
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
+#include <linux/kernel.h>
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
@@ -41,6 +42,9 @@ extern unsigned long mmap_min_addr;
 
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
+/* to align the pointer to the (next) page boundary */
+#define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
+
 /*
  * Linux kernel virtual memory manager primitives.
  * The idea being to have a "virtual" mm in the same way

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
