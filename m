Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 4CA796B0032
	for <linux-mm@kvack.org>; Wed,  5 Jun 2013 15:46:11 -0400 (EDT)
Date: Wed, 5 Jun 2013 15:45:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 3/3] memcg: simplify mem_cgroup_reclaim_iter
Message-ID: <20130605194552.GI15721@cmpxchg.org>
References: <1370306679-13129-1-git-send-email-tj@kernel.org>
 <1370306679-13129-4-git-send-email-tj@kernel.org>
 <20130604131843.GF31242@dhcp22.suse.cz>
 <20130604205025.GG14916@htj.dyndns.org>
 <20130604212808.GB13231@dhcp22.suse.cz>
 <20130604215535.GM14916@htj.dyndns.org>
 <20130605073023.GB15997@dhcp22.suse.cz>
 <20130605082023.GG7303@mtj.dyndns.org>
 <20130605143949.GQ15576@cmpxchg.org>
 <20130605172212.GA10693@mtj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130605172212.GA10693@mtj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Michal Hocko <mhocko@suse.cz>, bsingharora@gmail.com, cgroups@vger.kernel.org, linux-mm@kvack.org, lizefan@huawei.com

On Wed, Jun 05, 2013 at 10:22:12AM -0700, Tejun Heo wrote:
> Hey, Johannes.
> 
> On Wed, Jun 05, 2013 at 10:39:49AM -0400, Johannes Weiner wrote:
> > 5k cgroups * say 10 priority levels * 1k struct mem_cgroup may pin 51M
> > of dead struct mem_cgroup, plus whatever else the css pins.
> 
> Yeah, it seems like it can grow quite a bit.
> 
> > > I'll get to the barrier thread but really complex barrier dancing like
> > > that is only justifiable in extremely hot paths a lot of people pay
> > > attention to.  It doesn't belong inside memcg proper.  If the cached
> > > amount is an actual concern, let's please implement a simple clean up
> > > thing.  All we need is a single delayed_work which scans the tree
> > > periodically.
> > > 
> > > Johannes, what do you think?
> > 
> > While I see your concerns about complexity (and this certainly is not
> > the most straight-forward code), I really can't get too excited about
> > asynchroneous garbage collection, even worse when it's time-based. It
> > would probably start out with less code but two releases later we
> > would have added all this stuff that's required to get the interaction
> > right and fix unpredictable reclaim disruption that hits when the
> > reaper coincides just right with heavy reclaim once a week etc.  I
> > just don't think that asynchroneous models are simpler than state
> > machines.  Harder to reason about, harder to debug.
> 
> Agreed, but we can do the cleanup from ->css_offline() as Michal
> suggested.  Naively implemented, this will lose the nice property of
> keeping the iteration point even when the cursor cgroup is removed,
> which can be an issue if we're actually worrying about cases with 5k
> cgroups continuously being created and destroyed.  Maybe we can make
> it point to the next cgroup to visit rather than the last visited one
> and update it from ->css_offline().

I'm not sure what you are suggesting.  Synchroneously invalidate every
individual iterator upwards the hierarchy every time a cgroup is
destroyed?

> > Now, there are separate things that add complexity to our current
> > code: the weak pointers, the lockless iterator, and the fact that all
> > of it is jam-packed into one monolithic iterator function.  I can see
> > why you are not happy.  But that does not mean we have to get rid of
> > everything wholesale.
> > 
> > You hate the barriers, so let's add a lock to access the iterator.
> > That path is not too hot in most cases.
> > 
> > On the other hand, the weak pointer is not too esoteric of a pattern
> > and we can neatly abstract it into two functions: one that takes an
> > iterator and returns a verified css reference or NULL, and one to
> > invalidate pointers when called from the memcg destruction code.
> >
> > These two things should greatly simplify mem_cgroup_iter() while not
> > completely abandoning all our optimizations.
> > 
> > What do you think?
> 
> I really think the weak pointers should go especially as we can
> achieve about the same thing with normal RCU dereference.  Also, I'm a
> bit confused about what you're suggesting.  If we have invalidation
> from offline, why do we need weak pointers?

The invalidation I am talking about is what we do by increasing the
dead counts.  This lazily invalidates all the weak pointers in the
iterators of the hierarchy root.

Of course if you do a synchroneous invalidation of individual
iterators, we don't need weak pointers anymore and RCU is enough, but
that would mean nr_levels * nr_nodes * nr_zones * nr_priority_levels
invalidation operations per destruction, whereas the weak pointers are
invalidated with one atomic_inc() per nesting level.

As I said, the weak pointers are only a few lines of code that can be
neatly self-contained (see the invalidate, load, store functions
below).  Please convince me that your alternative solution will save
complexity to such an extent that either the memory waste of
indefinite css pinning, or the computational overhead of non-lazy
iterator cleanup, is justifiable.

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 010d6c1..e872554 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1148,6 +1148,57 @@ skip_node:
 	return NULL;
 }
 
