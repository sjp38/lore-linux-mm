Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx128.postini.com [74.125.245.128])
	by kanga.kvack.org (Postfix) with SMTP id 232F96B004D
	for <linux-mm@kvack.org>; Fri, 20 Jul 2012 03:51:19 -0400 (EDT)
Date: Fri, 20 Jul 2012 09:51:12 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] cgroup: Don't drop the cgroup_mutex in cgroup_rmdir
Message-ID: <20120720075112.GA12434@tiehlicka.suse.cz>
References: <87ipdjc15j.fsf@skywalker.in.ibm.com>
 <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1342706972-10912-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com, liwanp@linux.vnet.ibm.com, htejun@gmail.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-mm@kvack.org

On Thu 19-07-12 19:39:32, Aneesh Kumar K.V wrote:
> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
> 
> We dropped cgroup mutex, because of a deadlock between memcg and cpuset.
> cpuset took hotplug lock followed by cgroup_mutex, where as memcg pre_destroy
> did lru_add_drain_all() which took hotplug lock while already holding
> cgroup_mutex. The deadlock is explained in 3fa59dfbc3b223f02c26593be69ce6fc9a940405
> But dropping cgroup_mutex in cgroup_rmdir also means tasks could get
> added to cgroup while we are in pre_destroy. This makes error handling in
> pre_destroy complex. So move the unlock/lock to memcg pre_destroy callback.
> Core cgroup will now call pre_destroy with cgroup_mutex held.

OK, this should be good for now but we should definitely work towards
not messing with cgroup_mutex like that and remove the hack from memcg
callback in the long term.

> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  kernel/cgroup.c |    3 +--
>  mm/memcontrol.c |   11 ++++++++++-
>  2 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index 7981850..01c67f4 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -4151,7 +4151,6 @@ again:
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> -	mutex_unlock(&cgroup_mutex);
>  
>  	/*
>  	 * In general, subsystem has no css->refcnt after pre_destroy(). But
> @@ -4171,10 +4170,10 @@ again:
>  	ret = cgroup_call_pre_destroy(cgrp);
>  	if (ret) {
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> +		mutex_unlock(&cgroup_mutex);
>  		return ret;
>  	}
>  
> -	mutex_lock(&cgroup_mutex);
>  	parent = cgrp->parent;
>  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
>  		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e8ddc00..9bd56ee 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4993,9 +4993,18 @@ free_out:
>  
>  static int mem_cgroup_pre_destroy(struct cgroup *cont)
>  {
> +	int ret;
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cont);
>  
> -	return mem_cgroup_force_empty(memcg, false);
> +	cgroup_unlock();
> +	/*
> +	 * we call lru_add_drain_all, which end up taking
> +	 * mutex_lock(&cpu_hotplug.lock), But cpuset have
> +	 * the reverse order. So drop the cgroup lock
> +	 */
> +	ret = mem_cgroup_force_empty(memcg, false);
> +	cgroup_lock();
> +	return ret;
>  }
>  
>  static void mem_cgroup_destroy(struct cgroup *cont)
> -- 
> 1.7.10
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
