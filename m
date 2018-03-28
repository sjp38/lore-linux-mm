Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7C08A6B0025
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 04:36:09 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id n2so952345pgs.2
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 01:36:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i5sor932499pgq.75.2018.03.28.01.36.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 28 Mar 2018 01:36:07 -0700 (PDT)
From: Huacai Chen <chenhc@lemote.com>
Subject: [PATCH V4] ZBOOT: fix stack protector in compressed boot phase
Date: Wed, 28 Mar 2018 16:38:16 +0800
Message-Id: <1522226296-3091-1-git-send-email-chenhc@lemote.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ralf Baechle <ralf@linux-mips.org>, James Hogan <james.hogan@mips.com>, linux-mips@linux-mips.org, Russell King <linux@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, linux-sh@vger.kernel.org, Huacai Chen <chenhc@lemote.com>, stable@vger.kernel.org

Call __stack_chk_guard_setup() in decompress_kernel() is too late that
stack checking always fails for decompress_kernel() itself. So remove
__stack_chk_guard_setup() and initialize __stack_chk_guard before we
call decompress_kernel().

Original code comes from ARM but also used for MIPS and SH, so fix them
together. If without this fix, compressed booting of these archs will
fail because stack checking is enabled by default (>=4.16).

V1 -> V2: Fix build on ARM.
V2 -> V3: Fix build on SuperH.
V3 -> V4: Initialize __stack_chk_guard in C code as a constant.

Cc: stable@vger.kernel.org
Signed-off-by: Huacai Chen <chenhc@lemote.com>
---
 arch/arm/boot/compressed/head.S        | 4 ++++
 arch/arm/boot/compressed/misc.c        | 7 -------
 arch/mips/boot/compressed/decompress.c | 7 -------
 arch/mips/boot/compressed/head.S       | 4 ++++
 arch/sh/boot/compressed/head_32.S      | 8 ++++++++
 arch/sh/boot/compressed/head_64.S      | 4 ++++
 arch/sh/boot/compressed/misc.c         | 7 -------
 7 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/arch/arm/boot/compressed/misc.c b/arch/arm/boot/compressed/misc.c
index 16a8a80..e8fe51f 100644
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
+const unsigned long __stack_chk_guard = 0x000a0dff;
 
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
index fdf99e9..81df904 100644
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
+const unsigned long __stack_chk_guard = 0x000a0dff;
 
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
index 627ce8e..c15cac9 100644
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
+const unsigned long __stack_chk_guard = 0x000a0dff;
 
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
