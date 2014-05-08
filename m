Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 7AB6D6B00C8
	for <linux-mm@kvack.org>; Thu,  8 May 2014 01:56:50 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id v10so2049589pde.27
        for <linux-mm@kvack.org>; Wed, 07 May 2014 22:56:50 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id fd9si14934679pad.306.2014.05.07.22.56.48
        for <linux-mm@kvack.org>;
        Wed, 07 May 2014 22:56:49 -0700 (PDT)
Date: Thu, 8 May 2014 14:58:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/4] Volatile Ranges (v14 - madvise reborn edition!)
Message-ID: <20140508055852.GD5282@bbox>
References: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1398806483-19122-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, Keith Packard <keithp@keithp.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Apr 29, 2014 at 02:21:19PM -0700, John Stultz wrote:
> Another few weeks and another volatile ranges patchset...
> 
> After getting the sense that the a major objection to the earlier
> patches was the introduction of a new syscall (and its somewhat
> strange dual length/purged-bit return values), I spent some time
> trying to rework the vma manipulations so we can be we won't fail
> mid-way through changing volatility (basically making it atomic).
> I think I have it working, and thus, there is no longer the
> need for a new syscall, and we can go back to using madvise()
> to set and unset pages as volatile.

As I said reply as other patch's reply, I'm ok with this but I'd
like to make it clear to support zero-filled page as well as SIGBUS.
If we want to use madvise, maybe we need another advise flag like
MADV_VOLATILE_SIGBUS.
> 
> 
> New changes are:
> ----------------
> o Reworked vma manipulations to be be atomic
> o Converted back to using madvise() as syscall interface
> o Integrated fix from Minchan to avoid SIGBUS faulting race
> o Caught/fixed subtle use-after-free bug w/ vma merging
> o Lots of minor cleanups and comment improvements
> 
> 
> Still on the TODO list
> ----------------------------------------------------
> o Sort out how best to do page accounting when the volatility
>   is tracked on a per-mm basis.

What's is your concern about page accouting?
Could you elaborate it more for everybody to understand your concern
clearly.

> o Revisit anonymous page aging on swapless systems

One idea is that we can age forcefully on swapless system if system
has volatile vma or lazyfree pages. If the number of volatile vma or
lazyfree pages is zero, we can stop the aging automatically.

> o Draft up re-adding tmpfs/shm file volatility support
> 
  o One concern from minchan.
  I really like O(1) cost of unmarking syscall.

Vrange syscall is for others, not itself. I mean if some process calls
vrange syscall, it would scacrifice his resource for others when
emergency happens so if the syscall is overhead rather expensive,
anybody doesn't want to use it.

One idea is put increasing counter in mm_struct and assign the token
to volatile vma. Maybe we can squeeze it into vma->vm_start's lower
bits if we don't want to bloat vma size because we always hold mmap_sem
with write-side lock when we handle vrange syscall.
And we can use the token and purged mark together to pte when the purge
happens. With this, we can bail out as soon as we found purged entry in
unmarking syscall so remained ptes still have purged pte although
unmarking syscall is done. But it's no problem because if the vma is
marked as volatile again, the token will be change(ie, increased) and
doesn't match with pte's token. When the page fault occur, we can compare
the token to emit SIGBUS. If it doesn't match, we can ignore and just
map new page to pte.

One problem is overflow of counter. In the case, we can deliver false
positive to user but it isn't severe, either because use have a preparation
to handle SIGBUS if he want to use vrange syscall with SIGBUS model.

