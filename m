Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id DB9025F0001
	for <linux-mm@kvack.org>; Mon,  6 Apr 2009 14:42:19 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n36IgrhA001349
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 00:12:53 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n36Id2NB4448358
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 00:09:04 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n36IgoZv003897
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 00:12:50 +0530
Date: Tue, 7 Apr 2009 00:12:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/9] soft limit queue and priority
Message-ID: <20090406184221.GL7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090403170835.a2d6cbc3.kamezawa.hiroyu@jp.fujitsu.com> <20090403171248.df3e1b03.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090403171248.df3e1b03.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-03 17:12:48]:

> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Softlimitq. for memcg.
> 
> Implements an array of queue to list memcgs, array index is determined by
> the amount of memory usage excess the soft limit.
> 
> While Balbir's one uses RB-tree and my old one used a per-zone queue
> (with round-robin), this is one of mixture of them.
> (I'd like to use rotation of queue in later patches)
> 
> Priority is determined by following.
>    Assume unit = total pages/1024. (the code uses different value)
>    if excess is...
>       < unit,          priority = 0, 
>       < unit*2,        priority = 1,
>       < unit*2*2,      priority = 2,
>       ...
>       < unit*2^9,      priority = 9,
>       < unit*2^10,     priority = 10, (> 50% to total mem)
> 
> This patch just includes queue management part and not includes 
> selection logic from queue. Some trick will be used for selecting victims at
> soft limit in efficient way.
> 
> And this equips 2 queues, for anon and file. Inset/Delete of both list is
> done at once but scan will be independent. (These 2 queues are used later.)
> 
> Major difference from Balbir's one other than RB-tree is bahavior under
> hierarchy. This one adds all children to queue by checking hierarchical
> priority. This is for helping per-zone usage check on victim-selection logic.
> 
> Changelog: v1->v2
>  - fixed comments.
>  - change base size to exponent.
>  - some micro optimization to reduce code size.
>  - considering memory hotplug, it's not good to record a value calculated
>    from totalram_pages at boot and using it later is bad manner. Fixed it.
>  - removed soft_limit_lock (spinlock) 
>  - added soft_limit_update counter for avoiding mulptiple update at once.
>    
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |  118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++-
>  1 file changed, 117 insertions(+), 1 deletion(-)
> 
> Index: softlimit-test2/mm/memcontrol.c
> ===================================================================
> --- softlimit-test2.orig/mm/memcontrol.c
> +++ softlimit-test2/mm/memcontrol.c
> @@ -192,7 +192,14 @@ struct mem_cgroup {
>  	atomic_t	refcnt;
> 
>  	unsigned int	swappiness;
> -
> +	/*
> +	 * For soft limit.
> +	 */
> +	int soft_limit_priority;
> +	struct list_head soft_limit_list[2];

Looking at the rest of the code in the patch, it is not apparent as to
why we need two list_heads/array of list_heads?

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
