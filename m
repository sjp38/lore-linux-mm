Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA30290
	for <linux-mm@kvack.org>; Sat, 12 Dec 1998 10:17:43 -0500
Date: Sat, 12 Dec 1998 16:14:38 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Subject: Re: 2.1.130 mem usage.
In-Reply-To: <Pine.LNX.3.96.981211181928.765F-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.981212161010.704B-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Rik van Riel <H.H.vanRiel@phys.uu.nl>, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Fri, 11 Dec 1998, Andrea Arcangeli wrote:

>>> It would also be nice to not have two separate mm cycles (one that
>>> grow the cache until borrow percentage and the other one that shrink
>>> and that reach very near the limit of the working set). We should
>>> have always the same level of cache in the system if the mm stress
>>> is constant. This could be easily done by a state++ inside
>>> do_try_to_free_pages() after some (how many??) susccesfully returns.
>>
>>I'm seeing a pretty stable cache behaviour here, on everything from
>>4MB to 64MB systems.
>
>It works fine but it' s not stable at all. The cache here goes from

This patch should rebalance the swapping/mmap-shrinking (and seems to
works here, even if really my kswapd start when the buf/cache are over max
and stop when they are under borrow, I don' t remeber without look at the
code what the stock kswapd is doing):

Index: vmscan.c
===================================================================
RCS file: /var/cvs/linux/mm/vmscan.c,v
retrieving revision 1.1.1.1.2.16
diff -u -r1.1.1.1.2.16 vmscan.c
--- vmscan.c	1998/12/12 12:31:57	1.1.1.1.2.16
+++ linux/mm/vmscan.c	1998/12/12 14:27:55
@@ -439,7 +439,8 @@
 	kmem_cache_reap(gfp_mask);
 
 	if (buffer_over_borrow() || pgcache_over_borrow())
-		state = 0;
+		if (shrink_mmap(i, gfp_mask))
+			return 1;
 	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
 		shrink_mmap(i, gfp_mask);
 

The patch basically avoids the clobbering of state so the mm remains
always in state = `swapout' but the cache remains close to the borrow
percentage. I should have do that from time 0 instead of using state =
0...

Andrea Arcangeli

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
