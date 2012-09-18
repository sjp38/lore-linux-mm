Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id BDD826B0081
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 07:21:27 -0400 (EDT)
Date: Tue, 18 Sep 2012 12:21:22 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120918112122.GM11266@suse.de>
References: <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
 <20120913154824.44cc0e28@cuia.bos.redhat.com>
 <20120913155450.7634148f@cuia.bos.redhat.com>
 <20120915155524.GA24182@alpha.arachsys.com>
 <20120917122628.GF11266@suse.de>
 <20120918081455.GA16395@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120918081455.GA16395@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

On Tue, Sep 18, 2012 at 09:14:55AM +0100, Richard Davies wrote:
> Hi Mel,
> 
> Thanks for your latest patch, I attach a perf report below with this on top
> of all previous patches. There is still lock contention, though in a
> different place.
> 
>     59.97%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
>                    |
>                    --- _raw_spin_lock_irqsave
>                       |          
>                       |--99.30%-- compact_checklock_irqsave
>                       |          |          
>                       |          |--99.98%-- compaction_alloc

Ok, this just means the focus has moved to the zone->lock instead of the
zone->lru_lock. This was expected to some extent. This is an additional
patch that defers acquisition of the zone->lock for as long as possible.

Incidentally, I checked the efficiency of compaction - i.e. how many
pages scanned versus how many pages isolated and the efficiency
completely sucks. It must be addressed but addressing the lock
contention should happen first.

---8<---
mm: compaction: Acquire the zone->lock as late as possible

The zone lock is required when isolating pages to allocate and for checking
PageBuddy. It is a coarse-grained lock but the current implementation
acquires the lock when examining each pageblock before it is known if there
are free pages to isolate. This patch defers acquiring the zone lock for
as long as possible. In the event there are no free pages in the pageblock
then the lock will not be acquired at all.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   80 ++++++++++++++++++++++++++++++++-----------------------
 1 file changed, 47 insertions(+), 33 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index a5d698f..57ff9ef 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -89,19 +89,14 @@ static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 	return true;
 }
 
-static inline bool compact_trylock_irqsave(spinlock_t *lock,
-			unsigned long *flags, struct compact_control *cc)
-{
-	return compact_checklock_irqsave(lock, flags, false, cc);
-}
-
 /*
  * Isolate free pages onto a private freelist. Caller must hold zone->lock.
  * If @strict is true, will abort returning 0 on any invalid PFNs or non-free
  * pages inside of the pageblock (even though it may still end up isolating
  * some pages).
  */
