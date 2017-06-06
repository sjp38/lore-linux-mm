Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 80A396B0313
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 14:26:17 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id g36so15973508wrg.4
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 11:26:17 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id o30si10003319wra.335.2017.06.06.11.26.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 11:26:16 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [RFC v5 PATCH 0/4] NOT FOR MERGE - ro protection for dynamic data 
Date: Tue, 6 Jun 2017 21:24:49 +0300
Message-ID: <20170606182453.32688-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

This patchset introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a pool is made R/O, all the memory
that is part of it, will become R/O.

A R/O pool can be destroyed to recover its memory, but it cannot be
turned back into R/W mode.

This is intentional. This feature is meant for data that doesn't need
further modifications, after initialization.

An example is provided, showing how to turn into a boot-time option the
writable state of the security hooks.
Prior to this patch, it was a compile-time option.

This is made possible, thanks to Tetsuo Handa's rework of the hooks
structure (included in the patchset).

Since the previous version, I have applied fixes for all the issues
discovered that had a clear resolution:

- %p -> pK
- make the feature depend on ARCH_HAS_SET_MEMORY
- fix the range of the page scanning for hardened user copy
- fixed pointer checking for NULL dereferencing


And a couple of issues I found myself:
- return NULL in case someone asks memory from a locked pool
- turn the "protected" flag into atomic type


Still open (at least I didn't get the impression there was a closure):
- need for specific __PMALLOC_ALIGNED ?
- is it really needed to unprotect a pool?
  can't it wait for the implementation of write-seldom?


Igor Stoppa (3):
  Protectable Memory Allocator
  Protectable Memory Allocator - Debug interface
  Make LSM Writable Hooks a command line option

Tetsuo Handa (1):
  LSM: Convert security_hook_heads into explicit array of struct
    list_head

 include/linux/lsm_hooks.h      | 412 ++++++++++++++++++++---------------------
 include/linux/page-flags.h     |   2 +
 include/linux/pmalloc.h        |  20 ++
 include/trace/events/mmflags.h |   1 +
 init/main.c                    |   2 +
 mm/Kconfig                     |  11 ++
 mm/Makefile                    |   1 +
 mm/pmalloc.c                   | 340 ++++++++++++++++++++++++++++++++++
 mm/usercopy.c                  |  24 ++-
 security/security.c            |  49 +++--
 10 files changed, 632 insertions(+), 230 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
