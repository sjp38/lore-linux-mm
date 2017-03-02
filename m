Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1D76B0388
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 12:37:42 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id c85so108968558qkg.0
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 09:37:42 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id m47si7432597qta.154.2017.03.02.09.37.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Mar 2017 09:37:41 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/3] userfaultfd v4.11 updates
Date: Thu,  2 Mar 2017 18:37:35 +0100
Message-Id: <20170302173738.18994-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

Hello,

this is incremental against current -mm.

The earlier patchset fixed the fctx->orig memleak but as I thought
during review, there was a further leak in fctx->new and Mike promptly
fixed it too. I've been running a reproducer and there's no further
memleak when the uffd is closed by the parent while fork() blocks
waiting for the event to be received.

In addition I found a potential stale pointer in MADV_DONTNEED if
userfaultfd_remove has to block and releases the mmap_sem in the
process. This patch revalidates the vma and fixes the
race. Unfortunately calling userfaultfd_remove last is not ok as
explained in the commit.

A "make" run from the directory selftests/vm/ independently started to
fail in v4.11 trying to write executables to the root directory.
That's not very friendly because it worked before, but it's easy to
fix and the last patch corrects this behavior in the vm/Makefile.

Andrea Arcangeli (2):
  userfaultfd: non-cooperative: userfaultfd_remove revalidate vma in
    MADV_DONTNEED
  userfaultfd: selftest: vm: allow to build in vm/ directory

Mike Rapoport (1):
  userfaultfd: non-cooperative: fix fork fctx->new memleak

 fs/userfaultfd.c                    | 18 ++++++++++-----
 include/linux/userfaultfd_k.h       |  7 +++---
 mm/madvise.c                        | 44 ++++++++++++++++++++++++++++++++++---
 tools/testing/selftests/vm/Makefile |  4 ++++
 4 files changed, 60 insertions(+), 13 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
