Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 1B9E66B0033
	for <linux-mm@kvack.org>; Mon, 26 Aug 2013 12:10:36 -0400 (EDT)
Date: Mon, 26 Aug 2013 18:10:27 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH] mm, sched, numa: Create a per-task MPOL_INTERLEAVE policy
Message-ID: <20130826161027.GA10002@twins.programming.kicks-ass.net>
References: <1373901620-2021-1-git-send-email-mgorman@suse.de>
 <20130725104633.GQ27075@twins.programming.kicks-ass.net>
 <20130726095528.GB20909@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130726095528.GB20909@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>


OK, here's one that actually works and doesn't have magical crashes.

---
Subject: mm, sched, numa: Create a per-task MPOL_INTERLEAVE policy
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon Jul 22 10:42:38 CEST 2013

For those tasks belonging to groups that span nodes -- for whatever
reason -- we want to interleave their memory allocations to minimize
their performance penalty.

There's a subtlety to interleaved memory allocations though, once you
establish an interleave mask a measurement of where the actual memory
is is completely flat across those nodes. Therefore we'll never
actually shrink the interleave mask, even if at some point all tasks
can/do run on a single node again.

To fix this issue, change the accounting so that when we find a page
part of the interleave mask, we still account it against the current
node, not the node the page is really at. 

Finally, simplify the 'default' numa policy. It used a per-node
preferred node policy and always picked the current node, this can be
written with a single MPOL_F_LOCAL policy.

Signed-off-by: Peter Zijlstra <peterz@infradead.org>
---
 include/linux/mempolicy.h |    5 +-
 kernel/sched/fair.c       |   56 +++++++++++++++++++++++++++
 kernel/sched/features.h   |    1 
 mm/huge_memory.c          |   28 +++++++------
 mm/memory.c               |   33 ++++++++++-----
 mm/mempolicy.c            |   95 +++++++++++++++++++++++++++++-----------------
 6 files changed, 158 insertions(+), 60 deletions(-)

--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -60,6 +60,7 @@ struct mempolicy {
  * The default fast path of a NULL MPOL_DEFAULT policy is always inlined.
  */
 
+extern struct mempolicy *__mpol_new(unsigned short, unsigned short);
 extern void __mpol_put(struct mempolicy *pol);
 static inline void mpol_put(struct mempolicy *pol)
 {
@@ -187,7 +188,7 @@ static inline int vma_migratable(struct
 	return 1;
 }
 
-extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long);
+extern int mpol_misplaced(struct page *, struct vm_area_struct *, unsigned long, int *);
 
 #else
 
@@ -307,7 +308,7 @@ static inline int mpol_to_str(char *buff
 }
 
 static inline int mpol_misplaced(struct page *page, struct vm_area_struct *vma,
-				 unsigned long address)
+				 unsigned long address, int *account_node)
 {
 	return -1; /* no node preference */
 }
--- a/kernel/sched/fair.c
+++ b/kernel/sched/fair.c
@@ -893,6 +893,59 @@ static inline unsigned long task_faults(
 	return p->numa_faults[2*nid] + p->numa_faults[2*nid+1];
 }
 
+/*
+ * Create/Update p->mempolicy MPOL_INTERLEAVE to match p->numa_faults[].
+ */
+static void task_numa_mempol(struct task_struct *p, long max_faults)
+{
+	struct mempolicy *pol = p->mempolicy, *new = NULL;
+	nodemask_t nodes = NODE_MASK_NONE;
+	int node;
+
+	if (!max_faults)
+		return;
+
+	if (!pol) {
+		new = __mpol_new(MPOL_INTERLEAVE, MPOL_F_MOF | MPOL_F_MORON);
+		if (IS_ERR(new))
+			return;
+	}
+
+	task_lock(p);
+
+	pol = p->mempolicy; /* lock forces a re-read */
+	if (!pol)
+		pol = new;
+
+	if (!(pol->flags & MPOL_F_MORON))
+		goto unlock;
+
+	for_each_node(node) {
+		if (task_faults(p, node) > max_faults/2)
+			node_set(node, nodes);
+	}
+
+	if (pol == new) {
+		/*
+		 * XXX 'borrowed' from do_set_mempolicy()
+		 */
+		pol->v.nodes = nodes;
+		p->mempolicy = pol;
+		p->flags |= PF_MEMPOLICY;
+		p->il_next = first_node(nodes);
+		new = NULL;
+	} else {
+		mpol_rebind_task(p, &nodes, MPOL_REBIND_STEP1);
+		mpol_rebind_task(p, &nodes, MPOL_REBIND_STEP2);
+	}
+
+unlock:
+	task_unlock(p);
+
+	if (new)
+		__mpol_put(new);
+}
+
 static unsigned long weighted_cpuload(const int cpu);
 static unsigned long source_load(int cpu, int type);
 static unsigned long target_load(int cpu, int type);
