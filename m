Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f177.google.com (mail-lb0-f177.google.com [209.85.217.177])
	by kanga.kvack.org (Postfix) with ESMTP id 3283D82F65
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:53:01 -0400 (EDT)
Received: by lbbck17 with SMTP id ck17so27179969lbb.1
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:53:00 -0700 (PDT)
Received: from mail-lb0-x22a.google.com (mail-lb0-x22a.google.com. [2a00:1450:4010:c04::22a])
        by mx.google.com with ESMTPS id n10si11647247lbp.73.2015.10.12.08.52.58
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:52:58 -0700 (PDT)
Received: by lbcao8 with SMTP id ao8so147614178lbc.3
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:58 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v7 3/4] ARM64: kasan: print memory assignment
Date: Mon, 12 Oct 2015 18:52:59 +0300
Message-Id: <1444665180-301-4-git-send-email-ryabinin.a.a@gmail.com>
In-Reply-To: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Linus Walleij <linus.walleij@linaro.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

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
2.4.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
