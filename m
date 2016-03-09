Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id A99206B0005
	for <linux-mm@kvack.org>; Wed,  9 Mar 2016 06:05:55 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id l68so65666537wml.1
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 03:05:55 -0800 (PST)
Received: from mail-wm0-x22a.google.com (mail-wm0-x22a.google.com. [2a00:1450:400c:c09::22a])
        by mx.google.com with ESMTPS id j8si9340146wjf.83.2016.03.09.03.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Mar 2016 03:05:54 -0800 (PST)
Received: by mail-wm0-x22a.google.com with SMTP id l68so187395302wml.0
        for <linux-mm@kvack.org>; Wed, 09 Mar 2016 03:05:54 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v4 0/7] SLAB support for KASAN
Date: Wed,  9 Mar 2016 12:05:41 +0100
Message-Id: <cover.1457519440.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

This patch set implements SLAB support for KASAN

Unlike SLUB, SLAB doesn't store allocation/deallocation stacks for heap
objects, therefore we reimplement this feature in mm/kasan/stackdepot.c.
The intention is to ultimately switch SLUB to use this implementation as
well, which will save a lot of memory (right now SLUB bloats each object
by 256 bytes to store the allocation/deallocation stacks).

Also neither SLUB nor SLAB delay the reuse of freed memory chunks, which
is necessary for better detection of use-after-free errors. We introduce
memory quarantine (mm/kasan/quarantine.c), which allows delayed reuse of
deallocated memory.

Alexander Potapenko (7):
  kasan: Modify kmalloc_large_oob_right(), add
    kmalloc_pagealloc_oob_right()
  mm, kasan: SLAB support
  mm, kasan: Added GFP flags to KASAN API
  arch, ftrace: For KASAN put hard/soft IRQ entries into separate
    sections
  mm, kasan: Stackdepot implementation. Enable stackdepot for SLAB
  kasan: Test fix: Warn if the UAF could not be detected in kmalloc_uaf2
  mm: kasan: Initial memory quarantine implementation
---
v2: - merged two patches that touched kmalloc_large_oob_right
    - moved stackdepot implementation to lib/
    - moved IRQ definitions to include/linux/interrupt.h

v3: - minor description changes
    - store deallocation info in the "mm, kasan: SLAB support" patch

v4: - fix kbuild error reports

v5: - SLAB allocator, stackdepot: adopted suggestions by Andrey Ryabinin
    - IRQ: fixed kbuild warnings
---

 Documentation/kasan.txt              |   5 +-
 arch/arm/include/asm/exception.h     |   2 +-
 arch/arm/kernel/vmlinux.lds.S        |   1 +
 arch/arm64/include/asm/exception.h   |   2 +-
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
 include/linux/ftrace.h               |  11 --
 include/linux/interrupt.h            |  20 +++
 include/linux/kasan.h                |  63 ++++++--
 include/linux/slab.h                 |  10 +-
 include/linux/slab_def.h             |  14 ++
 include/linux/slub_def.h             |  11 ++
 include/linux/stackdepot.h           |  32 ++++
 kernel/softirq.c                     |   2 +-
 kernel/trace/trace_functions_graph.c |   1 +
 lib/Kconfig                          |   3 +
 lib/Kconfig.kasan                    |   5 +-
 lib/Makefile                         |   3 +
 lib/stackdepot.c                     | 275 +++++++++++++++++++++++++++++++
 lib/test_kasan.c                     |  59 ++++++-
 mm/Makefile                          |   1 +
 mm/kasan/Makefile                    |   4 +
 mm/kasan/kasan.c                     | 221 +++++++++++++++++++++++--
 mm/kasan/kasan.h                     |  45 ++++++
 mm/kasan/quarantine.c                | 306 +++++++++++++++++++++++++++++++++++
 mm/kasan/report.c                    |  64 ++++++--
 mm/mempool.c                         |  23 +--
 mm/page_alloc.c                      |   2 +-
 mm/slab.c                            |  53 +++++-
 mm/slab.h                            |   4 +-
 mm/slab_common.c                     |   8 +-
 mm/slub.c                            |  19 +--
 47 files changed, 1205 insertions(+), 92 deletions(-)
 create mode 100644 include/linux/stackdepot.h
 create mode 100644 lib/stackdepot.c
 create mode 100644 mm/kasan/quarantine.c

-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
