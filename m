Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 78CC86B0068
	for <linux-mm@kvack.org>; Mon,  4 Jun 2012 09:38:48 -0400 (EDT)
Received: from euspt1 (mailout4.w1.samsung.com [210.118.77.14])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0M530068DHXSLH10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 14:39:28 +0100 (BST)
Received: from linux.samsung.com ([106.116.38.10])
 by spt1.w1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14
 2004)) with ESMTPA id <0M5300JI5HWLIS@spt1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 04 Jun 2012 14:38:46 +0100 (BST)
Date: Mon, 04 Jun 2012 15:37:30 +0200
From: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>
Subject: Re: WARNING: at mm/page-writeback.c:1990
 __set_page_dirty_nobuffers+0x13a/0x170()
In-reply-to: <4FCC1D68.8060406@kernel.org>
Message-id: <201206041537.30787.b.zolnierkie@samsung.com>
MIME-version: 1.0
Content-type: Text/Plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
References: <20120530163317.GA13189@redhat.com>
 <alpine.LSU.2.00.1206031820520.5143@eggly.anvils> <4FCC1D68.8060406@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Cong Wang <amwang@redhat.com>, Markus Trippelsdorf <markus@trippelsdorf.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


Hi,

On Monday 04 June 2012 04:28:56 Minchan Kim wrote:
> On 06/04/2012 10:41 AM, Hugh Dickins wrote:
> 
> > On Mon, 4 Jun 2012, Minchan Kim wrote:
> >> On 06/02/2012 01:40 PM, Hugh Dickins wrote:
> >>
> >>> On Fri, 1 Jun 2012, Linus Torvalds wrote:
> >>>> On Fri, Jun 1, 2012 at 3:17 PM, Hugh Dickins <hughd@google.com> wrote:
> >>>>>
> >>>>> +       spin_lock_irqsave(&zone->lock, flags);
> >>>>>        for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
> >>>>>                                                                  page++) {
> >>>>
> >>>> So holding the spinlock (and disabling irqs!) over the whole loop
> >>>> sounds horrible.
> >>>
> >>> There looks to be a pretty similar loop inside move_freepages_block(),
> >>> which is the part which I believe really needs the lock - it's moving
> >>> free pages from one lru to another.
> >>>
> >>>>
> >>>> At the same time, the iterators don't seem to require the spinlock, so
> >>>> it should be possible to just move the lock into the loop, no?
> >>>
> >>> Move the lock after the loop, I think you meant.
> >>>
> >>> I put the lock before the loop because it's deciding whether it can
> >>> usefully proceed, and then proceeding: I was thinking that the lock
> >>> would stabilize the conditions that it bases that decision on.
> >>
> >>
> >> We do it with two phase.
> >> In first phase, we don't need lock because we don't need to be exact.
> >> In second phase where move pages really, we need a lock so we already hold it.
> > 
> > No, see Linus's point elsewhere in this thread.
> > 
> > To spell it out further, page_order(page) uses page_private(page),
> > and you've no idea what someone might put into page_private(page)
> > once it's no longer PageBuddy but perhaps allocated to a user.
> > 
> > So the unlocked advancment by page_order(page) may even take you
> > way out of this or any pageblock.
> > 
> > Linus was suggesting to take and drop the lock around that little
> > block each time.  Maybe.  I'm wary, I don't pretend to have thought
> > it through (nor shall further).
> 
> 
> Right.
> I got confused because suitable_migration_target did rescure_unmovable_pageblock. I don't want it.
>  I hope separating test which does just check whether it's migratable or not and working
> which really does rescue.
> So I think it would be better following as.
> 
> if (!suitable_migration_target())
> 	continue;
> 
> spin_lock_irqsave(&zone->lock, flags);
> if (ret = suitable_migration_target()) {
> 	if (ret == CAN_MAKE_MOVABLE_PAGE_BLOCK)
> 		rescure_unmoable_pageblock()
> 	isolate_freepages_block();
> }
> 
> > 
> >>
> >> ret = suitable_migration_target(page, cc);
> >> ..
> >> ..
> >> spin_lock_irqsave(&zone->lock, flags);
> >> ret = suitable_migration_target(page, cc); 
> >>
> >> So you shouldn't put the lock in loop.
> >>
> >>>
> >>> But it certainly does not stabilize all of them (most obviously not
> >>> PageLRU), so I'm guesssing that this is a best-effort decision which
> >>
> >>> can safely go wrong some of the time.
> >>
> >> Right.
> >>
> >>>
> >>> In which case, yes, much better to follow your suggestion, and hold
> >>> the lock (with irqs disabled) for only half the time.
> >>>
> >>> Similarly untested patch below.
> >>>
> >>> But I'm entirely unfamiliar with this code: best Cc people more familiar
> >>> with it.  Does this addition of locking to rescue_unmovable_pageblock()
> >>> look correct to you, and do you think it has a good chance of fixing the
> >>
> >>
> >> No.I think we need to use start_page instead of page and
> > 
> > I thought so, but Linus points out why not (pfn_valid_within).
> > 
> >> we need a last page of page block to check cross-over zones,
> >> not first page in next page block.
> > 
> > Yes, that's the off-by-one I was alluding to.
> > 
> >>
> >> I should have reviewed more carefully. :(
> >>
> >> barrios@bbox:~/linux-2.6$ git diff
> >> diff --git a/mm/compaction.c b/mm/compaction.c
> >> index 4ac338a..b3fcc4b 100644
> >> --- a/mm/compaction.c
> >> +++ b/mm/compaction.c
> >> @@ -372,7 +372,7 @@ static bool rescue_unmovable_pageblock(struct page *page)
> >>  
> >>         pfn = page_to_pfn(page);
> >>         start_pfn = pfn & ~(pageblock_nr_pages - 1);
> >> -       end_pfn = start_pfn + pageblock_nr_pages;
> >> +       end_pfn = start_pfn + pageblock_nr_pages - 1;
> > 
> > Yes.
> > 
> >>  
> >>         start_page = pfn_to_page(start_pfn);
> >>         end_page = pfn_to_page(end_pfn);
> >> @@ -381,7 +381,7 @@ static bool rescue_unmovable_pageblock(struct page *page)
> >>         if (page_zone(start_page) != page_zone(end_page))
> >>                 return false;
> >>  
> >> -       for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
> >> +       for (page = start_page, pfn = start_pfn; page <= end_page; pfn++,
> >>                                                                   page++) {
> > 
> > Yes.
> > 
> >>                 if (!pfn_valid_within(pfn))
> >>                         continue;
> >> @@ -399,8 +399,8 @@ static bool rescue_unmovable_pageblock(struct page *page)
> >>                 return false;
> >>         }
> >>  
> >> -       set_pageblock_migratetype(page, MIGRATE_MOVABLE);
> >> -       move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
> >> +       set_pageblock_migratetype(start_page, MIGRATE_MOVABLE);
> >> +       move_freepages_block(page_zone(start_page), start_page, MIGRATE_MOVABLE);
> > 
> > No.  I guess we can assume the incoming page was valid (fair?),
> > so should still use that, but something else for the loop iterator.
> 
> 
> It should be fair. I did it in following mail.
> 
> > 
> > And you seem to have missed out all the locking needed.
> > 
> >>         return true;
> >>  }
> > 
> > So Nack to that on several grounds.
> > 
> > And I'd like to hear evidence that this really is useful code,
> > justifying the locking and interrupt-disabling which would have to
> > be added.  My 0 out of 25000 was not reassuring.  Nor the original
> > test results, when it was doing completely the wrong thing unnoticed.
> 
> 
> In changelog, Bartlomiej said.
> 
>     My particular test case (on a ARM EXYNOS4 device with 512 MiB, which means
>     131072 standard 4KiB pages in 'Normal' zone) is to:
>     
>     - allocate 120000 pages for kernel's usage
>     - free every second page (60000 pages) of memory just allocated
>     - allocate and use 60000 pages from user space
>     - free remaining 60000 pages of kernel memory
>       (now we have fragmented memory occupied mostly by user space pages)
>     - try to allocate 100 order-9 (2048 KiB) pages for kernel's usage
>     
>     The results:
>     - with compaction disabled I get 11 successful allocations
>     - with compaction enabled - 14 successful allocations
>     - with this patch I'm able to get all 100 successful allocations
> 
> I think above workload is really really artificial and theoretical so I didn't like
> this patch but Mel seem to like it. :(
> 
> Quote from Mel
> " Ok, that is indeed an adverse workload that the current system will not
> properly deal with. I think you are right to try fixing this but may need
> a different approach that takes the cost out of the allocation/free path
> and moves it the compaction path."

Please note that the current patch is less intrusive than the original
version that Mel was talking about in the above quote (the cost is only in
compaction path which is non-default one and in a allocation slow-path).

> We can correct this patch to work but at least need justification about it.
> Do we really need this patch for such artificial workload?
> what do you think?

I would still like to get this patch included since it helps with my
test-case and is not very much code / complexity added.  So far I fixed
(all?) outstanding issues in the patch attached below and will post
the next combined version (v9) of the patch in the new thread.

Best regards,
--
Bartlomiej Zolnierkiewicz
Samsung Poland R&D Center


- use right page for pageblock conversion in rescue_unmovable_pageblock()
- split rescue_unmovable_pageblock() on can_rescue_unmovable_pageblock()
  and __rescue_unmovable_pageblock()
- add missing locking

---
 mm/compaction.c |   66 ++++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 45 insertions(+), 21 deletions(-)

Index: b/mm/compaction.c
===================================================================
--- a/mm/compaction.c	2012-06-04 15:19:04.564467996 +0200
+++ b/mm/compaction.c	2012-06-04 15:19:15.700467901 +0200
@@ -362,50 +362,70 @@ isolate_migratepages_range(struct zone *
 #endif /* CONFIG_COMPACTION || CONFIG_CMA */
 #ifdef CONFIG_COMPACTION
 /*
- * Returns true if MIGRATE_UNMOVABLE pageblock was successfully
+ * Returns true if MIGRATE_UNMOVABLE pageblock can be successfully
  * converted to MIGRATE_MOVABLE type, false otherwise.
  */
-static bool rescue_unmovable_pageblock(struct page *page)
+static bool can_rescue_unmovable_pageblock(struct page *page, bool locked)
 {
 	unsigned long pfn, start_pfn, end_pfn;
-	struct page *start_page, *end_page;
+	struct page *start_page, *end_page, *cursor_page;
 
 	pfn = page_to_pfn(page);
 	start_pfn = pfn & ~(pageblock_nr_pages - 1);
-	end_pfn = start_pfn + pageblock_nr_pages;
+	end_pfn = start_pfn + pageblock_nr_pages - 1;
 
 	start_page = pfn_to_page(start_pfn);
 	end_page = pfn_to_page(end_pfn);
 
-	/* Do not deal with pageblocks that overlap zones */
-	if (page_zone(start_page) != page_zone(end_page))
-		return false;
+	for (cursor_page = start_page, pfn = start_pfn; cursor_page <= end_page;
+		pfn++, cursor_page++) {
+		struct zone *zone = page_zone(start_page);
+		unsigned long flags;
 
-	for (page = start_page, pfn = start_pfn; page < end_page; pfn++,
-								  page++) {
 		if (!pfn_valid_within(pfn))
 			continue;
 
-		if (PageBuddy(page)) {
-			int order = page_order(page);
+		/* Do not deal with pageblocks that overlap zones */
+		if (page_zone(cursor_page) != zone)
+			return false;
+
+		if (!locked)
+			spin_lock_irqsave(&zone->lock, flags);
+
+		if (PageBuddy(cursor_page)) {
+			int order = page_order(cursor_page);
 
 			pfn += (1 << order) - 1;
-			page += (1 << order) - 1;
+			cursor_page += (1 << order) - 1;
 
+			if (!locked)
+				spin_unlock_irqrestore(&zone->lock, flags);
 			continue;
-		} else if (page_count(page) == 0 || PageLRU(page))
+		} else if (page_count(cursor_page) == 0 ||
+			   PageLRU(cursor_page)) {
+			if (!locked)
+				spin_unlock_irqrestore(&zone->lock, flags);
 			continue;
+		}
+
+		if (!locked)
+			spin_unlock_irqrestore(&zone->lock, flags);
 
 		return false;
 	}
 
+	return true;
+}
+
+void __rescue_unmovable_pageblock(struct page *page)
+{
 	set_pageblock_migratetype(page, MIGRATE_MOVABLE);
 	move_freepages_block(page_zone(page), page, MIGRATE_MOVABLE);
-	return true;
 }
 
 enum smt_result {
 	GOOD_AS_MIGRATION_TARGET,
+	GOOD_CAN_RESCUE_UNMOVABLE_TARGET,
 	FAIL_UNMOVABLE_TARGET,
 	FAIL_BAD_TARGET,
 };
@@ -416,7 +436,7 @@ enum smt_result {
  * is within a MIGRATE_UNMOVABLE block, FAIL_BAD_TARGET otherwise.
  */
 static enum smt_result suitable_migration_target(struct page *page,
-				      struct compact_control *cc)
+				      struct compact_control *cc, bool locked)
 {
 
 	int migratetype = get_pageblock_migratetype(page);
@@ -440,8 +460,8 @@ static enum smt_result suitable_migratio
 
 	if (cc->mode != COMPACT_ASYNC_MOVABLE &&
 	    migratetype == MIGRATE_UNMOVABLE &&
-	    rescue_unmovable_pageblock(page))
-		return GOOD_AS_MIGRATION_TARGET;
+	    can_rescue_unmovable_pageblock(page, locked))
+		return GOOD_CAN_RESCUE_UNMOVABLE_TARGET;
 
 	/* Otherwise skip the block */
 	return FAIL_BAD_TARGET;
@@ -509,8 +529,9 @@ static void isolate_freepages(struct zon
 			continue;
 
 		/* Check the block is suitable for migration */
-		ret = suitable_migration_target(page, cc);
-		if (ret != GOOD_AS_MIGRATION_TARGET) {
+		ret = suitable_migration_target(page, cc, false);
+		if (ret != GOOD_AS_MIGRATION_TARGET &&
+		    ret != GOOD_CAN_RESCUE_UNMOVABLE_TARGET) {
 			if (ret == FAIL_UNMOVABLE_TARGET)
 				cc->nr_pageblocks_skipped++;
 			continue;
@@ -523,8 +544,11 @@ static void isolate_freepages(struct zon
 		 */
 		isolated = 0;
 		spin_lock_irqsave(&zone->lock, flags);
-		ret = suitable_migration_target(page, cc);
-		if (ret == GOOD_AS_MIGRATION_TARGET) {
+		ret = suitable_migration_target(page, cc, true);
+		if (ret == GOOD_AS_MIGRATION_TARGET ||
+		    ret == GOOD_CAN_RESCUE_UNMOVABLE_TARGET) {
+			if (ret == GOOD_CAN_RESCUE_UNMOVABLE_TARGET)
+				__rescue_unmovable_pageblock(page);
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
 			isolated = isolate_freepages_block(pfn, end_pfn,
 							   freelist, false);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
