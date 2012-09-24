Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 89EB96B002B
	for <linux-mm@kvack.org>; Mon, 24 Sep 2012 04:52:44 -0400 (EDT)
Date: Mon, 24 Sep 2012 09:52:38 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/9] mm: compaction: Acquire the zone->lock as late as
 possible
Message-ID: <20120924085238.GY11266@suse.de>
References: <1348224383-1499-1-git-send-email-mgorman@suse.de>
 <1348224383-1499-7-git-send-email-mgorman@suse.de>
 <20120921143557.fe490819.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120921143557.fe490819.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Richard Davies <richard@arachsys.com>, Shaohua Li <shli@kernel.org>, Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, QEMU-devel <qemu-devel@nongnu.org>, KVM <kvm@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Sep 21, 2012 at 02:35:57PM -0700, Andrew Morton wrote:
> On Fri, 21 Sep 2012 11:46:20 +0100
> Mel Gorman <mgorman@suse.de> wrote:
> 
> > Compactions free scanner acquires the zone->lock when checking for PageBuddy
> > pages and isolating them. It does this even if there are no PageBuddy pages
> > in the range.
> > 
> > This patch defers acquiring the zone lock for as long as possible. In the
> > event there are no free pages in the pageblock then the lock will not be
> > acquired at all which reduces contention on zone->lock.
> >
> > ...
> >
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -93,6 +93,28 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
> >  	return compact_checklock_irqsave(lock, flags, false, cc);
> >  }
> >  
> > +/* Returns true if the page is within a block suitable for migration to */
> > +static bool suitable_migration_target(struct page *page)
> > +{
> > +
> 
> stray newline
> 

Fixed.

> > +	int migratetype = get_pageblock_migratetype(page);
> > +
> > +	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
> > +	if (migratetype == MIGRATE_ISOLATE || migratetype == MIGRATE_RESERVE)
> > +		return false;
> > +
> > +	/* If the page is a large free page, then allow migration */
> > +	if (PageBuddy(page) && page_order(page) >= pageblock_order)
> > +		return true;
> > +
> > +	/* If the block is MIGRATE_MOVABLE or MIGRATE_CMA, allow migration */
> > +	if (migrate_async_suitable(migratetype))
> > +		return true;
> > +
> > +	/* Otherwise skip the block */
> > +	return false;
> > +}
> > +
> >
> > ...
> >
> > @@ -168,23 +193,38 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
> >  		int isolated, i;
> >  		struct page *page = cursor;
> >  
> > -		if (!pfn_valid_within(blockpfn)) {
> > -			if (strict)
> > -				return 0;
> > -			continue;
> > -		}
> > +		if (!pfn_valid_within(blockpfn))
> > +			goto strict_check;
> >  		nr_scanned++;
> >  
> > -		if (!PageBuddy(page)) {
> > -			if (strict)
> > -				return 0;
> > -			continue;
> > -		}
> > +		if (!PageBuddy(page))
> > +			goto strict_check;
> > +
> > +		/*
> > +		 * The zone lock must be held to isolate freepages. This
> > +		 * unfortunately this is a very coarse lock and can be
> 
> this this
> 

Fixed.

> > +		 * heavily contended if there are parallel allocations
> > +		 * or parallel compactions. For async compaction do not
> > +		 * spin on the lock and we acquire the lock as late as
> > +		 * possible.
> > +		 */
> > +		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
> > +								locked, cc);
> > +		if (!locked)
> > +			break;
> > +
> > +		/* Recheck this is a suitable migration target under lock */
> > +		if (!strict && !suitable_migration_target(page))
> > +			break;
> > +
> > +		/* Recheck this is a buddy page under lock */
> > +		if (!PageBuddy(page))
> > +			goto strict_check;
> >  
> >  		/* Found a free page, break it into order-0 pages */
> >  		isolated = split_free_page(page);
> >  		if (!isolated && strict)
> > -			return 0;
> > +			goto strict_check;
> >  		total_isolated += isolated;
> >  		for (i = 0; i < isolated; i++) {
> >  			list_add(&page->lru, freelist);
> > @@ -196,9 +236,23 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
> >  			blockpfn += isolated - 1;
> >  			cursor += isolated - 1;
> >  		}
> > +
> > +		continue;
> > +
> > +strict_check:
> > +		/* Abort isolation if the caller requested strict isolation */
> > +		if (strict) {
> > +			total_isolated = 0;
> > +			goto out;
> > +		}
> >  	}
> >  
> >  	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
> > +
> > +out:
> > +	if (locked)
> > +		spin_unlock_irqrestore(&cc->zone->lock, flags);
> > +
> >  	return total_isolated;
> >  }
> 
> A a few things about this function.
> 
> Would it be cleaner if we did
> 
> 	if (!strict) {
> 		if (!suitable_migration_target(page))
> 			break;
> 	} else {
> 		if (!PageBuddy(page))
> 			goto strict_check;
> 	}
> 
> and then remove the test of `strict' from strict_check (which then
> should be renamed)?
> 

I was not able to implement what you suggested without breakage.
However, I can do something very similar if "strict" mode does not bail
out ASAP and instead double checks at the end that everything was
isolated correctly. This does mean that CMAs failure case is slightly
more expensive but that really is a corner case and I think it's
acceptable if the code is easier to follow as a result.

> Which perhaps means that the whole `strict_check' block can go away:
> 
> 	if (!strict) {
> 		if (!suitable_migration_target(page))
> 			break;
> 	} else {
> 		if (!PageBuddy(page)) {
> 			total_isolated = 0;
> 			goto out;
> 	}
> 
> Have a think about it?  The function is a little straggly.
> 

Proposal below.

> Secondly, it is correct/desirable to skip the (now misnamed
> `trace_mm_compaction_isolate_freepages') tracepoint generation if we
> baled out of the loop?  The fact that we entered
> isolate_freepages_block() but failed to isolate anything is data which
> people might be interested in?
> 

You're right, it may be interesting for someone debugging CMA to know that
nr_scanned != nr_isolated at the time of allocation failure. 

> Thirdly, that (existing) comment "This assumes the block is valid" is
> either too vague or wrong.  If it's valid, why wo we check
> pfn_valid_within()?
> 

Comment is stale and should be removed.

> > @@ -218,13 +272,18 @@ static unsigned long isolate_freepages_block(unsigned long blockpfn,
> >  unsigned long
> >  isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
> >  {
> > -	unsigned long isolated, pfn, block_end_pfn, flags;
> > +	unsigned long isolated, pfn, block_end_pfn;
> >  	struct zone *zone = NULL;
> >  	LIST_HEAD(freelist);
> > +	struct compact_control cc;
> >  
> >  	if (pfn_valid(start_pfn))
> >  		zone = page_zone(pfn_to_page(start_pfn));
> >  
> > +	/* cc needed for isolate_freepages_block to acquire zone->lock */
> > +	cc.zone = zone;
> > +	cc.sync = true;
> 
> We initialise two of cc's fields, leave the other 12 fields containing
> random garbage, then start using it.  I see no bug here, but...
> 

I get your point. At the very least we should initialise it with zeros.

How about this?

---8<---
mm: compaction: Iron out isolate_freepages_block() and isolate_freepages_range()

Andrew pointed out that isolate_freepages_block() is "straggly" and
isolate_freepages_range() is making assumptions on how compact_control is
used which is delicate. This patch straightens isolate_freepages_block()
and makes it fly straight and initialses compact_control to zeros in
isolate_freepages_range(). The code should be easier to follow and
is functionally equivalent. The CMA failure path is now a little more
expensive but that is a marginal corner-case.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   47 ++++++++++++++++++++++-------------------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 9276bc8..5ffe9a5 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -154,7 +154,6 @@ static inline bool compact_trylock_irqsave(spinlock_t *lock,
 /* Returns true if the page is within a block suitable for migration to */
 static bool suitable_migration_target(struct page *page)
 {
-
 	int migratetype = get_pageblock_migratetype(page);
 
 	/* Don't interfere with memory hot-remove or the min_free_kbytes blocks */
@@ -246,23 +245,23 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 	cursor = pfn_to_page(blockpfn);
 
-	/* Isolate free pages. This assumes the block is valid */
+	/* Isolate free pages. */
 	for (; blockpfn < end_pfn; blockpfn++, cursor++) {
 		int isolated, i;
 		struct page *page = cursor;
 
-		if (!pfn_valid_within(blockpfn))
-			goto strict_check;
 		nr_scanned++;
+		if (!pfn_valid_within(blockpfn))
+			continue;
 		if (!valid_page)
 			valid_page = page;
 
 		if (!PageBuddy(page))
-			goto strict_check;
+			continue;
 
 		/*
-		 * The zone lock must be held to isolate freepages. This
-		 * unfortunately this is a very coarse lock and can be
+		 * The zone lock must be held to isolate freepages.
+		 * Unfortunately this is a very coarse lock and can be
 		 * heavily contended if there are parallel allocations
 		 * or parallel compactions. For async compaction do not
 		 * spin on the lock and we acquire the lock as late as
@@ -279,12 +278,12 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 
 		/* Recheck this is a buddy page under lock */
 		if (!PageBuddy(page))
-			goto strict_check;
+			continue;
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
 		if (!isolated && strict)
-			goto strict_check;
+			break;
 		total_isolated += isolated;
 		for (i = 0; i < isolated; i++) {
 			list_add(&page->lru, freelist);
@@ -296,20 +295,18 @@ static unsigned long isolate_freepages_block(struct compact_control *cc,
 			blockpfn += isolated - 1;
 			cursor += isolated - 1;
 		}
-
-		continue;
-
-strict_check:
-		/* Abort isolation if the caller requested strict isolation */
-		if (strict) {
-			total_isolated = 0;
-			goto out;
-		}
 	}
 
 	trace_mm_compaction_isolate_freepages(nr_scanned, total_isolated);
 
-out:
+	/*
+	 * If strict isolation is requested by CMA then check that all the
+	 * pages scanned were isolated. If there were any failures, 0 is
+	 * returned and CMA will fail.
+	 */
+	if (strict && nr_scanned != total_isolated)
+		total_isolated = 0;
+
 	if (locked)
 		spin_unlock_irqrestore(&cc->zone->lock, flags);
 
@@ -339,14 +336,14 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 	unsigned long isolated, pfn, block_end_pfn;
 	struct zone *zone = NULL;
 	LIST_HEAD(freelist);
-	struct compact_control cc;
-
-	if (pfn_valid(start_pfn))
-		zone = page_zone(pfn_to_page(start_pfn));
 
 	/* cc needed for isolate_freepages_block to acquire zone->lock */
-	cc.zone = zone;
-	cc.sync = true;
+	struct compact_control cc = {
+		.sync = true,
+	};
+
+	if (pfn_valid(start_pfn))
+		cc.zone = zone = page_zone(pfn_to_page(start_pfn));
 
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
 		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
