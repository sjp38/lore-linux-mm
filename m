Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f45.google.com (mail-oi0-f45.google.com [209.85.218.45])
	by kanga.kvack.org (Postfix) with ESMTP id BC6D56B0078
	for <linux-mm@kvack.org>; Fri, 29 May 2015 19:19:04 -0400 (EDT)
Received: by oiww2 with SMTP id w2so67596136oiw.0
        for <linux-mm@kvack.org>; Fri, 29 May 2015 16:19:04 -0700 (PDT)
Received: from g9t5009.houston.hp.com (g9t5009.houston.hp.com. [15.240.92.67])
        by mx.google.com with ESMTPS id w2si4429275obp.3.2015.05.29.16.19.02
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 16:19:03 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v11 7/12] arch/*/asm/io.h: Add ioremap_wt() to all architectures
Date: Fri, 29 May 2015 16:59:05 -0600
Message-Id: <1432940350-1802-8-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

From: Toshi Kani <toshi.kani@hp.com>

This patch adds ioremap_wt() to all arch-specific asm/io.h which
define ioremap_wc() locally.  These arch-specific asm/io.h do not
include <asm-generic/iomap.h>.  Some of them include
<asm-generic/io.h>, but ioremap_wt() is defined for consistency
since they define all ioremap_xxx locally.

ioremap_wt() is defined indentical to ioremap_nocache() to all
architectures without WT support.

frv and m68k already have ioremap_writethrough().  This patch
implements ioremap_wt() indetical to ioremap_writethrough() and
defines ARCH_HAS_IOREMAP_WT in both architectures.

This patch allows generic drivers to use ioremap_wt().

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/arc/include/asm/io.h        |    1 +
 arch/arm/include/asm/io.h        |    1 +
 arch/arm64/include/asm/io.h      |    1 +
 arch/avr32/include/asm/io.h      |    1 +
 arch/frv/include/asm/io.h        |    7 +++++++
 arch/m32r/include/asm/io.h       |    1 +
 arch/m68k/include/asm/io_mm.h    |    7 +++++++
 arch/m68k/include/asm/io_no.h    |    6 ++++++
 arch/metag/include/asm/io.h      |    3 +++
 arch/microblaze/include/asm/io.h |    1 +
 arch/mn10300/include/asm/io.h    |    1 +
 arch/nios2/include/asm/io.h      |    1 +
 arch/s390/include/asm/io.h       |    1 +
 arch/sparc/include/asm/io_32.h   |    1 +
 arch/sparc/include/asm/io_64.h   |    1 +
 arch/tile/include/asm/io.h       |    1 +
 arch/xtensa/include/asm/io.h     |    1 +
 17 files changed, 36 insertions(+)

diff --git a/arch/arc/include/asm/io.h b/arch/arc/include/asm/io.h
index cabd518..7cc4ced 100644
--- a/arch/arc/include/asm/io.h
+++ b/arch/arc/include/asm/io.h
@@ -20,6 +20,7 @@ extern void iounmap(const void __iomem *addr);
 
 #define ioremap_nocache(phy, sz)	ioremap(phy, sz)
 #define ioremap_wc(phy, sz)		ioremap(phy, sz)
+#define ioremap_wt(phy, sz)		ioremap(phy, sz)
 
 /* Change struct page to physical address */
 #define page_to_phys(page)		(page_to_pfn(page) << PAGE_SHIFT)
diff --git a/arch/arm/include/asm/io.h b/arch/arm/include/asm/io.h
index db58deb..1b7677d 100644
--- a/arch/arm/include/asm/io.h
+++ b/arch/arm/include/asm/io.h
@@ -336,6 +336,7 @@ extern void _memset_io(volatile void __iomem *, int, size_t);
 #define ioremap_nocache(cookie,size)	__arm_ioremap((cookie), (size), MT_DEVICE)
 #define ioremap_cache(cookie,size)	__arm_ioremap((cookie), (size), MT_DEVICE_CACHED)
 #define ioremap_wc(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE_WC)
