Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id ACA9A6B0038
	for <linux-mm@kvack.org>; Wed, 25 Mar 2015 02:17:31 -0400 (EDT)
Received: by wixw10 with SMTP id w10so23427990wix.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 23:17:31 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id ko5si2495560wjb.189.2015.03.24.23.17.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Mar 2015 23:17:30 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 00/12] mm: page_alloc: improve OOM mechanism and policy
Date: Wed, 25 Mar 2015 02:17:04 -0400
Message-Id: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

Hi everybody,

in the recent past we've had several reports and discussions on how to
deal with allocations hanging in the allocator upon OOM.

The idea of this series is mainly to make the mechanism of detecting
OOM situations reliable enough that we can be confident about failing
allocations, and then leave the fallback strategy to the caller rather
than looping forever in the allocator.

The other part is trying to reduce the __GFP_NOFAIL deadlock rate, at
least for the short term while we don't have a reservation system yet.

Here is a breakdown of the proposed changes:

 mm: oom_kill: remove pointless locking in oom_enable()
 mm: oom_kill: clean up victim marking and exiting interfaces
 mm: oom_kill: remove misleading test-and-clear of known TIF_MEMDIE
 mm: oom_kill: remove pointless locking in exit_oom_victim()
 mm: oom_kill: generalize OOM progress waitqueue
 mm: oom_kill: simplify OOM killer locking
 mm: page_alloc: inline should_alloc_retry() contents

These are preparational patches to clean up parts in the OOM killer
and the page allocator.  Filesystem folks and others that only care
about allocation semantics may want to skip over these.

 mm: page_alloc: wait for OOM killer progress before retrying

One of the hangs we have seen reported is from lower order allocations
that loop infinitely in the allocator.  In an attempt to address that,
it has been proposed to limit the number of retry loops - possibly
even make that number configurable from userspace - and return NULL
once we are certain that the system is "truly OOM".  But it wasn't
clear how high that number needs to be to reliably determine a global
OOM situation from the perspective of an individual allocation.

An issue is that OOM killing is currently an asynchroneous operation
and the optimal retry number depends on how long it takes an OOM kill
victim to exit and release its memory - which of course varies with
system load and exiting task.

To address this, this patch makes OOM killing synchroneous and only
returns to the allocator once the victim has actually exited.  With
that, the allocator no longer requires retry loops just to poll for
the victim releasing memory.

 mm: page_alloc: private memory reserves for OOM-killing allocations

Once out_of_memory() is synchroneous, there are still two issues that
can make determining system-wide OOM from a single allocation context
unreliable.  For one, concurrent allocations can swoop in right after
a kill and steal the memory, causing spurious allocation failures for
contexts that actually freed memory.  But also, the OOM victim could
get blocked on some state that the allocation is holding, which would
delay the release of the memory (and refilling of the reserves) until
after the allocation has completed.

This patch creates private reserves for allocations that have issued
an OOM kill.  Once these reserves run dry, it seems reasonable to
assume that other allocations are not succeeding either anymore.

 mm: page_alloc: emergency reserve access for __GFP_NOFAIL allocations

An exacerbation of the victim-stuck-behind-allocation scenario are
__GFP_NOFAIL allocations, because they will actually deadlock.  To
avoid this, or try to, give __GFP_NOFAIL allocations access to not
just the OOM reserves but also the system's emergency reserves.

This is basically a poor man's reservation system, which could or
should be replaced later on with an explicit reservation system that
e.g. filesystems have control over for use by transactions.

It's obviously not bulletproof and might still lock up, but it should
greatly reduce the likelihood.  AFAIK Andrea, whose idea this was, has
been using this successfully for some time.

 mm: page_alloc: do not lock up GFP_NOFS allocations upon OOM

Another hang that was reported was from NOFS allocations.  The trouble
with these is that they can't issue or wait for writeback during page
reclaim, and so we don't want to OOM kill on their behalf.  However,
with such restrictions on making progress, they are prone to hangs.

This patch makes NOFS allocations fail if reclaim can't free anything.

It would be good if the filesystem people could weigh in on whether
they can deal with failing GFP_NOFS allocations, or annotate the
exceptions with __GFP_NOFAIL etc.  It could well be that a middle
ground is required that allows using the OOM killer before giving up.

 mm: page_alloc: do not lock up low-order allocations upon OOM

With both OOM killing and "true OOM situation" detection more
reliable, this patch finally allows allocations up to order 3 to
actually fail on OOM and leave the fallback strategy to the caller -
as opposed to the current policy of hanging in the allocator.

Comments?

 drivers/staging/android/lowmemorykiller.c |   2 +-
 include/linux/mmzone.h                    |   2 +
 include/linux/oom.h                       |  12 +-
 kernel/exit.c                             |   2 +-
 mm/internal.h                             |   3 +-
 mm/memcontrol.c                           |  20 +--
 mm/oom_kill.c                             | 167 +++++++-----------------
 mm/page_alloc.c                           | 189 +++++++++++++---------------
 mm/vmstat.c                               |   2 +
 9 files changed, 154 insertions(+), 245 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