> 
> Many thanks again to Minchan, Kosaki-san, Johannes, Jan, Rik,
> Hugh, and others for the great feedback and discussion at
> LSF-MM.
> 
> thanks
> -john
> 
> 
> Volatile ranges provides a method for userland to inform the kernel
> that a range of memory is safe to discard (ie: can be regenerated)
> but userspace may want to try access it in the future.  It can be
> thought of as similar to MADV_DONTNEED, but that the actual freeing
> of the memory is delayed and only done under memory pressure, and the
> user can try to cancel the action and be able to quickly access any
> unpurged pages. The idea originated from Android's ashmem, but I've
> since learned that other OSes provide similar functionality.
> 
> This functionality allows for a number of interesting uses. One such
> example is: Userland caches that have kernel triggered eviction under
> memory pressure. This allows for the kernel to "rightsize" userspace
> caches for current system-wide workload. Things like image bitmap
> caches, or rendered HTML in a hidden browser tab, where the data is
> not visible and can be regenerated if needed, are good examples.
> 
> Both Chrome and Firefox already make use of volatile range-like
> functionality via the ashmem interface:
> https://hg.mozilla.org/releases/mozilla-b2g28_v1_3t/rev/a32c32b24a34
> 
> https://chromium.googlesource.com/chromium/src/base/+/47617a69b9a57796935e03d78931bd01b4806e70/memory/discardable_memory_allocator_android.cc
> 
> 
> The basic usage of volatile ranges is as so:
> 1) Userland marks a range of memory that can be regenerated if
> necessary as volatile
> 2) Before accessing the memory again, userland marks the memory as
> nonvolatile, and the kernel will provide notification if any pages in
> the range has been purged.
> 
> If userland accesses memory while it is volatile, it will either
> get the value stored at that memory if there has been no memory
> pressure or the application will get a SIGBUS if the page has been
> purged.
> 
> Reads or writes to the memory do not affect the volatility state of the
> pages.
> 
> You can read more about the history of volatile ranges here (~reverse
> chronological order):
> https://lwn.net/Articles/592042/
> https://lwn.net/Articles/590991/
> http://permalink.gmane.org/gmane.linux.kernel.mm/98848
> http://permalink.gmane.org/gmane.linux.kernel.mm/98676
> https://lwn.net/Articles/522135/
> https://lwn.net/Kernel/Index/#Volatile_ranges
> 
> 
> Continuing from the last few releases, this revision is reduced in
> scope when compared to earlier attempts. I've only focused on handled
> volatility on anonymous memory, and we're storing the volatility in
> the VMA.  This may have performance implications compared with the
> earlier approach, but it does simplify the approach. I'm open to
> expanding functionality via flags arguments, but for now I'm wanting
> to keep focus on what the right default behavior should be and keep
> the use cases restricted to help get reviewer interest.
> 
> Additionally, since we don't handle volatility on tmpfs files with this
> version of the patch, it is not able to be used to implement semantics
> similar to Android's ashmem. But since shared volatiltiy on files is
> more complex, my hope is to start small and hopefully grow from there.
> 
> Again, much of the logic in this patchset is based on Minchan's earlier
> efforts, so I do want to make sure the credit goes to him for his major
> contribution!
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Android Kernel Team <kernel-team@android.com>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Robert Love <rlove@google.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Cc: Hugh Dickins <hughd@google.com>
> Cc: Dave Hansen <dave@sr71.net>
> Cc: Rik van Riel <riel@redhat.com>
> Cc: Dmitry Adamushko <dmitry.adamushko@gmail.com>
> Cc: Neil Brown <neilb@suse.de>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Mike Hommey <mh@glandium.org>
> Cc: Taras Glek <tglek@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: Keith Packard <keithp@keithp.com>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> 
> John Stultz (4):
>   swap: Cleanup how special swap file numbers are defined
>   MADV_VOLATILE: Add MADV_VOLATILE/NONVOLATILE hooks and handle marking
>     vmas
>   MADV_VOLATILE: Add purged page detection on setting memory
>     non-volatile
>   MADV_VOLATILE: Add page purging logic & SIGBUS trap
> 
>  include/linux/mm.h                     |   1 +
>  include/linux/mvolatile.h              |   7 +
>  include/linux/swap.h                   |  36 +++-
>  include/linux/swapops.h                |  10 +
>  include/uapi/asm-generic/mman-common.h |   5 +
>  mm/Makefile                            |   2 +-
>  mm/internal.h                          |   2 -
>  mm/madvise.c                           |  14 ++
>  mm/memory.c                            |   7 +
>  mm/mvolatile.c                         | 353 +++++++++++++++++++++++++++++++++
>  mm/rmap.c                              |   5 +
>  mm/vmscan.c                            |  12 ++
>  12 files changed, 440 insertions(+), 14 deletions(-)
>  create mode 100644 include/linux/mvolatile.h
>  create mode 100644 mm/mvolatile.c
> 
> -- 
> 1.9.1
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
