Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0C5A46B0062
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 03:58:58 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nAQ8wuC4021578
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 26 Nov 2009 17:58:56 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1262A45DE4D
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 17:58:56 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D3D9445DE70
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 17:58:55 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9CD7BE1800B
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 17:58:55 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4571DE18008
	for <linux-mm@kvack.org>; Thu, 26 Nov 2009 17:58:55 +0900 (JST)
Date: Thu, 26 Nov 2009 17:56:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: memcg: slab control
Message-Id: <20091126175606.f7df2f80.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091126085031.GG2970@balbir.in.ibm.com>
References: <alpine.DEB.2.00.0911251500150.20198@chino.kir.corp.google.com>
	<20091126101414.829936d8.kamezawa.hiroyu@jp.fujitsu.com>
	<20091126085031.GG2970@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@openvz.org>, Suleiman Souhlal <suleiman@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 26 Nov 2009 14:20:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-11-26 10:14:14]:
> 
> > On Wed, 25 Nov 2009 15:08:00 -0800 (PST)
> > David Rientjes <rientjes@google.com> wrote:
> > 
> > > Hi,
> > > 
> > > I wanted to see what the current ideas are concerning kernel memory 
> > > accounting as it relates to the memory controller.  Eventually we'll want 
> > > the ability to restrict cgroups to a hard slab limit.  That'll require 
> > > accounting to map slab allocations back to user tasks so that we can 
> > > enforce a policy based on the cgroup's aggregated slab usage similiar to 
> > > how the memory controller currently does for user memory.
> > > 
> > > Is this currently being thought about within the memcg community? 
> > 
> > Not yet. But I always recommend people to implement another memcg (slabcg) for
> > kernel memory. Because
> > 
> >   - It must have much lower cost than memcg, good perfomance and scalability.
> >     system-wide shared counter is nonsense.
> >
> 
> We've solved those issues mostly! 
yes. but our solution is for page faults.
resolution of slab allocation is much more fine grained and often.

> Anyway, I agree that we need another
> slabcg, Pavel did some work in that area and posted patches, but they
> were mostly based and limited to SLUB (IIRC).
>  
> >   - slab is not base on LRU. So, another used-memory maintainance scheme should
> >     be used.
> > 
> >   - You can reuse page_cgroup even if slabcg is independent from memcg.
> > 
> > 
> > But, considering user-side, all people will not welcome dividing memcg and slabcg.
> > So, tieing it to current memcg is ok for me.
> > like...
> > ==
> > 	struct mem_cgroup {
> > 		....
> > 		....
> > 		struct slab_cgroup slabcg; (or struct slab_cgroup *slabcg)
> > 	}
> > ==
> > 
> > But we have to use another counter and another scheme, another implemenation
> > than memcg, which has good scalability and more fuzzy/lazy controls.
> > (For example, trigger slab-shrink when usage exceeds hiwatermark, not limit.)
> > 
> 
> That depends on requirements, hiwatermark is more like a soft limit
> than a hard limit and there might be need for hard limits.
> 
My point is that most of the kernel codes cannot work well when kmalloc(small area)
returns NULL.



> > Scalable accounting is the first wall in front of us. Second one will be
> > how-to-shrink. About information recording, we can reuse page_cgroup and
> > we'll not have much difficulty.
> > 
> > I hope, at implementing slabcg, we'll not meet very complicated
> > racy cases as what we met in memcg. 
> >
> 
> I think it will be because there is no swapping involved, OOM and rare
> race conditions. There is limited slab reclaim possible, but otherwise
> I think it is easier to write a slab controller IMHO. 
> 
yes ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
