Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 7C0766B0092
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 09:14:37 -0400 (EDT)
Message-ID: <1332854070.16159.223.camel@twins>
Subject: [PATCH] mm: Optimize put_mems_allowed() usage
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 27 Mar 2012 15:14:30 +0200
In-Reply-To: <20120327124734.GH16573@suse.de>
References: <20120307180852.GE17697@suse.de>
	 <1332759384.16159.92.camel@twins> <20120326155027.GF16573@suse.de>
	 <1332778852.16159.138.camel@twins> <20120327124734.GH16573@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Subject: mm: Optimize put_mems_allowed() usage
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon Mar 26 14:13:05 CEST 2012

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

Acked-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 include/linux/cpuset.h |   27 ++++++++++++++-------------
 kernel/cpuset.c        |    2 +-
 mm/filemap.c           |    4 ++--
 mm/hugetlb.c           |    4 ++--
 mm/mempolicy.c         |   14 +++++++-------
 mm/page_alloc.c        |    8 ++++----
 mm/slab.c              |    4 ++--
 mm/slub.c              |   16 +++-------------
 8 files changed, 35 insertions(+), 44 deletions(-)

--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -89,25 +89,26 @@ extern void rebuild_sched_domains(void);
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
=20
 /*
- * get_mems_allowed is required when making decisions involving mems_allow=
ed
- * such as during page allocation. mems_allowed can be updated in parallel
- * and depending on the new value an operation can fail potentially causin=
g
- * process failure. A retry loop with get_mems_allowed and put_mems_allowe=
d
- * prevents these artificial failures.
+ * read_mems_allowed_begin is required when making decisions involving
+ * mems_allowed such as during page allocation. mems_allowed can be update=
d in
+ * parallel and depending on the new value an operation can fail potential=
ly
+ * causing process failure. A retry loop with read_mems_allowed_begin and
+ * read_mems_allowed_retry prevents these artificial failures.
  */
-static inline unsigned int get_mems_allowed(void)
+static inline unsigned int read_mems_allowed_begin(void)
 {
 	return read_seqcount_begin(&current->mems_allowed_seq);
 }
=20
 /*
- * If this returns false, the operation that took place after get_mems_all=
owed
- * may have failed. It is up to the caller to retry the operation if
+ * If this returns true, the operation that took place after
+ * read_mems_allowed_begin may have failed artificially due to a concurren=
t
+ * update of mems_allowed. It is up to the caller to retry the operation i=
f
  * appropriate.
  */
-static inline bool put_mems_allowed(unsigned int seq)
+static inline bool read_mems_allowed_retry(unsigned int seq)
 {
-	return !read_seqcount_retry(&current->mems_allowed_seq, seq);
+	return read_seqcount_retry(&current->mems_allowed_seq, seq);
 }
=20
 static inline void set_mems_allowed(nodemask_t nodemask)
