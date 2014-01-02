Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id C38EE6B0035
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 05:04:21 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id uo5so14226536pbc.25
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 02:04:21 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id tt8si4883876pbc.18.2014.01.02.02.04.19
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 02:04:20 -0800 (PST)
From: "Gioh Kim" <gioh.kim@lge.com>
Subject: ARM: mm: Could I change module space size or place modules in vmalloc area?
Date: Thu, 2 Jan 2014 19:04:13 +0900
Message-ID: <002001cf07a1$fd4bdc10$f7e39430$@lge.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: ko
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Russell King <linux@arm.linux.org.uk>, linux-mm@kvack.org, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
Cc: HyoJun Im <hyojun.im@lge.com>



Hi,

I run out of module space because I have several big driver modules.
I know I can strip the modules to decrease size but I need debug info now.

The default size of module is 16MB and the size is statically defined in the
header file. 
But a description for the module space size tells that it can be
configurable at most 32MB.

I have changed the module space size to 18MB and tested my platform.
It has been looking good.

I am not sure my patch is proper solution.
Anyway, could I configure the module space size?

Or could I place the modules into vmalloc area?



Signed-off-by: Gioh Kim <gioh.kim@lge.com>
---
 arch/arm/Kconfig              |    4 ++++
 arch/arm/include/asm/memory.h |   10 +++++++---
 2 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig index c1f1a7e..cf1fb55
100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -2257,6 +2257,10 @@ config ARM_CPU_SUSPEND

 endmenu

+config MODULES_AREA_SIZE
+       int
+       default 0x1000000
+
 source "net/Kconfig"

 source "drivers/Kconfig"
diff --git a/arch/arm/include/asm/memory.h b/arch/arm/include/asm/memory.h
index 6976b03..3396758 100644
--- a/arch/arm/include/asm/memory.h
+++ b/arch/arm/include/asm/memory.h
@@ -32,13 +32,17 @@

 #ifdef CONFIG_MMU

+#if CONFIG_MODULES_AREA_SIZE > SZ_32M
+#error Too much space for modules
+#endif
+
 /*
  * PAGE_OFFSET - the virtual address of the start of the kernel image
  * TASK_SIZE - the maximum size of a user space task.
  * TASK_UNMAPPED_BASE - the lower boundary of the mmap VM area
  */
-#define PAGE_OFFSET            UL(CONFIG_PAGE_OFFSET)
-#define TASK_SIZE              (UL(CONFIG_PAGE_OFFSET) - UL(SZ_16M))
+#define PAGE_OFFSET    UL(CONFIG_PAGE_OFFSET)
+#define TASK_SIZE      (UL(CONFIG_PAGE_OFFSET) -
UL(CONFIG_MODULES_AREA_SIZE))
 #define TASK_UNMAPPED_BASE     ALIGN(TASK_SIZE / 3, SZ_16M)

 /*
@@ -51,7 +55,7 @@
  * and PAGE_OFFSET - it must be within 32MB of the kernel text.
  */
 #ifndef CONFIG_THUMB2_KERNEL
-#define MODULES_VADDR          (PAGE_OFFSET - SZ_16M)
+#define MODULES_VADDR          (PAGE_OFFSET - CONFIG_MODULES_AREA_SIZE)
 #else
 /* smaller range for Thumb-2 symbols relocation (2^24)*/
 #define MODULES_VADDR          (PAGE_OFFSET - SZ_8M)
--
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
