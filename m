Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 79B5C6B0055
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 23:07:01 -0400 (EDT)
Date: Thu, 18 Jun 2009 12:03:35 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
Message-Id: <20090618120335.d6431cb7.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090616174436.5a4b6577.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
	<20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
	<20090615120213.e9a3bd1d.kamezawa.hiroyu@jp.fujitsu.com>
	<20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
	<20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616153810.fd710c5b.nishimura@mxp.nes.nec.co.jp>
	<20090616154820.c9065809.kamezawa.hiroyu@jp.fujitsu.com>
	<20090616174436.5a4b6577.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm <linux-mm@kvack.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, 16 Jun 2009 17:44:36 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Tue, 16 Jun 2009 15:48:20 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > > It has been working well so far, but I will continue to test for more long time.
> > > 
> > Thank you. I'd like to find out more clean fix, keeping this as an option.
> > 
> This is cleaned up version. works well in following test.
> 
> ==
> 1. mount -t tmpfs /dev/null /mnt/tmpfs
> 2. mount -t cgroup /dev/null /mnt/cgroups -o memory
> 3. mkdir /mnt/cgroups/A/
> 4. echo $$ > /mnt/cgroups/A/tasks
> 5. echo 4M > /mnt/cgroups/A/memory.limit_in_bytes
> 5. dd if=/dev/zero of=/mnt/tmpfs/testfile bs=1024 count=30000
>  => 26M of swap.
> 6. echo $$ > /mnt/cgroups/tasks
>  => group "A" is empty now.
> 7-a. while true; do cat /mnt/tmpfs/testfile > /dev/null;done
> 
> In ohter shell.
> 7-b. rmdir /mnt/cgroups/A
> ==
> Of course, you have more compliated ones..
> 
> the patch seems a bit long but most of patch is comment..
> 
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> In general, cgroup is for tasks and cgroup subsys(css)'s refcnt is maintained
> per objects related to tasks. But memcg counts refcnt per pages because
> the pointer to css is recorded per page. And more, hierarchy-management support
> requires safe css refcnt management while a rmdir() is ongoing.
> 
> css_tryget()/css_put() is for such purpose and works well.
> 
> But, frequent css_put()/get() tends to prevent rmdir() and users can see
> EBUSY very often. To fix that, waitqueue-for-rmdir was introduced and
> rmdir() can work in synchronous way with cgroup subsytems. But this logic
> expects "refcnt obtained by css_tryget() is temporal and will go down to
> 0 soon, then rmdir() will wake up soon."
> 
> But memcg's swapin code breaks the assumption. (But necessary...)
> This patch try to reuse another anotation of CGRP_WAIT_ON_RMDIR flag to
> check whether cgroup is under rmdir if memcg got a *not termporal* refcnt 
> by css_tryget().
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  include/linux/cgroup.h |    7 +++++++
>  kernel/cgroup.c        |   46 +++++++++++++++++++++++++++-------------------
>  mm/memcontrol.c        |   11 +++++++++--
>  3 files changed, 43 insertions(+), 21 deletions(-)
> 
> Index: linux-2.6.30.org/include/linux/cgroup.h
> ===================================================================
> --- linux-2.6.30.org.orig/include/linux/cgroup.h
> +++ linux-2.6.30.org/include/linux/cgroup.h
> @@ -365,6 +365,13 @@ int cgroup_task_count(const struct cgrou
>  /* Return true if cgrp is a descendant of the task's cgroup */
>  int cgroup_is_descendant(const struct cgroup *cgrp, struct task_struct *task);
>  
> +void __cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp);
> +static inline void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> +{
> +	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> +		__cgroup_wakeup_rmdir_waiters(cgrp);
> +}
> +
>  /*
>   * Control Group subsystem type.
>   * See Documentation/cgroups/cgroups.txt for details
> Index: linux-2.6.30.org/kernel/cgroup.c
> ===================================================================
> --- linux-2.6.30.org.orig/kernel/cgroup.c
> +++ linux-2.6.30.org/kernel/cgroup.c
> @@ -737,10 +737,9 @@ static void cgroup_d_remove_dir(struct d
>   */
>  DECLARE_WAIT_QUEUE_HEAD(cgroup_rmdir_waitq);
>  
> -static void cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
> +void __cgroup_wakeup_rmdir_waiters(const struct cgroup *cgrp)
>  {
> -	if (unlikely(test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags)))
> -		wake_up_all(&cgroup_rmdir_waitq);
> +	wake_up_all(&cgroup_rmdir_waitq);
>  }
>  
>  static int rebind_subsystems(struct cgroupfs_root *root,
> @@ -2667,13 +2666,27 @@ static int cgroup_rmdir(struct inode *un
>  
>  	/* the vfs holds both inode->i_mutex already */
>  again:
> +	/*
> +	 * css_put/get is provided for subsys to grab refcnt to css. In typical
> +	 * case, subsystem has no reference after pre_destroy(). But, under
> +	 * hierarchy management, some *temporal* refcnt can be hold.
> +	 * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
> +	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
> +	 * is called when css_put() is called and refcnt goes down to 0.
> +	 *
> +	 * Subsys can check CGRP_WAIT_ON_RMDIR bit by itself to know
> +	 * it's under ongoing rmdir() or not. Because css_tryget() returns false
> +	 * only after css->refcnt returns 0, checking this bit is useful when
> +	 * css' refcnt seems to be not temporal.
> +	 */
> +	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> +	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
> +
I'm sorry if I misunderstand something.

Preparing waitq here means force_empty would be called with TASK_INTERRUPTIBLE,
so current can sleep with TASK_INTRRUPTIBLE by cond_resched().

Can we ensure that it can be waken up, especially in case we are not under
memory pressure ?

>  	mutex_lock(&cgroup_mutex);
> -	if (atomic_read(&cgrp->count) != 0) {
> -		mutex_unlock(&cgroup_mutex);
> -		return -EBUSY;
> -	}
> -	if (!list_empty(&cgrp->children)) {
> +	if (atomic_read(&cgrp->count) != 0 || !list_empty(&cgrp->children)) {
>  		mutex_unlock(&cgroup_mutex);
> +		finish_wait(&cgroup_rmdir_waitq, &wait);
> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		return -EBUSY;
>  	}
>  	mutex_unlock(&cgroup_mutex);
> @@ -2683,25 +2696,20 @@ again:
>  	 * that rmdir() request comes.
>  	 */
>  	ret = cgroup_call_pre_destroy(cgrp);
> -	if (ret)
> +	if (ret) {
> +		finish_wait(&cgroup_rmdir_waitq, &wait);
> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>  		return ret;
> +	}
>  
>  	mutex_lock(&cgroup_mutex);
>  	parent = cgrp->parent;
>  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
>  		mutex_unlock(&cgroup_mutex);
> +		finish_wait(&cgroup_rmdir_waitq, &wait);
> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
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
> -	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
>  
>  	if (!cgroup_clear_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
> Index: linux-2.6.30.org/mm/memcontrol.c
> ===================================================================
> --- linux-2.6.30.org.orig/mm/memcontrol.c
> +++ linux-2.6.30.org/mm/memcontrol.c
> @@ -1338,6 +1338,7 @@ __mem_cgroup_commit_charge_swapin(struct
>  		return;
>  	if (!ptr)
>  		return;
> +	css_get(&ptr->css);
What's the purpose of this css_get ?
Can you add a comment ?

>  	pc = lookup_page_cgroup(page);
>  	mem_cgroup_lru_del_before_commit_swapcache(page);
>  	__mem_cgroup_commit_charge(ptr, pc, ctype);
> @@ -1367,8 +1368,14 @@ __mem_cgroup_commit_charge_swapin(struct
>  		}
>  		rcu_read_unlock();
>  	}
> -	/* add this page(page_cgroup) to the LRU we want. */
> -
> +	/*
> +	 * Because we charged against a cgroup which is obtained by record
> +	 * in swap_cgroup, not by task, there is a possibility that someone is
> +	 * waiting for rmdir. This happens when a swap entry is shared
> +	 * among cgroups. After wakeup, pre_destroy() will be called again.
> +	 */
> +	cgroup_wakeup_rmdir_waiters(&ptr->css.cgroup);
'&' must be removed here.

> +	css_put(&ptr->css);
>  }
>  
>  void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> 
> 


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
