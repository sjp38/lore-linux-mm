Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 1582F6B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 14:58:26 -0500 (EST)
Date: Fri, 21 Dec 2012 19:58:17 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy
 tree
Message-ID: <20121221195817.GE13367@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org>
 <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
 <20121221134740.GC13367@suse.de>
 <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CA+55aFxrdPpMWLD8LF0NNqgJqmB-L-HW3Xyxht6e5AwnoaueTw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Fri, Dec 21, 2012 at 08:53:33AM -0800, Linus Torvalds wrote:
> > Jeez, I'm still not keen on that approach for the reasons that are explained
> > in the changelog for b22d127a39dd.
> 
> Christ, Mel.
> 
> Your reasons in b22d127a39dd are weak as hell, and then you come up
> with *THIS* shit instead:
> 

The complaint about duplicated code was based on the fact that the mempolicy
code was a complete mess and duplicating code did not help. I'll accept
that it's weak.

> > That leads to this third *ugly* option that conditionally drops the lock
> > and it's up to the caller to figure out what happened. Fooling around with
> > how it conditionally releases the lock results in different sorts of ugly.
> > We now have three ugly sister patches for this. Who wants to be Cinderalla?
> >
> > ---8<---
> > mm: numa: Release the PTL if calling vm_ops->get_policy during NUMA hinting faults
> 
> Heck no. In fact, not a f*cking way in hell. Look yourself in the
> mirror, Mel.

I could do with a shave, a glass of wine and a holiday in that order.

> This patch is ugly, and *guaranteed* to result in subtle
> locking issues, and then you have the *gall* to quote the "uhh, that's
> a bit ugly due to some trivial duplication" thing in commit
> b22d127a39dd.
> 

No argument.

> Reverting commit b22d127a39dd and just having a "ok, if we need to
> allocate, then drop the lock, allocate, re-get the lock, and see if we
> still need the new allocation" is *beautiful* code compared to the
> diseased abortion you just posted.
> 
> Seriously. Conditional locking is error-prone, and about a million
> times worse than the trivial fix that Kosaki suggested.
> 

Kosaki's patch does not fix the actual problem with NUMA hinting
faults. Converting to a spinlock is nice but we'd still hold the PTL at
the time sp_alloc is called and potentially allocating GFP_KERNEL with a
spinlock held.

At the risk of making your head explode, here is another patch.  It does
the conversion to spinlock as Kosaki originally did. It's unnecessary for
the actual problem at hand but I felt that avoiding it would piss you off
more. The actual fix is changing how the PTL is handled by NUMA hinting fault
handler. It's still conditionally locking but only at the location it matters
where it'll be obvious. As before, we could unconditionally unlock but then
a PMD fault potentially releases/acquires the PTL a large number of times.

This survived a trinity fuzz test for mbind running for 5 minutes and
autonumabench. CONFIG_SLUB_DEBUG, CONFIG_DEBUG_MUTEXES, CONFIG_DEBUG_SPINLOCK
and CONFIG_NUMA_BALANCING were enabled.  Unfortunately, as part of the
same test I also checked slabinfo and I see that shared_policy_nodes is
continually increasing indicating that it's leaking again. This also
happens with current git so it's another regression.

---8<---
mm: mempolicy: Convert shared_policy mutex to spinlock and do not hold PTL across a shmem vm_ops->get_vma_policy().

Sasha was fuzzing with trinity and reported the following problem:

BUG: sleeping function called from invalid context at kernel/mutex.c:269
in_atomic(): 1, irqs_disabled(): 0, pid: 6361, name: trinity-main
2 locks held by trinity-main/6361:
 #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff810aa314>] __do_page_fault+0x1e4/0x4f0
 #1:  (&(&mm->page_table_lock)->rlock){+.+...}, at: [<ffffffff8122f017>] handle_pte_fault+0x3f7/0x6a0
Pid: 6361, comm: trinity-main Tainted: G        W
3.7.0-rc2-next-20121024-sasha-00001-gd95ef01-dirty #74
Call Trace:
 [<ffffffff8114e393>] __might_sleep+0x1c3/0x1e0
 [<ffffffff83ae5209>] mutex_lock_nested+0x29/0x50
 [<ffffffff8124fc3e>] mpol_shared_policy_lookup+0x2e/0x90
 [<ffffffff81219ebe>] shmem_get_policy+0x2e/0x30
 [<ffffffff8124e99a>] get_vma_policy+0x5a/0xa0
 [<ffffffff8124fce1>] mpol_misplaced+0x41/0x1d0
 [<ffffffff8122f085>] handle_pte_fault+0x465/0x6a0

