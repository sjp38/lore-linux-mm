Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id kAA9RTGv219488
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:27:29 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kAA9JuoU105126
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:20:07 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kAA9GTbY010462
	for <linux-mm@kvack.org>; Fri, 10 Nov 2006 20:16:29 +1100
Message-ID: <45544362.9040805@in.ibm.com>
Date: Fri, 10 Nov 2006 14:46:18 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 8/8] RSS controller support reclamation
References: <20061109193523.21437.86224.sendpatchset@balbir.in.ibm.com> <20061109193636.21437.11778.sendpatchset@balbir.in.ibm.com> <45543E36.2080600@openvz.org>
In-Reply-To: <45543E36.2080600@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelianov <xemul@openvz.org>
Cc: Linux MM <linux-mm@kvack.org>, dev@openvz.org, ckrm-tech@lists.sourceforge.net, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, haveblue@us.ibm.com, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

Pavel Emelianov wrote:
> Balbir Singh wrote:
>> Reclaim memory as we hit the max_shares limit. The code for reclamation
>> is inspired from Dave Hansen's challenged memory controller and from the
>> shrink_all_memory() code
>>
>> Reclamation can be triggered from two paths
>>
>> 1. While incrementing the RSS, we hit the limit of the container
>> 2. A container is resized, such that it's new limit is below its current
>>    RSS
>>
>> In (1) reclamation takes place in the background.
> 
> Hmm... This is not a hard limit in this case, right? And in case
> of overloaded system from the moment reclamation thread is woken
> up till the moment it starts shrinking zones container may touch
> too many pages...
> 
> That's not good.

Yes, please see my comments in the TODO's. Hard limits should be easy
to implement, it's a question of calling the correct routine based
on policy.

> 
>> TODO's
>>
>> 1. max_shares currently works like a soft limit. The RSS can grow beyond it's
>>    limit. One possible fix is to introduce a soft limit (reclaim when the
>>    container hits the soft limit) and fail when we hit the hard limit
> 
> Such soft limit doesn't help also. It just makes effects on
> low-loaded system smoother.
> 
> And what about a hard limit - how would you fail in page fault in
> case of limit hit? SIGKILL/SEGV is not an option - in this case we
> should run synchronous reclamation. This is done in beancounter
> patches v6 we've sent recently.
> 

I thought about running synchronous reclamation, but then did not follow
that approach, I was not sure if calling the reclaim routines from the
page fault context is a good thing to do. It's worth trying out, since
it would provide better control over rss.


>> Signed-off-by: Balbir Singh <balbir@in.ibm.com>
>> ---
>>
>> --- linux-2.6.19-rc2/mm/vmscan.c~container-memctlr-reclaim	2006-11-09 22:21:11.000000000 +0530
>> +++ linux-2.6.19-rc2-balbir/mm/vmscan.c	2006-11-09 22:21:11.000000000 +0530
>> @@ -36,6 +36,8 @@
>>  #include <linux/rwsem.h>
>>  #include <linux/delay.h>
>>  #include <linux/kthread.h>
>> +#include <linux/container.h>
>> +#include <linux/memctlr.h>
>>  
>>  #include <asm/tlbflush.h>
>>  #include <asm/div64.h>
>> @@ -65,6 +67,9 @@ struct scan_control {
>>  	int swappiness;
>>  
>>  	int all_unreclaimable;
>> +
>> +	int overlimit;
>> +	void *container;	/* Added as void * to avoid #ifdef's */
>>  };
>>  
>>  /*
>> @@ -811,6 +816,10 @@ force_reclaim_mapped:
>>  		cond_resched();
>>  		page = lru_to_page(&l_hold);
>>  		list_del(&page->lru);
>> +		if (!memctlr_page_reclaim(page, sc->container, sc->overlimit)) {
>> +			list_add(&page->lru, &l_active);
>> +			continue;
>> +		}
>>  		if (page_mapped(page)) {
>>  			if (!reclaim_mapped ||
>>  			    (total_swap_pages == 0 && PageAnon(page)) ||
> 
> [snip] See comment below.
> 
>>  
>> +#ifdef CONFIG_RES_GROUPS_MEMORY
>> +/*
>> + * Modelled after shrink_all_memory
>> + */
>> +unsigned long memctlr_shrink_container_memory(unsigned long nr_pages,
>> +						struct container *container,
>> +						int overlimit)
>> +{
>> +	unsigned long lru_pages;
>> +	unsigned long ret = 0;
>> +	int pass;
>> +	struct zone *zone;
>> +	struct scan_control sc = {
>> +		.gfp_mask = GFP_KERNEL,
>> +		.may_swap = 0,
>> +		.swap_cluster_max = nr_pages,
>> +		.may_writepage = 1,
>> +		.swappiness = vm_swappiness,
>> +		.overlimit = overlimit,
>> +		.container = container,
>> +	};
>> +
> 
> [snip]
> 
>> +		for (prio = DEF_PRIORITY; prio >= 0; prio--) {
>> +			unsigned long nr_to_scan = nr_pages - ret;
>> +
>> +			sc.nr_scanned = 0;
>> +			ret += shrink_all_zones(nr_to_scan, prio, pass, &sc);
>> +			if (ret >= nr_pages)
>> +				break;
>> +
>> +			if (sc.nr_scanned && prio < DEF_PRIORITY - 2)
>> +				blk_congestion_wait(WRITE, HZ / 10);
>> +		}
>> +	}
>> +	return ret;
>> +}
>> +#endif
> 
> Please correct me if I'm wrong, but does this reclamation work like
> "run over all the zones' lists searching for page whose controller
> is sc->container" ?
> 

Yeah, that's correct. The code can also reclaim memory from all over-the-limit
containers (by passing SC_OVERLIMIT_ALL). The idea behind using such a scheme
is to ensure that the global LRU list is not broken.


-- 
	Thanks for the feedback,
	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
