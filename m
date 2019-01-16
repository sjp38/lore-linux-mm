Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 43FD08E0011
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:37 -0500 (EST)
Received: by mail-io1-f70.google.com with SMTP id c4so5341373ioh.16
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:37 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id 130si4091127jaz.43.2019.01.16.10.25.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 10:25:36 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 16 Jan 2019 11:25:20 -0700
Message-Id: <20190116182523.19446-4-logang@deltatee.com>
In-Reply-To: <20190116182523.19446-1-logang@deltatee.com>
References: <20190116182523.19446-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v25 3/6] iomap: introduce io{read|write}64_{lo_hi|hi_lo}
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, =?UTF-8?q?Horia=20Geant=C4=83?= <horia.geanta@nxp.com>, Logan Gunthorpe <logang@deltatee.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Suresh Warrier <warrier@linux.vnet.ibm.com>, Nicholas Piggin <npiggin@gmail.com>

In order to provide non-atomic functions for io{read|write}64 that will
use readq and writeq when appropriate. We define a number of variants
of these functions in the generic iomap that will do non-atomic
operations on pio but atomic operations on mmio.

These functions are only defined if readq and writeq are defined. If
they are not, then the wrappers that always use non-atomic operations
from include/linux/io-64-nonatomic*.h will be used.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Reviewed-by: Andy Shevchenko <andy.shevchenko@gmail.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Suresh Warrier <warrier@linux.vnet.ibm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/include/asm/io.h |   2 +
 include/asm-generic/iomap.h   |  22 ++++++
 lib/iomap.c                   | 132 ++++++++++++++++++++++++++++++++++
 3 files changed, 156 insertions(+)

diff --git a/arch/powerpc/include/asm/io.h b/arch/powerpc/include/asm/io.h
index 7f19fbd3ba55..4b73847e9b95 100644
--- a/arch/powerpc/include/asm/io.h
+++ b/arch/powerpc/include/asm/io.h
@@ -783,8 +783,10 @@ extern void __iounmap_at(void *ea, unsigned long size);
 
 #define mmio_read16be(addr)		readw_be(addr)
 #define mmio_read32be(addr)		readl_be(addr)
+#define mmio_read64be(addr)		readq_be(addr)
 #define mmio_write16be(val, addr)	writew_be(val, addr)
 #define mmio_write32be(val, addr)	writel_be(val, addr)
+#define mmio_write64be(val, addr)	writeq_be(val, addr)
 #define mmio_insb(addr, dst, count)	readsb(addr, dst, count)
 #define mmio_insw(addr, dst, count)	readsw(addr, dst, count)
 #define mmio_insl(addr, dst, count)	readsl(addr, dst, count)
diff --git a/include/asm-generic/iomap.h b/include/asm-generic/iomap.h
index 5b63b94ef6b5..a008f504a2d0 100644
--- a/include/asm-generic/iomap.h
+++ b/include/asm-generic/iomap.h
@@ -36,6 +36,17 @@ extern u64 ioread64(void __iomem *);
 extern u64 ioread64be(void __iomem *);
 #endif
 
+#ifdef readq
+#define ioread64_lo_hi ioread64_lo_hi
+#define ioread64_hi_lo ioread64_hi_lo
+#define ioread64be_lo_hi ioread64be_lo_hi
+#define ioread64be_hi_lo ioread64be_hi_lo
+extern u64 ioread64_lo_hi(void __iomem *addr);
+extern u64 ioread64_hi_lo(void __iomem *addr);
+extern u64 ioread64be_lo_hi(void __iomem *addr);
+extern u64 ioread64be_hi_lo(void __iomem *addr);
+#endif
+
 extern void iowrite8(u8, void __iomem *);
 extern void iowrite16(u16, void __iomem *);
 extern void iowrite16be(u16, void __iomem *);
@@ -46,6 +57,17 @@ extern void iowrite64(u64, void __iomem *);
 extern void iowrite64be(u64, void __iomem *);
 #endif
 
