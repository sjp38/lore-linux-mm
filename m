Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id AC56A6B0292
	for <linux-mm@kvack.org>; Wed, 30 Aug 2017 12:23:38 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id k94so9491149wrc.6
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:38 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id j64si5156297edd.420.2017.08.30.09.23.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Aug 2017 09:23:37 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id 187so4712125wmn.1
        for <linux-mm@kvack.org>; Wed, 30 Aug 2017 09:23:37 -0700 (PDT)
From: Dmitry Vyukov <dvyukov@google.com>
Subject: [PATCH 0/3] kcov: support comparison operands collection
Date: Wed, 30 Aug 2017 18:23:28 +0200
Message-Id: <cover.1504109849.git.dvyukov@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, linux-mm@kvack.org
Cc: tchibo@google.com, Dmitry Vyukov <dvyukov@google.com>

Enables kcov to collect comparison operands from instrumented code.
This is done by using Clang's -fsanitize=trace-cmp instrumentation
(currently not available for GCC).

The comparison operands help a lot in fuzz testing. E.g. they are
used in syzkaller to cover the interiors of conditional statements
with way less attempts and thus make previously unreachable code
reachable.

To allow separate collection of coverage and comparison operands two
different work modes are implemented. Mode selection is now done via
a KCOV_ENABLE ioctl call with corresponding argument value.

Clang instrumentation:
https://clang.llvm.org/docs/SanitizerCoverage.html#tracing-data-flow
Syzkaller:
https://github.com/google/syzkaller

Victor Chibotaru (3):
  kcov: support comparison operands collection
  Makefile: support flag -fsanitizer-coverage=trace-cmp
  kcov: update documentation

 Documentation/dev-tools/kcov.rst |  94 +++++++++++++++++-
 Makefile                         |   5 +-
 include/linux/kcov.h             |  12 ++-
 include/uapi/linux/kcov.h        |  32 ++++++
 kernel/kcov.c                    | 203 ++++++++++++++++++++++++++++++++-------
 lib/Kconfig.debug                |   8 ++
 scripts/Makefile.kcov            |   6 ++
 scripts/Makefile.lib             |   6 ++
 8 files changed, 322 insertions(+), 44 deletions(-)
 create mode 100644 scripts/Makefile.kcov

-- 
2.14.1.581.gf28d330327-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
