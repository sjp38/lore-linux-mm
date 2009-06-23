Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4CFF96B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 20:23:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5N0NwWc021401
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 23 Jun 2009 09:23:58 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EB8E345DD70
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:23:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C7DE945DD71
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:23:57 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A60A51DB8042
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:23:57 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B8201DB803A
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 09:23:57 +0900 (JST)
Date: Tue, 23 Jun 2009 09:22:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] cgroup: fix permanent wait in rmdir
Message-Id: <20090623092223.a44e7b20.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090622183707.dd9e665b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090622183707.dd9e665b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Jun 2009 18:37:07 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> previous discussion was this => http://marc.info/?t=124478543600001&r=1&w=2
> 
> I think this is a minimum fix (in code size and behavior) and because
> we can take a BIG LOCK, this kind of check is necessary, anyway.
> Any comments are welcome.

I'll split this into 2 patches...and I found I should check page-migration, too.
Then, modifing swap account logic is not help, at last.

Thanks,
-Kame

> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, cgroup has a logic to wait until ready-to-rmdir for avoiding
> frequent -EBUSY at rmdir.
>  (See Commit ec64f51545fffbc4cb968f0cea56341a4b07e85a
>   cgroup: fix frequent -EBUSY at rmdir.
> 
> Nishimura-san reported bad case for waiting and This is a fix to
> make it reliable. A thread waiting for thread cannot be waken up
> when a refcnt gotten by css_tryget() isn't put immediately.
> (Original code assumed css_put() will be called soon.)
> 
> memcg has this case and this is a fix for the problem. This adds
> retry_rmdir() callback to subsys and check we can sleep or not
> before sleeping and export CGRP_WAIT_ON_RMDIR flag to subsys.
> 
> Note: another solution will be adding "rmdir state" to subsys.
> But it will be much complicated than this do-enough-check solution.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  Documentation/cgroups/cgroups.txt |   11 +++++++++++
>  include/linux/cgroup.h            |    9 +++++++++
>  kernel/cgroup.c                   |   25 +++++++++++++++++++++----
>  mm/memcontrol.c                   |   29 ++++++++++++++++++++++++++---
>  4 files changed, 67 insertions(+), 7 deletions(-)
> 
> Index: linux-2.6.30-git18/include/linux/cgroup.h
> ===================================================================
> --- linux-2.6.30-git18.orig/include/linux/cgroup.h
> +++ linux-2.6.30-git18/include/linux/cgroup.h
> @@ -192,6 +192,14 @@ struct cgroup {
>  	struct rcu_head rcu_head;
>  };
>  
> +void __cgroup_wakeup_rmdir_waiters(void);
> +static inline void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> +{
> +	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> +		__cgroup_wakeup_rmdir_waiters();
> +}
> +
> +
>  /*
>   * A css_set is a structure holding pointers to a set of
>   * cgroup_subsys_state objects. This saves space in the task struct
> @@ -374,6 +382,7 @@ struct cgroup_subsys {
>  	struct cgroup_subsys_state *(*create)(struct cgroup_subsys *ss,
>  						  struct cgroup *cgrp);
>  	int (*pre_destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +	int (*retry_rmdir)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	void (*destroy)(struct cgroup_subsys *ss, struct cgroup *cgrp);
>  	int (*can_attach)(struct cgroup_subsys *ss,
>  			  struct cgroup *cgrp, struct task_struct *tsk);
> Index: linux-2.6.30-git18/kernel/cgroup.c
> ===================================================================
> --- linux-2.6.30-git18.orig/kernel/cgroup.c
> +++ linux-2.6.30-git18/kernel/cgroup.c
> @@ -636,6 +636,23 @@ static int cgroup_call_pre_destroy(struc
>  		}
>  	return ret;
>  }
> +/*
> + * Call subsys's retry_rmdir() handler. If this returns non-Zero, we retry
> + * rmdir immediately and call pre_destroy again.
> + */
> +static int cgroup_check_retry_rmdir(struct cgroup *cgrp)
> +{
> +	struct cgroup_subsys *ss;
> +	int ret = 0;
> +
> +	for_each_subsys(cgrp->root, ss)
> +		if (ss->pre_destroy) {
> +			ret = ss->retry_rmdir(ss, cgrp);
> +			if (ret)
> +				break;
> +		}
> +	return ret;
> +}
>  
>  static void free_cgroup_rcu(struct rcu_head *obj)
>  {
> @@ -738,10 +755,9 @@ static void cgroup_d_remove_dir(struct d
>   */
>  DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
>  
> -static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> +void __cgroup_wakeup_rmdir_waiters(void)
>  {
> -	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> -		wake_up_all(&cgroup_rmdir_waitq);
> +	wake_up_all(&cgroup_rmdir_waitq);
>  }
>  
>  static int rebind_subsystems(struct cgroupfs_root *root,
> @@ -2722,7 +2738,8 @@ again:
>  
>  	if (!cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
> -		schedule();
> +		if (!cgroup_check_retry_rmdir(cgrp))
> +			schedule();
>  		finish_wait(&cgroup_rmdir_waitq, &wait);
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		if (signal_pending(current))
> Index: linux-2.6.30-git18/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.30-git18.orig/mm/memcontrol.c
> +++ linux-2.6.30-git18/mm/memcontrol.c
> @@ -179,7 +179,6 @@ struct mem_cgroup {
>  
>  	/* set when res.limit == memsw.limit */
>  	bool		memsw_is_minimum;
> -
>  	/*
>  	 * statistics. This must be placed at the end of memcg.
>  	 */
> @@ -1428,6 +1427,9 @@ __mem_cgroup_commit_charge_swapin(struct
>  		return;
>  	if (!ptr)
>  		return;
> +	/* We access ptr->css.cgroup later. keep 1 refcnt here. */
> +	css_get(&ptr->css);
> +
>  	pc = lookup_page_cgroup(page);
>  	mem_cgroup_lru_del_before_commit_swapcache(page);
>  	__mem_cgroup_commit_charge(ptr, pc, ctype);
> @@ -1457,8 +1459,16 @@ __mem_cgroup_commit_charge_swapin(struct
>  		}
>  		rcu_read_unlock();
>  	}
> -	/* add this page(page_cgroup) to the LRU we want. */
> -
> +	/*
> +	 * At swapin, "ptr" is got from swap_cgroup and not from task. Then,
> +	 * this ptr can be under rmdir(). Under race with rmdir(), we may
> +	 * charge against cgroup which a thread is waiting for restart rmdir().
> +	 * It can be waken up when css's refcnt goes to 0 but we charged...
> +	 * Because we can't do css_get()->charge in atomic, at swapin, we have
> +	 * to check there is no waiter for rmdir.
> +	 */
> +	cgroup_wakeup_rmdir_waiters(ptr->css.cgroup);
> +	css_put(&ptr->css);
>  }
>  
>  void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> @@ -2556,6 +2566,7 @@ mem_cgroup_create(struct cgroup_subsys *
>  
>  	if (parent)
>  		mem->swappiness = get_swappiness(parent);
> +
>  	atomic_set(&mem->refcnt, 1);
>  	return &mem->css;
>  free_out:
> @@ -2571,6 +2582,17 @@ static int mem_cgroup_pre_destroy(struct
>  	return mem_cgroup_force_empty(mem, false);
>  }
>  
> +static int mem_cgroup_retry_rmdir(struct cgroup_subsys *ss,
> +				  struct cgroup *cont)
> +{
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> +
> +	if (res_counter_read_u64(&memcg->res, RES_USAGE))
> +		return 1;
> +	return 0;
> +}
> +
> +
>  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
>  				struct cgroup *cont)
>  {
> @@ -2610,6 +2632,7 @@ struct cgroup_subsys mem_cgroup_subsys =
>  	.subsys_id = mem_cgroup_subsys_id,
>  	.create = mem_cgroup_create,
>  	.pre_destroy = mem_cgroup_pre_destroy,
> +	.retry_rmdir = mem_cgroup_retry_rmdir,
>  	.destroy = mem_cgroup_destroy,
>  	.populate = mem_cgroup_populate,
>  	.attach = mem_cgroup_move_task,
> Index: linux-2.6.30-git18/Documentation/cgroups/cgroups.txt
> ===================================================================
> --- linux-2.6.30-git18.orig/Documentation/cgroups/cgroups.txt
> +++ linux-2.6.30-git18/Documentation/cgroups/cgroups.txt
> @@ -500,6 +500,17 @@ there are not tasks in the cgroup. If pr
>  rmdir() will fail with it. From this behavior, pre_destroy() can be
>  called multiple times against a cgroup.
>  
> +int retry_rmdir(struct cgroup_subsys *ss, struct cgroup *cgrp);
> +
> +Called at rmdir right after the kernel finds there are remaining refcnt on
> +subsystems after pre_destroy(). When retry_rmdir() returns 0, the caller enter
> +sleep and wakes up when css's refcnt goes down to 0 by css_put().
> +When this returns 1, the caller doesn't sleep and retry rmdir immediately.
> +This is useful when the subsys knows remaining css's refcnt is not temporal
> +and to calling pre_destroy() again is proper way to remove that.
> +(or proper way to retrun -EBUSY.)
> +
> +
>  int can_attach(struct cgroup_subsys *ss, struct cgroup *cgrp,
>  	       struct task_struct *task)
>  (cgroup_mutex held by caller)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
