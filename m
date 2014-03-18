Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 316B36B00C0
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 11:08:29 -0400 (EDT)
Received: by mail-pb0-f52.google.com with SMTP id rr13so7446508pbb.11
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 08:08:28 -0700 (PDT)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id q5si18364816pbh.254.2014.03.18.08.08.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 18 Mar 2014 08:08:27 -0700 (PDT)
Received: by mail-pd0-f182.google.com with SMTP id y10so7177213pdj.41
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 08:08:27 -0700 (PDT)
Date: Tue, 18 Mar 2014 15:11:14 +0000
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 0/3] Volatile Ranges (v11)
Message-ID: <20140318151113.GA10724@gmail.com>
References: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1394822013-23804-1-git-send-email-john.stultz@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Android Kernel Team <kernel-team@android.com>, Johannes Weiner <hannes@cmpxchg.org>, Robert Love <rlove@google.com>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave@sr71.net>, Rik van Riel <riel@redhat.com>, Dmitry Adamushko <dmitry.adamushko@gmail.com>, Neil Brown <neilb@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Mike Hommey <mh@glandium.org>, Taras Glek <tglek@mozilla.com>, Dhaval Giani <dgiani@mozilla.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Michel Lespinasse <walken@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello John,

Sorry for late. Timing between us is always not good.
I say my thought although I don't prepare whole thing in my brain
since you sent out the patchset(Anyway, we should share ideas before
the LSF/MM)

On Fri, Mar 14, 2014 at 11:33:30AM -0700, John Stultz wrote:
> I recently got a chance to try to implement Johannes' suggested approach
> so I wanted to send it out for comments. It looks like Minchan has also
> done the same, but from a different direction, focusing on the MADV_FREE
> use cases. I think both approaches are valid, so I wouldn't consider

True and I just wanted to think over vrange-anon after resolving
MADV_FREE first because MADV_FREE is very clear(ie, Other OS and general
allocators already have supported) and vrange-anon might share some of
implementaion from MADV_FREE. Once we give up the vrange syscall's speed(
ex, no mmap_sem writeside lock, no pte enumeration in syscall contex)
we could do better for other parts. I will describe them in below.

> these patches to be in conflict. Its just that earlier iterations of the
> volatile range patches had tried to handle numerous different use cases,
> and the resulting complexity was apparently making it difficult to review
> and get interest in the patch set. So basically we're splitting the use
> cases up and trying to find simpler solutions for each.
> 
> I'd greatly appreciate any feedback or thoughts!

1) SIGBUS

It's one of the arguable issue because some user want to get a
SIGBUS(ex, Firefox) while other want a just zero page(ex, Google
address sanitizer) without signal so it should be option.
	
	int vrange(start, len, VRANGE_VOLATILE|VRANGE_ZERO, &purged);
	int vrange(start, len, VRANGE_VOLATILE|VRANGE_SIGNAL, &purged);

2) Accouting

The one of problem I have thought is lack of accouting of vrange pages.
I mean we need some statistics for vrange pages and it should be number
of pages rather than vma size. Without that, user space couldn't see
current status and then they couldn't control the system's memory
consumption. It's alredy known problem for other OS which have support
similar thing(ex, MADV_FREE).

For accouting, we should account how many of existing pages are the range
when vrange syscall is called. It could increase syscall overhead
but user could have accurate statistics information. It's just trade-off.

3) Aging

I think vrange pages should be discarded eariler than other hot pages
so want to move pages to tail of inactive LRU when syscall is called.
We could do by using deactivate_page with some tweak while we accouts
pages in syscall context.

But if user want to treat vrange pages with other hot pages equally
he could ask so that we could skip deactivating.

	vrange(start, len, VRANGE_VOLATILE|VRANGE_ZERO|VRANGE_AGING, &purged)
	or
	vrange(start, len, VRANGE_VOLATILE|VRANGE_SIGNAL|VRANGE_AGING, &purged)

It could be convenient for Moz usecase if they want to age vrange
pages.

4) Permanency

Like MCL_FUTURE of mlockall, it would be better to make the range
have permanent property until called VRANGE_NOVOLATILE.
I mean pages faulted on the range in future since syscall is called
should be volatile automatically so that user could avoid frequent
syscall to make them volatile.

Any thoughts?