@@ -225,14 +226,14 @@ static inline void set_mems_allowed(node
 {
 }
=20
-static inline unsigned int get_mems_allowed(void)
+static inline unsigned int read_mems_allowed_begin(void)
 {
 	return 0;
 }
=20
-static inline bool put_mems_allowed(unsigned int seq)
+static inline bool read_mems_allowed_retry(unsigned int seq)
 {
-	return true;
+	return false;
 }
=20
 #endif /* !CONFIG_CPUSETS */
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -976,7 +976,7 @@ static void cpuset_change_task_nodemask(
 	task_lock(tsk);
 	/*
 	 * Determine if a loop is necessary if another thread is doing
-	 * get_mems_allowed().  If at least one node remains unchanged and
+	 * read_mems_allowed_begin().  If at least one node remains unchanged and
 	 * tsk does not have a mempolicy, then an empty nodemask will not be
 	 * possible when mems_allowed is larger than a word.
 	 */
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -501,10 +501,10 @@ struct page *__page_cache_alloc(gfp_t gf
 	if (cpuset_do_page_mem_spread()) {
 		unsigned int cpuset_mems_cookie;
 		do {
-			cpuset_mems_cookie =3D get_mems_allowed();
+			cpuset_mems_cookie =3D read_mems_allowed_begin();
 			n =3D cpuset_mem_spread_node();
 			page =3D alloc_pages_exact_node(n, gfp, 0);
-		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
+		} while (!page && read_mems_allowed_retry(cpuset_mems_cookie));
=20
 		return page;
 	}
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -541,7 +541,7 @@ static struct page *dequeue_huge_page_vm
 	unsigned int cpuset_mems_cookie;
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
 	zonelist =3D huge_zonelist(vma, address,
 					htlb_alloc_mask, &mpol, &nodemask);
 	/*
@@ -570,7 +570,7 @@ static struct page *dequeue_huge_page_vm
 	}
=20
 	mpol_cond_put(mpol);
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
=20
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1692,7 +1692,7 @@ int node_random(const nodemask_t *maskp)
  * If the effective policy is 'BIND, returns a pointer to the mempolicy's
  * @nodemask for filtering the zonelist.
  *
- * Must be protected by get_mems_allowed()
+ * Must be protected by read_mems_allowed_begin()
  */
 struct zonelist *huge_zonelist(struct vm_area_struct *vma, unsigned long a=
ddr,
 				gfp_t gfp_flags, struct mempolicy **mpol,
@@ -1857,7 +1857,7 @@ alloc_pages_vma(gfp_t gfp, int order, st
=20
 retry_cpuset:
 	pol =3D get_vma_policy(current, vma, addr);
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
=20
 	if (unlikely(pol->mode =3D=3D MPOL_INTERLEAVE)) {
 		unsigned nid;
@@ -1865,7 +1865,7 @@ alloc_pages_vma(gfp_t gfp, int order, st
 		nid =3D interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
 		page =3D alloc_page_interleave(gfp, order, nid);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 			goto retry_cpuset;
=20
 		return page;
@@ -1878,7 +1878,7 @@ alloc_pages_vma(gfp_t gfp, int order, st
 		struct page *page =3D  __alloc_pages_nodemask(gfp, order,
 						zl, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 			goto retry_cpuset;
 		return page;
 	}
@@ -1887,7 +1887,7 @@ alloc_pages_vma(gfp_t gfp, int order, st
 	 */
 	page =3D __alloc_pages_nodemask(gfp, order, zl,
 				      policy_nodemask(gfp, pol));
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
 }
@@ -1921,7 +1921,7 @@ struct page *alloc_pages_current(gfp_t g
 		pol =3D &default_policy;
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
=20
 	/*
 	 * No reference counting needed for current->mempolicy
@@ -1934,7 +1934,7 @@ struct page *alloc_pages_current(gfp_t g
 				policy_zonelist(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
=20
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
=20
 	return page;
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2402,7 +2402,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
 		return NULL;
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
=20
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx,
@@ -2429,7 +2429,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
 	 * the mask is being updated. If a page allocation is about to fail,
 	 * check if the cpuset changed during allocation and if so, retry.
 	 */
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
=20
 	return page;
@@ -2651,9 +2651,9 @@ bool skip_free_areas_node(unsigned int f
 		goto out;
=20
 	do {
-		cpuset_mems_cookie =3D get_mems_allowed();
+		cpuset_mems_cookie =3D read_mems_allowed_begin();
 		ret =3D !node_isset(nid, cpuset_current_mems_allowed);
-	} while (!put_mems_allowed(cpuset_mems_cookie));
+	} while (read_mems_allowed_retry(cpuset_mems_cookie));
 out:
 	return ret;
 }
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3318,7 +3318,7 @@ static void *fallback_alloc(struct kmem_
 	local_flags =3D flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
 	zonelist =3D node_zonelist(slab_node(current->mempolicy), flags);
=20
 retry:
@@ -3374,7 +3374,7 @@ static void *fallback_alloc(struct kmem_
 		}
 	}
=20
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !obj))
+	if (unlikely(!obj && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return obj;
 }
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1606,7 +1606,7 @@ static struct page *get_any_partial(stru
 		return NULL;
=20
 	do {
-		cpuset_mems_cookie =3D get_mems_allowed();
+		cpuset_mems_cookie =3D read_mems_allowed_begin();
 		zonelist =3D node_zonelist(slab_node(current->mempolicy), flags);
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
@@ -1616,21 +1616,11 @@ static struct page *get_any_partial(stru
 			if (n && cpuset_zone_allowed_hardwall(zone, flags) &&
 					n->nr_partial > s->min_partial) {
 				object =3D get_partial_node(s, n, c);
-				if (object) {
-					/*
-					 * Return the object even if
-					 * put_mems_allowed indicated that
-					 * the cpuset mems_allowed was
-					 * updated in parallel. It's a
-					 * harmless race between the alloc
-					 * and the cpuset update.
-					 */
-					put_mems_allowed(cpuset_mems_cookie);
+				if (object)
 					return object;
-				}
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
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
