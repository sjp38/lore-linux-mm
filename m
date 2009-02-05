Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D255B6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:58:27 -0500 (EST)
Received: from [172.20.20.9]([172.20.20.9]) (4496 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1LVAMd-0000HhC@megami.veritas.com>
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 11:58:19 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Thu, 5 Feb 2009 19:57:56 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Swap Memory
In-Reply-To: <77e5ae570902051110v65e08d87t885378de659195e3@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0902051943360.6349@blonde.anvils>
References: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
 <Pine.LNX.4.64.0902051802480.1445@blonde.anvils>
 <77e5ae570902051110v65e08d87t885378de659195e3@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: William Chan <williamchan@google.com>
Cc: linux-mm@kvack.org, wchan212@gmail.com
List-ID: <linux-mm.kvack.org>

On Thu, 5 Feb 2009, William Chan wrote:
> > Correct (or you can have several at the same priority,
> > and it rotates around them before going down to the next priority).
> 
> Where does it rotate the priorities? I am looking at mm/swapfile.c and
> swp_entry_t get_swap_page(void), I can not find where it rotates.

Sorry to confuse: I meant that get_swap_page() cycles around swap
areas of the same priority before going on to the next priority,
I didn't mean that it "rotates the priorities".

> 
> > True.  But wouldn't you use MD/DM for that, say, RAID 0 swap?
> > The priority scheme in swap is rather ancient, but is there any
> > point in fiddling with that, when there's already a logical
> > volume management layer which could do it better for you?
> >
> > Though googling for "RAID 0 swap" doesn't inspire confidence.
> 
> There are many cases where RAID 0 may not be applicable. What if my
> user is cost conscience and can't afford a RAID chip?

I'm not a good person to discuss such matters with;
but I thought MD/DM was perfectly capable of software RAID?

> Or fFor example,
> what if I have uneven drives - I have 1 drive that is 20 GB and 5400
> rpm and 40 GB at 7200 rpm. It would still be advantageous to take
> advantage of the additional bandwidth - I mean if the system already
> has two swap drives - why not take advantage of it?

Would MD/DM prevent that?  As I see it, you're asking for striping,
and we already have a layer that specializes in that and more,
so why add such features in at the swap end.

> > However, I don't get what you're proposing.  You write of evicting
> > LRU pages in priority 1 swap to priority 2 swap.  But if those pages
> > are still on an LRU in memory, doesn't that imply that they're useful
> > pages, which we're more likely to want to delete from swap, than copy
> > to slower storage?
> 
> I am saying - there may be other pages that need to be evicted to swap
> and are more used than the LRU page in priority 1 swap. IE. I have a
> page I want to evict to swap, but Swap1 is full - I want to evict some
> of the LRU pages on Swap1 to Swap2 to make room for the new pages I
> want to evict.

I'm confused by your use of "LRU".  We have LRUs for pages in memory,
and sometimes a page is in memory on LRU and also has a copy on swap;
but in general the copies on swap are not on any LRU, they're on swap.

> > I can imagine wanting to move long-forgotten pages from fast swap to
> > slower swap; but the overhead of such housekeeping rather puts me off.
> > It sounds like swap prefetch, but for those pages which we least want
> > to have in memory rather than those which we're likely to want.
> 
> I think this is an area that is definitely worth exploring - I agree
> tho, for some systems, the overhead may be big enough to make it not
> worth it. If we use a linked list, the overhead would be linearly
> proportional to the number of pages in the swap. We would need to
> update an LRU linked list for each memory access into swap. We may or
> may not want a daemon which is responsible for evicting pages from
> high priority swap into low priority (or vice versa if pages in the
> 2nd priority swap becomes used a lot). I have not done any
> benchmarking or intensive research to measure the overhead - but
> doesn't the kernel mm already do an LRU list for pages in physical
> memory to evict them to swap?

Yes, but the LRU in memory is for pages in memory: once they're out
to swap, and freed from memory, there is no LRU for them.

That could be changed, yes: but would multiply the amount of memory
needed for recording pages out of swap.  The present design is to
minimize the memory needed by what's out on swap.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
