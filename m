Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id DF98E6B0062
	for <linux-mm@kvack.org>; Wed, 20 Jun 2012 02:11:54 -0400 (EDT)
Message-ID: <4FE169B1.7020600@kernel.org>
Date: Wed, 20 Jun 2012 15:12:01 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Accounting problem of MIGRATE_ISOLATED freed page
Content-Type: multipart/mixed;
 boundary="------------000707090707070002060305"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaditya Kumar <aaditya.kumar.30@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is a multi-part message in MIME format.
--------------000707090707070002060305
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit


Hi Aaditya,

I want to discuss this problem on another thread.

On 06/19/2012 10:18 PM, Aaditya Kumar wrote:
> On Mon, Jun 18, 2012 at 6:13 AM, Minchan Kim <minchan@kernel.org> wrote:
>> On 06/17/2012 02:48 AM, Aaditya Kumar wrote:
>>
>>> On Fri, Jun 15, 2012 at 12:57 PM, Minchan Kim <minchan@kernel.org> wrote:
>>>
>>>>>
>>>>> pgdat_balanced() doesn't recognized zone. Therefore kswapd may sleep
>>>>> if node has multiple zones. Hm ok, I realized my descriptions was
>>>>> slightly misleading. priority 0 is not needed. bakance_pddat() calls
>>>>> pgdat_balanced()
>>>>> every priority. Most easy case is, movable zone has a lot of free pages and
>>>>> normal zone has no reclaimable page.
>>>>>
>>>>> btw, current pgdat_balanced() logic seems not correct. kswapd should
>>>>> sleep only if every zones have much free pages than high water mark
>>>>> _and_ 25% of present pages in node are free.
>>>>>
>>>>
>>>>
>>>> Sorry. I can't understand your point.
>>>> Current kswapd doesn't sleep if relevant zones don't have free pages above high watermark.
>>>> It seems I am missing your point.
>>>> Please anybody correct me.
>>>
>>> Since currently direct reclaim is given up based on
>>> zone->all_unreclaimable flag,
>>> so for e.g in one of the scenarios:
>>>
>>> Lets say system has one node with two zones (NORMAL and MOVABLE) and we
>>> hot-remove the all the pages of the MOVABLE zone.
>>>
>>> While migrating pages during memory hot-unplugging, the allocation function
>>> (for new page to which the page in MOVABLE zone would be moved)  can end up
>>> looping in direct reclaim path for ever.
>>>
>>> This is so because when most of the pages in the MOVABLE zone have
>>> been migrated,
>>> the zone now contains lots of free memory (basically above low watermark)
>>> BUT all are in MIGRATE_ISOLATE list of the buddy list.
>>>
>>> So kswapd() would not balance this zone as free pages are above low watermark
>>> (but all are in isolate list). So zone->all_unreclaimable flag would
>>> never be set for this zone
>>> and allocation function would end up looping forever. (assuming the
>>> zone NORMAL is
>>> left with no reclaimable memory)
>>>
>>
>>
>> Thanks a lot, Aaditya! Scenario you mentioned makes perfect.
>> But I don't see it's a problem of kswapd.
> 
> Hi Kim,

I like called Minchan rather than Kim
Never mind. :)

> 
> Yes I agree it is not a problem of kswapd.

Yeb.

