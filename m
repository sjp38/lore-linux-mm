Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep13-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050829044010.GVRX1950.amsfep13-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Mon, 29 Aug 2005 06:40:10 +0200
Message-Id: <20050829043132.908007000@twins>
Date: Mon, 29 Aug 2005 06:31:33 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][patch 0/6] CART Implementation ver 2
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

Marcelo was ofcourse right, and I needed to do scary stuff to 
avoid calling page_referenced() while holding zone->lru_lock.
Thanks Rik for making my thik head see that :-)

So here is an update of my code.

Changes:
 - Changed the hash algo. for the nonresident buckets
   It is worse now, so it has to change again :-(
 - Made the nonresident code blank out a paged in cookie.
 - Rewrote the cart code (yet again) to work on temp lists
   much like refill_inactive and co.

I put all that code in cart.c instead of swap.c to get a clearer 
distinction on what was general page reclaim logic and what was
part of the page cache.

Just before mailing (and ofcourse untested) I changed the calls to 
cart_rebalance_*() to take nr_dst/2 + 1 as target because I got
too much OOMs, no idea if this solved it. When i put nr_scan = 
sc->swap_cluster_max (in shrink_cache) I go no OOMs, work left there.


Kind regards,

Peter Zijlstra

--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
