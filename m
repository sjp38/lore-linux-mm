Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp03.in.ibm.com (8.13.1/8.13.1) with ESMTP id m5KDY70A021041
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 19:04:07 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5KDXn8j942310
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 19:03:49 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m5KDY6op002813
	for <linux-mm@kvack.org>; Fri, 20 Jun 2008 19:04:06 +0530
Message-ID: <485BB1C3.6000009@linux.vnet.ibm.com>
Date: Fri, 20 Jun 2008 19:03:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Question : memrlimit cgroup's task_move (2.6.26-rc5-mm3)
References: <20080619121435.f868c110.kamezawa.hiroyu@jp.fujitsu.com> <20080619182556.GA10461@balbir.in.ibm.com> <20080620091316.80771d14.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080620091316.80771d14.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "menage@google.com" <menage@google.com>, "containers@lists.osdl.org" <containers@lists.osdl.org>
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> On Thu, 19 Jun 2008 23:55:56 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
>> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-06-19 12:14:35]:
>>
>>> I used memrlimit cgroup at the first time.
>>>
>>> May I ask a question about memrlimit cgroup ?
>>>
>> Hi, Kamezawa-San,
>>
>> Could you please review/test the patch below to see if it solves your
>> problem? If it does, I'll push it up to Andrew
>>
> 
> At quick glance,
>> +	/*
>> +	 * NOTE: Even though we do the necessary checks in can_attach(),
>> +	 * by the time we come here, there is a chance that we still
>> +	 * fail (the memrlimit cgroup has grown its usage, and the
>> +	 * addition of total_vm will no longer fit into its limit)
>> +	 */
> I don't like this kind of holes. Considering tests which are usually done
> by developpers, the problem seems not to be mentioned as "rare"..
> It seems we can easily cause Warning. right ?
> 
> Even if you don't want to handle this case now, please mention as "TBD" 
> rather than as "NOTE".
> 

Honestly to fix this problem completely, we need transactional management in
cgroups. Both can_attach() and attach() are called with cgroup_mutex held, but
total_vm is changed with mmap_sem held.

What we can do is

1. Implement a routine attach_failed() in cgroups, that is called for each task
   for which can_attach() succeeded, if any of the can_attach() routine returns
   an error
2. Do the migration in can_attach() and unroll in attach_failed()



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
