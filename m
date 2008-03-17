Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2HCr3XT014830
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 23:53:03 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2HCrIII4370460
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 23:53:18 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2HCrIEi029993
	for <linux-mm@kvack.org>; Mon, 17 Mar 2008 23:53:18 +1100
Message-ID: <47DE695D.3080605@linux.vnet.ibm.com>
Date: Mon, 17 Mar 2008 18:21:41 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][2/3] Account and control virtual address space allocations
References: <20080316172942.8812.56051.sendpatchset@localhost.localdomain> <20080316173005.8812.88290.sendpatchset@localhost.localdomain> <47DE57C2.5060206@openvz.org> <47DE640F.3070601@linux.vnet.ibm.com> <47DE66BE.30904@openvz.org>
In-Reply-To: <47DE66BE.30904@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pavel Emelyanov <xemul@openvz.org>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Pavel Emelyanov wrote:
> Balbir Singh wrote:
>> Pavel Emelyanov wrote:
>>> [snip]
>>>
>>>> +int mem_cgroup_update_as(struct mm_struct *mm, long nr_pages)
>>>> +{
>>>> +	int ret = 0;
>>>> +	struct mem_cgroup *mem;
>>>> +	if (mem_cgroup_subsys.disabled)
>>>> +		return ret;
>>>> +
>>>> +	rcu_read_lock();
>>>> +	mem = rcu_dereference(mm->mem_cgroup);
>>>> +	css_get(&mem->css);
>>>> +	rcu_read_unlock();
>>>> +
>>>> +	if (nr_pages > 0) {
>>>> +		if (res_counter_charge(&mem->as_res, (nr_pages * PAGE_SIZE)))
>>>> +			ret = 1;
>>>> +	} else
>>>> +		res_counter_uncharge(&mem->as_res, (-nr_pages * PAGE_SIZE));
>>> No, please, no. Let's make two calls - mem_cgroup_charge_as and mem_cgroup_uncharge_as.
>>>
>>> [snip]
>>>
>> Yes, sure :)
> 
> Thanks :)
> 
>>>> @@ -1117,6 +1117,9 @@ munmap_back:
>>>>  		}
>>>>  	}
>>>>  
>>>> +	if (mem_cgroup_update_as(mm, len >> PAGE_SHIFT))
>>>> +		return -ENOMEM;
>>>> +
>>> Why not use existintg cap_vm_enough_memory and co?
>>>
>> I thought about it and almost used may_expand_vm(), but there is a slight catch
>> there. With cap_vm_enough_memory() or security_vm_enough_memory(), they are
>> called after total_vm has been calculated. In our case we need to keep the
>> cgroups equivalent of total_vm up to date, and we do this in mem_cgorup_update_as.
> 
> So? What prevents us from using these hooks? :)

1. We need to account total_vm usage of the task anyway. So why have two places,
   one for accounting and second for control?
2. These hooks are activated for conditionally invoked for vma's with VM_ACCOUNT
   set.


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
