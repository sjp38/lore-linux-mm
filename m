Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id SAA00597
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 18:01:37 -0500
Date: Mon, 7 Dec 1998 23:51:20 +0100 (CET)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <199812072204.WAA01733@dax.scot.redhat.com>
Message-ID: <Pine.LNX.3.96.981207233805.3961A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

On Mon, 7 Dec 1998, Stephen C. Tweedie wrote:

> Right: 2.1.131 + Rik's fixes + my fix to Rik's fixes (see below) has
> set a new record for my 8MB benchmarks.  In 64MB, it is behaving
> much more rationally than older kernels: still very very very fast,
> especially interactively, but with no massive cache growth and swap
> storms when doing filesystem intensive operations, and swap
> throughput when we _do_ swap is great. 
> 
> I've changed your readahead stuff to look like:
> 
> 	struct page *page_map = lookup_swap_cache(entry);
> 
> 	if (!page_map) {
>                 swapin_readahead(entry);
> 		page_map = read_swap_cache(entry);
> 	}
> 
> which is the right way to do it: we don't want to start a readahead
> on a swap hit, because that will try to extend the readahead "zone"
> one page at a time as we hit existing pages in the cache.  That ends
> up with one-page writes,

And one-page reads too. We should probably only start reading
when there are more than swap_readahead/2 pages to read. This
will give us enough time to keep up with 'streaming' applications
while at the same time avoiding single-page I/O.

Kswapd should also avoid calling run_task_queue(&tq_disk)
when (on exit) the number of async pages is less than one
quarter of pager_daemon.swap_cluster. We can always sync
those pages later...

Besides, moving the disk head from where it's now just is
more expensive than the temporary loss of the few kilobytes
we don't free by keeping the pages on the queue :)

> I also fixed the readahead logic itself to start with the correct
> initial page (previously you were doing a "++i" in the for ()
> condition, which means we were skipping the first page in the
> readahead).

Oops, I will fix that too in my tree...

> Finally, I'll experiment with making the readahead a
> granularity-based thing, so that we read an aligned block of (say)
> 64k from swap at a time.

This would be nice, yes. Currently we page in the most
useless rubbish because we simply don't know any better...

> For now, this is looking very good indeed.

Thanks... Always good to hear something like this :)

cheers,

Rik -- the flu hits, the flu hits, the flu hits -- MORE
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