@@ -1106,6 +1159,9 @@ static void task_numa_placement(struct t
 		}
 	}
 
+	if (sched_feat(NUMA_INTERLEAVE))
+		task_numa_mempol(p, max_faults);
+
 	/* Preferred node as the node with the most faults */
 	if (max_faults && max_nid != p->numa_preferred_nid) {
 
--- a/kernel/sched/features.h
+++ b/kernel/sched/features.h
@@ -72,4 +72,5 @@ SCHED_FEAT(NUMA_FORCE,	false)
 SCHED_FEAT(NUMA_BALANCE, true)
 SCHED_FEAT(NUMA_FAULTS_UP, true)
 SCHED_FEAT(NUMA_FAULTS_DOWN, true)
+SCHED_FEAT(NUMA_INTERLEAVE, false)
 #endif
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1292,7 +1292,7 @@ int do_huge_pmd_numa_page(struct mm_stru
 {
 	struct page *page;
 	unsigned long haddr = addr & HPAGE_PMD_MASK;
-	int page_nid = -1, this_nid = numa_node_id();
+	int page_nid = -1, account_nid = -1, this_nid = numa_node_id();
 	int target_nid, last_nidpid;
 	bool migrated = false;
 
@@ -1301,7 +1301,6 @@ int do_huge_pmd_numa_page(struct mm_stru
 		goto out_unlock;
 
 	page = pmd_page(pmd);
-	get_page(page);
 
 	/*
 	 * Do not account for faults against the huge zero page. The read-only
@@ -1317,13 +1316,12 @@ int do_huge_pmd_numa_page(struct mm_stru
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
 	last_nidpid = page_nidpid_last(page);
-	target_nid = mpol_misplaced(page, vma, haddr);
-	if (target_nid == -1) {
-		put_page(page);
+	target_nid = mpol_misplaced(page, vma, haddr, &account_nid);
+	if (target_nid == -1)
 		goto clear_pmdnuma;
-	}
 
 	/* Acquire the page lock to serialise THP migrations */
+	get_page(page);
 	spin_unlock(&mm->page_table_lock);
 	lock_page(page);
 
@@ -1332,6 +1330,7 @@ int do_huge_pmd_numa_page(struct mm_stru
 	if (unlikely(!pmd_same(pmd, *pmdp))) {
 		unlock_page(page);
 		put_page(page);
+		account_nid = page_nid = -1; /* someone else took our fault */
 		goto out_unlock;
 	}
 	spin_unlock(&mm->page_table_lock);
@@ -1339,17 +1338,20 @@ int do_huge_pmd_numa_page(struct mm_stru
 	/* Migrate the THP to the requested node */
 	migrated = migrate_misplaced_transhuge_page(mm, vma,
 				pmdp, pmd, addr, page, target_nid);
-	if (migrated)
-		page_nid = target_nid;
-	else
+	if (!migrated) {
+		account_nid = -1; /* account against the old page */
 		goto check_same;
+	}
 
+	page_nid = target_nid;
 	goto out;
 
 check_same:
 	spin_lock(&mm->page_table_lock);
-	if (unlikely(!pmd_same(pmd, *pmdp)))
+	if (unlikely(!pmd_same(pmd, *pmdp))) {
+		page_nid = -1; /* someone else took our fault */
 		goto out_unlock;
+	}
 clear_pmdnuma:
 	pmd = pmd_mknonnuma(pmd);
 	set_pmd_at(mm, haddr, pmdp, pmd);
@@ -1359,8 +1361,10 @@ int do_huge_pmd_numa_page(struct mm_stru
 	spin_unlock(&mm->page_table_lock);
 
 out:
-	if (page_nid != -1)
-		task_numa_fault(last_nidpid, page_nid, HPAGE_PMD_NR, migrated);
+	if (account_nid == -1)
+		account_nid = page_nid;
+	if (account_nid != -1)
+		task_numa_fault(last_nidpid, account_nid, HPAGE_PMD_NR, migrated);
 
 	return 0;
 }
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3529,16 +3529,17 @@ static int do_nonlinear_fault(struct mm_
 	return __do_fault(mm, vma, address, pmd, pgoff, flags, orig_pte);
 }
 
-int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
-				unsigned long addr, int current_nid)
+static int numa_migrate_prep(struct page *page, struct vm_area_struct *vma,
+			     unsigned long addr, int page_nid,
+			     int *account_nid)
 {
 	get_page(page);
 
 	count_vm_numa_event(NUMA_HINT_FAULTS);
-	if (current_nid == numa_node_id())
+	if (page_nid == numa_node_id())
 		count_vm_numa_event(NUMA_HINT_FAULTS_LOCAL);
 
-	return mpol_misplaced(page, vma, addr);
+	return mpol_misplaced(page, vma, addr, account_nid);
 }
 
 int do_numa_page(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -3546,7 +3547,7 @@ int do_numa_page(struct mm_struct *mm, s
 {
 	struct page *page = NULL;
 	spinlock_t *ptl;
-	int page_nid = -1;
+	int page_nid = -1, account_nid = -1;
 	int target_nid, last_nidpid;
 	bool migrated = false;
 
@@ -3583,7 +3584,7 @@ int do_numa_page(struct mm_struct *mm, s
 
 	last_nidpid = page_nidpid_last(page);
 	page_nid = page_to_nid(page);
-	target_nid = numa_migrate_prep(page, vma, addr, page_nid);
+	target_nid = numa_migrate_prep(page, vma, addr, page_nid, &account_nid);
 	pte_unmap_unlock(ptep, ptl);
 	if (target_nid == -1) {
 		put_page(page);
@@ -3596,8 +3597,10 @@ int do_numa_page(struct mm_struct *mm, s
 		page_nid = target_nid;
 
 out:
-	if (page_nid != -1)
-		task_numa_fault(last_nidpid, page_nid, 1, migrated);
+	if (account_nid == -1)
+		account_nid = page_nid;
+	if (account_nid != -1)
+		task_numa_fault(last_nidpid, account_nid, 1, migrated);
 
 	return 0;
 }
@@ -3636,7 +3639,7 @@ static int do_pmd_numa_page(struct mm_st
 	for (addr = _addr + offset; addr < _addr + PMD_SIZE; pte++, addr += PAGE_SIZE) {
 		pte_t pteval = *pte;
 		struct page *page;
-		int page_nid = -1;
+		int page_nid = -1, account_nid = -1;
 		int target_nid;
 		bool migrated = false;
 
@@ -3661,19 +3664,25 @@ static int do_pmd_numa_page(struct mm_st
 		last_nidpid = page_nidpid_last(page);
 		page_nid = page_to_nid(page);
 		target_nid = numa_migrate_prep(page, vma, addr,
-				               page_nid);
+				               page_nid, &account_nid);
 		pte_unmap_unlock(pte, ptl);
 
 		if (target_nid != -1) {
 			migrated = migrate_misplaced_page(page, vma, target_nid);
 			if (migrated)
 				page_nid = target_nid;
+			else
+				account_nid = -1;
 		} else {
 			put_page(page);
 		}
 
-		if (page_nid != -1)
-			task_numa_fault(last_nidpid, page_nid, 1, migrated);
+		if (account_nid == -1)
+			account_nid = page_nid;
+		if (account_nid != -1)
+			task_numa_fault(last_nidpid, account_nid, 1, migrated);
+
+		cond_resched();
 
 		pte = pte_offset_map_lock(mm, pmdp, addr, &ptl);
 	}
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -118,22 +118,18 @@ static struct mempolicy default_policy =
 	.flags = MPOL_F_LOCAL,
 };
 
-static struct mempolicy preferred_node_policy[MAX_NUMNODES];
+static struct mempolicy numa_policy = {
+	.refcnt = ATOMIC_INIT(1), /* never free it */
+	.mode = MPOL_PREFERRED,
+	.flags = MPOL_F_LOCAL | MPOL_F_MOF | MPOL_F_MORON,
+};
 
 static struct mempolicy *get_task_policy(struct task_struct *p)
 {
 	struct mempolicy *pol = p->mempolicy;
-	int node;
 
-	if (!pol) {
-		node = numa_node_id();
-		if (node != NUMA_NO_NODE)
-			pol = &preferred_node_policy[node];
-
-		/* preferred_node_policy is not initialised early in boot */
-		if (!pol->mode)
-			pol = NULL;
-	}
+	if (!pol)
+		pol = &numa_policy;
 
 	return pol;
 }
@@ -248,6 +244,20 @@ static int mpol_set_nodemask(struct memp
 	return ret;
 }
 
+struct mempolicy *__mpol_new(unsigned short mode, unsigned short flags)
+{
+	struct mempolicy *policy;
+
+	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
+	if (!policy)
+		return ERR_PTR(-ENOMEM);
+	atomic_set(&policy->refcnt, 1);
+	policy->mode = mode;
+	policy->flags = flags;
+
+	return policy;
+}
+
 /*
  * This function just creates a new policy, does some check and simple
  * initialization. You must invoke mpol_set_nodemask() to set nodes.
@@ -255,8 +265,6 @@ static int mpol_set_nodemask(struct memp
 static struct mempolicy *mpol_new(unsigned short mode, unsigned short flags,
 				  nodemask_t *nodes)
 {
-	struct mempolicy *policy;
-
 	pr_debug("setting mode %d flags %d nodes[0] %lx\n",
 		 mode, flags, nodes ? nodes_addr(*nodes)[0] : NUMA_NO_NODE);
 
@@ -284,14 +292,8 @@ static struct mempolicy *mpol_new(unsign
 		mode = MPOL_PREFERRED;
 	} else if (nodes_empty(*nodes))
 		return ERR_PTR(-EINVAL);
-	policy = kmem_cache_alloc(policy_cache, GFP_KERNEL);
-	if (!policy)
-		return ERR_PTR(-ENOMEM);
-	atomic_set(&policy->refcnt, 1);
-	policy->mode = mode;
-	policy->flags = flags;
 
-	return policy;
+	return __mpol_new(mode, flags);
 }
 
 /* Slow path of a mpol destructor. */
@@ -2242,12 +2244,13 @@ static void sp_free(struct sp_node *n)
  * Policy determination "mimics" alloc_page_vma().
  * Called from fault path where we know the vma and faulting address.
  */
-int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr)
+int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long addr, int *account_node)
 {
 	struct mempolicy *pol;
 	struct zone *zone;
 	int curnid = page_to_nid(page);
 	unsigned long pgoff;
+	int thisnid = numa_node_id();
 	int polnid = -1;
 	int ret = -1;
 
@@ -2269,7 +2272,7 @@ int mpol_misplaced(struct page *page, st
 
 	case MPOL_PREFERRED:
 		if (pol->flags & MPOL_F_LOCAL)
-			polnid = numa_node_id();
+			polnid = thisnid;
 		else
 			polnid = pol->v.preferred_node;
 		break;
@@ -2284,7 +2287,7 @@ int mpol_misplaced(struct page *page, st
 		if (node_isset(curnid, pol->v.nodes))
 			goto out;
 		(void)first_zones_zonelist(
-				node_zonelist(numa_node_id(), GFP_HIGHUSER),
+				node_zonelist(thisnid, GFP_HIGHUSER),
 				gfp_zone(GFP_HIGHUSER),
 				&pol->v.nodes, &zone);
 		polnid = zone->node;
@@ -2299,8 +2302,7 @@ int mpol_misplaced(struct page *page, st
 		int last_nidpid;
 		int this_nidpid;
 
-		polnid = numa_node_id();
-		this_nidpid = nid_pid_to_nidpid(polnid, current->pid);;
+		this_nidpid = nid_pid_to_nidpid(thisnid, current->pid);
 
 		/*
 		 * Multi-stage node selection is used in conjunction
@@ -2326,6 +2328,40 @@ int mpol_misplaced(struct page *page, st
 		last_nidpid = page_nidpid_xchg_last(page, this_nidpid);
 		if (!nidpid_pid_unset(last_nidpid) && nidpid_to_nid(last_nidpid) != polnid)
 			goto out;
+
+		/*
+		 * Preserve interleave pages while allowing useful
+		 * ->numa_faults[] statistics.
+		 *
+		 * When migrating into an interleave set, migrate to
+		 * the correct interleaved node but account against the
+		 * current node (where the task is running).
+		 *
+		 * Not doing this would result in ->numa_faults[] being
+		 * flat across the interleaved nodes, making it
+		 * impossible to shrink the node list even when all
+		 * tasks are running on a single node.
+		 *
+		 * src dst    migrate      account
+		 *  0   0  -- this_node    $page_node
+		 *  0   1  -- policy_node  this_node
+		 *  1   0  -- this_node    $page_node
+		 *  1   1  -- policy_node  this_node
+		 *
+		 */
+		switch (pol->mode) {
+		case MPOL_INTERLEAVE:
+			if (node_isset(thisnid, pol->v.nodes)) {
+				if (account_node)
+					*account_node = thisnid;
+				break;
+			}
+			/* fall-through for nodes outside the set */
+
+		default:
+			polnid = thisnid;
+			break;
+		}
 	}
 
 	if (curnid != polnid)
@@ -2588,15 +2624,6 @@ void __init numa_policy_init(void)
 				     sizeof(struct sp_node),
 				     0, SLAB_PANIC, NULL);
 
-	for_each_node(nid) {
-		preferred_node_policy[nid] = (struct mempolicy) {
-			.refcnt = ATOMIC_INIT(1),
-			.mode = MPOL_PREFERRED,
-			.flags = MPOL_F_MOF | MPOL_F_MORON,
-			.v = { .preferred_node = nid, },
-		};
-	}
-
 	/*
 	 * Set interleaving policy for system init. Interleaving is only
 	 * enabled across suitably sized nodes (default is >= 16MB), or

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
