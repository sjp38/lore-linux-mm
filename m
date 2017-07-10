Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 917F66B04AB
	for <linux-mm@kvack.org>; Mon, 10 Jul 2017 11:07:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id z81so25024734wrc.2
        for <linux-mm@kvack.org>; Mon, 10 Jul 2017 08:07:44 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id s185si6876345wmd.7.2017.07.10.08.07.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 10 Jul 2017 08:07:43 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH v10 0/3] mm: security: ro protection for dynamic data
Date: Mon, 10 Jul 2017 18:06:00 +0300
Message-ID: <20170710150603.387-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, penguin-kernel@I-love.SAKURA.ne.jp, labbott@redhat.com, hch@infradead.org
Cc: paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor
 Stoppa <igor.stoppa@huawei.com>

Hi,
please consider this patch-set for inclusion.

This patch-set introduces the possibility of protecting memory that has
been allocated dynamically.

The memory is managed in pools: when a memory pool is turned into R/O,
all the memory that is part of it, will become R/O.

A R/O pool can be destroyed, to recover its memory, but it cannot be
turned back into R/W mode.

This is intentional. This feature is meant for data that doesn't need
further modifications after initialization.

However the data might need to be released, as part of module unloading.
To do this, the memory must first be freed, then the pool can be destroyed.

An example is provided, showing how to turn into a boot-time option the
writable state of the security hooks.
Prior to this patch, it was a compile-time option.

This is made possible, thanks to Tetsuo Handa's rework of the hooks
structure (included in the patchset).

Changes since the v9 version:
- drop page flag to mark pmalloc pages and use page->private & bit
  as followup to Jerome Glisse's advice to use existing fields.
- introduce non-API header mm/pmalloc_usercopy.h for usercopy test

Question still open:
- should it be possibile to unprotect a pool for rewrite?

The only cases found for this topic are:
- protecting the LSM header structure between creation and insertion of a
  security module that was not built as part of the kernel
  (but the module can protect the headers after it has loaded)

- unloading SELinux from RedHat, if the system has booted, but no policy
  has been loaded yet - this feature is going away, according to Casey.

Regarding the last point, there was a comment from Christoph Hellwig,
for which I asked for clarifications, but it's still pending:

https://marc.info/?l=linux-mm&m=149863848120692&w=2


Notes:

- The patch is larg-ish, but I was not sure what criteria to use for
  splitting it. If it helps the reviewing, please do let me know how I
  should split it and I will comply.
- I had to rebase Tetsuo Handa's patch because it didn't apply cleanly
  anymore, I would appreciate an ACK to that or a revised patch, whatever 
  comes easier.

Igor Stoppa (2):
  Protectable memory support
  Make LSM Writable Hooks a command line option

Tetsuo Handa (1):
  LSM: Convert security_hook_heads into explicit array of struct
    list_head

 arch/Kconfig              |   1 +
 include/linux/lsm_hooks.h | 420 +++++++++++++++++++++++-----------------------
 include/linux/pmalloc.h   | 127 ++++++++++++++
 lib/Kconfig               |   1 +
 mm/Makefile               |   1 +
 mm/pmalloc.c              | 372 ++++++++++++++++++++++++++++++++++++++++
 mm/pmalloc.h              |  17 ++
 mm/pmalloc_usercopy.h     |  38 +++++
 mm/usercopy.c             |  23 ++-
 security/security.c       |  49 ++++--
 10 files changed, 815 insertions(+), 234 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c
 create mode 100644 mm/pmalloc.h
 create mode 100644 mm/pmalloc_usercopy.h

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
