Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A28876B004D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 16:00:30 -0400 (EDT)
Date: Tue, 17 Mar 2009 12:55:05 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090317193538.GD28447@random.random>
Message-ID: <alpine.LFD.2.00.0903171242080.3082@localhost.localdomain>
References: <alpine.LFD.2.00.0903161739310.3082@localhost.localdomain> <20090317121900.GD20555@random.random> <alpine.LFD.2.00.0903170929180.3082@localhost.localdomain> <alpine.LFD.2.00.0903170950410.3082@localhost.localdomain> <20090317171049.GA28447@random.random>
 <alpine.LFD.2.00.0903171023390.3082@localhost.localdomain> <alpine.LFD.2.00.0903171048100.3082@localhost.localdomain> <alpine.LFD.2.00.0903171112470.3082@localhost.localdomain> <20090317184647.GC28447@random.random> <alpine.LFD.2.00.0903171155090.3082@localhost.localdomain>
 <20090317193538.GD28447@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



On Tue, 17 Mar 2009, Andrea Arcangeli wrote:

> On Tue, Mar 17, 2009 at 12:03:55PM -0700, Linus Torvalds wrote:
> > If it's in the swap cache, it should be mapped read-only, and gup(write=1) 
> > will do the COW break and un-swapcache it.
> 
> It may turn it read-write instead of COW break and un-swapcache.
> 
>    if (write_access && reuse_swap_page(page)) {
>       pte = maybe_mkwrite(pte_mkdirty(pte), vma);
> 
> This is done to avoid fragmenting the swap device.

Right, but reuse_swap_page() will have removed it from the swapcache if it 
returns success.

So if the page is writable in the page tables, it should not be in the 
swap cache.

Oh, except that we do it in shrink_page_list(), and while we're going to 
do that whole "try_to_unmap()", I guess it can fail to unmap there? In 
that case, you could actually have it in the page tables while in the swap 
cache.

And besides, we do remove it from the page tables in the wrong order (ie 
we add it to the swap cache first, _then_ remove it), so I guess that also 
ends up being a race with another CPU doing fast-gup. And we _have_ to do 
it in that order at least for the map_count > 1 case, since a read-only 
swap page may be shared by multiple mm's, and the swap-cache is how we 
make sure that they all end up joining together.

Of course, the only case we really care about is the map_count=1 case, 
since that's the only one that is possible after GUP has succeeded 
(assuming, as always, that fork() is locked out of making copies). So we 
really only care about the simpler case.

> I agree in principle, if the VM stays away from pages under GUP
> theoretically the dirty bit shouldn't be transferred to the PG_dirty
> of the page until after the I/O is complete, so the dirty bit set by
> gup in the pte may be enough. Not sure if there are other places that
> could transfer the dirty bit of the pte before the gup user releases
> the page-pin.

I do suspect there are subtle issues like the above. 

> > I don't think you can use just mapcount on its own - you have to compare 
> > it to page_count(). Otherwise perfectly normal (non-gup) pages will 
> > trigger, since that page count is the only thing that differs between the 
> > two cases.
> 
> Yes, page_count shall be compared with page_mapcount. My worry is only
> that both can change from under us if mapcount > 1 (not enough to hold
> PT lock to be sure mapcount/count is stable if mapcount > 1).

Now, that's not a big worry, because we only care about mapcount=1 for the 
anonymous page case at least. So we can stabilize that one with the pt 
lock.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
