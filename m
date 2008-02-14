Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1E7hNPi022590
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 18:43:23 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1E7lB8r242296
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 18:47:11 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1E7hW80030214
	for <linux-mm@kvack.org>; Thu, 14 Feb 2008 18:43:33 +1100
Message-ID: <47B3F073.1070804@linux.vnet.ibm.com>
Date: Thu, 14 Feb 2008 13:10:35 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
References: <20080213151201.7529.53642.sendpatchset@localhost.localdomain> <20080213151242.7529.79924.sendpatchset@localhost.localdomain> <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080214163054.81deaf27.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Herbert Poetzl <herbert@13thfloor.at>, "Eric W. Biederman" <ebiederm@xmission.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Rik Van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Wed, 13 Feb 2008 20:42:42 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> +	read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
>> +	while (!list_empty(&mem_cgroup_sl_exceeded_list)) {
>> +		mem = list_first_entry(&mem_cgroup_sl_exceeded_list,
>> +				struct mem_cgroup, sl_exceeded_list);
>> +		list_move(&mem->sl_exceeded_list, &reclaimed_groups);
>> +		read_unlock_irqrestore(&mem_cgroup_sl_list_lock, flags);
>> +
>> +		nr_bytes_over_sl = res_counter_sl_excess(&mem->res);
>> +		if (nr_bytes_over_sl <= 0)
>> +			goto next;
>> +		nr_pages = (nr_bytes_over_sl >> PAGE_SHIFT);
>> +		ret += try_to_free_mem_cgroup_pages(mem, gfp_mask, nr_pages,
>> +							zones);
>> +next:
>> +		read_lock_irqsave(&mem_cgroup_sl_list_lock, flags);
> 
> Hmm... 
> This is triggered by page allocation failure (fast path) in alloc_pages()
> after try_to_free_pages(). 

We trigger it prior to try_to_free_pages() in __alloc_pages()

Then, what pages should be reclaimed is
> depends on zones[]. Because nr-bytes_over_sl is counted globally, cgroup's
> pages may not be included in zones[].
> 

True, that is quite possible.

> And I think it's big workload to relclaim all excessed pages at once.
> 
> How about just reclaiming small # of pages ? like
> ==
> if (nr_bytes_over_sl <= 0)
> 	goto next;
> nr_pages = SWAP_CLUSTER_MAX;

I thought about this, but wanted to push back all groups over their soft limit
back to their soft limit quickly. I'll experiment with your suggestion and see
how the system behaves when we push back pages slowly. Thanks for the suggestion.

> ==
> 
> Regards,
> -Kame


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
