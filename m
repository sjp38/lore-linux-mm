Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D9F8B6B0078
	for <linux-mm@kvack.org>; Wed, 17 Feb 2010 08:30:11 -0500 (EST)
Date: Wed, 17 Feb 2010 13:29:52 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 05/12] Memory compaction core
Message-ID: <20100217132952.GA1663@csn.ul.ie>
References: <1265976059-7459-1-git-send-email-mel@csn.ul.ie> <1265976059-7459-6-git-send-email-mel@csn.ul.ie> <20100216170014.7309.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100216170014.7309.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Feb 16, 2010 at 05:31:59PM +0900, KOSAKI Motohiro wrote:

> > <SNIP>
> >
> > +static unsigned long isolate_migratepages(struct zone *zone,
> > +					struct compact_control *cc)
> > +{
> > +	unsigned long low_pfn, end_pfn;
> > +	struct list_head *migratelist;
> > +	enum lru_list lru_src;
> > +
> > +	low_pfn = ALIGN(cc->migrate_pfn, pageblock_nr_pages);
> > +	migratelist = &cc->migratepages;
> > +
> > +	/* Do not scan outside zone boundaries */
> > +	if (low_pfn < zone->zone_start_pfn)
> > +		low_pfn = zone->zone_start_pfn;
> > +
> > +	/* Setup to scan one block but not past where we are migrating to */
> > +	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
> > +	cc->migrate_pfn = end_pfn;
> > +	VM_BUG_ON(end_pfn > cc->free_pfn);
> > +
> > +	if (!pfn_valid(low_pfn))
> > +		return 0;
> > +
> > +	migrate_prep();
> > +
> > +	/* Time to isolate some pages for migration */
> > +	spin_lock_irq(&zone->lru_lock);
> > +	for (; low_pfn < end_pfn; low_pfn++) {
> 
> pageblock_nr_pages seems too long spin lock holding. why can't we
> release spinlock more frequently?
> 

I changed it to only isolate in quantities of SWAP_CLUSTER_MAX.

> plus, we need prevent too many concurrent compaction. otherwise too
> many isolation makes strange oom killer.
> 

I think the fact that watermarks are checked should prevent this and
processes enter direct reclaim where too_many_isolated() is checked.

> 
> > +		struct page *page;
> > +		if (!pfn_valid_within(low_pfn))
> > +			continue;
> > +
> > +		/* Get the page and skip if free */
> > +		page = pfn_to_page(low_pfn);
> > +		if (PageBuddy(page)) {
> > +			low_pfn += (1 << page_order(page)) - 1;
> > +			continue;
> > +		}
> > +
> > +		if (!PageLRU(page) || PageUnevictable(page))
> > +			continue;
> > +
> > +		/* Try isolate the page */
> > +		lru_src = page_lru(page);
> > +		switch (__isolate_lru_page(page, ISOLATE_BOTH, 0)) {
> 
> I don't think __isolate_lru_page() is suitable. because it can't isolate
> unevictable pages. unevictable pages mean it's undroppable but it can be
> migrated.
> 
> This is significantly difference between lumpy reclaim and migrate based
> compaction. please consider it.
> 

As unevictable pages are being ignored for the moment, I kept with
__isolate_lru_page. Unevictable pages will be a follow-on patch if we
end up agreeing on this set.

> plus, can you please change NR_ISOLATED_FILE/ANON stat in this place. it
> help to prevent strange oom issue.
> 

Good point. Also, I was breaking counters for the LRU lists so thanks
for pushing me to look closer at that.

> 
> > +		case 0:
> > +			list_move(&page->lru, migratelist);
> > +			mem_cgroup_del_lru(page);
> > +			cc->nr_migratepages++;
> > +			break;
> > +
> > +		case -EBUSY:
> > +			/*
> > +			 * else it is being freed elsewhere. The
> > +			 * problem is that we are not really sure where
> > +			 * it came from in the first place
> > +			 * XXX: Verify the putback logic is ok. This was
> > +			 *       all written before LRU lists were split
> > +			 */
> > +			list_move(&page->lru, &zone->lru[lru_src].list);
> > +			mem_cgroup_rotate_lru_list(page, page_lru(page));
> > +			continue;
> 
> we don't need this rotation. probaby you copied it from isolate_lru_pages().

It was copied, yes.

> then, I'd like to explain why isolate_lru_pages() need such rotation.
> isolate_lru_pages() isolate page by lru order, then if it put back the page
> to lru front, next isolate_lru_pages() found the same page. it's obviously
> cpu wasting. then we put back the page to lru tail.
> 
> but this function isolate pages by pfn order, we don't need such trick imho.
> 

Good point. I've addressed this in the patch below. Does it address your
concerns?

==== CUT HERE ====
Fix concerns from Kosaki Motohiro (merge with compaction core)

o Fewer pages are isolated. Hence, cc->migrate_pfn in
  isolate_migratepages() is updated slightly differently and the debug
  checks change
o LRU lists are no longer rotated
o NR_ISOLATED_* is updated
o del_page_from_lru_list() is used instead list_move when isolated so
  that the counters get updated correctly.
o Pages that fail to migrate are put back on the LRU promptly to avoid
  being isolated for too long.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/swap.h |    1 +
 mm/compaction.c      |   81 +++++++++++++++++++++++++++----------------------
 2 files changed, 46 insertions(+), 36 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index 7e7181b..12566ed 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -151,6 +151,7 @@ enum {
 };
 
 #define SWAP_CLUSTER_MAX 32
+#define COMPACT_CLUSTER_MAX SWAP_CLUSTER_MAX
 
 #define SWAP_MAP_MAX	0x3e	/* Max duplication count, in first swap_map */
 #define SWAP_MAP_BAD	0x3f	/* Note pageblock is bad, in first swap_map */
diff --git a/mm/compaction.c b/mm/compaction.c
index 11934b3..9d6fd9f 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -27,6 +27,10 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
+	/* Account for isolated anon and file pages */
+	unsigned long nr_anon;
+	unsigned long nr_file;
+
 	struct zone *zone;
 };
 
@@ -155,6 +159,23 @@ static void isolate_freepages(struct zone *zone,
 	cc->nr_freepages = nr_freepages;
 }
 
+/* Update the number of anon and file isolated pages in the zone) */
+void update_zone_isolated(struct zone *zone, struct compact_control *cc)
+{
+	struct page *page;
+	unsigned int count[NR_LRU_LISTS] = { 0, };
+
+	list_for_each_entry(page, &cc->migratepages, lru) {
+		int lru = page_lru_base_type(page);
+		count[lru]++;
+	}
+
+	cc->nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
+	cc->nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON, cc->nr_anon);
+	__mod_zone_page_state(zone, NR_ISOLATED_FILE, cc->nr_file);
+}
+
 /*
  * Isolate all pages that can be migrated from the block pointed to by
  * the migrate scanner within compact_control.
@@ -164,9 +185,8 @@ static unsigned long isolate_migratepages(struct zone *zone,
 {
 	unsigned long low_pfn, end_pfn;
 	struct list_head *migratelist;
-	enum lru_list lru_src;
 
-	low_pfn = ALIGN(cc->migrate_pfn, pageblock_nr_pages);
+	low_pfn = cc->migrate_pfn;
 	migratelist = &cc->migratepages;
 
 	/* Do not scan outside zone boundaries */
@@ -175,11 +195,12 @@ static unsigned long isolate_migratepages(struct zone *zone,
 
 	/* Setup to scan one block but not past where we are migrating to */
 	end_pfn = ALIGN(low_pfn + pageblock_nr_pages, pageblock_nr_pages);
-	cc->migrate_pfn = end_pfn;
-	VM_BUG_ON(end_pfn > cc->free_pfn);
 
-	if (!pfn_valid(low_pfn))
+	/* Do not cross the free scanner or scan within a memory hole */
+	if (end_pfn > cc->free_pfn || !pfn_valid(low_pfn)) {
+		cc->migrate_pfn = end_pfn;
 		return 0;
+	}
 
 	migrate_prep();
 
@@ -201,31 +222,22 @@ static unsigned long isolate_migratepages(struct zone *zone,
 			continue;
 
 		/* Try isolate the page */
-		lru_src = page_lru(page);
-		switch (__isolate_lru_page(page, ISOLATE_BOTH, 0)) {
-		case 0:
-			list_move(&page->lru, migratelist);
+		if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
+			del_page_from_lru_list(zone, page, page_lru(page));
+			list_add(&page->lru, migratelist);
 			mem_cgroup_del_lru(page);
 			cc->nr_migratepages++;
+		}
+
+		/* Avoid isolating too much */
+		if (cc->nr_migratepages == COMPACT_CLUSTER_MAX)
 			break;
+	}
 
-		case -EBUSY:
-			/*
-			 * else it is being freed elsewhere. The
-			 * problem is that we are not really sure where
-			 * it came from in the first place
-			 * XXX: Verify the putback logic is ok. This was
-			 *       all written before LRU lists were split
-			 */
-			list_move(&page->lru, &zone->lru[lru_src].list);
-			mem_cgroup_rotate_lru_list(page, page_lru(page));
-			continue;
+	update_zone_isolated(zone, cc);
 
-		default:
-			BUG();
-		}
-	}
 	spin_unlock_irq(&zone->lru_lock);
