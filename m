Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id EFC986B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 01:58:09 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id n12so9011622wgh.24
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 22:58:09 -0800 (PST)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id q18si5609208wiw.0.2014.01.21.22.58.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 22:58:08 -0800 (PST)
Date: Wed, 22 Jan 2014 01:57:14 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 9/9] mm: keep page cache radix tree nodes in check
Message-ID: <20140122065714.GU6963@cmpxchg.org>
References: <1389377443-11755-1-git-send-email-hannes@cmpxchg.org>
 <1389377443-11755-10-git-send-email-hannes@cmpxchg.org>
 <20140117000517.GB18112@dastard>
 <20140120231737.GS6963@cmpxchg.org>
 <20140121030358.GN18112@dastard>
 <20140121055017.GT6963@cmpxchg.org>
 <20140122030607.GB27606@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140122030607.GB27606@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Bob Liu <bob.liu@oracle.com>, Christoph Hellwig <hch@infradead.org>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Metin Doslu <metin@citusdata.com>, Michel Lespinasse <walken@google.com>, Minchan Kim <minchan.kim@gmail.com>, Ozgun Erdogan <ozgun@citusdata.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Roman Gushchin <klamm@yandex-team.ru>, Ryan Mallon <rmallon@gmail.com>, Tejun Heo <tj@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jan 22, 2014 at 02:06:07PM +1100, Dave Chinner wrote:
> On Tue, Jan 21, 2014 at 12:50:17AM -0500, Johannes Weiner wrote:
> > On Tue, Jan 21, 2014 at 02:03:58PM +1100, Dave Chinner wrote:
> > > On Mon, Jan 20, 2014 at 06:17:37PM -0500, Johannes Weiner wrote:
> > > > On Fri, Jan 17, 2014 at 11:05:17AM +1100, Dave Chinner wrote:
> > > > > On Fri, Jan 10, 2014 at 01:10:43PM -0500, Johannes Weiner wrote:
> > > > > > +static struct shrinker workingset_shadow_shrinker = {
> > > > > > +	.count_objects = count_shadow_nodes,
> > > > > > +	.scan_objects = scan_shadow_nodes,
> > > > > > +	.seeks = DEFAULT_SEEKS * 4,
> > > > > > +	.flags = SHRINKER_NUMA_AWARE,
> > > > > > +};
> > > > > 
> > > > > Can you add a comment explaining how you calculated the .seeks
> > > > > value? It's important to document the weighings/importance
> > > > > we give to slab reclaim so we can determine if it's actually
> > > > > acheiving the desired balance under different loads...
> > > > 
> > > > This is not an exact science, to say the least.
> > > 
> > > I know, that's why I asked it be documented rather than be something
> > > kept in your head.
> > > 
> > > > The shadow entries are mostly self-regulated, so I don't want the
> > > > shrinker to interfere while the machine is just regularly trimming
> > > > caches during normal operation.
> > > > 
> > > > It should only kick in when either a) reclaim is picking up and the
> > > > scan-to-reclaim ratio increases due to mapped pages, dirty cache,
> > > > swapping etc. or b) the number of objects compared to LRU pages
> > > > becomes excessive.
> > > > 
> > > > I think that is what most shrinkers with an elevated seeks value want,
> > > > but this translates very awkwardly (and not completely) to the current
> > > > cost model, and we should probably rework that interface.
> > > > 
> > > > "Seeks" currently encodes 3 ratios:
> > > > 
> > > >   1. the cost of creating an object vs. a page
> > > > 
> > > >   2. the expected number of objects vs. pages
> > > 
> > > It doesn't encode that at all. If it did, then the default value
> > > wouldn't be "2".
> > >
> > > >   3. the cost of reclaiming an object vs. a page
> > > 
> > > Which, when you consider #3 in conjunction with #1, the actual
> > > intended meaning of .seeks is "the cost of replacing this object in
> > > the cache compared to the cost of replacing a page cache page."
> > 
> > But what it actually seems to do is translate scan rate from LRU pages
> > to scan rate in another object pool.  The actual replacement cost
> > varies based on hotness of each set, an in-use object is more
> > expensive to replace than a cold page and vice versa, the dentry and
> > inode shrinkers reflect this by rotating hot objects and refusing to
> > actually reclaim items while they are in active use.
> 
> Right, but so does the page cache when the page referenced bit is
> seen by the LRU scanner. That's a scanned page, so what is passed to
> shrink_slab is a ratio of pages scanned vs pages eligible for
> reclaim. IOWs, the fact that the slab caches rotate rather than
> reclaim is irrelevant - what matters is the same proportional
> pressure is applied to the slab cache that was applied to the page
> cache....

