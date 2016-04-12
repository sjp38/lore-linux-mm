Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f172.google.com (mail-pf0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 181F26B0005
	for <linux-mm@kvack.org>; Tue, 12 Apr 2016 03:18:12 -0400 (EDT)
Received: by mail-pf0-f172.google.com with SMTP id c20so8604362pfc.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:18:12 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id a190si8338058pfa.80.2016.04.12.00.18.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Apr 2016 00:18:11 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id ot11so8428373pab.1
        for <linux-mm@kvack.org>; Tue, 12 Apr 2016 00:18:11 -0700 (PDT)
Date: Tue, 12 Apr 2016 00:18:00 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: mmotm woes, mainly compaction
Message-ID: <alpine.LSU.2.11.1604120005350.1832@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Michal, I'm sorry to say that I now find that I misinformed you.

You'll remember when we were chasing the order=2 OOMs on two of my
machines at the end of March (in private mail).  And you sent me a
mail containing two patches, the second "Another thing to try ...
so this on top" doing a *migrate_mode++.

I answered you definitively that the first patch worked,
so "I haven't tried adding the one below at all".

Not true, I'm afraid.  Although I had split the *migrate_mode++ one
off into a separate patch that I did not apply, I found looking back
today (when trying to work out why order=2 OOMs were still a problem
on mmotm 2016-04-06) that I never deleted that part from the end of
the first patch; so in fact what I'd been testing had included the
second; and now I find that _it_ was the effective solution.

Which is particularly sad because I think we were both a bit
uneasy about the *migrate_mode++ one: partly the style of it
incrementing the enum; but more seriously that it advances all the
way to MIGRATE_SYNC, when the first went only to MIGRATE_SYNC_LIGHT.

But without it, I am still stuck with the order=2 OOMs.

And worse: after establishing that that fixes the order=2 OOMs for
me on 4.6-rc2-mm1, I thought I'd better check that the three you
posted today (the 1/2 classzone_idx one, the 2/2 prevent looping
forever, and the "ction-abstract-compaction-feedback-to-helpers-fix";
but I'm too far behind to consider or try the RFC thp backoff one)
(a) did not surprisingly fix it on their own, and (b) worked well
with the *migrate_mode++ one added in.

(a) as you'd expect, they did not help on their own; and (b) they
worked fine together on the G5 (until it hit the powerpc swapping
sigsegv, which I think the powerpc guys are hoping is a figment of
my imagination); but (b) they did not work fine together on the
laptop, that combination now gives it order=1 OOMs.  Despair.

And I'm sorry that it's taken me so long to report, but aside from
home distractions, I had quite a lot of troubles with 4.6-rc2-mm1 on
different machines, once I got down to trying it.  But located Eric's
fix to an __inet_hash() crash in linux-next, and spotted Joonsoo's
setup_kmem_cache_node() slab bootup fix on lkml this morning.
With those out of the way, and forgetting the OOMs for now,

[PATCH mmotm] mm: fix several bugs in compaction

Fix three problems in the mmotm 2016-04-06-20-40 mm/compaction.c,
plus three minor tidyups there.  Sorry, I'm now too tired to work
out which is a fix to what patch, and split them up appropriately:
better get these out quickly now.

1. Fix crash in release_pages() from compact_zone() from kcompactd_do_work():
   kcompactd needs to INIT_LIST_HEAD on the new freepages_held list.

2. Fix crash in get_pfnblock_flags_mask() from suitable_migration_target()
   from isolate_freepages(): there's a case when that "block_start_pfn -=
   pageblock_nr_pages" loop can pass through 0 and end up trying to access
   a pageblock before the start of the mem_map[].  (I have not worked out
   why this never hit me before 4.6-rc2-mm1, it looks much older.)

3. /proc/sys/vm/stat_refresh warns nr_isolated_anon and nr_isolated_file
   go increasingly negative under compaction: which would add delay when
   should be none, or no delay when should delay.  putback_movable_pages()
   decrements the NR_ISOLATED counts which acct_isolated() increments,
   so isolate_migratepages_block() needs to acct before putback in that
   special case, and isolate_migratepages_range() can always do the acct
   itself, leaving migratepages putback to caller like most other places.

4. Added VM_BUG_ONs to assert freepages_held is empty, matching those on
   the other lists - though they're getting to look rather too much now.

5. It's easier to track the life of cc->migratepages if we don't assign
   it to a migratelist variable.

6. Remove unused bool success from kcompactd_do_work().

Signed-off-by: Hugh Dickins <hughd@google.com>

--- 4.6-rc2-mm1/mm/compaction.c	2016-04-10 09:43:20.314514944 -0700
+++ linux/mm/compaction.c	2016-04-11 11:35:08.536604712 -0700
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
@@ -1019,7 +1011,7 @@ static void isolate_freepages(struct com
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
 	 */
-	for (; block_start_pfn >= low_pfn;
+	for (; block_start_pfn >= low_pfn && block_start_pfn < block_end_pfn;
 				block_end_pfn = block_start_pfn,
 				block_start_pfn -= pageblock_nr_pages,
 				isolate_start_pfn = block_start_pfn) {
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
@@ -1915,7 +1909,6 @@ static void kcompactd_do_work(pg_data_t
 		.ignore_skip_hint = true,
 
 	};
-	bool success = false;
 
 	trace_mm_compaction_kcompactd_wake(pgdat->node_id, cc.order,
 							cc.classzone_idx);
@@ -1940,12 +1933,12 @@ static void kcompactd_do_work(pg_data_t
 		cc.zone = zone;
 		INIT_LIST_HEAD(&cc.freepages);
 		INIT_LIST_HEAD(&cc.migratepages);
+		INIT_LIST_HEAD(&cc.freepages_held);
 
 		status = compact_zone(zone, &cc);
 
 		if (zone_watermark_ok(zone, cc.order, low_wmark_pages(zone),
 						cc.classzone_idx, 0)) {
-			success = true;
 			compaction_defer_reset(zone, cc.order, false);
 		} else if (status == COMPACT_PARTIAL_SKIPPED || status == COMPACT_COMPLETE) {
 			/*
@@ -1957,6 +1950,7 @@ static void kcompactd_do_work(pg_data_t
 
 		VM_BUG_ON(!list_empty(&cc.freepages));
 		VM_BUG_ON(!list_empty(&cc.migratepages));
+		VM_BUG_ON(!list_empty(&cc.freepages_held));
 	}
 
 	/*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
