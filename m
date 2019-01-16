Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it1-f197.google.com (mail-it1-f197.google.com [209.85.166.197])
	by kanga.kvack.org (Postfix) with ESMTP id 60FBA8E0004
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 13:25:35 -0500 (EST)
Received: by mail-it1-f197.google.com with SMTP id b14so2503841itd.1
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 10:25:35 -0800 (PST)
Received: from ale.deltatee.com (ale.deltatee.com. [207.54.116.67])
        by mx.google.com with ESMTPS id m123si4177181iof.141.2019.01.16.10.25.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 10:25:34 -0800 (PST)
From: Logan Gunthorpe <logang@deltatee.com>
Date: Wed, 16 Jan 2019 11:25:18 -0700
Message-Id: <20190116182523.19446-2-logang@deltatee.com>
In-Reply-To: <20190116182523.19446-1-logang@deltatee.com>
References: <20190116182523.19446-1-logang@deltatee.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: [PATCH v25 1/6] iomap: Use non-raw io functions for io{read|write}XXbe
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-ntb@googlegroups.com, linux-crypto@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andy Shevchenko <andy.shevchenko@gmail.com>, =?UTF-8?q?Horia=20Geant=C4=83?= <horia.geanta@nxp.com>, Logan Gunthorpe <logang@deltatee.com>, Thomas Gleixner <tglx@linutronix.de>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>

Fix an asymmetry in the io{read|write}XXbe functions in that the
big-endian variants make use of the raw io accessors while the
little-endian variants use the regular accessors. Some architectures
implement barriers to order against both spinlocks and DMA accesses
and for these case, the big-endian variant of the API would not be
protected.

Thus, change the mmio_XXXXbe macros to use the appropriate swab() function
wrapping the regular accessor. This is similar to what was done for PIO.

When this code was originally written, barriers in the IO accessors were
not common and the accessors simply wrapped the raw functions in a
conversion to CPU endianness. Since then, barriers have been added in
some architectures and are now missing in the big endian variant of the
API.

This also manages to silence a few sparse warnings that check
for using the correct endian types which the original code did
not annotate correctly.

Signed-off-by: Logan Gunthorpe <logang@deltatee.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Kate Stewart <kstewart@linuxfoundation.org>
Cc: Philippe Ombredanne <pombredanne@nexb.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>
Link: http://lkml.kernel.org/r/CAK8P3a25zQDxyaY3iVv+JmSSzs7F6ssGc+HdBkGs54ZfViX+Fg@mail.gmail.com
---
 lib/iomap.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/lib/iomap.c b/lib/iomap.c
index 541d926da95e..2c293b22569f 100644
--- a/lib/iomap.c
+++ b/lib/iomap.c
@@ -65,8 +65,8 @@ static void bad_io_access(unsigned long port, const char *access)
 #endif
 
 #ifndef mmio_read16be
-#define mmio_read16be(addr) be16_to_cpu(__raw_readw(addr))
-#define mmio_read32be(addr) be32_to_cpu(__raw_readl(addr))
+#define mmio_read16be(addr) swab16(readw(addr))
+#define mmio_read32be(addr) swab32(readl(addr))
 #endif
 
 unsigned int ioread8(void __iomem *addr)
@@ -106,8 +106,8 @@ EXPORT_SYMBOL(ioread32be);
 #endif
 
 #ifndef mmio_write16be
-#define mmio_write16be(val,port) __raw_writew(be16_to_cpu(val),port)
-#define mmio_write32be(val,port) __raw_writel(be32_to_cpu(val),port)
+#define mmio_write16be(val,port) writew(swab16(val),port)
+#define mmio_write32be(val,port) writel(swab32(val),port)
 #endif
 
 void iowrite8(u8 val, void __iomem *addr)
-- 
2.19.0
