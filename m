Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 34DCD6B009D
	for <linux-mm@kvack.org>; Wed, 29 Jul 2009 16:16:35 -0400 (EDT)
Date: Wed, 29 Jul 2009 13:16:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [BUGFIX] set_mempolicy(MPOL_INTERLEAV) N_HIGH_MEMORY aware
Message-Id: <20090729131600.647ff10a.akpm@linux-foundation.org>
In-Reply-To: <20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090715182320.39B5.A69D9226@jp.fujitsu.com>
	<20090728161813.f2fefd29.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com, miaox@cn.fujitsu.com, mingo@elte.hu, a.p.zijlstra@chello.nl, cl@linux-foundation.org, menage@google.com, nickpiggin@yahoo.com.au, y-goto@jp.fujitsu.com, penberg@cs.helsinki.fi, rientjes@google.com, lee.schermerhorn@hp.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 28 Jul 2009 16:18:13 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> tested on x86-64/fake NUMA and ia64/NUMA.
> (That ia64 is a host which orignal bug report used.)

There's no description here of this bug.

Does this patch actually fix a bug?  Seems not.  Confusing.

> Maybe this is bigger patch than expected, but NODEMASK_ALLOC() will be a way
> to go, anyway. (even if CPUMASK_ALLOC is not used anyware yet..)
> Kosaki tested this on ia64 NUMA. thanks.
> 
> I'll wonder more fundamental fix to tsk->mems_allowed but this patch
> is enough as a fix for now, I think.
> 
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> mpol_set_nodemask() should be aware of N_HIGH_MEMORY and policy's nodemask
> should be includes only online nodes.
> In old behavior, this is guaranteed by frequent reference to cpuset's code.
> Now, most of them are removed and mempolicy has to check it by itself.
> 
> To do check, a few nodemask_t will be used for calculating nodemask. But,
> size of nodemask_t can be big and it's not good to allocate them on stack.
> 
> Now, cpumask_t has CPUMASK_ALLOC/FREE an easy code for get scratch area.
> NODEMASK_ALLOC/FREE shoudl be there.
> 
> Tested-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/nodemask.h |   31 +++++++++++++++++
>  mm/mempolicy.c           |   82 ++++++++++++++++++++++++++++++++---------------
>  2 files changed, 87 insertions(+), 26 deletions(-)
> 
> Index: task-mems-allowed-fix/include/linux/nodemask.h
> ===================================================================
> --- task-mems-allowed-fix.orig/include/linux/nodemask.h
> +++ task-mems-allowed-fix/include/linux/nodemask.h
> @@ -82,6 +82,13 @@
>   *    to generate slightly worse code.  So use a simple one-line #define
>   *    for node_isset(), instead of wrapping an inline inside a macro, the
>   *    way we do the other calls.
> + *
> + * NODEMASK_SCRATCH
> + * For doing above logical AND, OR, XOR, Remap, etc...the caller tend to be
> + * necessary to use temporal nodemask_t on stack. But if NODES_SHIFT is large,
> + * size of nodemask_t can be very big and not suitable for allocating in stack.
> + * NODEMASK_SCRATCH is a helper for such situaions. See below and CPUMASK_ALLOC
> + * also.
>   */
>  
>  #include <linux/kernel.h>
> @@ -473,4 +480,28 @@ static inline int num_node_state(enum no
>  #define for_each_node(node)	   for_each_node_state(node, N_POSSIBLE)
>  #define for_each_online_node(node) for_each_node_state(node, N_ONLINE)
>  
> +/*
> + * For nodemask scrach area.(See CPUMASK_ALLOC() in cpumask.h)
> + */
> +
> +#if NODES_SHIFT > 8 /* nodemask_t > 64 bytes */
> +#define NODEMASK_ALLOC(x, m) struct x *m = kmalloc(sizeof(*m), GFP_KERNEL)
> +#define NODEMASK_FREE(m) kfree(m)
> +#else
> +#define NODEMASK_ALLOC(x, m) struct x _m, *m = &_m
> +#define NODEMASK_FREE(m)
> +#endif
> +
> +#define NODEMASK_POINTER(v, m) nodemask_t *v = &(m->v)
> +
> +/* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
> +struct nodemask_scratch {
> +	nodemask_t	mask1;
> +	nodemask_t	mask2;
> +};
> +
> +#define NODEMASK_SCRATCH(x) NODEMASK_ALLOC(nodemask_scratch, x)
> +#define NODEMASK_SCRATCH_FREE(x)  NODEMASK_FREE(x)

Ick.  Ho hum.  OK.  Such is life.

NODEMASK_POINTER() has no callers and is undocumented and unobvious. 
Can I delete it?

>  void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
>  {
>  	int ret;
> +	NODEMASK_SCRATCH(scratch);
>  
>  	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
>  	spin_lock_init(&sp->lock);
> @@ -1902,19 +1923,22 @@ void mpol_shared_policy_init(struct shar
>  	if (mpol) {
>  		struct vm_area_struct pvma;
>  		struct mempolicy *new;
> -
> +		if (!scratch)
> +			return;
>  		/* contextualize the tmpfs mount point mempolicy */
>  		new = mpol_new(mpol->mode, mpol->flags, &mpol->w.user_nodemask);
>  		if (IS_ERR(new)) {
>  			mpol_put(mpol);	/* drop our ref on sb mpol */
> +			NODEMASK_SCRATCH_FREE(scratch);
>  			return;		/* no valid nodemask intersection */
>  		}
>  
>  		task_lock(current);
> -		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask);
> +		ret = mpol_set_nodemask(new, &mpol->w.user_nodemask, scratch);
>  		task_unlock(current);
>  		mpol_put(mpol);	/* drop our ref on sb mpol */
>  		if (ret) {
> +			NODEMASK_SCRATCH_FREE(scratch);
>  			mpol_put(new);
>  			return;
>  		}
> @@ -1925,6 +1949,7 @@ void mpol_shared_policy_init(struct shar
>  		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
>  		mpol_put(new);			/* drop initial ref */
>  	}
> +	NODEMASK_SCRATCH_FREE(scratch);
>  }

