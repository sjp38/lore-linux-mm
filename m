Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id CA5ED6B002C
	for <linux-mm@kvack.org>; Tue,  6 Mar 2012 08:27:41 -0500 (EST)
Date: Tue, 6 Mar 2012 13:27:35 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH] cpuset: mm: Reduce large amounts of memory barrier related
 damage v2
Message-ID: <20120306132735.GA2855@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux.com>, Miao Xie <miaox@cn.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Changelog since V1
  o Use seqcount with rmb instead of atomics (Peter, Christoph)

Commit [c0ff7453: cpuset,mm: fix no node to alloc memory when changing
cpuset's mems] wins a super prize for the largest number of memory
barriers entered into fast paths for one commit. [get|put]_mems_allowed
is incredibly heavy with pairs of full memory barriers inserted into a
number of hot paths. This was detected while investigating at large page
allocator slowdown introduced some time after 2.6.32. The largest portion
of this overhead was shown by oprofile to be at an mfence introduced by
this commit into the page allocator hot path.

For extra style points, the commit introduced the use of yield() in an
implementation of what looks like a spinning mutex.

This patch replaces the full memory barriers on both read and write sides
with a sequence counter with just read barriers on the fast path side.
This is much cheaper on some architectures, including x86.  The main bulk
of the patch is the retry logic if the nodemask changes in a manner that
can cause a false failure.

While updating the nodemask, a check is made to see if a false failure is
a risk. If it is, the sequence number gets bumped and parallel allocators
will briefly stall while the nodemask update takes place.

In a page fault test microbenchmark, oprofile samples from
__alloc_pages_nodemask went from 4.53% of all samples to 1.15%. The actual
results were

                         3.3.0-rc3          3.3.0-rc3
                         rc3-vanilla        nobarrier-v2r1
Clients   1 UserTime       0.07 (  0.00%)   0.08 (-14.19%)
Clients   2 UserTime       0.07 (  0.00%)   0.07 (  2.72%)
Clients   4 UserTime       0.08 (  0.00%)   0.07 (  3.29%)
Clients   1 SysTime        0.70 (  0.00%)   0.65 (  6.65%)
Clients   2 SysTime        0.85 (  0.00%)   0.82 (  3.65%)
Clients   4 SysTime        1.41 (  0.00%)   1.41 (  0.32%)
Clients   1 WallTime       0.77 (  0.00%)   0.74 (  4.19%)
Clients   2 WallTime       0.47 (  0.00%)   0.45 (  3.73%)
Clients   4 WallTime       0.38 (  0.00%)   0.37 (  1.58%)
Clients   1 Flt/sec/cpu  497620.28 (  0.00%) 520294.53 (  4.56%)
Clients   2 Flt/sec/cpu  414639.05 (  0.00%) 429882.01 (  3.68%)
Clients   4 Flt/sec/cpu  257959.16 (  0.00%) 258761.48 (  0.31%)
Clients   1 Flt/sec      495161.39 (  0.00%) 517292.87 (  4.47%)
Clients   2 Flt/sec      820325.95 (  0.00%) 850289.77 (  3.65%)
Clients   4 Flt/sec      1020068.93 (  0.00%) 1022674.06 (  0.26%)
MMTests Statistics: duration
Sys Time Running Test (seconds)             135.68    132.17
User+Sys Time Running Test (seconds)         164.2    160.13
Total Elapsed Time (seconds)                123.46    120.87

The overall improvement is small but the System CPU time is much improved
and roughly in correlation to what oprofile reported (these performance
figures are without profiling so skew is expected). The actual number of
page faults is noticeably improved.

For benchmarks like kernel builds, the overall benefit is marginal but
the system CPU time is slightly reduced.

To test the actual bug the commit fixed I opened two terminals. The first
ran within a cpuset and continually ran a small program that faulted 100M
of anonymous data. In a second window, the nodemask of the cpuset was
continually randomised in a loop. Without the commit, the program would
fail every so often (usually within 10 seconds) and obviously with the
commit everything worked fine. With this patch applied, it also worked
fine so the fix should be functionally equivalent.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/cpuset.h |   38 +++++++++++++-------------------------
 include/linux/sched.h  |    2 +-
 kernel/cpuset.c        |   43 ++++++++-----------------------------------
 mm/filemap.c           |   11 +++++++----
 mm/hugetlb.c           |    7 +++++--
 mm/mempolicy.c         |   28 +++++++++++++++++++++-------
 mm/page_alloc.c        |   33 +++++++++++++++++++++++----------
 mm/slab.c              |   11 +++++++----
 mm/slub.c              |   32 +++++++++++++++++---------------
 mm/vmscan.c            |    2 --
 10 files changed, 102 insertions(+), 105 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index e9eaec5..104f701 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -92,33 +92,19 @@ extern void cpuset_print_task_mems_allowed(struct task_struct *p);
  * reading current mems_allowed and mempolicy in the fastpath must protected
  * by get_mems_allowed()
  */
-static inline void get_mems_allowed(void)
+static inline unsigned int get_mems_allowed(void)
 {
-	current->mems_allowed_change_disable++;
-
-	/*
-	 * ensure that reading mems_allowed and mempolicy happens after the
-	 * update of ->mems_allowed_change_disable.
-	 *
-	 * the write-side task finds ->mems_allowed_change_disable is not 0,
-	 * and knows the read-side task is reading mems_allowed or mempolicy,
-	 * so it will clear old bits lazily.
-	 */
-	smp_mb();
+	return read_seqcount_begin(&current->mems_allowed_seq);
 }
 
-static inline void put_mems_allowed(void)
+/*
+ * If this returns false, the operation that took place after get_mems_allowed
+ * may have failed. It is up to the caller to retry the operation if
+ * appropriate
+ */
+static inline bool put_mems_allowed(unsigned int seq)
 {
-	/*
-	 * ensure that reading mems_allowed and mempolicy before reducing
-	 * mems_allowed_change_disable.
-	 *
-	 * the write-side task will know that the read-side task is still
-	 * reading mems_allowed or mempolicy, don't clears old bits in the
-	 * nodemask.
-	 */
-	smp_mb();
-	--ACCESS_ONCE(current->mems_allowed_change_disable);
+	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
 }
 
 static inline void set_mems_allowed(nodemask_t nodemask)
@@ -234,12 +220,14 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 {
 }
 
-static inline void get_mems_allowed(void)
+static inline unsigned int get_mems_allowed(void)
 {
+	return 0;
 }
 
-static inline void put_mems_allowed(void)
+static inline bool put_mems_allowed(unsigned int seq)
 {
+	return true;
 }
 
 #endif /* !CONFIG_CPUSETS */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 7d379a6..a0bb87a 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1498,7 +1498,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_CPUSETS
 	nodemask_t mems_allowed;	/* Protected by alloc_lock */
-	int mems_allowed_change_disable;
+	seqcount_t mems_allowed_seq;	/* Seqence no to catch updates */
 	int cpuset_mem_spread_rotor;
 	int cpuset_slab_spread_rotor;
 #endif
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index a09ac2b..5014493 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -964,7 +964,6 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 {
 	bool need_loop;
 
-repeat:
 	/*
 	 * Allow tasks that have access to memory reserves because they have
 	 * been OOM killed to get memory anywhere.
@@ -983,45 +982,19 @@ repeat:
 	 */
 	need_loop = task_has_mempolicy(tsk) ||
 			!nodes_intersects(*newmems, tsk->mems_allowed);
-	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
-	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
 
-	/*
-	 * ensure checking ->mems_allowed_change_disable after setting all new
-	 * allowed nodes.
-	 *
-	 * the read-side task can see an nodemask with new allowed nodes and
-	 * old allowed nodes. and if it allocates page when cpuset clears newly
-	 * disallowed ones continuous, it can see the new allowed bits.
-	 *
-	 * And if setting all new allowed nodes is after the checking, setting
-	 * all new allowed nodes and clearing newly disallowed ones will be done
-	 * continuous, and the read-side task may find no node to alloc page.
-	 */
-	smp_mb();
+	if (need_loop)
+		write_seqcount_begin(&tsk->mems_allowed_seq);
 
-	/*
-	 * Allocation of memory is very fast, we needn't sleep when waiting
-	 * for the read-side.
-	 */
-	while (need_loop && ACCESS_ONCE(tsk->mems_allowed_change_disable)) {
-		task_unlock(tsk);
-		if (!task_curr(tsk))
-			yield();
-		goto repeat;
-	}
-
-	/*
-	 * ensure checking ->mems_allowed_change_disable before clearing all new
-	 * disallowed nodes.
-	 *
-	 * if clearing newly disallowed bits before the checking, the read-side
-	 * task may find no node to alloc page.
-	 */
-	smp_mb();
+	nodes_or(tsk->mems_allowed, tsk->mems_allowed, *newmems);
+	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP1);
 
 	mpol_rebind_task(tsk, newmems, MPOL_REBIND_STEP2);
 	tsk->mems_allowed = *newmems;
+
+	if (need_loop)
+		write_seqcount_end(&tsk->mems_allowed_seq);
+
 	task_unlock(tsk);
 }
 
