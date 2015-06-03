Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 61E58900016
	for <linux-mm@kvack.org>; Wed,  3 Jun 2015 17:37:15 -0400 (EDT)
Received: by padjw17 with SMTP id jw17so15215028pad.2
        for <linux-mm@kvack.org>; Wed, 03 Jun 2015 14:37:15 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id b9si2681062pas.133.2015.06.03.14.37.14
        for <linux-mm@kvack.org>;
        Wed, 03 Jun 2015 14:37:14 -0700 (PDT)
Subject: [PATCH v3 3/6] arch/*/asm/io.h: add ioremap_cache() to all
 architectures
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 03 Jun 2015 17:34:28 -0400
Message-ID: <20150603213428.13749.99455.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <20150603211948.13749.85816.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: arnd@arndb.de, mingo@redhat.com, bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, ross.zwisler@linux.intel.com, akpm@linux-foundation.org
Cc: jgross@suse.com, x86@kernel.org, toshi.kani@hp.com, linux-nvdimm@lists.01.org, benh@kernel.crashing.org, mcgrof@suse.com, konrad.wilk@oracle.com, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, linux-mm@kvack.org, geert@linux-m68k.org, ralf@linux-mips.org, hmh@hmh.eng.br, mpe@ellerman.id.au, tj@kernel.org, paulus@samba.org, hch@lst.de

Similar to ioremap_wc() let architecture implementations optionally
provide ioremap_cache().  As is, current ioremap_cache() users have
architecture dependencies that prevent them from compiling on archs
without ioremap_cache().  In some cases the architectures that have a
cached ioremap() capability have an identifier other than
"ioremap_cache".

Allow drivers to compile with ioremap_cache() support and fallback to a
safe / uncached ioremap otherwise.

Cc: Toshi Kani <toshi.kani@hp.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/arc/include/asm/io.h        |    1 +
 arch/arm/include/asm/io.h        |    2 ++
 arch/arm64/include/asm/io.h      |    3 +++
 arch/avr32/include/asm/io.h      |    1 +
 arch/frv/include/asm/io.h        |    6 ++++++
 arch/ia64/include/asm/io.h       |    5 -----
 arch/m32r/include/asm/io.h       |    1 +
 arch/m68k/include/asm/io_mm.h    |    7 +++++++
 arch/m68k/include/asm/io_no.h    |    5 +++++
 arch/metag/include/asm/io.h      |    5 +++++
 arch/microblaze/include/asm/io.h |    1 +
 arch/mips/include/asm/io.h       |   17 +++++++++++++----
 arch/mn10300/include/asm/io.h    |    1 +
 arch/nios2/include/asm/io.h      |    1 +
 arch/s390/include/asm/io.h       |    1 +
 arch/sparc/include/asm/io_32.h   |    1 +
 arch/sparc/include/asm/io_64.h   |    1 +
 arch/tile/include/asm/io.h       |    1 +
 arch/x86/include/asm/io.h        |    1 +
 arch/xtensa/include/asm/io.h     |    3 +++
 include/asm-generic/io.h         |    8 ++++++++
 include/asm-generic/iomap.h      |    4 ++++
 22 files changed, 67 insertions(+), 9 deletions(-)

diff --git a/arch/arc/include/asm/io.h b/arch/arc/include/asm/io.h
index 7cc4ced5dbf4..6b6f5a47acec 100644
--- a/arch/arc/include/asm/io.h
+++ b/arch/arc/include/asm/io.h
@@ -19,6 +19,7 @@ extern void __iomem *ioremap_prot(phys_addr_t offset, unsigned long size,
 extern void iounmap(const void __iomem *addr);
 
 #define ioremap_nocache(phy, sz)	ioremap(phy, sz)
+#define ioremap_cache(phy, sz)		ioremap(phy, sz)
 #define ioremap_wc(phy, sz)		ioremap(phy, sz)
 #define ioremap_wt(phy, sz)		ioremap(phy, sz)
 
diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index 1b7677d1e5e1..5e2c5cbdffdc 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -23,6 +23,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_CACHE
+
 #include <linux/types.h>
 #include <linux/blk_types.h>
 #include <asm/byteorder.h>
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index 7116d3973058..6a8836c9d993 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -21,6 +21,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_CACHE
+
 #include <linux/types.h>
 #include <linux/blk_types.h>
 
@@ -171,6 +173,7 @@ extern void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size);
 #define ioremap_nocache(addr, size)	__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define ioremap_wc(addr, size)		__ioremap((addr), (size), __pgprot(PROT_NORMAL_NC))
 #define ioremap_wt(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
+#define ioremap_cache			ioremap_cache
 #define iounmap				__iounmap
 
 /*
diff --git a/arch/avr32/include/asm/io.h b/arch/avr32/include/asm/io.h
index e998ff5d8e1a..c6994d880dbd 100644
--- a/arch/avr32/include/asm/io.h
+++ b/arch/avr32/include/asm/io.h
@@ -297,6 +297,7 @@ extern void __iounmap(void __iomem *addr);
 
 #define ioremap_wc ioremap_nocache
 #define ioremap_wt ioremap_nocache
+#define ioremap_cache ioremap_nocache
 
 #define cached(addr) P1SEGADDR(addr)
 #define uncached(addr) P2SEGADDR(addr)
diff --git a/arch/frv/include/asm/io.h b/arch/frv/include/asm/io.h
index a31b63ec4930..cd841f852af3 100644
--- a/arch/frv/include/asm/io.h
+++ b/arch/frv/include/asm/io.h
@@ -18,6 +18,7 @@
 #ifdef __KERNEL__
 
 #define ARCH_HAS_IOREMAP_WT
+#define ARCH_HAS_IOREMAP_CACHE
 
 #include <linux/types.h>
 #include <asm/virtconvert.h>
@@ -277,6 +278,11 @@ static inline void __iomem *ioremap_fullcache(unsigned long physaddr, unsigned l
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
 }
 
+static inline void __iomem *ioremap_cache(unsigned long physaddr, unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
+}
+
 #define ioremap_wc ioremap_nocache
 
 extern void iounmap(void volatile __iomem *addr);
diff --git a/arch/ia64/include/asm/io.h b/arch/ia64/include/asm/io.h
index 8588ef767a44..cba265c30c3c 100644
--- a/arch/ia64/include/asm/io.h
+++ b/arch/ia64/include/asm/io.h
@@ -431,11 +431,6 @@ extern void __iomem * early_ioremap (unsigned long phys_addr, unsigned long size
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
diff --git a/arch/m32r/include/asm/io.h b/arch/m32r/include/asm/io.h
index 0c3f25ee3381..f3eceeac25c8 100644
--- a/arch/m32r/include/asm/io.h
+++ b/arch/m32r/include/asm/io.h
@@ -67,6 +67,7 @@ static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 
 extern void iounmap(volatile void __iomem *addr);
 #define ioremap_nocache(off,size) ioremap(off,size)
+#define ioremap_cache ioremap_nocache
 #define ioremap_wc ioremap_nocache
 #define ioremap_wt ioremap_nocache
 
diff --git a/arch/m68k/include/asm/io_mm.h b/arch/m68k/include/asm/io_mm.h
index 618c85d3c786..aaf1009f2f94 100644
--- a/arch/m68k/include/asm/io_mm.h
+++ b/arch/m68k/include/asm/io_mm.h
@@ -21,6 +21,7 @@
 #ifdef __KERNEL__
 
 #define ARCH_HAS_IOREMAP_WT
+#define ARCH_HAS_IOREMAP_CACHE
 
 #include <linux/compiler.h>
 #include <asm/raw_io.h>
@@ -478,6 +479,12 @@ static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
 }
 
+static inline void __iomem *ioremap_cache(unsigned long physaddr,
+		unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
+}
+
 static inline void memset_io(volatile void __iomem *addr, unsigned char val, int count)
 {
 	__builtin_memset((void __force *) addr, val, count);
diff --git a/arch/m68k/include/asm/io_no.h b/arch/m68k/include/asm/io_no.h
index ad7bd40e6742..020483566b73 100644
--- a/arch/m68k/include/asm/io_no.h
+++ b/arch/m68k/include/asm/io_no.h
@@ -4,6 +4,7 @@
 #ifdef __KERNEL__
 
 #define ARCH_HAS_IOREMAP_WT
+#define ARCH_HAS_IOREMAP_CACHE
 
 #include <asm/virtconvert.h>
 #include <asm-generic/iomap.h>
@@ -163,6 +164,10 @@ static inline void *ioremap_fullcache(unsigned long physaddr, unsigned long size
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
 }
+static inline void *ioremap_cache(unsigned long physaddr, unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
+}
 
 #define	iounmap(addr)	do { } while(0)
 
diff --git a/arch/metag/include/asm/io.h b/arch/metag/include/asm/io.h
index 9890f21eadbe..d9b2873e3ca8 100644
--- a/arch/metag/include/asm/io.h
+++ b/arch/metag/include/asm/io.h
@@ -1,6 +1,8 @@
 #ifndef _ASM_METAG_IO_H
 #define _ASM_METAG_IO_H
 
+#define ARCH_HAS_IOREMAP_CACHE
+
 #include <linux/types.h>
 #include <asm/pgtable-bits.h>
 
@@ -157,6 +159,9 @@ extern void __iounmap(void __iomem *addr);
 #define ioremap_cached(offset, size)            \
 	__ioremap((offset), (size), _PAGE_CACHEABLE)
 
+#define ioremap_cache(offset, size)            \
+	__ioremap((offset), (size), _PAGE_CACHEABLE)
+
 #define ioremap_wc(offset, size)                \
 	__ioremap((offset), (size), _PAGE_WR_COMBINE)
 
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index 39b6315db82e..986cc0c9e67f 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -43,6 +43,7 @@ extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
 #define ioremap_fullcache(addr, size)		ioremap((addr), (size))
 #define ioremap_wc(addr, size)			ioremap((addr), (size))
 #define ioremap_wt(addr, size)			ioremap((addr), (size))
+#define ioremap_cache(addr, size)		ioremap((addr), (size))
 
 #endif /* CONFIG_MMU */
 
