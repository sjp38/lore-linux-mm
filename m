Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5DC4B6B02B4
	for <linux-mm@kvack.org>; Wed,  7 Jun 2017 08:36:29 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id h127so2627335oic.11
        for <linux-mm@kvack.org>; Wed, 07 Jun 2017 05:36:29 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id c193si733934oib.24.2017.06.07.05.36.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Jun 2017 05:36:28 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH v6 0/4] ro protection for dynamic data
Date: Wed, 7 Jun 2017 15:35:01 +0300
Message-ID: <20170607123505.16629-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Hi,
please consider for inclusion.

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

Changes since the v5 version:
- use unsigned long for  __PMALLOC_ALIGNED alignment
- fixed a regression where size in bytes was used instead of size in words
- tightened the update of the pools list during removal, by doing
  earlier the decrement of the atomic counter

The only question still open is if there should be a possibility for
unprotecting a memory pool in other cases than destruction.

The only cases found for this topic are:
- protecting the LSM header structure between creation and insertion of a
  security module that was not built as part of the kernel
  (but the module can protect the headers after it has loaded)

- unloading SELinux from RedHat, if the system has booted, but no policy
  has been loaded yet - this feature is going away, according to Casey.


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
 mm/pmalloc.c                   | 339 +++++++++++++++++++++++++++++++++
 mm/usercopy.c                  |  24 ++-
 security/security.c            |  49 +++--
 10 files changed, 631 insertions(+), 230 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
