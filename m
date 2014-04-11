Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5896B004D
	for <linux-mm@kvack.org>; Fri, 11 Apr 2014 16:15:55 -0400 (EDT)
Received: by mail-pd0-f181.google.com with SMTP id p10so5693914pdj.12
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:15:55 -0700 (PDT)
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
        by mx.google.com with ESMTPS id z10si4857709pbx.52.2014.04.11.13.15.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 11 Apr 2014 13:15:53 -0700 (PDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so5758268pab.8
        for <linux-mm@kvack.org>; Fri, 11 Apr 2014 13:15:53 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/4] Volatile Ranges (v13)
Date: Fri, 11 Apr 2014 13:15:36 -0700
Message-Id: <1397247340-3365-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Just wanted to send out an updated patch set that includes changes
(mostly cleanups and fixes) from some of the reviews and discussion
at LSF-MM.

New changes are:
----------------
o Renamed vrange syscall to mvolatile (Per Hugh's suggestion)
o Dropped any modifications made to page age when marking volatile.
  (from LSF-MM discussion)
o Changed "discard" usage to "purged" for clarity/consistency
  (Kosaki-san's suggestion)
o Moved appropriate header definitions to uapi/ (Kosaki-san)
o Made sure to take write on mmap_sem (Kosaki-san/Minchan)
o Made sure to clean ptes on marking non-volatile rather then
  cleaning them on fault (Kosaki-san's suggestion)
o Introduced a cleanup patch to make adding new psudo-swap types
  simpler
o Numerous other fixes from Minchan
o Numerous other fixes suggested by Kosaki-san
o For now I've also dropped the naive aging anonymous memory on
  swapless systems, as I need to sort out accounting details first.


Still on the TODO list
----------------------------------------------------
o Look into possibility of doing VMA splitting/merging more
  carefully by hand to avoid potential allocation failures.
  This would allow us to go back using madvise() syscall.
o Sort out how best to do page accounting when the volatility
  is tracked on a per-mm basis.
o Revisit anonymous page aging on swapless systems
o Draft up re-adding tmpfs/shm file volatility support


There is of course, the ongoing discussion w/ Johannes
about his suggestion of cleaning the pte entries dirty
bit to represent volatility. While this method is
attractive from a kernel mm-developer point of view,
the resulting semantics are quite subtle and I worry
would be confusing and error prone for application
developers. If consensus builds for that approach,
I'm willing to move to that method, but until then
I figured I'd continue with this approach, which
has simpler semantics (but will require more logic
when tmpfs/shm file support is readded).


Many thanks again to Minchan, Kosaki-san, Johannes, Jan, Rik,
Hugh, and others for the great feedback and discussion at
LSF-MM.

thanks
-john


Volatile ranges provides a method for userland to inform the kernel
that a range of memory is safe to discard (ie: can be regenerated)
but userspace may want to try access it in the future.  It can be
thought of as similar to MADV_DONTNEED, but that the actual freeing
of the memory is delayed and only done under memory pressure, and the
user can try to cancel the action and be able to quickly access any
unpurged pages. The idea originated from Android's ashmem, but I've
since learned that other OSes provide similar functionality.

This functionality allows for a number of interesting uses. One such
example is: Userland caches that have kernel triggered eviction under
memory pressure. This allows for the kernel to "rightsize" userspace
caches for current system-wide workload. Things like image bitmap
caches, or rendered HTML in a hidden browser tab, where the data is
not visible and can be regenerated if needed, are good examples.

Both Chrome and Firefox already make use of volatile range-like
functionality via the ashmem interface:
https://hg.mozilla.org/releases/mozilla-b2g28_v1_3t/rev/a32c32b24a34

https://chromium.googlesource.com/chromium/src/base/+/47617a69b9a57796935e03d78931bd01b4806e70/memory/discardable_memory_allocator_android.cc


The basic usage of volatile ranges is as so:
1) Userland marks a range of memory that can be regenerated if
necessary as volatile
2) Before accessing the memory again, userland marks the memory as
nonvolatile, and the kernel will provide notification if any pages in
the range has been purged.

If userland accesses memory while it is volatile, it will either
get the value stored at that memory if there has been no memory
pressure or the application will get a SIGBUS if the page has been
purged.

Reads or writes to the memory do not affect the volatility state of the
pages.

You can read more about the history of volatile ranges here (~reverse
chronological order):
https://lwn.net/Articles/592042/
https://lwn.net/Articles/590991/
http://permalink.gmane.org/gmane.linux.kernel.mm/98848
http://permalink.gmane.org/gmane.linux.kernel.mm/98676
https://lwn.net/Articles/522135/
https://lwn.net/Kernel/Index/#Volatile_ranges


Continuing from the last few releases, this revision is reduced in
scope when compared to earlier attempts. I've only focused on handled
volatility on anonymous memory, and we're storing the volatility in
the VMA.  This may have performance implications compared with the
earlier approach, but it does simplify the approach. I'm open to
expanding functionality via flags arguments, but for now I'm wanting
to keep focus on what the right default behavior should be and keep
the use cases restricted to help get reviewer interest.

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
Cc: Keith Packard <keithp@keithp.com>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>

John Stultz (4):
  swap: Cleanup how special swap file numbers are defined
  mvolatile: Add mvolatile syscall and handle splitting/merging and
    marking vmas
  mvolatile: Add purged page detection on setting memory non-volatile
  mvolatile: Add page purging logic & SIGBUS trap

 arch/x86/syscalls/syscall_64.tbl |   1 +
 include/linux/mm.h               |   1 +
 include/linux/mvolatile.h        |  10 +
 include/linux/swap.h             |  36 ++--
 include/linux/swapops.h          |  10 +
 include/uapi/linux/mvolatile.h   |   7 +
 mm/Makefile                      |   2 +-
 mm/internal.h                    |   2 -
 mm/memory.c                      |   8 +
 mm/mvolatile.c                   | 401 +++++++++++++++++++++++++++++++++++++++
 mm/rmap.c                        |   5 +
 mm/vmscan.c                      |  12 ++
 12 files changed, 481 insertions(+), 14 deletions(-)
 create mode 100644 include/linux/mvolatile.h
 create mode 100644 include/uapi/linux/mvolatile.h
 create mode 100644 mm/mvolatile.c

-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
