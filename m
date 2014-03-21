Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id E57216B003B
	for <linux-mm@kvack.org>; Fri, 21 Mar 2014 17:17:52 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so2915564pbc.2
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:17:52 -0700 (PDT)
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
        by mx.google.com with ESMTPS id dg5si4383820pbc.179.2014.03.21.14.17.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Mar 2014 14:17:51 -0700 (PDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2837665pdi.30
        for <linux-mm@kvack.org>; Fri, 21 Mar 2014 14:17:51 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/5] Volatile Ranges (v12) & LSF-MM discussion fodder
Date: Fri, 21 Mar 2014 14:17:30 -0700
Message-Id: <1395436655-21670-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Just wanted to send out an updated patch set that includes changes from
some of the reviews. Hopefully folks will have some time to look them
over prior to the LSF-MM discussion on volatile ranges on Tuesday (see
below for LSF-MM discussion points to think about).

New changes are:
----------------
o Added flags argument to the syscall, which is unused, but per
  https://lwn.net/Articles/585415/ seems like a good idea.
o Minor vma traversing cleanups suggested by Jan
o Return an error when trying to mark unmapped regions
o First pass implementation of marking pages referenced when
  they are marked volatile, so the pages in a range are set to
  the same "age" and will be approximately purged together.
  This behavior is still open for discussion.
o Very naive implementation of anonymous page aging on swapless
  systems. This has clear performance issues, as we burn time
  overly scanning anonymous pages, but provides something
  concrete upon which to discuss what the best way would be to
  solve this.
o Other minor code cleanups

The first three patches are still the core functionality, which
I'd really like further review on. The last two patches in this
series are more discussion starters, and are less serious.


Potential discussion items for LSF-MM to think about:
----------------------------------------------------
o How to increase reviewer interest?
    - Lots of interest from application world
o Page aging semantics when marking volatile.
    - Should marking volatile be the same as accessing pages?
    - Should volatile ranges be put on end of inactive lru?
    - Should we just punt this and have applications combine madvise()
      use with vrange() to specify range age?
o Volatile page & purged page accounting
    - Volatility is stored in per-process vma, not page
    - vmstats are page based, how do we deal w/ COWed pages?
o Aging anonymous memory on swapless systems
    - Any thoughts on improving over naive method?
    - Better volatile page accounting might help?
    - Do we need a separate volatile LRU?
o Shared volatility on tmpfs/shm/memfd (required for ashmem)
    - Johannes idea for clearing dirty bits?
    - vma-like structure on the address space?

thanks
-john


Volatile ranges provides a method for userland to inform the kernel that
a range of memory is safe to discard (ie: can be regenerated) but
userspace may want to try access it in the future.  It can be thought of
as similar to MADV_DONTNEED, but that the actual freeing of the memory
is delayed and only done under memory pressure, and the user can try to
cancel the action and be able to quickly access any unpurged pages. The
idea originated from Android's ashmem, but I've since learned that other
OSes provide similar functionality.

This functionality allows for a number of interesting uses. One such
example is: Userland caches that have kernel triggered eviction under
memory pressure. This allows for the kernel to "rightsize" userspace
caches for current system-wide workload. Things like image bitmap
caches, or rendered HTML in a hidden browser tab, where the data is
not visible and can be regenerated if needed, are good examples.

Both Chrome and Firefox already make use of volatile ranges via the
ashmem interface:
https://hg.mozilla.org/releases/mozilla-b2g28_v1_3t/rev/a32c32b24a34

https://chromium.googlesource.com/chromium/src/base/+/47617a69b9a57796935e03d78931bd01b4806e70/memory/discardable_memory_allocator_android.cc


There are two basic ways volatile ranges can be used:

Explicit marking method:
1) Userland marks a range of memory that can be regenerated if necessary
as volatile
2) Before accessing the memory again, userland marks the memory as
nonvolatile, and the kernel will provide notification if any pages in the
range has been purged.

Optimistic method:
1) Userland marks a large range of data as volatile
2) Userland continues to access the data as it needs.
3) If userland accesses a page that has been purged, the kernel will
send a SIGBUS
4) Userspace can trap the SIGBUS, mark the affected pages as
non-volatile, and refill the data as needed before continuing on


You can read more about the history of volatile ranges here (~reverse
chronological order):
https://lwn.net/Articles/590991/
http://permalink.gmane.org/gmane.linux.kernel.mm/98848
http://permalink.gmane.org/gmane.linux.kernel.mm/98676
https://lwn.net/Articles/522135/
https://lwn.net/Kernel/Index/#Volatile_ranges


Continuing from the last release, this revision is reduced in scope
when compared to earlier attempts. I've only focused on handled
volatility on anonymous memory, and we're storing the volatility in
the VMA.  This may have performance implications compared with the earlier
approach, but it does simplify the approach. I'm open to expanding
functionality via flags arugments, but for now I'm wanting to keep focus
on what the right default behavior should be and keep the use cases
restricted to help get reviewer interest.

Further, the page discarding happens via normal vmscanning, which due to
anonymous pages not being aged on swapless systems, means we'll only purge
pages when swap is enabled. In this version I've included a naive
implementation of enabling anonymous scanning on swapless systems, which
clearly has performance issues, but hopefully will trigger some discussion
on how to best do this.

Additionally, since we don't handle volatility on tmpfs files with this
version of the patch, it is not able to be used to implement semantics
similar to Android's ashmem. But since shared volatiltiy on files is
more complex, my hope is to start small and hopefully grow from there.

Again, much of the logic in this patchset is based on Minchan's earlier
efforts, so I do want to make sure the credit goes to him for his major
contribution!


Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Android Kernel Team <kernel-team@android.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Robert Love <rlove@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>
Cc: Rik van Riel <riel@redhat.com>
Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
Cc: Neil Brown <neilb@suse.de>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mike Hommey <mh@glandium.org>
Cc: Taras Glek <tglek@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>


John Stultz (5):
  vrange: Add vrange syscall and handle splitting/merging and marking
    vmas
  vrange: Add purged page detection on setting memory non-volatile
  vrange: Add page purging logic & SIGBUS trap
  vrange: Set affected pages referenced when marking volatile
  vmscan: Age anonymous memory even when swap is off.

 arch/x86/syscalls/syscall_64.tbl |   1 +
 include/linux/mm.h               |   1 +
 include/linux/swap.h             |  15 +-
 include/linux/swapops.h          |  10 +
 include/linux/vrange.h           |  13 ++
 mm/Makefile                      |   2 +-
 mm/internal.h                    |   2 -
 mm/memory.c                      |  21 ++
 mm/rmap.c                        |   5 +
 mm/vmscan.c                      |  38 ++--
 mm/vrange.c                      | 433 +++++++++++++++++++++++++++++++++++++++
 11 files changed, 514 insertions(+), 27 deletions(-)
 create mode 100644 include/linux/vrange.h
 create mode 100644 mm/vrange.c

-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
