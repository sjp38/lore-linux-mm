Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 22CC16B0005
	for <linux-mm@kvack.org>; Wed, 23 Jan 2013 21:03:03 -0500 (EST)
Received: by mail-da0-f53.google.com with SMTP id x6so3976615dac.26
        for <linux-mm@kvack.org>; Wed, 23 Jan 2013 18:03:02 -0800 (PST)
Date: Thu, 24 Jan 2013 10:02:50 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
Message-ID: <20130124020250.GA32496@kernel.org>
References: <20130122065341.GA1850@kernel.org>
 <20130123075808.GH2723@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130123075808.GH2723@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Wed, Jan 23, 2013 at 04:58:08PM +0900, Minchan Kim wrote:
> On Tue, Jan 22, 2013 at 02:53:41PM +0800, Shaohua Li wrote:
> > Hi,
> > 
> > Because of high density, low power and low price, flash storage (SSD) is a good
> > candidate to partially replace DRAM. A quick answer for this is using SSD as
> > swap. But Linux swap is designed for slow hard disk storage. There are a lot of
> > challenges to efficiently use SSD for swap:
> 
> Many of below item could be applied in in-memory swap like zram, zcache.
> 
> > 
> > 1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> > 2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This
> > overhead is very high even in a normal 2-socket machine.
> > 3. Better swap IO pattern. Both direct and kswapd page reclaim can do swap,
> > which makes swap IO pattern is interleave. Block layer isn't always efficient
> > to do request merge. Such IO pattern also makes swap prefetch hard.
> 
> Agreed.
> 
> > 4. Swap map scan overhead. Swap in-memory map scan scans an array, which is
> > very inefficient, especially if swap storage is fast.
> 
> Agreed.
> 
> > 5. SSD related optimization, mainly discard support
> > 6. Better swap prefetch algorithm. Besides item 3, sequentially accessed pages
> > aren't always in LRU list adjacently, so page reclaim will not swap such pages
> > in adjacent storage sectors. This makes swap prefetch hard.
> 
> One of problem is LRU churning and I wanted to try to fix it.
> http://marc.info/?l=linux-mm&m=130978831028952&w=4

Yes, LRU churning is a problem. Another problem is we didn't add sequentially
accessed pages to LRU list adjacently if there are multiple tasks running and
consuming memory in the meantime. The percpu pagevec helps a little, but its
size isn't large.
 
> > 7. Alternative page reclaim policy to bias reclaiming anonymous page.
> > Currently reclaim anonymous page is considering harder than reclaim file pages,
> > so we bias reclaiming file pages. If there are high speed swap storage, we are
> > considering doing swap more aggressively.
> 
> Yeb. We need it. I tried it with extending vm_swappiness to 200.
> 
> From: Minchan Kim <minchan@kernel.org>
> Date: Mon, 3 Dec 2012 16:21:00 +0900
> Subject: [PATCH] mm: increase swappiness to 200

I had exactly the same code in my tree. And actually I found if swappiness is
set to 200, zone reclaim has problem. I has a patch for it. But haven't post it
out yet.

swappiness doesn't solve all the problem here. anonymous pages are in active
list first. And the rotation logic bias to anonymous pages too. So even you set
a high swappiness, file pages can still be easily reclaimed.

> > 8. Huge page swap. Huge page swap can solve a lot of problems above, but both
> > THP and hugetlbfs don't support swap.
> 
> Another items are indirection layers. Please read Rik's mail below.
> Indirection layers could give many flexibility to backends and helpful
> for defragmentation.
> 
> One of idea I am considering is that makes hierarchy swap devides,
> NOT priority-based. I mean currently swap devices are used up by prioirty order.
> It's not good fit if we use fast swap and slow swap at the same time.
> I'd like to consume fast swap device (ex, in-memory swap) firstly, then
> I want to migrate some of swap pages from fast swap to slow swap to
> make room for fast swap. It could solve below concern.
> In addition, buffering via in-memory swap could make big chunk which is aligned
> to slow device's block size so migration speed from fast swap to slow swap
> could be enhanced so wear out problem would go away, too.

This looks interesting.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
