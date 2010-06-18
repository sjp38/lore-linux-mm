Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id DC3EA6B01AC
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 23:15:55 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o5I32S64004558
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 23:02:28 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o5I3Fmv1143602
	for <linux-mm@kvack.org>; Thu, 17 Jun 2010 23:15:48 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o5I3Fln4021001
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 00:15:47 -0300
Date: Fri, 18 Jun 2010 08:45:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [BUGFIX][PATCH -mm] fix bad call of memcg_oom_recover at cancel
 move.
Message-ID: <20100618031543.GM4306@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20100617172034.00ea8835.kamezawa.hiroyu@jp.fujitsu.com>
 <20100617092442.GJ4306@balbir.in.ibm.com>
 <20100618105741.4e596ea7.nishimura@mxp.nes.nec.co.jp>
 <20100618111735.b3d64d95.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20100618111735.b3d64d95.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-06-18 11:17:35]:

> On Fri, 18 Jun 2010 10:57:41 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > May I recommend the following change instead
> > > 
> > > 
> > > Don't crash on a null memcg being passed, check if memcg
> > > is NULL and handle the condition gracefully
> > > 
> > > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > > ---
> > >  mm/memcontrol.c |    2 +-
> > >  1 files changed, 1 insertions(+), 1 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index c6ece0a..d71c488 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1370,7 +1370,7 @@ static void memcg_wakeup_oom(struct mem_cgroup *mem)
> > >  
> > >  static void memcg_oom_recover(struct mem_cgroup *mem)
> > >  {
> > > -	if (mem->oom_kill_disable && atomic_read(&mem->oom_lock))
> > > +	if (mem && mem->oom_kill_disable && atomic_read(&mem->oom_lock))
> > >  		memcg_wakeup_oom(mem);
> > >  }
> > >  
> > I agree to this fix.
> > 
> > Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> 
> I tend to dislike band-aid in callee. but it's not important here.
> 
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
>

The reason is just to make the reading easier

if (cond)
        func(cond)

if (cond2)
        func(cond2)

It is easier to read

        func(cond)
        ...
        func(cond2)

Provided it is valid for us to test the condition inside func()

This way new callers don't have to worry about using func(). This is
very much like how the free calls work today, they can tolerate a NULL
argument and return gracefully.
 

-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
