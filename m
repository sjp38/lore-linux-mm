Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f49.google.com (mail-oi0-f49.google.com [209.85.218.49])
	by kanga.kvack.org (Postfix) with ESMTP id C6E816B007B
	for <linux-mm@kvack.org>; Fri, 29 May 2015 19:19:07 -0400 (EDT)
Received: by oihb142 with SMTP id b142so67477751oih.3
        for <linux-mm@kvack.org>; Fri, 29 May 2015 16:19:07 -0700 (PDT)
Received: from g4t3427.houston.hp.com (g4t3427.houston.hp.com. [15.201.208.55])
        by mx.google.com with ESMTPS id w7si4398930oep.76.2015.05.29.16.19.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 May 2015 16:19:05 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH v11 8/12] video/fbdev, asm/io.h: Remove ioremap_writethrough()
Date: Fri, 29 May 2015 16:59:06 -0600
Message-Id: <1432940350-1802-9-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
References: <1432940350-1802-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: bp@alien8.de, hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, linux-nvdimm@lists.01.org, jgross@suse.com, stefan.bader@canonical.com, luto@amacapital.net, hmh@hmh.eng.br, yigal@plexistor.com, konrad.wilk@oracle.com, Elliott@hp.com, mcgrof@suse.com, hch@lst.de, Toshi Kani <toshi.kani@hp.com>

From: Toshi Kani <toshi.kani@hp.com>

This patch removes the callers of ioremap_writethrough() by
replacing them with ioremap_wt() in three drivers under
drivers/video/fbdev.  It then removes ioremap_writethrough()
defined in some architecture's asm/io.h, frv, m68k, microblaze,
and tile.

Signed-off-by: Toshi Kani <toshi.kani@hp.com>
---
 arch/frv/include/asm/io.h        |    5 -----
 arch/m68k/include/asm/io_mm.h    |    5 -----
 arch/m68k/include/asm/io_no.h    |    4 ----
 arch/microblaze/include/asm/io.h |    1 -
 arch/tile/include/asm/io.h       |    1 -
 drivers/video/fbdev/amifb.c      |    4 ++--
 drivers/video/fbdev/atafb.c      |    3 +--
 drivers/video/fbdev/hpfb.c       |    4 ++--
 8 files changed, 5 insertions(+), 22 deletions(-)