+#define ioremap_wt(cookie,size)		__arm_ioremap((cookie), (size), MT_DEVICE)
 #define iounmap				__arm_iounmap
 
 /*
diff --git a/arch/arm64/include/asm/io.h b/arch/arm64/include/asm/io.h
index 540f7c0..7116d39 100644
--- a/arch/arm64/include/asm/io.h
+++ b/arch/arm64/include/asm/io.h
@@ -170,6 +170,7 @@ extern void __iomem *ioremap_cache(phys_addr_t phys_addr, size_t size);
 #define ioremap(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define ioremap_nocache(addr, size)	__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define ioremap_wc(addr, size)		__ioremap((addr), (size), __pgprot(PROT_NORMAL_NC))
+#define ioremap_wt(addr, size)		__ioremap((addr), (size), __pgprot(PROT_DEVICE_nGnRE))
 #define iounmap				__iounmap
 
 /*
diff --git a/arch/avr32/include/asm/io.h b/arch/avr32/include/asm/io.h
index 4f5ec2b..e998ff5 100644
--- a/arch/avr32/include/asm/io.h
+++ b/arch/avr32/include/asm/io.h
@@ -296,6 +296,7 @@ extern void __iounmap(void __iomem *addr);
 	__iounmap(addr)
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 #define cached(addr) P1SEGADDR(addr)
 #define uncached(addr) P2SEGADDR(addr)
diff --git a/arch/frv/include/asm/io.h b/arch/frv/include/asm/io.h
index 0b78bc8..1fe98fe 100644
--- a/arch/frv/include/asm/io.h
+++ b/arch/frv/include/asm/io.h
@@ -17,6 +17,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_WT
+
 #include <linux/types.h>
 #include <asm/virtconvert.h>
 #include <asm/string.h>
@@ -270,6 +272,11 @@ static inline void __iomem *ioremap_writethrough(unsigned long physaddr, unsigne
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
 
+static inline void __iomem *ioremap_wt(unsigned long physaddr, unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
+}
+
 static inline void __iomem *ioremap_fullcache(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
diff --git a/arch/m32r/include/asm/io.h b/arch/m32r/include/asm/io.h
index 9cc00db..0c3f25e 100644
--- a/arch/m32r/include/asm/io.h
+++ b/arch/m32r/include/asm/io.h
@@ -68,6 +68,7 @@ static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 extern void iounmap(volatile void __iomem *addr);
 #define ioremap_nocache(off,size) ioremap(off,size)
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 /*
  * IO bus memory addresses are also 1:1 with the physical address
diff --git a/arch/m68k/include/asm/io_mm.h b/arch/m68k/include/asm/io_mm.h
index 8955b40..7c12138 100644
--- a/arch/m68k/include/asm/io_mm.h
+++ b/arch/m68k/include/asm/io_mm.h
@@ -20,6 +20,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_WT
+
 #include <linux/compiler.h>
 #include <asm/raw_io.h>
 #include <asm/virtconvert.h>
@@ -470,6 +472,11 @@ static inline void __iomem *ioremap_writethrough(unsigned long physaddr,
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
+static inline void __iomem *ioremap_wt(unsigned long physaddr,
+					 unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
+}
 static inline void __iomem *ioremap_fullcache(unsigned long physaddr,
 				      unsigned long size)
 {
diff --git a/arch/m68k/include/asm/io_no.h b/arch/m68k/include/asm/io_no.h
index a93c8cd..5fff9a2 100644
--- a/arch/m68k/include/asm/io_no.h
+++ b/arch/m68k/include/asm/io_no.h
@@ -3,6 +3,8 @@
 
 #ifdef __KERNEL__
 
+#define ARCH_HAS_IOREMAP_WT
+
 #include <asm/virtconvert.h>
 #include <asm-generic/iomap.h>
 
@@ -157,6 +159,10 @@ static inline void *ioremap_writethrough(unsigned long physaddr, unsigned long s
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
 }
+static inline void *ioremap_wt(unsigned long physaddr, unsigned long size)
+{
+	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
+}
 static inline void *ioremap_fullcache(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_FULL_CACHING);
diff --git a/arch/metag/include/asm/io.h b/arch/metag/include/asm/io.h
index d5779b0..9890f21 100644
--- a/arch/metag/include/asm/io.h
+++ b/arch/metag/include/asm/io.h
@@ -160,6 +160,9 @@ extern void __iounmap(void __iomem *addr);
 #define ioremap_wc(offset, size)                \
 	__ioremap((offset), (size), _PAGE_WR_COMBINE)
 
+#define ioremap_wt(offset, size)                \
+	__ioremap((offset), (size), 0)
+
 #define iounmap(addr)                           \
 	__iounmap(addr)
 
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index 940f5fc..ec3da11 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -43,6 +43,7 @@ extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
 #define ioremap_nocache(addr, size)		ioremap((addr), (size))
 #define ioremap_fullcache(addr, size)		ioremap((addr), (size))
 #define ioremap_wc(addr, size)			ioremap((addr), (size))
+#define ioremap_wt(addr, size)			ioremap((addr), (size))
 
 #endif /* CONFIG_MMU */
 
