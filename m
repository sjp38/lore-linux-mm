Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m1R84q1Q003033
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 13:34:52 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1R84qsW868362
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 13:34:52 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m1R84p56018954
	for <linux-mm@kvack.org>; Wed, 27 Feb 2008 08:04:52 GMT
Message-ID: <47C51856.7060408@linux.vnet.ibm.com>
Date: Wed, 27 Feb 2008 13:29:18 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] page reclaim throttle take2
References: <47C4EF2D.90508@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262115270.1799@chino.kir.corp.google.com> <20080227143301.4252.KOSAKI.MOTOHIRO@jp.fujitsu.com> <alpine.DEB.1.00.0802262145410.31356@chino.kir.corp.google.com> <47C4F9C0.5010607@linux.vnet.ibm.com> <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.1.00.0802262201390.1613@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Wed, 27 Feb 2008, Balbir Singh wrote:
> 
>> Since we're talking of parallel reclaims, I think it's a function of CPUs and
>> Nodes. I'd rather keep it as a sysctl with a good default value based on the
>> topology. If we end up getting it wrong, the system administrator has a choice.
>> That is better than expecting him/her to recompile the kernel and boot that. A
>> sysctl does not create problems either w.r.t changing the number of threads, no
>> hard to solve race-conditions - it is fairly straight forward
>>
> 
> We lack node hotplug, so the dependence on the number of system nodes in 
> the equation is static and can easily be defined at compile-time.
> 

Let's forget node hotplug for the moment, but what if someone

1. Changes the machine configuration and adds more nodes, do we expect the
kernel to be recompiled? Or is it easier to update /etc/sysctl.conf?
2. Uses fake NUMA nodes and increases/decreases the number of nodes across
reboots. Should the kernel be recompiled?

> I agree that the maximum number of parallel reclaim threads should be a 
> function of cpus, so you can easily make it that by adding callback 
> functions for cpu hotplug events.
> 
> Perhaps a better alternative than creating a set of heuristics and setting 
> a user-defined maximum on the number of concurrent reclaim threads is to 
> configure the number of threads to be used for each online cpu called 
> CONFIG_NUM_RECLAIM_THREADS_PER_CPU.  This solves the lock contention 
> problem if configured properly that was mentioned earlier.
> 

I am afraid it doesn't. Consider as you scale number of CPU's with the same
amount of memory, we'll end up making the reclaim problem worse.

> Adding yet another sysctl for this functionality seems unnecessary, unless 
> it is attempting to address other VM problems where page reclaim needs to 
> be throttled when it is being stressed.  Those issues need to be addressed 
> directly, in my opinion, instead of attempting to workaround it by 
> limiting the number of concurrent reclaim threads.

We are providing a solution with a good default value, allowing the
administrator to change them when our defaults don't work well.

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
