Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 599136B0044
	for <linux-mm@kvack.org>; Mon, 26 Mar 2012 13:05:57 -0400 (EDT)
Message-ID: <1332778852.16159.138.camel@twins>
Subject: Re: [PATCH] cpuset: mm: Reduce large amounts of memory barrier
 related damage v3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 26 Mar 2012 18:20:52 +0200
In-Reply-To: <20120326155027.GF16573@suse.de>
References: <20120307180852.GE17697@suse.de>
	 <1332759384.16159.92.camel@twins> <20120326155027.GF16573@suse.de>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Miao Xie <miaox@cn.fujitsu.com>, David Rientjes <rientjes@google.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, 2012-03-26 at 16:50 +0100, Mel Gorman wrote:
> On Mon, Mar 26, 2012 at 12:56:24PM +0200, Peter Zijlstra wrote:
> > On Wed, 2012-03-07 at 18:08 +0000, Mel Gorman wrote:
> > > +               } while (!put_mems_allowed(cpuset_mems_cookie) && !pa=
ge);
> >=20
> > Sorry for only noticing this now, but wouldn't it be better to first
> > check page and only then bother with the put_mems_allowed() thing? That
> > avoids the smp_rmb() and seqcount conditional all together in the likel=
y
> > case the allocation actually succeeded.
> >=20
> > <SNIP>
> >
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index c3811bc..3b41553 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -504,7 +504,7 @@ struct page *__page_cache_alloc(gfp_t gfp)
> >  			cpuset_mems_cookie =3D get_mems_allowed();
> >  			n =3D cpuset_mem_spread_node();
> >  			page =3D alloc_pages_exact_node(n, gfp, 0);
> > -		} while (!put_mems_allowed(cpuset_mems_cookie) && !page);
> > +		} while (!page && !put_mems_allowed(cpuset_mems_cookie));
> > =20
> >  		return page;
> >  	}
>=20
> I think such a change would be better but should also rename the API.
> If developers see a get_foo type call, they will expect to see a put_foo
> call or assume it's a bug even though the implementation happens to be ok
> with that. Any suggestion on what a good new name would be?
>=20
> How about read_mems_allowed_begin() and read_mems_allowed_retry()?
>=20
> read_mems_allowed_begin would be a rename of get_mems_allowed().  In an
> error path, read_mems_allowed_retry() would documented to be *optionally*
> called when deciding whether to retry the operation or not. In this schem=
e,
> !put_mems_allowed would become read_mems_allowed_retry() which might be
> a bit easier to read overall.

One:

git grep -l "\(get\|put\)_mems_allowed" | while read file; do sed -i -e
's/\<get_mems_allowed\>/read_mems_allowed_begin/g' -e
's/\<put_mems_allowed\>/read_mems_allowed_retry/g' $file; done

and a few edits later..

---
 include/linux/cpuset.h |   18 +++++++++---------
 kernel/cpuset.c        |    2 +-
 mm/filemap.c           |    4 ++--
 mm/hugetlb.c           |    4 ++--
 mm/mempolicy.c         |   14 +++++++-------
 mm/page_alloc.c        |    8 ++++----
 mm/slab.c              |    4 ++--
 mm/slub.c              |   16 +++-------------
 8 files changed, 30 insertions(+), 40 deletions(-)

diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index 7a7e5fd..d008b03 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -89,25 +89,25 @@ extern void rebuild_sched_domains(void);
 extern void cpuset_print_task_mems_allowed(struct task_struct *p);
=20
 /*
- * get_mems_allowed is required when making decisions involving mems_allow=
ed
+ * read_mems_allowed_begin is required when making decisions involving mem=
s_allowed
  * such as during page allocation. mems_allowed can be updated in parallel
  * and depending on the new value an operation can fail potentially causin=
g
- * process failure. A retry loop with get_mems_allowed and put_mems_allowe=
d
+ * process failure. A retry loop with read_mems_allowed_begin and read_mem=
s_allowed_retry
  * prevents these artificial failures.
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
+ * If this returns false, the operation that took place after read_mems_al=
lowed_begin
  * may have failed. It is up to the caller to retry the operation if
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
@@ -225,14 +225,14 @@ static inline void set_mems_allowed(nodemask_t nodema=
sk)
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
diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 1010cc6..703df59 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -976,7 +976,7 @@ static void cpuset_change_task_nodemask(struct task_str=
uct *tsk,
 	task_lock(tsk);
 	/*
 	 * Determine if a loop is necessary if another thread is doing
-	 * get_mems_allowed().  If at least one node remains unchanged and
+	 * read_mems_allowed_begin().  If at least one node remains unchanged and
 	 * tsk does not have a mempolicy, then an empty nodemask will not be
 	 * possible when mems_allowed is larger than a word.
 	 */
