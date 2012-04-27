Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C8F696B004A
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 06:39:37 -0400 (EDT)
Received: by qabg27 with SMTP id g27so281788qab.14
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 03:39:36 -0700 (PDT)
Date: Fri, 27 Apr 2012 12:39:29 +0200
From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [RFC][PATCH 7/9 v2] cgroup: avoid attaching task to a cgroup
 under rmdir()
Message-ID: <20120427103927.GA3514@somewhere.redhat.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
 <4F9A366E.9020307@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F9A366E.9020307@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Glauber Costa <glommer@parallels.com>, Tejun Heo <tj@kernel.org>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On Fri, Apr 27, 2012 at 03:02:22PM +0900, KAMEZAWA Hiroyuki wrote:
> attach_task() is done under cgroup_mutex() but ->pre_destroy() callback
> in rmdir() isn't called under cgroup_mutex().
> 
> It's better to avoid attaching a task to a cgroup which
> is under pre_destroy(). Considering memcg, the attached task may
> increase resource usage after memcg's pre_destroy() confirms that
> memcg is empty. This is not good.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  kernel/cgroup.c |    5 ++++-
>  1 files changed, 4 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/cgroup.c b/kernel/cgroup.c
> index ad8eae5..7a3076b 100644
> --- a/kernel/cgroup.c
> +++ b/kernel/cgroup.c
> @@ -1953,6 +1953,9 @@ int cgroup_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
>  	if (cgrp == oldcgrp)
>  		return 0;
>  
> +	if (test_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags))
> +		return -EBUSY;
> +

You probably need to update cgroup_attach_proc() as well?

>  	tset.single.task = tsk;
>  	tset.single.cgrp = oldcgrp;
>  
> @@ -4181,7 +4184,6 @@ again:
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> -	mutex_unlock(&cgroup_mutex);
>  
>  	/*
>  	 * In general, subsystem has no css->refcnt after pre_destroy(). But
> @@ -4193,6 +4195,7 @@ again:
>  	 * and css_tryget() and cgroup_wakeup_rmdir_waiter() implementation.
>  	 */
>  	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
> +	mutex_unlock(&cgroup_mutex);
>  
>  	/*
>  	 * Call pre_destroy handlers of subsys. Notify subsystems
> -- 
> 1.7.4.1
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
