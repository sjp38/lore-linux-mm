Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 08FAD6B0089
	for <linux-mm@kvack.org>; Fri,  3 Dec 2010 01:22:51 -0500 (EST)
Date: Fri, 3 Dec 2010 15:21:46 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] mm: make ioremap_prot() take a pgprot.
Message-ID: <20101203062146.GA1114@linux-sh.org>
References: <20101102203102.GA12723@linux-sh.org> <20101202151901.e34e4e62.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101202151901.e34e4e62.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Mikael Starvik <starvik@axis.com>, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Metcalf <cmetcalf@tilera.com>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 02, 2010 at 03:19:01PM -0800, Andrew Morton wrote:
> On Wed, 3 Nov 2010 05:31:03 +0900
> Paul Mundt <lethal@linux-sh.org> wrote:
> 
> > The current definition of ioremap_prot() takes an unsigned long for the
> > page flags and then converts to/from a pgprot as necessary. This is
> > unfortunately not sufficient for the SH-X2 TLB case which has a 64-bit
> > pgprot and a 32-bit unsigned long.
> > 
> > An inspection of the tree shows that tile and cris also have their
> > own equivalent routines that are using the pgprot_t but do not set
> > HAVE_IOREMAP_PROT, both of which could trivially be adapted.
> > 
> > After cris/tile are updated there would also be enough critical mass to
> > move the powerpc devm_ioremap_prot() in to the generic lib/devres.c.
> 
> In file included from sound/drivers/mpu401/mpu401_uart.c:31:
> arch/x86/include/asm/io.h:199: error: syntax error before 'pgprot_t'
> arch/x86/include/asm/io.h:199: warning: function declaration isn't a prototype
> 
> because asm/io.h now needs asm/pgtable.h for pgprot_t.
> 
Both sh and powerpc have pgprot_t in asm/page.h, it seems to only be x86
that is special. Adding asm/pgtable_types.h for x86 seems to work ok,
though.

Here's a rediffed version:

---

 arch/powerpc/include/asm/io.h       |    8 +++++---
 arch/powerpc/lib/devres.c           |   10 +++++-----
 arch/sh/Kconfig                     |    2 +-
 arch/sh/boards/mach-landisk/setup.c |    2 +-
 arch/sh/boards/mach-lboxre2/setup.c |    2 +-
 arch/sh/boards/mach-sh03/setup.c    |    2 +-
 arch/sh/include/asm/io.h            |    4 ++--
 arch/x86/include/asm/io.h           |    4 ++--
 arch/x86/mm/ioremap.c               |    5 +++--
 arch/x86/mm/pat.c                   |    5 ++---
 include/linux/mm.h                  |    2 +-
 mm/memory.c                         |    6 +++---
 12 files changed, 27 insertions(+), 25 deletions(-)

diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
index 001f2f1..27f40e6 100644
--- a/arch/powerpc/include/asm/io.h
+++ b/arch/powerpc/include/asm/io.h
@@ -618,7 +618,8 @@ static inline void iosync(void)
  *
  * * ioremap_flags allows to specify the page flags as an argument and can
  *   also be hooked by the platform via ppc_md. ioremap_prot is the exact
- *   same thing as ioremap_flags.
+ *   same thing as ioremap_flags, with the exception that it takes a
+ *   pgprot value instead.
  *
  * * ioremap_nocache is identical to ioremap
  *
@@ -643,7 +644,8 @@ extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
 extern void __iomem *ioremap_flags(phys_addr_t address, unsigned long size,
 				   unsigned long flags);
 #define ioremap_nocache(addr, size)	ioremap((addr), (size))
-#define ioremap_prot(addr, size, prot)	ioremap_flags((addr), (size), (prot))
+#define ioremap_prot(addr, size, prot)	ioremap_flags((addr), (size), \
+						      pgprot_val(prot))
 
 extern void iounmap(volatile void __iomem *addr);
 
@@ -779,7 +781,7 @@ static inline void * bus_to_virt(unsigned long address)
 #define clrsetbits_8(addr, clear, set) clrsetbits(8, addr, clear, set)
 
 void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
-				size_t size, unsigned long flags);
+				size_t size, pgprot_t prot);
 
 #endif /* __KERNEL__ */
 
diff --git a/arch/powerpc/lib/devres.c b/arch/powerpc/lib/devres.c
index deac4d3..045f7a7 100644
--- a/arch/powerpc/lib/devres.c
+++ b/arch/powerpc/lib/devres.c
@@ -9,21 +9,21 @@
 
 #include <linux/device.h>	/* devres_*(), devm_ioremap_release() */
 #include <linux/gfp.h>
