Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id A49936B0005
	for <linux-mm@kvack.org>; Tue, 15 Mar 2016 06:10:42 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l68so144117521wml.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 03:10:42 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id 184si13488237wmj.92.2016.03.15.03.10.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Mar 2016 03:10:41 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id p65so18829891wmp.0
        for <linux-mm@kvack.org>; Tue, 15 Mar 2016 03:10:41 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v8 0/7] SLAB support for KASAN
Date: Tue, 15 Mar 2016 11:10:29 +0100
Message-Id: <cover.1458036040.git.glider@google.com>
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

v6: - stackdepot: fixed kbuild warnings, simplified kasan_track,
use vmalloc() for depot when possible
    - quarantine: improved patch description, removed dead code

v7: - fix kbuild error reports

v8: - removed vmalloc() and recursion flags from stackdepot
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
 include/linux/kasan.h                |  63 +++++---
 include/linux/slab.h                 |  10 +-
 include/linux/slab_def.h             |  14 ++
 include/linux/slub_def.h             |  11 ++
 include/linux/stackdepot.h           |  32 ++++
 kernel/softirq.c                     |   2 +-
 kernel/trace/trace_functions_graph.c |   1 +
 lib/Kconfig                          |   4 +
 lib/Kconfig.kasan                    |   5 +-
 lib/Makefile                         |   3 +
 lib/stackdepot.c                     | 278 +++++++++++++++++++++++++++++++++
 lib/test_kasan.c                     |  59 ++++++-
 mm/Makefile                          |   1 +
 mm/kasan/Makefile                    |   4 +
 mm/kasan/kasan.c                     | 219 ++++++++++++++++++++++++--
 mm/kasan/kasan.h                     |  44 ++++++
 mm/kasan/quarantine.c                | 289 +++++++++++++++++++++++++++++++++++
 mm/kasan/report.c                    |  63 ++++++--
 mm/mempool.c                         |  23 +--
 mm/page_alloc.c                      |   2 +-
 mm/slab.c                            |  53 ++++++-
 mm/slab.h                            |   4 +-
 mm/slab_common.c                     |   8 +-
 mm/slub.c                            |  19 +--
 47 files changed, 1188 insertions(+), 92 deletions(-)
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
