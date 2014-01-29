Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f53.google.com (mail-wg0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 74ECB6B0031
	for <linux-mm@kvack.org>; Wed, 29 Jan 2014 08:58:06 -0500 (EST)
Received: by mail-wg0-f53.google.com with SMTP id y10so3648171wgg.32
        for <linux-mm@kvack.org>; Wed, 29 Jan 2014 05:58:06 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cl9si1499061wib.5.2014.01.29.05.58.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 29 Jan 2014 05:58:05 -0800 (PST)
Date: Wed, 29 Jan 2014 13:58:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH RESEND] mm: Optimize put_mems_allowed() usage
Message-ID: <20140129135801.GE6732@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>

This is a resend of an old patch of Peter's. It lived in Andrew's
tree and one point and in the tip tree at another but never made it to
mainline. I suspect it fell between the tracks because the patch itself
is not objectionable.

---8<---
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: mm: Optimize put_mems_allowed() usage

Since put_mems_allowed() is strictly optional, its a seqcount retry,
we don't need to evaluate the function if the allocation was in fact
successful, saving a smp_rmb some loads and comparisons on some
relative fast-paths.

Since the naming, get/put_mems_allowed() does suggest a mandatory
pairing, rename the interface, as suggested by Mel, to resemble the
seqcount interface.

This gives us: read_mems_allowed_begin() and
read_mems_allowed_retry(), where it is important to note that the
return value of the latter call is inverted from its previous
incarnation.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/cpuset.h | 27 ++++++++++++++-------------
 kernel/cpuset.c        |  2 +-
 mm/filemap.c           |  4 ++--
 mm/hugetlb.c           |  4 ++--
 mm/mempolicy.c         | 12 ++++++------
 mm/page_alloc.c        |  8 ++++----
 mm/slab.c              |  4 ++--
 mm/slub.c              | 16 +++++++---------
 8 files changed, 38 insertions(+), 39 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 3fe661f..b19d3dc 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -87,25 +87,26 @@ extern void rebuild_sched_domains(void);
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
 
 /*
- * get_mems_allowed is required when making decisions involving mems_allowed
- * such as during page allocation. mems_allowed can be updated in parallel
- * and depending on the new value an operation can fail potentially causing
- * process failure. A retry loop with get_mems_allowed and put_mems_allowed
- * prevents these artificial failures.
+ * read_mems_allowed_begin is required when making decisions involving
+ * mems_allowed such as during page allocation. mems_allowed can be updated in
+ * parallel and depending on the new value an operation can fail potentially
+ * causing process failure. A retry loop with read_mems_allowed_begin and
+ * read_mems_allowed_retry prevents these artificial failures.
  */
-static inline unsigned int get_mems_allowed(void)
+static inline unsigned int read_mems_allowed_begin(void)
 {
 	return read_seqcount_begin(&current->mems_allowed_seq);
 }
 
 /*
- * If this returns false, the operation that took place after get_mems_allowed
- * may have failed. It is up to the caller to retry the operation if
+ * If this returns true, the operation that took place after
+ * read_mems_allowed_begin may have failed artificially due to a concurrent
+ * update of mems_allowed. It is up to the caller to retry the operation if
  * appropriate.
  */
-static inline bool put_mems_allowed(unsigned int seq)
+static inline bool read_mems_allowed_retry(unsigned int seq)
 {
-	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
+	return read_seqcount_retry(&current->mems_allowed_seq, seq);
 }
 
 static inline void set_mems_allowed(nodemask_t nodemask)
@@ -225,14 +226,14 @@ static inline void set_mems_allowed(nodemask_t nodemask)
 {
 }
 
-static inline unsigned int get_mems_allowed(void)
+static inline unsigned int read_mems_allowed_begin(void)
 {
 	return 0;
 }
 
-static inline bool put_mems_allowed(unsigned int seq)
+static inline bool read_mems_allowed_retry(unsigned int seq)
 {
-	return true;
+	return false;
 }
 
 #endif /* !CONFIG_CPUSETS */
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 4772034..f44d21e 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -1026,7 +1026,7 @@ static void cpuset_change_task_nodemask(struct task_struct *tsk,
 	task_lock(tsk);
 	/*
 	 * Determine if a loop is necessary if another thread is doing
-	 * get_mems_allowed().  If at least one node remains unchanged and
+	 * read_mems_allowed_begin().  If at least one node remains unchanged and
 	 * tsk does not have a mempolicy, then an empty nodemask will not be
 	 * possible when mems_allowed is larger than a word.
 	 */
diff --git a/mm/filemap.c b/mm/filemap.c
index b7749a9..5d53cd3 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -520,10 +520,10 @@ struct page *__page_cache_alloc(gfp_t gfp)
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
-			cpuset_mems_cookie = get_mems_allowed();
+			cpuset_mems_cookie = read_mems_allowed_begin();
 			n = cpuset_mem_spread_node();
 			page = alloc_pages_exact_node(n, gfp, 0);
-		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
+		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
 
 		return page;
 	}
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index dee6cf4..0c1fe51 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -540,7 +540,7 @@ static struct page *dequeue_huge_page_vma(struct hstate *h,
 		goto err;
 
 retry_cpuset:
-	cpuset_mems_cookie = get_mems_allowed();
+	cpuset_mems_cookie = read_mems_allowed_begin();
 	zonelist = huge_zonelist(vma, address,
 					htlb_alloc_mask(h), &mpol, &nodemask);
 
@@ -562,7 +562,7 @@ retry_cpuset:
 	}
 
 	mpol_cond_put(mpol);
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0cd2c4d..745fb70 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1902,7 +1902,7 @@ int node_random(const nodemask_t *maskp)
  * If the effective policy is 'BIND, returns a pointer to the mempolicy's
  * @nodemask for filtering the zonelist.
  *
