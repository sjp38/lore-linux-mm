Date: Wed, 10 Dec 2008 11:28:15 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH 1/6] memcg: fix pre_destory handler
Message-Id: <20081210112815.d5098e9e.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com>
	<20081209200647.a1fa76a9.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, nishimura@mxp.nes.nec.co.jp
List-ID: <linux-mm.kvack.org>

On Tue, 9 Dec 2008 20:06:47 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> better name for new flag is welcome.
> 
> ==
> Because pre_destroy() handler is moved out to cgroup_lock() for
> avoiding dead-lock, now, cgroup's rmdir() does following sequence.
> 
> 	cgroup_lock()
> 	check children and tasks.
> 	(A)
> 	cgroup_unlock()
> 	(B)
> 	pre_destroy() for subsys;-----(1)
> 	(C)
> 	cgroup_lock();
> 	(D)
> 	Second check:check for -EBUSY again because we released the lock.
> 	(E)
> 	mark cgroup as removed.
> 	(F)
> 	unlink from lists.
> 	cgroup_unlock();
> 	dput()
> 	=> when dentry's refcnt goes down to 0
> 		destroy() handers for subsys
> 
> memcg marks itself as "obsolete" when pre_destroy() is called at (1)
> But rmdir() can fail after pre_destroy(). So marking "obsolete" is bug.
> I'd like to fix sanity of pre_destroy() in cgroup layer.
> 
> Considering above sequence, new tasks can be added while
> 	(B) and (C)
> swap-in recored can be charged back to a cgroup after pre_destroy()
> 	at (C) and (D), (E)
> (means cgrp's refcnt not comes from task but from other persistent objects.)
> 
> This patch adds "cgroup_is_being_removed()" check. (better name is welcome)
> After this,
> 
> 	- cgroup is marked as CGRP_PRE_REMOVAL at (A)
> 	- If Second check fails, CGRP_PRE_REMOVAL flag is removed.
> 	- memcg's its own obsolete flag is removed.
> 	- While CGROUP_PRE_REMOVAL, task attach will fail by -EBUSY.
> 	  (task attach via clone() will not hit the case.)
> 
> By this, we can trust pre_restroy()'s result.
> 
> 
I agrree to the direction of this patch, but I think it would be better
to split this into cgroup and memcg part.

> Note: if CGRP_REMOVED can be set and cleared, it should be used instead of
>       CGRP_PRE_REMOVAL.
> 
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  include/linux/cgroup.h |    5 +++++
>  kernel/cgroup.c        |   18 +++++++++++++++++-
>  mm/memcontrol.c        |   36 ++++++++++++++++++++++++++----------
>  3 files changed, 48 insertions(+), 11 deletions(-)
> 
> Index: mmotm-2.6.28-Dec08/mm/memcontrol.c
> ===================================================================
> --- mmotm-2.6.28-Dec08.orig/mm/memcontrol.c
> +++ mmotm-2.6.28-Dec08/mm/memcontrol.c
> @@ -166,7 +166,6 @@ struct mem_cgroup {
>  	 */
>  	bool use_hierarchy;
>  	unsigned long	last_oom_jiffies;
> -	int		obsolete;
>  	atomic_t	refcnt;
>  
>  	unsigned int	swappiness;
> @@ -211,6 +210,24 @@ pcg_default_flags[NR_CHARGE_TYPE] = {
>  static void mem_cgroup_get(struct mem_cgroup *mem);
>  static void mem_cgroup_put(struct mem_cgroup *mem);
>  
> +static bool memcg_is_obsolete(struct mem_cgroup *mem)
> +{
> +	struct cgroup *cg = mem->css.cgroup;
> +	/*
> +	 * "Being Removed" means pre_destroy() handler is called.
> +	 * After  "pre_destroy" handler is called, memcg should not
> +	 * have any additional charges.
> +	 * This means there are small races for mis-accounting. But this
> +	 * mis-accounting should happen only under swap-in opration.
> +	 * (Attachin new task will fail if cgroup is under rmdir()).
> +	 */
> +
> +	if (!cg || cgroup_is_removed(cg) || cgroup_is_being_removed(cg))
> +		return true;
> +	return false;
> +}
> +
> +
>  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
>  					 struct page_cgroup *pc,
>  					 bool charge)
> @@ -597,7 +614,7 @@ mem_cgroup_get_first_node(struct mem_cgr
>  	struct cgroup *cgroup;
>  	struct mem_cgroup *ret;
>  	bool obsolete = (root_mem->last_scanned_child &&
> -				root_mem->last_scanned_child->obsolete);
> +			memcg_is_obsolete(root_mem->last_scanned_child);
>  
>  	/*
>  	 * Scan all children under the mem_cgroup mem
> @@ -1070,7 +1087,7 @@ int mem_cgroup_try_charge_swapin(struct 
>  	ent.val = page_private(page);
>  
>  	mem = lookup_swap_cgroup(ent);
> -	if (!mem || mem->obsolete)
> +	if (!mem || memcg_is_obsolete(mem))
>  		goto charge_cur_mm;
>  	*ptr = mem;
>  	return __mem_cgroup_try_charge(NULL, mask, ptr, true);
> @@ -1104,7 +1121,7 @@ int mem_cgroup_cache_charge_swapin(struc
>  		ent.val = page_private(page);
>  		if (do_swap_account) {
>  			mem = lookup_swap_cgroup(ent);
> -			if (mem && mem->obsolete)
> +			if (mem && memcg_is_obsolete(mem))
>  				mem = NULL;
>  			if (mem)
>  				mm = NULL;
> @@ -2050,9 +2067,6 @@ static struct mem_cgroup *mem_cgroup_all
>   * the number of reference from swap_cgroup and free mem_cgroup when
>   * it goes down to 0.
>   *
> - * When mem_cgroup is destroyed, mem->obsolete will be set to 0 and
> - * entry which points to this memcg will be ignore at swapin.
> - *
>   * Removal of cgroup itself succeeds regardless of refs from swap.
>   */
>  
> @@ -2081,7 +2095,7 @@ static void mem_cgroup_get(struct mem_cg
>  static void mem_cgroup_put(struct mem_cgroup *mem)
>  {
>  	if (atomic_dec_and_test(&mem->refcnt)) {
> -		if (!mem->obsolete)
> +		if (!memcg_is_obsolete(mem))
>  			return;
>  		mem_cgroup_free(mem);
>  	}
> @@ -2148,14 +2162,16 @@ static void mem_cgroup_pre_destroy(struc
>  					struct cgroup *cont)
>  {
>  	struct mem_cgroup *mem = mem_cgroup_from_cont(cont);
> -	mem->obsolete = 1;
>  	mem_cgroup_force_empty(mem, false);
>  }
>  
>  static void mem_cgroup_destroy(struct cgroup_subsys *ss,
>  				struct cgroup *cont)
>  {
> -	mem_cgroup_free(mem_cgroup_from_cont(cont));
> +	struct mem_cgroup *mem = mem_cgroup_from_cont(cont):
> +	mem_cgroup_free(mem);
> +	/* forget */
> +	mem->css.cgroup = NULL;
>  }
>  
Is it OK to access "mem" while it may have been freed ?

>  static int mem_cgroup_populate(struct cgroup_subsys *ss,
> Index: mmotm-2.6.28-Dec08/include/linux/cgroup.h
> ===================================================================
> --- mmotm-2.6.28-Dec08.orig/include/linux/cgroup.h
> +++ mmotm-2.6.28-Dec08/include/linux/cgroup.h
> @@ -98,6 +98,8 @@ enum {
>  	CGRP_RELEASABLE,
>  	/* Control Group requires release notifications to userspace */
>  	CGRP_NOTIFY_ON_RELEASE,
> +	/* Control Group is preparing for death */
> +	CGRP_PRE_REMOVAL,
>  };
>  
>  struct cgroup {
> @@ -303,8 +305,11 @@ int cgroup_add_files(struct cgroup *cgrp
>  			const struct cftype cft[],
>  			int count);
>  
> +
>  int cgroup_is_removed(const struct cgroup *cgrp);
>  
> +int cgroup_is_being_removed(const struct cgroup *cgrp);
> +
>  int cgroup_path(const struct cgroup *cgrp, char *buf, int buflen);
>  
>  int cgroup_task_count(const struct cgroup *cgrp);
> Index: mmotm-2.6.28-Dec08/kernel/cgroup.c
> ===================================================================
> --- mmotm-2.6.28-Dec08.orig/kernel/cgroup.c
> +++ mmotm-2.6.28-Dec08/kernel/cgroup.c
> @@ -123,6 +123,11 @@ inline int cgroup_is_removed(const struc
>  	return test_bit(CGRP_REMOVED, &cgrp->flags);
>  }
>  
> +inline int cgroup_is_being_removed(const struct cgroup *cgrp)
> +{
> +	return test_bit(CGRP_PRE_REMOVAL, &cgrp->flags);
> +}
> +
>  /* bits in struct cgroupfs_root flags field */
>  enum {
>  	ROOT_NOPREFIX, /* mounted subsystems have no named prefix */
> @@ -1217,6 +1222,13 @@ int cgroup_attach_task(struct cgroup *cg
>  	if (cgrp == oldcgrp)
>  		return 0;
>  
> +	/*
> +	 * This cgroup is under rmdir() operation. Never fails here when this
> + 	 * is called from clone().
> + 	 */
I don't think clone() calls cgroup_attach_task().
Do you mean cgroup_clone() ?
(I'm sorry that I'm not good at ns_cgroup.)

> +	if (cgroup_is_being_removed(cgrp))
> +		return -EBUSY;
> +
>  	for_each_subsys(root, ss) {
>  		if (ss->can_attach) {
>  			retval = ss->can_attach(ss, cgrp, tsk);
> @@ -2469,12 +2481,14 @@ static int cgroup_rmdir(struct inode *un
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> -	mutex_unlock(&cgroup_mutex);
>  
>  	/*
>  	 * Call pre_destroy handlers of subsys. Notify subsystems
>  	 * that rmdir() request comes.
>  	 */
> +	set_bit(CGRP_PRE_REMOVAL, &cgrp->flags);
> +	mutex_unlock(&cgroup_mutex);
> +
>  	cgroup_call_pre_destroy(cgrp);
>  
Is there any case where pre_destory is called simultaneusly ?

>  	mutex_lock(&cgroup_mutex);
> @@ -2483,12 +2497,14 @@ static int cgroup_rmdir(struct inode *un
>  	if (atomic_read(&cgrp->count)
>  	    || !list_empty(&cgrp->children)
>  	    || cgroup_has_css_refs(cgrp)) {
> +		clear_bit(CGRP_PRE_REMOVAL, &cgrp->flags);
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
>  
>  	spin_lock(&release_list_lock);
>  	set_bit(CGRP_REMOVED, &cgrp->flags);
> +	clear_bit(CGRP_PRE_REMOVAL, &cgrp->flags);
>  	if (!list_empty(&cgrp->release_list))
>  		list_del(&cgrp->release_list);
>  	spin_unlock(&release_list_lock);
> 


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