diff --git a/arch/frv/include/asm/io.h b/arch/frv/include/asm/io.h
index 1fe98fe..a31b63e 100644
--- a/arch/frv/include/asm/io.h
+++ b/arch/frv/include/asm/io.h
@@ -267,11 +267,6 @@ static inline void __iomem *ioremap_nocache(unsigned long physaddr, unsigned lon
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
 
-static inline void __iomem *ioremap_writethrough(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
-
 static inline void __iomem *ioremap_wt(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
diff --git a/arch/m68k/include/asm/io_mm.h b/arch/m68k/include/asm/io_mm.h
index 7c12138..618c85d3 100644
--- a/arch/m68k/include/asm/io_mm.h
+++ b/arch/m68k/include/asm/io_mm.h
@@ -467,11 +467,6 @@ static inline void __iomem *ioremap_nocache(unsigned long physaddr, unsigned lon
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
-static inline void __iomem *ioremap_writethrough(unsigned long physaddr,
-					 unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
 static inline void __iomem *ioremap_wt(unsigned long physaddr,
 					 unsigned long size)
 {
diff --git a/arch/m68k/include/asm/io_no.h b/arch/m68k/include/asm/io_no.h
index 5fff9a2..ad7bd40 100644
--- a/arch/m68k/include/asm/io_no.h
+++ b/arch/m68k/include/asm/io_no.h
@@ -155,10 +155,6 @@ static inline void *ioremap_nocache(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_NOCACHE_SER);
 }
-static inline void *ioremap_writethrough(unsigned long physaddr, unsigned long size)
-{
-	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
-}
 static inline void *ioremap_wt(unsigned long physaddr, unsigned long size)
 {
 	return __ioremap(physaddr, size, IOMAP_WRITETHROUGH);
diff --git a/arch/microblaze/include/asm/io.h b/arch/microblaze/include/asm/io.h
index ec3da11..39b6315 100644
--- a/arch/microblaze/include/asm/io.h
+++ b/arch/microblaze/include/asm/io.h
@@ -39,7 +39,6 @@ extern resource_size_t isa_mem_base;
 extern void iounmap(void __iomem *addr);
 
 extern void __iomem *ioremap(phys_addr_t address, unsigned long size);
-#define ioremap_writethrough(addr, size)	ioremap((addr), (size))
 #define ioremap_nocache(addr, size)		ioremap((addr), (size))
 #define ioremap_fullcache(addr, size)		ioremap((addr), (size))
 #define ioremap_wc(addr, size)			ioremap((addr), (size))
diff --git a/arch/tile/include/asm/io.h b/arch/tile/include/asm/io.h
index 9c3d950..dc61de1 100644
--- a/arch/tile/include/asm/io.h
+++ b/arch/tile/include/asm/io.h
@@ -55,7 +55,6 @@ extern void iounmap(volatile void __iomem *addr);
 #define ioremap_nocache(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wc(physaddr, size)		ioremap(physaddr, size)
 #define ioremap_wt(physaddr, size)		ioremap(physaddr, size)
-#define ioremap_writethrough(physaddr, size)	ioremap(physaddr, size)
 #define ioremap_fullcache(physaddr, size)	ioremap(physaddr, size)
 
 #define mmiowb()
diff --git a/drivers/video/fbdev/amifb.c b/drivers/video/fbdev/amifb.c
index 35f7900..ee3a703 100644
--- a/drivers/video/fbdev/amifb.c
+++ b/drivers/video/fbdev/amifb.c
@@ -3705,8 +3705,8 @@ default_chipset:
 	 * access the videomem with writethrough cache
 	 */
 	info->fix.smem_start = (u_long)ZTWO_PADDR(videomemory);
-	videomemory = (u_long)ioremap_writethrough(info->fix.smem_start,
-						   info->fix.smem_len);
+	videomemory = (u_long)ioremap_wt(info->fix.smem_start,
+					 info->fix.smem_len);
 	if (!videomemory) {
 		dev_warn(&pdev->dev,
 			 "Unable to map videomem cached writethrough\n");
diff --git a/drivers/video/fbdev/atafb.c b/drivers/video/fbdev/atafb.c
index cb9ee25..d6ce613 100644
--- a/drivers/video/fbdev/atafb.c
+++ b/drivers/video/fbdev/atafb.c
@@ -3185,8 +3185,7 @@ int __init atafb_init(void)
 		/* Map the video memory (physical address given) to somewhere
 		 * in the kernel address space.
 		 */
-		external_screen_base = ioremap_writethrough(external_addr,
-						     external_len);
+		external_screen_base = ioremap_wt(external_addr, external_len);
 		if (external_vgaiobase)
 			external_vgaiobase =
 			  (unsigned long)ioremap(external_vgaiobase, 0x10000);
diff --git a/drivers/video/fbdev/hpfb.c b/drivers/video/fbdev/hpfb.c
index a1b7e5f..9476d19 100644
--- a/drivers/video/fbdev/hpfb.c
+++ b/drivers/video/fbdev/hpfb.c
@@ -241,8 +241,8 @@ static int hpfb_init_one(unsigned long phys_base, unsigned long virt_base)
 	fb_info.fix.line_length = fb_width;
 	fb_height = (in_8(fb_regs + HPFB_FBHMSB) << 8) | in_8(fb_regs + HPFB_FBHLSB);
 	fb_info.fix.smem_len = fb_width * fb_height;
-	fb_start = (unsigned long)ioremap_writethrough(fb_info.fix.smem_start,
-						       fb_info.fix.smem_len);
+	fb_start = (unsigned long)ioremap_wt(fb_info.fix.smem_start,
+					     fb_info.fix.smem_len);
 	hpfb_defined.xres = (in_8(fb_regs + HPFB_DWMSB) << 8) | in_8(fb_regs + HPFB_DWLSB);
 	hpfb_defined.yres = (in_8(fb_regs + HPFB_DHMSB) << 8) | in_8(fb_regs + HPFB_DHLSB);
 	hpfb_defined.xres_virtual = hpfb_defined.xres;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
