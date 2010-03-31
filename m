Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5E5F36B01EE
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 02:30:21 -0400 (EDT)
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by e28smtp09.in.ibm.com (8.14.3/8.13.1) with ESMTP id o2V5hnmx029072
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 11:13:49 +0530
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay05.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2V6UCPC3350694
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:00:12 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2V6UBGm013017
	for <linux-mm@kvack.org>; Wed, 31 Mar 2010 12:00:12 +0530
Date: Wed, 31 Mar 2010 12:00:07 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] oom killer: break from infinite loop
Message-ID: <20100331063007.GN3308@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100328145528.GA14622@desktop>
 <20100328162821.GA16765@redhat.com>
 <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com>
 <20100329140633.GA26464@desktop>
 <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
 <20100330142923.GA10099@desktop>
 <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com>
 <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com>
 <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, anfei <anfei.zhou@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-03-31 15:13:56]:

> On Tue, 30 Mar 2010 23:07:08 -0700 (PDT)
> David Rientjes <rientjes@google.com> wrote:
> 
> > On Wed, 31 Mar 2010, KAMEZAWA Hiroyuki wrote:
> > 
> > > > > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > > > > index 0cb1ca4..9e89a29 100644
> > > > > --- a/mm/oom_kill.c
> > > > > +++ b/mm/oom_kill.c
> > > > > @@ -510,8 +510,10 @@ retry:
> > > > >  	if (PTR_ERR(p) == -1UL)
> > > > >  		goto out;
> > > > >  
> > > > > -	if (!p)
> > > > > -		p = current;
> > > > > +	if (!p) {
> > > > > +		read_unlock(&tasklist_lock);
> > > > > +		panic("Out of memory and no killable processes...\n");
> > > > > +	}
> > > > >  
> > > > >  	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
> > > > >  				"Memory cgroup out of memory"))
> > > > > 
> > > > 
> > > > This actually does appear to be necessary but for a different reason: if 
> > > > current is unkillable because it has OOM_DISABLE, for example, then 
> > > > oom_kill_process() will repeatedly fail and mem_cgroup_out_of_memory() 
> > > > will infinitely loop.
> > > > 
> > > > Kame-san?
> > > > 
> > > 
> > > When a memcg goes into OOM and it only has unkillable processes (OOM_DISABLE),
> > > we can do nothing. (we can't panic because container's death != system death.)
> > > 
> > > Because memcg itself has mutex+waitqueue for mutual execusion of OOM killer, 
> > > I think infinite-loop will not be critical probelm for the whole system.
> > > 
> > > And, now, memcg has oom-kill-disable + oom-kill-notifier features.
> > > So, If a memcg goes into OOM and there is no killable process, but oom-kill is
> > > not disabled by memcg.....it means system admin's mis-configuraton.
> > > 
> > > He can stop inifite loop by hand, anyway.
> > > # echo 1 > ..../group_A/memory.oom_control
> > > 
> > 
> > Then we should be able to do this since current is by definition 
> > unkillable since it was not found in select_bad_process(), right?
> 
> To me, this patch is acceptable and seems reasnoable.
> 
> But I didn't joined to memcg development when this check was added
> and don't know why kill current..
>

The reason for adding current was that we did not want to loop
forever, since it stops forward progress - no error/no forward
progress. It made sense to oom kill the current process, so that the
cgroup admin could look at what went wrong.
 
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=c7ba5c9e8176704bfac0729875fa62798037584d
> 
> Addinc Balbir to CC. Maybe situation is changed now.
> Because we can stop inifinite loop (by hand) and there is no rushing oom-kill
> callers, this change is acceptable.
>

By hand is not always possible if we have a large number of cgroups
(I've seen a setup with 2000 cgroups on libcgroup ML). 2000 cgroups *
number of processes make the situation complex. I think using OOM
notifier is now another way of handling such a situation.
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