> 
>> a5d76b54 made new migration type 'MIGRATE_ISOLATE' which is very irony type because there are many free pages in free list
>> but we can't allocate it. :(
>> It doesn't reflect right NR_FREE_PAGES while many places in the kernel use NR_FREE_PAGES to trigger some operation.
>> Kswapd is just one of them confused.
>> As right fix of this problem, we should fix hot plug code, IMHO which can fix CMA, too.
>>
>> This patch could make inconsistency between NR_FREE_PAGES and SumOf[free_area[order].nr_free]
> 
> 
> I assume that by the inconsistency you mention above, you mean
> temporary inconsistency.
> 
> Sorry, but IMHO as for memory hot plug the main issue with this patch
> is that the inconsistency you mentioned above would NOT be a temporary
> inconsistency.
> 
> Every time say 'x' number of page frames are off lined, they will
> introduce a difference of 'x' pages between
> NR_FREE_PAGES and SumOf[free_area[order].nr_free].
> (So for e.g. if we do a frequent offline/online it will make
> NR_FREE_PAGES  negative)
> 
> This is so because, unset_migratetype_isolate() is called from
> offlining  code (to set the migrate type of off lined pages again back
> to MIGRATE_MOVABLE)
> after the pages have been off lined and removed from the buddy list.
> Since the pages for which unset_migratetype_isolate() is called are
> not buddy pages so move_freepages_block() does not move any page, and
> thus introducing a permanent inconsistency.

Good point. Negative NR_FREE_PAGES is caused by double counting by my patch and __offline_isolated_pages.
I think at first MIGRATE_ISOLATE type freed page shouldn't account as free page.

> 
>> and it could make __zone_watermark_ok confuse so we might need to fix move_freepages_block itself to reflect
>> free_area[order].nr_free exactly.
>>
>> Any thought?
> 
> As for fixing move_freepages_block(), At least for memory hot plug,
> the pages stay in MIGRATE_ISOLATE list only for duration
> offline_pages() function,
> I mean only temporarily. Since fixing move_freepages_block() for will
> introduce some overhead, So I am not very sure whether that overhead
> is justified
> for a temporary condition. What do you think?

