Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2R85ADC010487
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 19:05:10 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2R85o5F1265808
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 19:05:50 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2R85n5o019023
	for <linux-mm@kvack.org>; Thu, 27 Mar 2008 19:05:50 +1100
Message-ID: <47EB548D.2050609@linux.vnet.ibm.com>
Date: Thu, 27 Mar 2008 13:32:21 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
 (v2)
References: <20080326184954.9465.19379.sendpatchset@localhost.localdomain> <20080326185017.9465.29950.sendpatchset@localhost.localdomain> <47EB4A7E.6060505@openvz.org>
In-Reply-To: <47EB4A7E.6060505@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> Balbir Singh wrote:
>> Changelog v2
>> ------------
>> Change the accounting to what is already present in the kernel. Split
>> the address space accounting into mem_cgroup_charge_as and
>> mem_cgroup_uncharge_as. At the time of VM expansion, call
>> mem_cgroup_cannot_expand_as to check if the new allocation will push
>> us over the limit
>>
>> This patch implements accounting and control of virtual address space.
>> Accounting is done when the virtual address space of any task/mm_struct
>> belonging to the cgroup is incremented or decremented. This patch
>> fails the expansion if the cgroup goes over its limit.
>>
>> TODOs
>>
>> 1. Only when CONFIG_MMU is enabled, is the virtual address space control
>>    enabled. Should we do this for nommu cases as well? My suspicion is
>>    that we don't have to.
>>
>> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
>> ---
>>
>>  arch/ia64/kernel/perfmon.c  |    2 +
>>  arch/x86/kernel/ptrace.c    |    7 +++
>>  fs/exec.c                   |    2 +
>>  include/linux/memcontrol.h  |   26 +++++++++++++
>>  include/linux/res_counter.h |   19 ++++++++--
>>  init/Kconfig                |    2 -
>>  kernel/fork.c               |   17 +++++++--
>>  mm/memcontrol.c             |   83 ++++++++++++++++++++++++++++++++++++++++++++
>>  mm/mmap.c                   |   11 +++++
>>  mm/mremap.c                 |    2 +
>>  10 files changed, 163 insertions(+), 8 deletions(-)
>>
>> diff -puN mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control mm/memcontrol.c
>> --- linux-2.6.25-rc5/mm/memcontrol.c~memory-controller-virtual-address-space-accounting-and-control	2008-03-26 16:27:59.000000000 +0530
>> +++ linux-2.6.25-rc5-balbir/mm/memcontrol.c	2008-03-27 00:18:16.000000000 +0530
>> @@ -526,6 +526,76 @@ unsigned long mem_cgroup_isolate_pages(u
>>  	return nr_taken;
>>  }
>>  
>> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_AS
>> +/*
>> + * Charge the address space usage for cgroup. This routine is most
>> + * likely to be called from places that expand the total_vm of a mm_struct.
>> + */
>> +void mem_cgroup_charge_as(struct mm_struct *mm, long nr_pages)
>> +{
>> +	struct mem_cgroup *mem;
>> +
>> +	if (mem_cgroup_subsys.disabled)
>> +		return;
>> +
>> +	rcu_read_lock();
>> +	mem = rcu_dereference(mm->mem_cgroup);
>> +	css_get(&mem->css);
>> +	rcu_read_unlock();
>> +
>> +	res_counter_charge(&mem->as_res, (nr_pages * PAGE_SIZE));
>> +	css_put(&mem->css);
> 
> Why don't you check whether the counter is charged? This is
> bad for two reasons:
> 1. you allow for some growth above the limit (e.g. in expand_stack)

I was doing that earlier and then decided to keep the virtual address space code
in sync with the RLIMIT_AS checking code in the kernel. If you see the flow, it
closely resembles what we do with mm->total_vm and may_expand_vm().
expand_stack() in turn calls acct_stack_growth() which calls may_expand_vm()

> 2. you will undercharge it in the future when uncharging the
>    vme, whose charge was failed and thus unaccounted.

Hmmm...  This should ideally never happen, since we do a may_expand_vm() before
expanding the VM and in our case the virtual address space usage. I've not seen
it during my runs either. But it is something to keep in mind.

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