This function does an unneeded kmalloc/kfree if mpol==NULL.


How's this look?

diff -puN include/linux/nodemask.h~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix include/linux/nodemask.h
--- a/include/linux/nodemask.h~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix
+++ a/include/linux/nodemask.h
@@ -84,11 +84,10 @@
  *    way we do the other calls.
  *
  * NODEMASK_SCRATCH
- * For doing above logical AND, OR, XOR, Remap, etc...the caller tend to be
- * necessary to use temporal nodemask_t on stack. But if NODES_SHIFT is large,
- * size of nodemask_t can be very big and not suitable for allocating in stack.
- * NODEMASK_SCRATCH is a helper for such situaions. See below and CPUMASK_ALLOC
- * also.
+ * When doing above logical AND, OR, XOR, Remap operations the callers tend to
+ * need temporary nodemask_t's on the stack. But if NODES_SHIFT is large,
+ * nodemask_t's consume too much stack space.  NODEMASK_SCRATCH is a helper
+ * for such situations. See below and CPUMASK_ALLOC also.
  */
 
 #include <linux/kernel.h>
@@ -492,8 +491,6 @@ static inline int num_node_state(enum no
 #define NODEMASK_FREE(m)
 #endif
 
-#define NODEMASK_POINTER(v, m) nodemask_t *v = &(m->v)
-
 /* A example struture for using NODEMASK_ALLOC, used in mempolicy. */
 struct nodemask_scratch {
 	nodemask_t	mask1;
diff -puN mm/mempolicy.c~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix mm/mempolicy.c
--- a/mm/mempolicy.c~mm-make-set_mempolicympol_interleav-n_high_memory-aware-fix
+++ a/mm/mempolicy.c
@@ -1915,7 +1915,6 @@ restart:
 void mpol_shared_policy_init(struct shared_policy *sp, struct mempolicy *mpol)
 {
 	int ret;
-	NODEMASK_SCRATCH(scratch);
 
 	sp->root = RB_ROOT;		/* empty tree == default mempolicy */
 	spin_lock_init(&sp->lock);
@@ -1923,6 +1922,8 @@ void mpol_shared_policy_init(struct shar
 	if (mpol) {
 		struct vm_area_struct pvma;
 		struct mempolicy *new;
+		NODEMASK_SCRATCH(scratch);
+
 		if (!scratch)
 			return;
 		/* contextualize the tmpfs mount point mempolicy */
@@ -1948,8 +1949,8 @@ void mpol_shared_policy_init(struct shar
 		pvma.vm_end = TASK_SIZE;	/* policy covers entire file */
 		mpol_set_shared_policy(sp, &pvma, new); /* adds ref */
 		mpol_put(new);			/* drop initial ref */
+		NODEMASK_SCRATCH_FREE(scratch);
 	}
-	NODEMASK_SCRATCH_FREE(scratch);
 }
 
 int mpol_set_shared_policy(struct shared_policy *info,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