diff --git a/arch/mn10300/include/asm/io.h b/arch/mn10300/include/asm/io.h
index cc4a2ba..07c5b4a 100644
--- a/arch/mn10300/include/asm/io.h
+++ b/arch/mn10300/include/asm/io.h
@@ -282,6 +282,7 @@ static inline void __iomem *ioremap_nocache(unsigned long offset, unsigned long
 }
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 static inline void iounmap(void __iomem *addr)
 {
diff --git a/arch/nios2/include/asm/io.h b/arch/nios2/include/asm/io.h
index 6e24d7c..c5a62da 100644
--- a/arch/nios2/include/asm/io.h
+++ b/arch/nios2/include/asm/io.h
@@ -46,6 +46,7 @@ static inline void iounmap(void __iomem *addr)
 }
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 /* Pages to physical address... */
 #define page_to_phys(page)	virt_to_phys(page_to_virt(page))
diff --git a/arch/s390/include/asm/io.h b/arch/s390/include/asm/io.h
index 30fd5c8..cb5fdf3 100644
--- a/arch/s390/include/asm/io.h
+++ b/arch/s390/include/asm/io.h
@@ -29,6 +29,7 @@ void unxlate_dev_mem_ptr(phys_addr_t phys, void *addr);
 
 #define ioremap_nocache(addr, size)	ioremap(addr, size)
 #define ioremap_wc			ioremap_nocache
+#define ioremap_wt			ioremap_nocache
 
 static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 {
diff --git a/arch/sparc/include/asm/io_32.h b/arch/sparc/include/asm/io_32.h
index 407ac14..57f26c3 100644
--- a/arch/sparc/include/asm/io_32.h
+++ b/arch/sparc/include/asm/io_32.h
@@ -129,6 +129,7 @@ static inline void sbus_memcpy_toio(volatile void __iomem *dst,
 void __iomem *ioremap(unsigned long offset, unsigned long size);
 #define ioremap_nocache(X,Y)	ioremap((X),(Y))
 #define ioremap_wc(X,Y)		ioremap((X),(Y))
+#define ioremap_wt(X,Y)		ioremap((X),(Y))
 void iounmap(volatile void __iomem *addr);
 
 /* Create a virtual mapping cookie for an IO port range */
diff --git a/arch/sparc/include/asm/io_64.h b/arch/sparc/include/asm/io_64.h
index 50d4840..c32fa3f 100644
--- a/arch/sparc/include/asm/io_64.h
+++ b/arch/sparc/include/asm/io_64.h
@@ -402,6 +402,7 @@ static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 
 #define ioremap_nocache(X,Y)		ioremap((X),(Y))
 #define ioremap_wc(X,Y)			ioremap((X),(Y))
+#define ioremap_wt(X,Y)			ioremap((X),(Y))
 
 static inline void iounmap(volatile void __iomem *addr)
 {
diff --git a/arch/tile/include/asm/io.h b/arch/tile/include/asm/io.h
index 6ef4eca..9c3d950 100644
--- a/arch/tile/include/asm/io.h
+++ b/arch/tile/include/asm/io.h
@@ -54,6 +54,7 @@ extern void iounmap(volatile void __iomem *addr);
 
 #define ioremap_nocache(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wc(physaddr, size)		ioremap(physaddr, size)
+#define ioremap_wt(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_writethrough(physaddr, size)	ioremap(physaddr, size)
 #define ioremap_fullcache(physaddr, size)	ioremap(physaddr, size)
 
diff --git a/arch/xtensa/include/asm/io.h b/arch/xtensa/include/asm/io.h
index fe1600a..c39bb6e 100644
--- a/arch/xtensa/include/asm/io.h
+++ b/arch/xtensa/include/asm/io.h
@@ -59,6 +59,7 @@ static inline void __iomem *ioremap_cache(unsigned long offset,
 }
 
 #define ioremap_wc ioremap_nocache
+#define ioremap_wt ioremap_nocache
 
 static inline void __iomem *ioremap(unsigned long offset, unsigned long size)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
