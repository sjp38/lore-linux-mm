Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id F2B006B0258
	for <linux-mm@kvack.org>; Wed, 27 Jan 2016 13:25:18 -0500 (EST)
Received: by mail-wm0-f44.google.com with SMTP id r129so155910513wmr.0
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:18 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id j142si12562926wmg.110.2016.01.27.10.25.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jan 2016 10:25:17 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id n5so41727194wmn.1
        for <linux-mm@kvack.org>; Wed, 27 Jan 2016 10:25:17 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v1 0/8] SLAB support for KASAN
Date: Wed, 27 Jan 2016 19:25:05 +0100
Message-Id: <cover.1453918525.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch set implements SLAB support for KASAN

Unlike SLUB, SLAB doesn't store allocation/deallocation stacks for heap
objects, therefore we reimplement this feature in mm/kasan/stackdepot.c.
The intention is to ultimately switch SLUB to use this implementation as
well, which will remove the dependency on SLUB_DEBUG.

Also neither SLUB nor SLAB delay the reuse of freed memory chunks, which
is necessary for better detection of use-after-free errors. We introduce
memory quarantine (mm/kasan/quarantine.c), which allows delayed reuse of
deallocated memory.

Alexander Potapenko (8):
  kasan: Change the behavior of kmalloc_large_oob_right test
  mm, kasan: SLAB support
  mm, kasan: Added GFP flags to KASAN API
  arch, ftrace: For KASAN put hard/soft IRQ entries into separate
    sections
  mm, kasan: Stackdepot implementation. Enable stackdepot for SLAB
  kasan: Test fix: Warn if the UAF could not be detected in kmalloc_uaf2
  kasan: Changed kmalloc_large_oob_right, added
    kmalloc_pagealloc_oob_right
  mm: kasan: Initial memory quarantine implementation

 Documentation/kasan.txt              |   5 +-
 arch/arm/kernel/vmlinux.lds.S        |   1 +
 arch/arm64/kernel/vmlinux.lds.S      |   1 +
 arch/blackfin/kernel/vmlinux.lds.S   |   1 +
 arch/c6x/kernel/vmlinux.lds.S        |   1 +
 arch/metag/kernel/vmlinux.lds.S      |   1 +
 arch/microblaze/kernel/vmlinux.lds.S |   1 +
 arch/mips/kernel/vmlinux.lds.S       |   1 +
 arch/nios2/kernel/vmlinux.lds.S      |   1 +
 arch/openrisc/kernel/vmlinux.lds.S   |   1 +
 arch/parisc/kernel/vmlinux.lds.S     |   1 +
 arch/powerpc/kernel/vmlinux.lds.S    |   1 +
 arch/s390/kernel/vmlinux.lds.S       |   1 +
 arch/sh/kernel/vmlinux.lds.S         |   1 +
 arch/sparc/kernel/vmlinux.lds.S      |   1 +
 arch/tile/kernel/vmlinux.lds.S       |   1 +
 arch/x86/kernel/Makefile             |   1 +
 arch/x86/kernel/vmlinux.lds.S        |   1 +
 include/asm-generic/vmlinux.lds.h    |  12 +-
 include/linux/ftrace.h               |  31 ++--
 include/linux/kasan.h                |  63 +++++---
 include/linux/slab.h                 |   6 +
 include/linux/slab_def.h             |  14 ++
 include/linux/slub_def.h             |  11 ++
 kernel/softirq.c                     |   3 +-
 lib/Kconfig.kasan                    |   4 +-
 lib/test_kasan.c                     |  66 +++++++-
 mm/Makefile                          |   1 +
 mm/kasan/Makefile                    |   3 +
 mm/kasan/kasan.c                     | 221 +++++++++++++++++++++++++--
 mm/kasan/kasan.h                     |  52 +++++++
 mm/kasan/quarantine.c                | 284 +++++++++++++++++++++++++++++++++++
 mm/kasan/report.c                    |  68 +++++++--
 mm/kasan/stackdepot.c                | 236 +++++++++++++++++++++++++++++
 mm/mempool.c                         |  23 +--
 mm/page_alloc.c                      |   2 +-
 mm/slab.c                            |  56 ++++++-
 mm/slab.h                            |   4 +
 mm/slab_common.c                     |   8 +-
 mm/slub.c                            |  21 +--
 40 files changed, 1122 insertions(+), 89 deletions(-)
 create mode 100644 mm/kasan/quarantine.c
 create mode 100644 mm/kasan/stackdepot.c

-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
