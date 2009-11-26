Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF0446B0044
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 03:50:40 -0500 (EST)
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp01.in.ibm.com (8.14.3/8.13.1) with ESMTP id nAQ8oYgd017726
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 14:20:34 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id nAQ8oXZW2695286
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 14:20:34 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id nAQ8oWv2026930
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 19:50:33 +1100
Date: Thu, 26 Nov 2009 14:20:31 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: memcg: slab control
Message-ID: <20091126085031.GG2970@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
 <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@openvz.org>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-11-26 10:14:14]:

> On Wed, 25 Nov 2009 15:08:00 -0800 (PST)
> David Rientjes <rientjes@google.com> wrote:
> 
> > Hi,
> > 
> > I wanted to see what the current ideas are concerning kernel memory 
> > accounting as it relates to the memory controller.  Eventually we'll want 
> > the ability to restrict cgroups to a hard slab limit.  That'll require 
> > accounting to map slab allocations back to user tasks so that we can 
> > enforce a policy based on the cgroup's aggregated slab usage similiar to 
> > how the memory controller currently does for user memory.
> > 
> > Is this currently being thought about within the memcg community? 
> 
> Not yet. But I always recommend people to implement another memcg (slabcg) for
> kernel memory. Because
> 
>   - It must have much lower cost than memcg, good perfomance and scalability.
>     system-wide shared counter is nonsense.
>

We've solved those issues mostly! Anyway, I agree that we need another
slabcg, Pavel did some work in that area and posted patches, but they
were mostly based and limited to SLUB (IIRC).
 
>   - slab is not base on LRU. So, another used-memory maintainance scheme should
>     be used.
> 
>   - You can reuse page_cgroup even if slabcg is independent from memcg.
> 
> 
> But, considering user-side, all people will not welcome dividing memcg and slabcg.
> So, tieing it to current memcg is ok for me.
> like...
> ==
> 	struct mem_cgroup {
> 		....
> 		....
> 		struct slab_cgroup slabcg; (or struct slab_cgroup *slabcg)
> 	}
> ==
> 
> But we have to use another counter and another scheme, another implemenation
> than memcg, which has good scalability and more fuzzy/lazy controls.
> (For example, trigger slab-shrink when usage exceeds hiwatermark, not limit.)
> 

That depends on requirements, hiwatermark is more like a soft limit
than a hard limit and there might be need for hard limits.

> Scalable accounting is the first wall in front of us. Second one will be
> how-to-shrink. About information recording, we can reuse page_cgroup and
> we'll not have much difficulty.
> 
> I hope, at implementing slabcg, we'll not meet very complicated
> racy cases as what we met in memcg. 
>

I think it will be because there is no swapping involved, OOM and rare
race conditions. There is limited slab reclaim possible, but otherwise
I think it is easier to write a slab controller IMHO. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
