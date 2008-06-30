Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5U7mKmW026586
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 13:18:20 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5U7m0dW1515572
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 13:18:00 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5U7mKQv025910
	for <linux-mm@kvack.org>; Mon, 30 Jun 2008 13:18:20 +0530
Message-ID: <48688FCB.9040205@linux.vnet.ibm.com>
Date: Mon, 30 Jun 2008 13:18:27 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC 5/5] Memory controller soft limit reclaim on contention
References: <20080627151808.31664.36047.sendpatchset@balbir-laptop> <20080627151906.31664.7247.sendpatchset@balbir-laptop> <20080630161657.37E3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
In-Reply-To: <20080630161657.37E3.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

KOSAKI Motohiro wrote:
> Hi
> 
> this code survive stress testing?
> 
> 
>> +		while (count-- &&
>> +			((mem = heap_delete_max(&mem_cgroup_heap)) != NULL)) {
>> +			BUG_ON(!mem->on_heap);
>> +			spin_unlock_irqrestore(&mem_cgroup_heap_lock, flags);
>> +			nr_reclaimed += try_to_free_mem_cgroup_pages(mem,
>> +								gfp_mask);
>> +			cond_resched();
>> +			spin_lock_irqsave(&mem_cgroup_heap_lock, flags);
>> +			mem->on_heap = 0;
>> +			/*
>> +			 * What should be the basis of breaking out?
>> +			 */
>> +			if (nr_reclaimed)
>> +				goto done;
> 
> doubtful shortcut.
> we shouldn't assume we need only one page.
> 

There's a comment on top -- what should be the basis of breaking out? It
definitely needs refinement, the current solution seemed to be working, so I
kept it.

> 
> 
>>  #endif /* _LINUX_MEMCONTROL_H */
>> diff -puN mm/vmscan.c~memory-controller-soft-limit-reclaim-on-contention mm/vmscan.c
>> diff -puN mm/page_alloc.c~memory-controller-soft-limit-reclaim-on-contention mm/page_alloc.c
>> --- linux-2.6.26-rc5/mm/page_alloc.c~memory-controller-soft-limit-reclaim-on-contention	2008-06-27 20:43:10.000000000 +0530
>> +++ linux-2.6.26-rc5-balbir/mm/page_alloc.c	2008-06-27 20:43:10.000000000 +0530
>> @@ -1669,7 +1669,14 @@ nofail_alloc:
>>  	reclaim_state.reclaimed_slab = 0;
>>  	p->reclaim_state = &reclaim_state;
>>  
>> -	did_some_progress = try_to_free_pages(zonelist, order, gfp_mask);
>> +	/*
>> +	 * First try to reclaim from memory control groups that have
>> +	 * exceeded their soft limit
>> +	 */
>> +	did_some_progress = mem_cgroup_reclaim_on_contention(gfp_mask);
>> +	if (!did_some_progress)
>> +		did_some_progress = try_to_free_pages(zonelist, order,
>> +							gfp_mask);
> 
> try_to_free_mem_cgroup_pages() assume memcg need only one page.
> but this code break it.
> 
> if anyone need several continuous memory, mem_cgroup_reclaim_on_contention() reclaim 
> one or a very few page and return >0, then cause page allocation failure.
> 
> shouldn't we extend try_to_free_mem_cgroup_pages() agruments?
> 
> 
> in addition, if we don't assume try_to_free_mem_cgroup_pages() need one page,
> we should implement lumpy reclaim to mem_cgroup_isolate_pages().
> otherwise, cpu wasting significant increase.

The memory controller currently controls just *user* pages, which are all of
order 1. Since pages are faulted in at different times, lumpy reclaim was not
the highest priority for the memory controller. NOTE: the pages are duplicated
on the per-zone LRU, so lumpy reclaim from there should work just fine.

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