Oh, but it does.  You apply the same pressure to both, but the actual
reclaim outcome depends on object valuation measures specific to each
pool (e.g. recently referenced or not), whereas my shrinker takes
sc->nr_to_scan objects and reclaims them without looking at their
individual value, which varies just like the value of slab objects
varies.

I thought I could compensate for the lack of object valuation in the
shadow shrinker by tweaking that fixed pressure factor between page
cache and shadow entries, but I'm no longer convinced this can work.

One thing that does affect the value of shadow entries is the overall
health of the system, memory-wise, so reclaim efficiency would be one
factor that affects individual object value, albeit a secondary one.

The most obvious value factor is whether the shadow entries in a node
are expired or not, but there are potentially 64 of them, potentially
from different zones with different "inactive ages" atomic_t's, so
that is fairly expensive to assess.

> > So I am having a hard time deriving a meaningful value out of this
> > definition for my usecase because I want to push back objects based on
> > reclaim efficiency (scan rate vs. reclaim rate).  The other shrinkers
> > with non-standard seek settings reek of magic number as well, which
> > suggests I am not alone with this.
> 
> Right, which is exactly why I'm asking you to document it. I've got
> no idea how other subsystems have come up with their magic numbers
> because they are not documented, and so it's just about impossible
> to determine what the author of the code really needed and hence the
> best way to improve the interface is difficult to determine.
> 
> > I wonder if we can come up with a better interface that allows both
> > traditional cache shrinkers with their own aging, as well as object
> > pools that want to push back based on reclaim efficiency.
> 
> We probably can, though I'd prefer we don't end up with some
> alternative algorithm that is specific to a single shrinker.
> 
> So, how do we measure page cache reclaim efficiency? How can that be
> communicated to a shrinker? how can we tell a shrinker what measure
> to use? How do we tell shrinker authors what measure to use?  How do
> we translate that new method useful scan count information?

We usually define it as the scanned / reclaim ratio.  I have to think
about the rest and what exactly I need from the shrinker.  Unless I
can come up with a better object valuation model that can be a private
part of the shadow shrinker, of course.

> > > > but they are not necessarily correlated.  How I would like to
> > > > configure the shadow shrinker instead is:
> > > > 
> > > >   o scan objects when reclaim efficiency is down to 75%, because they
> > > >     are more valuable than use-once cache but less than workingset
> > > > 
> > > >   o scan objects when the ratio between them and the number of pages
> > > >     exceeds 1/32 (one shadow entry for each resident page, up to 64
> > > >     entries per shrinkable object, assume 50% packing for robustness)
> > > > 
> > > >   o as the expected balance between objects and lru pages is 1:32,
> > > >     reclaim one object for every 32 reclaimed LRU pages, instead of
> > > >     assuming that number of scanned pages corresponds meaningfully to
> > > >     number of objects to scan.
> > > 
> > > You're assuming that every radix tree node has a full population of
> > > pages. This only occurs on sequential read and write workloads, and
> > > so isn't going tobe true for things like mapped executables or any
> > > semi-randomly accessed data set...
> > 
> > No, I'm assuming 50% population on average for that reason.  I don't
> > know how else I could assign a fixed value to a variable object.
> 
> Ok, I should have say "fixed population", not "full population". Do
> you have any stats on the typical mapping tree radix node population
> on running systems?

