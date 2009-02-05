Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 837526B003D
	for <linux-mm@kvack.org>; Thu,  5 Feb 2009 13:33:42 -0500 (EST)
Received: from [172.20.20.9]([172.20.20.9]) (3205 bytes) by megami.veritas.com
	via sendmail with P:esmtp/R:smart_host/T:smtp
	(sender: <hugh@veritas.com>)
	id <m1LV92d-0000GqC@megami.veritas.com>
	for <linux-mm@kvack.org>; Thu, 5 Feb 2009 10:33:35 -0800 (PST)
	(Smail-3.2.0.101 1997-Dec-17 #15 built 2001-Aug-30)
Date: Thu, 5 Feb 2009 18:33:12 +0000 (GMT)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: Swap Memory
In-Reply-To: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0902051802480.1445@blonde.anvils>
References: <77e5ae570902031238q5fc9231bpb65ecd511da5a9c7@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: William Chan <williamchan@google.com>
Cc: linux-mm@kvack.org, wchan212@gmail.com
List-ID: <linux-mm.kvack.org>

On Tue, 3 Feb 2009, William Chan wrote:
> 
> According to my understanding of the kernel mm, swap pages are
> allocated in order of priority.
> 
> For example, I have the follow swap devices: FlashDevice1 with
> priority 1 and DiskDevice2 with priority 2 and DiskDevice3 with
> priority3. FlashDevice1 will get filled up, then DsikDevice2 and
> DiskDevice3.

Correct (or you can have several at the same priority,
and it rotates around them before going down to the next priority).

> 
> To allocate a page of memroy in swap, the kernel will call
> get_swap_page to find the first device with available swap slots and
> then pass that device to scan_swap_map to allocate a page.
> 
> I see a "problem" with this: The kernel does not take advantage of
> available bandwidth. For example: my system has 2 swap
> devices...DiskDevice2 and DiskDevice3, they are both identical 20 GB
> 7200rpm drives. If we need 4 GB worth of swap pages, only DiskDevice2
> will be filled up. We have available free bandwidth on DiskDevice3
> that is never used. If we were to split the swap pages into the two
> drives, 2 GB of swap on each drive - we can potentially double our
> bandwidth (latency is another issue).

True.  But wouldn't you use MD/DM for that, say, RAID 0 swap?
The priority scheme in swap is rather ancient, but is there any
point in fiddling with that, when there's already a logical
volume management layer which could do it better for you?

Though googling for "RAID 0 swap" doesn't inspire confidence.

> 
> Another problem that I am working on is what if one device is Flash
> and the second device is Rotational. Does the kernel mm employ a
> scheme to evict LRU pages in Priority1 swap to Priority2 swap?

No, it has no such scheme.

I'm accustomed to answering that you should be adding RAM rather
than worrying about the speed of swap.  But it could well be that
SSDs will change the game, and deserve more attention to tiered swap.

However, I don't get what you're proposing.  You write of evicting
LRU pages in priority 1 swap to priority 2 swap.  But if those pages
are still on an LRU in memory, doesn't that imply that they're useful
pages, which we're more likely to want to delete from swap, than copy
to slower storage?

I can imagine wanting to move long-forgotten pages from fast swap to
slower swap; but the overhead of such housekeeping rather puts me off.
It sounds like swap prefetch, but for those pages which we least want
to have in memory rather than those which we're likely to want.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
