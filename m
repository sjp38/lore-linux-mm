Message-ID: <4011392D.1090600@cyberone.com.au>
Date: Sat, 24 Jan 2004 02:09:33 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au>	<20040121223608.1ea30097.akpm@osdl.org>	<16399.42863.159456.646624@laputa.namesys.com>	<40105633.4000800@cyberone.com.au> <16400.63379.453282.283117@laputa.namesys.com>
In-Reply-To: <16400.63379.453282.283117@laputa.namesys.com>
Content-Type: multipart/mixed;
 boundary="------------010606030200090103000600"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <Nikita@Namesys.COM>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------010606030200090103000600
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Nikita Danilov wrote:

>Nick Piggin writes:
> > 
>
>[...]
>
> > 
> > But those cold mapped pages are basically ignored until the
> > reclaim_mapped threshold, however they do continue to have their
> > referenced bits cleared - hence page_referenced check should
> > become a better estimation when reclaim_mapped is reached, right?
>
>Right.
>


I still am a bit skeptical that the LRU lists are actually LRU,
however I'm running out of other explainations for your patch's
improvements :)

One ideas I had turns out to have little effect for kbuild, but
it might still be worth including?

When reclaim_mapped == 0 mapped referenced pages are treated
the same way as mapped unreferenced pages, and the referenced
info is thrown out. Fixed by not clearing referenced bits.


--------------010606030200090103000600
Content-Type: text/plain;
 name="vm-info.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-info.patch"

 linux-2.6-npiggin/mm/vmscan.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff -puN mm/vmscan.c~vm-info mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-info	2004-01-24 00:50:15.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-01-24 01:58:56.000000000 +1100
@@ -656,6 +656,12 @@ refill_inactive_zone(struct zone *zone, 
 		page = list_entry(l_hold.prev, struct page, lru);
 		list_del(&page->lru);
 		if (page_mapped(page)) {
+
+			if (!reclaim_mapped) {
+				list_add(&page->lru, &l_active);
+				continue;
+			}
+
 			pte_chain_lock(page);
 			if (page_mapped(page) && page_referenced(page)) {
 				pte_chain_unlock(page);
@@ -663,10 +669,6 @@ refill_inactive_zone(struct zone *zone, 
 				continue;
 			}
 			pte_chain_unlock(page);
-			if (!reclaim_mapped) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
 		}
 		/*
 		 * FIXME: need to consider page_count(page) here if/when we

_

--------------010606030200090103000600--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
