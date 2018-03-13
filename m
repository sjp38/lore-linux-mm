Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 184126B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 17:47:03 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g13so730264wrh.23
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 14:47:03 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j185si699604wma.102.2018.03.13.14.47.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 14:47:01 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC PATCH v19 0/8] mm: security: ro protection for dynamic data
Date: Tue, 13 Mar 2018 23:45:46 +0200
Message-ID: <20180313214554.28521-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, rppt@linux.vnet.ibm.com, keescook@chromium.org, mhocko@kernel.org
Cc: labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

This patch-set introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a memory pool is turned into R/O,
all the memory that is part of it, will become R/O.

A R/O pool can be destroyed, to recover its memory, but it cannot be
turned back into R/W mode.

This is intentional. This feature is meant for data that doesn't need
further modifications after initialization.

However the data might need to be released, for example as part of module
unloading.
To do this, the memory must first be freed, then the pool can be destroyed.

An example is provided, in the form of self-testing.

Changes since v18:

[http://www.openwall.com/lists/kernel-hardening/2018/02/28/21]

* Code refactoring in pmalloc & genalloc:
  - simplify the logic for handling pools before and after sysf init
  - reduced section holding mutex on pmalloc list, when adding a pool
  - reduced the steps in finding length of an existing allocation
  - split various functions into smaller ones
* clarified in the comments the need for pfree()
* Various fixes to the documentation:
  - remove kerneldoc duplicates
  - added cross-reference lables
  - miscellaneous typos
* improved error notifications: use WARNs with specific messages
* added missing tests for possible error conditions


Discussion topics that are unclear if they are closed and would need
comment from those who initiated them, if my answers are accepted or not:

* @Kees Cook proposed to have first self testing for genalloc, to
  validate the following patch, adding tracing of allocations
  My answer was that such tests would also need patching, therefore they 
  could not certify that the functionality is corect both before and
  after the genalloc bitmap modification.

* @Kees Cook proposed to turn the self testing into modules.
  My answer was that the functionality is intentionally tested very early
  in the boot phase, to prevent unexplainable errors, should the feature
  really fail.

* @Matthew Wilcox proposed to use a different mechanism for th genalloc
  bitmap: 2 bitmaps, one for occupation and one for start.
  And possibly use an rbtree for the starts.
  My answer was that this solution is less optimized, because it scatters
  the data of one allocation across multiple words/pages, plus is not
  a transaction anymore. And the particular distribution of sizes of
  allocation is likely to eat up much more memory than the bitmap.

Igor Stoppa (8):
  genalloc: track beginning of allocations
  Add label to genalloc.rst for cross reference
  genalloc: selftest
  struct page: add field for vm_struct
  Protectable Memory
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var
  Documentation for Pmalloc

 Documentation/core-api/genalloc.rst |   2 +
 Documentation/core-api/index.rst    |   1 +
 Documentation/core-api/pmalloc.rst  | 111 ++++++
 drivers/misc/lkdtm.h                |   1 +
 drivers/misc/lkdtm_core.c           |   3 +
 drivers/misc/lkdtm_perms.c          |  28 ++
 include/linux/genalloc.h            | 116 +++---
 include/linux/mm_types.h            |   1 +
 include/linux/pmalloc.h             | 163 ++++++++
 include/linux/test_genalloc.h       |  26 ++
 include/linux/test_pmalloc.h        |  24 ++
 include/linux/vmalloc.h             |   1 +
 init/main.c                         |   4 +
 lib/Kconfig                         |  15 +
 lib/Makefile                        |   1 +
 lib/genalloc.c                      | 765 ++++++++++++++++++++++++++----------
 lib/test_genalloc.c                 | 410 +++++++++++++++++++
 mm/Kconfig                          |  17 +
 mm/Makefile                         |   2 +
 mm/pmalloc.c                        | 643 ++++++++++++++++++++++++++++++
 mm/test_pmalloc.c                   | 238 +++++++++++
 mm/usercopy.c                       |  33 ++
 mm/vmalloc.c                        |   2 +
 23 files changed, 2352 insertions(+), 255 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 include/linux/test_genalloc.h
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 lib/test_genalloc.c
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/test_pmalloc.c

-- 
2.14.1
