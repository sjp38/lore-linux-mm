Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7FFAD5F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:34:31 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n377Z1Pn022797
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 7 Apr 2009 16:35:02 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 94F0C45DD72
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:35:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6ADFF45DD74
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:35:01 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 58FF81DB8016
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:35:01 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F20811DB8014
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 16:34:57 +0900 (JST)
Date: Tue, 7 Apr 2009 16:33:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-Id: <20090407163331.8e577170.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090407071825.GR7082@balbir.in.ibm.com>
References: <20090407063722.GQ7082@balbir.in.ibm.com>
	<20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com>
	<20090407071825.GR7082@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 7 Apr 2009 12:48:25 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 16:00:14]:
> 
> > On Tue, 7 Apr 2009 12:07:22 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Hi, All,
> > > 
> > > This is a request for input for the design of shared page accounting for
> > > the memory resource controller, here is what I have so far
> > > 
> > 
> > In my first impression, I think simple counting is impossible.
> > IOW, "usage count" and "shared or not" is very different problem.
> > 
> > Assume a page and its page_cgroup.
> > 
> > Case 1)
> >   1. a page is mapped by process-X under group-A
> >   2. its mapped by process-Y in group-B (now, shared and charged under group-A)
> >   3. move process-X to group-B
> >   4. now the page is not shared.
> > 
> 
> By shared I don't mean only between cgroups, it could be a page shared
> in the same cgroup
> 
Hmm, is it good information ?

Such kind of information can be calucated by
==
   rss = 0;
   for_each_process_under_cgroup() {
       mm = tsk->mm
       rss += mm->anon_rss;
   }
   some_of_all_rss = rss;
   
   shared_ratio = mem_cgrou->rss *100 / some_of_all_rss.
==
   if 100%, all anon memory are not shared.
 

> > Case 2)
> >   swap is an object which can be shared.
> > 
> 
> Good point, I expect the user to account all cached pages as shared -
> no
Maybe yes if we explain it's so ;)

?
> 
> > Case 3)
> >   1. a page known as "A" is mapped by process-X under group-A.
> >   2. its mapped by process-Y under group-B(now, shared and charged under group-A)
> >   3. Do copy-on-write by process-X.
> >      Now, "A" is mapped only by B but accoutned under group-A.
> >      This case is ignored intentionally, now.
> 
> Yes, that is the original design
> 
> >      Do you want to call try_charge() both against group-A and group-B
> >      under process-X's page fault ?
> > 
> 
> No we don't, but copy-on-write is caught at page_rmap_dup() - no?
> 
Hmm, if we don't consider group-B, maybe we can.
But I wonder counting is overkill..


> > There will be many many corner case.
> > 
> > 
> > > Motivation for shared page accounting
> > > -------------------------------------
> > > 1. Memory cgroup administrators will benefit from the knowledge of how
> > >    much of the data is shared, it helps size the groups correctly.
> > > 2. We currently report only the pages brought in by the cgroup, knowledge
> > >    of shared data will give a complete picture of the actual usage.
> > > 
> > 
> > Motivation sounds good. But counting this in generic rmap will have tons of
> > troubles and slow-down.
> > 
> > I bet we should prepare a file as
> >   /proc/<pid>/cgroup_maps
> > 
> > And show RSS/RSS-owned-by-us per process. Maybe this feature will be able to be
> > implemented in 3 days.
> 
> Yes, we can probably do that, but if we have too many processes in one
> cgroup, we'll need to walk across all of them in user space. One other
> alternative I did not mention is to walk the LRU like we walk page
> tables and look at page_mapcount of every page, but that will be
> very slow.

Can't we make use of information in mm_counters ? (As I shown in above)
(see set/get/add/inc/dec_mm_counters())

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
