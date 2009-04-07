Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 327035F0001
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:18:49 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n377IdWR018976
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 17:18:39 +1000
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n377IuHi1151098
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 17:18:56 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n377Its3023705
	for <linux-mm@kvack.org>; Tue, 7 Apr 2009 17:18:56 +1000
Date: Tue, 7 Apr 2009 12:48:25 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFI] Shared accounting for memory resource controller
Message-ID: <20090407071825.GR7082@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090407063722.GQ7082@balbir.in.ibm.com> <20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090407160014.8c545c3c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, Rik van Riel <riel@surriel.com>, Bharata B Rao <bharata.rao@in.ibm.com>, Dhaval Giani <dhaval@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-04-07 16:00:14]:

> On Tue, 7 Apr 2009 12:07:22 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Hi, All,
> > 
> > This is a request for input for the design of shared page accounting for
> > the memory resource controller, here is what I have so far
> > 
> 
> In my first impression, I think simple counting is impossible.
> IOW, "usage count" and "shared or not" is very different problem.
> 
> Assume a page and its page_cgroup.
> 
> Case 1)
>   1. a page is mapped by process-X under group-A
>   2. its mapped by process-Y in group-B (now, shared and charged under group-A)
>   3. move process-X to group-B
>   4. now the page is not shared.
> 

By shared I don't mean only between cgroups, it could be a page shared
in the same cgroup

> Case 2)
>   swap is an object which can be shared.
> 

Good point, I expect the user to account all cached pages as shared -
no?

> Case 3)
>   1. a page known as "A" is mapped by process-X under group-A.
>   2. its mapped by process-Y under group-B(now, shared and charged under group-A)
>   3. Do copy-on-write by process-X.
>      Now, "A" is mapped only by B but accoutned under group-A.
>      This case is ignored intentionally, now.

Yes, that is the original design

>      Do you want to call try_charge() both against group-A and group-B
>      under process-X's page fault ?
> 

No we don't, but copy-on-write is caught at page_rmap_dup() - no?

> There will be many many corner case.
> 
> 
> > Motivation for shared page accounting
> > -------------------------------------
> > 1. Memory cgroup administrators will benefit from the knowledge of how
> >    much of the data is shared, it helps size the groups correctly.
> > 2. We currently report only the pages brought in by the cgroup, knowledge
> >    of shared data will give a complete picture of the actual usage.
> > 
> 
> Motivation sounds good. But counting this in generic rmap will have tons of
> troubles and slow-down.
> 
> I bet we should prepare a file as
>   /proc/<pid>/cgroup_maps
> 
> And show RSS/RSS-owned-by-us per process. Maybe this feature will be able to be
> implemented in 3 days.

Yes, we can probably do that, but if we have too many processes in one
cgroup, we'll need to walk across all of them in user space. One other
alternative I did not mention is to walk the LRU like we walk page
tables and look at page_mapcount of every page, but that will be
very slow.

> 
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
