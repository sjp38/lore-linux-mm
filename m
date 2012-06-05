Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id BE9D56B0062
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 22:38:36 -0400 (EDT)
Message-ID: <4FCD713D.3020100@kernel.org>
Date: Tue, 05 Jun 2012 11:38:53 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v9] mm: compaction: handle incorrect MIGRATE_UNMOVABLE
 type pageblocks
References: <201206041543.56917.b.zolnierkie@samsung.com> <4FCD18FD.5030307@gmail.com> <4FCD6806.7070609@kernel.org>
In-Reply-To: <4FCD6806.7070609@kernel.org>
Content-Type: multipart/mixed;
 boundary="------------010704080805010100080709"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>

This is a multi-part message in MIME format.
--------------010704080805010100080709
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 06/05/2012 10:59 AM, Minchan Kim wrote:

> On 06/05/2012 05:22 AM, KOSAKI Motohiro wrote:
> 
>>> +/*
>>> + * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
>>> + * converted to MIGRATE_MOVABLE type, false otherwise.
>>> + */
>>> +static bool can_rescue_unmovable_pageblock(struct page *page, bool
>>> locked)
>>> +{
>>> +    unsigned long pfn, start_pfn, end_pfn;
>>> +    struct page *start_page, *end_page, *cursor_page;
>>> +
>>> +    pfn = page_to_pfn(page);
>>> +    start_pfn = pfn&  ~(pageblock_nr_pages - 1);
>>> +    end_pfn = start_pfn + pageblock_nr_pages - 1;
>>> +
>>> +    start_page = pfn_to_page(start_pfn);
>>> +    end_page = pfn_to_page(end_pfn);
>>> +
>>> +    for (cursor_page = start_page, pfn = start_pfn; cursor_page<=
>>> end_page;
>>> +        pfn++, cursor_page++) {
>>> +        struct zone *zone = page_zone(start_page);
>>> +        unsigned long flags;
>>> +
>>> +        if (!pfn_valid_within(pfn))
>>> +            continue;
>>> +
>>> +        /* Do not deal with pageblocks that overlap zones */
>>> +        if (page_zone(cursor_page) != zone)
>>> +            return false;
>>> +
>>> +        if (!locked)
>>> +            spin_lock_irqsave(&zone->lock, flags);
>>> +
>>> +        if (PageBuddy(cursor_page)) {
>>> +            int order = page_order(cursor_page);
>>>
>>> -/* Returns true if the page is within a block suitable for migration
>>> to */
>>> -static bool suitable_migration_target(struct page *page)
>>> +            pfn += (1<<  order) - 1;
>>> +            cursor_page += (1<<  order) - 1;
>>> +
>>> +            if (!locked)
>>> +                spin_unlock_irqrestore(&zone->lock, flags);
>>> +            continue;
>>> +        } else if (page_count(cursor_page) == 0 ||
>>> +               PageLRU(cursor_page)) {
>>> +            if (!locked)
>>> +                spin_unlock_irqrestore(&zone->lock, flags);
>>> +            continue;
>>> +        }
>>> +
>>> +        if (!locked)
>>> +            spin_unlock_irqrestore(&zone->lock, flags);
>>> +
>>> +        return false;
>>> +    }
>>> +
>>> +    return true;
>>> +}
>>
>> Minchan, are you interest this patch? If yes, can you please rewrite it?
> 
> 
> Can do it but I want to give credit to Bartlomiej.
> Bartlomiej, if you like my patch, could you resend it as formal patch after you do broad testing?
> 
> 
>> This one are
>> not fixed our pointed issue and can_rescue_unmovable_pageblock() still
>> has plenty bugs.
>> We can't ack it.
>>
>> -- 
> 
> 
> Frankly speaking, I don't want to merge it without any data which prove it's really good for real practice.
> 
> When the patch firstly was submitted, it wasn't complicated so I was okay at that time but it has been complicated
> than my expectation. So if Andrew might pass the decision to me, I'm totally NACK if author doesn't provide
> any real data or VOC of some client.
> 
> 1) Any comment?
> 
> Anyway, I fixed some bugs and clean up something I found during review.
> 
> Minor thing.
> 1. change smt_result naming - I never like such long non-consistent naming. How about this?
> 2. fix can_rescue_unmovable_pageblock 
>    2.1 pfn valid check for page_zone
> 
> Major thing.
> 
>    2.2 add lru_lock for stablizing PageLRU
>        If we don't hold lru_lock, there is possibility that unmovable(non-LRU) page can put in movable pageblock.
>        It can make compaction/CMA's regression. But there is a concern about deadlock between lru_lock and lock.
>        As I look the code, I can't find allocation trial with holding lru_lock so it might be safe(but not sure,
>        I didn't test it. It need more careful review/testing) but it makes new locking dependency(not sure, too.
>        We already made such rule but I didn't know that until now ;-) ) Why I thought so is we can allocate
>        GFP_ATOMIC with holding lru_lock, logically which might be crazy idea.
> 
>    2.3 remove zone->lock in first phase.
>        We do rescue unmovable pageblock by 2-phase. In first-phase, we just peek pages so we don't need locking.
>        If we see non-stablizing value, it would be caught by 2-phase with needed lock or 
>        can_rescue_unmovable_pageblock can return out of loop by stale page_order(cursor_page).
>        It couldn't make unmovable pageblock to movable but we can do it next time, again.
>        It's not critical.
> 
> 2) Any comment?
> 
> Now I can't inline the code so sorry but attach patch.
> It's not a formal patch/never tested.
> 


