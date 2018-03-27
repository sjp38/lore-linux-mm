Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3A46B0010
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:38:21 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id v189so3585763wmf.4
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 08:38:20 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 99si1258179wrb.60.2018.03.27.08.38.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 08:38:19 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC PATCH v21 0/6] mm: security: ro protection for dynamic data
Date: Tue, 27 Mar 2018 18:37:36 +0300
Message-ID: <20180327153742.17328-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

This patch-set introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a memory pool is protected, all the
memory that is currently part of it, will become R/O.

A R/O pool can be expanded (adding more protectable memory).
It can also be destroyed, to recover its memory, but it cannot be
turned back into R/W mode.

This is intentional. This feature is meant for data that doesn't need
further modifications after initialization.

However the data might need to be released, for example as part of module
unloading. The pool, therefore, can be destroyed.

An example is provided, in the form of self-testing.

Changes since v20:

[http://www.openwall.com/lists/kernel-hardening/2018/03/27/2]

* removed the align_order parameter from allocation functions
* improved documentation with more explanation
* fixed lkdt test
* reworked the destroy function, removing a possible race with
  use-after-free code.


Igor Stoppa (6):
  struct page: add field for vm_struct
  vmalloc: rename llist field in vmap_area
  Protectable Memory
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var
  Documentation for Pmalloc

 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 107 +++++++++++++++
 drivers/misc/lkdtm.h               |   1 +
 drivers/misc/lkdtm_core.c          |   3 +
 drivers/misc/lkdtm_perms.c         |  25 ++++
 include/linux/mm_types.h           |   1 +
 include/linux/pmalloc.h            | 166 +++++++++++++++++++++++
 include/linux/test_pmalloc.h       |  24 ++++
 include/linux/vmalloc.h            |   5 +-
 init/main.c                        |   2 +
 mm/Kconfig                         |  16 +++
 mm/Makefile                        |   2 +
 mm/pmalloc.c                       | 264 +++++++++++++++++++++++++++++++++++++
 mm/test_pmalloc.c                  | 136 +++++++++++++++++++
 mm/usercopy.c                      |  33 +++++
 mm/vmalloc.c                       |  10 +-
 16 files changed, 791 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/test_pmalloc.c

-- 
2.14.1
