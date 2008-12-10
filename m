Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [202.81.18.234])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mBA2ogKK011994
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:50:42 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mBA2o6b41335432
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:50:07 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mBA2nYFc020421
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 13:49:35 +1100
Date: Wed, 10 Dec 2008 08:19:29 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/6] Flat hierarchical reclaim by ID
Message-ID: <20081210024929.GG7593@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com> <20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com> <20081209122731.GB4174@balbir.in.ibm.com> <3526.10.75.179.61.1228832912.squirrel@webmail-b.css.fujitsu.com> <20081209154612.GB7694@balbir.in.ibm.com> <36125.10.75.179.61.1228840454.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <36125.10.75.179.61.1228840454.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-10 01:34:14]:

> Balbir Singh said:
> 
> >>     I think your soft-limit idea can be easily merged onto this patch
> >> set.
> >>
> >
> > Yes, potentially. With soft limit, the general expectation is this
> >
> > Let us say you have group A and B
> >
> >         groupA, soft limit = 1G
> >         groupB, soft limit = 2G
> >
> > Now assume the system has 4G. When groupB is not using its memory,
> > group A can grab all 4G, but when groupB kicks in and tries to use 2G
> > or more, then the expectation is that
> >
> > group A will get 1/3 * 4 = 4/3G
> > group B will get 2/3 * 4 = 8/3G
> >
> > Similar to CPU shares currently.
> >
> I like that idea because it's easy to understand.
>

Excellent, I'll start looking at how to implement it
 
> >> > Does this order reflect their position in the hierarchy?
> >>   No. just scan IDs from last scannned one in RR.
> >>   BTW, can you show what an algorithm works well in following case ?
> >>   ex)
> >>     groupA/   limit=1G     usage=300M
> >>           01/ limit=600M   usage=600M
> >>           02/ limit=700M   usage=70M
> >>           03/ limit=100M   usage=30M
> >>    Which one should be shrinked at first and why ?
> >>    1) when group_A hit limits.
> >
> > With tree reclaim, reclaim will first reclaim from A and stop if
> > successful, otherwise it will go to 01, 02 and 03 and then go back to
> > A.
> >
> Sorry for my poor example
> 
> >>    2) when group_A/01 hit limits.
> >
> > This will reclaim only from 01, since A is under its limit
> >
> I should ask
>       2') when a task in group_A/01 hit limit in group_A
> 
> ex)
>     group_A/   limtit=1G, usage~0
>            /01 limit= unlimited  usage=800M
>            /02 limit= unlimited  usage=200M
>   (what limit is allowed to children is another problem to be fixed...)
>   when a task in 01 hits limit of group_A
>   when a task in 02 hits limit of group_A
>   where we should start from ? (is unknown)
>   Currenty , this patch uses RR (in A->01->02->A->...).
>   and soft-limit or some good algorithm will give us better view.
> 
> >>    3) when group_A/02 hit limits.
> >
> > This will reclaim only from 02 since A is under its limit
> >
> > Does RR do the same right now?
> >
> I think so.
> 
> Assume
>    group_A/
>           /01
>           /02
> RR does
>    1) when a task under A/01/02 hit limits at A, shrink A, 01, 02,
>    2) when a task under 01 hit limits at 01, shrink only 01.
>    3) when a task under 02 hit limits at 02, shrink only 02.
> 
> When 1), start point of shrinking is saved as last_scanned_child.
> 
> 
> >>    I can't now.
> >>
> >>    This patch itself uses round-robin and have no special order.
> >>    I think implenting good algorithm under this needs some amount of
> >> time.
> >>
> >
> > I agree that fine tuning it will require time, but what we need is
> > something usable that will not have hard to debug or understand corner
> > cases.
> 
> yes, we have now. My point  is "cgroup_lock()" caused many problems and
> will cause new ones in future, I convince.
> 
> And please see 5/6 and 6/6 we need hierarchy consideration in other
> places. I think there are more codes which should take care of hierarchy.
> 

Yes, I do have the patches to remove cgroup_lock(), let me post them
indepedent of Daisuke's patches

> 
> > > Shouldn't id's belong to cgroups instead of just memory controller?
> >> If Paul rejects, I'll move this to memcg. But bio-cgroup people also use
> >> ID and, in this summer, I posted swap-cgroup-ID patch and asked to
> >> implement IDs under cgroup rather than subsys. (asked by Paul or you.)
> >>
> >
> > We should talk to Paul and convince him.
> >
> yes.
>

Paul, would it be very hard to add id's to control groups?
 
> >> >From implementation, hierarchy code management at el. should go into
> >> cgroup.c and it gives us clear view rather than implemented under memcg.
> >>
> >
> > cgroup has hierarchy management already, in the form of children and
> > sibling. Walking those structures is up to us, that is all we do
> > currently :)
> >
> yes, but need cgroup_lock(). and you have to keep refcnt to pointer
> just for rememebring it.
> 
> This patch doesn't change anything other than removing cgroup_lock() and
> removing refcnt to remember start point.
>

OK, I'll play with it 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
