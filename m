Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 57B4C6B0382
	for <linux-mm@kvack.org>; Wed,  5 Jul 2017 09:47:44 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id z1so47972715wrz.10
        for <linux-mm@kvack.org>; Wed, 05 Jul 2017 06:47:44 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id h75si17029527wmi.145.2017.07.05.06.47.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 05 Jul 2017 06:47:42 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@huawei.com>
Subject: [PATCH v9 0/3]  mm: security: ro protection for dynamic data
Date: Wed, 5 Jul 2017 16:46:25 +0300
Message-ID: <20170705134628.3803-1-igor.stoppa@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: keescook@chromium.org, mhocko@kernel.org, jmorris@namei.org, labbott@redhat.com, hch@infradead.org
Cc: penguin-kernel@I-love.SAKURA.ne.jp, paul@paul-moore.com, sds@tycho.nsa.gov, casey@schaufler-ca.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com, Igor
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

Changes since the v8 version:
- do not abuse devres, but manage the pools in a normal list
- added one sysfs attribute, showing the number of chnks in each pool

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

 arch/Kconfig                   |   1 +
 include/linux/lsm_hooks.h      | 420 ++++++++++++++++++++---------------------
 include/linux/page-flags.h     |   2 +
 include/linux/pmalloc.h        | 127 +++++++++++++
 include/trace/events/mmflags.h |   1 +
 lib/Kconfig                    |   1 +
 mm/Makefile                    |   1 +
 mm/pmalloc.c                   | 356 ++++++++++++++++++++++++++++++++++
 mm/usercopy.c                  |  24 ++-
 security/security.c            |  49 +++--
 10 files changed, 748 insertions(+), 234 deletions(-)
 create mode 100644 include/linux/pmalloc.h
 create mode 100644 mm/pmalloc.c

-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
