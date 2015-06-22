Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 214A56B006E
	for <linux-mm@kvack.org>; Mon, 22 Jun 2015 04:30:14 -0400 (EDT)
Received: by pabvl15 with SMTP id vl15so83253283pab.1
        for <linux-mm@kvack.org>; Mon, 22 Jun 2015 01:30:13 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id cy9si28584995pad.8.2015.06.22.01.30.11
        for <linux-mm@kvack.org>;
        Mon, 22 Jun 2015 01:30:12 -0700 (PDT)
Subject: [PATCH v5 2/6] arch: unify ioremap prototypes and macro aliases
From: Dan Williams <dan.j.williams@intel.com>
Date: Mon, 22 Jun 2015 04:24:27 -0400
Message-ID: <20150622082427.35954.73529.stgit@dwillia2-desk3.jf.intel.com>
In-Reply-To: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
References: <20150622081028.35954.89885.stgit@dwillia2-desk3.jf.intel.com>
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
asm-generic/io.h expects object-like macros, unify on the latter.

Move all handling of ioremap aliasing (i.e. ioremap_wt => ioremap) to
include/linux/io.h.  Add a check to include/linux/io.h to warn at
compile time if an arch violates expectations.

Kill ARCH_HAS_IOREMAP_WC and ARCH_HAS_IOREMAP_WT in favor of just
testing for ioremap_wc, and ioremap_wt being defined.  This arrangement
allows drivers to know when ioremap_<foo> are being re-directed to plain
ioremap.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/alpha/include/asm/io.h      |    7 +++--
 arch/arc/include/asm/io.h        |    6 ----
 arch/arm/include/asm/io.h        |   31 ++++++++++++++++----
 arch/arm64/include/asm/io.h      |   23 ++++++++++++---
 arch/avr32/include/asm/io.h      |   22 +++++++-------
 arch/avr32/mm/ioremap.c          |    2 +
 arch/cris/include/asm/io.h       |    8 +++--
 arch/cris/mm/ioremap.c           |    2 +
 arch/frv/include/asm/io.h        |   23 +++++++--------
 arch/hexagon/include/asm/io.h    |    5 +++
 arch/ia64/include/asm/io.h       |   10 +------
 arch/ia64/mm/ioremap.c           |    4 +--
 arch/m32r/include/asm/io.h       |    9 +++---
 arch/m68k/include/asm/io_mm.h    |   21 +++++++++-----
 arch/m68k/include/asm/io_no.h    |   34 ++++++++++++++--------
 arch/m68k/include/asm/raw_io.h   |    3 +-
 arch/m68k/mm/kmap.c              |    2 +
 arch/metag/include/asm/io.h      |   35 ++++++++++++++---------
 arch/microblaze/include/asm/io.h |    6 ----
 arch/microblaze/mm/pgtable.c     |    2 +
 arch/mips/include/asm/io.h       |   42 ++++++++++------------------
 arch/mn10300/include/asm/io.h    |   10 ++++---
 arch/nios2/include/asm/io.h      |   15 +++-------
 arch/openrisc/include/asm/io.h   |    3 +-
 arch/openrisc/mm/ioremap.c       |    2 +
 arch/parisc/include/asm/io.h     |    6 +---
 arch/parisc/mm/ioremap.c         |    2 +
 arch/powerpc/include/asm/io.h    |    7 ++---
 arch/s390/include/asm/io.h       |    8 ++---
 arch/sh/include/asm/io.h         |    9 +++++-
 arch/sparc/include/asm/io_32.h   |    7 +----
 arch/sparc/include/asm/io_64.h   |    8 ++---
 arch/sparc/kernel/ioport.c       |    2 +
 arch/tile/include/asm/io.h       |   17 +++++++----
 arch/unicore32/include/asm/io.h  |   25 +++++++++++++---
 arch/x86/include/asm/io.h        |    9 ++++--
 arch/xtensa/include/asm/io.h     |   13 +++++----
 drivers/net/ethernet/sfc/io.h    |    2 +
 include/asm-generic/iomap.h      |    8 -----
 include/linux/io.h               |   58 ++++++++++++++++++++++++++++++++++++++
 40 files changed, 300 insertions(+), 208 deletions(-)

diff --git a/arch/alpha/include/asm/io.h b/arch/alpha/include/asm/io.h
index f05bdb4b1cb9..6b63689c27a6 100644
--- a/arch/alpha/include/asm/io.h
+++ b/arch/alpha/include/asm/io.h
@@ -282,10 +282,11 @@ extern inline void ioport_unmap(void __iomem *addr)
 {
 }
 
-static inline void __iomem *ioremap(unsigned long port, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t port, unsigned long size)
 {
 	return IO_CONCAT(__IO_PREFIX,ioremap) (port, size);
 }
+#define ioremap ioremap
 
 static inline void __iomem *__ioremap(unsigned long port, unsigned long size,
 				      unsigned long flags)
@@ -293,16 +294,18 @@ static inline void __iomem *__ioremap(unsigned long port, unsigned long size,
 	return ioremap(port, size);
 }
 
