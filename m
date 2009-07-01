Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8666B004D
	for <linux-mm@kvack.org>; Wed,  1 Jul 2009 19:37:27 -0400 (EDT)
Date: Thu, 2 Jul 2009 08:35:26 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: fix cgroup rmdir hang v4
Message-Id: <20090702083526.17a7881f.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090630180109.f137c10e.kamezawa.hiroyu@jp.fujitsu.com>
	<20090701104747.afdcc6c7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, 1 Jul 2009 10:47:47 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
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

It works very well.
I believe it's ready to go :)

	Tested-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Daisuke Nishimura

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
