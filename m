Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id mACBS65U006429
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:28:06 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mACBQTr5233746
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:26:38 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mACBQSNN012336
	for <linux-mm@kvack.org>; Wed, 12 Nov 2008 22:26:29 +1100
Message-ID: <491ABD61.7090502@linux.vnet.ibm.com>
Date: Wed, 12 Nov 2008 16:56:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [PATCH] [BUGFIX]cgroup: fix potential deadlock in pre_destroy
 (v2)
References: <20081112133002.15c929c3.kamezawa.hiroyu@jp.fujitsu.com> <20081112163256.b36d6952.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20081112163256.b36d6952.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> This is fixed one. Thank you for all help.
> 
> Regards,
> -Kame
> ==
> As Balbir pointed out, memcg's pre_destroy handler has potential deadlock.
> 
> It has following lock sequence.
> 
> 	cgroup_mutex (cgroup_rmdir)
> 	    -> pre_destroy -> mem_cgroup_pre_destroy-> force_empty
> 		-> cpu_hotplug.lock. (lru_add_drain_all->
> 				      schedule_work->
>                                       get_online_cpus)
> 
> But, cpuset has following.
> 	cpu_hotplug.lock (call notifier)
> 		-> cgroup_mutex. (within notifier)
> 
> Then, this lock sequence should be fixed.
> 
> Considering how pre_destroy works, it's not necessary to holding
> cgroup_mutex() while calling it. 
> 
> As side effect, we don't have to wait at this mutex while memcg's force_empty
> works.(it can be long when there are tons of pages.)
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> ---
>  kernel/cgroup.c |   14 +++++++++-----
>  1 file changed, 9 insertions(+), 5 deletions(-)
> 
> Index: mmotm-2.6.28-Nov10/kernel/cgroup.c
> ===================================================================
> --- mmotm-2.6.28-Nov10.orig/kernel/cgroup.c
> +++ mmotm-2.6.28-Nov10/kernel/cgroup.c
> @@ -2475,10 +2475,7 @@ static int cgroup_rmdir(struct inode *un
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> -
> -	parent = cgrp->parent;
> -	root = cgrp->root;
> -	sb = root->sb;
> +	mutex_unlock(&cgroup_mutex);
> 
>  	/*
>  	 * Call pre_destroy handlers of subsys. Notify subsystems
> @@ -2486,7 +2483,14 @@ static int cgroup_rmdir(struct inode *un
>  	 */
>  	cgroup_call_pre_destroy(cgrp);
> 
> -	if (cgroup_has_css_refs(cgrp)) {
> +	mutex_lock(&cgroup_mutex);
> +	parent = cgrp->parent;
> +	root = cgrp->root;
> +	sb = root->sb;
> +
> +	if (atomic_read(&cgrp->count)
> +	    || !list_empty(&cgrp->children)
> +	    || cgroup_has_css_refs(cgrp)) {
>  		mutex_unlock(&cgroup_mutex);
>  		return -EBUSY;
>  	}
> 

I think the last statement deserves a comment that after re-acquiring the lock,
we need to check if count, children or references changed. Otherwise looks good,
though I've not yet tested it.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
