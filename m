Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 671DF6B009D
	for <linux-mm@kvack.org>; Tue,  4 Mar 2014 22:59:19 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id uo5so500432pbc.4
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:19 -0800 (PST)
Received: from mail-pd0-x22b.google.com (mail-pd0-x22b.google.com [2607:f8b0:400e:c02::22b])
        by mx.google.com with ESMTPS id iu9si921976pac.176.2014.03.04.19.59.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 04 Mar 2014 19:59:18 -0800 (PST)
Received: by mail-pd0-f171.google.com with SMTP id r10so486027pdi.16
        for <linux-mm@kvack.org>; Tue, 04 Mar 2014 19:59:18 -0800 (PST)
Date: Tue, 4 Mar 2014 19:59:16 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 03/11] mm, mempolicy: remove per-process flag
In-Reply-To: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1403041954420.8067@chino.kir.corp.google.com>
References: <alpine.DEB.2.02.1403041952170.8067@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Tejun Heo <tj@kernel.org>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Rik van Riel <riel@redhat.com>, Jianguo Wu <wujianguo@huawei.com>, Tim Hockin <thockin@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-doc@vger.kernel.org

PF_MEMPOLICY is an unnecessary optimization for CONFIG_SLAB users.
There's no significant performance degradation to checking
current->mempolicy rather than current->flags & PF_MEMPOLICY in the
allocation path, especially since this is considered unlikely().

Running TCP_RR with netperf-2.4.5 through localhost on 16 cpu machine
with 64GB of memory and without a mempolicy:

	threads		before		after
	16		1249409		1244487
	32		1281786		1246783
	48		1239175		1239138
	64		1244642		1241841
	80		1244346		1248918
	96		1266436		1254316
	112		1307398		1312135
	128		1327607		1326502

Per-process flags are a scarce resource so we should free them up
whenever possible and make them available.  We'll be using it shortly for
memcg oom reserves.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/mempolicy.h |  1 -
 include/linux/sched.h     |  1 -
 kernel/fork.c             |  1 -
 mm/mempolicy.c            | 31 -------------------------------
 mm/slab.c                 |  4 ++--
 5 files changed, 2 insertions(+), 36 deletions(-)

diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -143,7 +143,6 @@ extern void numa_policy_init(void);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
 extern void mpol_rebind_mm(struct mm_struct *mm, nodemask_t *new);
-extern void mpol_fix_fork_child_flag(struct task_struct *p);
 
 extern struct zonelist *huge_zonelist(struct vm_area_struct *vma,
 				unsigned long addr, gfp_t gfp_flags,
diff --git a/include/linux/sched.h b/include/linux/sched.h
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1821,7 +1821,6 @@ extern void thread_group_cputime_adjusted(struct task_struct *p, cputime_t *ut,
 #define PF_SPREAD_SLAB	0x02000000	/* Spread some slab caches over cpuset */
 #define PF_NO_SETAFFINITY 0x04000000	/* Userland is not allowed to meddle with cpus_allowed */
 #define PF_MCE_EARLY    0x08000000      /* Early kill for mce process policy */
-#define PF_MEMPOLICY	0x10000000	/* Non-default NUMA mempolicy */
 #define PF_MUTEX_TESTER	0x20000000	/* Thread belongs to the rt mutex tester */
 #define PF_FREEZER_SKIP	0x40000000	/* Freezer should not count it as freezable */
 #define PF_SUSPEND_TASK 0x80000000      /* this thread called freeze_processes and should not be frozen */
diff --git a/kernel/fork.c b/kernel/fork.c
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1265,7 +1265,6 @@ static struct task_struct *copy_process(unsigned long clone_flags,
 		p->mempolicy = NULL;
 		goto bad_fork_cleanup_cgroup;
 	}
-	mpol_fix_fork_child_flag(p);
 #endif
 #ifdef CONFIG_CPUSETS
 	p->cpuset_mem_spread_rotor = NUMA_NO_NODE;
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -795,36 +795,6 @@ static int mbind_range(struct mm_struct *mm, unsigned long start,
 	return err;
 }
 
-/*
- * Update task->flags PF_MEMPOLICY bit: set iff non-default
- * mempolicy.  Allows more rapid checking of this (combined perhaps
- * with other PF_* flag bits) on memory allocation hot code paths.
- *
- * If called from outside this file, the task 'p' should -only- be
- * a newly forked child not yet visible on the task list, because
- * manipulating the task flags of a visible task is not safe.
- *
- * The above limitation is why this routine has the funny name
- * mpol_fix_fork_child_flag().
- *
- * It is also safe to call this with a task pointer of current,
- * which the static wrapper mpol_set_task_struct_flag() does,
- * for use within this file.
- */
-
-void mpol_fix_fork_child_flag(struct task_struct *p)
-{
-	if (p->mempolicy)
-		p->flags |= PF_MEMPOLICY;
-	else
-		p->flags &= ~PF_MEMPOLICY;
-}
-
-static void mpol_set_task_struct_flag(void)
-{
-	mpol_fix_fork_child_flag(current);
-}
-
 /* Set the process memory policy */
 static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 			     nodemask_t *nodes)
@@ -861,7 +831,6 @@ static long do_set_mempolicy(unsigned short mode, unsigned short flags,
 	}
 	old = current->mempolicy;
 	current->mempolicy = new;
-	mpol_set_task_struct_flag();
 	if (new && new->mode == MPOL_INTERLEAVE &&
 	    nodes_weight(new->v.nodes))
 		current->il_next = first_node(new->v.nodes);
diff --git a/mm/slab.c b/mm/slab.c
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3027,7 +3027,7 @@ out:
 
 #ifdef CONFIG_NUMA
 /*
- * Try allocating on another node if PF_SPREAD_SLAB|PF_MEMPOLICY.
+ * Try allocating on another node if PF_SPREAD_SLAB is a mempolicy is set.
  *
  * If we are in_interrupt, then process context, including cpusets and
  * mempolicy, may not apply and should not be used for allocation policy.
@@ -3259,7 +3259,7 @@ __do_cache_alloc(struct kmem_cache *cache, gfp_t flags)
 {
 	void *objp;
 
-	if (unlikely(current->flags & (PF_SPREAD_SLAB | PF_MEMPOLICY))) {
+	if (current->mempolicy || unlikely(current->flags & PF_SPREAD_SLAB)) {
 		objp = alternate_node_alloc(cache, flags);
 		if (objp)
 			goto out;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
