Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id E73CA6B0005
	for <linux-mm@kvack.org>; Sat, 28 Apr 2018 22:46:09 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id m18-v6so1831352lfj.1
        for <linux-mm@kvack.org>; Sat, 28 Apr 2018 19:46:09 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h13-v6sor890282lfl.75.2018.04.28.19.46.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 28 Apr 2018 19:46:08 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH 0/3] linux-next: mm: hardening: Track genalloc allocations
Date: Sun, 29 Apr 2018 06:45:39 +0400
Message-Id: <20180429024542.19475-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org, keescook@chromium.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, linux-security-module@vger.kernel.org
Cc: willy@infradead.org, labbott@redhat.com, linux-kernel@vger.kernel.org, igor.stoppa@huawei.com

This patchset was created as part of an older version of pmalloc, however
it has value per-se, as it hardens the memory management for the generic
allocator genalloc.

Genalloc does not currently track the size of the allocations it hands out.

Either by mistake, or due to an attack, it is possible that more memory
than what was initially allocated is freed, leaving behind dangling
pointers, ready for an use-after-free attack.

With this patch, genalloc becomes capable of tracking the size of each
allocation it has handed out, when it's time to free it.

It can either verify that the size received, when free is invoked, is
correct, or it can decide autonomously how much memory to free, if the
value received for the size parameter is 0.

These patches are proposed for beign merged into linux-next, to verify
that they do not introduce regressions, by comparing the value received
from the callers of the free function with the internal tracking.

Later on, the "size" parameter can be dropped, and each caller can be
adjusted accordingly.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>

Igor Stoppa (3):
  genalloc: track beginning of allocations
  Add label and license to genalloc.rst
  genalloc: selftest

 Documentation/core-api/genalloc.rst |   4 +
 include/linux/genalloc.h            | 112 +++---
 init/main.c                         |   2 +
 lib/Kconfig                         |  15 +
 lib/Makefile                        |   1 +
 lib/genalloc.c                      | 742 ++++++++++++++++++++++++++----------
 lib/test_genalloc.c                 | 410 ++++++++++++++++++++
 7 files changed, 1031 insertions(+), 255 deletions(-)
 create mode 100644 lib/test_genalloc.c

-- 
2.14.1
