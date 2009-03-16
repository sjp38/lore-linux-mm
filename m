Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 062B66B003D
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 08:19:32 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp02.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2GCJNGl019168
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:49:23 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2GCG5rZ3461278
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:46:05 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2GCJNDb023271
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 17:49:23 +0530
Date: Mon, 16 Mar 2009 17:49:15 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v6)
Message-ID: <20090316121915.GB16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090314173043.16591.18336.sendpatchset@localhost.localdomain> <20090314173111.16591.68465.sendpatchset@localhost.localdomain> <20090316095258.94ae559d.kamezawa.hiroyu@jp.fujitsu.com> <20090316083512.GV16897@balbir.in.ibm.com> <20090316174943.53ec8196.kamezawa.hiroyu@jp.fujitsu.com> <20090316180308.6be6b8a2.kamezawa.hiroyu@jp.fujitsu.com> <20090316091024.GX16897@balbir.in.ibm.com> <2217159d612e4e4d3fcbd50354e53f5b.squirrel@webmail-b.css.fujitsu.com> <20090316113853.GA16897@balbir.in.ibm.com> <969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <969730ee419be9fbe4aca3ec3249650e.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16 20:58:30]:

> Balbir Singh wrote:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-16
> > 20:10:41]:
> >> >> At least, this check will be necessary in v7, I think.
> >> >> shrink_slab() should be called.
> >> >
> >> > Why do you think so? So here is the design
> >> >
> >> > 1. If a cgroup was using over its soft limit, we believe that this
> >> >    cgroup created overall memory contention and caused the page
> >> >    reclaimer to get activated.
> >> This assumption is wrong, see below.
> >>
> >> >    If we can solve the situation by
> >> >    reclaiming from this cgroup, why do we need to invoke shrink_slab?
> >> >
> >> No,
> >> IIUC, in big server, inode, dentry cache etc....can occupy Gigabytes
> >> of memory even if 99% of them are not used.
> >>
> >> By shrink_slab(), we can reclaim unused but cached slabs and make
> >> the kernel more healthy.
> >>
> >
> > But that is not the job of the soft limit reclaimer.. Yes if no groups
> > are over their soft limit, the regular action will take place.
> >
> Oh, yes, it's not job of memcg but it's job of memory management.
> 
> 
> >>
> >> > If the concern is that we are not following the traditional reclaim,
> >> > soft limit reclaim can be followed by unconditional reclaim, but I
> >> > believe this is not necessary. Remember, we wake up kswapd that will
> >> > call shrink_slab if needed.
> >> kswapd doesn't call shrink_slab() when zone->free is enough.
> >> (when direct recail did good jobs.)
> >>
> >
> > If zone->free is high why do we need shrink_slab()? The other way
> > of asking it is, why does the soft limit reclaimer need to call
> > shrink_slab(), when its job is to reclaim memory from cgroups above
> > their soft limits.
> >
> Why do you consider that softlimit is called more than necessary
> if shrink_slab() is never called ?

A run away application can do that. Like I mentioned with the tests I
did for your patches. Soft limits were at 1G/2G and the applications
(two) tried to touch all the memory in the system. The point is that
shrink_slab() will be called if the normal system experiences
watermark issues, soft limits will tackle/control cgroups running out
of their soft limits and causing memory contention to take place.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
