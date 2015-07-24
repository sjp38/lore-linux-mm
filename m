Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f177.google.com (mail-ig0-f177.google.com [209.85.213.177])
	by kanga.kvack.org (Postfix) with ESMTP id EC4466B025A
	for <linux-mm@kvack.org>; Fri, 24 Jul 2015 12:42:42 -0400 (EDT)
Received: by igbij6 with SMTP id ij6so21022876igb.1
        for <linux-mm@kvack.org>; Fri, 24 Jul 2015 09:42:42 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id fo7si21881391pac.56.2015.07.24.09.42.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 24 Jul 2015 09:42:37 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS000K1W3QYRJ60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Fri, 24 Jul 2015 17:42:34 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [PATCH v4 6/7] ARM64: kasan: print memory assignment
Date: Fri, 24 Jul 2015 19:41:58 +0300
Message-id: <1437756119-12817-7-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Andrey Ryabinin <a.ryabinin@samsung.com>

From: Linus Walleij <linus.walleij@linaro.org>

This prints out the virtual memory assigned to KASan in the
boot crawl along with other memory assignments, if and only
if KASan is activated.

Example dmesg from the Juno Development board:

Memory: 1691156K/2080768K available (5465K kernel code, 444K rwdata,
2160K rodata, 340K init, 217K bss, 373228K reserved, 16384K cma-reserved)
Virtual kernel memory layout:
    kasan   : 0xffffff8000000000 - 0xffffff9000000000   (    64 GB)
    vmalloc : 0xffffff9000000000 - 0xffffffbdbfff0000   (   182 GB)
    vmemmap : 0xffffffbdc0000000 - 0xffffffbfc0000000   (     8 GB maximum)
              0xffffffbdc2000000 - 0xffffffbdc3fc0000   (    31 MB actual)
    fixed   : 0xffffffbffabfd000 - 0xffffffbffac00000   (    12 KB)
    PCI I/O : 0xffffffbffae00000 - 0xffffffbffbe00000   (    16 MB)
    modules : 0xffffffbffc000000 - 0xffffffc000000000   (    64 MB)
    memory  : 0xffffffc000000000 - 0xffffffc07f000000   (  2032 MB)
      .init : 0xffffffc0007f5000 - 0xffffffc00084a000   (   340 KB)
      .text : 0xffffffc000080000 - 0xffffffc0007f45b4   (  7634 KB)
      .data : 0xffffffc000850000 - 0xffffffc0008bf200   (   445 KB)

Signed-off-by: Linus Walleij <linus.walleij@linaro.org>
Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/mm/init.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index ad87ce8..3930692 100644
--- a/arch/arm64/mm/init.c
+++ b/arch/arm64/mm/init.c
@@ -298,6 +298,9 @@ void __init mem_init(void)
 #define MLK_ROUNDUP(b, t) b, t, DIV_ROUND_UP(((t) - (b)), SZ_1K)
 
 	pr_notice("Virtual kernel memory layout:\n"
+#ifdef CONFIG_KASAN
+		  "    kasan   : 0x%16lx - 0x%16lx   (%6ld GB)\n"
+#endif
 		  "    vmalloc : 0x%16lx - 0x%16lx   (%6ld GB)\n"
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 		  "    vmemmap : 0x%16lx - 0x%16lx   (%6ld GB maximum)\n"
@@ -310,6 +313,9 @@ void __init mem_init(void)
 		  "      .init : 0x%p" " - 0x%p" "   (%6ld KB)\n"
 		  "      .text : 0x%p" " - 0x%p" "   (%6ld KB)\n"
 		  "      .data : 0x%p" " - 0x%p" "   (%6ld KB)\n",
+#ifdef CONFIG_KASAN
+		  MLG(KASAN_SHADOW_START, KASAN_SHADOW_END),
+#endif
 		  MLG(VMALLOC_START, VMALLOC_END),
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
 		  MLG((unsigned long)vmemmap,
-- 
2.4.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
