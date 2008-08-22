Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m7MDJCwX031419
	for <linux-mm@kvack.org>; Fri, 22 Aug 2008 23:19:12 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7MDKEAl3874964
	for <linux-mm@kvack.org>; Fri, 22 Aug 2008 23:20:18 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7MDKDXF030987
	for <linux-mm@kvack.org>; Fri, 22 Aug 2008 23:20:13 +1000
Message-ID: <48AEBD06.5060704@linux.vnet.ibm.com>
Date: Fri, 22 Aug 2008 18:50:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 0/14]  Mem+Swap Controller v2
References: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080822202720.b7977aab.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Hi, I totally rewrote the series. maybe easier to be reviewed.
> 
> This patch series provides memory resource controller enhancement(candidates)
> Codes are totally rewritten from "preview".
> Based on rc3 + a bit old mmtom (may not have conflicts with the latest...)
> (I'm not so in hurry now, please see when you have time.)
> 
> Contents are following. I'll push them gradually when it seems O.K.
> 
>  - New force_empty implementation.
>    - rather than drop all accounting, move all accounting to "root".
>      This behavior can be changed later (based on some policy.)
>      It may take some amount of time about "good" policy, I think start from
>      "move charge to the root" is good. I want to hear opinions about this
>      interface's behavior.
> 
>  - Lockless page_cgroup
>    - Removes lock_page_cgroup() and makes access to page->page_cgroup safe
>      under some situation. This will makes memcg's lock semantics to
>      be better.
>      
>  - Exporting page_cgroup.
>    - Because of Lockess page_cgroup, we can easily access page_cgroup from
>      outside of memcontrol.c. There are some people who ask me to allow
>      them to access page_cgroup.
> 
>  - Mem+Swap controller.
>    - This controller is implemented as an extention of memory controller.
>      If Mem+Swap controller is enabled, you can set 2 limits ans see    
>      2 counters.
> 
>      memory.limit_in_bytes .... limit of amounts of pages.
>      memory.memsw_limit_in_bytes .... limit of amounts of the sum of pages 
>                                       and swap_on_disks.
>      memory.usage_in_bytes .... current usage of on-memory pages.
>      memory.memory.swap_in_bytes .... current usage of swaps which is not 
>                                       on_memory.
> 
> Any feedback, comments are welcome.
> 
> This set passed some fundamental tests on small box and works good.
> but I have not done long-run test on big box. So, you may see panic
> of race conditions....
> 
> TODO:
>   - Update Documentation more.
>   - Long-run test.
>   - Update force_empty's policy.
> 
> Major Changes from v1.
>   - force_empty is updated.
>   - small bug fix on Lockless page_cgroup.
>   - Mem+Swap controller is added. (Implementation detail is quite different
>     from preview version. But no change in algorithm.)
> 
> Patch series:
>   I'd like to push patch 1...9 in early than 10..14
>   Comments about the direction of patch 1,2,11,13 is helpful.
> 
> 1. unlimted_root_cgroup.patch 
>             .... makes root cgroup's limitation to unlimited.
> 2. new_force_empty.patch
>             .... rewrite force_empty to move the resource rather
> 3. atomic_flags.patch
>             .... makes page_cgroup->flags modification to atomic_ops.
> 4. lazy-lru-freeing.patch
>             .... makes freeing of page_cgroup to be delayed.
> 5. rcu-free.patch
>             ....freeing of page_cgroup by RCU.
> 6. lockess.patch
>             ....remove lock_page_cgroup()
> 7. prefetch.patch
>             .... just adds prefetch().
> 8. make_mapping_null.patch
>             .... guarantee page->mapping to be NULL before uncharge
>                  file cache (and check it by BUG_ON)
> 9. split-page-cgroup.patch
>             .... add page_cgroup.h file.
> 10. mem_counter.patch
>             .... replace res_coutner with mem_counter, newly added.
>                  (reason of this patch will be shown in patch[11])
> 11. memcgrp_id.patch
>             .... give each mem_cgroup its own ID.

To be honest, I think something like this needs to happen at the cgroups level, no?

> 12. swap_cgroup_config.patch
>             .... Add Kconfig and some macro for Mem+Swap Controller.
> 13. swap_counter.patch
>             .... modifies mem_counter to handle swaps.
> 14. swap_account.patch
>             .... account swap.

This is too fast for me to review. I'll review this series anyway. I was also
hoping to getting down to user space notifications for OOM and pagevec series.
Let me see if I can do the latter quickly.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
