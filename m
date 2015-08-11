Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f169.google.com (mail-lb0-f169.google.com [209.85.217.169])
	by kanga.kvack.org (Postfix) with ESMTP id C4F8C6B0038
	for <linux-mm@kvack.org>; Mon, 10 Aug 2015 18:22:53 -0400 (EDT)
Received: by lbbsx3 with SMTP id sx3so19486512lbb.0
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:22:53 -0700 (PDT)
Received: from mail-lb0-x233.google.com (mail-lb0-x233.google.com. [2a00:1450:4010:c04::233])
        by mx.google.com with ESMTPS id ms1si15307557lbb.53.2015.08.10.15.22.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 10 Aug 2015 15:22:51 -0700 (PDT)
Received: by lbbtg9 with SMTP id tg9so65400525lbb.1
        for <linux-mm@kvack.org>; Mon, 10 Aug 2015 15:22:51 -0700 (PDT)
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Subject: [PATCH v5 0/6]  KASAN for amr64
Date: Tue, 11 Aug 2015 05:18:13 +0300
Message-Id: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Arnd Bergmann <arnd@arndb.de>, Linus Walleij <linus.walleij@linaro.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alexey Klimov <klimov.linux@gmail.com>, Yury <yury.norov@gmail.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

For git users patches are available in git:
        git://github.com/aryabinin/linux.git kasan/arm64v5

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

Andrey Ryabinin (5):
  x86/kasan: define KASAN_SHADOW_OFFSET per architecture
  x86/kasan, mm: introduce generic kasan_populate_zero_shadow()
  arm64: introduce VA_START macro - the first kernel virtual address.
  arm64: move PGD_SIZE definition to pgalloc.h
  arm64: add KASAN support

Linus Walleij (1):
  ARM64: kasan: print memory assignment

 arch/arm64/Kconfig               |   1 +
 arch/arm64/Makefile              |   7 ++
 arch/arm64/include/asm/kasan.h   |  36 +++++++++
 arch/arm64/include/asm/memory.h  |   2 +
 arch/arm64/include/asm/pgalloc.h |   1 +
 arch/arm64/include/asm/pgtable.h |   9 ++-
 arch/arm64/include/asm/string.h  |  16 ++++
 arch/arm64/kernel/arm64ksyms.c   |   3 +
 arch/arm64/kernel/head.S         |   3 +
 arch/arm64/kernel/module.c       |  16 +++-
 arch/arm64/kernel/setup.c        |   2 +
 arch/arm64/lib/memcpy.S          |   3 +
 arch/arm64/lib/memmove.S         |   7 +-
 arch/arm64/lib/memset.S          |   3 +
 arch/arm64/mm/Makefile           |   3 +
 arch/arm64/mm/init.c             |   6 ++
 arch/arm64/mm/kasan_init.c       | 165 +++++++++++++++++++++++++++++++++++++++
 arch/arm64/mm/pgd.c              |   2 -
 arch/x86/include/asm/kasan.h     |   3 +
 arch/x86/mm/kasan_init_64.c      | 123 ++---------------------------
 include/linux/kasan.h            |  10 ++-
 mm/kasan/Makefile                |   2 +-
 mm/kasan/kasan_init.c            | 152 ++++++++++++++++++++++++++++++++++++
 scripts/Makefile.kasan           |   4 +-
 24 files changed, 450 insertions(+), 129 deletions(-)
 create mode 100644 arch/arm64/include/asm/kasan.h
 create mode 100644 arch/arm64/mm/kasan_init.c
 create mode 100644 mm/kasan/kasan_init.c

-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
