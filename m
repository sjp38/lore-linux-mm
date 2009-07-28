Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 3F9E36B004D
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 03:20:12 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6S7KG2X017217
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 28 Jul 2009 16:20:16 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D0E545DE53
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 16:20:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1B81B45DE52
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 16:20:16 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 034F11DB8038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 16:20:16 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E72E1DB803C
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 16:20:15 +0900 (JST)
Date: Tue, 28 Jul 2009 16:18:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [BUGFIX] set_mempolicy(MPOL_INTERLEAV) N_HIGH_MEMORY aware
Message-Id: <20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Miao Xie <miaox@cn.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Christoph Lameter <cl@linux-foundation.org>, Paul Menage <menage@google.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Yasunori Goto <y-goto@jp.fujitsu.com>, Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

tested on x86-64/fake NUMA and ia64/NUMA.
(That ia64 is a host which orignal bug report used.)

Maybe this is bigger patch than expected, but NODEMASK_ALLOC() will be a way
to go, anyway. (even if CPUMASK_ALLOC is not used anyware yet..)
Kosaki tested this on ia64 NUMA. thanks.

I'll wonder more fundamental fix to tsk->mems_allowed but this patch
is enough as a fix for now, I think.

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

mpol_set_nodemask() should be aware of N_HIGH_MEMORY and policy's nodemask
should be includes only online nodes.
In old behavior, this is guaranteed by frequent reference to cpuset's code.
Now, most of them are removed and mempolicy has to check it by itself.

To do check, a few nodemask_t will be used for calculating nodemask. But,
size of nodemask_t can be big and it's not good to allocate them on stack.

Now, cpumask_t has CPUMASK_ALLOC/FREE an easy code for get scratch area.
NODEMASK_ALLOC/FREE shoudl be there.

Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/nodemask.h |   31 +++++++++++++++++
 mm/mempolicy.c           |   82 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 87 insertions(+), 26 deletions(-)

Index: task-mems-allowed-fix/include/linux/nodemask.h
===================================================================
--- task-mems-allowed-fix.orig/include/linux/nodemask.h
+++ task-mems-allowed-fix/include/linux/nodemask.h
@@ -82,6 +82,13 @@
  *    to generate slightly worse code.  So use a simple one-line #define
  *    for node_isset(), instead of wrapping an inline inside a macro, the
  *    way we do the other calls.
+ *
+ * NODEMASK_SCRATCH
+ * For doing above logical AND, OR, XOR, Remap, etc...the caller tend to be
+ * necessary to use temporal nodemask_t on stack. But if NODES_SHIFT is large,
+ * size of nodemask_t can be very big and not suitable for allocating in stack.
+ * NODEMASK_SCRATCH is a helper for such situaions. See below and CPUMASK_ALLOC
+ * also.
  */
 
 #include <linux/kernel.h>
