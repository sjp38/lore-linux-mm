Date: Mon, 10 Jul 2000 02:53:42 -0700
From: Philipp Rumpf <prumpf@uzix.org>
Subject: Re: sys_exit() and zap_page_range()
Message-ID: <20000710025342.A3826@fruits.uzix.org>
References: <3965EC8E.5950B758@uow.edu.au>, <3965EC8E.5950B758@uow.edu.au> <20000709103011.A3469@fruits.uzix.org> <396910CE.64A79820@uow.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <396910CE.64A79820@uow.edu.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <andrewm@uow.edu.au>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, Jul 09, 2000 at 11:54:54PM +0000, Andrew Morton wrote:
> Philipp Rumpf wrote:
> Hi, Philipp.
> 
> > Here's a simple way:
> 
> Already done it :)  It's apparent that not _all_ callers of z_p_r need
> this treatment, so I've added an extra 'do_reschedule' flag.  I've also
> moved the TLB flushing into this function.

It is ?  I must be missing something, but it looks to me like all calls
to z_p_r can be done out of syscalls, with pretty much any size the user
wants.

> It strikes me that the TLB flush race can be avoided by simply deferring
> the actual free_page until _after_ the flush.  So
> free_page_and_swap_cache simply appends them to a passed-in list rather
> than returning them to the buddy allocator.  zap_page_range can then
> free the pages after the flush.

In fact, both the tlb flushing and the cache invalidating/flushing (we don't
really need to flush the cache if we're zapping the last mapping) belong in
zap_page_range.  Right now three callers don't do the tlb/cache flushes:
 exit_mmap and move_page_tables should be fine with doing the cache/tlb
invalidates;  read_zero_pagealigned doesn't want to have intermediate invalid
ptes, so I would say it's buggy now.

> > [PAGE_SIZE*4 is low, I suspect.]
> 
> zap_page_range zaps 1000 pages per millisecond, so I'm doing 1000 at a
> time.

I think we should be able to live with that for 2.4, unless the tlb flushing
race is really bad.  It looks like a rather theoretical possibility limited
to SMP systems to me.

	Philipp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