diff --git a/arch/mips/include/asm/io.h b/arch/mips/include/asm/io.h
index 9e777cd42b67..6d4c3ae146a5 100644
--- a/arch/mips/include/asm/io.h
+++ b/arch/mips/include/asm/io.h
@@ -12,6 +12,8 @@
 #ifndef _ASM_IO_H
 #define _ASM_IO_H
 
+#define ARCH_HAS_IOREMAP_CACHE
+
 #include <linux/compiler.h>
 #include <linux/kernel.h>
 #include <linux/types.h>
@@ -232,8 +234,10 @@ static inline void __iomem * __ioremap_mode(phys_addr_t offset, unsigned long si
  * address is not guaranteed to be usable directly as a virtual
  * address.
  */
-#define ioremap(offset, size)						\
-	__ioremap_mode((offset), (size), _CACHE_UNCACHED)
+static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
+{
+	return __ioremap_mode(offset, size, _CACHE_UNCACHED);
+}
 
 /*
  * ioremap_nocache     -   map bus memory into CPU space
@@ -254,8 +258,7 @@ static inline void __iomem * __ioremap_mode(phys_addr_t offset, unsigned long si
  * It's useful if some control registers are in such an area and
  * write combining or read caching is not desirable:
  */
-#define ioremap_nocache(offset, size)					\
-	__ioremap_mode((offset), (size), _CACHE_UNCACHED)
+#define ioremap_nocache ioremap
 
 /*
  * ioremap_cachable -	map bus memory into CPU space
@@ -272,8 +275,14 @@ static inline void __iomem * __ioremap_mode(phys_addr_t offset, unsigned long si
  * the CPU.  Also enables full write-combining.	 Useful for some
  * memory-like regions on I/O busses.
  */
+extern unsigned long _page_cachable_default;
 #define ioremap_cachable(offset, size)					\
 	__ioremap_mode((offset), (size), _page_cachable_default)
+static inline void __iomem *ioremap_cache(resource_size_t offset,
+		unsigned long size)
+{
+	return ioremap_cachable(offset, size);
+}
 
 /*
  * These two are MIPS specific ioremap variant.	 ioremap_cacheable_cow
diff --git a/arch/mn10300/include/asm/io.h b/arch/mn10300/include/asm/io.h
index 07c5b4a3903b..dcab414f40df 100644
--- a/arch/mn10300/include/asm/io.h
+++ b/arch/mn10300/include/asm/io.h
@@ -283,6 +283,7 @@ static inline void __iomem *ioremap_nocache(unsigned long offset, unsigned long
 
 #define ioremap_wc ioremap_nocache
 #define ioremap_wt ioremap_nocache
+#define ioremap_cache ioremap_nocache
 
 static inline void iounmap(void __iomem *addr)
 {
diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
index c5a62da22cd2..367e2ea7663a 100644
--- a/arch/nios2/include/asm/io.h
+++ b/arch/nios2/include/asm/io.h
@@ -47,6 +47,7 @@ static inline void iounmap(void __iomem *addr)
 
 #define ioremap_wc ioremap_nocache
 #define ioremap_wt ioremap_nocache
+#define ioremap_cache ioremap_nocache
 
 /* Pages to physical address... */
 #define page_to_phys(page)	virt_to_phys(page_to_virt(page))
diff --git a/arch/s390/include/asm/io.h b/arch/s390/include/asm/io.h
index cb5fdf3a78fc..6824c3daa2a1 100644
--- a/arch/s390/include/asm/io.h
+++ b/arch/s390/include/asm/io.h
@@ -30,6 +30,7 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 #define ioremap_nocache(addr, size)	ioremap(addr, size)
 #define ioremap_wc			ioremap_nocache
 #define ioremap_wt			ioremap_nocache
+#define ioremap_cache			ioremap_nocache
 
 static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 {
diff --git a/arch/sparc/include/asm/io_32.h b/arch/sparc/include/asm/io_32.h
index 57f26c398dc9..b9a734caf57d 100644
--- a/arch/sparc/include/asm/io_32.h
+++ b/arch/sparc/include/asm/io_32.h
@@ -128,6 +128,7 @@ static inline void sbus_memcpy_toio(volatile void __iomem *dst,
  */
 void __iomem *ioremap(unsigned long offset, unsigned long size);
 #define ioremap_nocache(X,Y)	ioremap((X),(Y))
+#define ioremap_cache(X,Y)	ioremap((X),(Y))
 #define ioremap_wc(X,Y)		ioremap((X),(Y))
 #define ioremap_wt(X,Y)		ioremap((X),(Y))
 void iounmap(volatile void __iomem *addr);
diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index b99ae1fac174..61f5d04da892 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -401,6 +401,7 @@ static inline void __iomem *ioremap(resource_size_t offset, unsigned long size)
 }
 
 #define ioremap_nocache ioremap
+#define ioremap_cache ioremap
 #define ioremap_wc ioremap
 #define ioremap_wt ioremap
 
diff --git a/arch/tile/include/asm/io.h b/arch/tile/include/asm/io.h
index dc61de15c1f9..fe853a135e25 100644
--- a/arch/tile/include/asm/io.h
+++ b/arch/tile/include/asm/io.h
@@ -53,6 +53,7 @@ extern void iounmap(volatile void __iomem *addr);
 #endif
 
 #define ioremap_nocache(physaddr, size)		ioremap(physaddr, size)
+#define ioremap_cache(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wc(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wt(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_fullcache(physaddr, size)	ioremap(physaddr, size)
diff --git a/arch/x86/include/asm/io.h b/arch/x86/include/asm/io.h
index 6c3a130de503..956f2768bdc1 100644
--- a/arch/x86/include/asm/io.h
+++ b/arch/x86/include/asm/io.h
@@ -36,6 +36,7 @@
 
 #define ARCH_HAS_IOREMAP_WC
 #define ARCH_HAS_IOREMAP_WT
+#define ARCH_HAS_IOREMAP_CACHE
 
 #include <linux/string.h>
 #include <linux/compiler.h>
diff --git a/arch/xtensa/include/asm/io.h b/arch/xtensa/include/asm/io.h
index c39bb6e61911..f91a8a99aa29 100644
--- a/arch/xtensa/include/asm/io.h
+++ b/arch/xtensa/include/asm/io.h
@@ -12,6 +12,9 @@
 #define _XTENSA_IO_H
 
 #ifdef __KERNEL__
+
+#define ARCH_HAS_IOREMAP_CACHE
+
 #include <asm/byteorder.h>
 #include <asm/page.h>
 #include <asm/vectors.h>
diff --git a/include/asm-generic/io.h b/include/asm-generic/io.h
index f56094cfdeff..a0665dfcab47 100644
--- a/include/asm-generic/io.h
+++ b/include/asm-generic/io.h
@@ -793,6 +793,14 @@ static inline void __iomem *ioremap_wt(phys_addr_t offset, size_t size)
 }
 #endif
 
+#ifndef ioremap_cache
+#define ioremap_cache ioremap_cache
+static inline void __iomem *ioremap_cache(phys_addr_t offset, size_t size)
+{
+	return ioremap_nocache(offset, size);
+}
+#endif
+
 #ifndef iounmap
 #define iounmap iounmap
 
diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
index d8f8622fa044..f0f30464cecd 100644
--- a/include/asm-generic/iomap.h
+++ b/include/asm-generic/iomap.h
@@ -70,6 +70,10 @@ extern void ioport_unmap(void __iomem *);
 #define ioremap_wt ioremap_nocache
 #endif
 
+#ifndef ARCH_HAS_IOREMAP_CACHE
+#define ioremap_cache ioremap_nocache
+#endif
+
 #ifdef CONFIG_PCI
 /* Destroy a virtual mapping cookie for a PCI BAR (memory or IO) */
 struct pci_dev;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
