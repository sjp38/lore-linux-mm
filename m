Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 111BE6B0007
	for <linux-mm@kvack.org>; Mon, 23 Apr 2018 08:55:21 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id o17-v6so14086168iob.12
        for <linux-mm@kvack.org>; Mon, 23 Apr 2018 05:55:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b186-v6sor4055921ith.105.2018.04.23.05.55.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 23 Apr 2018 05:55:19 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [RFC PATCH v23 0/6] mm: security: write protection for dynamic data
Date: Mon, 23 Apr 2018 16:54:49 +0400
Message-Id: <20180423125458.5338-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: willy@infradead.org, keescook@chromium.org, paul@paul-moore.com, sds@tycho.nsa.gov, mhocko@kernel.org, corbet@lwn.net
Cc: labbott@redhat.com, linux-cc=david@fromorbit.com, --cc=rppt@linux.vnet.ibm.com, --security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>

This patch-set introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a memory pool is protected, all the
memory that is currently part of it, will become R/O.

A R/O pool can be expanded (adding more protectable memory).
It can also be destroyed, to recover its memory, but it cannot be
turned back into normal R/W mode.

This is intentional. This feature is meant for data that either doesn't
need further modifications after initialization, or it will change very
seldom.

The data might need to be released, for example as part of module unloading.
The pool, therefore, can be destroyed.

For those cases where the data is never completely stable, however it can
stay unmodified for very long periods, there is a possibility of
allocating it from a "rare write" pool, which allows modification to its
data, through an helper function.

I did not want to overcomplicate the first version of rare write, but it
might be needed to add disabling/enabling of preemption, however I would
appreciate comments in general about the implementation through transient
remapping.

An example is provided, showing how to protect one of hte internal states
of SELinux.

Changes since v22:
[http://www.openwall.com/lists/kernel-hardening/2018/04/13/3]

- refactored some helper functions in a separate local header
- expanded the documentation
- introduction of rare write support
- example with SELinux "initialized" field


Igor Stoppa (9):
  struct page: add field for vm_struct
  vmalloc: rename llist field in vmap_area
  Protectable Memory
  Documentation for Pmalloc
  Pmalloc selftest
  lkdtm: crash on overwriting protected pmalloc var
  Pmalloc Rare Write: modify selected pools
  Preliminary self test for pmalloc rare write
  Protect SELinux initialized state with pmalloc

 Documentation/core-api/index.rst    |   1 +
 Documentation/core-api/pmalloc.rst  | 189 ++++++++++++++++++++++++++
 drivers/misc/lkdtm/core.c           |   3 +
 drivers/misc/lkdtm/lkdtm.h          |   1 +
 drivers/misc/lkdtm/perms.c          |  25 ++++
 include/linux/mm_types.h            |   1 +
 include/linux/pmalloc.h             | 170 ++++++++++++++++++++++++
 include/linux/test_pmalloc.h        |  24 ++++
 include/linux/vmalloc.h             |   6 +-
 init/main.c                         |   2 +
 mm/Kconfig                          |  16 +++
 mm/Makefile                         |   2 +
 mm/pmalloc.c                        | 258 ++++++++++++++++++++++++++++++++++++
 mm/pmalloc_helpers.h                | 210 +++++++++++++++++++++++++++++
 mm/test_pmalloc.c                   | 213 +++++++++++++++++++++++++++++
 mm/usercopy.c                       |   9 ++
 mm/vmalloc.c                        |  10 +-
 security/selinux/hooks.c            |  12 +-
 security/selinux/include/security.h |   2 +-
 security/selinux/ss/services.c      |  51 ++++---
 20 files changed, 1174 insertions(+), 31 deletions(-)
 create mode 100644 Documentation/core-api/pmalloc.rst
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 include/linux/test_pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/pmalloc_helpers.h
 create mode 100644 mm/test_pmalloc.c

-- 
2.14.1
