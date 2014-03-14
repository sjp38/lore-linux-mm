Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f43.google.com (mail-pb0-f43.google.com [209.85.160.43])
	by kanga.kvack.org (Postfix) with ESMTP id 2C7D56B007B
	for <linux-mm@kvack.org>; Fri, 14 Mar 2014 14:33:46 -0400 (EDT)
Received: by mail-pb0-f43.google.com with SMTP id um1so2953202pbc.16
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 11:33:45 -0700 (PDT)
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
        by mx.google.com with ESMTPS id sf3si464734pac.452.2014.03.14.11.33.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 14 Mar 2014 11:33:44 -0700 (PDT)
Received: by mail-pb0-f41.google.com with SMTP id jt11so2966200pbb.14
        for <linux-mm@kvack.org>; Fri, 14 Mar 2014 11:33:44 -0700 (PDT)
From: John Stultz <john.stultz@linaro.org>
Subject: [PATCH 0/3] Volatile Ranges (v11)
Date: Fri, 14 Mar 2014 11:33:30 -0700
Message-Id: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: John Stultz <john.stultz@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

I recently got a chance to try to implement Johannes' suggested approach
so I wanted to send it out for comments. It looks like Minchan has also
done the same, but from a different direction, focusing on the MADV_FREE
use cases. I think both approaches are valid, so I wouldn't consider
these patches to be in conflict. Its just that earlier iterations of the
volatile range patches had tried to handle numerous different use cases,
and the resulting complexity was apparently making it difficult to review
and get interest in the patch set. So basically we're splitting the use
cases up and trying to find simpler solutions for each.

I'd greatly appreciate any feedback or thoughts!

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

This functionality allows for a number of interesting uses:
* Userland caches that have kernel triggered eviction under memory
pressure. This allows for the kernel to "rightsize" userspace caches for
current system-wide workload. Things like image bitmap caches, or
rendered HTML in a hidden browser tab, where the data is not visible and
can be regenerated if needed, are good examples.

* Opportunistic freeing of memory that may be quickly reused. Minchan
has done a malloc implementation where free() marks the pages as
volatile, allowing the kernel to reclaim under pressure. This avoids the
unmapping and remapping of anonymous pages on free/malloc. So if
userland wants to malloc memory quickly after the free, it just needs to
mark the pages as non-volatile, and only purged pages will have to be
faulted back in.

There are two basic ways this can be used:

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

You can read more about the history of volatile ranges here:
http://permalink.gmane.org/gmane.linux.kernel.mm/98848
http://permalink.gmane.org/gmane.linux.kernel.mm/98676
https://lwn.net/Articles/522135/
https://lwn.net/Kernel/Index/#Volatile_ranges


This version of the patchset, at Johannes Weiner's suggestion, is much
reduced in scope compared to earlier attempts. I've only handled
volatility on anonymous memory, and we're storing the volatility in
the VMA.  This may have performance implications compared with the earlier
approach, but it does simplify the approach.

Further, the page discarding happens via normal vmscanning, which due to
anonymous pages not being aged on swapless systems, means we'll only purge
pages when swap is enabled. I'll be looking at enabling anonymous aging
when swap is disabled to resolve this, but I wanted to get this out for
initial comment.

Additionally, since we don't handle volatility on tmpfs files with this
version of the patch, it is not able to be used to implement semantics
similar to Android's ashmem. But since shared volatiltiy on files is
more complex, my hope is to start small and hopefully grow from there.

Also, much of the logic in this patchset is based on Minchan's earlier
efforts. On this iteration, I've not been in close collaboration with him,
so I don't want to mis-attribute my rework of the code as his design,
but I do want to make sure the credit goes to him for his major contribution.


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
Cc: Dhaval Giani <dgiani@mozilla.com>
Cc: Jan Kara <jack@suse.cz>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Michel Lespinasse <walken@google.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org <linux-mm@kvack.org>


John Stultz (3):
  vrange: Add vrange syscall and handle splitting/merging and marking
    vmas
  vrange: Add purged page detection on setting memory non-volatile
  vrange: Add page purging logic & SIGBUS trap

 arch/x86/syscalls/syscall_64.tbl |   1 +
 include/linux/mm.h               |   1 +
 include/linux/swap.h             |  15 +-
 include/linux/vrange.h           |  22 +++
 mm/Makefile                      |   2 +-
 mm/internal.h                    |   2 -
 mm/memory.c                      |  21 +++
 mm/rmap.c                        |   5 +
 mm/vmscan.c                      |  12 ++
 mm/vrange.c                      | 306 +++++++++++++++++++++++++++++++++++++++
 10 files changed, 382 insertions(+), 5 deletions(-)
 create mode 100644 include/linux/vrange.h
 create mode 100644 mm/vrange.c

-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