- * Must be protected by get_mems_allowed()
+ * Must be protected by read_mems_allowed_begin()
  */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long addr,
 				gfp_t gfp_flags, struct mempolicy **mpol,
@@ -2066,7 +2066,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
 
 retry_cpuset:
 	pol = get_vma_policy(current, vma, addr);
-	cpuset_mems_cookie = get_mems_allowed();
+	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	if (unlikely(pol->mode == MPOL_INTERLEAVE)) {
 		unsigned nid;
@@ -2074,7 +2074,7 @@ retry_cpuset:
 		nid = interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
 		page = alloc_page_interleave(gfp, order, nid);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 			goto retry_cpuset;
 
 		return page;
@@ -2084,7 +2084,7 @@ retry_cpuset:
 				      policy_nodemask(gfp, pol));
 	if (unlikely(mpol_needs_cond_ref(pol)))
 		__mpol_put(pol);
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
 }
@@ -2118,7 +2118,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned order)
 		pol = &default_policy;
 
 retry_cpuset:
-	cpuset_mems_cookie = get_mems_allowed();
+	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	/*
 	 * No reference counting needed for current->mempolicy
@@ -2131,7 +2131,7 @@ retry_cpuset:
 				policy_zonelist(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
 
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
 	return page;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5248fe0..dd98837 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2697,7 +2697,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 retry_cpuset:
-	cpuset_mems_cookie = get_mems_allowed();
+	cpuset_mems_cookie = read_mems_allowed_begin();
 
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx,
@@ -2735,7 +2735,7 @@ out:
 	 * the mask is being updated. If a page allocation is about to fail,
 	 * check if the cpuset changed during allocation and if so, retry.
 	 */
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 
 	memcg_kmem_commit_charge(page, memcg, order);
@@ -3003,9 +3003,9 @@ bool skip_free_areas_node(unsigned int flags, int nid)
 		goto out;
 
 	do {
-		cpuset_mems_cookie = get_mems_allowed();
+		cpuset_mems_cookie = read_mems_allowed_begin();
 		ret = !node_isset(nid, cpuset_current_mems_allowed);
-	} while (!put_mems_allowed(cpuset_mems_cookie));
+	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 out:
 	return ret;
 }
diff --git a/mm/slab.c b/mm/slab.c
index eb043bf..dc4b0e8 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3073,7 +3073,7 @@ static void *fallback_alloc(struct kmem_cache *cache, gfp_t flags)
 	local_flags = flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
 
 retry_cpuset:
-	cpuset_mems_cookie = get_mems_allowed();
+	cpuset_mems_cookie = read_mems_allowed_begin();
 	zonelist = node_zonelist(slab_node(), flags);
 
 retry:
@@ -3131,7 +3131,7 @@ retry:
 		}
 	}
 
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !obj))
+	if (unlikely(!obj && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return obj;
 }
diff --git a/mm/slub.c b/mm/slub.c
index 545a170..367a97f 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1662,7 +1662,7 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 		return NULL;
 
 	do {
-		cpuset_mems_cookie = get_mems_allowed();
+		cpuset_mems_cookie = read_mems_allowed_begin();
 		zonelist = node_zonelist(slab_node(), flags);
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
@@ -1674,19 +1674,17 @@ static void *get_any_partial(struct kmem_cache *s, gfp_t flags,
 				object = get_partial_node(s, n, c, flags);
 				if (object) {
 					/*
-					 * Return the object even if
-					 * put_mems_allowed indicated that
-					 * the cpuset mems_allowed was
-					 * updated in parallel. It's a
-					 * harmless race between the alloc
-					 * and the cpuset update.
+					 * Don't check read_mems_allowed_retry()
+					 * here - if mems_allowed was updated in
+					 * parallel, that was a harmless race
+					 * between allocation and the cpuset
+					 * update
 					 */
-					put_mems_allowed(cpuset_mems_cookie);
 					return object;
 				}
 			}
 		}
-	} while (!put_mems_allowed(cpuset_mems_cookie));
+	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 #endif
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