-static unsigned long isolate_freepages_block(unsigned long start_pfn,
+static unsigned long isolate_freepages_block(struct compact_control *cc,
+				unsigned long start_pfn,
 				unsigned long end_pfn,
 				struct list_head *freelist,
 				bool strict)
@@ -109,6 +104,8 @@ static unsigned long isolate_freepages_block(unsigned long start_pfn,
 	int nr_scanned = 0, total_isolated = 0;
 	unsigned long blockpfn = start_pfn;
 	struct page *cursor;
+	unsigned long flags;
+	bool locked = false;
 
 	cursor = pfn_to_page(blockpfn);
 
@@ -117,18 +114,29 @@ static unsigned long isolate_freepages_block(unsigned long start_pfn,
 		int isolated, i;
 		struct page *page = cursor;
 
-		if (!pfn_valid_within(blockpfn)) {
-			if (strict)
-				return 0;
-			continue;
-		}
+		if (!pfn_valid_within(blockpfn))
+			goto strict_check;
 		nr_scanned++;
 
-		if (!PageBuddy(page)) {
-			if (strict)
-				return 0;
-			continue;
-		}
+		if (!PageBuddy(page))
+			goto strict_check;
+
+		/*
+		 * The zone lock must be held to isolate freepages. This
+		 * unfortunately this is a very coarse lock and can be
+		 * heavily contended if there are parallel allocations
+		 * or parallel compactions. For async compaction do not
+		 * spin on the lock and we acquire the lock as late as
+		 * possible.
+		 */
+		locked = compact_checklock_irqsave(&cc->zone->lock, &flags,
+								locked, cc);
+		if (!locked)
+			break;
+
+		/* Recheck this is a buddy page under lock */
+		if (!PageBuddy(page))
+			goto strict_check;
 
 		/* Found a free page, break it into order-0 pages */
 		isolated = split_free_page(page);
@@ -145,10 +153,24 @@ static unsigned long isolate_freepages_block(unsigned long start_pfn,
 			blockpfn += isolated - 1;
 			cursor += isolated - 1;
 		}
+
+		continue;
+
+strict_check:
+		/* Abort isolation if the caller requested strict isolation */
+		if (strict) {
+			total_isolated = 0;
+			goto out;
+		}
 	}
 
 	trace_mm_compaction_isolate_freepages(start_pfn, nr_scanned,
 						total_isolated);
+
+out:
+	if (locked)
+		spin_unlock_irqrestore(&cc->zone->lock, flags);
+
 	return total_isolated;
 }
 
@@ -168,13 +190,18 @@ static unsigned long isolate_freepages_block(unsigned long start_pfn,
 unsigned long
 isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 {
-	unsigned long isolated, pfn, block_end_pfn, flags;
+	unsigned long isolated, pfn, block_end_pfn;
 	struct zone *zone = NULL;
 	LIST_HEAD(freelist);
+	struct compact_control cc;
 
 	if (pfn_valid(start_pfn))
 		zone = page_zone(pfn_to_page(start_pfn));
 
+	/* cc needed for isolate_freepages_block to acquire zone->lock */
+	cc.zone = zone;
+	cc.sync = true;
+
 	for (pfn = start_pfn; pfn < end_pfn; pfn += isolated) {
 		if (!pfn_valid(pfn) || zone != page_zone(pfn_to_page(pfn)))
 			break;
@@ -186,10 +213,8 @@ isolate_freepages_range(unsigned long start_pfn, unsigned long end_pfn)
 		block_end_pfn = ALIGN(pfn + 1, pageblock_nr_pages);
 		block_end_pfn = min(block_end_pfn, end_pfn);
 
-		spin_lock_irqsave(&zone->lock, flags);
-		isolated = isolate_freepages_block(pfn, block_end_pfn,
+		isolated = isolate_freepages_block(&cc, pfn, block_end_pfn,
 						   &freelist, true);
-		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
 		 * In strict mode, isolate_freepages_block() returns 0 if
@@ -480,7 +505,6 @@ static void isolate_freepages(struct zone *zone,
 {
 	struct page *page;
 	unsigned long high_pfn, low_pfn, pfn, zone_end_pfn, end_pfn;
-	unsigned long flags;
 	int nr_freepages = cc->nr_freepages;
 	struct list_head *freelist = &cc->freepages;
 
@@ -536,22 +560,12 @@ static void isolate_freepages(struct zone *zone,
 		 */
 		isolated = 0;
 
-		/*
-		 * The zone lock must be held to isolate freepages. This
-		 * unfortunately this is a very coarse lock and can be
-		 * heavily contended if there are parallel allocations
-		 * or parallel compactions. For async compaction do not
-		 * spin on the lock
-		 */
-		if (!compact_trylock_irqsave(&zone->lock, &flags, cc))
-			break;
 		if (suitable_migration_target(page)) {
 			end_pfn = min(pfn + pageblock_nr_pages, zone_end_pfn);
-			isolated = isolate_freepages_block(pfn, end_pfn,
+			isolated = isolate_freepages_block(cc, pfn, end_pfn,
 							   freelist, false);
 			nr_freepages += isolated;
 		}
-		spin_unlock_irqrestore(&zone->lock, flags);
 
 		/*
 		 * Record the highest PFN we isolated pages from. When next

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
