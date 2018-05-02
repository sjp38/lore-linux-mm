Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 506DE6B0005
	for <linux-mm@kvack.org>; Tue,  1 May 2018 21:05:36 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x188-v6so4214042lfa.4
        for <linux-mm@kvack.org>; Tue, 01 May 2018 18:05:36 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m62-v6sor2132635lfm.77.2018.05.01.18.05.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 01 May 2018 18:05:34 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 0/3 v2] linux-next: mm: Track genalloc allocations
Date: Wed,  2 May 2018 05:05:19 +0400
Message-Id: <20180502010522.28767-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org
Cc: willy@infradead.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

This patchset was created as part of an older version of pmalloc, however
it has value per-se, as it hardens the memory management for the generic
allocator genalloc.

Genalloc does not currently track the size of the allocations it hands
out.

Either by mistake, or due to an attack, it is possible that more memory
than what was initially allocated is freed, leaving behind dangling
pointers, ready for an use-after-free attack.

With this patch, genalloc becomes capable of tracking the size of each
allocation it has handed out, when it's time to free it.

It can either verify that the size received is correct, when free is
invoked, or it can decide autonomously how much memory to free, if the
value received for the size parameter is 0.

These patches are proposed for beign merged into linux-next, to verify
that they do not introduce regressions, by comparing the value received
from the callers of the free function with the internal tracking.

For this reason, the patchset does not contain the removal of the size
parameter from users of the free() function.

Later on, the "size" parameter can be dropped, and each caller can be
adjusted accordingly.

However, I do not have access to most of the HW required for confirming
that all of its users are not negatively affected.
This is where I believe having the patches in linux-next would help to
coordinate with the maintaiers of the code that uses gen_alloc.

Since there were comments about the (lack-of) efficiency introduced by
this patchset, I have added some more explanations and calculations to the
description of the first patch, the one adding the bitmap.
My conclusion is that this patch should not cause any major perfomance
problem.

Regarding the possibility of completely changing genalloc into some other
type of allocator, I think it should not be a showstopper for this
patchset, which aims to plug a security hole in genalloc, without
introducing any major regression.

The security flaw is clear and present, while the benefit of introducing a
new allocator is not clear, at least for the current users of genalloc.

And anyway the users of genalloc should be fixed to not pass any size
parameter, which can be done after this patch is merged.

A newer, more efficient allocator will still benefit from not receiving a
spurious parameter (size), when freeing memory.

Changes since v1:

[http://www.openwall.com/lists/kernel-hardening/2018/04/29/1]

* make the tester code a kernel module
* turn selftest BUG() error exit paths into WARN()
* add analysis of impact on current users of genalloc


Igor Stoppa (3):
  genalloc: track beginning of allocations
  Add label and license to genalloc.rst
  genalloc: selftest

 Documentation/core-api/genalloc.rst |   4 +
 include/linux/genalloc.h            | 112 +++---
 lib/Kconfig.debug                   |  23 ++
 lib/Makefile                        |   1 +
 lib/genalloc.c                      | 742 ++++++++++++++++++++++++++----------
 lib/test_genalloc.c                 | 419 ++++++++++++++++++++
 6 files changed, 1046 insertions(+), 255 deletions(-)
 create mode 100644 lib/test_genalloc.c

-- 
2.14.1
