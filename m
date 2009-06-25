Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D40F66B005D
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:26:40 -0400 (EDT)
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e37.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id n5P3Qlgd003816
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 21:26:47 -0600
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5P3RTp8206764
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 21:27:29 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n5P3RTCR011418
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 21:27:29 -0600
Date: Thu, 25 Jun 2009 08:57:17 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-ID: <20090625032717.GX8642@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090624170516.GT8642@balbir.in.ibm.com> <20090624161028.b165a61a.akpm@linux-foundation.org> <20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090625085347.a64654a7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-06-25 08:53:47]:

> On Wed, 24 Jun 2009 16:10:28 -0700
> Andrew Morton <akpm@linux-foundation.org> wrote:
> 
> > On Wed, 24 Jun 2009 22:35:16 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Hi, All,
> > > 
> > > I've been experimenting with reduction of resource counter locking
> > > overhead. My benchmarks show a marginal improvement, /proc/lock_stat
> > > however shows that the lock contention time and held time reduce
> > > by quite an amount after this patch. 
> > 
> > That looks sane.
> > 
> I suprized to see seq_lock here can reduce the overhead.
>

I am not too surprised, given that we do frequent read-writes. We do a
read everytime before we charge.
 
> 
> > > -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> > >                               class name    con-bounces    contentions
> > > waittime-min   waittime-max waittime-total    acq-bounces
> > > acquisitions   holdtime-min   holdtime-max holdtime-total
> > > -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
> > > 
> > >                           &counter->lock:       1534627        1575341
> > > 0.57          18.39      675713.23       43330446      138524248
> > > 0.43         148.13    54133607.05
> > >                           --------------
> > >                           &counter->lock         809559
> > > [<ffffffff810810c5>] res_counter_charge+0x3f/0xed
> > >                           &counter->lock         765782
> > > [<ffffffff81081045>] res_counter_uncharge+0x2c/0x6d
> > >                           --------------
> > >                           &counter->lock         653284
> > > [<ffffffff81081045>] res_counter_uncharge+0x2c/0x6d
> > >                           &counter->lock         922057
> > > [<ffffffff810810c5>] res_counter_charge+0x3f/0xed
> > 
> > Please turn off the wordwrapping before sending the signed-off version.
> > 
> > >  static inline bool res_counter_check_under_limit(struct res_counter *cnt)
> > >  {
> > >  	bool ret;
> > > -	unsigned long flags;
> > > +	unsigned long flags, seq;
> > >  
> > > -	spin_lock_irqsave(&cnt->lock, flags);
> > > -	ret = res_counter_limit_check_locked(cnt);
> > > -	spin_unlock_irqrestore(&cnt->lock, flags);
> > > +	do {
> > > +		seq = read_seqbegin_irqsave(&cnt->lock, flags);
> > > +		ret = res_counter_limit_check_locked(cnt);
> > > +	} while (read_seqretry_irqrestore(&cnt->lock, seq, flags));
> > >  	return ret;
> > >  }
> > 
> > This change makes the inlining of these functions even more
> > inappropriate than it already was.
> > 
> > This function should be static in memcontrol.c anyway?
> > 
> > Which function is calling mem_cgroup_check_under_limit() so much? 
> > __mem_cgroup_try_charge()?  If so, I'm a bit surprised because
> > inefficiencies of this nature in page reclaim rarely are demonstrable -
> > reclaim just doesn't get called much.  Perhaps this is a sign that
> > reclaim is scanning the same pages over and over again and is being
> > inefficient at a higher level?
> > 
> > Do we really need to call mem_cgroup_hierarchical_reclaim() as
> > frequently as we apparently are doing?
> > 
> 
> Most of modification to res_counter is
> 	- charge
> 	- uncharge
> and not
> 	- read
> 
> What kind of workload can be much improved ?
> IIUC, in general, using seq_lock to frequently modified counter just makes
> it slow.

Why do you think so? I've been looking primarily at do_gettimeofday().
Yes, frequent updates can hurt readers in the worst case. I've been
meaning to experiment with percpu counters as well, but we'll need to
decide what is the tolerance limit, since we can have a batch value
fuzziness, before all CPUs see that the limit is exceeded, but it
might be worth experimenting.

> 
> Could you show improved kernbench or unixbench score ?
> 

I'll start some of these and see if I can get a large machine to test
on. I ran reaim for the current run.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
