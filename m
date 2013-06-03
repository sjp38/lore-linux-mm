Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 174D56B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 11:02:10 -0400 (EDT)
Date: Mon, 3 Jun 2013 11:01:54 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 10/10] mm: workingset: keep shadow entries in check
Message-ID: <20130603150154.GE15576@cmpxchg.org>
References: <1369937046-27666-1-git-send-email-hannes@cmpxchg.org>
 <1369937046-27666-11-git-send-email-hannes@cmpxchg.org>
 <20130603082209.GG5910@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130603082209.GG5910@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: linux-mm@kvack.org, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, metin d <metdos@yahoo.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Mon, Jun 03, 2013 at 10:22:09AM +0200, Peter Zijlstra wrote:
> On Thu, May 30, 2013 at 02:04:06PM -0400, Johannes Weiner wrote:
> > 2. a list of files that contain shadow entries is maintained.  If the
> >    global number of shadows exceeds a certain threshold, a shrinker is
> >    activated that reclaims old entries from the mappings.  This is
> >    heavy-handed but it should not be a common case and is only there
> >    to protect from accidentally/maliciously induced OOM kills.
> 
> Grrr.. another global files list. We've been trying rather hard to get
> rid of the first one :/
> 
> I see why you want it but ugh.

I'll try to make it per-SB like the inode list.  It probably won't be
per-SB shrinkers because of the global nature of the shadow limit, but
at least per-SB inode lists should be doable.

> I have similar worries for your global time counter, large machines
> might thrash on that one cacheline.

Fair enough.

So I'm trying the following idea: instead of the global time counter,
have per-zone time counters and store the zone along with those local
timestamps in the shadow entries (nid | zid | time).  On refault, we
can calculate the zone-local distance first and then use the inverse
of the zone's eviction proportion to scale it to a global distance.

Delta for 9/10:

