Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id E7E396B005D
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:42:56 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id u129-v6so2685642lff.9
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:42:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y17sor1608104lji.67.2018.04.13.06.42.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Apr 2018 06:42:54 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [RFC PATCH v22 0/6] mm: security: ro protection for dynamic data
Date: Fri, 13 Apr 2018 17:41:25 +0400
Message-Id: <20180413134131.4651-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, mhocko@kernel.org, corbet@lwn.net
Cc: david@fromorbit.com, rppt@linux.vnet.ibm.com, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

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

Since it was advised to give an example of protecting real kernel data
[1],
a well known vulnerability has been used to demo an effective use of
pmalloc.

[1] http://www.openwall.com/lists/kernel-hardening/2018/03/29/7

However it turned out to be almost an how-to for attacking the kernel, so
it was sent first to security@kernel.org, for obtaining clearance about
the
publication.

Changes since v21:

[http://www.openwall.com/lists/kernel-hardening/2018/03/27/23]

* fixed type mismatch error in use of max(), detected by gcc 7.3
* converted internal types into size_t
* fixed leak of vmalloc memory in the self-test code

Igor Stoppa (6):
  struct page: add field for vm_struct
  vmalloc: rename llist field in vmap_area
  Protectable Memory
  Documentation for Pmalloc
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var

Igor Stoppa (6):
  struct page: add field for vm_struct
  vmalloc: rename llist field in vmap_area
  Protectable Memory
  Documentation for Pmalloc
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var

 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 107 +++++++++++++++
 drivers/misc/lkdtm/core.c          |   3 +
 drivers/misc/lkdtm/lkdtm.h         |   1 +
 drivers/misc/lkdtm/perms.c         |  25 ++++
 include/linux/mm_types.h           |   1 +
 include/linux/pmalloc.h            | 166 +++++++++++++++++++++++
 include/linux/test_pmalloc.h       |  24 ++++
 include/linux/vmalloc.h            |   5 +-
 init/main.c                        |   2 +
 mm/Kconfig                         |  16 +++
 mm/Makefile                        |   2 +
 mm/pmalloc.c                       | 265 +++++++++++++++++++++++++++++++++++++
 mm/test_pmalloc.c                  | 137 +++++++++++++++++++
 mm/usercopy.c                      |  33 +++++
 mm/vmalloc.c                       |  10 +-
 16 files changed, 793 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/test_pmalloc.c

-- 
2.14.1