> 
> thanks
> -john
> 
> 
> Volatile ranges provides a method for userland to inform the kernel that
> a range of memory is safe to discard (ie: can be regenerated) but
> userspace may want to try access it in the future.  It can be thought of
> as similar to MADV_DONTNEED, but that the actual freeing of the memory
> is delayed and only done under memory pressure, and the user can try to
> cancel the action and be able to quickly access any unpurged pages. The
> idea originated from Android's ashmem, but I've since learned that other
> OSes provide similar functionality.
> 
> This functionality allows for a number of interesting uses:
> * Userland caches that have kernel triggered eviction under memory
> pressure. This allows for the kernel to "rightsize" userspace caches for
> current system-wide workload. Things like image bitmap caches, or
> rendered HTML in a hidden browser tab, where the data is not visible and
> can be regenerated if needed, are good examples.
> 
> * Opportunistic freeing of memory that may be quickly reused. Minchan
> has done a malloc implementation where free() marks the pages as
> volatile, allowing the kernel to reclaim under pressure. This avoids the
> unmapping and remapping of anonymous pages on free/malloc. So if
> userland wants to malloc memory quickly after the free, it just needs to
> mark the pages as non-volatile, and only purged pages will have to be
> faulted back in.
> 
> There are two basic ways this can be used:
> 
> Explicit marking method:
> 1) Userland marks a range of memory that can be regenerated if necessary
> as volatile
> 2) Before accessing the memory again, userland marks the memory as
> nonvolatile, and the kernel will provide notification if any pages in the
> range has been purged.
> 
> Optimistic method:
> 1) Userland marks a large range of data as volatile
> 2) Userland continues to access the data as it needs.
> 3) If userland accesses a page that has been purged, the kernel will
> send a SIGBUS
> 4) Userspace can trap the SIGBUS, mark the affected pages as
> non-volatile, and refill the data as needed before continuing on
> 
> You can read more about the history of volatile ranges here:
> http://permalink.gmane.org/gmane.linux.kernel.mm/98848
> http://permalink.gmane.org/gmane.linux.kernel.mm/98676
> https://lwn.net/Articles/522135/
> https://lwn.net/Kernel/Index/#Volatile_ranges
> 
> 
> This version of the patchset, at Johannes Weiner's suggestion, is much
> reduced in scope compared to earlier attempts. I've only handled
> volatility on anonymous memory, and we're storing the volatility in
> the VMA.  This may have performance implications compared with the earlier
> approach, but it does simplify the approach.
> 
> Further, the page discarding happens via normal vmscanning, which due to
> anonymous pages not being aged on swapless systems, means we'll only purge
> pages when swap is enabled. I'll be looking at enabling anonymous aging
> when swap is disabled to resolve this, but I wanted to get this out for
> initial comment.
> 
> Additionally, since we don't handle volatility on tmpfs files with this
> version of the patch, it is not able to be used to implement semantics
> similar to Android's ashmem. But since shared volatiltiy on files is
> more complex, my hope is to start small and hopefully grow from there.
> 
> Also, much of the logic in this patchset is based on Minchan's earlier
> efforts. On this iteration, I've not been in close collaboration with him,
> so I don't want to mis-attribute my rework of the code as his design,
> but I do want to make sure the credit goes to him for his major contribution.
> 
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
> Cc: Dhaval Giani <dgiani@mozilla.com>
> Cc: Jan Kara <jack@suse.cz>
> Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Minchan Kim <minchan@kernel.org>
> Cc: linux-mm@kvack.org <linux-mm@kvack.org>
> 
> 
> John Stultz (3):
>   vrange: Add vrange syscall and handle splitting/merging and marking
>     vmas
>   vrange: Add purged page detection on setting memory non-volatile
>   vrange: Add page purging logic & SIGBUS trap
> 
>  arch/x86/syscalls/syscall_64.tbl |   1 +
>  include/linux/mm.h               |   1 +
>  include/linux/swap.h             |  15 +-
>  include/linux/vrange.h           |  22 +++
>  mm/Makefile                      |   2 +-
>  mm/internal.h                    |   2 -
>  mm/memory.c                      |  21 +++
>  mm/rmap.c                        |   5 +
>  mm/vmscan.c                      |  12 ++
>  mm/vrange.c                      | 306 +++++++++++++++++++++++++++++++++++++++
>  10 files changed, 382 insertions(+), 5 deletions(-)
>  create mode 100644 include/linux/vrange.h
>  create mode 100644 mm/vrange.c
> 
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