---
 include/linux/mmzone.h |  1 +
 mm/workingset.c        | 74 ++++++++++++++++++++++++++++++--------------------
 2 files changed, 46 insertions(+), 29 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 505bd80..24e9805 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -206,6 +206,7 @@ struct zone_reclaim_stat {
 struct lruvec {
 	struct list_head lists[NR_LRU_LISTS];
 	struct zone_reclaim_stat reclaim_stat;
+	atomic_long_t workingset_time;
 	struct prop_local_percpu evictions;
 	long shrink_active;
 #ifdef CONFIG_MEMCG
diff --git a/mm/workingset.c b/mm/workingset.c
index 7986aa4..5fd7277 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -85,27 +85,10 @@
  */
 
 /*
- * Monotonic workingset clock for non-resident pages.
- *
- * The refault distance of a page is the number of ticks that occurred
- * between that page's eviction and subsequent refault.
- *
- * Every page slot that is taken away from the inactive list is one
- * more slot the inactive list would have to grow again in order to
- * hold the current non-resident pages in memory as well.
- *
- * As the refault distance needs to reflect the space missing on the
- * inactive list, the workingset time is advanced every time the
- * inactive list is shrunk.  This means eviction, but also activation.
- */
-static atomic_long_t workingset_time;
-
-/*
  * Workingset clock snapshots are stored in the page cache radix tree
  * as exceptional entries (shadows).
  */
 #define EV_SHIFT	RADIX_TREE_EXCEPTIONAL_SHIFT
-#define EV_MASK		(~0UL >> EV_SHIFT)
 
 /*
  * Per-zone proportional eviction counter to keep track of recent zone
@@ -115,12 +98,12 @@ static struct prop_descriptor global_evictions;
 
 void *workingset_eviction(struct address_space *mapping, struct page *page)
 {
+	struct zone *zone = page_zone(page);
 	struct lruvec *lruvec;
 	unsigned long time;
 
-	time = atomic_long_inc_return(&workingset_time);
-
-	lruvec = mem_cgroup_zone_lruvec(page_zone(page), NULL);
+	lruvec = mem_cgroup_zone_lruvec(zone, NULL);
+	time = atomic_long_inc_return(&lruvec->workingset_time);
 	prop_inc_percpu(&global_evictions, &lruvec->evictions);
 
 	/*
@@ -132,21 +115,57 @@ void *workingset_eviction(struct address_space *mapping, struct page *page)
 	if (mapping_exiting(mapping))
 		return NULL;
 
+	time = (time << NODES_SHIFT) | zone->node;
+	time = (time << ZONES_SHIFT) | zone_idx(zone);
+
 	return (void *)((time << EV_SHIFT) | RADIX_TREE_EXCEPTIONAL_ENTRY);
 }
 
-unsigned long workingset_refault_distance(struct page *page)
+static void lruvec_refault_distance(unsigned long shadow,
+				    struct lruvec **lruvec,
+				    unsigned long *distance)
 {
 	unsigned long time_of_eviction;
+	struct zone *zone;
 	unsigned long now;
+	int zid, nid;
+
+	shadow >>= EV_SHIFT;
+	zid = shadow & ((1UL << ZONES_SHIFT) - 1);
+	shadow >>= ZONES_SHIFT;
+	nid = shadow & ((1UL << NODES_SHIFT) - 1);
+	shadow >>= NODES_SHIFT;
+	time_of_eviction = shadow;
+	zone = NODE_DATA(nid)->node_zones + zid;
+
+	*lruvec = mem_cgroup_zone_lruvec(zone, NULL);
+
+	now = atomic_long_read(&(*lruvec)->workingset_time);
+
+	*distance = (now - time_of_eviction) &
+		(~0UL >> (EV_SHIFT + ZONES_SHIFT + NODES_SHIFT));
+}
+
+unsigned long workingset_refault_distance(struct page *page)
+{
+	unsigned long refault_distance;
+	unsigned long lruvec_distance;
+	struct lruvec *lruvec;
+	long denominator;
+	long numerator;
 
 	if (!page)
 		return ~0UL;
 
 	BUG_ON(!radix_tree_exceptional_entry(page));
-	time_of_eviction = (unsigned long)page >> EV_SHIFT;
-	now = atomic_long_read(&workingset_time);
-	return (now - time_of_eviction) & EV_MASK;
+	lruvec_refault_distance((unsigned long)page,
+				&lruvec, &lruvec_distance);
+	prop_fraction_percpu(&global_evictions, &lruvec->evictions,
+			     &numerator, &denominator);
+	if (!numerator)
+		numerator = 1;
+	refault_distance = mult_frac(lruvec_distance, denominator, numerator);
+	return refault_distance;
 }
 EXPORT_SYMBOL(workingset_refault_distance);
 
@@ -187,8 +206,7 @@ void workingset_zone_balance(struct zone *zone, unsigned long refault_distance)
 	 */
 	prop_fraction_percpu(&global_evictions, &lruvec->evictions,
 			     &numerator, &denominator);
-	missing = refault_distance * numerator;
-	do_div(missing, denominator);
+	missing = mult_frac(refault_distance, numerator, denominator);
 
 	/*
 	 * Protected pages should be challenged when the refault
@@ -207,9 +225,6 @@ void workingset_zone_balance(struct zone *zone, unsigned long refault_distance)
 void workingset_activation(struct page *page)
 {
 	struct lruvec *lruvec;
-
-	atomic_long_inc(&workingset_time);
-
 	/*
 	 * The lists are rebalanced when the inactive list is observed
 	 * to be too small for activations.  An activation means that
@@ -217,6 +232,7 @@ void workingset_activation(struct page *page)
 	 * page, so back off further deactivation.
 	 */
 	lruvec = mem_cgroup_zone_lruvec(page_zone(page), NULL);
+	atomic_long_inc(&lruvec->workingset_time);
 	if (lruvec->shrink_active > 0)
 		lruvec->shrink_active--;
 }
-- 
1.8.2.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
