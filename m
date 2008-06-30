Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5U3fAgw013718
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 09:11:10 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U3enrI1372206
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 09:10:50 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5U3f9nt006095
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 09:11:09 +0530
Message-ID: <486855DF.2070100@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 09:11:19 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 0/5] Memory controller soft limit introduction (v3)
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080628133615.a5fa16cf.kamezawa.hiroyu@jp.fujitsu.com> <4867174B.3090005@linux.vnet.ibm.com> <20080630102054.ee214765.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080630102054.ee214765.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Sun, 29 Jun 2008 10:32:03 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>> I have a couple of comments.
>>>
>>> 1. Why you add soft_limit to res_coutner ?
>>>    Is there any other controller which uses soft-limit ?
>>>    I'll move watermark handling to memcg from res_counter becasue it's
>>>    required only by memcg.
>>>
>> I expect soft_limits to be controller independent. The same thing can be applied
>> to an io-controller for example, right?
>>
> 
> I can't imagine how soft-limit works on i/o controller. could you explain ?
> 

An io-controller could have the same concept. A hard-limit on the bandwidth and
a soft-limit to allow a group to exceed the soft-limit provided there is no i/o
bandwidth congestion.

> 
>>> 2. *please* handle NUMA
>>>    There is a fundamental difference between global VMM and memcg.
>>>      global VMM - reclaim memory at memory shortage.
>>>      memcg     - for reclaim memory at memory limit
>>>    Then, memcg wasn't required to handle place-of-memory at hitting limit. 
>>>    *just reducing the usage* was enough.
>>>    In this set, you try to handle memory shortage handling.
>>>    So, please handle NUMA, i.e. "what node do you want to reclaim memory from ?"
>>>    If not, 
>>>     - memory placement of Apps can be terrible.
>>>     - cannot work well with cpuset. (I think)
>>>
>> try_to_free_mem_cgroup_pages() handles NUMA right? We start with the
>> node_zonelists of the current node on which we are executing.  I can pass on the
>> zonelist from __alloc_pages_internal() to try_to_free_mem_cgroup_pages(). Is
>> there anything else you had in mind?
>>
> Assume following case of a host with 2 nodes. and following mount style.
> 
> mount -t cgroup -o memory,cpuset none /opt/cgroup/
> 
>   
>   /Group1: cpu 0-1, mem=0 limit=1G, soft-limit=700M
>   /Group2: cpu 2-3, mem=1 limit=1G  soft-limit=700M
>   ....
>   /Groupxxxx
> 
> Assume a environ after some workload, 
> 
>   /Group1: cpu 0-1, mem=0 limit=1G, soft-limit=700M usage=990M
>   /Group2: cpu 2-3, mem=1 limit=1G  soft-limit=700M usage=400M
> 
> *And* memory of node"1" is in shortage and the kernel has to reclaim
> memory from node "1".
> 
> Your routine tries to relclaim memory from a group, which exceeds soft-limit
> ....Group1. But it's no help because Group1 doesn't contains any memory in Node1.
> And make it worse, your routine doen't tries to call try_to_free_pages() in global
> LRU when your soft-limit reclaim some memory. So, if a task in Group 1 continues
> to allocate memory at some speed, memory shortage in Group2 will not be recovered,
> easily.
> 
> This includes 2 aspects of trouble.
>  - Group1's memory is reclaimed but it's wrong.
>  - Group2's try_to_free_pages() may took very long time.
> 
> (Current page shrinking under cpuset seems to scan all nodes,
>  his seems not to be quick, but it works  because it scans all.
>  This will be another problem, anyway ;).
> 
> 
> BTW, currently mem_cgroup_try_to_free_pages() assumes GFP_HIGHUSER_MOVABLE
> always.
> ==
> unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem_cont,
>                                                 gfp_t gfp_mask)
> {
>         struct scan_control sc = {
>                 .may_writepage = !laptop_mode,
>                 .may_swap = 1,
>                 .swap_cluster_max = SWAP_CLUSTER_MAX,
>                 .swappiness = vm_swappiness,
>                 .order = 0,
>                 .mem_cgroup = mem_cont,
>                 .isolate_pages = mem_cgroup_isolate_pages,
>         };
>         struct zonelist *zonelist;
> 
>         sc.gfp_mask = (gfp_mask & GFP_RECLAIM_MASK) |
>                         (GFP_HIGHUSER_MOVABLE & ~GFP_RECLAIM_MASK);
>         zonelist = NODE_DATA(numa_node_id())->node_zonelists;
>         return do_try_to_free_pages(zonelist, &sc);
> }
> ==
> please select appropriate zonelist here.
> 

We do have zonelist information in __alloc_pages_internal(), it should be easy
to pass the zonelist or come up with a good default (current one) if no zonelist
is provided to the routine.


> 
>>> 3. I think  when "mem_cgroup_reclaim_on_contention" exits is unclear.
>>>    plz add explanation of algorithm. It returns when some pages are reclaimed ?
>>>
>> Sure, I will do that.
>>
>>> 4. When swap-full cgroup is on the top of heap, which tends to contain
>>>    tons of memory, much amount of cpu-time will be wasted.
>>>    Can we add "ignore me" flag  ?
>>>
>> Could you elaborate on swap-full cgroup please? Are you referring to changes
>> introduced by the memcg-handle-swap-cache patch? I don't mind adding a ignore me
>> flag, but I guess we need to figure out when a cgroup is swap full.
>>
> No. no-available-swap, or all-swap-are-used situation.
> 
> This situation will happen very easily if swap-controller comes.

We'll definitely deal with it when the swap-controller comes in.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
