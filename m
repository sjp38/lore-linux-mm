Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C2A746B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 00:23:17 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id o215NB9a003358
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 10:53:11 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o215NBmP2752578
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 10:53:11 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o215NBE6002679
	for <linux-mm@kvack.org>; Mon, 1 Mar 2010 16:23:11 +1100
Date: Mon, 1 Mar 2010 10:53:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [patch -mm v2 04/10] oom: remove special handling for pagefault
 ooms
Message-ID: <20100301052306.GG19665@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.1002261549290.30830@chino.kir.corp.google.com>
 <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1002261551030.30830@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2010-02-26 15:53:11]:

> It is possible to remove the special pagefault oom handler by simply
> oom locking all system zones and then calling directly into
> out_of_memory().
> 
> All populated zones must have ZONE_OOM_LOCKED set, otherwise there is a
> parallel oom killing in progress that will lead to eventual memory
> freeing so it's not necessary to needlessly kill another task.  The
> context in which the pagefault is allocating memory is unknown to the oom
> killer, so this is done on a system-wide level.
> 
> If a task has already been oom killed and hasn't fully exited yet, this
> will be a no-op since select_bad_process() recognizes tasks across the
> system with TIF_MEMDIE set.
> 
> The special handling to determine whether a parallel memcg is currently
> oom is removed since we can detect future memory freeing with TIF_MEMDIE.
> The memcg has already reached its memory limit, so it will still need to
> kill a task regardless of the pagefault oom.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
>  include/linux/memcontrol.h |    6 ---
>  mm/memcontrol.c            |   35 +---------------
>  mm/oom_kill.c              |   97 ++++++++++++++++++++++++++------------------
>  3 files changed, 58 insertions(+), 80 deletions(-)
> 
> diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
> --- a/include/linux/memcontrol.h
> +++ b/include/linux/memcontrol.h
> @@ -124,7 +124,6 @@ static inline bool mem_cgroup_disabled(void)
>  	return false;
>  }
> 
> -extern bool mem_cgroup_oom_called(struct task_struct *task);
>  void mem_cgroup_update_file_mapped(struct page *page, int val);
>  unsigned long mem_cgroup_soft_limit_reclaim(struct zone *zone, int order,
>  						gfp_t gfp_mask, int nid,
> @@ -258,11 +257,6 @@ static inline bool mem_cgroup_disabled(void)
>  	return true;
>  }
> 
> -static inline bool mem_cgroup_oom_called(struct task_struct *task)
> -{
> -	return false;
> -}
> -
>  static inline int
>  mem_cgroup_inactive_anon_is_low(struct mem_cgroup *memcg)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -217,7 +217,6 @@ struct mem_cgroup {
>  	 * Should the accounting and control be hierarchical, per subtree?
>  	 */
>  	bool use_hierarchy;
> -	unsigned long	last_oom_jiffies;
>  	atomic_t	refcnt;
> 
>  	unsigned int	swappiness;
> @@ -1205,34 +1204,6 @@ static int mem_cgroup_hierarchical_reclaim(struct mem_cgroup *root_mem,
>  	return total;
>  }
> 
> -bool mem_cgroup_oom_called(struct task_struct *task)
> -{
> -	bool ret = false;
> -	struct mem_cgroup *mem;
> -	struct mm_struct *mm;
> -
> -	rcu_read_lock();
> -	mm = task->mm;
> -	if (!mm)
> -		mm = &init_mm;
> -	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
> -	if (mem && time_before(jiffies, mem->last_oom_jiffies + HZ/10))
> -		ret = true;
> -	rcu_read_unlock();
> -	return ret;
> -}
> -
> -static int record_last_oom_cb(struct mem_cgroup *mem, void *data)
> -{
> -	mem->last_oom_jiffies = jiffies;
> -	return 0;
> -}
> -
> -static void record_last_oom(struct mem_cgroup *mem)
> -{
> -	mem_cgroup_walk_tree(mem, NULL, record_last_oom_cb);
> -}
> -
>  /*
>   * Currently used to update mapped file statistics, but the routine can be
>   * generalized to update other statistics as well.
> @@ -1484,10 +1455,8 @@ static int __mem_cgroup_try_charge(struct mm_struct *mm,
>  			continue;
> 
>  		if (!nr_retries--) {
> -			if (oom) {
> +			if (oom)
>  				mem_cgroup_out_of_memory(mem_over_limit, gfp_mask);
> -				record_last_oom(mem_over_limit);
> -			}
>  			goto nomem;
>  		}
>  	}
> @@ -2284,8 +2253,6 @@ void mem_cgroup_end_migration(struct mem_cgroup *mem,
> 
>  /*
>   * A call to try to shrink memory usage on charge failure at shmem's swapin.
> - * Calling hierarchical_reclaim is not enough because we should update
> - * last_oom_jiffies to prevent pagefault_out_of_memory from invoking global OOM.
>   * Moreover considering hierarchy, we should reclaim from the mem_over_limit,
>   * not from the memcg which this page would be charged to.
>   * try_charge_swapin does all of these works properly.
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -580,6 +580,44 @@ void clear_zonelist_oom(struct zonelist *zonelist, gfp_t gfp_mask)
>  }
> 
>  /*
> + * Try to acquire the oom killer lock for all system zones.  Returns zero if a
> + * parallel oom killing is taking place, otherwise locks all zones and returns
> + * non-zero.
> + */
> +static int try_set_system_oom(void)
> +{
> +	struct zone *zone;
> +	int ret = 1;
> +
> +	spin_lock(&zone_scan_lock);
> +	for_each_populated_zone(zone)
> +		if (zone_is_oom_locked(zone)) {
> +			ret = 0;
> +			goto out;
> +		}
> +	for_each_populated_zone(zone)
> +		zone_set_flag(zone, ZONE_OOM_LOCKED);
> +out:
> +	spin_unlock(&zone_scan_lock);
> +	return ret;
> +}

Isn't this an overkill, if pagefault_out_of_memory() does nothing and
oom takes longer than anticipated, we might end up looping, no?
Aren't we better off waiting for OOM to finish and retry the
pagefault?

And like Kame said the pagefault code in memcg is undergoing a churn,
we should revisit those parts later. I am yet to review that
patchset though.

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