+#ifdef writeq
+#define iowrite64_lo_hi iowrite64_lo_hi
+#define iowrite64_hi_lo iowrite64_hi_lo
+#define iowrite64be_lo_hi iowrite64be_lo_hi
+#define iowrite64be_hi_lo iowrite64be_hi_lo
+extern void iowrite64_lo_hi(u64 val, void __iomem *addr);
+extern void iowrite64_hi_lo(u64 val, void __iomem *addr);
+extern void iowrite64be_lo_hi(u64 val, void __iomem *addr);
+extern void iowrite64be_hi_lo(u64 val, void __iomem *addr);
+#endif
+
 /*
  * "string" versions of the above. Note that they
  * use native byte ordering for the accesses (on
diff --git a/lib/iomap.c b/lib/iomap.c
index 2c293b22569f..e909ab71e995 100644
--- a/lib/iomap.c
+++ b/lib/iomap.c
@@ -67,6 +67,7 @@ static void bad_io_access(unsigned long port, const char *access)
 #ifndef mmio_read16be
 #define mmio_read16be(addr) swab16(readw(addr))
 #define mmio_read32be(addr) swab32(readl(addr))
+#define mmio_read64be(addr) swab64(readq(addr))
 #endif
 
 unsigned int ioread8(void __iomem *addr)
@@ -100,6 +101,80 @@ EXPORT_SYMBOL(ioread16be);
 EXPORT_SYMBOL(ioread32);
 EXPORT_SYMBOL(ioread32be);
 
+#ifdef readq
+static u64 pio_read64_lo_hi(unsigned long port)
+{
+	u64 lo, hi;
+
+	lo = inl(port);
+	hi = inl(port + sizeof(u32));
+
+	return lo | (hi << 32);
+}
+
+static u64 pio_read64_hi_lo(unsigned long port)
+{
+	u64 lo, hi;
+
+	hi = inl(port + sizeof(u32));
+	lo = inl(port);
+
+	return lo | (hi << 32);
+}
+
+static u64 pio_read64be_lo_hi(unsigned long port)
+{
+	u64 lo, hi;
+
+	lo = pio_read32be(port + sizeof(u32));
+	hi = pio_read32be(port);
+
+	return lo | (hi << 32);
+}
+
+static u64 pio_read64be_hi_lo(unsigned long port)
+{
+	u64 lo, hi;
+
+	hi = pio_read32be(port);
+	lo = pio_read32be(port + sizeof(u32));
+
+	return lo | (hi << 32);
+}
+
+u64 ioread64_lo_hi(void __iomem *addr)
+{
+	IO_COND(addr, return pio_read64_lo_hi(port), return readq(addr));
+	return 0xffffffffffffffffULL;
+}
+
+u64 ioread64_hi_lo(void __iomem *addr)
+{
+	IO_COND(addr, return pio_read64_hi_lo(port), return readq(addr));
+	return 0xffffffffffffffffULL;
+}
+
+u64 ioread64be_lo_hi(void __iomem *addr)
+{
+	IO_COND(addr, return pio_read64be_lo_hi(port),
+		return mmio_read64be(addr));
+	return 0xffffffffffffffffULL;
+}
+
+u64 ioread64be_hi_lo(void __iomem *addr)
+{
+	IO_COND(addr, return pio_read64be_hi_lo(port),
+		return mmio_read64be(addr));
+	return 0xffffffffffffffffULL;
+}
+
+EXPORT_SYMBOL(ioread64_lo_hi);
+EXPORT_SYMBOL(ioread64_hi_lo);
+EXPORT_SYMBOL(ioread64be_lo_hi);
+EXPORT_SYMBOL(ioread64be_hi_lo);
+
+#endif /* readq */
+
 #ifndef pio_write16be
 #define pio_write16be(val,port) outw(swab16(val),port)
 #define pio_write32be(val,port) outl(swab32(val),port)
@@ -108,6 +183,7 @@ EXPORT_SYMBOL(ioread32be);
 #ifndef mmio_write16be
 #define mmio_write16be(val,port) writew(swab16(val),port)
 #define mmio_write32be(val,port) writel(swab32(val),port)
+#define mmio_write64be(val,port) writeq(swab64(val),port)
 #endif
 
 void iowrite8(u8 val, void __iomem *addr)
@@ -136,6 +212,62 @@ EXPORT_SYMBOL(iowrite16be);
 EXPORT_SYMBOL(iowrite32);
 EXPORT_SYMBOL(iowrite32be);
 
+#ifdef writeq
+static void pio_write64_lo_hi(u64 val, unsigned long port)
+{
+	outl(val, port);
+	outl(val >> 32, port + sizeof(u32));
+}
+
+static void pio_write64_hi_lo(u64 val, unsigned long port)
+{
+	outl(val >> 32, port + sizeof(u32));
+	outl(val, port);
+}
+
+static void pio_write64be_lo_hi(u64 val, unsigned long port)
+{
+	pio_write32be(val, port + sizeof(u32));
+	pio_write32be(val >> 32, port);
+}
+
+static void pio_write64be_hi_lo(u64 val, unsigned long port)
+{
+	pio_write32be(val >> 32, port);
+	pio_write32be(val, port + sizeof(u32));
+}
+
+void iowrite64_lo_hi(u64 val, void __iomem *addr)
+{
+	IO_COND(addr, pio_write64_lo_hi(val, port),
+		writeq(val, addr));
+}
+
+void iowrite64_hi_lo(u64 val, void __iomem *addr)
+{
+	IO_COND(addr, pio_write64_hi_lo(val, port),
+		writeq(val, addr));
+}
+
+void iowrite64be_lo_hi(u64 val, void __iomem *addr)
+{
+	IO_COND(addr, pio_write64be_lo_hi(val, port),
+		mmio_write64be(val, addr));
+}
+
+void iowrite64be_hi_lo(u64 val, void __iomem *addr)
+{
+	IO_COND(addr, pio_write64be_hi_lo(val, port),
+		mmio_write64be(val, addr));
+}
+
+EXPORT_SYMBOL(iowrite64_lo_hi);
+EXPORT_SYMBOL(iowrite64_hi_lo);
+EXPORT_SYMBOL(iowrite64be_lo_hi);
+EXPORT_SYMBOL(iowrite64be_hi_lo);
+
+#endif /* readq */
+
 /*
  * These are the "repeat MMIO read/write" functions.
  * Note the "__raw" accesses, since we don't want to
-- 
2.19.0