+static void mem_cgroup_iter_invalidate(struct mem_cgroup *root)
+{
+	/*
+	 * When a group in the hierarchy below root is destroyed, the
+	 * hierarchy iterator can no longer be trusted since it might
+	 * have pointed to the destroyed group.  Invalidate it.
+	 */
+	atomic_inc(&root->dead_count);
+}
+
+static struct mem_cgroup *mem_cgroup_iter_load(struct mem_cgroup_reclaim_iter *iter,
+					       struct mem_cgroup *root,
+					       int *sequence)
+{
+	struct mem_cgroup *position = NULL;
+	/*
+	 * A cgroup destruction happens in two stages: offlining and
+	 * release.  They are separated by a RCU grace period.
+	 *
+	 * If the iterator is valid, we may still race with an
+	 * offlining.  The RCU lock ensures the object won't be
+	 * released, tryget will fail if we lost the race.
+	 */
+	*sequence = atomic_read(&root->dead_count);
+	if (iter->last_dead_count == *sequence) {
+		smp_rmb();
+		position = iter->last_visited;
+		if (position && !css_tryget(&position->css))
+			position = NULL;
+	}
+	return position;
+}
+
+static void mem_cgroup_iter_update(struct mem_cgroup_reclaim_iter *iter,
+				   struct mem_cgroup *last_visited,
+				   struct mem_cgroup *new_position,
+				   int sequence)
+{
+	if (last_visited)
+		css_put(&last_visited->css);
+	/*
+	 * We store the sequence count from the time @last_visited was
+	 * loaded successfully instead of rereading it here so that we
+	 * don't lose destruction events in between.  We could have
+	 * raced with the destruction of @new_position after all.
+	 */
+	iter->last_visited = new_position;
+	smp_wmb();
+	iter->last_dead_count = sequence;
+}
+
 /**
  * mem_cgroup_iter - iterate over memory cgroup hierarchy
  * @root: hierarchy root
@@ -1171,7 +1222,6 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 {
 	struct mem_cgroup *memcg = NULL;
 	struct mem_cgroup *last_visited = NULL;
-	unsigned long uninitialized_var(dead_count);
 
 	if (mem_cgroup_disabled())
 		return NULL;
@@ -1191,6 +1241,7 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 	rcu_read_lock();
 	while (!memcg) {
 		struct mem_cgroup_reclaim_iter *uninitialized_var(iter);
+		int sequence;
 
 		if (reclaim) {
 			int nid = zone_to_nid(reclaim->zone);
@@ -1205,38 +1256,13 @@ struct mem_cgroup *mem_cgroup_iter(struct mem_cgroup *root,
 				goto out_unlock;
 			}
 
-			/*
-			 * If the dead_count mismatches, a destruction
-			 * has happened or is happening concurrently.
-			 * If the dead_count matches, a destruction
-			 * might still happen concurrently, but since
-			 * we checked under RCU, that destruction
-			 * won't free the object until we release the
-			 * RCU reader lock.  Thus, the dead_count
-			 * check verifies the pointer is still valid,
-			 * css_tryget() verifies the cgroup pointed to
-			 * is alive.
-			 */
-			dead_count = atomic_read(&root->dead_count);
-			smp_rmb();
-			last_visited = iter->last_visited;
-			if (last_visited) {
-				if ((dead_count != iter->last_dead_count) ||
-					!css_tryget(&last_visited->css)) {
-					last_visited = NULL;
-				}
-			}
+			last_visited = mem_cgroup_iter_load(iter, root, &sequence);
 		}
 
 		memcg = __mem_cgroup_iter_next(root, last_visited);
 
 		if (reclaim) {
-			if (last_visited)
-				css_put(&last_visited->css);
-
-			iter->last_visited = memcg;
-			smp_wmb();
-			iter->last_dead_count = dead_count;
+			mem_cgroup_iter_update(iter, last_visited, memcg, sequence);
 
 			if (!memcg)
 				iter->generation++;
@@ -6321,14 +6347,14 @@ static void mem_cgroup_invalidate_reclaim_iterators(struct mem_cgroup *memcg)
 	struct mem_cgroup *parent = memcg;
 
 	while ((parent = parent_mem_cgroup(parent)))
-		atomic_inc(&parent->dead_count);
+		mem_cgroup_iter_invalidate(parent);
 
 	/*
 	 * if the root memcg is not hierarchical we have to check it
 	 * explicitely.
 	 */
 	if (!root_mem_cgroup->use_hierarchy)
-		atomic_inc(&root_mem_cgroup->dead_count);
+		mem_cgroup_iter_invalidate(parent);
 }
 
 static void mem_cgroup_css_offline(struct cgroup *cont)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
