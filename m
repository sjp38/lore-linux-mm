Received: from neon.transmeta.com (neon-best.transmeta.com [206.184.214.10])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA27572
	for <linux-mm@kvack.org>; Wed, 16 Dec 1998 20:24:56 -0500
Date: Wed, 16 Dec 1998 17:24:05 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] swapin readahead v3 + kswapd fixes
In-Reply-To: <Pine.LNX.3.96.981201075322.509A-100000@mirkwood.dummy.home>
Message-ID: <Pine.LNX.3.95.981216171905.2111A-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Linux MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Tue, 1 Dec 1998, Rik van Riel wrote:
> 
> --- ./mm/vmscan.c.orig	Thu Nov 26 11:26:50 1998
> +++ ./mm/vmscan.c	Tue Dec  1 07:12:28 1998
> @@ -431,6 +431,8 @@
>  	kmem_cache_reap(gfp_mask);
>  
>  	if (buffer_over_borrow() || pgcache_over_borrow())
> +		state = 0;		
> +	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
>  		shrink_mmap(i, gfp_mask);
>  
>  	switch (state) {

I really hate the above tests that make no sense at all from a conceptual
view, and are fairly obviously just something to correct for a more basic
problem. 

So I've removed them, and re-written the logic for the "state" in the VM
scanning. I made "state" be private to the invocation, and always start at
zero - and could thus remove it altogether. 

That means that the first thing freeing memory always tries to do is the
shrink_mmap() thing, and thus the problem becomes one of just making sure
that shrink_mmap() doesn't try _too_ aggressively to throw out stuff that
is still needed. So I changed shrink_mmap() too a bit, and simplified that
too (so that it looks at at most 1/32th of all memory on the first try,
and if it can't find anything to free there it lets the other memory
de-allocators have a go at it). 

It's a lot simpler, has no arbitrary heuristics like the above two tests,
and worked for me both with a small memory setup and my normal half gig
setup. Would you guys please test and comment? It's in the pre-2.1.132-1
patch. 

		Linus "arbitrary rules are bad rules" Torvalds

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
