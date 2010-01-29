Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5A54F6B008A
	for <linux-mm@kvack.org>; Fri, 29 Jan 2010 12:46:36 -0500 (EST)
Date: Fri, 29 Jan 2010 17:46:34 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH] mm: fix migratetype bug which slowed swapping
In-Reply-To: <20100129173430.GK7139@csn.ul.ie>
Message-ID: <alpine.LSU.2.00.1001291742150.12906@sister.anvils>
References: <4B5FA147.5040802@teksavvy.com> <4B610FDA.50104@teksavvy.com> <4B6113C7.201@teksavvy.com> <201001281152.20352.rjw@sisk.pl> <4B61964F.6060307@teksavvy.com> <4B619C6D.9030205@teksavvy.com> <20100128142437.GA7139@csn.ul.ie> <4B62E904.9020401@teksavvy.com>
 <20100129154653.GJ7139@csn.ul.ie> <alpine.LSU.2.00.1001291716520.10968@sister.anvils> <20100129173430.GK7139@csn.ul.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Mark Lord <kernel@teksavvy.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

After memory pressure has forced it to dip into the reserves, 2.6.32's
5f8dcc21211a3d4e3a7a5ca366b469fb88117f61 "page-allocator: split per-cpu
list into one-list-per-migrate-type" has been returning MIGRATE_RESERVE
pages to the MIGRATE_MOVABLE free_list: in some sense depleting reserves.

Fix that in the most straightforward way (which, considering the overheads
of alternative approaches, is Mel's preference): the right migratetype is
already in page_private(page), but free_pcppages_bulk() wasn't using it.

How did this bug show up?  As a 20% slowdown in my tmpfs loop kbuild
swapping tests, on PowerMac G5 with SLUB allocator.  Bisecting to that
commit was easy, but explaining the magnitude of the slowdown not easy.

The same effect appears, but much less markedly, with SLAB, and even
less markedly on other machines (the PowerMac divides into fewer zones
than x86, I think that may be a factor).  We guess that lumpy reclaim
of short-lived high-order pages is implicated in some way, and probably
this bug has been tickling a poor decision somewhere in page reclaim.

But instrumentation hasn't told me much, I've run out of time and
imagination to determine exactly what's going on, and shouldn't hold up
the fix any longer: it's valid, and might even fix other misbehaviours.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Acked-by: Mel Gorman <mel@csn.ul.ie>
Cc: stable@kernel.org
---

 mm/page_alloc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- 2.6.33-rc5/mm/page_alloc.c	2010-01-22 12:36:18.000000000 +0000
+++ linux/mm/page_alloc.c	2010-01-22 12:53:38.000000000 +0000
@@ -556,8 +556,9 @@ static void free_pcppages_bulk(struct zo
 			page = list_entry(list->prev, struct page, lru);
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
-			__free_one_page(page, zone, 0, migratetype);
-			trace_mm_page_pcpu_drain(page, 0, migratetype);
+			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
+			__free_one_page(page, zone, 0, page_private(page));
+			trace_mm_page_pcpu_drain(page, 0, page_private(page));
 		} while (--count && --batch_free && !list_empty(list));
 	}
 	spin_unlock(&zone->lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