Attached patch has a BUG in can_rescue_unmovable_pageblock.
Resend. I hope it is fixed.

 



-- 
Kind regards,
Minchan Kim

--------------010704080805010100080709
Content-Type: text/x-patch;
 name="1.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="1.patch"

diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index 51a90b7..e988037 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,6 +1,8 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
+#include <linux/node.h>
+
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* compaction didn't start as it was not possible or direct reclaim was more suitable */
 #define COMPACT_SKIPPED		0
@@ -11,6 +13,23 @@
 /* The full zone was compacted */
 #define COMPACT_COMPLETE	3
 
+/*
+ * compaction supports three modes
+ *
+ * COMPACT_ASYNC_MOVABLE uses asynchronous migration and only scans
+ *    MIGRATE_MOVABLE pageblocks as migration sources and targets.
+ * COMPACT_ASYNC_UNMOVABLE uses asynchronous migration and only scans
+ *    MIGRATE_MOVABLE pageblocks as migration sources.
+ *    MIGRATE_UNMOVABLE pageblocks are scanned as potential migration
+ *    targets and convers them to MIGRATE_MOVABLE if possible
+ * COMPACT_SYNC uses synchronous migration and scans all pageblocks
+ */
+enum compact_mode {
+	COMPACT_ASYNC_MOVABLE,
+	COMPACT_ASYNC_UNMOVABLE,
+	COMPACT_SYNC,
+};
+
 #ifdef CONFIG_COMPACTION
 extern int sysctl_compact_memory;
 extern int sysctl_compaction_handler(struct ctl_table *table, int write,
diff --git a/mm/compaction.c b/mm/compaction.c
index 7ea259d..dd02f25 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -236,7 +236,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	 */
 	while (unlikely(too_many_isolated(zone))) {
 		/* async migration should just abort */
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			return 0;
 
 		congestion_wait(BLK_RW_ASYNC, HZ/10);
@@ -304,7 +304,8 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		 * satisfies the allocation
 		 */
 		pageblock_nr = low_pfn >> pageblock_order;
-		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
+		if (cc->mode != COMPACT_SYNC &&
+		    last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
 			low_pfn += pageblock_nr_pages;
 			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
@@ -325,7 +326,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			continue;
 		}
 
-		if (!cc->sync)
+		if (cc->mode != COMPACT_SYNC)
 			mode |= ISOLATE_ASYNC_MIGRATE;
 
 		lruvec = mem_cgroup_page_lruvec(page, zone);
@@ -360,27 +361,121 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
+/*
+ * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
+ * converted to MIGRATE_MOVABLE type, false otherwise.
+ */
+static bool can_rescue_unmovable_pageblock(struct page *page, bool need_lrulock)
+{
+	struct zone *zone;
+	unsigned long pfn, start_pfn, end_pfn;
+	struct page *start_page, *end_page, *cursor_page;
+	bool lru_locked = false;
+
+	zone = page_zone(page);
+	pfn = page_to_pfn(page);
+	start_pfn = pfn & ~(pageblock_nr_pages - 1);
+	end_pfn = start_pfn + pageblock_nr_pages - 1;
+
+	start_page = pfn_to_page(start_pfn);
+	end_page = pfn_to_page(end_pfn);
+
+	for (cursor_page = start_page, pfn = start_pfn; cursor_page <= end_page;
+		pfn++, cursor_page++) {
 
-/* Returns true if the page is within a block suitable for migration to */
-static bool suitable_migration_target(struct page *page)
+		if (!pfn_valid_within(pfn))
+			continue;
+
+		/* Do not deal with pageblocks that overlap zones */
+		if (page_zone(cursor_page) != zone)
+			goto out;
+
+		if (PageBuddy(cursor_page)) {
+			unsigned long order = page_order(cursor_page);
+
+			pfn += (1 << order) - 1;
+			cursor_page += (1 << order) - 1;
+			continue;
+		} else if (page_count(cursor_page) == 0) {
+			continue;
+		} else if (PageLRU(cursor_page)) {
+			if (!need_lrulock)
+				continue;
+			else if (lru_locked)
+				continue;
+			else {
+				spin_lock(&zone->lru_lock);
+				lru_locked = true;
+				if (PageLRU(page))
+					continue;
+			}
+		}
+
+		goto out;
+	}
+
+	return true;
+out:
+	if (lru_locked)
+		spin_unlock(&zone->lru_lock);
+
+	return false;
+}
+
+static void rescue_unmovable_pageblock(struct page *page)
+{
+	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
+	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
+}
+
+/*
+ * MIGRATE_TARGET : good for migration target
+ * RESCUE_UNMOVABLE_TARTET : good only if we can rescue the unmovable pageblock.
+ * UNMOVABLE_TARGET : can't migrate because it's a page in unmovable pageblock.
+ * SKIP_TARGET : can't migrate another reasons.
+ */
+enum smt_result {
+	MIGRATE_TARGET,
+	RESCUE_UNMOVABLE_TARGET,
+	UNMOVABLE_TARGET,
+	SKIP_TARGET,
+};
+
+/*
+ * Returns MIGRATE_TARGET if the page is within a block
+ * suitable for migration to, UNMOVABLE_TARGET if the page
+ * is within a MIGRATE_UNMOVABLE block, SKIP_TARGET otherwise.
+ */
+static enum smt_result suitable_migration_target(struct page *page,
+			      struct compact_control *cc, bool need_lrulock)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
 	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
-		return false;
+		return SKIP_TARGET;
 
 	/* If the page is a large free page, then allow migration */
 	if (PageBuddy(page) && page_order(page) >= pageblock_order)
-		return true;
+		return MIGRATE_TARGET;
 
 	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
-	if (migrate_async_suitable(migratetype))
-		return true;
+	if (cc->mode != COMPACT_ASYNC_UNMOVABLE &&
+	    migrate_async_suitable(migratetype))
+		return MIGRATE_TARGET;
+
+	if (cc->mode == COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE)
+		return UNMOVABLE_TARGET;
+
+	if (cc->mode != COMPACT_ASYNC_MOVABLE &&
+	    migratetype == MIGRATE_UNMOVABLE &&
+	    can_rescue_unmovable_pageblock(page, need_lrulock))
+		return RESCUE_UNMOVABLE_TARGET;
 
 	/* Otherwise skip the block */
-	return false;
+	return SKIP_TARGET;
 }
 
 /*
@@ -414,6 +509,13 @@ static void isolate_freepages(struct zone *zone,
 	zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
 
 	/*
+	 * isolate_freepages() may be called more than once during
+	 * compact_zone_order() run and we want only the most recent
+	 * count.
+	 */
+	cc->nr_unmovable_pageblock = 0;
+
+	/*
 	 * Isolate free pages until enough are available to migrate the
 	 * pages on cc->migratepages. We stop searching if the migrate
 	 * and free page scanners meet or enough free pages are isolated.
@@ -421,6 +523,7 @@ static void isolate_freepages(struct zone *zone,
 	for (; pfn > low_pfn && cc->nr_migratepages > nr_freepages;
 					pfn -= pageblock_nr_pages) {
 		unsigned long isolated;
+		enum smt_result ret;
 
 		if (!pfn_valid(pfn))
 			continue;
@@ -437,9 +540,12 @@ static void isolate_freepages(struct zone *zone,
 			continue;
 
 		/* Check the block is suitable for migration */
-		if (!suitable_migration_target(page))
+		ret = suitable_migration_target(page, cc, false);
+		if (ret != MIGRATE_TARGET && ret != RESCUE_UNMOVABLE_TARGET) {
+			if (ret == UNMOVABLE_TARGET)
+				cc->nr_unmovable_pageblock++;
 			continue;
-
+		}
 		/*
 		 * Found a block suitable for isolating free pages from. Now
 		 * we disabled interrupts, double check things are ok and
@@ -448,12 +554,16 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		if (suitable_migration_target(page)) {
+		ret = suitable_migration_target(page, cc, true);
+		if (ret == MIGRATE_TARGET || ret == RESCUE_UNMOVABLE_TARGET) {
+			if (ret == RESCUE_UNMOVABLE_TARGET)
+				rescue_unmovable_pageblock(page);
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);
 			nr_freepages += isolated;
-		}
+		} else if (ret == UNMOVABLE_TARGET)
+			cc->nr_unmovable_pageblock++;
 		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
@@ -685,8 +795,9 @@ static int compact_zone(struct zone *zone, struct compact_control *cc)
 
 		nr_migrate = cc->nr_migratepages;
 		err = migrate_pages(&cc->migratepages, compaction_alloc,
-				(unsigned long)cc, false,
-				cc->sync ? MIGRATE_SYNC_LIGHT : MIGRATE_ASYNC);
+			(unsigned long)&cc->freepages, false,
+			(cc->mode == COMPACT_SYNC) ? MIGRATE_SYNC_LIGHT
+						      : MIGRATE_ASYNC);
 		update_nr_listpages(cc);
 		nr_remaining = cc->nr_migratepages;
 
@@ -715,7 +826,8 @@ out:
 
 static unsigned long compact_zone_order(struct zone *zone,
 				 int order, gfp_t gfp_mask,
-				 bool sync)
+				 enum compact_mode mode,
+				 unsigned long *nr_pageblocks_skipped)
 {
 	struct compact_control cc = {
 		.nr_freepages = 0,
@@ -723,12 +835,17 @@ static unsigned long compact_zone_order(struct zone *zone,
 		.order = order,
 		.migratetype = allocflags_to_migratetype(gfp_mask),
 		.zone = zone,
-		.sync = sync,
+		.mode = mode,
 	};
+	unsigned long rc;
+
 	INIT_LIST_HEAD(&cc.freepages);
 	INIT_LIST_HEAD(&cc.migratepages);
 
-	return compact_zone(zone, &cc);
+	rc = compact_zone(zone, &cc);
+	*nr_pageblocks_skipped = cc.nr_unmovable_pageblock;
+
+	return rc;
 }
 
 int sysctl_extfrag_threshold = 500;
@@ -753,6 +870,8 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 	struct zoneref *z;
 	struct zone *zone;
 	int rc = COMPACT_SKIPPED;
+	unsigned long nr_pageblocks_skipped;
+	enum compact_mode mode;
 
 	/*
 	 * Check whether it is worth even starting compaction. The order check is
@@ -769,12 +888,22 @@ unsigned long try_to_compact_pages(struct zonelist *zonelist,
 								nodemask) {
 		int status;
 
-		status = compact_zone_order(zone, order, gfp_mask, sync);
+		mode = sync ? COMPACT_SYNC : COMPACT_ASYNC_MOVABLE;
+retry:
+		status = compact_zone_order(zone, order, gfp_mask, mode,
+						&nr_pageblocks_skipped);
 		rc = max(status, rc);
 
 		/* If a normal allocation would succeed, stop compacting */
 		if (zone_watermark_ok(zone, order, low_wmark_pages(zone), 0, 0))
 			break;
+
+		if (rc == COMPACT_COMPLETE && mode == COMPACT_ASYNC_MOVABLE) {
+			if (nr_pageblocks_skipped) {
+				mode = COMPACT_ASYNC_UNMOVABLE;
+				goto retry;
+			}
+		}
 	}
 
 	return rc;
