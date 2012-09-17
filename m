Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id E7DE36B0044
	for <linux-mm@kvack.org>; Mon, 17 Sep 2012 08:26:34 -0400 (EDT)
Date: Mon, 17 Sep 2012 13:26:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH -v2 2/2] make the compaction "skip ahead" logic robust
Message-ID: <20120917122628.GF11266@suse.de>
References: <20120825174550.GA8619@alpha.arachsys.com>
 <50391564.30401@redhat.com>
 <20120826105803.GA377@alpha.arachsys.com>
 <20120906092039.GA19234@alpha.arachsys.com>
 <20120912105659.GA23818@alpha.arachsys.com>
 <20120912122541.GO11266@suse.de>
 <20120912164615.GA14173@alpha.arachsys.com>
 <20120913154824.44cc0e28@cuia.bos.redhat.com>
 <20120913155450.7634148f@cuia.bos.redhat.com>
 <20120915155524.GA24182@alpha.arachsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120915155524.GA24182@alpha.arachsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Davies <richard@arachsys.com>
Cc: Rik van Riel <riel@redhat.com>, Avi Kivity <avi@redhat.com>, Shaohua Li <shli@kernel.org>, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-mm@kvack.org

On Sat, Sep 15, 2012 at 04:55:24PM +0100, Richard Davies wrote:
> Hi Rik, Mel and Shaohua,
> 
> Thank you for your latest patches. I attach my latest perf report for a slow
> boot with all of these applied.
> 

Thanks for testing.

> Mel asked for timings of the slow boots. It's very hard to give anything
> useful here! A normal boot would be a minute or so, and many are like that,
> but the slowest that I have seen (on 3.5.x) was several hours. Basically, I
> just test many times until I get one which is noticeably slow than normal
> and then run perf record on that one.
> 

Ok.

> The latest perf report for a slow boot is below. For the fast boots, most of
> the time is in clean_page_c in do_huge_pmd_anonymous_page, but for this slow
> one there is a lot of lock contention above that.
> 
> <SNIP>
>     58.49%         qemu-kvm  [kernel.kallsyms]     [k] _raw_spin_lock_irqsave                    
>                    |
>                    --- _raw_spin_lock_irqsave
>                       |          
>                       |--95.07%-- compact_checklock_irqsave
>                       |          |          
>                       |          |--70.03%-- isolate_migratepages_range
> <SNIP>
>                       |           --29.97%-- compaction_alloc
>                       |          
>                       |--4.53%-- isolate_migratepages_range

> <SNIP>

This is going the right direction but usage due to contentions is still
obviously stupidly high.  Compaction features throughout the profile but
staying focused on the lock contention for the moment. Can you try the
following patch? So far I'm not having much luck reproducing this locally.

---8<---
mm: compaction: Only release lru_lock every SWAP_CLUSTER_MAX pages if necessary

Commit b2eef8c0 (mm: compaction: minimise the time IRQs are disabled while
isolating pages for migration) releases the lru_lock every SWAP_CLUSTER_MAX
pages that are scanned as it was found at the time that compaction could
contend badly with page reclaim. This can lead to a situation where
compaction contends heavily with itself as it releases and reacquires
the LRU lock.

This patch makes two changes to how the migrate scanner acquires the LRU
lock. First, it only releases the LRU lock every SWAP_CLUSTER_MAX pages if
the lock is contended. This reduces the number of times it unnnecessarily
disables and reenables IRQs. The second is that it defers acquiring the
LRU lock for as long as possible. In cases where transparent hugepages
are encountered the LRU lock will not be acquired at all.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/compaction.c |   65 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 44 insertions(+), 21 deletions(-)

diff --git a/mm/compaction.c b/mm/compaction.c
index 39342ee..1874f23 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -50,6 +50,11 @@ static inline bool migrate_async_suitable(int migratetype)
 	return is_migrate_cma(migratetype) || migratetype == MIGRATE_MOVABLE;
 }
 
