Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 1FFB16B008C
	for <linux-mm@kvack.org>; Thu, 19 Jul 2012 10:37:08 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 33/34] cpuset: mm: Reduce large amounts of memory barrier related damage v3
Date: Thu, 19 Jul 2012 15:36:43 +0100
Message-Id: <1342708604-26540-34-git-send-email-mgorman@suse.de>
In-Reply-To: <1342708604-26540-1-git-send-email-mgorman@suse.de>
References: <1342708604-26540-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stable <stable@vger.kernel.org>
Cc: "Linux-MM <linux-mm"@kvack.org, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

commit cc9a6c8776615f9c194ccf0b63a0aa5628235545 upstream.

Stable note:  Not tracked in Bugzilla. [get|put]_mems_allowed() is extremely
	expensive and severely impacted page allocator performance. This
	is part of a series of patches that reduce page allocator overhead.

Changelog since V2
  o Documentation						(akpm)
  o Do not retry hugetlb allocations in the event of an error	(akpm)

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
 include/linux/cpuset.h    |   45 ++++++++++++++++++---------------------------
 include/linux/init_task.h |    8 ++++++++
 include/linux/sched.h     |    2 +-
 kernel/cpuset.c           |   43 ++++++++-----------------------------------
 kernel/fork.c             |    3 +++
 mm/filemap.c              |   11 +++++++----
 mm/hugetlb.c              |   15 +++++++++++----
 mm/mempolicy.c            |   28 +++++++++++++++++++++-------
 mm/page_alloc.c           |   33 +++++++++++++++++++++++----------
 mm/slab.c                 |   13 ++++++++-----
 mm/slub.c                 |   39 +++++++++++++++++++++++++--------------
 mm/vmscan.c               |    2 --
 12 files changed, 133 insertions(+), 109 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index e9eaec5..8f15695 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -89,36 +89,25 @@ extern void rebuild_sched_domains(void);
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 
 /*
- * reading current mems_allowed and mempolicy in the fastpath must protected
- * by get_mems_allowed()
+ * get_mems_allowed is required when making decisions involving mems_allowed
+ * such as during page allocation. mems_allowed can be updated in parallel
+ * and depending on the new value an operation can fail potentially causing
+ * process failure. A retry loop with get_mems_allowed and put_mems_allowed
+ * prevents these artificial failures.
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
+ * appropriate.
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
@@ -234,12 +223,14 @@ static inline void set_mems_allowed(nodemask_t nodemask)
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
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index 580f70c..5e41a8e 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -30,6 +30,13 @@ extern struct fs_struct init_fs;
 #define INIT_THREADGROUP_FORK_LOCK(sig)
 #endif
 
+#ifdef CONFIG_CPUSETS
+#define INIT_CPUSET_SEQ							\
+	.mems_allowed_seq = SEQCNT_ZERO,
+#else
+#define INIT_CPUSET_SEQ
+#endif
+
 #define INIT_SIGNALS(sig) {						\
 	.nr_threads	= 1,						\
 	.wait_chldexit	= __WAIT_QUEUE_HEAD_INITIALIZER(sig.wait_chldexit),\
@@ -193,6 +200,7 @@ extern struct cred init_cred;
 	INIT_FTRACE_GRAPH						\
 	INIT_TRACE_RECURSION						\
 	INIT_TASK_RCU_PREEMPT(tsk)					\
+	INIT_CPUSET_SEQ							\
 }
 
 
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 4ef452b..443ec43 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1484,7 +1484,7 @@ struct task_struct {
 #endif
 #ifdef CONFIG_CPUSETS
 	nodemask_t mems_allowed;	/* Protected by alloc_lock */
-	int mems_allowed_change_disable;
+	seqcount_t mems_allowed_seq;	/* Seqence no to catch updates */
 	int cpuset_mem_spread_rotor;
 	int cpuset_slab_spread_rotor;
 #endif
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 28d0bbd..b2e84bd 100644
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
 
diff --git a/kernel/fork.c b/kernel/fork.c
index 4712e3e..3d42aa3 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -985,6 +985,9 @@ static int copy_signal(unsigned long clone_flags, struct task_struct *tsk)
 #ifdef CONFIG_CGROUPS
 	init_rwsem(&sig->threadgroup_fork_lock);
 #endif
+#ifdef CONFIG_CPUSETS
+	seqcount_init(&tsk->mems_allowed_seq);
+#endif
 
 	sig->oom_adj = current->signal->oom_adj;
 	sig->oom_score_adj = current->signal->oom_score_adj;
