Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 80F066B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 15:40:38 -0500 (EST)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n15KeYM6017060
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 20:40:34 GMT
Received: from an-out-0708.google.com (anab38.prod.google.com [10.100.53.38])
	by spaceape10.eur.corp.google.com with ESMTP id n15KeVYJ002019
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 12:40:32 -0800
Received: by an-out-0708.google.com with SMTP id b38so212035ana.43
        for <linux-mm@kvack.org>; Thu, 05 Feb 2009 12:40:31 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0902051943360.6349@blonde.anvils>
References: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
	 <Pine.LNX.4.64.0902051802480.1445@blonde.anvils>
	 <77e5ae570902051110v65e08d87t885378de659195e3@mail.gmail.com>
	 <Pine.LNX.4.64.0902051943360.6349@blonde.anvils>
Date: Thu, 5 Feb 2009 12:40:31 -0800
Message-ID: <77e5ae570902051240l1c7de8d5jbef5cfe55c156b6c@mail.gmail.com>
Subject: Re: Swap Memory
From: William Chan <williamchan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, wchan212@gmail.com
List-ID: <linux-mm.kvack.org>

> Sorry to confuse: I meant that get_swap_page() cycles around swap
> areas of the same priority before going on to the next priority,
> I didn't mean that it "rotates the priorities".

I think we should at a minimum do a rotation around same priority.
This is easy to implement with minimal overhead. I can send a patch in
for this later.

> I'm not a good person to discuss such matters with;
> but I thought MD/DM was perfectly capable of software RAID?

Software raid consumes lots of CPU cycles - it is not ideal. Even the
cheap hardware RAIDs that come with a lot of desktop mobos nowadays,
they consume a lot of CPU cycles as well.

> Would MD/DM prevent that?  As I see it, you're asking for striping,
> and we already have a layer that specializes in that and more,
> so why add such features in at the swap end.

I do not think MD/DM would take "full" advantage. And it is very hard
to take full advantage. By full advantage I mean correct load
balancing, put Z % of pages on the 7200 rpm drive and (1 - Z) % of
pages on 5400 rpm drive to maximize the average E(x) of bandwidth and
minimize latency.

> I'm confused by your use of "LRU".  We have LRUs for pages in memory,
> and sometimes a page is in memory on LRU and also has a copy on swap;
> but in general the copies on swap are not on any LRU, they're on swap.

Sorry for the confusion - What I mean by LRU is Least Recently Used.
ie. Least Recently used page of memory in Swap1 or least recently used
page of memory in system memory.

> That could be changed, yes: but would multiply the amount of memory
> needed for recording pages out of swap.  The present design is to
> minimize the memory needed by what's out on swap.

Hopefully there will be less pages in swap than in system memory. If
this is true - the overhead introduced should be minimal relative to
the overhead the kernel already has for manging system memory pages.

will



On Thu, Feb 5, 2009 at 11:57 AM, Hugh Dickins <hugh@veritas.com> wrote:
> On Thu, 5 Feb 2009, William Chan wrote:
>> > Correct (or you can have several at the same priority,
>> > and it rotates around them before going down to the next priority).
>>
>> Where does it rotate the priorities? I am looking at mm/swapfile.c and
>> swp_entry_t get_swap_page(void), I can not find where it rotates.
>
> Sorry to confuse: I meant that get_swap_page() cycles around swap
> areas of the same priority before going on to the next priority,
> I didn't mean that it "rotates the priorities".
>
>>
>> > True.  But wouldn't you use MD/DM for that, say, RAID 0 swap?
>> > The priority scheme in swap is rather ancient, but is there any
>> > point in fiddling with that, when there's already a logical
>> > volume management layer which could do it better for you?
>> >
>> > Though googling for "RAID 0 swap" doesn't inspire confidence.
>>
>> There are many cases where RAID 0 may not be applicable. What if my
>> user is cost conscience and can't afford a RAID chip?
>
> I'm not a good person to discuss such matters with;
> but I thought MD/DM was perfectly capable of software RAID?
>
>> Or fFor example,
>> what if I have uneven drives - I have 1 drive that is 20 GB and 5400
>> rpm and 40 GB at 7200 rpm. It would still be advantageous to take
>> advantage of the additional bandwidth - I mean if the system already
>> has two swap drives - why not take advantage of it?
>
> Would MD/DM prevent that?  As I see it, you're asking for striping,
> and we already have a layer that specializes in that and more,
> so why add such features in at the swap end.
>
>> > However, I don't get what you're proposing.  You write of evicting
>> > LRU pages in priority 1 swap to priority 2 swap.  But if those pages
>> > are still on an LRU in memory, doesn't that imply that they're useful
>> > pages, which we're more likely to want to delete from swap, than copy
>> > to slower storage?
>>
>> I am saying - there may be other pages that need to be evicted to swap
>> and are more used than the LRU page in priority 1 swap. IE. I have a
>> page I want to evict to swap, but Swap1 is full - I want to evict some
>> of the LRU pages on Swap1 to Swap2 to make room for the new pages I
>> want to evict.
>
> I'm confused by your use of "LRU".  We have LRUs for pages in memory,
> and sometimes a page is in memory on LRU and also has a copy on swap;
> but in general the copies on swap are not on any LRU, they're on swap.
>
>> > I can imagine wanting to move long-forgotten pages from fast swap to
>> > slower swap; but the overhead of such housekeeping rather puts me off.
>> > It sounds like swap prefetch, but for those pages which we least want
>> > to have in memory rather than those which we're likely to want.
>>
>> I think this is an area that is definitely worth exploring - I agree
>> tho, for some systems, the overhead may be big enough to make it not
>> worth it. If we use a linked list, the overhead would be linearly
>> proportional to the number of pages in the swap. We would need to
>> update an LRU linked list for each memory access into swap. We may or
>> may not want a daemon which is responsible for evicting pages from
>> high priority swap into low priority (or vice versa if pages in the
>> 2nd priority swap becomes used a lot). I have not done any
>> benchmarking or intensive research to measure the overhead - but
>> doesn't the kernel mm already do an LRU list for pages in physical
>> memory to evict them to swap?
>
> Yes, but the LRU in memory is for pages in memory: once they're out
> to swap, and freed from memory, there is no LRU for them.
>
> That could be changed, yes: but would multiply the amount of memory
> needed for recording pages out of swap.  The present design is to
> minimize the memory needed by what's out on swap.
>
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
