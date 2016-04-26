Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A3F56B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 17:46:06 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id e190so53881733pfe.3
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 14:46:06 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id ts10si1015645pac.50.2016.04.26.14.46.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Apr 2016 14:46:04 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id r5so11481656pag.1
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 14:46:04 -0700 (PDT)
Date: Tue, 26 Apr 2016 14:45:35 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [BUG linux-next] kernel NULL pointer dereference on
 linux-next-20160420
In-Reply-To: <571FC5C0.1080208@linaro.org>
Message-ID: <alpine.LSU.2.11.1604261354100.3217@eggly.anvils>
References: <5719729E.7000101@linaro.org> <571FC5C0.1080208@linaro.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Shi, Yang" <yang.shi@linaro.org>
Cc: akpm@linux-foundation.org, sfr@canb.auug.org.au, hughd@google.com, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 26 Apr 2016, Shi, Yang wrote:
> On 4/21/2016 5:38 PM, Shi, Yang wrote:
> > Hi folks,
> > 
> > I did the below test with huge tmpfs on linux-next-20160420:
> > 
> > # mount -t tmpfs huge=1 tmpfs /mnt
> > # cd /mnt
> > Then clone linux kernel
> > 
> > Then I got the below bug, such test works well on non-huge tmpfs.
> > 
> > BUG: unable to handle kernel NULL pointer dereference at           (null)
> > IP: [<ffffffff8119d2f8>] release_freepages+0x18/0xa0
> > PGD 0
> > Oops: 0000 [#1] PREEMPT SMP
> > Modules linked in:
> > CPU: 6 PID: 110 Comm: kcompactd0 Not tainted
> > 4.6.0-rc4-next-20160420-WR7.0.0.0_standard #4
> > Hardware name: Intel Corporation S5520HC/S5520HC, BIOS
> > S5500.86B.01.10.0025.030220091519 03/02/2009
> > task: ffff880361708040 ti: ffff880361704000 task.ti: ffff880361704000
> > RIP: 0010:[<ffffffff8119d2f8>]  [<ffffffff8119d2f8>]
> > release_freepages+0x18/0xa0
> > RSP: 0018:ffff880361707cf8  EFLAGS: 00010282
> > RAX: 0000000000000000 RBX: ffff88036ffde7c0 RCX: 0000000000000009
> > RDX: 0000000000001bf1 RSI: 000000000000000f RDI: ffff880361707dd0
> > RBP: ffff880361707d20 R08: 0000000000000007 R09: 0000160000000000
> > R10: ffff88036ffde7c0 R11: 0000000000000000 R12: 0000000000000000
> > R13: ffff880361707dd0 R14: ffff880361707dc0 R15: ffff880361707db0
> > FS:  0000000000000000(0000) GS:ffff880363cc0000(0000)
> > knlGS:0000000000000000
> > CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> > CR2: 0000000000000000 CR3: 0000000002206000 CR4: 00000000000006e0
> > Stack:
> >   ffff88036ffde7c0 0000000000000000 0000000000001a00 ffff880361707dc0
> >   ffff880361707db0 ffff880361707da0 ffffffff8119f13d ffffffff81196239
> >   0000000000000000 ffff880361708040 0000000000000001 0000000000100000
> > Call Trace:
> >   [<ffffffff8119f13d>] compact_zone+0x55d/0x9f0
> >   [<ffffffff81196239>] ? fragmentation_index+0x19/0x70
> >   [<ffffffff8119f92f>] kcompactd_do_work+0x10f/0x230
> >   [<ffffffff8119fae0>] kcompactd+0x90/0x1e0
> >   [<ffffffff810a3a40>] ? wait_woken+0xa0/0xa0
> >   [<ffffffff8119fa50>] ? kcompactd_do_work+0x230/0x230
> >   [<ffffffff810801ed>] kthread+0xdd/0x100
> >   [<ffffffff81be5ee2>] ret_from_fork+0x22/0x40
> >   [<ffffffff81080110>] ? kthread_create_on_node+0x180/0x180
> > Code: c1 fa 06 31 f6 e8 a9 9b fd ff eb 98 0f 1f 80 00 00 00 00 66 66 66
> > 66 90 55 48 89 e5 41 57 41 56 41 55 49 89 fd 41 54 53 48 8b 07 <48> 8b
> > 10 48 8d 78 e0 49 39 c5 4c 8d 62 e0 74 70 49 be 00 00 00
> > RIP  [<ffffffff8119d2f8>] release_freepages+0x18/0xa0
> >   RSP <ffff880361707cf8>
> > CR2: 0000000000000000
> > ---[ end trace 855da7e142f7311f ]---
> 
> Did some preliminary investigation on this one.
> 
> The problem is the cc->freepages list is empty, but cc->nr_freepages > 0, it
> looks the list and nr_freepages get out-of-sync somewhere.
> 
> Any hint is appreciated.

Many thanks for continuing to test huge tmpfs on linux-next-20160420.

Sorry for leaving you hanging on that bug, it was an easy one, and
in fact fixed before 2016-04-16; but your report got buried in my
mailbox, and we just didn't have an mmotm including the fix in
between: we've all been busy.

Here's a little collection of fixes to bugs, mostly in compaction.c,
that had hit me when trying to test an mmotm of that vintage: see
the thread "mmotm woes, mainly compaction" starting 2016-04-12 on
lkml or linux-kernel.

The problem you hit there was that kcompactd_do_work() was added
by one patchset, and the freepages_held list by another patchset,
so an INIT_LIST_HEAD(&cc.freepages_held) was overlooked.

I've updated one of fixes below to match how Vlastimil actually fixed
it (pageblock_end_pfn instead of what I did originally); and thrown in
the removal of a bogus hunk from page_alloc.c that wasted a lot of time.

But Andrew now has all these or equivalent fixes in his mmots tree
(I believe freepages_held has been withdrawn for now), so there's
nothing for him or Stephen or Vlastimil or Michal to pick up below:
merely collected for your testing convenience.

Hugh
----

 mm/compaction.c |   26 +++++++++++---------------
 mm/page_alloc.c |    8 --------
 2 files changed, 11 insertions(+), 23 deletions(-)

--- 4.6-rc2-mm1/mm/compaction.c	2016-04-10 09:43:20.314514944 -0700
+++ linux/mm/compaction.c	2016-04-26 13:48:38.309152732 -0700
@@ -638,7 +638,6 @@ isolate_migratepages_block(struct compac
 {
 	struct zone *zone = cc->zone;
 	unsigned long nr_scanned = 0, nr_isolated = 0;
-	struct list_head *migratelist = &cc->migratepages;
 	struct lruvec *lruvec;
 	unsigned long flags = 0;
 	bool locked = false;
@@ -817,7 +816,7 @@ isolate_migratepages_block(struct compac
 		del_page_from_lru_list(page, lruvec, page_lru(page));
 
 isolate_success:
-		list_add(&page->lru, migratelist);
+		list_add(&page->lru, &cc->migratepages);
 		cc->nr_migratepages++;
 		nr_isolated++;
 
@@ -851,9 +850,11 @@ isolate_fail:
 				spin_unlock_irqrestore(&zone->lru_lock,	flags);
 				locked = false;
 			}
-			putback_movable_pages(migratelist);
-			nr_isolated = 0;
+			acct_isolated(zone, cc);
+			putback_movable_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
 			cc->last_migrated_pfn = 0;
+			nr_isolated = 0;
 		}
 
 		if (low_pfn < next_skip_pfn) {
@@ -928,17 +929,8 @@ isolate_migratepages_range(struct compac
 
 		pfn = isolate_migratepages_block(cc, pfn, block_end_pfn,
 							ISOLATE_UNEVICTABLE);
-
-		/*
-		 * In case of fatal failure, release everything that might
-		 * have been isolated in the previous iteration, and signal
-		 * the failure back to caller.
-		 */
-		if (!pfn) {
-			putback_movable_pages(&cc->migratepages);
-			cc->nr_migratepages = 0;
+		if (!pfn)
 			break;
-		}
 
 		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
 			break;
@@ -1012,7 +1004,7 @@ static void isolate_freepages(struct com
 	block_start_pfn = pageblock_start_pfn(cc->free_pfn);
 	block_end_pfn = min(block_start_pfn + pageblock_nr_pages,
 						zone_end_pfn(zone));
-	low_pfn = pageblock_start_pfn(cc->migrate_pfn);
+	low_pfn = pageblock_end_pfn(cc->migrate_pfn);
 
 	/*
 	 * Isolate free pages until enough are available to migrate the
@@ -1617,6 +1609,7 @@ static enum compact_result compact_zone_
 
 	VM_BUG_ON(!list_empty(&cc.freepages));
 	VM_BUG_ON(!list_empty(&cc.migratepages));
+	VM_BUG_ON(!list_empty(&cc.freepages_held));
 
 	*contended = cc.contended;
 	return ret;
@@ -1776,6 +1769,7 @@ static void __compact_pgdat(pg_data_t *p
 
 		VM_BUG_ON(!list_empty(&cc->freepages));
 		VM_BUG_ON(!list_empty(&cc->migratepages));
+		VM_BUG_ON(!list_empty(&cc->freepages_held));
 
 		if (is_via_compact_memory(cc->order))
 			continue;
@@ -1940,6 +1934,7 @@ static void kcompactd_do_work(pg_data_t
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
+		INIT_LIST_HEAD(&cc.freepages_held);
 
 		status = compact_zone(zone, &cc);
 
@@ -1957,6 +1952,7 @@ static void kcompactd_do_work(pg_data_t
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
+		VM_BUG_ON(!list_empty(&cc.freepages_held));
 	}
 
 	/*
--- 4.6-rc2-mm1/mm/page_alloc.c	2016-04-10 09:43:20.342515240 -0700
+++ linux/mm/page_alloc.c	2016-04-26 13:48:38.309152732 -0700
@@ -3424,14 +3424,6 @@ retry:
 	if (order && compaction_made_progress(compact_result))
 		compaction_retries++;
 
-	/*
-	 * It can become very expensive to allocate transparent hugepages at
-	 * fault, so use asynchronous memory compaction for THP unless it is
-	 * khugepaged trying to collapse.
-	 */
-	if (!is_thp_gfp_mask(gfp_mask) || (current->flags & PF_KTHREAD))
-		migration_mode = MIGRATE_SYNC_LIGHT;
-
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
 							&did_some_progress);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
