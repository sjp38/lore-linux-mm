Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id QAA12888
	for <linux-mm@kvack.org>; Wed, 9 Dec 1998 16:38:37 -0500
Date: Wed, 9 Dec 1998 22:05:56 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <Pine.LNX.3.96.981209183310.3727A-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981209220124.25588B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <andrea@e-mind.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Wed, 9 Dec 1998, Andrea Arcangeli wrote:
> On Mon, 7 Dec 1998, Stephen C. Tweedie wrote:
> 
> >Right: 2.1.131 + Rik's fixes + my fix to Rik's fixes (see below) has set
> >a new record for my 8MB benchmarks.  In 64MB, it is behaving much more
> 
> I think that my state = 0 in do_try_to_free_page() helped a lot to handle
> the better kernel performance.

It does. I wonder who the culprit was that removed the state = 0
from 2.1.129 -> 2.1.130?  We've had the state = 0 since 2.1.90
when we put it in...

> >--- mm/vmscan.c.~1~	Mon Dec  7 12:05:54 1998
> >+++ mm/vmscan.c	Mon Dec  7 18:55:55 1998
> >@@ -432,6 +432,8 @@
> > 
> > 	if (buffer_over_borrow() || pgcache_over_borrow())
> > 		state = 0;
> >+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
> >+		shrink_mmap(i, gfp_mask);
> > 
> 
> Doing that we risk to shrink too much cache even if not necessary
> but this part of the patch improve a _lot_ swapping performance even
> if I don' t know why ;) 

This is because 'swapped' data is added to the cache. It also
is because without it kswapd would not free memory in swap_out().
Then, because it didn't free memory, it would continue to swap
out more and more and still more with no effect (remember the
removal of page aging?).

All this is fixed by the two little lines above :)

> And why not to use GFP_USER in the userspace swaping code?

>  	if (found_page)
>  		goto out;
>  
> -	new_page_addr = __get_free_page(GFP_KERNEL);
> +	new_page_addr = __get_free_page(GFP_USER);
>  	if (!new_page_addr)
>  		goto out;	/* Out of memory */
>  	new_page = mem_map + MAP_NR(new_page_addr);

Seems like a great idea... Stephen?

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
