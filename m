Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 74BB46B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 01:17:30 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id v3-v6so7603963ply.20
        for <linux-mm@kvack.org>; Sun, 04 Mar 2018 22:17:30 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38-v6sor3699178pln.118.2018.03.04.22.17.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 04 Mar 2018 22:17:29 -0800 (PST)
From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH] ZBOOT: fix stack protector in compressed boot phase
Date: Mon,  5 Mar 2018 14:18:41 +0800
Message-Id: <1520230721-1839-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <james.hogan@mips.com>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, Huacai Chen <chenhc@lemote.com>, stable@vger.kernel.org

Call __stack_chk_guard_setup() in decompress_kernel() is too late that
stack checking always fails for decompress_kernel() itself. So remove
__stack_chk_guard_setup() and initialize __stack_chk_guard at where we
define it.

Original code comes from ARM but also used for MIPS and SH, so fix them
together. If without this fix, compressed booting of these archs will
fail because stack checking is enabled by default (>=4.16).

Cc: stable@vger.kernel.org
Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 arch/arm/boot/compressed/misc.c        | 9 +--------
 arch/mips/boot/compressed/decompress.c | 9 +--------
 arch/sh/boot/compressed/misc.c         | 9 +--------
 3 files changed, 3 insertions(+), 24 deletions(-)

diff --git a/arch/arm/boot/compressed/misc.c b/arch/arm/boot/compressed/misc.c
index 16a8a80..43aca75 100644
--- a/arch/arm/boot/compressed/misc.c
+++ b/arch/arm/boot/compressed/misc.c
@@ -128,12 +128,7 @@ asmlinkage void __div0(void)
 	error("Attempting division by 0!");
 }
 
-unsigned long __stack_chk_guard;
-
-void __stack_chk_guard_setup(void)
-{
-	__stack_chk_guard = 0x000a0dff;
-}
+unsigned long __stack_chk_guard = 0x000a0dff;
 
 void __stack_chk_fail(void)
 {
@@ -150,8 +145,6 @@ decompress_kernel(unsigned long output_start, unsigned long free_mem_ptr_p,
 {
 	int ret;
 
-	__stack_chk_guard_setup();
-
 	output_data		= (unsigned char *)output_start;
 	free_mem_ptr		= free_mem_ptr_p;
 	free_mem_end_ptr	= free_mem_ptr_end_p;
diff --git a/arch/mips/boot/compressed/decompress.c b/arch/mips/boot/compressed/decompress.c
index fdf99e9..0694b3f 100644
--- a/arch/mips/boot/compressed/decompress.c
+++ b/arch/mips/boot/compressed/decompress.c
@@ -76,12 +76,7 @@ void error(char *x)
 #include "../../../../lib/decompress_unxz.c"
 #endif
 
-unsigned long __stack_chk_guard;
-
-void __stack_chk_guard_setup(void)
-{
-	__stack_chk_guard = 0x000a0dff;
-}
+unsigned long __stack_chk_guard = 0x000a0dff;
 
 void __stack_chk_fail(void)
 {
@@ -92,8 +87,6 @@ void decompress_kernel(unsigned long boot_heap_start)
 {
 	unsigned long zimage_start, zimage_size;
 
-	__stack_chk_guard_setup();
-
 	zimage_start = (unsigned long)(&__image_begin);
 	zimage_size = (unsigned long)(&__image_end) -
 	    (unsigned long)(&__image_begin);
diff --git a/arch/sh/boot/compressed/misc.c b/arch/sh/boot/compressed/misc.c
index 627ce8e..2c564c2 100644
--- a/arch/sh/boot/compressed/misc.c
+++ b/arch/sh/boot/compressed/misc.c
@@ -104,12 +104,7 @@ static void error(char *x)
 	while(1);	/* Halt */
 }
 
-unsigned long __stack_chk_guard;
-
-void __stack_chk_guard_setup(void)
-{
-	__stack_chk_guard = 0x000a0dff;
-}
+unsigned long __stack_chk_guard = 0x000a0dff;
 
 void __stack_chk_fail(void)
 {
@@ -130,8 +125,6 @@ void decompress_kernel(void)
 {
 	unsigned long output_addr;
 
-	__stack_chk_guard_setup();
-
 #ifdef CONFIG_SUPERH64
 	output_addr = (CONFIG_MEMORY_START + 0x2000);
 #else
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