This was triggered by a different version of automatic NUMA balancing but
in theory the current version is vunerable to the same problem.

do_numa_page
  -> numa_migrate_prep
    -> mpol_misplaced
      -> get_vma_policy
        -> shmem_get_policy

It's very unlikely this will happen as shared pages are not marked
pte_numa -- see the page_mapcount() check in change_pte_range() -- but
it is possible.

To address this, this patch is in two parts. First it restores sp->lock as
originally implemented by Kosaki Motohiro. This is not actually necessary at
this point but the related flames were such that I felt that hand-waving at
it would result in a second kick in the arse.

The second part alters how PTL is acquired and released during a NUMA
hinting fault.  numa_migrate_prep() only takes a reference to the page and
the caller calls mpol_misplaced(). It is up to the caller how to handle
the PTL. In the case of do_numa_page(), it just releases it. For PMDs,
it will hold the PTL if there is no vm_ops->get_vma_policy(). Otherwise
it will release the PTL and reacquire it if necessary.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mempolicy.h |    2 +-
 mm/memory.c               |   27 +++++++++++++-----
 mm/mempolicy.c            |   68 ++++++++++++++++++++++++++++++++-------------
 3 files changed, 69 insertions(+), 28 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 9adc270..cc51d17 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -123,7 +123,7 @@ struct sp_node {
 
 struct shared_policy {
 	struct rb_root root;
-	struct mutex mutex;
+	spinlock_t lock;
 };
 
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol);
diff --git a/mm/memory.c b/mm/memory.c
index e0a9b0c..d8c2a5c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3431,7 +3431,7 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
+static void numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 				unsigned long addr, int current_nid)
 {
 	get_page(page);
@@ -3439,8 +3439,6 @@ int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (current_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
-
-	return mpol_misplaced(page, vma, addr);
 }
 
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -3479,8 +3477,10 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	current_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
+	numa_migrate_prep(page, vma, addr, current_nid);
 	pte_unmap_unlock(ptep, ptl);
+
+	target_nid = mpol_misplaced(page, vma, addr);
 	if (target_nid == -1) {
 		/*
 		 * Account for the fault against the current node if it not
@@ -3513,6 +3513,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
+	bool policy_vma = (vma->vm_ops && vma->vm_ops->get_policy);
 	int local_nid = numa_node_id();
 
 	spin_lock(&mm->page_table_lock);
@@ -3566,15 +3567,27 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 * migrated to.
 		 */
 		curr_nid = local_nid;
-		target_nid = numa_migrate_prep(page, vma, addr,
-					       page_to_nid(page));
+		numa_migrate_prep(page, vma, addr, page_to_nid(page));
+
+		/*
+		 * If there is a possibility that mpol_misplaced will need
+		 * to allocate for a shared memory policy then we have to
+		 * release the PTL now and reacquire later if necessary.
+		 */
+		if (policy_vma)
+			pte_unmap_unlock(pte, ptl);
+
+		target_nid = mpol_misplaced(page, vma, addr);
 		if (target_nid == -1) {
+			if (policy_vma)
+				pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 			put_page(page);
 			continue;
 		}
 
 		/* Migrate to the requested node */
-		pte_unmap_unlock(pte, ptl);
+		if (!policy_vma)
+			pte_unmap_unlock(pte, ptl);
 		migrated = migrate_misplaced_page(page, target_nid);
 		if (migrated)
 			curr_nid = target_nid;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index d1b315e..ed8ebbf 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2132,7 +2132,7 @@ bool __mpol_equal(struct mempolicy *a, struct mempolicy *b)
  */
 
 /* lookup first element intersecting start-end */
-/* Caller holds sp->mutex */
+/* Caller holds sp->lock */
 static struct sp_node *
 sp_lookup(struct shared_policy *sp, unsigned long start, unsigned long end)
 {
@@ -2196,13 +2196,13 @@ mpol_shared_policy_lookup(struct shared_policy *sp, unsigned long idx)
 
 	if (!sp->root.rb_node)
 		return NULL;
-	mutex_lock(&sp->mutex);
+	spin_lock(&sp->lock);
 	sn = sp_lookup(sp, idx, idx+1);
 	if (sn) {
 		mpol_get(sn->policy);
 		pol = sn->policy;
 	}
-	mutex_unlock(&sp->mutex);
+	spin_unlock(&sp->lock);
 	return pol;
 }
 
@@ -2328,6 +2328,14 @@ static void sp_delete(struct shared_policy *sp, struct sp_node *n)
 	sp_free(n);
 }
 
+static void sp_node_init(struct sp_node *node, unsigned long start,
+			unsigned long end, struct mempolicy *pol)
+{
+	node->start = start;
+	node->end = end;
+	node->policy = pol;
+}
+
 static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 				struct mempolicy *pol)
 {
@@ -2344,10 +2352,7 @@ static struct sp_node *sp_alloc(unsigned long start, unsigned long end,
 		return NULL;
 	}
 	newpol->flags |= MPOL_F_SHARED;
-
-	n->start = start;
-	n->end = end;
-	n->policy = newpol;
+	sp_node_init(n, start, end, newpol);
 
 	return n;
 }
