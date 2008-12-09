Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by e23smtp03.au.ibm.com (8.13.1/8.13.1) with ESMTP id mB9FiqIW029669
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 02:44:52 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id mB9FkGSa285224
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 02:46:17 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id mB9FkFh7013483
	for <linux-mm@kvack.org>; Wed, 10 Dec 2008 02:46:16 +1100
Date: Tue, 9 Dec 2008 21:16:12 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/6] Flat hierarchical reclaim by ID
Message-ID: <20081209154612.GB7694@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20081209200213.0e2128c1.kamezawa.hiroyu@jp.fujitsu.com> <20081209200915.41917722.kamezawa.hiroyu@jp.fujitsu.com> <20081209122731.GB4174@balbir.in.ibm.com> <3526.10.75.179.61.1228832912.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <3526.10.75.179.61.1228832912.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-09 23:28:32]:

> Balbir Singh said:
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2008-12-09
> > 20:09:15]:
> >
> >>
> >> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >>
> >> Implement hierarchy reclaim by cgroup_id.
> >>
> >> What changes:
> >> 	- Page reclaim is not done by tree-walk algorithm
> >> 	- mem_cgroup->last_schan_child is changed to be ID, not pointer.
> >> 	- no cgroup_lock, done under RCU.
> >> 	- scanning order is just defined by ID's order.
> >> 	  (Scan by round-robin logic.)
> >>
> >> Changelog: v3 -> v4
> >> 	- adjusted to changes in base kernel.
> >> 	- is_acnestor() is moved to other patch.
> >>
> >> Changelog: v2 -> v3
> >> 	- fixed use_hierarchy==0 case
> >>
> >> Changelog: v1 -> v2
> >> 	- make use of css_tryget();
> >> 	- count # of loops rather than remembering position.
> >>
> >> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujisu.com>
> >
> > I have not yet run the patch, but the heuristics seem a lot like
> > magic. I am not against scanning by order, but is order the right way
> > to scan groups?
> My consideration is
>   - Both of current your implementation and this round robin is just
>     an example. I never think some kind of search algorighm detemined by
>     shape of tree is the best way.
>   - No one knows what order is the best, now. We have to find it.
>   - The best order will be determined by some kind of calculation rather
>     than shape of tree and must pass by tons of tests.

Yes, the shape of the tree just limits where to reclaim from

>     This needs much amount of time and patient work. VM management is not
>     so easy thing.
>     I think your soft-limit idea can be easily merged onto this patch set.
> 

Yes, potentially. With soft limit, the general expectation is this

Let us say you have group A and B

        groupA, soft limit = 1G
        groupB, soft limit = 2G

Now assume the system has 4G. When groupB is not using its memory,
group A can grab all 4G, but when groupB kicks in and tries to use 2G
or more, then the expectation is that

group A will get 1/3 * 4 = 4/3G
group B will get 2/3 * 4 = 8/3G

Similar to CPU shares currently.

> > Does this order reflect their position in the hierarchy?
>   No. just scan IDs from last scannned one in RR.
>   BTW, can you show what an algorithm works well in following case ?
>   ex)
>     groupA/   limit=1G     usage=300M
>           01/ limit=600M   usage=600M
>           02/ limit=700M   usage=70M
>           03/ limit=100M   usage=30M
>    Which one should be shrinked at first and why ?
>    1) when group_A hit limits.

With tree reclaim, reclaim will first reclaim from A and stop if
successful, otherwise it will go to 01, 02 and 03 and then go back to
A.

>    2) when group_A/01 hit limits.

This will reclaim only from 01, since A is under its limit

>    3) when group_A/02 hit limits.

This will reclaim only from 02 since A is under its limit

Does RR do the same right now?

>    I can't now.
> 
>    This patch itself uses round-robin and have no special order.
>    I think implenting good algorithm under this needs some amount of time.
> 

I agree that fine tuning it will require time, but what we need is
something usable that will not have hard to debug or understand corner cases.

> > Shouldn't id's belong to cgroups instead of just memory controller?
> If Paul rejects, I'll move this to memcg. But bio-cgroup people also use
> ID and, in this summer, I posted swap-cgroup-ID patch and asked to
> implement IDs under cgroup rather than subsys. (asked by Paul or you.)
> 

We should talk to Paul and convince him.

> >From implementation, hierarchy code management at el. should go into
> cgroup.c and it gives us clear view rather than implemented under memcg.
> 

cgroup has hierarchy management already, in the form of children and
sibling. Walking those structures is up to us, that is all we do
currently :)

> -Kame
> > I would push back ids to cgroups infrastructure.
> >
> 
> 
> 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
