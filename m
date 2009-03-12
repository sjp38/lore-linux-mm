Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 7079A6B003D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 19:09:10 -0400 (EDT)
Date: Thu, 12 Mar 2009 16:04:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 3/4] Memory controller soft limit organize cgroups (v5)
Message-Id: <20090312160424.7d6f146c.akpm@linux-foundation.org>
In-Reply-To: <20090312175625.17890.94795.sendpatchset@localhost.localdomain>
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain>
	<20090312175625.17890.94795.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 23:26:25 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Feature: Organize cgroups over soft limit in a RB-Tree
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v5...v4
> 1. res_counter_uncharge has an additional parameter to indicate if the
>    counter was over its soft limit, before uncharge.
> 
> Changelog v4...v3
> 1. Optimizations to ensure we don't uncessarily get res_counter values
> 2. Fixed a bug in usage of time_after()
> 
> Changelog v3...v2
> 1. Add only the ancestor to the RB-Tree
> 2. Use css_tryget/css_put instead of mem_cgroup_get/mem_cgroup_put
> 
> Changelog v2...v1
> 1. Add support for hierarchies
> 2. The res_counter that is highest in the hierarchy is returned on soft
>    limit being exceeded. Since we do hierarchical reclaim and add all
>    groups exceeding their soft limits, this approach seems to work well
>    in practice.
> 
> This patch introduces a RB-Tree for storing memory cgroups that are over their
> soft limit. The overall goal is to
> 
> 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
>    We are careful about updates, updates take place only after a particular
>    time interval has passed
> 2. We remove the node from the RB-Tree when the usage goes below the soft
>    limit
> 
> The next set of patches will exploit the RB-Tree to get the group that is
> over its soft limit by the largest amount and reclaim from it, when we
> face memory contention.
> 
>
> ...
>
> +#define	MEM_CGROUP_TREE_UPDATE_INTERVAL		(HZ/4)

Wall-clock time is a quite poor way of tracking system activity. 
There's little correlation between the two things.

>From a general design point of view it would be better to pace this
polling activity in a manner which correlates with the amount of system
activity.  For example, "once per 100,000 pages scanned" is much more
adaptive than "once per 250 milliseconds".

>
> ...
>> @@ -2459,6 +2561,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
>  		parent = NULL;
> +		mem_cgroup_soft_limit_tree = RB_ROOT;

This can be done at compile time?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