Not at this time, I'll try to look into that.  For now, I am updating
the patch to revert the shrinker back to DEFAULT_SEEKS and change the
object count to only include objects above a certain threshold, which
assumes a worst-case population of 4 in 64 slots.  It's not perfect,
but neither was the seeks magic, and it's easier to reason about what
it's actually doing.

---
 mm/filemap.c    | 17 +++++++++++++++--
 mm/list_lru.c   |  4 +++-
 mm/truncate.c   |  8 +++++++-
 mm/workingset.c | 54 ++++++++++++++++++++++++++++++++++++++----------------
 4 files changed, 63 insertions(+), 20 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index b93e223b59a9..45a52fd28938 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -156,7 +156,13 @@ static void page_cache_tree_delete(struct address_space *mapping,
 		if (__radix_tree_delete_node(&mapping->page_tree, node))
 			return;
 
-	/* Only shadow entries in there, keep track of this node */
+	/*
+	 * Track node that only contains shadow entries.
+	 *
+	 * Avoid acquiring the list_lru lock if already tracked.  The
+	 * list_empty() test is safe as node->private_list is
+	 * protected by mapping->tree_lock.
+	 */
 	if (!(node->count & RADIX_TREE_COUNT_MASK) &&
 	    list_empty(&node->private_list)) {
 		node->private_data = mapping;
@@ -531,7 +537,14 @@ static int page_cache_tree_insert(struct address_space *mapping,
 	mapping->nrpages++;
 	if (node) {
 		node->count++;
-		/* Installed page, can't be shadow-only anymore */
+		/*
+		 * Don't track node that contains actual pages.
+		 *
+		 * Avoid acquiring the list_lru lock if already
+		 * untracked.  The list_empty() test is safe as
+		 * node->private_list is protected by
+		 * mapping->tree_lock.
+		 */
 		if (!list_empty(&node->private_list))
 			list_lru_del(&workingset_shadow_nodes,
 				     &node->private_list);
diff --git a/mm/list_lru.c b/mm/list_lru.c
index 47a9faf4070b..7f5b73e2513b 100644
--- a/mm/list_lru.c
+++ b/mm/list_lru.c
@@ -87,8 +87,9 @@ restart:
 
 		ret = isolate(item, &nlru->lock, cb_arg);
 		switch (ret) {
-		case LRU_REMOVED:
 		case LRU_REMOVED_RETRY:
+			assert_spin_locked(&nlru->lock);
+		case LRU_REMOVED:
 			if (--nlru->nr_items == 0)
 				node_clear(nid, lru->active_nodes);
 			WARN_ON_ONCE(nlru->nr_items < 0);
@@ -111,6 +112,7 @@ restart:
 			 * The lru lock has been dropped, our list traversal is
 			 * now invalid and so we have to restart from scratch.
 			 */
+			assert_spin_locked(&nlru->lock);
 			goto restart;
 		default:
 			BUG();
diff --git a/mm/truncate.c b/mm/truncate.c
index 5c2615d7f4da..5f7599b49126 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -47,7 +47,13 @@ static void clear_exceptional_entry(struct address_space *mapping,
 	if (!node)
 		goto unlock;
 	node->count -= 1U << RADIX_TREE_COUNT_SHIFT;
-	/* No more shadow entries, stop tracking the node */
+	/*
+	 * Don't track node without shadow entries.
+	 *
+	 * Avoid acquiring the list_lru lock if already untracked.
+	 * The list_empty() test is safe as node->private_list is
+	 * protected by mapping->tree_lock.
+	 */
 	if (!(node->count >> RADIX_TREE_COUNT_SHIFT) &&
 	    !list_empty(&node->private_list))
 		list_lru_del(&workingset_shadow_nodes, &node->private_list);
diff --git a/mm/workingset.c b/mm/workingset.c
index 7bb1a432c137..8ac2a26951ef 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -253,12 +253,15 @@ void workingset_activation(struct page *page)
 }
 
 /*
- * Page cache radix tree nodes containing only shadow entries can grow
- * excessively on certain workloads.  That's why they are tracked on
- * per-(NUMA)node lists and pushed back by a shrinker, but with a
- * slightly higher threshold than regular shrinkers so we don't
- * discard the entries too eagerly - after all, during light memory
- * pressure is exactly when we need them.
+ * Shadow entries reflect the share of the working set that does not
+ * fit into memory, so their number depends on the access pattern of
+ * the workload.  In most cases, they will refault or get reclaimed
+ * along with the inode, but a (malicious) workload that streams
+ * through files with a total size several times that of available
+ * memory, while preventing the inodes from being reclaimed, can
+ * create excessive amounts of shadow nodes.  To keep a lid on this,
+ * track shadow nodes and reclaim them when they grow way past the
+ * point where they would still be useful.
  */
 
 struct list_lru workingset_shadow_nodes;
@@ -266,14 +269,38 @@ struct list_lru workingset_shadow_nodes;
 static unsigned long count_shadow_nodes(struct shrinker *shrinker,
 					struct shrink_control *sc)
 {
-	return list_lru_count_node(&workingset_shadow_nodes, sc->nid);
+	unsigned long shadow_nodes;
+	unsigned long max_nodes;
+	unsigned long pages;
+
+	shadow_nodes = list_lru_count_node(&workingset_shadow_nodes, sc->nid);
+	pages = node_present_pages(sc->nid);
+	/*
+	 * Active cache pages are limited to 50% of memory, and shadow
+	 * entries that represent a refault distance bigger than that
+	 * do not have any effect.  Limit the number of shadow nodes
+	 * such that shadow entries do not exceed the number of active
+	 * cache pages, assuming a worst-case node population density
+	 * of 1/16th on average.
+	 *
+	 * On 64-bit with 7 radix_tree_nodes per page and 64 slots
+	 * each, this will reclaim shadow entries when they consume
+	 * ~2% of available memory:
+	 *
+	 * PAGE_SIZE / radix_tree_nodes / node_entries / PAGE_SIZE
+	 */
+	max_nodes = pages >> (1 + RADIX_TREE_MAP_SHIFT - 3);
+
+	if (shadow_nodes <= max_nodes)
+		return 0;
+
+	return shadow_nodes - max_nodes;
 }
 
 static enum lru_status shadow_lru_isolate(struct list_head *item,
 					  spinlock_t *lru_lock,
 					  void *arg)
 {
-	unsigned long *nr_reclaimed = arg;
 	struct address_space *mapping;
 	struct radix_tree_node *node;
 	unsigned int i;
@@ -327,7 +354,6 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	inc_zone_state(page_zone(virt_to_page(node)), WORKINGSET_NODERECLAIM);
 	if (!__radix_tree_delete_node(&mapping->page_tree, node))
 		BUG();
-	(*nr_reclaimed)++;
 
 	spin_unlock_irq(&mapping->tree_lock);
 	ret = LRU_REMOVED_RETRY;
@@ -340,18 +366,14 @@ out:
 static unsigned long scan_shadow_nodes(struct shrinker *shrinker,
 				       struct shrink_control *sc)
 {
-	unsigned long nr_reclaimed = 0;
-
-	list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
-			   shadow_lru_isolate, &nr_reclaimed, &sc->nr_to_scan);
-
-	return nr_reclaimed;
+	return list_lru_walk_node(&workingset_shadow_nodes, sc->nid,
+				  shadow_lru_isolate, NULL, &sc->nr_to_scan);
 }
 
 static struct shrinker workingset_shadow_shrinker = {
 	.count_objects = count_shadow_nodes,
 	.scan_objects = scan_shadow_nodes,
-	.seeks = DEFAULT_SEEKS * 4,
+	.seeks = DEFAULT_SEEKS,
 	.flags = SHRINKER_NUMA_AWARE,
 };
 
-- 
1.8.4.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