diff --git a/mm/filemap.c b/mm/filemap.c
index b662757..56a1e11 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -498,12 +498,15 @@ struct page *__page_cache_alloc(gfp_t gfp)
 {
 	int n;
 	struct page *page;
+	unsigned int cpuset_mems_cookie;
 
 	if (cpuset_do_page_mem_spread()) {
-		get_mems_allowed();
-		n = cpuset_mem_spread_node();
-		page = alloc_pages_exact_node(n, gfp, 0);
-		put_mems_allowed();
+		do {
+			cpuset_mems_cookie = get_mems_allowed();
+			n = cpuset_mem_spread_node();
+			page = alloc_pages_exact_node(n, gfp, 0);
+		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
+
 		return page;
 	}
 	return alloc_pages(gfp, 0);
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 5f34bd8..5f1e959 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -460,8 +460,10 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	struct zonelist *zonelist;
 	struct zone *zone;
 	struct zoneref *z;
+	unsigned int cpuset_mems_cookie;
 
-	get_mems_allowed();
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
 	zonelist = huge_zonelist(vma, address,
 					htlb_alloc_mask, &mpol, &nodemask);
 	/*
@@ -490,7 +492,8 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 	}
 err:
 	mpol_cond_put(mpol);
-	put_mems_allowed();
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		goto retry_cpuset;
 	return page;
 }
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 06b145f..013d981 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1843,18 +1843,24 @@ struct page *
 alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		unsigned long addr, int node)
 {
-	struct mempolicy *pol = get_vma_policy(current, vma, addr);
+	struct mempolicy *pol;
 	struct zonelist *zl;
 	struct page *page;
+	unsigned int cpuset_mems_cookie;
+
+retry_cpuset:
+	pol = get_vma_policy(current, vma, addr);
+	cpuset_mems_cookie = get_mems_allowed();
 
-	get_mems_allowed();
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
 
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
 		page = alloc_page_interleave(gfp, order, nid);
-		put_mems_allowed();
+		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+			goto retry_cpuset;
+
 		return page;
 	}
 	zl = policy_zonelist(gfp, pol, node);
@@ -1865,7 +1871,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		struct page *page =  __alloc_pages_nodemask(gfp, order,
 						zl, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
-		put_mems_allowed();
+		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+			goto retry_cpuset;
 		return page;
 	}
 	/*
@@ -1873,7 +1880,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	 */
 	page = __alloc_pages_nodemask(gfp, order, zl,
 				      policy_nodemask(gfp, pol));
-	put_mems_allowed();
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		goto retry_cpuset;
 	return page;
 }
 
@@ -1900,11 +1908,14 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 {
 	struct mempolicy *pol = current->mempolicy;
 	struct page *page;
+	unsigned int cpuset_mems_cookie;
 
 	if (!pol || in_interrupt() || (gfp & __GFP_THISNODE))
 		pol = &default_policy;
 
-	get_mems_allowed();
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
+
 	/*
 	 * No reference counting needed for current->mempolicy
 	 * nor system default_policy
@@ -1915,7 +1926,10 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 		page = __alloc_pages_nodemask(gfp, order,
 				policy_zonelist(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
-	put_mems_allowed();
+
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		goto retry_cpuset;
+
 	return page;
 }
 EXPORT_SYMBOL(alloc_pages_current);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d2186ec..3a667da 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2378,8 +2378,9 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone *preferred_zone;
-	struct page *page;
+	struct page *page = NULL;
 	int migratetype = allocflags_to_migratetype(gfp_mask);
+	unsigned int cpuset_mems_cookie;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2398,15 +2399,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 	if (unlikely(!zonelist->_zonerefs->zone))
 		return NULL;
 
-	get_mems_allowed();
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
+
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx,
 				nodemask ? : &cpuset_current_mems_allowed,
 				&preferred_zone);
-	if (!preferred_zone) {
-		put_mems_allowed();
-		return NULL;
-	}
+	if (!preferred_zone)
+		goto out;
 
 	/* First allocation attempt */
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
@@ -2416,9 +2417,19 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-	put_mems_allowed();
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
+
+out:
+	/*
+	 * When updating a tasks mems_allowed, it is possible to race with
+	 * parallel threads in such a way that an allocation can fail while
+	 * the mask is being updated. If a page allocation is about to fail,
+	 * check if the cpuset changed during allocation and if so, retry.
+	 */
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		goto retry_cpuset;
+
 	return page;
 }
 EXPORT_SYMBOL(__alloc_pages_nodemask);
@@ -2632,13 +2643,15 @@ void si_meminfo_node(struct sysinfo *val, int nid)
 bool skip_free_areas_node(unsigned int flags, int nid)
 {
 	bool ret = false;
+	unsigned int cpuset_mems_cookie;
 
 	if (!(flags & SHOW_MEM_FILTER_NODES))
 		goto out;
 
-	get_mems_allowed();
-	ret = !node_isset(nid, cpuset_current_mems_allowed);
-	put_mems_allowed();
+	do {
+		cpuset_mems_cookie = get_mems_allowed();
+		ret = !node_isset(nid, cpuset_current_mems_allowed);
+	} while (!put_mems_allowed(cpuset_mems_cookie));
 out:
 	return ret;
 }
diff --git a/mm/slab.c b/mm/slab.c
index f0bd785..ae2db04 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3284,12 +3284,10 @@ static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
 	if (in_interrupt() || (flags & __GFP_THISNODE))
 		return NULL;
 	nid_alloc = nid_here = numa_mem_id();
-	get_mems_allowed();
 	if (cpuset_do_slab_mem_spread() && (cachep->flags & SLAB_MEM_SPREAD))
 		nid_alloc = cpuset_slab_spread_node();
 	else if (current->mempolicy)
 		nid_alloc = slab_node(current->mempolicy);
-	put_mems_allowed();
 	if (nid_alloc != nid_here)
 		return ____cache_alloc_node(cachep, flags, nid_alloc);
 	return NULL;
@@ -3312,11 +3310,14 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
+	unsigned int cpuset_mems_cookie;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	get_mems_allowed();
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
+
 	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
@@ -3372,7 +3373,9 @@ retry:
 			}
 		}
 	}
