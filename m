Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2879C6B0007
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 09:48:49 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u83so1451680wmb.3
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 06:48:49 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id i7si1291325wre.6.2018.02.23.06.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 06:48:47 -0800 (PST)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC PATCH v17 0/7] mm: security: ro protection for dynamic data
Date: Fri, 23 Feb 2018 16:48:00 +0200
Message-ID: <20180223144807.1180-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: david@fromorbit.com, willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
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

Changes since v16:
[http://www.openwall.com/lists/kernel-hardening/2018/02/12/13]

* introduced lkdtm test for write protection of a variable
* added comments with rationale for use of BUG_ON() when running selftest
* converted self-tests to kernel naming patter "test_xxx.c"
* moved triggering of pmalloc self-testing to early phase of main.c
* improved summaries of genalloc and vmalloc patches
* removed example of optimization of find_vm_area because of possible bug
  in vmalloc_to_page:
[https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1617030.html]

Igor Stoppa (7):
  genalloc: track beginning of allocations
  genalloc: selftest
  struct page: add field for vm_struct
  Protectable Memory
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var
  Documentation for Pmalloc

 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 114 +++++++
 drivers/misc/lkdtm.h               |   1 +
 drivers/misc/lkdtm_core.c          |   3 +
 drivers/misc/lkdtm_perms.c         |  28 ++
 include/linux/genalloc.h           |   7 +-
 include/linux/mm_types.h           |   1 +
 include/linux/pmalloc.h            | 242 ++++++++++++++
 include/linux/test_genalloc.h      |  26 ++
 include/linux/test_pmalloc.h       |  24 ++
 include/linux/vmalloc.h            |   1 +
 init/main.c                        |   4 +
 lib/Kconfig                        |  15 +
 lib/Makefile                       |   1 +
 lib/genalloc.c                     | 658 +++++++++++++++++++++++++++----------
 lib/test_genalloc.c                | 410 +++++++++++++++++++++++
 mm/Kconfig                         |  15 +
 mm/Makefile                        |   2 +
 mm/pmalloc.c                       | 499 ++++++++++++++++++++++++++++
 mm/test_pmalloc.c                  |  79 +++++
 mm/usercopy.c                      |  33 ++
 mm/vmalloc.c                       |   5 +
 22 files changed, 1999 insertions(+), 170 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 include/linux/test_genalloc.h
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 lib/test_genalloc.c
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/test_pmalloc.c

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
