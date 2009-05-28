Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 8363F6B0055
	for <linux-mm@kvack.org>; Wed, 27 May 2009 20:35:23 -0400 (EDT)
Date: Thu, 28 May 2009 02:34:45 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch] mm: release swap slots for actively used pages
Message-ID: <20090528003445.GA7263@cmpxchg.org>
References: <1243388859-9760-1-git-send-email-hannes@cmpxchg.org> <20090527161535.ac2dd1ba.akpm@linux-foundation.org> <20090528092345.58f31056.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090528092345.58f31056.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com, hugh.dickins@tiscali.co.uk
List-ID: <linux-mm.kvack.org>

On Thu, May 28, 2009 at 09:23:45AM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 27 May 2009 16:15:35 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 27 May 2009 03:47:39 +0200
> > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > For anonymous pages activated by the reclaim scan or faulted from an
> > > evicted page table entry we should always try to free up swap space.
> > > 
> > > Both events indicate that the page is in active use and a possible
> > > change in the working set.  Thus removing the slot association from
> > > the page increases the chance of the page being placed near its new
> > > LRU buddies on the next eviction and helps keeping the amount of stale
> > > swap cache entries low.
> > > 
> > > try_to_free_swap() inherently only succeeds when the last user of the
> > > swap slot vanishes so it is safe to use from places where that single
> > > mapping just brought the page back to life.
> > > 
> > 
> > Seems that this has a risk of worsening swap fragmentation for some
> > situations.  Or not, I have no way of knowing, really.
> > 
> I'm afraid, too.
> 
> > > diff --git a/mm/memory.c b/mm/memory.c
> > > index 8b4e40e..407ebf7 100644
> > > --- a/mm/memory.c
> > > +++ b/mm/memory.c
> > > @@ -2671,8 +2671,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
> > >  	mem_cgroup_commit_charge_swapin(page, ptr);
> > >  
> > >  	swap_free(entry);
> > > -	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> > > -		try_to_free_swap(page);
> > > +	try_to_free_swap(page);
> > >  	unlock_page(page);
> > >  
> > >  	if (write_access) {
> > > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > > index 621708f..2f0549d 100644
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -788,7 +788,7 @@ cull_mlocked:
> > >  
> > >  activate_locked:
> > >  		/* Not a candidate for swapping, so reclaim swap space. */
> > > -		if (PageSwapCache(page) && vm_swap_full())
> > > +		if (PageSwapCache(page))
> > >  			try_to_free_swap(page);
> > >  		VM_BUG_ON(PageActive(page));
> > >  		SetPageActive(page);
> > 
> > How are we to know that this is a desirable patch for Linux??
> 
> I'm not sure what is the "purpose/benefit" of this patch...
> In patch description,
> "we should always try to free up swap space" ...then, why "should" ?

I wrote the reason in the next paragraph:

	Both events indicate that the page is in active use and a
	possible change in the working set.  Thus removing the slot
	association from the page increases the chance of the page
	being placed near its new LRU buddies on the next eviction and
	helps keeping the amount of stale swap cache entries low.

I did some investigation on the average swap distance of slots used by
one reclaimer and noticed that the highest distances occurred when
most of the pages where already in swap cache.

The conclusion for me was that the pages had been rotated on the lists
but still clung to their old swap cache entries, which led to LRU
buddies being scattered all over the swap device.

Sorry that I didn't mention that beforehand.  And I will try and see
if I can get some hard numbers on this.

Thanks,

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
