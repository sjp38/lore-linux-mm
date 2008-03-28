Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id m2SAuCmR001563
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:56:12 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m2SB0II2127848
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 22:00:18 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m2SAub36010676
	for <linux-mm@kvack.org>; Fri, 28 Mar 2008 21:56:37 +1100
Message-ID: <47ECCE00.70803@linux.vnet.ibm.com>
Date: Fri, 28 Mar 2008 16:22:48 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [-mm] Add an owner to the mm_struct (v2)
References: <20080328082316.6961.29044.sendpatchset@localhost.localdomain> <20080328195516.494edde3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080328195516.494edde3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Fri, 28 Mar 2008 13:53:16 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> -static struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>> +struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p)
>>  {
>>  	return container_of(task_subsys_state(p, mem_cgroup_subsys_id),
>>  				struct mem_cgroup, css);
>> @@ -250,12 +250,17 @@ void mm_init_cgroup(struct mm_struct *mm
>>  
>>  	mem = mem_cgroup_from_task(p);
>>  	css_get(&mem->css);
>> -	mm->mem_cgroup = mem;
>>  }
>>  
>>  void mm_free_cgroup(struct mm_struct *mm)
>>  {
>> -	css_put(&mm->mem_cgroup->css);
>> +	struct mem_cgroup *mem;
>> +
>> +	/*
>> +	 * TODO: Should we assign mm->owner to NULL here?
>> +	 */
>> +	mem = mem_cgroup_from_task(rcu_dereference(mm->owner));
>> +	css_put(&mem->css);
>>  }
>>  
> How about changing this css_get()/css_put() from accounting against mm_struct
> to accouting against task_struct ?
> It seems simpler way after this mm->owner change.

But the reason why we account the mem_cgroup is that we don't want the
mem_cgroup to be deleted. I hope you meant mem_cgroup instead of mm_struct.

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
