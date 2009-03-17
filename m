Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 99B086B003D
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 00:40:33 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2H4ePGF029085
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:10:25 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2H4eXbY3432554
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 10:10:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2H4ePsS018140
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 15:40:25 +1100
Date: Tue, 17 Mar 2009 10:10:16 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090317044016.GG16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com> <20090316083512.GV16897@balbir.in.ibm.com> <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com> <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com> <20090316091024.GX16897@balbir.in.ibm.com> <2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com> <20090316113853.GA16897@balbir.in.ibm.com> <969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com> <20090316121915.GB16897@balbir.in.ibm.com> <20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090317124740.d8356d01.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-17 12:47:40]:

> On Mon, 16 Mar 2009 17:49:15 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 20:58:30]:
> 
> > A run away application can do that. Like I mentioned with the tests I
> > did for your patches. Soft limits were at 1G/2G and the applications
> > (two) tried to touch all the memory in the system. The point is that
> > shrink_slab() will be called if the normal system experiences
> > watermark issues, soft limits will tackle/control cgroups running out
> > of their soft limits and causing memory contention to take place.
> > 
> Ok, then, how about this ?
> 
>  Because our target is "softlimit" and not "memory shortage"
>  - don't call soft limit from alloc_pages().
>  - don't call soft limit from kswapd and others.
> 
> Instead of this, add sysctl like this.
> 
>   - vm.softlimit_ratio
> 
> If vm.softlimit_ratio = 99%, 
>   when sum of all usage of memcg is over 99% of system memory,
>   softlimit runs and reclaim memory until the whole usage will be below 99%.
>    (or some other trigger can be considered.)
> 
> Then,
>  - We don't have to take care of misc. complicated aspects of memory reclaiming
>    We reclaim memory based on our own logic, then, no influence to global LRU.
> 
> I think this approach will hide the all corner case and make merging softlimit 
> to mainline much easier. If you use this approach, RB-tree is the best one
> to go with (and we don't have to care zone's status.)

I like the idea in general, but I have concerns about

1. Tracking all cgroup memory, it can quickly get expensive (tracking
to check for vm.soft_limit_ratio and for usage)
2. Finding a good default for the sysctl (might not be so hard)

Even today our influence on global LRU is very limited, only when we
come under reclaim, we do an additional step of seeing if we can get
memory from soft limit groups first.

(1) is a real concern.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