@@ -2357,9 +2362,12 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 				 unsigned long end, struct sp_node *new)
 {
 	struct sp_node *n;
+	struct sp_node *n_new = NULL;
+	struct mempolicy *mpol_new = NULL;
 	int ret = 0;
 
-	mutex_lock(&sp->mutex);
+restart:
+	spin_lock(&sp->lock);
 	n = sp_lookup(sp, start, end);
 	/* Take care of old policies in the same range. */
 	while (n && n->start < end) {
@@ -2372,14 +2380,16 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 		} else {
 			/* Old policy spanning whole new range. */
 			if (n->end > end) {
-				struct sp_node *new2;
-				new2 = sp_alloc(end, n->end, n->policy);
-				if (!new2) {
-					ret = -ENOMEM;
-					goto out;
-				}
+				if (!n_new)
+					goto alloc_new;
+
+				*mpol_new = *n->policy;
+				atomic_set(&mpol_new->refcnt, 1);
+				sp_node_init(n_new, n->end, end, mpol_new);
+				sp_insert(sp, n_new);
 				n->end = start;
-				sp_insert(sp, new2);
+				n_new = NULL;
+				mpol_new = NULL;
 				break;
 			} else
 				n->end = start;
@@ -2390,9 +2400,27 @@ static int shared_policy_replace(struct shared_policy *sp, unsigned long start,
 	}
 	if (new)
 		sp_insert(sp, new);
-out:
-	mutex_unlock(&sp->mutex);
+	spin_unlock(&sp->lock);
+	ret = 0;
+
+err_out:
+	if (mpol_new)
+		mpol_put(mpol_new);
+	if (n_new)
+		kmem_cache_free(sn_cache, n_new);
+		
 	return ret;
+
+alloc_new:
+	spin_unlock(&sp->lock);
+	ret = -ENOMEM;
+	n_new = kmem_cache_alloc(sn_cache, GFP_KERNEL);
+	if (!n_new)
+		goto err_out;
+	mpol_new = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	if (!mpol_new)
+		goto err_out;
+	goto restart;
 }
 
 /**
@@ -2410,7 +2438,7 @@ void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 	int ret;
 
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
-	mutex_init(&sp->mutex);
+	spin_lock_init(&sp->lock);
 
 	if (mpol) {
 		struct vm_area_struct pvma;
@@ -2476,14 +2504,14 @@ void mpol_free_shared_policy(struct shared_policy *p)
 
 	if (!p->root.rb_node)
 		return;
-	mutex_lock(&p->mutex);
+	spin_lock(&p->lock);
 	next = rb_first(&p->root);
 	while (next) {
 		n = rb_entry(next, struct sp_node, nd);
 		next = rb_next(&n->nd);
 		sp_delete(p, n);
 	}
-	mutex_unlock(&p->mutex);
+	spin_unlock(&p->lock);
 }
 
 #ifdef CONFIG_NUMA_BALANCING

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
