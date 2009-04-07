Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 3B7525F0003
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 04:04:54 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n3784hDA029843
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 13:34:43 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3780bps4124696
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 13:30:37 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n3784QXA008685
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 18:04:27 +1000
Date: Tue, 7 Apr 2009 13:33:55 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090407080355.GS7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090407063722.GQ7082@balbir.in.ibm.com> <20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com> <20090407071825.GR7082@balbir.in.ibm.com> <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 16:33:31]:

> On Tue, 7 Apr 2009 12:48:25 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 16:00:14]:
> > 
> > > On Tue, 7 Apr 2009 12:07:22 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > Hi, All,
> > > > 
> > > > This is a request for input for the design of shared page accounting for
> > > > the memory resource controller, here is what I have so far
> > > > 
> > > 
> > > In my first impression, I think simple counting is impossible.
> > > IOW, "usage count" and "shared or not" is very different problem.
> > > 
> > > Assume a page and its page_cgroup.
> > > 
> > > Case 1)
> > >   1. a page is mapped by process-X under group-A
> > >   2. its mapped by process-Y in group-B (now, shared and charged under group-A)
> > >   3. move process-X to group-B
> > >   4. now the page is not shared.
> > > 
> > 
> > By shared I don't mean only between cgroups, it could be a page shared
> > in the same cgroup
> > 
> Hmm, is it good information ?
> 
> Such kind of information can be calucated by
> ==
>    rss = 0;
>    for_each_process_under_cgroup() {
>        mm = tsk->mm
>        rss += mm->anon_rss;
>    }
>    some_of_all_rss = rss;
>    
>    shared_ratio = mem_cgrou->rss *100 / some_of_all_rss.
> ==
>    if 100%, all anon memory are not shared.
>

Why only anon? This seems like a good idea, except when we have a page
charged to a cgroup and the task that charged it has migrated, in that
case sum_of_all_rss will be 0.
 
> 
> > > Case 2)
> > >   swap is an object which can be shared.
> > > 
> > 
> > Good point, I expect the user to account all cached pages as shared -
> > no
> Maybe yes if we explain it's so ;)
> 
> ?
> > 
> > > Case 3)
> > >   1. a page known as "A" is mapped by process-X under group-A.
> > >   2. its mapped by process-Y under group-B(now, shared and charged under group-A)
> > >   3. Do copy-on-write by process-X.
> > >      Now, "A" is mapped only by B but accoutned under group-A.
> > >      This case is ignored intentionally, now.
> > 
> > Yes, that is the original design
> > 
> > >      Do you want to call try_charge() both against group-A and group-B
> > >      under process-X's page fault ?
> > > 
> > 
> > No we don't, but copy-on-write is caught at page_rmap_dup() - no?
> > 
> Hmm, if we don't consider group-B, maybe we can.
> But I wonder counting is overkill..
> 
> 
> > > There will be many many corner case.
> > > 
> > > 
> > > > Motivation for shared page accounting
> > > > -------------------------------------
> > > > 1. Memory cgroup administrators will benefit from the knowledge of how
> > > >    much of the data is shared, it helps size the groups correctly.
> > > > 2. We currently report only the pages brought in by the cgroup, knowledge
> > > >    of shared data will give a complete picture of the actual usage.
> > > > 
> > > 
> > > Motivation sounds good. But counting this in generic rmap will have tons of
> > > troubles and slow-down.
> > > 
> > > I bet we should prepare a file as
> > >   /proc/<pid>/cgroup_maps
> > > 
> > > And show RSS/RSS-owned-by-us per process. Maybe this feature will be able to be
> > > implemented in 3 days.
> > 
> > Yes, we can probably do that, but if we have too many processes in one
> > cgroup, we'll need to walk across all of them in user space. One other
> > alternative I did not mention is to walk the LRU like we walk page
> > tables and look at page_mapcount of every page, but that will be
> > very slow.
> 
> Can't we make use of information in mm_counters ? (As I shown in above)
> (see set/get/add/inc/dec_mm_counters())
>

I've seen them, might be a good way to get started, except some corner
cases mentioned above. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
