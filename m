Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 22BE26B00EA
	for <linux-mm@kvack.org>; Thu, 17 Oct 2013 20:50:54 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id lf10so1163522pab.34
        for <linux-mm@kvack.org>; Thu, 17 Oct 2013 17:50:53 -0700 (PDT)
From: Davidlohr Bueso <davidlohr@hp.com>
Subject: [PATCH 0/3] mm,vdso: preallocate new vmas
Date: Thu, 17 Oct 2013 17:50:35 -0700
Message-Id: <1382057438-3306-1-git-send-email-davidlohr@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org, Davidlohr Bueso <davidlohr@hp.com>

Linus recently pointed out[1] some of the amount of unnecessary work 
being done with the mmap_sem held. This patchset is a very initial 
approach on reducing some of the contention on this lock, and moving
work outside of the critical region.

Patch 1 adds a simple helper function.

Patch 2 moves out some trivial setup logic in mlock related calls.

Patch 3 allows managing new vmas without requiring the mmap_sem for
vdsos. While it's true that there are many other scenarios where
this can be done, few are actually as straightforward as this in the
sense that we *always* end up allocating memory anyways, so there's really
no tradeoffs. For this reason I wanted to get this patch out in the open.

There are a few points to consider when preallocating vmas at the start
of system calls, such as how many new vmas (ie: callers of split_vma can
end up calling twice, depending on the mm state at that point) or the probability
that we end up merging the vma instead of having to create a new one, like the 
case of brk or copy_vma. In both cases the overhead of creating and freeing
memory at every syscall's invocation might outweigh what we gain in not holding
the sem.

[1] https://lkml.org/lkml/2013/10/9/665 

Thanks!

Davidlohr Bueso (3):
  mm: add mlock_future_check helper
  mm/mlock: prepare params outside critical region
  vdso: preallocate new vmas

 arch/arm/kernel/process.c          | 22 +++++++++----
 arch/arm64/kernel/vdso.c           | 21 ++++++++++---
 arch/hexagon/kernel/vdso.c         | 16 +++++++---
 arch/mips/kernel/vdso.c            | 10 +++++-
 arch/powerpc/kernel/vdso.c         | 11 +++++--
 arch/s390/kernel/vdso.c            | 19 +++++++++---
 arch/sh/kernel/vsyscall/vsyscall.c | 11 ++++++-
 arch/tile/kernel/vdso.c            | 13 ++++++--
 arch/um/kernel/skas/mmu.c          | 16 +++++++---
 arch/unicore32/kernel/process.c    | 17 +++++++---
 arch/x86/um/vdso/vma.c             | 18 ++++++++---
 arch/x86/vdso/vdso32-setup.c       | 16 +++++++++-
 arch/x86/vdso/vma.c                | 10 +++++-
 include/linux/mm.h                 |  3 +-
 kernel/events/uprobes.c            | 14 +++++++--
 mm/mlock.c                         | 18 ++++++-----
 mm/mmap.c                          | 63 ++++++++++++++++++--------------------
 17 files changed, 213 insertions(+), 85 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
