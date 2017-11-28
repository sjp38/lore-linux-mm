Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1F67C6B0287
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:21 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id d6so26786897pfb.3
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id q80sor7550170pfi.141.2017.11.27.23.49.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:20 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 00/18] introduce a new tool, valid access checker
Date: Tue, 28 Nov 2017 16:48:35 +0900
Message-Id: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

Hello,

This patchset introduces a new tool, valid access checker.

Vchecker is a dynamic memory error detector. It provides a new debug feature
that can find out an un-intended access to valid area. Valid area here means
the memory which is allocated and allowed to be accessed by memory owner and
un-intended access means the read/write that is initiated by non-owner.
Usual problem of this class is memory overwritten.

Most of debug feature focused on finding out un-intended access to
in-valid area, for example, out-of-bound access and use-after-free, and,
there are many good tools for it. But, as far as I know, there is no good tool
to find out un-intended access to valid area. This kind of problem is really
hard to solve so this tool would be very useful.

This tool doesn't automatically catch a problem. Manual runtime configuration
to specify the target object is required.

Note that there was a similar attempt for the debugging overwritten problem
however it requires manual code modifying and recompile.

http://lkml.kernel.org/r/<20171117223043.7277-1-wen.gang.wang@oracle.com>

To get more information about vchecker, please see a documention at
the last patch.

Patchset can also be available at

https://github.com/JoonsooKim/linux/tree/vchecker-master-v1.0-next-20171122

Enjoy it.

Thanks.

Joonsoo Kim (14):
  mm/kasan: make some kasan functions global
  vchecker: introduce the valid access checker
  vchecker: mark/unmark the shadow of the allocated objects
  vchecker: prepare per object memory for vchecker
  vchecker: store/report callstack of value writer
  lib/stackdepot: extend stackdepot API to support per-user stackdepot
  vchecker: consistently exclude vchecker's stacktrace
  vchecker: fix 'remove' handling on callstack checker
  mm/vchecker: support inline KASAN build
  mm/vchecker: make callstack depth configurable
  mm/vchecker: pass allocation caller address to vchecker hook
  mm/vchecker: support allocation caller filter
  lib/vchecker_test: introduce a sample for vchecker test
  doc: add vchecker document

Namhyung Kim (4):
  lib/stackdepot: Add is_new arg to depot_save_stack
  vchecker: Add 'callstack' checker
  vchecker: Support toggle on/off of callstack check
  vchecker: Use __GFP_ATOMIC to save stacktrace

 Documentation/dev-tools/vchecker.rst |  200 +++++++
 drivers/gpu/drm/drm_mm.c             |    4 +-
 include/linux/kasan.h                |    1 +
 include/linux/slab.h                 |    8 +
 include/linux/slab_def.h             |    3 +
 include/linux/slub_def.h             |    3 +
 include/linux/stackdepot.h           |   10 +-
 lib/Kconfig.kasan                    |   21 +
 lib/Makefile                         |    1 +
 lib/stackdepot.c                     |  126 ++--
 lib/vchecker_test.c                  |  117 ++++
 mm/kasan/Makefile                    |    1 +
 mm/kasan/kasan.c                     |   14 +-
 mm/kasan/kasan.h                     |    3 +
 mm/kasan/report.c                    |   12 +-
 mm/kasan/vchecker.c                  | 1089 ++++++++++++++++++++++++++++++++++
 mm/kasan/vchecker.h                  |   43 ++
 mm/page_owner.c                      |    8 +-
 mm/slab.c                            |   47 +-
 mm/slab.h                            |   14 +-
 mm/slab_common.c                     |   25 +
 mm/slub.c                            |   49 +-
 22 files changed, 1730 insertions(+), 69 deletions(-)
 create mode 100644 Documentation/dev-tools/vchecker.rst
 create mode 100644 lib/vchecker_test.c
 create mode 100644 mm/kasan/vchecker.c
 create mode 100644 mm/kasan/vchecker.h

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