@@ -808,7 +937,7 @@ static int __compact_pgdat(pg_data_t *pgdat, struct compact_control *cc)
 			if (ok && cc->order > zone->compact_order_failed)
 				zone->compact_order_failed = cc->order + 1;
 			/* Currently async compaction is never deferred. */
-			else if (!ok && cc->sync)
+			else if (!ok && cc->mode == COMPACT_SYNC)
 				defer_compaction(zone, cc->order);
 		}
 
@@ -823,7 +952,7 @@ int compact_pgdat(pg_data_t *pgdat, int order)
 {
 	struct compact_control cc = {
 		.order = order,
-		.sync = false,
+		.mode = COMPACT_ASYNC_MOVABLE,
 	};
 
 	return __compact_pgdat(pgdat, &cc);
@@ -833,7 +962,7 @@ static int compact_node(int nid)
 {
 	struct compact_control cc = {
 		.order = -1,
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 
 	return __compact_pgdat(NODE_DATA(nid), &cc);
diff --git a/mm/internal.h b/mm/internal.h
index 2ba87fb..061fde7 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -94,6 +94,9 @@ extern void putback_lru_page(struct page *page);
 /*
  * in mm/page_alloc.c
  */
+extern void set_pageblock_migratetype(struct page *page, int migratetype);
+extern int move_freepages_block(struct zone *zone, struct page *page,
+				int migratetype);
 extern void __free_pages_bootmem(struct page *page, unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned long order);
 #ifdef CONFIG_MEMORY_FAILURE
@@ -101,6 +104,7 @@ extern bool is_free_buddy_page(struct page *page);
 #endif
 
 #if defined CONFIG_COMPACTION || defined CONFIG_CMA
+#include <linux/compaction.h>
 
 /*
  * in mm/compaction.c
@@ -119,11 +123,14 @@ struct compact_control {
 	unsigned long nr_migratepages;	/* Number of pages to migrate */
 	unsigned long free_pfn;		/* isolate_freepages search base */
 	unsigned long migrate_pfn;	/* isolate_migratepages search base */
-	bool sync;			/* Synchronous migration */
+	enum compact_mode mode;		/* Compaction mode */
 
 	int order;			/* order a direct compactor needs */
 	int migratetype;		/* MOVABLE, RECLAIMABLE etc */
 	struct zone *zone;
+
+	/* Number of UNMOVABLE destination pageblocks skipped during scan */
+	unsigned long nr_unmovable_pageblock;
 };
 
 unsigned long
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 476ae3e..d40e4c7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -219,7 +219,7 @@ EXPORT_SYMBOL(nr_online_nodes);
 
 int page_group_by_mobility_disabled __read_mostly;
 
-static void set_pageblock_migratetype(struct page *page, int migratetype)
+void set_pageblock_migratetype(struct page *page, int migratetype)
 {
 
 	if (unlikely(page_group_by_mobility_disabled))
@@ -954,8 +954,8 @@ static int move_freepages(struct zone *zone,
 	return pages_moved;
 }
 
-static int move_freepages_block(struct zone *zone, struct page *page,
-				int migratetype)
+int move_freepages_block(struct zone *zone, struct page *page,
+			 int migratetype)
 {
 	unsigned long start_pfn, end_pfn;
 	struct page *start_page, *end_page;
@@ -5651,7 +5651,7 @@ static int __alloc_contig_migrate_range(unsigned long start, unsigned long end)
 		.nr_migratepages = 0,
 		.order = -1,
 		.zone = page_zone(pfn_to_page(start)),
-		.sync = true,
+		.mode = COMPACT_SYNC,
 	};
 	INIT_LIST_HEAD(&cc.migratepages);
 

--------------010704080805010100080709--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
