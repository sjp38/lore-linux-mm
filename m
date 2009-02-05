Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1678C6B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 14:10:48 -0500 (EST)
Received: from zps75.corp.google.com (zps75.corp.google.com [172.25.146.75])
	by smtp-out.google.com with ESMTP id n15JAkGN017772
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 11:10:46 -0800
Received: from yx-out-2324.google.com (yxg8.prod.google.com [10.190.2.136])
	by zps75.corp.google.com with ESMTP id n15JAhKD021887
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 11:10:43 -0800
Received: by yx-out-2324.google.com with SMTP id 8so176309yxg.75
        for <linux-mm@kvack.org>; Thu, 05 Feb 2009 11:10:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <Pine.LNX.4.64.0902051802480.1445@blonde.anvils>
References: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
	 <Pine.LNX.4.64.0902051802480.1445@blonde.anvils>
Date: Thu, 5 Feb 2009 11:10:42 -0800
Message-ID: <77e5ae570902051110v65e08d87t885378de659195e3@mail.gmail.com>
Subject: Re: Swap Memory
From: William Chan <williamchan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: linux-mm@kvack.org, wchan212@gmail.com
List-ID: <linux-mm.kvack.org>

> Correct (or you can have several at the same priority,
> and it rotates around them before going down to the next priority).

Where does it rotate the priorities? I am looking at mm/swapfile.c and
swp_entry_t get_swap_page(void), I can not find where it rotates.

> True.  But wouldn't you use MD/DM for that, say, RAID 0 swap?
> The priority scheme in swap is rather ancient, but is there any
> point in fiddling with that, when there's already a logical
> volume management layer which could do it better for you?
>
> Though googling for "RAID 0 swap" doesn't inspire confidence.

There are many cases where RAID 0 may not be applicable. What if my
user is cost conscience and can't afford a RAID chip? Or fFor example,
what if I have uneven drives - I have 1 drive that is 20 GB and 5400
rpm and 40 GB at 7200 rpm. It would still be advantageous to take
advantage of the additional bandwidth - I mean if the system already
has two swap drives - why not take advantage of it?

> I'm accustomed to answering that you should be adding RAM rather
> than worrying about the speed of swap.  But it could well be that
> SSDs will change the game, and deserve more attention to tiered swap.

Sure, for PCs yes - adding more RAM is probably the way to go. However
adding RAM may not always be the solution - sure RAM is a lot cheaper
nowadays - but there are still many applications that need swap. For
example, what if I am doing protein folding and I need 1 TB of RAM,
but after I finish a set of calculations I just need to set it aside,
but I won't touch that piece of data until 5 gazillion cpu cycles
later for a 2nd pass.

> However, I don't get what you're proposing.  You write of evicting
> LRU pages in priority 1 swap to priority 2 swap.  But if those pages
> are still on an LRU in memory, doesn't that imply that they're useful
> pages, which we're more likely to want to delete from swap, than copy
> to slower storage?

I am saying - there may be other pages that need to be evicted to swap
and are more used than the LRU page in priority 1 swap. IE. I have a
page I want to evict to swap, but Swap1 is full - I want to evict some
of the LRU pages on Swap1 to Swap2 to make room for the new pages I
want to evict.

> I can imagine wanting to move long-forgotten pages from fast swap to
> slower swap; but the overhead of such housekeeping rather puts me off.
> It sounds like swap prefetch, but for those pages which we least want
> to have in memory rather than those which we're likely to want.

I think this is an area that is definitely worth exploring - I agree
tho, for some systems, the overhead may be big enough to make it not
worth it. If we use a linked list, the overhead would be linearly
proportional to the number of pages in the swap. We would need to
update an LRU linked list for each memory access into swap. We may or
may not want a daemon which is responsible for evicting pages from
high priority swap into low priority (or vice versa if pages in the
2nd priority swap becomes used a lot). I have not done any
benchmarking or intensive research to measure the overhead - but
doesn't the kernel mm already do an LRU list for pages in physical
memory to evict them to swap?


will


On Thu, Feb 5, 2009 at 10:33 AM, Hugh Dickins <hugh@veritas.com> wrote:
> On Tue, 3 Feb 2009, William Chan wrote:
>>
>> According to my understanding of the kernel mm, swap pages are
>> allocated in order of priority.
>>
>> For example, I have the follow swap devices: FlashDevice1 with
>> priority 1 and DiskDevice2 with priority 2 and DiskDevice3 with
>> priority3. FlashDevice1 will get filled up, then DsikDevice2 and
>> DiskDevice3.
>
> Correct (or you can have several at the same priority,
> and it rotates around them before going down to the next priority).
>
>>
>> To allocate a page of memroy in swap, the kernel will call
>> get_swap_page to find the first device with available swap slots and
>> then pass that device to scan_swap_map to allocate a page.
>>
>> I see a "problem" with this: The kernel does not take advantage of
>> available bandwidth. For example: my system has 2 swap
>> devices...DiskDevice2 and DiskDevice3, they are both identical 20 GB
>> 7200rpm drives. If we need 4 GB worth of swap pages, only DiskDevice2
>> will be filled up. We have available free bandwidth on DiskDevice3
>> that is never used. If we were to split the swap pages into the two
>> drives, 2 GB of swap on each drive - we can potentially double our
>> bandwidth (latency is another issue).
>
> True.  But wouldn't you use MD/DM for that, say, RAID 0 swap?
> The priority scheme in swap is rather ancient, but is there any
> point in fiddling with that, when there's already a logical
> volume management layer which could do it better for you?
>
> Though googling for "RAID 0 swap" doesn't inspire confidence.
>
>>
>> Another problem that I am working on is what if one device is Flash
>> and the second device is Rotational. Does the kernel mm employ a
>> scheme to evict LRU pages in Priority1 swap to Priority2 swap?
>
> No, it has no such scheme.
>
> I'm accustomed to answering that you should be adding RAM rather
> than worrying about the speed of swap.  But it could well be that
> SSDs will change the game, and deserve more attention to tiered swap.
>
> However, I don't get what you're proposing.  You write of evicting
> LRU pages in priority 1 swap to priority 2 swap.  But if those pages
> are still on an LRU in memory, doesn't that imply that they're useful
> pages, which we're more likely to want to delete from swap, than copy
> to slower storage?
>
> I can imagine wanting to move long-forgotten pages from fast swap to
> slower swap; but the overhead of such housekeeping rather puts me off.
> It sounds like swap prefetch, but for those pages which we least want
> to have in memory rather than those which we're likely to want.
>
> Hugh
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