Yes. I don't like hurt fast path, either.
How about this? (Passed just compile test :(  )
The patch's goal is to NOT increase nr_free and NR_FREE_PAGES about freed page into MIGRATE_ISOLATED.

This patch hurts high order page free path but I think it's not critical because higher order allocation
is rare than order-0 allocation and we already have done same thing on free_hot_cold_page on order-0 free path
which is more hot.

Maybe below patch is completed malformed. I can't inline the code at the office. Sorry.
Instead, I will attach the patch.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..d2a515d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -676,6 +676,24 @@ static void free_pcppages_bulk(struct zone *zone, int count,
        spin_unlock(&zone->lock);
 }
 
+/*
+ * This function is almost same with free_one_page except that it
+ * doesn't increase NR_FREE_PAGES and free_area[order].nr_free.
+ * Because page allocator can't allocate MIGRATE_ISOLATE type page.
+ *
+ * Caller should hold zone->lock.
+ */
+static void free_one_isolated_page(struct zone *zone, struct page *page,
+                               int order)
+{
+       zone->all_unreclaimable = 0;
+       zone->pages_scanned = 0;
+
+       __free_one_page(page, zone, order, MIGRATE_ISOLATE);
+       /* rollback nr_free increased by __free_one_page */
+       zone->free_area[order].nr_free--;
+}
+
 static void free_one_page(struct zone *zone, struct page *page, int order,
                                int migratetype)
 {
@@ -683,6 +701,13 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
        zone->all_unreclaimable = 0;
        zone->pages_scanned = 0;
 
+       /*
+        * Freed MIGRATE_ISOLATE page should be free_one_isolated_page path
+        * because page allocator don't want to increase NR_FREE_PAGES and
+        * free_area[order].nr_free.
+        */
+       VM_BUG_ON(migratetype == MIGRATE_ISOLATE);
+
        __free_one_page(page, zone, order, migratetype);
        __mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
        spin_unlock(&zone->lock);
@@ -718,6 +743,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 {
        unsigned long flags;
        int wasMlocked = __TestClearPageMlocked(page);
+       int migratetype;
 
        if (!free_pages_prepare(page, order))
                return;
@@ -726,8 +752,21 @@ static void __free_pages_ok(struct page *page, unsigned int order)
        if (unlikely(wasMlocked))
                free_page_mlock(page);
        __count_vm_events(PGFREE, 1 << order);
-       free_one_page(page_zone(page), page, order,
-                                       get_pageblock_migratetype(page));
+       migratetype = get_pageblock_migratetype(page);
+       /*
+        * High order page alloc/free is rare compared to
+        * order-0. So this condition check should be not
+        * critical about performance.
+        */
+       if (unlikely(migratetype == MIGRATE_ISOLATE)) {
+               struct zone *zone = page_zone(page);
+               spin_lock(&zone->lock);
+               free_one_isolated_page(zone, page, order);
+               spin_unlock(&zone->lock);
+       }
+       else {
+               free_one_page(page_zone(page), page, order, migratetype);
+       }
        local_irq_restore(flags);
 }
 
@@ -906,6 +945,55 @@ static int fallbacks[MIGRATE_TYPES][4] = {
        [MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
 };
 
+static int hotplug_move_freepages(struct zone *zone,
+                         struct page *start_page, struct page *end_page,
+                         int from_migratetype, int to_migratetype)
+{
+       struct page *page;
+       unsigned long order;
+       int pages_moved = 0;
+
+#ifndef CONFIG_HOLES_IN_ZONE
+       /*
+        * page_zone is not safe to call in this context when
+        * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
+        * anyway as we check zone boundaries in move_freepages_block().
+        * Remove at a later date when no bug reports exist related to
+        * grouping pages by mobility
+        */
+       BUG_ON(page_zone(start_page) != page_zone(end_page));
+#endif
+
+       BUG_ON(from_migratetype == to_migratetype);
+
+       for (page = start_page; page <= end_page;) {
+               /* Make sure we are not inadvertently changing nodes */
+               VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone));
+
+               if (!pfn_valid_within(page_to_pfn(page))) {
+                       page++;
+                       continue;
+               }
+
+               if (!PageBuddy(page)) {
+                       page++;
+                       continue;
+               }
+
+               order = page_order(page);
+               list_move(&page->lru,
+                         &zone->free_area[order].free_list[to_migratetype]);
+               if (to_migratetype == MIGRATE_ISOLATE)
+                       zone->free_area[order].nr_free--;
+               else if (from_migratetype == MIGRATE_ISOLATE)
+                       zone->free_area[order].nr_free++;
+               page += 1 << order;
+               pages_moved += 1 << order;
+       }
+
+       return pages_moved;
+}
+
 /*
  * Move the free pages in a range to the free lists of the requested type.
  * Note that start_page and end_pages are not aligned on a pageblock
@@ -954,6 +1042,32 @@ static int move_freepages(struct zone *zone,
        return pages_moved;
 }
 
+/*
+ * It's almost same with move_freepages_block except [from, to] migratetype.
+ * We need it for accounting zone->free_area[order].nr_free exactly.
+ */
+static int hotplug_move_freepages_block(struct zone *zone, struct page *page,
+                               int from_migratetype, int to_migratetype)
+{
+       unsigned long start_pfn, end_pfn;
+       struct page *start_page, *end_page;
+
+       start_pfn = page_to_pfn(page);
+       start_pfn = start_pfn & ~(pageblock_nr_pages-1);
+       start_page = pfn_to_page(start_pfn);
+       end_page = start_page + pageblock_nr_pages - 1;
+       end_pfn = start_pfn + pageblock_nr_pages - 1;
+
+       /* Do not cross zone boundaries */
+       if (start_pfn < zone->zone_start_pfn)
+               start_page = page;
+       if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
+               return 0;
+
+       return hotplug_move_freepages(zone, start_page, end_page,
+                       from_migratetype, to_migratetype);
+}
+
 static int move_freepages_block(struct zone *zone, struct page *page,
                                int migratetype)
 {
@@ -1311,7 +1425,9 @@ void free_hot_cold_page(struct page *page, int cold)
         */
        if (migratetype >= MIGRATE_PCPTYPES) {
                if (unlikely(migratetype == MIGRATE_ISOLATE)) {
-                       free_one_page(zone, page, 0, migratetype);
+                       spin_lock(&zone->lock);
+                       free_one_isolated_page(zone, page, 0);
+                       spin_unlock(&zone->lock);
                        goto out;
                }
                migratetype = MIGRATE_MOVABLE;
@@ -1388,6 +1504,7 @@ int split_free_page(struct page *page)
        unsigned int order;
        unsigned long watermark;
        struct zone *zone;
+       int migratetype;
 
        BUG_ON(!PageBuddy(page));
 
@@ -1400,10 +1517,17 @@ int split_free_page(struct page *page)
                return 0;
 
        /* Remove page from free list */
+       migratetype = get_pageblock_migratetype(page);
        list_del(&page->lru);
-       zone->free_area[order].nr_free--;
+       /*
+        * Page allocator didn't increase nr_free and NR_FREE_PAGES on pages
+        * which are in free_area[order].free_list[MIGRATE_ISOLATE] pages.
+        */
+       if (migratetype != MIGRATE_ISOLATE) {
+               zone->free_area[order].nr_free--;
+               __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+       }
        rmv_page_order(page);
-       __mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 
        /* Split into individual pages */
        set_page_refcounted(page);
@@ -5593,8 +5717,11 @@ int set_migratetype_isolate(struct page *page)
 
 out:
        if (!ret) {
+               int pages_moved;
                set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-               move_freepages_block(zone, page, MIGRATE_ISOLATE);
+               pages_moved = hotplug_move_freepages_block(zone, page,
+                       MIGRATE_MOVABLE, MIGRATE_ISOLATE);
+               __mod_zone_page_state(zone, NR_FREE_PAGES, -pages_moved);
        }
 
        spin_unlock_irqrestore(&zone->lock, flags);
@@ -5607,12 +5734,15 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
        struct zone *zone;
        unsigned long flags;
+       int pages_moved;
        zone = page_zone(page);
        spin_lock_irqsave(&zone->lock, flags);
        if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
                goto out;
        set_pageblock_migratetype(page, migratetype);
-       move_freepages_block(zone, page, migratetype);
+       pages_moved = hotplug_move_freepages_block(zone, page,
+                                       MIGRATE_ISOLATE, migratetype);
+       __mod_zone_page_state(zone, NR_FREE_PAGES, pages_moved);
 out:
        spin_unlock_irqrestore(&zone->lock, flags);
 }
@@ -5900,9 +6030,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 #endif
                list_del(&page->lru);
                rmv_page_order(page);
-               zone->free_area[order].nr_free--;
-               __mod_zone_page_state(zone, NR_FREE_PAGES,
-                                     - (1UL << order));
                for (i = 0; i < (1 << order); i++)
                        SetPageReserved((page+i));
                pfn += (1 << order);






-- 
Kind regards,
Minchan Kim

--------------000707090707070002060305
Content-Type: text/x-patch;
 name="patch.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="patch.patch"

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4403009..d2a515d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -676,6 +676,24 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 	spin_unlock(&zone->lock);
 }
 
+/*
+ * This function is almost same with free_one_page except that it
+ * doesn't increase NR_FREE_PAGES and free_area[order].nr_free.
+ * Because page allocator can't allocate MIGRATE_ISOLATE type page.
+ *
+ * Caller should hold zone->lock.
+ */
+static void free_one_isolated_page(struct zone *zone, struct page *page,
+				int order)
+{
+	zone->all_unreclaimable = 0;
+	zone->pages_scanned = 0;
+
+	__free_one_page(page, zone, order, MIGRATE_ISOLATE);
+	/* rollback nr_free increased by __free_one_page */
+	zone->free_area[order].nr_free--;
+}
+
 static void free_one_page(struct zone *zone, struct page *page, int order,
 				int migratetype)
 {
@@ -683,6 +701,13 @@ static void free_one_page(struct zone *zone, struct page *page, int order,
 	zone->all_unreclaimable = 0;
 	zone->pages_scanned = 0;
 
+	/*
+	 * Freed MIGRATE_ISOLATE page should be free_one_isolated_page path
+	 * because page allocator don't want to increase NR_FREE_PAGES and
+	 * free_area[order].nr_free.
+	 */
+	VM_BUG_ON(migratetype == MIGRATE_ISOLATE);
+
 	__free_one_page(page, zone, order, migratetype);
 	__mod_zone_page_state(zone, NR_FREE_PAGES, 1 << order);
 	spin_unlock(&zone->lock);
@@ -718,6 +743,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 {
 	unsigned long flags;
 	int wasMlocked = __TestClearPageMlocked(page);
+	int migratetype;
 
 	if (!free_pages_prepare(page, order))
 		return;
@@ -726,8 +752,21 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	if (unlikely(wasMlocked))
 		free_page_mlock(page);
 	__count_vm_events(PGFREE, 1 << order);
-	free_one_page(page_zone(page), page, order,
-					get_pageblock_migratetype(page));
+	migratetype = get_pageblock_migratetype(page);
+	/*
+	 * High order page alloc/free is rare compared to
+	 * order-0. So this condition check should be not
+	 * critical about performance.
+	 */
+	if (unlikely(migratetype == MIGRATE_ISOLATE)) {
+		struct zone *zone = page_zone(page);
+		spin_lock(&zone->lock);
+		free_one_isolated_page(zone, page, order);
+		spin_unlock(&zone->lock);
+	}
+	else {
+		free_one_page(page_zone(page), page, order, migratetype);
+	}
 	local_irq_restore(flags);
 }
 
@@ -906,6 +945,55 @@ static int fallbacks[MIGRATE_TYPES][4] = {
 	[MIGRATE_ISOLATE]     = { MIGRATE_RESERVE }, /* Never used */
 };
 
+static int hotplug_move_freepages(struct zone *zone,
+			  struct page *start_page, struct page *end_page,
+			  int from_migratetype, int to_migratetype)
+{
+	struct page *page;
+	unsigned long order;
+	int pages_moved = 0;
+
+#ifndef CONFIG_HOLES_IN_ZONE
+	/*
+	 * page_zone is not safe to call in this context when
+	 * CONFIG_HOLES_IN_ZONE is set. This bug check is probably redundant
+	 * anyway as we check zone boundaries in move_freepages_block().
+	 * Remove at a later date when no bug reports exist related to
+	 * grouping pages by mobility
+	 */
+	BUG_ON(page_zone(start_page) != page_zone(end_page));
+#endif
+
+	BUG_ON(from_migratetype == to_migratetype);
+
+	for (page = start_page; page <= end_page;) {
+		/* Make sure we are not inadvertently changing nodes */
+		VM_BUG_ON(page_to_nid(page) != zone_to_nid(zone));
+
+		if (!pfn_valid_within(page_to_pfn(page))) {
+			page++;
+			continue;
+		}
+
+		if (!PageBuddy(page)) {
+			page++;
+			continue;
+		}
+
+		order = page_order(page);
+		list_move(&page->lru,
+			  &zone->free_area[order].free_list[to_migratetype]);
+		if (to_migratetype == MIGRATE_ISOLATE)
+			zone->free_area[order].nr_free--;
+		else if (from_migratetype == MIGRATE_ISOLATE)
+			zone->free_area[order].nr_free++;
+		page += 1 << order;
+		pages_moved += 1 << order;
+	}
+
+	return pages_moved;
+}
+
 /*
  * Move the free pages in a range to the free lists of the requested type.
  * Note that start_page and end_pages are not aligned on a pageblock
@@ -954,6 +1042,32 @@ static int move_freepages(struct zone *zone,
 	return pages_moved;
 }
 
+/*
+ * It's almost same with move_freepages_block except [from, to] migratetype.
+ * We need it for accounting zone->free_area[order].nr_free exactly.
+ */
+static int hotplug_move_freepages_block(struct zone *zone, struct page *page,
+				int from_migratetype, int to_migratetype)
+{
+	unsigned long start_pfn, end_pfn;
+	struct page *start_page, *end_page;
+
+	start_pfn = page_to_pfn(page);
+	start_pfn = start_pfn & ~(pageblock_nr_pages-1);
+	start_page = pfn_to_page(start_pfn);
+	end_page = start_page + pageblock_nr_pages - 1;
+	end_pfn = start_pfn + pageblock_nr_pages - 1;
+
+	/* Do not cross zone boundaries */
+	if (start_pfn < zone->zone_start_pfn)
+		start_page = page;
+	if (end_pfn >= zone->zone_start_pfn + zone->spanned_pages)
+		return 0;
+
+	return hotplug_move_freepages(zone, start_page, end_page,
+			from_migratetype, to_migratetype);
+}
+
 static int move_freepages_block(struct zone *zone, struct page *page,
 				int migratetype)
 {
@@ -1311,7 +1425,9 @@ void free_hot_cold_page(struct page *page, int cold)
 	 */
 	if (migratetype >= MIGRATE_PCPTYPES) {
 		if (unlikely(migratetype == MIGRATE_ISOLATE)) {
-			free_one_page(zone, page, 0, migratetype);
+			spin_lock(&zone->lock);
+			free_one_isolated_page(zone, page, 0);
+			spin_unlock(&zone->lock);
 			goto out;
 		}
 		migratetype = MIGRATE_MOVABLE;
@@ -1388,6 +1504,7 @@ int split_free_page(struct page *page)
 	unsigned int order;
 	unsigned long watermark;
 	struct zone *zone;
+	int migratetype;
 
 	BUG_ON(!PageBuddy(page));
 
@@ -1400,10 +1517,17 @@ int split_free_page(struct page *page)
 		return 0;
 
 	/* Remove page from free list */
+	migratetype = get_pageblock_migratetype(page);
 	list_del(&page->lru);
-	zone->free_area[order].nr_free--;
+	/*
+	 * Page allocator didn't increase nr_free and NR_FREE_PAGES on pages
+	 * which are in free_area[order].free_list[MIGRATE_ISOLATE] pages.
+	 */
+	if (migratetype != MIGRATE_ISOLATE) {
+		zone->free_area[order].nr_free--;
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
+	}
 	rmv_page_order(page);
-	__mod_zone_page_state(zone, NR_FREE_PAGES, -(1UL << order));
 
 	/* Split into individual pages */
 	set_page_refcounted(page);
@@ -5593,8 +5717,11 @@ int set_migratetype_isolate(struct page *page)
 
 out:
 	if (!ret) {
+		int pages_moved;
 		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
-		move_freepages_block(zone, page, MIGRATE_ISOLATE);
+		pages_moved = hotplug_move_freepages_block(zone, page,
+			MIGRATE_MOVABLE, MIGRATE_ISOLATE);
+		__mod_zone_page_state(zone, NR_FREE_PAGES, -pages_moved);
 	}
 
 	spin_unlock_irqrestore(&zone->lock, flags);
@@ -5607,12 +5734,15 @@ void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 {
 	struct zone *zone;
 	unsigned long flags;
+	int pages_moved;
 	zone = page_zone(page);
 	spin_lock_irqsave(&zone->lock, flags);
 	if (get_pageblock_migratetype(page) != MIGRATE_ISOLATE)
 		goto out;
 	set_pageblock_migratetype(page, migratetype);
-	move_freepages_block(zone, page, migratetype);
+	pages_moved = hotplug_move_freepages_block(zone, page,
+					MIGRATE_ISOLATE, migratetype);
+	__mod_zone_page_state(zone, NR_FREE_PAGES, pages_moved);
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 }
@@ -5900,9 +6030,6 @@ __offline_isolated_pages(unsigned long start_pfn, unsigned long end_pfn)
 #endif
 		list_del(&page->lru);
 		rmv_page_order(page);
-		zone->free_area[order].nr_free--;
-		__mod_zone_page_state(zone, NR_FREE_PAGES,
-				      - (1UL << order));
 		for (i = 0; i < (1 << order); i++)
 			SetPageReserved((page+i));
 		pfn += (1 << order);

--------------000707090707070002060305--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
