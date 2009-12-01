Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 08892600786
	for <linux-mm@kvack.org>; Tue,  1 Dec 2009 05:39:51 -0500 (EST)
Message-ID: <4B14F263.50109@parallels.com>
Date: Tue, 01 Dec 2009 13:39:31 +0300
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: Re: memcg: slab control
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com> <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com> <20091126085031.GG2970@balbir.in.ibm.com> <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com> <4B0E461C.50606@parallels.com> <alpine.DEB.2.00.0911301447400.7131@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0911301447400.7131@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, balbir@linux.vnet.ibm.com, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Thu, 26 Nov 2009, Pavel Emelyanov wrote:
> 
>> I'm ready to resurrect the patches and port them for slab.
>> But before doing it we should answer one question.
>>
> 
> Do you have a pointer to your latest implementation that you proposed for 
> slab?

I believe this is the one:
https://lists.linux-foundation.org/pipermail/containers/2007-September/007481.html

>> Consider we have two kmalloc-s in a kernel code - one is
>> user-space triggerable and the other one is not. From my
>> POV we should account for the former one, but should not
>> for the latter.
>>
>> If so - how should we patch the kernel to achieve that goal?
>>
> 
> I think all slab allocations should be accounted for based on current's 
> memcg other than those done in hardirq context, annotating slab 
> allocations doesn't seem scalable.  Whether the accounting is done on a 
> task level or cgroup level isn't really a problem for us since we don't 
> move tasks amongst cgroups.  I imagine there've been previous restrictions 
> on that put into place with the memcg so this doesn't seem like a 
> slabcg-specific requirement anyway.
> 
> The problem on the freeing side is mapping the object back to the cgroup 
> that allocated it.  We'd also need to map the object to the context in 
> which it was allocated to determine whether we should decrement the 
> counter or not.  How do you propose doing that without a considerable 
> overhead in memory consumption, fastpath branch, and cache cold slabcg 
> lookups?

That's the biggest problem. Generally speaking - no other way rather than
store additional pointer. In some situations you can rely on the cgroup of
a task in which context an object is being freed, but in that case once you
move a task to another cgroup your accounting is screwed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
