Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f171.google.com (mail-lb0-f171.google.com [209.85.217.171])
	by kanga.kvack.org (Postfix) with ESMTP id A5BC082F64
	for <linux-mm@kvack.org>; Thu, 17 Sep 2015 05:38:28 -0400 (EDT)
Received: by lbpo4 with SMTP id o4so6232945lbp.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:38:28 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id tt2si1538422lbb.13.2015.09.17.02.38.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Sep 2015 02:38:27 -0700 (PDT)
Received: by lagj9 with SMTP id j9so7614492lag.2
        for <linux-mm@kvack.org>; Thu, 17 Sep 2015 02:38:27 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v6 5/6] ARM64: kasan: print memory assignment
Date: Thu, 17 Sep 2015 12:38:11 +0300
Message-Id: <1442482692-6416-6-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Linus Walleij <linus.walleij@linaro.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>

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
Signed-off-by: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm64/mm/init.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm64/mm/init.c b/arch/arm64/mm/init.c
index f5c0680..7a1f9a0 100644
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
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
