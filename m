Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f179.google.com (mail-wi0-f179.google.com [209.85.212.179])
	by kanga.kvack.org (Postfix) with ESMTP id 8FD9D6B0038
	for <linux-mm@kvack.org>; Tue, 22 Sep 2015 02:24:07 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so176868600wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:07 -0700 (PDT)
Received: from mail-wi0-x235.google.com (mail-wi0-x235.google.com. [2a00:1450:400c:c05::235])
        by mx.google.com with ESMTPS id 9si4908wjt.113.2015.09.21.23.24.05
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Sep 2015 23:24:06 -0700 (PDT)
Received: by wiclk2 with SMTP id lk2so176868055wic.0
        for <linux-mm@kvack.org>; Mon, 21 Sep 2015 23:24:05 -0700 (PDT)
From: Ingo Molnar <mingo@kernel.org>
Subject: [PATCH 00/11] x86/mm: Implement lockless pgd_alloc()/pgd_free()
Date: Tue, 22 Sep 2015 08:23:30 +0200
Message-Id: <1442903021-3893-1-git-send-email-mingo@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Denys Vlasenko <dvlasenk@redhat.com>, Brian Gerst <brgerst@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Waiman Long <waiman.long@hp.com>, Thomas Gleixner <tglx@linutronix.de>

So this is the somewhat belated latest iteration of the series.
I (think I) fixed all correctness bugs in the code pointed out by Oleg.

The task list walk is still 'dumb', using for_each_process(), as none of
the call sites are performance critical.

Oleg, can you see any problems with this code?

Background:

Waiman Long reported 'pgd_lock' contention on high CPU count systems and proposed
moving pgd_lock on a separate cacheline to eliminate false sharing and to reduce
some of the lock bouncing overhead.

I think we can do much better: this series eliminates the pgd_list and makes
pgd_alloc()/pgd_free() lockless.

Now the lockless initialization of the PGD has a few preconditions, which the
initial part of the series implements:

 - no PGD clearing is allowed, only additions. This makes sense as a single PGD
   entry covers 512 GB of RAM so the 4K overhead per 0.5TB of RAM mapped is
   miniscule.

The patches after that convert existing pgd_list users to walk the task list.

PGD locking is kept intact: coherency guarantees between the CPA, vmalloc,
hotplug, etc. code are unchanged.

The final patches eliminate the pgd_list and thus make pgd_alloc()/pgd_free()
lockless.

The patches have been boot tested on 64-bit and 32-bit x86 systems.

Architectures not making use of the new facility are unaffected.

Thanks,

	Ingo

===
Ingo Molnar (11):
  x86/mm/pat: Don't free PGD entries on memory unmap
  x86/mm/hotplug: Remove pgd_list use from the memory hotplug code
  x86/mm/hotplug: Don't remove PGD entries in remove_pagetable()
  x86/mm/hotplug: Simplify sync_global_pgds()
  mm: Introduce arch_pgd_init_late()
  x86/virt/guest/xen: Remove use of pgd_list from the Xen guest code
  x86/mm: Remove pgd_list use from vmalloc_sync_all()
  x86/mm/pat/32: Remove pgd_list use from the PAT code
  x86/mm: Make pgd_alloc()/pgd_free() lockless
  x86/mm: Remove pgd_list leftovers
  x86/mm: Simplify pgd_alloc()

 arch/Kconfig                      |   9 +++
 arch/x86/Kconfig                  |   1 +
 arch/x86/include/asm/pgtable.h    |   3 -
 arch/x86/include/asm/pgtable_64.h |   3 +-
 arch/x86/mm/fault.c               |  32 +++++++---
 arch/x86/mm/init_64.c             |  92 ++++++++++++--------------
 arch/x86/mm/pageattr.c            |  40 ++++++------
 arch/x86/mm/pgtable.c             | 131 +++++++++++++++++++-------------------
 arch/x86/xen/mmu.c                |  45 +++++++++++--
 fs/exec.c                         |   3 +
 include/linux/mm.h                |   6 ++
 kernel/fork.c                     |  16 +++++
 12 files changed, 227 insertions(+), 154 deletions(-)

--
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
