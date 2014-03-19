Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id A7BAD6B012E
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 21:02:55 -0400 (EDT)
Received: by mail-pb0-f54.google.com with SMTP id ma3so8121801pbc.13
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 18:02:55 -0700 (PDT)
Received: from LGEMRELSE1Q.lge.com (LGEMRELSE1Q.lge.com. [156.147.1.111])
        by mx.google.com with ESMTP id yp10si8255083pab.11.2014.03.18.18.02.53
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 18:02:54 -0700 (PDT)
Date: Wed, 19 Mar 2014 10:02:53 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 0/6] mm: support madvise(MADV_FREE)
Message-ID: <20140319010253.GC13475@bbox>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <5328888C.7030402@mit.edu>
 <20140319001826.GA13475@bbox>
 <CALCETrUsgVgKDRjqY=7avbvowkNSn-CWJ3L9zti1SCOYgrY3UA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrUsgVgKDRjqY=7avbvowkNSn-CWJ3L9zti1SCOYgrY3UA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

On Tue, Mar 18, 2014 at 05:23:37PM -0700, Andy Lutomirski wrote:
> On Tue, Mar 18, 2014 at 5:18 PM, Minchan Kim <minchan@kernel.org> wrote:
> > Hello,
> >
> > On Tue, Mar 18, 2014 at 10:55:24AM -0700, Andy Lutomirski wrote:
> >> On 03/13/2014 11:37 PM, Minchan Kim wrote:
> >> > This patch is an attempt to support MADV_FREE for Linux.
> >> >
> >> > Rationale is following as.
> >> >
> >> > Allocators call munmap(2) when user call free(3) if ptr is
> >> > in mmaped area. But munmap isn't cheap because it have to clean up
> >> > all pte entries, unlinking a vma and returns free pages to buddy
> >> > so overhead would be increased linearly by mmaped area's size.
> >> > So they like madvise_dontneed rather than munmap.
> >> >
> >> > "dontneed" holds read-side lock of mmap_sem so other threads
> >> > of the process could go with concurrent page faults so it is
> >> > better than munmap if it's not lack of address space.
> >> > But the problem is that most of allocator reuses that address
> >> > space soonish so applications see page fault, page allocation,
> >> > page zeroing if allocator already called madvise_dontneed
> >> > on the address space.
> >> >
> >> > For avoidng that overheads, other OS have supported MADV_FREE.
> >> > The idea is just mark pages as lazyfree when madvise called
> >> > and purge them if memory pressure happens. Otherwise, VM doesn't
> >> > detach pages on the address space so application could use
> >> > that memory space without above overheads.
> >>
> >> I must be missing something.
> >>
> >> If the application issues MADV_FREE and then writes to the MADV_FREEd
> >> range, the kernel needs to know that the pages are no longer safe to
> >> lazily free.  This would presumably happen via a page fault on write.
> >> For that to happen reliably, the kernel has to write protect the pages
> >> when MADV_FREE is called, which in turn requires flushing the TLBs.
> >
> > It could be done by pte_dirty bit check. Of course, if some architectures
> > don't support it by H/W, pte_mkdirty would make it CoW as you said.
> 
> If the page already has dirty PTEs, then you need to clear the dirty
> bits and flush TLBs so that other CPUs notice that the PTEs are clean,
> I think.

True. I didn't mean we don't need TLB flush. Look at the code although
there are lots of bug in RFC v1.

> 
> Also, this has very odd semantics wrt reading the page after MADV_FREE
> -- is reading the page guaranteed to un-free it?

Yeb, I thought about that oddness but didn't make conclusion because
other OS seem to work like that.
http://www.freebsd.org/cgi/man.cgi?query=madvise&sektion=2

But we could fix it easily by checking access bit instead of dirty bit.

> 
> >>
> >> How does this end up being faster than munmap?
> >
> > MADV_FREE doesn't need to return back the pages into page allocator
> > compared to MADV_DONTNEED and the overhead is not small when I measured
> > that on my machine.(Roughly, MADV_FREE's cost is half of DONTNEED through
> > avoiding involving page allocator.)
> >
> > But I'd like to clarify that it's not MADV_FREE's goal that syscall
> > itself should be faster than MADV_DONTNEED but major goal is to
> > avoid unnecessary page fault + page allocation + page zeroing +
> > garbage swapout.
> 
> This sounds like it might be better solved by trying to make munmap or
> MADV_DONTNEED faster.  Maybe those functions should lazily give pages
> back to the buddy allocator.

About munmap, it needs write-mmap_sem and it hurts heavily of
allocator performance in multi-thread.

About MADV_DONTNEED, Rik van Riel tried to replace MADV_DONTNEED
with MADV_FREE in 2007(http://lwn.net/Articles/230799/).
But I don't know why it was dropped. One think I can imagine
is that it could make regression because user on MADV_DONTNEED
expect rss decreasing when syscall is called.

> 
> --Andy
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
