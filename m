Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 835F26B005D
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:26:41 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5P3MpMc015722
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:22:51 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P3RT0g249956
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:27:29 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5P3P6W8005654
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:25:07 -0400
Date: Thu, 25 Jun 2009 08:34:46 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-ID: <20090625030446.GW8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090624170516.GT8642@balbir.in.ibm.com> <20090624161028.b165a61a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090624161028.b165a61a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-06-24 16:10:28]:

> On Wed, 24 Jun 2009 22:35:16 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Hi, All,
> > 
> > I've been experimenting with reduction of resource counter locking
> > overhead. My benchmarks show a marginal improvement, /proc/lock_stat
> > however shows that the lock contention time and held time reduce
> > by quite an amount after this patch. 
> 
> That looks sane.
> 
> > -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> >                               class name    con-bounces    contentions
> > waittime-min   waittime-max waittime-total    acq-bounces
> > acquisitions   holdtime-min   holdtime-max holdtime-total
> > -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> > 
> >                           &counter->lock:       1534627        1575341
> > 0.57          18.39      675713.23       43330446      138524248
> > 0.43         148.13    54133607.05
> >                           --------------
> >                           &counter->lock         809559
> > [<ffffffff810810c5>] res_counter_charge+0x3f/0xed
> >                           &counter->lock         765782
> > [<ffffffff81081045>] res_counter_uncharge+0x2c/0x6d
> >                           --------------
> >                           &counter->lock         653284
> > [<ffffffff81081045>] res_counter_uncharge+0x2c/0x6d
> >                           &counter->lock         922057
> > [<ffffffff810810c5>] res_counter_charge+0x3f/0xed
> 
> Please turn off the wordwrapping before sending the signed-off version.
>

I'll need to see what caused the problem here. Thanks for the heads-up
 
> >  static inline bool res_counter_check_under_limit(struct res_counter *cnt)
> >  {
> >  	bool ret;
> > -	unsigned long flags;
> > +	unsigned long flags, seq;
> >  
> > -	spin_lock_irqsave(&cnt->lock, flags);
> > -	ret = res_counter_limit_check_locked(cnt);
> > -	spin_unlock_irqrestore(&cnt->lock, flags);
> > +	do {
> > +		seq = read_seqbegin_irqsave(&cnt->lock, flags);
> > +		ret = res_counter_limit_check_locked(cnt);
> > +	} while (read_seqretry_irqrestore(&cnt->lock, seq, flags));
> >  	return ret;
> >  }
> 
> This change makes the inlining of these functions even more
> inappropriate than it already was.
> 
> This function should be static in memcontrol.c anyway?

We wanted to modularize resource counters and keep the code isolated
from memcontrol.c, hence it continues to live outside

> 
> Which function is calling mem_cgroup_check_under_limit() so much?
> __mem_cgroup_try_charge()?  If so, I'm a bit surprised because
> inefficiencies of this nature in page reclaim rarely are demonstrable -
> reclaim just doesn't get called much.  Perhaps this is a sign that
> reclaim is scanning the same pages over and over again and is being
> inefficient at a higher level?
> 

We do a check everytime before we charge. To answer the other part of
reclaim, I am currently seeing some interesting data, even with no
groups created, I see memcg reclaim_stats set to root to be quite
high, even though we are not reclaiming from root.
I am yet to get to the root cause of the issue


> Do we really need to call mem_cgroup_hierarchical_reclaim() as
> frequently as we apparently are doing?
>

All our reclaim is now hierarchical, was there anything specific you
saw? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