+	cc->migrate_pfn = low_pfn;
 
 	return cc->nr_migratepages;
 }
@@ -318,24 +330,21 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 		count_vm_events(COMPACTPAGES, nr_migrate - nr_remaining);
 		if (nr_remaining)
 			count_vm_events(COMPACTPAGEFAILED, nr_remaining);
+
+		/* Release LRU pages not migrated */
+		if (!list_empty(&cc->migratepages)) {
+			putback_lru_pages(&cc->migratepages);
+			cc->nr_migratepages = 0;
+		}
+
+		mod_zone_page_state(zone, NR_ISOLATED_ANON, -cc->nr_anon);
+		mod_zone_page_state(zone, NR_ISOLATED_FILE, -cc->nr_file);
 	}
 
 	/* Release free pages and check accounting */
 	cc->nr_freepages -= release_freepages(zone, &cc->freepages);
 	VM_BUG_ON(cc->nr_freepages != 0);
 
-	/*
-	 * Release LRU pages not migrated
-	 * XXX: Page migration at this point tries fairly hard to move
-	 *	pages as it is but if migration fails, pages are left
-	 *	on cc->migratepages for more passes. This might cause
-	 *	multiple useless failures. Watch compact_pagemigrate_failed
-	 *	in /proc/vmstat. If it grows a lot, then putback should
-	 *	happen after each failed migration
-	 */
-	if (!list_empty(&cc->migratepages))
-		putback_lru_pages(&cc->migratepages);
-
 	return ret;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
