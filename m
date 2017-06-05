Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6E75A6B0292
	for <linux-mm@kvack.org>; Mon,  5 Jun 2017 15:23:48 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id k15so24475143wmh.3
        for <linux-mm@kvack.org>; Mon, 05 Jun 2017 12:23:48 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id g12si7589594wrd.274.2017.06.05.12.23.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 05 Jun 2017 12:23:46 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: 
Date: Mon, 5 Jun 2017 22:22:11 +0300
Message-ID: <20170605192216.21596-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, hch@infradead.org, labbott@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor Stoppa <igor.stoppa@huawei.com>

Subject: [RFC v4 PATCH 0/5] NOT FOR MERGE - ro protection for dynamic data

This patchset introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a pool is made R/O, all the memory
that is part of it, will become R/O.

A R/O pool can be destroyed to recover its memory, but it cannot be
turned back into R/W mode.

This is intentional and this feature is meant for data that doesn't need
further modifications, after initialization.

An example is provided, showing how to turn into a boot-time option the
writable state of the security hooks.
Prior to this patch, it was a compile-time option.

This is made possible, thanks to Tetsuo Handa's rewor of the hooks
structure (included in the patchset).

Notes:

* I have performed some preliminary test on qemu x86_64 and the changes
  seem to hold, but more extensive testing is required.

* I'll be AFK for about a week, so I preferred to share this version, even
  if not thoroughly tested, in the hope to get preliminary comments, but
  it is rough around the edges.

Igor Stoppa (4):
  Protectable Memory Allocator
  Protectable Memory Allocator - Debug interface
  Make LSM Writable Hooks a command line option
  NOT FOR MERGE - Protectable Memory Allocator test

Tetsuo Handa (1):
  LSM: Convert security_hook_heads into explicit array of struct
    list_head

 include/linux/lsm_hooks.h      | 412 ++++++++++++++++++++---------------------
 include/linux/page-flags.h     |   2 +
 include/linux/pmalloc.h        |  20 ++
 include/trace/events/mmflags.h |   1 +
 init/main.c                    |   2 +
 mm/Kconfig                     |  11 ++
 mm/Makefile                    |   4 +-
 mm/pmalloc.c                   | 340 ++++++++++++++++++++++++++++++++++
 mm/pmalloc_test.c              | 172 +++++++++++++++++
 mm/usercopy.c                  |  24 ++-
 security/security.c            |  58 ++++--
 11 files changed, 814 insertions(+), 232 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/pmalloc_test.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
