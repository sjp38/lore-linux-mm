Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id E93616B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 16:51:10 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id r22so4038612iod.7
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 13:51:10 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k36sor1414075ioi.71.2017.11.29.13.51.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 29 Nov 2017 13:51:10 -0800 (PST)
From: Paul Lawrence <paullawrence@google.com>
Subject: [PATCH v2 0/5] kasan: support alloca, LLVM
Date: Wed, 29 Nov 2017 13:50:45 -0800
Message-Id: <20171129215050.158653-1-paullawrence@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <mmarek@suse.com>
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Matthias Kaehlcke <mka@chromium.org>, Michael Davidson <md@google.com>, Greg Hackmann <ghackmann@google.com>, Paul Lawrence <paullawrence@google.com>

Adding kasan alloca support using clang
Also adding support for clang, since needed for this feature
gcc has kasan alloca support, but only post 7.2

[Patch v2 1/5] kasan: support alloca() poisoning
  Tests moved to patch 2/5
  __asan_alloca_unpoison():
    Use precalculated rounded-up-size
    Warning added if bottom is not aligned as expected
    Parameter check added to make sure gcc builds don't fail
    Now unpoisons partial chunks
  get_shadow_bug_type():
    Missing break added

[PATCH v2 2/5] kasan: Add tests for alloca poisonong
  Tests moved here
  kasan_alloca_oob_right():
    No longer rounding up

[PATCH v2 3/5] kasan: added functions for unpoisoning stack variables
  No change from v1. clang builds need f8

[PATCH v2 4/5] kasan: support LLVM-style asan parameters
  Rejigged whole file. Old approach would not work except with ToT gcc
  or clang. All parameters would be rejected if one was not known.
  Also if both were empty, CFLAGS_KASAN would be " " which mostly
  disabled kasan on older compilers.
  Added support for gcc, tested on ToT compiler

[PATCH v2 5/5] kasan: add compiler support for clang
  Made comments single line

Paul Lawrence (5):
  kasan: support alloca() poisoning
  kasan: Add tests for alloca poisonong
  kasan: added functions for unpoisoning stack variables
  kasan: support LLVM-style asan parameters
  kasan: add compiler support for clang

 include/linux/compiler-clang.h |  8 +++++++
 lib/test_kasan.c               | 22 ++++++++++++++++++++
 mm/kasan/kasan.c               | 47 ++++++++++++++++++++++++++++++++++++++++++
 mm/kasan/kasan.h               |  8 +++++++
 mm/kasan/report.c              |  4 ++++
 scripts/Makefile.kasan         | 39 ++++++++++++++++++++++++-----------
 6 files changed, 116 insertions(+), 12 deletions(-)

--
2.15.0.531.g2ccb3012c9-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