diff --git a/mm/filemap.c b/mm/filemap.c
index c3811bc..5694807 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -501,10 +501,10 @@ struct page *__page_cache_alloc(gfp_t gfp)
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
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index b8ce6f4..6c52f6a 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -541,7 +541,7 @@ static struct page *dequeue_huge_page_vma(struct hstate=
 *h,
 	unsigned int cpuset_mems_cookie;
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
 	zonelist =3D huge_zonelist(vma, address,
 					htlb_alloc_mask, &mpol, &nodemask);
 	/*
@@ -570,7 +570,7 @@ static struct page *dequeue_huge_page_vma(struct hstate=
 *h,
 	}
=20
 	mpol_cond_put(mpol);
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
=20
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index cfb6c86..ee5f48c 100644
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
@@ -1857,7 +1857,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_=
struct *vma,
=20
 retry_cpuset:
 	pol =3D get_vma_policy(current, vma, addr);
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
=20
 	if (unlikely(pol->mode =3D=3D MPOL_INTERLEAVE)) {
 		unsigned nid;
@@ -1865,7 +1865,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_=
struct *vma,
 		nid =3D interleave_nid(pol, vma, addr, PAGE_SHIFT + order);
 		mpol_cond_put(pol);
 		page =3D alloc_page_interleave(gfp, order, nid);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 			goto retry_cpuset;
=20
 		return page;
@@ -1878,7 +1878,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_=
struct *vma,
 		struct page *page =3D  __alloc_pages_nodemask(gfp, order,
 						zl, policy_nodemask(gfp, pol));
 		__mpol_put(pol);
-		if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+		if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 			goto retry_cpuset;
 		return page;
 	}
@@ -1887,7 +1887,7 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_=
struct *vma,
 	 */
 	page =3D __alloc_pages_nodemask(gfp, order, zl,
 				      policy_nodemask(gfp, pol));
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return page;
 }
@@ -1921,7 +1921,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned =
order)
 		pol =3D &default_policy;
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
=20
 	/*
 	 * No reference counting needed for current->mempolicy
@@ -1934,7 +1934,7 @@ struct page *alloc_pages_current(gfp_t gfp, unsigned =
order)
 				policy_zonelist(gfp, pol, numa_node_id()),
 				policy_nodemask(gfp, pol));
=20
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
=20
 	return page;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index caea788..b586d96 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2402,7 +2402,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int o=
rder,
 		return NULL;
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
=20
 	/* The preferred zone is used for statistics later */
 	first_zones_zonelist(zonelist, high_zoneidx,
@@ -2429,7 +2429,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int o=
rder,
 	 * the mask is being updated. If a page allocation is about to fail,
 	 * check if the cpuset changed during allocation and if so, retry.
 	 */
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !page))
+	if (unlikely(!page && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
=20
 	return page;
@@ -2651,9 +2651,9 @@ bool skip_free_areas_node(unsigned int flags, int nid=
)
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
diff --git a/mm/slab.c b/mm/slab.c
index 29c8716..e5a4533 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3318,7 +3318,7 @@ static void *fallback_alloc(struct kmem_cache *cache,=
 gfp_t flags)
 	local_flags =3D flags & (GFP_CONSTRAINT_MASK|GFP_RECLAIM_MASK);
=20
 retry_cpuset:
-	cpuset_mems_cookie =3D get_mems_allowed();
+	cpuset_mems_cookie =3D read_mems_allowed_begin();
 	zonelist =3D node_zonelist(slab_node(current->mempolicy), flags);
=20
 retry:
@@ -3374,7 +3374,7 @@ static void *fallback_alloc(struct kmem_cache *cache,=
 gfp_t flags)
 		}
 	}
=20
-	if (unlikely(!put_mems_allowed(cpuset_mems_cookie) && !obj))
+	if (unlikely(!obj && read_mems_allowed_retry(cpuset_mems_cookie)))
 		goto retry_cpuset;
 	return obj;
 }
diff --git a/mm/slub.c b/mm/slub.c
index f4a6229..7a158be 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1606,7 +1606,7 @@ static struct page *get_any_partial(struct kmem_cache=
 *s, gfp_t flags,
 		return NULL;
=20
 	do {
-		cpuset_mems_cookie =3D get_mems_allowed();
+		cpuset_mems_cookie =3D read_mems_allowed_begin();
 		zonelist =3D node_zonelist(slab_node(current->mempolicy), flags);
 		for_each_zone_zonelist(zone, z, zonelist, high_zoneidx) {
 			struct kmem_cache_node *n;
@@ -1616,21 +1616,11 @@ static struct page *get_any_partial(struct kmem_cac=
he *s, gfp_t flags,
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
