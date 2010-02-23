Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2941A6B0095
	for <linux-mm@kvack.org>; Tue, 23 Feb 2010 02:33:02 -0500 (EST)
Message-ID: <4B838490.1050908@cn.fujitsu.com>
Date: Tue, 23 Feb 2010 15:32:32 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: Re: [regression] cpuset,mm: update tasks' mems_allowed in time (58568d2)
References: <20100218134921.GF9738@laptop> <alpine.DEB.2.00.1002181302430.13707@chino.kir.corp.google.com> <20100219033126.GI9738@laptop> <alpine.DEB.2.00.1002190143040.6293@chino.kir.corp.google.com> <4B827043.3060305@cn.fujitsu.com> <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1002221339160.14426@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

on 2010-2-23 6:06, David Rientjes wrote:
>>>> Right, but the callback_mutex was being removed by this patch.
>>>>
>>>
>>> I was making the case for it to be readded :)
>>
>> But cgroup_mutex is held when someone changes cs->cpus_allowed or doing hotplug,
>> so I think callback_mutex is not necessary in this case.
>>
> 
> Then why is it taken in update_cpumask()?

when we read cs->cpus_allowed, we need just hold one of callback_mutex and cgroup_mutex.
If we want to change cs->cpus_allowed, we must hold callback_mutex and cgroup_mutex.

>>  /*
>> @@ -1391,11 +1393,10 @@ static void cpuset_attach(struct cgroup_subsys *ss, struct cgroup *cont,
>>  
>>  	if (cs == &top_cpuset) {
>>  		cpumask_copy(cpus_attach, cpu_possible_mask);
>> -		to = node_possible_map;
>>  	} else {
>>  		guarantee_online_cpus(cs, cpus_attach);
>> -		guarantee_online_mems(cs, &to);
>>  	}
>> +	guarantee_online_mems(cs, &to);
>>  
>>  	/* do per-task migration stuff possibly for each in the threadgroup */
>>  	cpuset_attach_task(tsk, &to, cs);
> 
> Do we need to set cpus_attach to cpu_possible_mask?  Why won't 
> cpu_active_mask suffice?

If we set cpus_attach to cpu_possible_mask, we needn't do anything for tasks in the top_cpuset when
doing cpu hotplug. If not, we will update cpus_allowed of all tasks in the top_cpuset.

> 
>> @@ -2090,15 +2091,19 @@ static int cpuset_track_online_cpus(struct notifier_block *unused_nb,
>>  static int cpuset_track_online_nodes(struct notifier_block *self,
>>  				unsigned long action, void *arg)
>>  {
>> +	nodemask_t oldmems;
> 
> Is it possible to use NODEMASK_ALLOC() instead?

Yes. I will write another patch to fix it.(These are the same problems in the other functions) 




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
