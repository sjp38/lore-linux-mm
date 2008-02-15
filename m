Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m1F3M4ai021295
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 14:22:04 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1F3PqqB188924
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 14:25:52 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1F3ME2B008430
	for <linux-mm@kvack.org>; Fri, 15 Feb 2008 14:22:14 +1100
Message-ID: <47B504AF.90001@linux.vnet.ibm.com>
Date: Fri, 15 Feb 2008 08:49:11 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC] [PATCH 3/4] Reclaim from groups over their soft limit under
 memory pressure
References: <20080213151242.7529.79924.sendpatchset@localhost.localdomain> <20080214102758.D2CD91E3C58@siro.lan>
In-Reply-To: <20080214102758.D2CD91E3C58@siro.lan>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: linux-mm@kvack.org, hugh@veritas.com, a.p.zijlstra@chello.nl, menage@google.com, Lee.Schermerhorn@hp.com, herbert@13thfloor.at, ebiederm@xmission.com, rientjes@google.com, xemul@openvz.org, nickpiggin@yahoo.com.au, riel@redhat.com, akpm@linux-foundation.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

YAMAMOTO Takashi wrote:
>> +/*
>> + * Free all control groups, which are over their soft limit
>> + */
>> +unsigned long mem_cgroup_pushback_groups_over_soft_limit(struct zone **zones,
>> +								gfp_t gfp_mask)
>> +{
>> +	struct mem_cgroup *mem;
>> +	unsigned long nr_pages;
>> +	long long nr_bytes_over_sl;
>> +	unsigned long ret = 0;
>> +	unsigned long flags;
>> +	struct list_head reclaimed_groups;
>>  
>> +	INIT_LIST_HEAD(&reclaimed_groups);
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
>> +	}
> 
> what prevents the cgroup 'mem' from disappearing while we are dropping
> mem_cgroup_sl_list_lock?
> 

I thought I had a css_get/put around it, but I don't. Thanks for catching the
problem.

> YAMAMOTO Takashi


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
