Received: from programming.kicks-ass.net ([62.194.129.232])
          by amsfep15-int.chello.nl
          (InterMail vM.6.01.04.04 201-2131-118-104-20050224) with SMTP
          id <20050827220249.QWRH10024.amsfep15-int.chello.nl@programming.kicks-ass.net>
          for <linux-mm@kvack.org>; Sun, 28 Aug 2005 00:02:49 +0200
Message-Id: <20050827215756.726585000@twins>
Date: Sat, 27 Aug 2005 23:57:56 +0200
From: a.p.zijlstra@chello.nl
Subject: [RFC][PATCH 0/6] CART Implementation
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi All,

(now split as per request)

After another day of hard work I feel I have this CART implementation
complete.

It survives a pounding and the stats seem pretty stable.

The things that need more work:
 1) the hash function seems pretty lousy
 2) __cart_remember() called from shrink_list() needs zone->lru_lock

The whole non-resident code is based on the idea that the hash function
gives an even spread so that:

 B1_j     B1
------ ~ ---- 
 B2_j     B2

However after a pounding the variance in (B1_j - B2_j) as given by the
std. deviation: sqrt(<x^2> - <x>^2) is around 10. And this for a bucket
with 57 slots.

The other issue is that __cart_remember() needs the zone->lru_lock. This
function is called from shrink_list() where the lock is explicitly
avoided, so this seems like an issue. Alternatives would be atomic_t for
zone->nr_q or a per cpu counter delta. Suggestions?

Also I made quite some changes in swap.c and vmscan.c without being an
expert on the code. Did I foul up too bad?

Then ofcourse I need to benchmark, suggestions?

Some of this code is shamelessly copied from Rik van Riel, other parts 
are inspired by code from Rahul Iyer. 

Any comments appreciated.

Kind regards,

Peter Zijlstra
--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
