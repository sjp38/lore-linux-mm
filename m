Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f175.google.com (mail-lb0-f175.google.com [209.85.217.175])
	by kanga.kvack.org (Postfix) with ESMTP id 348206B0253
	for <linux-mm@kvack.org>; Mon, 12 Oct 2015 11:52:56 -0400 (EDT)
Received: by lbbk10 with SMTP id k10so35199254lbb.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:55 -0700 (PDT)
Received: from mail-lb0-x229.google.com (mail-lb0-x229.google.com. [2a00:1450:4010:c04::229])
        by mx.google.com with ESMTPS id pf6si11628610lbc.166.2015.10.12.08.52.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Oct 2015 08:52:54 -0700 (PDT)
Received: by lbbk10 with SMTP id k10so35198716lbb.0
        for <linux-mm@kvack.org>; Mon, 12 Oct 2015 08:52:54 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v7 0/4] KASAN for arm64
Date: Mon, 12 Oct 2015 18:52:56 +0300
Message-Id: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Linus Walleij <linus.walleij@linaro.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Arnd Bergmann <arnd@arndb.de>, linux-kernel@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, linux-mm@kvack.org, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, Andrey Konovalov <andreyknvl@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>

As usual patches available in git
	git://github.com/aryabinin/linux.git kasan/arm64v7


Changes since v6:
 - Rebased on top of arm64/for-next/core:
	e8f3010f7326c00368dbc057bd052bec80dfc072 ("arm64/efi: isolate EFI stub from the kernel proper")
   This should fix boot as an EFI application once again.



Changes since v5:
 - Rebase on top of 4.3-rc1
 - Fixed EFI boot.
 - Updated Doc/features/KASAN.

Changes since v4:
 - Generate KASAN_SHADOW_OFFSET using 32 bit arithmetic
 - merge patches x86/kasan: switch to generic kasan_populate_zero_shadow()
    and mm: introduce generic kasan_populate_zero_shadow() into one.
 - remove useless check for start != 0 in clear_pgds()
 - Don't generate KASAN_SHADOW_OFFSET in Makefile for x86,
   assign it in Makefile.kasan if CONFIG_KASAN_SHADOW_OFFSET was defined.
 
Changes since v3:
 - Generate KASAN_SHADOW_OFFSET in Makefile
 - zero_p*_populate() functions now return void
 - Switch x86 to generic kasan_populate_zero_shadow() too
 - Add license headers
 - fix memleak in kasan_populate_zero_shadow:
       Following code could leak memory when pgd_populate() is nop:
                void *p = early_alloc(PAGE_SIZE, NUMA_NO_NODE);
                pgd_populate(&init_mm, pgd, p);
        This was replaced by:
                 pgd_populate(&init_mm, pgd, early_alloc(PAGE_SIZE, NUMA_NO_NODE));

Changes since v2:
 - Rebase on top of v4.2-rc3
 - Address feedback from Catalin.
 - Print memory assignment from Linus
 - Add message about KASAN being initialized

Changes since v1:
 - Address feedback from Catalin.
 - Generalize some kasan init code from arch/x86/mm/kasan_init_64.c
    and reuse it for arm64.
 - Some bugfixes, including:
        add missing arm64/include/asm/kasan.h
        add tlb flush after changing ttbr1
 - Add code comments.
 

Andrey Ryabinin (3):
  arm64: move PGD_SIZE definition to pgalloc.h
  arm64: add KASAN support
  Documentation/features/KASAN: arm64 supports KASAN now

Linus Walleij (1):
  ARM64: kasan: print memory assignment

 .../features/debug/KASAN/arch-support.txt          |   2 +-
 arch/arm64/Kconfig                                 |   1 +
 arch/arm64/Makefile                                |   7 +
 arch/arm64/include/asm/kasan.h                     |  36 +++++
 arch/arm64/include/asm/pgalloc.h                   |   1 +
 arch/arm64/include/asm/pgtable.h                   |   7 +
 arch/arm64/include/asm/string.h                    |  16 ++
 arch/arm64/kernel/Makefile                         |   2 +
 arch/arm64/kernel/arm64ksyms.c                     |   3 +
 arch/arm64/kernel/head.S                           |   3 +
 arch/arm64/kernel/image.h                          |   6 +
 arch/arm64/kernel/module.c                         |  16 +-
 arch/arm64/kernel/setup.c                          |   4 +
 arch/arm64/lib/memcpy.S                            |   3 +
 arch/arm64/lib/memmove.S                           |   7 +-
 arch/arm64/lib/memset.S                            |   3 +
 arch/arm64/mm/Makefile                             |   3 +
 arch/arm64/mm/init.c                               |   6 +
 arch/arm64/mm/kasan_init.c                         | 165 +++++++++++++++++++++
 arch/arm64/mm/pgd.c                                |   2 -
 drivers/firmware/efi/Makefile                      |   8 +
 scripts/Makefile.kasan                             |   4 +-
 22 files changed, 296 insertions(+), 9 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c

-- 
2.4.9

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