-	put_mems_allowed();
+
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !obj))
+		goto retry_cpuset;
 	return obj;
 }
 
diff --git a/mm/slub.c b/mm/slub.c
index 4907563..ac5dddc 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1581,6 +1581,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *object;
+	unsigned int cpuset_mems_cookie;
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1604,23 +1605,24 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags,
 			get_cycles() % 1024 > s->remote_node_defrag_ratio)
 		return NULL;
 
-	get_mems_allowed();
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
-	for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
-		struct kmem_cache_node *n;
-
-		n = get_node(s, zone_to_nid(zone));
-
-		if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
-				n->nr_partial > s->min_partial) {
-			object = get_partial_node(s, n, c);
-			if (object) {
-				put_mems_allowed();
-				return object;
+	do {
+		cpuset_mems_cookie = get_mems_allowed();
+		zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
+			struct kmem_cache_node *n;
+
+			n = get_node(s, zone_to_nid(zone));
+
+			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
+					n->nr_partial > s->min_partial) {
+				object = get_partial_node(s, n, c);
+				if (object) {
+					put_mems_allowed(cpuset_mems_cookie);
+					return object;
+				}
 			}
 		}
-	}
-	put_mems_allowed();
+	} while (!put_mems_allowed(cpuset_mems_cookie));
 #endif
 	return NULL;
 }
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c52b235..fccc048 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2337,7 +2337,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long writeback_threshold;
 	bool aborted_reclaim;
 
-	get_mems_allowed();
 	delayacct_freepages_start();
 
 	if (global_reclaim(sc))
@@ -2401,7 +2400,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 out:
 	delayacct_freepages_end();
-	put_mems_allowed();
 
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