+static inline bool should_release_lock(spinlock_t *lock)
+{
+	return need_resched() || spin_is_contended(lock);
+}
+
 /*
  * Compaction requires the taking of some coarse locks that are potentially
  * very heavily contended. Check if the process needs to be scheduled or
@@ -62,7 +67,7 @@ static inline bool migrate_async_suitable(int migratetype)
 static bool compact_checklock_irqsave(spinlock_t *lock, unsigned long *flags,
 				      bool locked, struct compact_control *cc)
 {
-	if (need_resched() || spin_is_contended(lock)) {
+	if (should_release_lock(lock)) {
 		if (locked) {
 			spin_unlock_irqrestore(lock, *flags);
 			locked = false;
@@ -275,7 +280,7 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 	isolate_mode_t mode = 0;
 	struct lruvec *lruvec;
 	unsigned long flags;
-	bool locked;
+	bool locked = false;
 
 	/*
 	 * Ensure that there are not too many pages isolated from the LRU
@@ -295,24 +300,17 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 
 	/* Time to isolate some pages for migration */
 	cond_resched();
-	locked = compact_trylock_irqsave(&zone->lru_lock, &flags, cc);
-	if (!locked)
-		return 0;
 	for (; low_pfn < end_pfn; low_pfn++) {
 		struct page *page;
 
 		/* give a chance to irqs before checking need_resched() */
-		if (!((low_pfn+1) % SWAP_CLUSTER_MAX)) {
-			spin_unlock_irqrestore(&zone->lru_lock, flags);
-			locked = false;
+		if (locked && !((low_pfn+1) % SWAP_CLUSTER_MAX)) {
+			if (should_release_lock(&zone->lru_lock)) {
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				locked = false;
+			}
 		}
 
-		/* Check if it is ok to still hold the lock */
-		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
-								locked, cc);
-		if (!locked)
-			break;
-
 		/*
 		 * migrate_pfn does not necessarily start aligned to a
 		 * pageblock. Ensure that pfn_valid is called when moving
@@ -352,21 +350,38 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 		pageblock_nr = low_pfn >> pageblock_order;
 		if (!cc->sync && last_pageblock_nr != pageblock_nr &&
 		    !migrate_async_suitable(get_pageblock_migratetype(page))) {
-			low_pfn += pageblock_nr_pages;
-			low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
-			last_pageblock_nr = pageblock_nr;
-			continue;
+			goto next_pageblock;
 		}
 
+		/* Check may be lockless but that's ok as we recheck later */
 		if (!PageLRU(page))
 			continue;
 
 		/*
-		 * PageLRU is set, and lru_lock excludes isolation,
-		 * splitting and collapsing (collapsing has already
-		 * happened if PageLRU is set).
+		 * PageLRU is set. lru_lock normally excludes isolation
+		 * splitting and collapsing (collapsing has already happened
+		 * if PageLRU is set) but the lock is not necessarily taken
+		 * here and it is wasteful to take it just to check transhuge.
+		 * Check transhuge without lock and skip if it's either a
+		 * transhuge or hugetlbfs page.
 		 */
 		if (PageTransHuge(page)) {
+			if (!locked)
+				goto next_pageblock;
+			low_pfn += (1 << compound_order(page)) - 1;
+			continue;
+		}
+
+		/* Check if it is ok to still hold the lock */
+		locked = compact_checklock_irqsave(&zone->lru_lock, &flags,
+								locked, cc);
+		if (!locked)
+			break;
+
+		/* Recheck PageLRU and PageTransHuge under lock */
+		if (!PageLRU(page))
+			continue;
+		if (PageTransHuge(page)) {
 			low_pfn += (1 << compound_order(page)) - 1;
 			continue;
 		}
@@ -393,6 +408,14 @@ isolate_migratepages_range(struct zone *zone, struct compact_control *cc,
 			++low_pfn;
 			break;
 		}
+
+		continue;
+
+next_pageblock:
+		low_pfn += pageblock_nr_pages;
+		low_pfn = ALIGN(low_pfn, pageblock_nr_pages) - 1;
+		last_pageblock_nr = pageblock_nr;
+
 	}
 
 	acct_isolated(zone, locked, cc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
