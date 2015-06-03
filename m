Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id BBDA1900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 17:37:01 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so15211995pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 14:37:01 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id do5si2701531pbb.68.2015.06.03.14.37.00
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 14:37:00 -0700 (PDT)
Subject: [PATCH v3 1/6] arch: unify ioremap prototypes and macro aliases
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 03 Jun 2015 17:34:18 -0400
Message-ID: <20150603213418.13749.27715.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

Some archs define the first parameter to ioremap() as unsigned long,
while the balance define it as resource_size_t.  Unify on
resource_size_t to enable passing ioremap function pointers.  Also, some
archs use function-like macros for defining ioremap aliases, but
asm-generic/iomap.h expects object-like macros, unify on the latter.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/cris/include/asm/io.h     |    8 ++++----
 arch/cris/mm/ioremap.c         |    6 +++---
 arch/ia64/include/asm/io.h     |    4 ++--
 arch/ia64/mm/ioremap.c         |    4 ++--
 arch/powerpc/include/asm/io.h  |    2 +-
 arch/sparc/include/asm/io_64.h |    8 ++++----
 6 files changed, 16 insertions(+), 16 deletions(-)

diff --git a/arch/cris/include/asm/io.h b/arch/cris/include/asm/io.h
index 752a3f45df60..2e4ee658fb04 100644
--- a/arch/cris/include/asm/io.h
+++ b/arch/cris/include/asm/io.h
@@ -34,17 +34,17 @@ static inline void * phys_to_virt(unsigned long address)
 	return __va(address);
 }
 
-extern void __iomem * __ioremap(unsigned long offset, unsigned long size, unsigned long flags);
-extern void __iomem * __ioremap_prot(unsigned long phys_addr, unsigned long size, pgprot_t prot);
+extern void __iomem * __ioremap(resource_size_t offset, unsigned long size, unsigned long flags);
+extern void __iomem * __ioremap_prot(resource_size_t phys_addr, unsigned long size, pgprot_t prot);
 
-static inline void __iomem * ioremap (unsigned long offset, unsigned long size)
+static inline void __iomem * ioremap (resource_size_t offset, unsigned long size)
 {
 	return __ioremap(offset, size, 0);
 }
 
 extern void iounmap(volatile void * __iomem addr);
 
-extern void __iomem * ioremap_nocache(unsigned long offset, unsigned long size);
+extern void __iomem * ioremap_nocache(resource_size_t offset, unsigned long size);
 
 /*
  * IO bus memory addresses are also 1:1 with the physical address
diff --git a/arch/cris/mm/ioremap.c b/arch/cris/mm/ioremap.c
index 80fdb995a8ce..51ae80432eb5 100644
--- a/arch/cris/mm/ioremap.c
+++ b/arch/cris/mm/ioremap.c
@@ -27,7 +27,7 @@
  * have to convert them into an offset in a page-aligned mapping, but the
  * caller shouldn't need to know that small detail.
  */
-void __iomem * __ioremap_prot(unsigned long phys_addr, unsigned long size, pgprot_t prot)
+void __iomem * __ioremap_prot(resource_size_t phys_addr, unsigned long size, pgprot_t prot)
 {
 	void __iomem * addr;
 	struct vm_struct * area;
@@ -60,7 +60,7 @@ void __iomem * __ioremap_prot(unsigned long phys_addr, unsigned long size, pgpro
 	return (void __iomem *) (offset + (char __iomem *)addr);
 }
 
-void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned long flags)
+void __iomem * __ioremap(resource_size_t phys_addr, unsigned long size, unsigned long flags)
 {
 	return __ioremap_prot(phys_addr, size,
 		              __pgprot(_PAGE_PRESENT | __READABLE |
@@ -76,7 +76,7 @@ void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned l
  * Must be freed with iounmap.
  */
 
-void __iomem *ioremap_nocache(unsigned long phys_addr, unsigned long size)
+void __iomem *ioremap_nocache(resource_size_t phys_addr, unsigned long size)
 {
         return __ioremap(phys_addr | MEM_NON_CACHEABLE, size, 0);
 }
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 80a7e34be009..8588ef767a44 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -424,8 +424,8 @@ __writeq (unsigned long val, volatile void __iomem *addr)
 
 # ifdef __KERNEL__
 
-extern void __iomem * ioremap(unsigned long offset, unsigned long size);
-extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
+extern void __iomem * ioremap(resource_size_t offset, unsigned long size);
+extern void __iomem * ioremap_nocache (resource_size_t offset, unsigned long size);
 extern void iounmap (volatile void __iomem *addr);
 extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
 #define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
diff --git a/arch/ia64/mm/ioremap.c b/arch/ia64/mm/ioremap.c
index 43964cde6214..205d71445f06 100644
--- a/arch/ia64/mm/ioremap.c
+++ b/arch/ia64/mm/ioremap.c
@@ -32,7 +32,7 @@ early_ioremap (unsigned long phys_addr, unsigned long size)
 }
 
 void __iomem *
-ioremap (unsigned long phys_addr, unsigned long size)
+ioremap (resource_size_t phys_addr, unsigned long size)
 {
 	void __iomem *addr;
 	struct vm_struct *area;
@@ -102,7 +102,7 @@ ioremap (unsigned long phys_addr, unsigned long size)
 EXPORT_SYMBOL(ioremap);
 
 void __iomem *
-ioremap_nocache (unsigned long phys_addr, unsigned long size)
+ioremap_nocache (resource_size_t phys_addr, unsigned long size)
 {
 	if (kern_mem_attribute(phys_addr, size) & EFI_MEMORY_WB)
 		return NULL;
diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
index a8d2ef30d473..eaadc99b652b 100644
--- a/arch/powerpc/include/asm/io.h
+++ b/arch/powerpc/include/asm/io.h
@@ -720,7 +720,7 @@ extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
 extern void __iomem *ioremap_prot(phys_addr_t address, unsigned long size,
 				  unsigned long flags);
 extern void __iomem *ioremap_wc(phys_addr_t address, unsigned long size);
-#define ioremap_nocache(addr, size)	ioremap((addr), (size))
+#define ioremap_nocache ioremap
 
 extern void iounmap(volatile void __iomem *addr);
 
diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index c32fa3f752c8..b99ae1fac174 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -395,14 +395,14 @@ static inline void memcpy_toio(volatile void __iomem *dst, const void *src,
 /* On sparc64 we have the whole physical IO address space accessible
  * using physically addressed loads and stores, so this does nothing.
  */
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return (void __iomem *)offset;
 }
 
-#define ioremap_nocache(X,Y)		ioremap((X),(Y))
-#define ioremap_wc(X,Y)			ioremap((X),(Y))
-#define ioremap_wt(X,Y)			ioremap((X),(Y))
+#define ioremap_nocache ioremap
+#define ioremap_wc ioremap
+#define ioremap_wt ioremap
 
 static inline void iounmap(volatile void __iomem *addr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