@@ -473,4 +480,28 @@ static inline int num_node_state(enum no
 #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
 #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
 
+/*
+ * For nodemask scrach area.(See CPUMASK_ALLOC() in cpumask.h)
+ */
+
+#if NODES_SHIFT > 8 /* nodemask_t > 64 bytes */
+#define NODEMASK_ALLOC(x, m) struct x *m = kmalloc(sizeof(*m), GFP_KERNEL)
+#define NODEMASK_FREE(m) kfree(m)
+#else
+#define NODEMASK_ALLOC(x, m) struct x _m, *m = &_m
+#define NODEMASK_FREE(m)
+#endif
+
+#define NODEMASK_POINTER(v, m) nodemask_t *v = &(m->v)
+
+/* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
+struct nodemask_scratch {
+	nodemask_t	mask1;
+	nodemask_t	mask2;
+};
+
+#define NODEMASK_SCRATCH(x) NODEMASK_ALLOC(nodemask_scratch, x)
+#define NODEMASK_SCRATCH_FREE(x)  NODEMASK_FREE(x)
+
+
 #endif /* __LINUX_NODEMASK_H */
Index: task-mems-allowed-fix/mm/mempolicy.c
===================================================================
--- task-mems-allowed-fix.orig/mm/mempolicy.c
+++ task-mems-allowed-fix/mm/mempolicy.c
@@ -191,25 +191,27 @@ static int mpol_new_bind(struct mempolic
  * Must be called holding task's alloc_lock to protect task's mems_allowed
  * and mempolicy.  May also be called holding the mmap_semaphore for write.
  */
-static int mpol_set_nodemask(struct mempolicy *pol, const nodemask_t *nodes)
+static int mpol_set_nodemask(struct mempolicy *pol,
+		     const nodemask_t *nodes, struct nodemask_scratch *nsc)
 {
-	nodemask_t cpuset_context_nmask;
 	int ret;
 
 	/* if mode is MPOL_DEFAULT, pol is NULL. This is right. */
 	if (pol == NULL)
 		return 0;
+	/* Check N_HIGH_MEMORY */
+	nodes_and(nsc->mask1,
+		  cpuset_current_mems_allowed, node_states[N_HIGH_MEMORY]);
 
 	VM_BUG_ON(!nodes);
 	if (pol->mode == MPOL_PREFERRED && nodes_empty(*nodes))
 		nodes = NULL;	/* explicit local allocation */
 	else {
 		if (pol->flags & MPOL_F_RELATIVE_NODES)
-			mpol_relative_nodemask(&cpuset_context_nmask, nodes,
-					       &cpuset_current_mems_allowed);
+			mpol_relative_nodemask(&nsc->mask2, nodes,&nsc->mask1);
 		else
-			nodes_and(cpuset_context_nmask, *nodes,
-				  cpuset_current_mems_allowed);
+			nodes_and(nsc->mask2, *nodes, nsc->mask1);
+
 		if (mpol_store_user_nodemask(pol))
 			pol->w.user_nodemask = *nodes;
 		else
@@ -217,8 +219,10 @@ static int mpol_set_nodemask(struct memp
 						cpuset_current_mems_allowed;
 	}
 
-	ret = mpol_ops[pol->mode].create(pol,
-				nodes ? &cpuset_context_nmask : NULL);
+	if (nodes)
+		ret = mpol_ops[pol->mode].create(pol, &nsc->mask2);
+	else
+		ret = mpol_ops[pol->mode].create(pol, NULL);
 	return ret;
 }
 
@@ -620,12 +624,17 @@ static long do_set_mempolicy(unsigned sh
 {
 	struct mempolicy *new, *old;
 	struct mm_struct *mm = current->mm;
+	NODEMASK_SCRATCH(scratch);
 	int ret;
 
-	new = mpol_new(mode, flags, nodes);
-	if (IS_ERR(new))
-		return PTR_ERR(new);
+	if (!scratch)
+		return -ENOMEM;
 
+	new = mpol_new(mode, flags, nodes);
+	if (IS_ERR(new)) {
+		ret = PTR_ERR(new);
+		goto out;
+	}
 	/*
 	 * prevent changing our mempolicy while show_numa_maps()
 	 * is using it.
@@ -635,13 +644,13 @@ static long do_set_mempolicy(unsigned sh
 	if (mm)
 		down_write(&mm->mmap_sem);
 	task_lock(current);
-	ret = mpol_set_nodemask(new, nodes);
+	ret = mpol_set_nodemask(new, nodes, scratch);
 	if (ret) {
 		task_unlock(current);
 		if (mm)
 			up_write(&mm->mmap_sem);
 		mpol_put(new);
-		return ret;
+		goto out;
 	}
 	old = current->mempolicy;
 	current->mempolicy = new;
@@ -654,7 +663,10 @@ static long do_set_mempolicy(unsigned sh
 		up_write(&mm->mmap_sem);
 
 	mpol_put(old);
-	return 0;
+	ret = 0;
+out:
+	NODEMASK_SCRATCH_FREE(scratch);
+	return ret;
 }
 
 /*
@@ -1014,10 +1026,17 @@ static long do_mbind(unsigned long start
 		if (err)
 			return err;
 	}
-	down_write(&mm->mmap_sem);
-	task_lock(current);
-	err = mpol_set_nodemask(new, nmask);
-	task_unlock(current);
+	{
+		NODEMASK_SCRATCH(scratch);
+		if (scratch) {
+			down_write(&mm->mmap_sem);
+			task_lock(current);
+			err = mpol_set_nodemask(new, nmask, scratch);
+			task_unlock(current);
+		} else
+			err = -ENOMEM;
+		NODEMASK_SCRATCH_FREE(scratch);
+	}
 	if (err) {
 		up_write(&mm->mmap_sem);
 		mpol_put(new);
@@ -1891,10 +1910,12 @@ restart:
  * Install non-NULL @mpol in inode's shared policy rb-tree.
  * On entry, the current task has a reference on a non-NULL @mpol.
  * This must be released on exit.
+ * This is called at get_inode() calls and we can use GFP_KERNEL.
  */
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 {
 	int ret;
+	NODEMASK_SCRATCH(scratch);
 
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
 	spin_lock_init(&sp->lock);
@@ -1902,19 +1923,22 @@ void mpol_shared_policy_init(struct shar
 	if (mpol) {
 		struct vm_area_struct pvma;
 		struct mempolicy *new;
-
+		if (!scratch)
+			return;
 		/* contextualize the tmpfs mount point mempolicy */
 		new = mpol_new(mpol->mode, mpol->flags, &mpol->w.user_nodemask);
 		if (IS_ERR(new)) {
 			mpol_put(mpol);	/* drop our ref on sb mpol */
+			NODEMASK_SCRATCH_FREE(scratch);
 			return;		/* no valid nodemask intersection */
 		}
 
 		task_lock(current);
-		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask);
+		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
 		task_unlock(current);
 		mpol_put(mpol);	/* drop our ref on sb mpol */
 		if (ret) {
+			NODEMASK_SCRATCH_FREE(scratch);
 			mpol_put(new);
 			return;
 		}
@@ -1925,6 +1949,7 @@ void mpol_shared_policy_init(struct shar
 		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
 		mpol_put(new);			/* drop initial ref */
 	}
+	NODEMASK_SCRATCH_FREE(scratch);
 }
 
 int mpol_set_shared_policy(struct shared_policy *info,
@@ -2140,13 +2165,18 @@ int mpol_parse_str(char *str, struct mem
 		err = 1;
 	else {
 		int ret;
-
-		task_lock(current);
-		ret = mpol_set_nodemask(new, &nodes);
-		task_unlock(current);
-		if (ret)
+		NODEMASK_SCRATCH(scratch);
+		if (scratch) {
+			task_lock(current);
+			ret = mpol_set_nodemask(new, &nodes, scratch);
+			task_unlock(current);
+		} else
+			ret = -ENOMEM;
+		NODEMASK_SCRATCH_FREE(scratch);
+		if (ret) {
 			err = 1;
-		else if (no_context) {
+			mpol_put(new);
+		} else if (no_context) {
 			/* save for contextualization */
 			new->w.user_nodemask = nodes;
 		}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
