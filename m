Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A4ABD6B011B
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 05:41:17 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n26AfAwJ004403
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 16:11:10 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n26AfHQP2703372
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 16:11:17 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n26Af8Bp028078
	for <linux-mm@kvack.org>; Fri, 6 Mar 2009 21:41:09 +1100
Date: Fri, 6 Mar 2009 16:11:06 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v4)
Message-ID: <20090306104106.GE5482@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090306092323.21063.93169.sendpatchset@localhost.localdomain> <20090306092353.21063.11068.sendpatchset@localhost.localdomain> <20090306185124.51a52519.kamezawa.hiroyu@jp.fujitsu.com> <20090306100155.GC5482@balbir.in.ibm.com> <20090306191436.ceeb6e42.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090306191436.ceeb6e42.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Bharata B Rao <bharata@in.ibm.com>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-06 19:14:36]:

> On Fri, 6 Mar 2009 15:31:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> 
> > > > +		if (wait)
> > > > +			wait_for_completion(&mem->wait_on_soft_reclaim);
> > > >  	}
> > > What ???? Why we have to wait here...holding mmap->sem...This is too bad.
> > >
> > 
> > Since mmap_sem is no longer used for pthread_mutex*, I was not sure.
> > That is why I added the comment asking for more review and see what
> > people think about it. We get here only when
> > 
> > 1. The memcg is over its soft limit
> > 2. Tasks/threads belonging to memcg are faulting in more pages
> > 
> > The idea is to throttle them. If we did reclaim inline, like we do for
> > hard limits, we can still end up holding mmap_sem for a long time.
> > 
> This "throttle" is hard to measuer the effect and IIUC, not implemneted in
> vmscan.c ...for global try_to_free_pages() yet.
> Under memory shortage. before reaching here, the thread already called
> try_to_free_pages() or check some memory shorage conditions because
> it called alloc_pages(). So, waiting here is redundant and gives it
> too much penaly.

The reason for adding it consider the the following scenario

1. Create cgroup "a", give it a soft limit of 0
2. Create cgroup "b", give it a soft limit of 3G.

With both "a' and "b" running, reclaiming from "a" makes no sense, it
goes and does a bulk allocation and increases it usage again. It does
not make sense to reclaim from "b" until it crosses 3G.

Throttling is not implemented in the main VM, but we have seen several
patches for it. This is a special case for soft limits.

> 
> 
> > > > +	/*
> > > > +	 * This loop can run a while, specially if mem_cgroup's continuously
> > > > +	 * keep exceeding their soft limit and putting the system under
> > > > +	 * pressure
> > > > +	 */
> > > > +	do {
> > > > +		mem = mem_cgroup_get_largest_soft_limit_exceeding_node();
> > > > +		if (!mem)
> > > > +			break;
> > > > +		usage = mem_cgroup_get_node_zone_usage(mem, zone, nid);
> > > > +		if (!usage)
> > > > +			goto skip_reclaim;
> > > 
> > > Why this works well ? if "mem" is the laragest, it will be inserted again
> > > as the largest. Do I miss any ?
> > >
> > 
> > No that is correct, but when reclaim is initiated from a different
> > zone/node combination, we still want mem to show up. 
> ....
> your logic is
> ==
>    nr_reclaimd = 0;
>    do {
>       mem = select victim.
>       remvoe victim from the RBtree (the largest usage one is selected)
>       if (victim is not good)
>           goto  skip this.
>       reclaimed += shirnk_zone.
>       
> skip_this:
>       if (mem is still exceeds soft limit)
>            insert RB tree again.
>    } while(!nr_reclaimed)
> ==
> When this exits loop ?
>

This is spill over from the main code without zones and nodes. Since
there, there was no concept of 0 usage and having a mem_cgroup on the
tree with highest usage. In practice, if we hit soft limit reclaim,
for each zone, kswapd will be called, at-least for one of the
node/zones that the mem we dequeud from has memory usage in. At that
point, the necessary changes to the RB-Tree will happen. However, you
have found a potential problem and I'll fix it in the next iteration.
 
> Thanks,
> -Kame
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
