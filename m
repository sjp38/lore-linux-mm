Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0879F5F0001
	for <linux-mm@kvack.org>; Wed,  8 Apr 2009 01:29:13 -0400 (EDT)
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.13.1/8.13.1) with ESMTP id n385ARGe026732
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 01:10:27 -0400
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n385TZ8i450890
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 15:29:35 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n385TYL4027314
	for <linux-mm@kvack.org>; Wed, 8 Apr 2009 15:29:35 +1000
Date: Wed, 8 Apr 2009 10:59:04 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090408052904.GY7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090407063722.GQ7082@balbir.in.ibm.com> <20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com> <20090407071825.GR7082@balbir.in.ibm.com> <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com> <20090407080355.GS7082@balbir.in.ibm.com> <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090407172419.a5f318b9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 17:24:19]:

> On Tue, 7 Apr 2009 13:33:55 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 16:33:31]:
> > 
> > > On Tue, 7 Apr 2009 12:48:25 +0530
> > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > 
> > > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 16:00:14]:
> > > > 
> > > > > On Tue, 7 Apr 2009 12:07:22 +0530
> > > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > > 
> > > > > > Hi, All,
> > > > > > 
> > > > > > This is a request for input for the design of shared page accounting for
> > > > > > the memory resource controller, here is what I have so far
> > > > > > 
> > > > > 
> > > > > In my first impression, I think simple counting is impossible.
> > > > > IOW, "usage count" and "shared or not" is very different problem.
> > > > > 
> > > > > Assume a page and its page_cgroup.
> > > > > 
> > > > > Case 1)
> > > > >   1. a page is mapped by process-X under group-A
> > > > >   2. its mapped by process-Y in group-B (now, shared and charged under group-A)
> > > > >   3. move process-X to group-B
> > > > >   4. now the page is not shared.
> > > > > 
> > > > 
> > > > By shared I don't mean only between cgroups, it could be a page shared
> > > > in the same cgroup
> > > > 
> > > Hmm, is it good information ?
> > > 
> > > Such kind of information can be calucated by
> > > ==
> > >    rss = 0;
> > >    for_each_process_under_cgroup() {
> > >        mm = tsk->mm
> > >        rss += mm->anon_rss;
> > >    }
> > >    some_of_all_rss = rss;
> > >    
> > >    shared_ratio = mem_cgrou->rss *100 / some_of_all_rss.
> > > ==
> > >    if 100%, all anon memory are not shared.
> > >
> > 
> > Why only anon? 
> 
> no serious intention.
> Just because you wrote "expect the user to account all cached pages as shared" ;)
>

OK, I noticed another thing, our RSS accounting is not RSS per-se, it
includes only anon RSS, file backed pages are accounted as cached.
I'll send out a patch to see if we can include anon RSS as well.
 
> > This seems like a good idea, except when we have a page
> > charged to a cgroup and the task that charged it has migrated, in that
> > case sum_of_all_rss will be 0.
> > 
> Yes. But we don't move pages at task-move under expectation that moved
> process will call fork() soon.
> "task move" has its own problem, so ignoring it for now is a choice.
> That kind of troubls can be treated when we fixes "task move".
> (or fix "task move" first.)
> 
> Thanks,
> -Kame
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
