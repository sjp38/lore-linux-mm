Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 14F646B0006
	for <linux-mm@kvack.org>; Mon, 26 Mar 2018 21:56:10 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id 31so11099522wrr.2
        for <linux-mm@kvack.org>; Mon, 26 Mar 2018 18:56:10 -0700 (PDT)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id 201si247181wmm.277.2018.03.26.18.56.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Mar 2018 18:56:08 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC PATCH v20 0/6] mm: security: ro protection for dynamic data
Date: Tue, 27 Mar 2018 04:55:18 +0300
Message-ID: <20180327015524.14318-1-igor.stoppa@huawei.com>
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

Changes since v19:

[http://www.openwall.com/lists/kernel-hardening/2018/03/13/68]

* dropped genalloc as allocator
* first attempt at rewriting pmalloc, as discussed with Matthew Wilcox:
  [http://www.openwall.com/lists/kernel-hardening/2018/03/14/20]
* removed free function from the API
* removed distinction between protected and unprotected pools: a pool can
  contain both protectec and unprotected areas.
* removed gpf parameter, as it didn't seem too useful (or not?)
* added option to specify alignment of allocations
* added parameter for specifying size of a refill
* removed option to pre-allocate memory for a pool (is it a bad idea?)
* changed vmap_area to allow chaining them, for tracking them in a pool
* made public the previously private find_vmap_area function

Igor Stoppa (6):
  struct page: add field for vm_struct
  vmalloc: rename llist field in vmap_area
  Protectable Memory
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var
  Documentation for Pmalloc

 Documentation/core-api/index.rst   |   1 +
 Documentation/core-api/pmalloc.rst | 101 ++++++++++++
 drivers/misc/lkdtm.h               |   1 +
 drivers/misc/lkdtm_core.c          |   3 +
 drivers/misc/lkdtm_perms.c         |  28 ++++
 include/linux/mm_types.h           |   1 +
 include/linux/pmalloc.h            | 281 ++++++++++++++++++++++++++++++++
 include/linux/test_pmalloc.h       |  24 +++
 include/linux/vmalloc.h            |   5 +-
 init/main.c                        |   2 +
 mm/Kconfig                         |  16 ++
 mm/Makefile                        |   2 +
 mm/pmalloc.c                       | 321 +++++++++++++++++++++++++++++++++++++
 mm/test_pmalloc.c                  | 136 ++++++++++++++++
 mm/usercopy.c                      |  33 ++++
 mm/vmalloc.c                       |  10 +-
 16 files changed, 960 insertions(+), 5 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/test_pmalloc.c

-- 
2.14.1
