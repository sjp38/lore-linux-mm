Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k7HAfkm2031508
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 06:41:46 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k7HAfkwr093822
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 04:41:46 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k7HAfkKS020976
	for <linux-mm@kvack.org>; Thu, 17 Aug 2006 04:41:46 -0600
Message-ID: <44E447E7.8070502@in.ibm.com>
Date: Thu, 17 Aug 2006 16:11:43 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] "challenged" memory controller
References: <20060815192047.EE4A0960@localhost.localdomain> <20060815150721.21ff961e.pj@sgi.com>
In-Reply-To: <20060815150721.21ff961e.pj@sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: dave@sr71.net, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Paul Jackson wrote:
> Dave wrote:
>> I've been toying with a little memory controller for the past
>> few weeks, on and off.
> 
> I haven't actually thought about this much yet, but I suspect:
> 
>  1) This is missing some cpuset locking - look at the routine
>     kernel/cpuset.c:__cpuset_memory_pressure_bump() for the
>     locking required to reference current->cpuset, using task_lock().
>     Notice that the current->cpuset reference is not valid once
>     the task lock is dropped.
> 
>  2) This might not scale well, with a hot spot in the cpuset.  So
>     far, I avoid any reference to the cpuset structure on hot code
>     paths, especially any write references, but even read references,
>     due to the above need for the task lock.

Would it be possible to protect task->cpuset using rcu_read_lock() for read 
references as cpuset_update_task_memory_state() does (and use the generations 
trick to see if a task changed cpusets)? I guess the cost paid is an additional 
field in the page structure to add generations.

-- 

	Balbir Singh,
	Linux Technology Center,
	IBM Software Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
