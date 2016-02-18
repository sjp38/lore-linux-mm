Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id B8E59828E2
	for <linux-mm@kvack.org>; Thu, 18 Feb 2016 12:16:13 -0500 (EST)
Received: by mail-wm0-f52.google.com with SMTP id c200so38569777wme.0
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:16:13 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id kb10si11662314wjb.118.2016.02.18.09.16.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 Feb 2016 09:16:12 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id g62so38857564wme.1
        for <linux-mm@kvack.org>; Thu, 18 Feb 2016 09:16:12 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2 0/7] SLAB support for KASAN
Date: Thu, 18 Feb 2016 18:16:00 +0100
Message-Id: <cover.1455811491.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
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
---
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
 include/linux/ftrace.h               |  11 --
 include/linux/interrupt.h            |  20 +++
 include/linux/kasan.h                |  63 ++++++--
 include/linux/slab.h                 |   6 +
 include/linux/slab_def.h             |  14 ++
 include/linux/slub_def.h             |  11 ++
 include/linux/stackdepot.h           |  32 ++++
 kernel/softirq.c                     |   3 +-
 kernel/trace/trace_functions_graph.c |   1 +
 lib/Kconfig.kasan                    |   4 +-
 lib/Makefile                         |   7 +
 lib/stackdepot.c                     | 274 +++++++++++++++++++++++++++++++
 lib/test_kasan.c                     |  59 ++++++-
 mm/Makefile                          |   1 +
 mm/kasan/Makefile                    |   4 +
 mm/kasan/kasan.c                     | 221 +++++++++++++++++++++++--
 mm/kasan/kasan.h                     |  45 ++++++
 mm/kasan/quarantine.c                | 306 +++++++++++++++++++++++++++++++++++
 mm/kasan/report.c                    |  69 ++++++--
 mm/mempool.c                         |  23 +--
 mm/page_alloc.c                      |   2 +-
 mm/slab.c                            |  58 ++++++-
 mm/slab.h                            |   4 +
 mm/slab_common.c                     |   8 +-
 mm/slub.c                            |  21 +--
 44 files changed, 1213 insertions(+), 88 deletions(-)
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