-static inline void __iomem * ioremap_nocache(unsigned long offset,
+static inline void __iomem * ioremap_nocache(resource_size_t offset,
 					     unsigned long size)
 {
 	return ioremap(offset, size);
 } 
+#define ioremap_nocache ioremap_nocache
 
 static inline void iounmap(volatile void __iomem *addr)
 {
 	IO_CONCAT(__IO_PREFIX,iounmap)(addr);
 }
+#define iounmap iounmap
 
 static inline int __is_ioaddr(unsigned long addr)
 {
diff --git a/arch/arc/include/asm/io.h b/arch/arc/include/asm/io.h
index 7cc4ced5dbf4..e6f782863026 100644
--- a/arch/arc/include/asm/io.h
+++ b/arch/arc/include/asm/io.h
@@ -13,14 +13,8 @@
 #include <asm/byteorder.h>
 #include <asm/page.h>
 
-extern void __iomem *ioremap(unsigned long physaddr, unsigned long size);
 extern void __iomem *ioremap_prot(phys_addr_t offset, unsigned long size,
 				  unsigned long flags);
-extern void iounmap(const void __iomem *addr);
-
-#define ioremap_nocache(phy, sz)	ioremap(phy, sz)
-#define ioremap_wc(phy, sz)		ioremap(phy, sz)
-#define ioremap_wt(phy, sz)		ioremap(phy, sz)
 
 /* Change struct page to physical address */
 #define page_to_phys(page)		(page_to_pfn(page) << PAGE_SHIFT)
diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 1b7677d1e5e1..ecd410c716d8 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -332,12 +332,31 @@ extern void _memset_io(volatile void __iomem *, int, size_t);
  * Documentation/io-mapping.txt.
  *
  */
-#define ioremap(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE)
-#define ioremap_nocache(cookie,size)	__arm_ioremap((cookie), (size), MT_DEVICE)
-#define ioremap_cache(cookie,size)	__arm_ioremap((cookie), (size), MT_DEVICE_CACHED)
-#define ioremap_wc(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE_WC)
-#define ioremap_wt(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE)
-#define iounmap				__arm_iounmap
+static inline void __iomem *ioremap(resource_size_t cookie, unsigned long size)
+{
+	return __arm_ioremap(cookie, size, MT_DEVICE);
+}
+#define ioremap ioremap
+
+static inline void __iomem *ioremap_cache(resource_size_t cookie,
+		unsigned long size)
+{
+	return __arm_ioremap(cookie, size, MT_DEVICE_CACHED);
+}
+#define ioremap_cache ioremap_cache
+
+static inline void __iomem *ioremap_wc(resource_size_t cookie,
+		unsigned long size)
+{
+	return __arm_ioremap(cookie, size, MT_DEVICE_WC);
+}
+#define ioremap_wc ioremap_wc
+
+static inline void iounmap(volatile void __iomem *addr)
+{
+	__arm_iounmap(addr);
+}
+#define iounmap iounmap
 
 /*
  * io{read,write}{16,32}be() macros
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index 7116d3973058..56782487bf3c 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -166,12 +166,25 @@ extern void __memset_io(volatile void __iomem *, int, size_t);
 extern void __iomem *__ioremap(phys_addr_t phys_addr, size_t size, pgprot_t prot);
 extern void __iounmap(volatile void __iomem *addr);
 extern void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size);
+#define ioremap_cache ioremap_cache
 
-#define ioremap(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
-#define ioremap_nocache(addr, size)	__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
-#define ioremap_wc(addr, size)		__ioremap((addr), (size), __pgprot(PROT_NORMAL_NC))
-#define ioremap_wt(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
-#define iounmap				__iounmap
+static inline void __iomem *ioremap(resource_size_t addr, unsigned long size)
+{
+	return __ioremap(addr, size, __pgprot(PROT_DEVICE_nGnRE));
+}
+#define ioremap ioremap
+
+static inline void __iomem *ioremap_wc(resource_size_t addr, unsigned long size)
+{
+	return __ioremap(addr, size, __pgprot(PROT_NORMAL_NC));
+}
+#define ioremap_wc ioremap_wc
+
+static inline void iounmap(volatile void __iomem *addr)
+{
+	return __iounmap(addr);
+}
+#define iounmap iounmap
 
 /*
  * io{read,write}{16,32}be() macros
diff --git a/arch/avr32/include/asm/io.h b/arch/avr32/include/asm/io.h
index e998ff5d8e1a..80af4cb6c5b6 100644
--- a/arch/avr32/include/asm/io.h
+++ b/arch/avr32/include/asm/io.h
@@ -274,7 +274,7 @@ static inline void memset_io(volatile void __iomem *addr, unsigned char val,
 
 extern void __iomem *__ioremap(unsigned long offset, size_t size,
 			       unsigned long flags);
-extern void __iounmap(void __iomem *addr);
+extern void __iounmap(volatile void __iomem *addr);
 
 /*
  * ioremap	-   map bus memory into CPU space
@@ -286,17 +286,17 @@ extern void __iounmap(void __iomem *addr);
  * the other mmio helpers. The returned address is not guaranteed to
  * be usable directly as a virtual address.
  */
-#define ioremap(offset, size)			\
-	__ioremap((offset), (size), 0)
-
-#define ioremap_nocache(offset, size)		\
-	__ioremap((offset), (size), 0)
-
-#define iounmap(addr)				\
-	__iounmap(addr)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
+{
+	return __ioremap(offset, size, 0);
+}
+#define ioremap ioremap
 
-#define ioremap_wc ioremap_nocache
-#define ioremap_wt ioremap_nocache
+static inline void iounmap(volatile void __iomem *addr)
+{
+	return __iounmap(addr);
+}
+#define iounmap iounmap
 
 #define cached(addr) P1SEGADDR(addr)
 #define uncached(addr) P2SEGADDR(addr)
diff --git a/arch/avr32/mm/ioremap.c b/arch/avr32/mm/ioremap.c
index 7def0d84cec6..f3eacbe5dff6 100644
--- a/arch/avr32/mm/ioremap.c
+++ b/arch/avr32/mm/ioremap.c
@@ -73,7 +73,7 @@ void __iomem *__ioremap(unsigned long phys_addr, size_t size,
 }
 EXPORT_SYMBOL(__ioremap);
 
-void __iounmap(void __iomem *addr)
+void __iounmap(volatile void __iomem *addr)
 {
 	struct vm_struct *p;
 
diff --git a/arch/cris/include/asm/io.h b/arch/cris/include/asm/io.h
index 752a3f45df60..cd55a5709433 100644
--- a/arch/cris/include/asm/io.h
+++ b/arch/cris/include/asm/io.h
@@ -37,14 +37,14 @@ static inline void * phys_to_virt(unsigned long address)
 extern void __iomem * __ioremap(unsigned long offset, unsigned long size, unsigned long flags);
 extern void __iomem * __ioremap_prot(unsigned long phys_addr, unsigned long size, pgprot_t prot);
 
-static inline void __iomem * ioremap (unsigned long offset, unsigned long size)
+static inline void __iomem * ioremap(resource_size_t offset, unsigned long size)
 {
 	return __ioremap(offset, size, 0);
 }
+#define ioremap ioremap
 
-extern void iounmap(volatile void * __iomem addr);
-
-extern void __iomem * ioremap_nocache(unsigned long offset, unsigned long size);
+extern void __iomem * ioremap_nocache(resource_size_t offset, unsigned long size);
+#define ioremap_nocache ioremap_nocache
 
 /*
  * IO bus memory addresses are also 1:1 with the physical address
diff --git a/arch/cris/mm/ioremap.c b/arch/cris/mm/ioremap.c
index 80fdb995a8ce..13cef92df503 100644
--- a/arch/cris/mm/ioremap.c
+++ b/arch/cris/mm/ioremap.c
@@ -76,7 +76,7 @@ void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned l
  * Must be freed with iounmap.
  */
 
-void __iomem *ioremap_nocache(unsigned long phys_addr, unsigned long size)
+void __iomem *ioremap_nocache(resource_size_t phys_addr, unsigned long size)
 {
         return __ioremap(phys_addr | MEM_NON_CACHEABLE, size, 0);
 }
diff --git a/arch/frv/include/asm/io.h b/arch/frv/include/asm/io.h
index a31b63ec4930..bde570d29c89 100644
--- a/arch/frv/include/asm/io.h
+++ b/arch/frv/include/asm/io.h
@@ -17,8 +17,6 @@
 
 #ifdef __KERNEL__
 
-#define ARCH_HAS_IOREMAP_WT
-
 #include <linux/types.h>
 #include <asm/virtconvert.h>
 #include <asm/string.h>
@@ -257,29 +255,28 @@ static inline void writel(uint32_t datum, volatile void __iomem *addr)
 
 extern void __iomem *__ioremap(unsigned long physaddr, unsigned long size, int cacheflag);
 
-static inline void __iomem *ioremap(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
-}
-
-static inline void __iomem *ioremap_nocache(unsigned long physaddr, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
+#define ioremap ioremap
 
-static inline void __iomem *ioremap_wt(unsigned long physaddr, unsigned long size)
+static inline void __iomem *ioremap_wt(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
+#define ioremap_wt ioremap_wt
 
-static inline void __iomem *ioremap_fullcache(unsigned long physaddr, unsigned long size)
+static inline void __iomem *ioremap_fullcache(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
 }
 
-#define ioremap_wc ioremap_nocache
-
-extern void iounmap(void volatile __iomem *addr);
+static inline void __iomem *ioremap_cache(resource_size_t physaddr, unsigned long size)
+{
+	return ioremap_fullcache(physaddr, size);
+}
+#define ioremap_cache ioremap_cache
 
 static inline void __iomem *ioport_map(unsigned long port, unsigned int nr)
 {
diff --git a/arch/hexagon/include/asm/io.h b/arch/hexagon/include/asm/io.h
index 66f5e9a61efc..e5ecc08b7627 100644
--- a/arch/hexagon/include/asm/io.h
+++ b/arch/hexagon/include/asm/io.h
@@ -191,16 +191,19 @@ static inline void writel(u32 data, volatile void __iomem *addr)
  * This is probably too long for an inline.
  */
 void __iomem *ioremap_nocache(unsigned long phys_addr, unsigned long size);
+#define ioremap_nocache ioremap_nocache
 
-static inline void __iomem *ioremap(unsigned long phys_addr, unsigned long size)
+static inline void __iomem *ioremap(resouce_size_t phys_addr, unsigned long size)
 {
 	return ioremap_nocache(phys_addr, size);
 }
+#define ioremap ioremap
 
 static inline void iounmap(volatile void __iomem *addr)
 {
 	__iounmap(addr);
 }
+#define iounmap iounmap
 
 #define __raw_writel writel
 
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 80a7e34be009..ea4c7a243973 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -424,18 +424,12 @@ __writeq (unsigned long val, volatile void __iomem *addr)
 
 # ifdef __KERNEL__
 
-extern void __iomem * ioremap(unsigned long offset, unsigned long size);
-extern void __iomem * ioremap_nocache (unsigned long offset, unsigned long size);
-extern void iounmap (volatile void __iomem *addr);
+extern void __iomem * ioremap_nocache (resource_size_t offset, unsigned long size);
+#define ioremap_nocache ioremap_nocache
 extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size);
 #define early_memremap(phys_addr, size)        early_ioremap(phys_addr, size)
 extern void early_iounmap (volatile void __iomem *addr, unsigned long size);
 #define early_memunmap(addr, size)             early_iounmap(addr, size)
-static inline void __iomem * ioremap_cache (unsigned long phys_addr, unsigned long size)
-{
-	return ioremap(phys_addr, size);
-}
-
 
 /*
  * String version of IO memory access ops:
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
diff --git a/arch/m32r/include/asm/io.h b/arch/m32r/include/asm/io.h
index 0c3f25ee3381..d7f96a542816 100644
--- a/arch/m32r/include/asm/io.h
+++ b/arch/m32r/include/asm/io.h
@@ -60,15 +60,14 @@ __ioremap(unsigned long offset, unsigned long size, unsigned long flags);
  *	address.
  */
 
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return __ioremap(offset, size, 0);
 }
+#define ioremap ioremap
 
-extern void iounmap(volatile void __iomem *addr);
-#define ioremap_nocache(off,size) ioremap(off,size)
-#define ioremap_wc ioremap_nocache
-#define ioremap_wt ioremap_nocache
+void iounmap(volatile void __iomem *addr);
+#define iounmap iounmap
 
 /*
  * IO bus memory addresses are also 1:1 with the physical address
diff --git a/arch/m68k/include/asm/io_mm.h b/arch/m68k/include/asm/io_mm.h
index 618c85d3c786..7658252c64ab 100644
--- a/arch/m68k/include/asm/io_mm.h
+++ b/arch/m68k/include/asm/io_mm.h
@@ -20,8 +20,6 @@
 
 #ifdef __KERNEL__
 
-#define ARCH_HAS_IOREMAP_WT
-
 #include <linux/compiler.h>
 #include <asm/raw_io.h>
 #include <asm/virtconvert.h>
@@ -459,25 +457,32 @@ static inline void isa_delay(void)
 
 #define mmiowb()
 
-static inline void __iomem *ioremap(unsigned long physaddr, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
-static inline void __iomem *ioremap_nocache(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
-}
-static inline void __iomem *ioremap_wt(unsigned long physaddr,
+#define ioremap ioremap
+
+static inline void __iomem *ioremap_wt(resource_size_t physaddr,
 					 unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
+#define ioremap_wt ioremap_wt
+
 static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
 				      unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
 }
 
+static inline void __iomem *ioremap_cache(resource_size_t physaddr,
+		unsigned long size)
+{
+	return ioremap_fullcache(physaddr, size);
+}
+#define ioremap_cache ioremap_cache
+
 static inline void memset_io(volatile void __iomem *addr, unsigned char val, int count)
 {
 	__builtin_memset((void __force *) addr, val, count);
diff --git a/arch/m68k/include/asm/io_no.h b/arch/m68k/include/asm/io_no.h
index ad7bd40e6742..ea9b280ebc33 100644
--- a/arch/m68k/include/asm/io_no.h
+++ b/arch/m68k/include/asm/io_no.h
@@ -3,8 +3,6 @@
 
 #ifdef __KERNEL__
 
-#define ARCH_HAS_IOREMAP_WT
-
 #include <asm/virtconvert.h>
 #include <asm-generic/iomap.h>
 
@@ -143,28 +141,40 @@ static inline void io_insl(unsigned int addr, void *buf, int len)
 #define IOMAP_NOCACHE_NONSER		2
 #define IOMAP_WRITETHROUGH		3
 
-static inline void *__ioremap(unsigned long physaddr, unsigned long size, int cacheflag)
-{
-	return (void *) physaddr;
-}
-static inline void *ioremap(unsigned long physaddr, unsigned long size)
+static inline void __iomem *__ioremap(unsigned long physaddr,
+		unsigned long size, int cacheflag)
 {
-	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
+	return (void __iomem *) physaddr;
 }
-static inline void *ioremap_nocache(unsigned long physaddr, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
-static inline void *ioremap_wt(unsigned long physaddr, unsigned long size)
+#define ioremap ioremap
+
+static inline void __iomem *ioremap_wt(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
-static inline void *ioremap_fullcache(unsigned long physaddr, unsigned long size)
+#define ioremap_wt ioremap_wt
+
+static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
+		unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
 }
 
-#define	iounmap(addr)	do { } while(0)
+static inline void __iomem *ioremap_cache(resource_size_t physaddr,
+		unsigned long size)
+{
+	return ioremap_fullcache(physaddr, size);
+}
+#define ioremap_cache ioremap_cache
+
+static inline void iounmap(volatile void __iomem *addr)
+{
+}
+#define iounmap iounmap
 
 /*
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
diff --git a/arch/m68k/include/asm/raw_io.h b/arch/m68k/include/asm/raw_io.h
index 932faa35655b..abb7708f02ed 100644
--- a/arch/m68k/include/asm/raw_io.h
+++ b/arch/m68k/include/asm/raw_io.h
@@ -19,7 +19,8 @@
 #define IOMAP_NOCACHE_NONSER		2
 #define IOMAP_WRITETHROUGH		3
 
-extern void iounmap(void __iomem *addr);
+extern void iounmap(volatile void __iomem *addr);
+#define iounmap iounmap
 
 extern void __iomem *__ioremap(unsigned long physaddr, unsigned long size,
 		       int cacheflag);
diff --git a/arch/m68k/mm/kmap.c b/arch/m68k/mm/kmap.c
index 6e4955bc542b..f0d76d9f0643 100644
--- a/arch/m68k/mm/kmap.c
+++ b/arch/m68k/mm/kmap.c
@@ -226,7 +226,7 @@ EXPORT_SYMBOL(__ioremap);
 /*
  * Unmap an ioremap()ed region again
  */
-void iounmap(void __iomem *addr)
+void iounmap(volatile void __iomem *addr)
 {
 #ifdef CONFIG_AMIGA
 	if ((!MACH_IS_AMIGA) ||
diff --git a/arch/metag/include/asm/io.h b/arch/metag/include/asm/io.h
index 9890f21eadbe..50e95ecb4bc2 100644
--- a/arch/metag/include/asm/io.h
+++ b/arch/metag/include/asm/io.h
@@ -148,22 +148,29 @@ extern void __iounmap(void __iomem *addr);
  *	address is not guaranteed to be usable directly as a virtual
  *	address.
  */
-#define ioremap(offset, size)                   \
-	__ioremap((offset), (size), 0)
-
-#define ioremap_nocache(offset, size)           \
-	__ioremap((offset), (size), 0)
-
-#define ioremap_cached(offset, size)            \
-	__ioremap((offset), (size), _PAGE_CACHEABLE)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
+{
+	return __ioremap(offset, size, 0);
+}
+#define ioremap ioremap
 
-#define ioremap_wc(offset, size)                \
-	__ioremap((offset), (size), _PAGE_WR_COMBINE)
+static inline void __iomem *ioremap_cache(resource_size_t offset, unsigned long size)
+{
+	return __ioremap(offset, size, _PAGE_CACHEABLE);
+}
+#define ioremap_cache ioremap_cache
+#define ioremap_cached ioremap_cache
 
-#define ioremap_wt(offset, size)                \
-	__ioremap((offset), (size), 0)
+static inline void __iomem *ioremap_wc(resource_size_t offset, unsigned long size)
+{
+	return __ioremap(offset, size, _PAGE_WR_COMBINE);
+}
+#define ioremap_wc ioremap_wc
 
-#define iounmap(addr)                           \
-	__iounmap(addr)
+static inline void iounmap(volatile void __iomem *addr)
+{
+	return __iounmap(addr);
+}
+#define iounmap iounmap
 
 #endif  /* _ASM_METAG_IO_H */
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index 39b6315db82e..60ca27d7dd1f 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -36,13 +36,7 @@ extern resource_size_t isa_mem_base;
 #ifdef CONFIG_MMU
 #define page_to_bus(page)	(page_to_phys(page))
 
-extern void iounmap(void __iomem *addr);
-
-extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
-#define ioremap_nocache(addr, size)		ioremap((addr), (size))
 #define ioremap_fullcache(addr, size)		ioremap((addr), (size))
-#define ioremap_wc(addr, size)			ioremap((addr), (size))
-#define ioremap_wt(addr, size)			ioremap((addr), (size))
 
 #endif /* CONFIG_MMU */
 
diff --git a/arch/microblaze/mm/pgtable.c b/arch/microblaze/mm/pgtable.c
index 4f4520e779a5..2b47b34ff26c 100644
--- a/arch/microblaze/mm/pgtable.c
+++ b/arch/microblaze/mm/pgtable.c
@@ -126,7 +126,7 @@ void __iomem *ioremap(phys_addr_t addr, unsigned long size)
 }
 EXPORT_SYMBOL(ioremap);
 
-void iounmap(void __iomem *addr)
+void iounmap(volatile void __iomem *addr)
 {
 	if ((__force void *)addr > high_memory &&
 					(unsigned long) addr < ioremap_bot)
diff --git a/arch/mips/include/asm/io.h b/arch/mips/include/asm/io.h
index 9e777cd42b67..a907e634f914 100644
--- a/arch/mips/include/asm/io.h
+++ b/arch/mips/include/asm/io.h
@@ -232,30 +232,11 @@ static inline void __iomem * __ioremap_mode(phys_addr_t offset, unsigned long si
  * address is not guaranteed to be usable directly as a virtual
  * address.
  */
-#define ioremap(offset, size)						\
-	__ioremap_mode((offset), (size), _CACHE_UNCACHED)
-
-/*
- * ioremap_nocache     -   map bus memory into CPU space
- * @offset:    bus address of the memory
- * @size:      size of the resource to map
- *
- * ioremap_nocache performs a platform specific sequence of operations to
- * make bus memory CPU accessible via the readb/readw/readl/writeb/
- * writew/writel functions and the other mmio helpers. The returned
- * address is not guaranteed to be usable directly as a virtual
- * address.
- *
- * This version of ioremap ensures that the memory is marked uncachable
- * on the CPU as well as honouring existing caching rules from things like
- * the PCI bus. Note that there are other caches and buffers on many
- * busses. In particular driver authors should read up on PCI writes
- *
- * It's useful if some control registers are in such an area and
- * write combining or read caching is not desirable:
- */
-#define ioremap_nocache(offset, size)					\
-	__ioremap_mode((offset), (size), _CACHE_UNCACHED)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
+{
+	return __ioremap_mode(offset, size, _CACHE_UNCACHED);
+}
+#define ioremap ioremap
 
 /*
  * ioremap_cachable -	map bus memory into CPU space
@@ -272,8 +253,14 @@ static inline void __iomem * __ioremap_mode(phys_addr_t offset, unsigned long si
  * the CPU.  Also enables full write-combining.	 Useful for some
  * memory-like regions on I/O busses.
  */
-#define ioremap_cachable(offset, size)					\
-	__ioremap_mode((offset), (size), _page_cachable_default)
+#define ioremap_cachable ioremap_cache
+extern unsigned long _page_cachable_default;
+static inline void __iomem *ioremap_cache(resource_size_t offset,
+		unsigned long size)
+{
+	return __ioremap_mode(offset, size, _page_cachable_default);
+}
+#define ioremap_cache ioremap_cache
 
 /*
  * These two are MIPS specific ioremap variant.	 ioremap_cacheable_cow
@@ -286,7 +273,7 @@ static inline void __iomem * __ioremap_mode(phys_addr_t offset, unsigned long si
 #define ioremap_uncached_accelerated(offset, size)			\
 	__ioremap_mode((offset), (size), _CACHE_UNCACHED_ACCELERATED)
 
-static inline void iounmap(const volatile void __iomem *addr)
+static inline void iounmap(volatile void __iomem *addr)
 {
 	if (plat_iounmap(addr))
 		return;
@@ -301,6 +288,7 @@ static inline void iounmap(const volatile void __iomem *addr)
 
 #undef __IS_KSEG1
 }
+#define iounmap iounmap
 
 #ifdef CONFIG_CPU_CAVIUM_OCTEON
 #define war_octeon_io_reorder_wmb()		wmb()
diff --git a/arch/mn10300/include/asm/io.h b/arch/mn10300/include/asm/io.h
index 07c5b4a3903b..48629631f718 100644
--- a/arch/mn10300/include/asm/io.h
+++ b/arch/mn10300/include/asm/io.h
@@ -266,27 +266,29 @@ static inline void __iomem *__ioremap(unsigned long offset, unsigned long size,
 	return (void __iomem *) offset;
 }
 
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return (void __iomem *)(offset & ~0x20000000);
 }
+#define ioremap ioremap
 
 /*
  * This one maps high address device memory and turns off caching for that
  * area.  it's useful if some control registers are in such an area and write
  * combining or read caching is not desirable:
  */
-static inline void __iomem *ioremap_nocache(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap_nocache(resource_size_t offset, unsigned long size)
 {
 	return (void __iomem *) (offset | 0x20000000);
 }
-
+#define ioremap_nocache ioremap_nocache
 #define ioremap_wc ioremap_nocache
 #define ioremap_wt ioremap_nocache
 
-static inline void iounmap(void __iomem *addr)
+static inline void iounmap(volatile void __iomem *addr)
 {
 }
+#define iounmap iounmap
 
 static inline void __iomem *ioport_map(unsigned long port, unsigned int nr)
 {
diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
index c5a62da22cd2..161a63265813 100644
--- a/arch/nios2/include/asm/io.h
+++ b/arch/nios2/include/asm/io.h
@@ -29,24 +29,17 @@ extern void __iomem *__ioremap(unsigned long physaddr, unsigned long size,
 			unsigned long cacheflag);
 extern void __iounmap(void __iomem *addr);
 
-static inline void __iomem *ioremap(unsigned long physaddr, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, 0);
 }
+#define ioremap ioremap
 
-static inline void __iomem *ioremap_nocache(unsigned long physaddr,
-						unsigned long size)
-{
-	return __ioremap(physaddr, size, 0);
-}
-
-static inline void iounmap(void __iomem *addr)
+static inline void iounmap(volatile void __iomem *addr)
 {
 	__iounmap(addr);
 }
-
-#define ioremap_wc ioremap_nocache
-#define ioremap_wt ioremap_nocache
+#define iounmap iounmap
 
 /* Pages to physical address... */
 #define page_to_phys(page)	virt_to_phys(page_to_virt(page))
diff --git a/arch/openrisc/include/asm/io.h b/arch/openrisc/include/asm/io.h
index 7c691399da3f..4f7636e7901d 100644
--- a/arch/openrisc/include/asm/io.h
+++ b/arch/openrisc/include/asm/io.h
@@ -39,6 +39,7 @@ static inline void __iomem *ioremap(phys_addr_t offset, unsigned long size)
 {
 	return __ioremap(offset, size, PAGE_KERNEL);
 }
+#define ioremap ioremap
 
 /* #define _PAGE_CI       0x002 */
 static inline void __iomem *ioremap_nocache(phys_addr_t offset,
@@ -47,6 +48,6 @@ static inline void __iomem *ioremap_nocache(phys_addr_t offset,
 	return __ioremap(offset, size,
 			 __pgprot(pgprot_val(PAGE_KERNEL) | _PAGE_CI));
 }
+#define ioremap_nocache ioremap_nocache
 
-extern void iounmap(void *addr);
 #endif
diff --git a/arch/openrisc/mm/ioremap.c b/arch/openrisc/mm/ioremap.c
index 62b08ef392be..2af1bbe5f80c 100644
--- a/arch/openrisc/mm/ioremap.c
+++ b/arch/openrisc/mm/ioremap.c
@@ -81,7 +81,7 @@ __ioremap(phys_addr_t addr, unsigned long size, pgprot_t prot)
 	return (void __iomem *)(offset + (char *)v);
 }
 
-void iounmap(void *addr)
+void iounmap(volatile void __iomem *addr)
 {
 	/* If the page is from the fixmap pool then we just clear out
 	 * the fixmap mapping.
diff --git a/arch/parisc/include/asm/io.h b/arch/parisc/include/asm/io.h
index 8cd0abf28ffb..8a4ecb47f960 100644
--- a/arch/parisc/include/asm/io.h
+++ b/arch/parisc/include/asm/io.h
@@ -132,13 +132,11 @@ extern void __iomem * __ioremap(unsigned long offset, unsigned long size, unsign
 /* Most machines react poorly to I/O-space being cacheable... Instead let's
  * define ioremap() in terms of ioremap_nocache().
  */
-static inline void __iomem * ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem * ioremap(resource_size_t offset, unsigned long size)
 {
 	return __ioremap(offset, size, _PAGE_NO_CACHE);
 }
-#define ioremap_nocache(off, sz)	ioremap((off), (sz))
-
-extern void iounmap(const volatile void __iomem *addr);
+#define ioremap ioremap
 
 static inline unsigned char __raw_readb(const volatile void __iomem *addr)
 {
diff --git a/arch/parisc/mm/ioremap.c b/arch/parisc/mm/ioremap.c
index 838d0259cd27..3830d8af80a4 100644
--- a/arch/parisc/mm/ioremap.c
+++ b/arch/parisc/mm/ioremap.c
@@ -91,7 +91,7 @@ void __iomem * __ioremap(unsigned long phys_addr, unsigned long size, unsigned l
 }
 EXPORT_SYMBOL(__ioremap);
 
-void iounmap(const volatile void __iomem *addr)
+void iounmap(volatile void __iomem *addr)
 {
 	if (addr > high_memory)
 		return vfree((void *) (PAGE_MASK & (unsigned long __force) addr));
diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
index a8d2ef30d473..081f7d3d8913 100644
--- a/arch/powerpc/include/asm/io.h
+++ b/arch/powerpc/include/asm/io.h
@@ -2,8 +2,6 @@
 #define _ASM_POWERPC_IO_H
 #ifdef __KERNEL__
 
-#define ARCH_HAS_IOREMAP_WC
-
 /*
  * This program is free software; you can redistribute it and/or
  * modify it under the terms of the GNU General Public License
@@ -25,7 +23,6 @@ extern struct pci_dev *isa_bridge_pcidev;
 #endif
 
 #include <linux/device.h>
-#include <linux/io.h>
 
 #include <linux/compiler.h>
 #include <asm/page.h>
@@ -717,12 +714,14 @@ static inline void iosync(void)
  *
  */
 extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
+#define ioremap ioremap
 extern void __iomem *ioremap_prot(phys_addr_t address, unsigned long size,
 				  unsigned long flags);
 extern void __iomem *ioremap_wc(phys_addr_t address, unsigned long size);
-#define ioremap_nocache(addr, size)	ioremap((addr), (size))
+#define ioremap_wc ioremap_wc
 
 extern void iounmap(volatile void __iomem *addr);
+#define iounmap iounmap
 
 extern void __iomem *__ioremap(phys_addr_t, unsigned long size,
 			       unsigned long flags);
diff --git a/arch/s390/include/asm/io.h b/arch/s390/include/asm/io.h
index cb5fdf3a78fc..1cb32250d12b 100644
--- a/arch/s390/include/asm/io.h
+++ b/arch/s390/include/asm/io.h
@@ -27,18 +27,16 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 
 #ifdef CONFIG_PCI
 
-#define ioremap_nocache(addr, size)	ioremap(addr, size)
-#define ioremap_wc			ioremap_nocache
-#define ioremap_wt			ioremap_nocache
-
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return (void __iomem *) offset;
 }
+#define ioremap ioremap
 
 static inline void iounmap(volatile void __iomem *addr)
 {
 }
+#define iounmap iounmap
 
 static inline void __iomem *ioport_map(unsigned long port, unsigned int nr)
 {
diff --git a/arch/sh/include/asm/io.h b/arch/sh/include/asm/io.h
index 728c4c571f40..5fd16fe8ecc9 100644
--- a/arch/sh/include/asm/io.h
+++ b/arch/sh/include/asm/io.h
@@ -336,12 +336,14 @@ static inline void __iomem *ioremap(phys_addr_t offset, unsigned long size)
 {
 	return __ioremap_mode(offset, size, PAGE_KERNEL_NOCACHE);
 }
+#define ioremap ioremap
 
 static inline void __iomem *
 ioremap_cache(phys_addr_t offset, unsigned long size)
 {
 	return __ioremap_mode(offset, size, PAGE_KERNEL);
 }
+#define ioremap_cache ioremap_cache
 
 #ifdef CONFIG_HAVE_IOREMAP_PROT
 static inline void __iomem *
@@ -367,8 +369,11 @@ static inline void ioremap_fixed_init(void) { }
 static inline int iounmap_fixed(void __iomem *addr) { return -EINVAL; }
 #endif
 
-#define ioremap_nocache	ioremap
-#define iounmap		__iounmap
+static inline void iounmap(volatile void __iomem *addr)
+{
+	__iounmap(addr);
+}
+#define iounmap	iounmap
 
 /*
  * Convert a physical pointer to a virtual kernel pointer for /dev/mem
diff --git a/arch/sparc/include/asm/io_32.h b/arch/sparc/include/asm/io_32.h
index 57f26c398dc9..138e47e0c7d2 100644
--- a/arch/sparc/include/asm/io_32.h
+++ b/arch/sparc/include/asm/io_32.h
@@ -126,11 +126,8 @@ static inline void sbus_memcpy_toio(volatile void __iomem *dst,
  * Bus number may be embedded in the higher bits of the physical address.
  * This is why we have no bus number argument to ioremap().
  */
-void __iomem *ioremap(unsigned long offset, unsigned long size);
-#define ioremap_nocache(X,Y)	ioremap((X),(Y))
-#define ioremap_wc(X,Y)		ioremap((X),(Y))
-#define ioremap_wt(X,Y)		ioremap((X),(Y))
-void iounmap(volatile void __iomem *addr);
+void __iomem *ioremap(resource_size_t offset, unsigned long size);
+#define ioremap ioremap
 
 /* Create a virtual mapping cookie for an IO port range */
 void __iomem *ioport_map(unsigned long port, unsigned int nr);
diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index c32fa3f752c8..47e90988b562 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -395,18 +395,16 @@ static inline void memcpy_toio(volatile void __iomem *dst, const void *src,
 /* On sparc64 we have the whole physical IO address space accessible
  * using physically addressed loads and stores, so this does nothing.
  */
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return (void __iomem *)offset;
 }
-
-#define ioremap_nocache(X,Y)		ioremap((X),(Y))
-#define ioremap_wc(X,Y)			ioremap((X),(Y))
-#define ioremap_wt(X,Y)			ioremap((X),(Y))
+#define ioremap ioremap
 
 static inline void iounmap(volatile void __iomem *addr)
 {
 }
+#define iounmap iounmap
 
 #define ioread8			readb
 #define ioread16		readw
diff --git a/arch/sparc/kernel/ioport.c b/arch/sparc/kernel/ioport.c
index 28fed53b13a0..b8c999f5b821 100644
--- a/arch/sparc/kernel/ioport.c
+++ b/arch/sparc/kernel/ioport.c
@@ -121,7 +121,7 @@ static void xres_free(struct xresource *xrp) {
  *
  * Bus type is always zero on IIep.
  */
-void __iomem *ioremap(unsigned long offset, unsigned long size)
+void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	char name[14];
 
diff --git a/arch/tile/include/asm/io.h b/arch/tile/include/asm/io.h
index dc61de15c1f9..bf7f0fffb8db 100644
--- a/arch/tile/include/asm/io.h
+++ b/arch/tile/include/asm/io.h
@@ -48,14 +48,19 @@ extern void __iomem *ioremap_prot(resource_size_t offset, unsigned long size,
 	pgprot_t pgprot);
 extern void iounmap(volatile void __iomem *addr);
 #else
-#define ioremap(physaddr, size)	((void __iomem *)(unsigned long)(physaddr))
-#define iounmap(addr)		((void)0)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
+{
+	return (void __force __iomem *) offset;
+}
+
+static inline void iounmap(volatile void __iomem *addr)
+{
+}
 #endif
+#define ioremap ioremap
+#define iounmap iounmap
 
-#define ioremap_nocache(physaddr, size)		ioremap(physaddr, size)
-#define ioremap_wc(physaddr, size)		ioremap(physaddr, size)
-#define ioremap_wt(physaddr, size)		ioremap(physaddr, size)
-#define ioremap_fullcache(physaddr, size)	ioremap(physaddr, size)
+#define ioremap_fullcache ioremap
 
 #define mmiowb()
 
diff --git a/arch/unicore32/include/asm/io.h b/arch/unicore32/include/asm/io.h
index cb1d8fd2b16b..1088450fabfd 100644
--- a/arch/unicore32/include/asm/io.h
+++ b/arch/unicore32/include/asm/io.h
@@ -18,7 +18,6 @@
 #include <asm/memory.h>
 
 #define PCI_IOBASE	PKUNITY_PCILIO_BASE
-#include <asm-generic/io.h>
 
 /*
  * __uc32_ioremap and __uc32_ioremap_cached takes CPU physical address.
@@ -34,10 +33,26 @@ extern void __uc32_iounmap(volatile void __iomem *addr);
  * Documentation/io-mapping.txt.
  *
  */
-#define ioremap(cookie, size)		__uc32_ioremap(cookie, size)
-#define ioremap_cached(cookie, size)	__uc32_ioremap_cached(cookie, size)
-#define ioremap_nocache(cookie, size)	__uc32_ioremap(cookie, size)
-#define iounmap(cookie)			__uc32_iounmap(cookie)
+static inline void __iomem *ioremap(resource_size_t cookie, unsigned long size)
+{
+	return __uc32_ioremap(cookie, size);
+}
+#define ioremap ioremap
+
+static inline void __iomem *ioremap_cache(resource_size_t cookie, unsigned long size)
+{
+	return __uc32_ioremap_cached(cookie, size);
+}
+#define ioremap_cache ioremap_cache
+#define ioremap_cached ioremap_cached
+
+static inline void iounmap(volatile void __iomem *addr)
+{
+	return __uc32_iounmap(addr);
+}
+#define iounmap iounmap
+
+#include <asm-generic/io.h>
 
 #define readb_relaxed readb
 #define readw_relaxed readw
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 83ec9b1d77cc..97ae3b748d9e 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -34,9 +34,6 @@
   *  - Arnaldo Carvalho de Melo <acme@conectiva.com.br>
   */
 
-#define ARCH_HAS_IOREMAP_WC
-#define ARCH_HAS_IOREMAP_WT
-
 #include <linux/string.h>
 #include <linux/compiler.h>
 #include <asm/page.h>
@@ -179,8 +176,10 @@ static inline unsigned int isa_virt_to_bus(volatile void *address)
  * look at pci_iomap().
  */
 extern void __iomem *ioremap_nocache(resource_size_t offset, unsigned long size);
+#define ioremap_nocache ioremap_nocache
 extern void __iomem *ioremap_uc(resource_size_t offset, unsigned long size);
 extern void __iomem *ioremap_cache(resource_size_t offset, unsigned long size);
+#define ioremap_cache ioremap_cache
 extern void __iomem *ioremap_prot(resource_size_t offset, unsigned long size,
 				unsigned long prot_val);
 
@@ -191,8 +190,10 @@ static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return ioremap_nocache(offset, size);
 }
+#define ioremap ioremap
 
 extern void iounmap(volatile void __iomem *addr);
+#define iounmap iounmap
 
 extern void set_iounmap_nonlazy(void);
 
@@ -321,7 +322,9 @@ extern void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 extern int ioremap_change_attr(unsigned long vaddr, unsigned long size,
 				enum page_cache_mode pcm);
 extern void __iomem *ioremap_wc(resource_size_t offset, unsigned long size);
+#define ioremap_wc ioremap_wc
 extern void __iomem *ioremap_wt(resource_size_t offset, unsigned long size);
+#define ioremap_wt ioremap_wt
 
 extern bool is_early_ioremap_ptep(pte_t *ptep);
 
diff --git a/arch/xtensa/include/asm/io.h b/arch/xtensa/include/asm/io.h
index c39bb6e61911..ae20fc5a1b5f 100644
--- a/arch/xtensa/include/asm/io.h
+++ b/arch/xtensa/include/asm/io.h
@@ -38,7 +38,7 @@ static inline unsigned long xtensa_get_kio_paddr(void)
  * Return the virtual address for the specified bus memory.
  * Note that we currently don't support any address outside the KIO segment.
  */
-static inline void __iomem *ioremap_nocache(unsigned long offset,
+static inline void __iomem *ioremap_nocache(resource_size_t offset,
 		unsigned long size)
 {
 	if (offset >= XCHAL_KIO_PADDR
@@ -47,8 +47,9 @@ static inline void __iomem *ioremap_nocache(unsigned long offset,
 	else
 		BUG();
 }
+#define ioremap_nocache ioremap_nocache
 
-static inline void __iomem *ioremap_cache(unsigned long offset,
+static inline void __iomem *ioremap_cache(resource_size_t offset,
 		unsigned long size)
 {
 	if (offset >= XCHAL_KIO_PADDR
@@ -57,18 +58,18 @@ static inline void __iomem *ioremap_cache(unsigned long offset,
 	else
 		BUG();
 }
+#define ioremap_cache ioremap_cache
 
-#define ioremap_wc ioremap_nocache
-#define ioremap_wt ioremap_nocache
-
-static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 {
 	return ioremap_nocache(offset, size);
 }
+#define ioremap ioremap
 
 static inline void iounmap(volatile void __iomem *addr)
 {
 }
+#define iounmap iounmap
 
 #define virt_to_bus     virt_to_phys
 #define bus_to_virt     phys_to_virt
diff --git a/drivers/net/ethernet/sfc/io.h b/drivers/net/ethernet/sfc/io.h
index afb94aa2c15e..9d54dd7f4c72 100644
--- a/drivers/net/ethernet/sfc/io.h
+++ b/drivers/net/ethernet/sfc/io.h
@@ -73,7 +73,7 @@
  */
 #ifdef CONFIG_X86_64
 /* PIO is a win only if write-combining is possible */
-#ifdef ARCH_HAS_IOREMAP_WC
+#ifdef ioremap_wc
 #define EFX_USE_PIO 1
 #endif
 #endif
diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
index d8f8622fa044..4789b1cec313 100644
--- a/include/asm-generic/iomap.h
+++ b/include/asm-generic/iomap.h
@@ -62,14 +62,6 @@ extern void __iomem *ioport_map(unsigned long port, unsigned int nr);
 extern void ioport_unmap(void __iomem *);
 #endif
 
-#ifndef ARCH_HAS_IOREMAP_WC
-#define ioremap_wc ioremap_nocache
-#endif
-
-#ifndef ARCH_HAS_IOREMAP_WT
-#define ioremap_wt ioremap_nocache
-#endif
-
 #ifdef CONFIG_PCI
 /* Destroy a virtual mapping cookie for a PCI BAR (memory or IO) */
 struct pci_dev;
diff --git a/include/linux/io.h b/include/linux/io.h
index fb5a99800e77..41e93fe14b3c 100644
--- a/include/linux/io.h
+++ b/include/linux/io.h
@@ -80,6 +80,64 @@ int check_signature(const volatile void __iomem *io_addr,
 			const unsigned char *signature, int length);
 void devm_ioremap_release(struct device *dev, void *res);
 
+#ifndef ioremap
+void __iomem *ioremap(resource_size_t offset, unsigned long size);
+#endif
+
+#ifndef iounmap
+void iounmap(volatile void __iomem *addr);
+#endif
+
+#ifndef ioremap_nocache
+static inline void __iomem *ioremap_nocache(resource_size_t offset,
+		unsigned long size)
+{
+	return ioremap(offset, size);
+}
+#endif
+
+#ifndef ioremap_wc
+static inline void __iomem *ioremap_wc(resource_size_t offset,
+		unsigned long size)
+{
+	return ioremap(offset, size);
+}
+#endif
+
+#ifndef ioremap_wt
+static inline void __iomem *ioremap_wt(resource_size_t offset,
+		unsigned long size)
+{
+	return ioremap(offset, size);
+}
+#endif
+
+#ifndef ioremap_cache
+static inline void __iomem *ioremap_cache(resource_size_t offset,
+		unsigned long size)
+{
+	return ioremap(offset, size);
+}
+#endif
+
+/*
+ * Throw warnings if an arch fails to define or uses unexpected data
+ * types in its ioremap implementations.
+ */
+static inline void ioremap_test(void)
+{
+	void __iomem *(*map)(resource_size_t offset, unsigned long size)
+		__always_unused;
+	void (*unmap)(volatile void __iomem *addr) __always_unused;
+
+	map = ioremap;
+	map = ioremap_nocache;
+	map = ioremap_cache;
+	map = ioremap_wc;
+	map = ioremap_wt;
+	unmap = iounmap;
+}
+
 /*
  * Some systems do not have legacy ISA devices.
  * /dev/port is not a valid interface on these systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