diff --git a/mm/filemap.c b/mm/filemap.c
index b7d8603..10481eb 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -516,10 +516,13 @@ struct page *__page_cache_alloc(gfp_t gfp)
 	struct page *page;
 
 	if (cpuset_do_page_mem_spread()) {
-		get_mems_allowed();
-		n = cpuset_mem_spread_node();
-		page = alloc_pages_exact_node(n, gfp, 0);
-		put_mems_allowed();
+		unsigned int cpuset_mems_cookie;
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
index 05f8fd4..64f2b7a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -454,14 +454,16 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 				struct vm_area_struct *vma,
 				unsigned long address, int avoid_reserve)
 {
-	struct page *page = NULL;
+	struct page *page;
 	struct mempolicy *mpol;
 	nodemask_t *nodemask;
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
@@ -488,10 +490,15 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 			}
 		}
 	}
-err:
+
 	mpol_cond_put(mpol);
-	put_mems_allowed();
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		goto retry_cpuset;
 	return page;
+
+err:
+	mpol_cond_put(mpol);
+	return NULL;
 }
 
 static void update_and_free_page(struct hstate *h, struct page *page)
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index dd5f874..cff919f 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1810,18 +1810,24 @@ struct page *
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
@@ -1832,7 +1838,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 		struct page *page =  __alloc_pages_nodemask(gfp, order,
 						zl, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
-		put_mems_allowed();
+		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+			goto retry_cpuset;
 		return page;
 	}
 	/*
@@ -1840,7 +1847,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 	 */
 	page = __alloc_pages_nodemask(gfp, order, zl,
 				      policy_nodemask(gfp, pol));
-	put_mems_allowed();
+	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		goto retry_cpuset;
 	return page;
 }
 
@@ -1867,11 +1875,14 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
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
@@ -1882,7 +1893,10 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
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
index 257acae..a1744f5 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2293,8 +2293,9 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 {
 	enum zone_type high_zoneidx = gfp_zone(gfp_mask);
 	struct zone *preferred_zone;
-	struct page *page;
+	struct page *page = NULL;
 	int migratetype = allocflags_to_migratetype(gfp_mask);
+	unsigned int cpuset_mems_cookie;
 
 	gfp_mask &= gfp_allowed_mask;
 
@@ -2313,15 +2314,15 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
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
@@ -2331,9 +2332,19 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
-	put_mems_allowed();
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
+
+out:
+	/*
+	 * When updating a task's mems_allowed, it is possible to race with
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
@@ -2557,13 +2568,15 @@ void si_meminfo_node(struct sysinfo *val, int nid)
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
index d96e223..a67f812 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3218,12 +3218,10 @@ static void *alternate_node_alloc(struct kmem_cache *cachep, gfp_t flags)
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
@@ -3246,14 +3244,17 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	void *obj = NULL;
 	int nid;
+	unsigned int cpuset_mems_cookie;
 
 	if (flags & __GFP_THISNODE)
 		return NULL;
 
-	get_mems_allowed();
-	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
+retry_cpuset:
+	cpuset_mems_cookie = get_mems_allowed();
+	zonelist = node_zonelist(slab_node(current->mempolicy), flags);
+
 retry:
 	/*
 	 * Look through allowed nodes for objects available
@@ -3306,7 +3307,9 @@ retry:
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
index 10ab233..00ccf2c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1457,6 +1457,7 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
 	struct zone *zone;
 	enum zone_type high_zoneidx = gfp_zone(flags);
 	struct page *page;
+	unsigned int cpuset_mems_cookie;
 
 	/*
 	 * The defrag ratio allows a configuration of the tradeoffs between
@@ -1480,22 +1481,32 @@ static struct page *get_any_partial(struct kmem_cache *s, gfp_t flags)
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
-			page = get_partial_node(n);
-			if (page) {
-				put_mems_allowed();
-				return page;
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
+				page = get_partial_node(n);
+				if (page) {
+					/*
+					 * Return the object even if
+					 * put_mems_allowed indicated that
+					 * the cpuset mems_allowed was
+					 * updated in parallel. It's a
+					 * harmless race between the alloc
+					 * and the cpuset update.
+					 */
+					put_mems_allowed(cpuset_mems_cookie);
+					return page;
+				}
 			}
 		}
-	}
+	} while (!put_mems_allowed(cpuset_mems_cookie));
 	put_mems_allowed();
 #endif
 	return NULL;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 49d8547..1682835 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2247,7 +2247,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	unsigned long writeback_threshold;
 	bool aborted_reclaim;
 
-	get_mems_allowed();
 	delayacct_freepages_start();
 
 	if (scanning_global_lru(sc))
@@ -2310,7 +2309,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 
 out:
 	delayacct_freepages_end();
-	put_mems_allowed();
 
 	if (sc->nr_reclaimed)
 		return sc->nr_reclaimed;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
