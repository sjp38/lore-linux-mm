Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C20C36B0047
	for <linux-mm@kvack.org>; Mon,  8 Mar 2010 16:22:48 -0500 (EST)
Received: from wpaz9.hot.corp.google.com (wpaz9.hot.corp.google.com [172.24.198.73])
	by smtp-out.google.com with ESMTP id o28LMhAa031731
	for <linux-mm@kvack.org>; Mon, 8 Mar 2010 21:22:44 GMT
Received: from pxi15 (pxi15.prod.google.com [10.243.27.15])
	by wpaz9.hot.corp.google.com with ESMTP id o28LMfpe003748
	for <linux-mm@kvack.org>; Mon, 8 Mar 2010 13:22:42 -0800
Received: by pxi15 with SMTP id 15so2397882pxi.20
        for <linux-mm@kvack.org>; Mon, 08 Mar 2010 13:22:41 -0800 (PST)
Date: Mon, 8 Mar 2010 13:22:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH V2 1/4] cpuset: fix the problem that cpuset_mem_spread_node()
 returns an offline node
In-Reply-To: <4B94CB6C.8090601@cn.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1003081318460.14689@chino.kir.corp.google.com>
References: <4B94CB6C.8090601@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Miao Xie <miaox@cn.fujitsu.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 8 Mar 2010, Miao Xie wrote:

> Changes from V1 to V2:
> - cleanup two unnecessary smp_wmb() at cpuset_migrate_mm()
> 

This patch is already in -mm without this update, so it's probably better 
to make this an incremental series basedo n mmotm-2010-03-04-18-05 or 
later.

> @@ -2090,15 +2086,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
>  static int cpuset_track_online_nodes(struct notifier_block *self,
>  				unsigned long action, void *arg)
>  {
> +	nodemask_t oldmems;
> +
>  	cgroup_lock();
>  	switch (action) {
>  	case MEM_ONLINE:
> -	case MEM_OFFLINE:
> +		oldmems = top_cpuset.mems_allowed;
>  		mutex_lock(&callback_mutex);
>  		top_cpuset.mems_allowed = node_states[N_HIGH_MEMORY];
>  		mutex_unlock(&callback_mutex);
> -		if (action == MEM_OFFLINE)
> -			scan_for_empty_cpusets(&top_cpuset);
> +		update_tasks_nodemask(&top_cpuset, &oldmems, NULL);
> +		break;
> +	case MEM_OFFLINE:
> +		scan_for_empty_cpusets(&top_cpuset);
>  		break;
>  	default:
>  		break;

This looks wrong, why isn't top_cpuset.mems_allowed updated for 
MEM_OFFLINE?  If you're going to update it when a new node comes online 
for (struct memory_notify *)arg->status_change_nid is >= 0, then it should 
be removed from the nodemask when offlined as well.  You'd be calling 
scan_for_empty_cpusets() needlessly in this code since it'll never change 
under your hotplug code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
