Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 97F9A6B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 07:39:09 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp05.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2GBd2oi009126
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:09:02 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2GBdAB52867248
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:09:10 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2GBd1xZ005172
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:09:01 +0530
Date: Mon, 16 Mar 2009 17:08:53 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090316113853.GA16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain> <20090314173111.16591.68465.sendpatchset@localhost.localdomain> <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com> <20090316083512.GV16897@balbir.in.ibm.com> <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com> <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com> <20090316091024.GX16897@balbir.in.ibm.com> <2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 20:10:41]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16
> > 18:03:08]:
> >
> >> On Mon, 16 Mar 2009 17:49:43 +0900
> >> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >>
> >> > On Mon, 16 Mar 2009 14:05:12 +0530
> >> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> >>
> >> > For example, shrink_slab() is not called. and this must be called.
> >> >
> >> > For exmaple, we may have to add
> >> >  sc->call_shrink_slab
> >> > flag and set it "true" at soft limit reclaim.
> >> >
> >> At least, this check will be necessary in v7, I think.
> >> shrink_slab() should be called.
> >
> > Why do you think so? So here is the design
> >
> > 1. If a cgroup was using over its soft limit, we believe that this
> >    cgroup created overall memory contention and caused the page
> >    reclaimer to get activated.
> This assumption is wrong, see below.
> 
> >    If we can solve the situation by
> >    reclaiming from this cgroup, why do we need to invoke shrink_slab?
> >
> No,
> IIUC, in big server, inode, dentry cache etc....can occupy Gigabytes
> of memory even if 99% of them are not used.
> 
> By shrink_slab(), we can reclaim unused but cached slabs and make
> the kernel more healthy.
> 

But that is not the job of the soft limit reclaimer.. Yes if no groups
are over their soft limit, the regular action will take place.

> 
> > If the concern is that we are not following the traditional reclaim,
> > soft limit reclaim can be followed by unconditional reclaim, but I
> > believe this is not necessary. Remember, we wake up kswapd that will
> > call shrink_slab if needed.
> kswapd doesn't call shrink_slab() when zone->free is enough.
> (when direct recail did good jobs.)
> 

If zone->free is high why do we need shrink_slab()? The other way
of asking it is, why does the soft limit reclaimer need to call
shrink_slab(), when its job is to reclaim memory from cgroups above
their soft limits.

> Anyway, we'll have to add softlimit hook to kswapd.
> I think you read Kosaki's e-mail to you.
> ==
> in global reclaim view, foreground reclaim and background reclaim's
>   reclaim rate is about 1:9 typically.
> ==

I think not. Please don't interpret soft limits as water marks, I
think that is where the basic disagreement lies. Keeping zones under
their watermarks is different from soft limits; where a cgroup gets
pushed it is causing the memory allocator to go into reclaim.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
