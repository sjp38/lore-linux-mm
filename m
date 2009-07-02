Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8B37C6B004D
	for <linux-mm@kvack.org>; Thu,  2 Jul 2009 02:27:50 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n626PYkb032421
	for <linux-mm@kvack.org>; Thu, 2 Jul 2009 00:25:34 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n626UEYf183678
	for <linux-mm@kvack.org>; Thu, 2 Jul 2009 00:30:14 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n626U8hl027585
	for <linux-mm@kvack.org>; Thu, 2 Jul 2009 00:30:14 -0600
Date: Thu, 2 Jul 2009 12:00:05 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: fix cgroup rmdir hang v4
Message-ID: <20090702063002.GO11273@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com> <20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "menage@google.com" <menage@google.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-01 10:47:47]:

> ok, here.
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> After commit: cgroup: fix frequent -EBUSY at rmdir
> 	      ec64f51545fffbc4cb968f0cea56341a4b07e85a
> cgroup's rmdir (especially against memcg) doesn't return -EBUSY
> by temporal ref counts. That commit expects all refs after pre_destroy()
> is temporary but...it wasn't. Then, rmdir can wait permanently.
> This patch tries to fix that and change followings.
> 

Sorry for the late review, a few comments below

>  - set CGRP_WAIT_ON_RMDIR flag before pre_destroy().
>  - clear CGRP_WAIT_ON_RMDIR flag when the subsys finds racy case.
>    if there are sleeping ones, wakes them up.
>  - rmdir() sleeps only when CGRP_WAIT_ON_RMDIR flag is set.
> 
> Changelog v4->v5:
>   - added cgroup_exclude_rmdir(), cgroup_release_rmdir().
> 
> Changelog v3->v4:
>   - rewrite/add comments.
>   - remane cgroup_wakeup_rmdir_waiters() to cgroup_wakeup_rmdir_waiter().
> Changelog v2->v3:
>   - removed retry_rmdir() callback.
>   - make use of CGRP_WAIT_ON_RMDIR flag more.
> 
> Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/cgroup.h |   14 ++++++++++++
>  kernel/cgroup.c        |   55 +++++++++++++++++++++++++++++++++----------------
>  mm/memcontrol.c        |   23 +++++++++++++++++---
>  3 files changed, 72 insertions(+), 20 deletions(-)
> 
> Index: mmotm-2.6.31-Jun25/include/linux/cgroup.h
> ===================================================================
> --- mmotm-2.6.31-Jun25.orig/include/linux/cgroup.h
> +++ mmotm-2.6.31-Jun25/include/linux/cgroup.h
> @@ -366,6 +366,20 @@ int cgroup_task_count(const struct cgrou
>  int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
> 
>  /*
> + * When the subsys has to access css and may add permanent refcnt to css,
> + * it should take care of racy conditions with rmdir(). Following set of
> + * functions, is for stop/restart rmdir if necessary.
> + * Because these will call css_get/put, "css" should be alive css.
> + *
> + *  cgroup_exclude_rmdir();
> + *  ...do some jobs which may access arbitrary empty cgroup
> + *  cgroup_release_rmdir();
> + */
> +
> +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css);
> +void cgroup_release_rmdir(struct cgroup_subsys_state *css);
> +
> +/*
>   * Control Group subsystem type.
>   * See Documentation/cgroups/cgroups.txt for details
>   */
> Index: mmotm-2.6.31-Jun25/kernel/cgroup.c
> ===================================================================
> --- mmotm-2.6.31-Jun25.orig/kernel/cgroup.c
> +++ mmotm-2.6.31-Jun25/kernel/cgroup.c
> @@ -734,16 +734,28 @@ static void cgroup_d_remove_dir(struct d
>   * reference to css->refcnt. In general, this refcnt is expected to goes down
>   * to zero, soon.
>   *
> - * CGRP_WAIT_ON_RMDIR flag is modified under cgroup's inode->i_mutex;
> + * CGRP_WAIT_ON_RMDIR flag is set under cgroup's inode->i_mutex;
>   */
>  DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
> 
> -static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> +static void cgroup_wakeup_rmdir_waiter(struct cgroup *cgrp)

Should the function explictly mention rmdir? Also something like
release_rmdir should be called release_and_wakeup to make the action
clearer.

Looks good to me otherwise and clean.

>  {
> -	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> +	if (unlikely(test_and_clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
>  		wake_up_all(&cgroup_rmdir_waitq);
>  }
> 
> +void cgroup_exclude_rmdir(struct cgroup_subsys_state *css)
> +{
> +	css_get(css);
> +}
> +
> +void cgroup_release_rmdir(struct cgroup_subsys_state *css)
> +{
> +	cgroup_wakeup_rmdir_waiter(css->cgroup);
> +	css_put(css);
> +}
> +
> +
>  static int rebind_subsystems(struct cgroupfs_root *root,
>  			      unsigned long final_bits)
>  {
> @@ -1357,7 +1369,7 @@ int cgroup_attach_task(struct cgroup *cg
>  	 * wake up rmdir() waiter. the rmdir should fail since the cgroup
>  	 * is no longer empty.
>  	 */
> -	cgroup_wakeup_rmdir_waiters(cgrp);
> +	cgroup_wakeup_rmdir_waiter(cgrp);
>  	return 0;
>  }
> 
> @@ -2696,33 +2708,42 @@ again:
>  	mutex_unlock(&cgroup_mutex);
> 
>  	/*
> +	 * In general, subsystem has no css->refcnt after pre_destroy(). But
> +	 * in racy cases, subsystem may have to get css->refcnt after
> +	 * pre_destroy() and it makes rmdir return with -EBUSY. This sometimes
> +	 * make rmdir return -EBUSY too often. To avoid that, we use waitqueue
> +	 * for cgroup's rmdir. CGRP_WAIT_ON_RMDIR is for synchronizing rmdir
> +	 * and subsystem's reference count handling. Please see css_get/put
> +	 * and css_tryget() and cgroup_wakeup_rmdir_waiter() implementation.
> +	 */
> +	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> +
> +	/*
>  	 * Call pre_destroy handlers of subsys. Notify subsystems
>  	 * that rmdir() request comes.
>  	 */
>  	ret = cgroup_call_pre_destroy(cgrp);
> -	if (ret)
> +	if (ret) {
> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		return ret;
> +	}
> 
>  	mutex_lock(&cgroup_mutex);
>  	parent = cgrp->parent;
>  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> -	/*
> -	 * css_put/get is provided for subsys to grab refcnt to css. In typical
> -	 * case, subsystem has no reference after pre_destroy(). But, under
> -	 * hierarchy management, some *temporal* refcnt can be hold.
> -	 * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
> -	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
> -	 * is called when css_put() is called and refcnt goes down to 0.
> -	 */
> -	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
> -
>  	if (!cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
> -		schedule();
> +		/*
> +		 * Because someone may call cgroup_wakeup_rmdir_waiter() before
> +		 * prepare_to_wait(), we need to check this flag.
> +		 */
> +		if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
> +			schedule();
>  		finish_wait(&cgroup_rmdir_waitq, &wait);
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		if (signal_pending(current))
> @@ -3294,7 +3315,7 @@ void __css_put(struct cgroup_subsys_stat
>  			set_bit(CGRP_RELEASABLE, &cgrp->flags);
>  			check_for_release(cgrp);
>  		}
> -		cgroup_wakeup_rmdir_waiters(cgrp);
> +		cgroup_wakeup_rmdir_waiter(cgrp);
>  	}
>  	rcu_read_unlock();
>  }
> Index: mmotm-2.6.31-Jun25/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.31-Jun25.orig/mm/memcontrol.c
> +++ mmotm-2.6.31-Jun25/mm/memcontrol.c
> @@ -1234,6 +1234,12 @@ static int mem_cgroup_move_account(struc
>  	ret = 0;
>  out:
>  	unlock_page_cgroup(pc);
> +	/*
> +	 * We charges against "to" which may not have any tasks. Then, "to"
> +	 * can be under rmdir(). But in current implementation, caller of
> +	 * this function is just force_empty() and it's garanteed that
> +	 * "to" is never removed. So, we don't check rmdir status here.
> +	 */
>  	return ret;
>  }
> 
> @@ -1455,6 +1461,7 @@ __mem_cgroup_commit_charge_swapin(struct
>  		return;
>  	if (!ptr)
>  		return;
> +	cgroup_exclude_rmdir(&ptr->css);
>  	pc = lookup_page_cgroup(page);
>  	mem_cgroup_lru_del_before_commit_swapcache(page);
>  	__mem_cgroup_commit_charge(ptr, pc, ctype);
> @@ -1484,8 +1491,12 @@ __mem_cgroup_commit_charge_swapin(struct
>  		}
>  		rcu_read_unlock();
>  	}
> -	/* add this page(page_cgroup) to the LRU we want. */
> -
> +	/*
> +	 * At swapin, we may charge account against cgroup which has no tasks.
> +	 * So, rmdir()->pre_destroy() can be called while we do this charge.
> +	 * In that case, we need to call pre_destroy() again. check it here.
> +	 */
> +	cgroup_release_rmdir(&ptr->css);
>  }
> 
>  void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> @@ -1691,7 +1702,7 @@ void mem_cgroup_end_migration(struct mem
> 
>  	if (!mem)
>  		return;
> -
> +	cgroup_exclude_rmdir(&mem->css);
>  	/* at migration success, oldpage->mapping is NULL. */
>  	if (oldpage->mapping) {
>  		target = oldpage;
> @@ -1731,6 +1742,12 @@ void mem_cgroup_end_migration(struct mem
>  	 */
>  	if (ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
>  		mem_cgroup_uncharge_page(target);
> +	/*
> +	 * At migration, we may charge account against cgroup which has no tasks
> +	 * So, rmdir()->pre_destroy() can be called while we do this charge.
> +	 * In that case, we need to call pre_destroy() again. check it here.
> +	 */
> +	cgroup_release_rmdir(&mem->css);
>  }
> 
>  /*
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
