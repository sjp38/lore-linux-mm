Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 882CE6B005A
	for <linux-mm@kvack.org>; Fri, 21 Dec 2012 08:47:49 -0500 (EST)
Date: Fri, 21 Dec 2012 13:47:40 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [patch] mm, mempolicy: Introduce spinlock to read shared policy
 tree
Message-ID: <20121221134740.GC13367@suse.de>
References: <1353624594-1118-1-git-send-email-mingo@kernel.org>
 <1353624594-1118-19-git-send-email-mingo@kernel.org>
 <alpine.DEB.2.00.1212031644440.32354@chino.kir.corp.google.com>
 <CA+55aFyrSVzGZ438DGnTFuyFb1BOXaMmvxtkW0Xhnx+BxAg2PA@mail.gmail.com>
 <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1212201440250.7807@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Sasha Levin <levinsasha928@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

On Thu, Dec 20, 2012 at 02:55:22PM -0800, David Rientjes wrote:
> On Thu, 20 Dec 2012, Linus Torvalds wrote:
> 
> > Going through some old emails before -rc1 rlease..
> > 
> > What is the status of this patch? The patch that is reported to cause
> > the problem hasn't been merged, but that mpol_misplaced() thing did
> > happen in commit 771fb4d806a9. And it looks like it's called from
> > numa_migrate_prep() under the pte map lock. Or am I missing something?
> 
> Andrew pinged both Ingo and I about it privately two weeks ago.  It 
> probably doesn't trigger right now because there's no pte_mknuma() on 
> shared pages (yet) but will eventually be needed for correctness.

Specifically it is very unlikely to hit because of the page_mapcount()
checks that are made before setting pte_numa. I guess it is still possible
to trigger if just one process is mapping the shared area.

> So it's 
> not required for -rc1 as it sits in the tree today but will be needed 
> later (and hopefully not forgotten about until Sasha fuzzes again).
> 

Indeed.

> > See commit 9532fec118d ("mm: numa: Migrate pages handled during a
> > pmd_numa hinting fault").
> > 
> > Am I missing something? Mel, please take another look.
> > 
> > I despise these kinds of dual-locking models, and am wondering if we
> > can't have *just* the spinlock?
> > 
> 
> Adding KOSAKI to the cc.
> 
> This is probably worth discussing now to see if we can't revert 
> b22d127a39dd ("mempolicy: fix a race in shared_policy_replace()"), keep it 
> only as a spinlock as you suggest, and do what KOSAKI suggested in 
> http://marc.info/?l=linux-kernel&m=133940650731255 instead.  I don't think 
> it's worth trying to optimize this path at the cost of having both a 
> spinlock and mutex.

Jeez, I'm still not keen on that approach for the reasons that are explained
in the changelog for b22d127a39dd.

The reported problem is due to the PTL being held for get_vma_policy()
during hinting fault handling but it's not actually necessary once the page
count has been elevated. If it was just PTEs we were dealing with, we could
just drop the PTL before calling mpol_misplaced() but the handling of PMDs
complicates that. A patch that simply dropped the PTL unconditionally looks
tidy but it then forces do_pmd_numa_page() to reacquire the PTL even if
the page was properly placed and 512 release/acquires of the PTL could suck.

That leads to this third *ugly* option that conditionally drops the lock
and it's up to the caller to figure out what happened. Fooling around with
how it conditionally releases the lock results in different sorts of ugly.
We now have three ugly sister patches for this. Who wants to be Cinderalla?

---8<---
mm: numa: Release the PTL if calling vm_ops->get_policy during NUMA hinting faults

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
it is possible. There are a couple of ways this can be handled. Peter
Zijlstra and David Rientjes had a patch that introduced a dual-locking
model where lookups can use a spinlock but dual-locking like this is
tricky. A second approach is to partially revert b22d127a (mempolicy:
fix a race in shared_policy_replace) and go back to Kosaki's original
approach at http://marc.info/?l=linux-kernel&m=133940650731255 to only
use a spinlock for shared policies.

This patch is a third approach that is a different type of ugly. It drops
the PTL in numa_migrate_prep() if vm_ops->get_policy exists after the page
has been pinned and it's up to the caller to reacquire if necessary.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 mm/memory.c |   34 ++++++++++++++++++++++++++++------
 1 file changed, 28 insertions(+), 6 deletions(-)

diff --git a/mm/memory.c b/mm/memory.c
index e0a9b0c..82d0b20 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3431,15 +3431,29 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-				unsigned long addr, int current_nid)
+static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
+				unsigned long addr, int current_nid,
+				pte_t *ptep, spinlock_t *ptl, bool *released)
 {
+	*released = false;
+
 	get_page(page);
 
 	count_vm_numa_event(NUMA_HINT_FAULTS);
 	if (current_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
+	/*
+	 * This is UGLY. If the vma has a get_policy ops then it is possible
+	 * it needs to allocate GFP_KERNEL which is not safe with the PTL
+	 * held. In this case we have to release the PTL and it's up to the
+	 * caller to reacquire it if necessary.
+	 */
+	if (vma->vm_ops && vma->vm_ops->get_policy) {
+		pte_unmap_unlock(ptep, ptl);
+		*released = true;
+	}
+		
 	return mpol_misplaced(page, vma, addr);
 }
 
@@ -3451,6 +3465,7 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	int current_nid = -1;
 	int target_nid;
 	bool migrated = false;
+	bool released_ptl;
 
 	/*
 	* The "pte" at this point cannot be used safely without
@@ -3479,8 +3494,10 @@ int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	current_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, current_nid);
-	pte_unmap_unlock(ptep, ptl);
+	target_nid = numa_migrate_prep(page, vma, addr, current_nid,
+					ptep, ptl, &released_ptl);
+	if (!released_ptl)
+		pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
 		/*
 		 * Account for the fault against the current node if it not
@@ -3513,6 +3530,7 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned long offset;
 	spinlock_t *ptl;
 	bool numa = false;
+	bool released_ptl;
 	int local_nid = numa_node_id();
 
 	spin_lock(&mm->page_table_lock);
@@ -3567,14 +3585,18 @@ static int do_pmd_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
 		 */
 		curr_nid = local_nid;
 		target_nid = numa_migrate_prep(page, vma, addr,
-					       page_to_nid(page));
+					       page_to_nid(page),
+					       pte, ptl, &released_ptl);
 		if (target_nid == -1) {
+			if (released_ptl)
+				pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 			put_page(page);
 			continue;
 		}
 
 		/* Migrate to the requested node */
-		pte_unmap_unlock(pte, ptl);
+		if (!released_ptl)
+			pte_unmap_unlock(pte, ptl);
 		migrated = migrate_misplaced_page(page, target_nid);
 		if (migrated)
 			curr_nid = target_nid;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
