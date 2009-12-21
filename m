Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2439F620001
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 17:23:51 -0500 (EST)
Date: Mon, 21 Dec 2009 22:23:47 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: fix 2.6.32 slowdown in heavy swapping
Message-ID: <Pine.LNX.4.64.0912212214420.10033@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Jiri Kosina <jkosina@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Mel,

Sorry to spring this upon you, when you've already mentioned that
you'll be offline shortly - maybe I'm too late, please don't let it
spoil your break, feel free not to respond for a couple of weeks.

I've sat quite a while on this, bisecting and trying to narrow
it down and experimenting with different fixes; but I've failed
to reproduce it with anything simpler than my kernel builds on
tmpfs loop swapping tests, and it's only obvious on the PowerPC G5.

The problem is that those swapping builds run about 20% slower in
2.6.32 than 2.6.31 (and look as if they run increasingly slowly,
though I'm not certain of that); and surprisingly it bisected
down to your commit 5f8dcc21211a3d4e3a7a5ca366b469fb88117f61
page-allocator: split per-cpu list into one-list-per-migrate-type

It then took me a long while to insert the vital printk which
revealed the now obvious problem: MIGRATE_RESERVE pages are being
put on the MIGRATE_MOVABLE list, then freed as MIGRATE_MOVABLE.
Which I assume gradually depletes the intended reserve?

The simplest, straight bugfix, patch is the one below: rely on
page_private instead of migratetype when freeing.  But three plausible
alternatives have occurred to me, and each has its own advantages.
All four bring the timing back to around what it used to be.

Whereas this patch below uses the migratetype in page_private(page),
the other three remove that as now redundant.  In the second version
free_hot_cold_page() does immediate free_one_page() of MIGRATE_RESERVEs
just like MIGRATE_ISOLATEs, so they never get on the MIGRATE_MOVABLE list.

In the third and fourth versions I've raised MIGRATE_PCPTYPES to 4,
so there's a list of MIGRATE_RESERVEs: in the third, buffered_rmqueue()
supplies pages from there if rmqueue_bulk() left list empty (that seems
closest to 2.6.31 behaviour); the same in the fourth, except only when
trying for MIGRATE_MOVABLE pages (that seems closer to your intention).

In my peculiar testing (on two machines: though the slowdown was much
less noticeable on Dell P4 x86_64, these fixes do show improvements),
fix 2 appears slightly the fastest, and fix 3 the one with least
variance.  But take that with a handful of salt, the likelihood
is that further tests on other machines would show differently.

Mel, do you have a feeling for which fix is the _right_ fix?

I don't, and I'd rather hold back from signing off a patch, until
we have your judgement.  But here is the first version of the fix,
in case anyone else has noticed a slowdown in heavy swapping and
wants to try it.

Thanks,
Hugh

---

 mm/page_alloc.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- 2.6.33-rc1/mm/page_alloc.c	2009-12-18 11:42:54.000000000 +0000
+++ linux/mm/page_alloc.c	2009-12-20 19:10:50.000000000 +0000
@@ -555,8 +555,9 @@ static void free_pcppages_bulk(struct zo
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