-#include <linux/io.h>		/* ioremap_flags() */
+#include <linux/io.h>		/* ioremap_prot() */
 #include <linux/module.h>	/* EXPORT_SYMBOL() */
 
 /**
- * devm_ioremap_prot - Managed ioremap_flags()
+ * devm_ioremap_prot - Managed ioremap_prot()
  * @dev: Generic device to remap IO address for
  * @offset: BUS offset to map
  * @size: Size of map
- * @flags: Page flags
+ * @prot: Page protection flags
  *
  * Managed ioremap_prot().  Map is automatically unmapped on driver
  * detach.
  */
 void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
-				 size_t size, unsigned long flags)
+				 size_t size, pgprot_t prot)
 {
 	void __iomem **ptr, *addr;
 
@@ -31,7 +31,7 @@ void __iomem *devm_ioremap_prot(struct device *dev, resource_size_t offset,
 	if (!ptr)
 		return NULL;
 
-	addr = ioremap_flags(offset, size, flags);
+	addr = ioremap_prot(offset, size, prot);
 	if (addr) {
 		*ptr = addr;
 		devres_add(dev, ptr);
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 7f217b3..75d03d5 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -33,7 +33,7 @@ config SUPERH32
 	def_bool ARCH = "sh"
 	select HAVE_KPROBES
 	select HAVE_KRETPROBES
-	select HAVE_IOREMAP_PROT if MMU && !X2TLB
+	select HAVE_IOREMAP_PROT if MMU
 	select HAVE_FUNCTION_TRACER
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_DYNAMIC_FTRACE
diff --git a/arch/sh/boards/mach-landisk/setup.c b/arch/sh/boards/mach-landisk/setup.c
index 50337ac..94ab2bb 100644
--- a/arch/sh/boards/mach-landisk/setup.c
+++ b/arch/sh/boards/mach-landisk/setup.c
@@ -63,7 +63,7 @@ static int __init landisk_devices_setup(void)
 	/* open I/O area window */
 	paddrbase = virt_to_phys((void *)PA_AREA5_IO);
 	prot = PAGE_KERNEL_PCC(1, _PAGE_PCC_IO16);
-	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, pgprot_val(prot));
+	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, prot);
 	if (!cf_ide_base) {
 		printk("allocate_cf_area : can't open CF I/O window!\n");
 		return -ENOMEM;
diff --git a/arch/sh/boards/mach-lboxre2/setup.c b/arch/sh/boards/mach-lboxre2/setup.c
index 79b4e0d..30e0eeb 100644
--- a/arch/sh/boards/mach-lboxre2/setup.c
+++ b/arch/sh/boards/mach-lboxre2/setup.c
@@ -57,7 +57,7 @@ static int __init lboxre2_devices_setup(void)
 	paddrbase = virt_to_phys((void*)PA_AREA5_IO);
 	psize = PAGE_SIZE;
 	prot = PAGE_KERNEL_PCC(1, _PAGE_PCC_IO16);
-	cf0_io_base = (u32)ioremap_prot(paddrbase, psize, pgprot_val(prot));
+	cf0_io_base = (u32)ioremap_prot(paddrbase, psize, prot);
 	if (!cf0_io_base) {
 		printk(KERN_ERR "%s : can't open CF I/O window!\n" , __func__ );
 		return -ENOMEM;
diff --git a/arch/sh/boards/mach-sh03/setup.c b/arch/sh/boards/mach-sh03/setup.c
index af4a0c0..abfb782 100644
--- a/arch/sh/boards/mach-sh03/setup.c
+++ b/arch/sh/boards/mach-sh03/setup.c
@@ -82,7 +82,7 @@ static int __init sh03_devices_setup(void)
 	/* open I/O area window */
 	paddrbase = virt_to_phys((void *)PA_AREA5_IO);
 	prot = PAGE_KERNEL_PCC(1, _PAGE_PCC_IO16);
-	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, pgprot_val(prot));
+	cf_ide_base = ioremap_prot(paddrbase, PAGE_SIZE, prot);
 	if (!cf_ide_base) {
 		printk("allocate_cf_area : can't open CF I/O window!\n");
 		return -ENOMEM;
diff --git a/arch/sh/include/asm/io.h b/arch/sh/include/asm/io.h
index b237d52..7c19d03 100644
--- a/arch/sh/include/asm/io.h
+++ b/arch/sh/include/asm/io.h
@@ -370,9 +370,9 @@ ioremap_cache(phys_addr_t offset, unsigned long size)
 
 #ifdef CONFIG_HAVE_IOREMAP_PROT
 static inline void __iomem *
-ioremap_prot(phys_addr_t offset, unsigned long size, unsigned long flags)
+ioremap_prot(phys_addr_t offset, unsigned long size, pgprot_t prot)
 {
-	return __ioremap_mode(offset, size, __pgprot(flags));
+	return __ioremap_mode(offset, size, prot);
 }
 #endif
 
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 0722730..09895b2 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -40,7 +40,7 @@
 #include <linux/compiler.h>
 #include <asm-generic/int-ll64.h>
 #include <asm/page.h>
-
+#include <asm/pgtable_types.h>
 #include <xen/xen.h>
 
 #define build_mmio_read(name, size, type, reg, barrier) \
@@ -196,7 +196,7 @@ static inline unsigned int isa_virt_to_bus(volatile void *address)
 extern void __iomem *ioremap_nocache(resource_size_t offset, unsigned long size);
 extern void __iomem *ioremap_cache(resource_size_t offset, unsigned long size);
 extern void __iomem *ioremap_prot(resource_size_t offset, unsigned long size,
-				unsigned long prot_val);
+				pgprot_t prot);
 
 /*
  * The default ioremap() behavior is non-cached:
diff --git a/arch/x86/mm/ioremap.c b/arch/x86/mm/ioremap.c
index 0369843..7e028ac 100644
--- a/arch/x86/mm/ioremap.c
+++ b/arch/x86/mm/ioremap.c
@@ -243,9 +243,10 @@ void __iomem *ioremap_cache(resource_size_t phys_addr, unsigned long size)
 EXPORT_SYMBOL(ioremap_cache);
 
 void __iomem *ioremap_prot(resource_size_t phys_addr, unsigned long size,
-				unsigned long prot_val)
+				pgprot_t prot)
 {
-	return __ioremap_caller(phys_addr, size, (prot_val & _PAGE_CACHE_MASK),
+	return __ioremap_caller(phys_addr, size,
+				(pgprot_val(prot) & _PAGE_CACHE_MASK),
 				__builtin_return_address(0));
 }
 EXPORT_SYMBOL(ioremap_prot);
diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index f6ff57b..56e8041 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -661,7 +661,6 @@ static void free_pfn_range(u64 paddr, unsigned long size)
 int track_pfn_vma_copy(struct vm_area_struct *vma)
 {
 	resource_size_t paddr;
-	unsigned long prot;
 	unsigned long vma_size = vma->vm_end - vma->vm_start;
 	pgprot_t pgprot;
 
@@ -670,11 +669,11 @@ int track_pfn_vma_copy(struct vm_area_struct *vma)
 		 * reserve the whole chunk covered by vma. We need the
 		 * starting address and protection from pte.
 		 */
-		if (follow_phys(vma, vma->vm_start, 0, &prot, &paddr)) {
+		if (follow_phys(vma, vma->vm_start, 0, &pgprot, &paddr)) {
 			WARN_ON_ONCE(1);
 			return -EINVAL;
 		}
-		pgprot = __pgprot(prot);
+
 		return reserve_pfn_range(paddr, vma_size, &pgprot, 1);
 	}
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 721f451..0f7d3a1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -818,7 +818,7 @@ void unmap_mapping_range(struct address_space *mapping,
 int follow_pfn(struct vm_area_struct *vma, unsigned long address,
 	unsigned long *pfn);
 int follow_phys(struct vm_area_struct *vma, unsigned long address,
-		unsigned int flags, unsigned long *prot, resource_size_t *phys);
+		unsigned int flags, pgprot_t *prot, resource_size_t *phys);
 int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write);
 
diff --git a/mm/memory.c b/mm/memory.c
index 02e48aa..598eee3 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3431,7 +3431,7 @@ EXPORT_SYMBOL(follow_pfn);
 #ifdef CONFIG_HAVE_IOREMAP_PROT
 int follow_phys(struct vm_area_struct *vma,
 		unsigned long address, unsigned int flags,
-		unsigned long *prot, resource_size_t *phys)
+		pgprot_t *prot, resource_size_t *phys)
 {
 	int ret = -EINVAL;
 	pte_t *ptep, pte;
@@ -3447,7 +3447,7 @@ int follow_phys(struct vm_area_struct *vma,
 	if ((flags & FOLL_WRITE) && !pte_write(pte))
 		goto unlock;
 
-	*prot = pgprot_val(pte_pgprot(pte));
+	*prot = pte_pgprot(pte);
 	*phys = (resource_size_t)pte_pfn(pte) << PAGE_SHIFT;
 
 	ret = 0;
@@ -3461,7 +3461,7 @@ int generic_access_phys(struct vm_area_struct *vma, unsigned long addr,
 			void *buf, int len, int write)
 {
 	resource_size_t phys_addr;
-	unsigned long prot = 0;
+	pgprot_t prot;
 	void __iomem *maddr;
 	int offset = addr & (PAGE_SIZE-1);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
