Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id CCEB16B0055
	for <linux-mm@kvack.org>; Wed, 24 Jun 2009 23:39:13 -0400 (EDT)
Date: Wed, 24 Jun 2009 20:40:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC] Reduce the resource counter lock overhead
Message-Id: <20090624204013.b0aeda29.akpm@linux-foundation.org>
In-Reply-To: <20090625030446.GW8642@balbir.in.ibm.com>
References: <20090624170516.GT8642@balbir.in.ibm.com>
	<20090624161028.b165a61a.akpm@linux-foundation.org>
	<20090625030446.GW8642@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, menage@google.com, xemul@openvz.org, linux-mm@kvack.org, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Thu, 25 Jun 2009 08:34:46 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Andrew Morton <akpm@linux-foundation.org> [2009-06-24 16:10:28]:
> 
> > On Wed, 24 Jun 2009 22:35:16 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>  
> ...
>
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
> 
> We wanted to modularize resource counters and keep the code isolated
> from memcontrol.c, hence it continues to live outside

That doesn't mean that is has to be inlined.  That function is really
really big, especially with lockdep enabled.

> > 
> > Which function is calling mem_cgroup_check_under_limit() so much?
> > __mem_cgroup_try_charge()?  If so, I'm a bit surprised because
> > inefficiencies of this nature in page reclaim rarely are demonstrable -
> > reclaim just doesn't get called much.  Perhaps this is a sign that
> > reclaim is scanning the same pages over and over again and is being
> > inefficient at a higher level?
> > 
> 
> We do a check everytime before we charge. To answer the other part of
> reclaim, I am currently seeing some interesting data, even with no
> groups created, I see memcg reclaim_stats set to root to be quite
> high, even though we are not reclaiming from root.
> I am yet to get to the root cause of the issue
> 
> 
> > Do we really need to call mem_cgroup_hierarchical_reclaim() as
> > frequently as we apparently are doing?
> >
> 
> All our reclaim is now hierarchical, was there anything specific you
> saw? 

My point is that when one sees a function high in the profiles,
speeding up that function isn't the only fix.  Another (often superior)
fix is to call that function less frequently.  Or perhaps to cache its
result in some fashion.

Have you established that this function is being called at the minimum
possible frequency?  Is the frequency at which it being called
reasonable and expected?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
