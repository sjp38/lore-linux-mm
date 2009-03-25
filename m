Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A7B126B009F
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 01:28:48 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2P5sP5C021433
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 11:24:25 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2P5oc5Z2261196
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 11:20:38 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2P5s8qN007028
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 16:54:09 +1100
Date: Wed, 25 Mar 2009 11:23:54 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-ID: <20090325055354.GK24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165735.27274.96091.sendpatchset@localhost.localdomain> <20090325135900.dc82f133.kamezawa.hiroyu@jp.fujitsu.com> <20090325052945.GI24227@balbir.in.ibm.com> <20090325143953.beba2e02.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090325143953.beba2e02.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 14:39:53]:

> On Wed, 25 Mar 2009 10:59:47 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 13:59:00]:
> 
> > > > @@ -75,7 +85,8 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> > > >  	counter->usage -= val;
> > > >  }
> > > >  
> > > > -void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > > > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > > > +				bool *was_soft_limit_excess)
> > > >  {
> > > >  	unsigned long flags;
> > > >  	struct res_counter *c;
> > > > @@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > > >  	local_irq_save(flags);
> > > >  	for (c = counter; c != NULL; c = c->parent) {
> > > >  		spin_lock(&c->lock);
> > > > +		if (c == counter && was_soft_limit_excess)
> > > > +			*was_soft_limit_excess =
> > > > +				!res_counter_soft_limit_check_locked(c);
> > > >  		res_counter_uncharge_locked(c, val);
> > > >  		spin_unlock(&c->lock);
> > > >  	}
> > > Does this work as intended ?
> > > Assume following hierarchy
> > > 
> > >    A/  softlimit=1G usage=300M
> > >      B/ softlimit=200M usage=300M.
> > >      C/ softlimit=800M usage=0M
> > > 
> > > *was_soft_limit_excess will be false and no tree update, forever.
> > >
> > 
> > No.. was_soft_limit_excess checks the soft limit before uncharge to
> > see if we were over soft limit, when a page gets uncharged from B,
> > since B is over soft limit and on tree, we will update the tree. Why
> > do you say that was_soft_limit_excess will return false? 
> > 
> my eyes tend to be buggy. ok, change the question.
>

No problem, we've all been there :)
 
> ==
> +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> +				bool *was_soft_limit_excess)
>  {
>  	unsigned long flags;
>  	struct res_counter *c;
> @@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
>  	local_irq_save(flags);
>  	for (c = counter; c != NULL; c = c->parent) {
>  		spin_lock(&c->lock);
> +		if (c == counter && was_soft_limit_excess)
> +			*was_soft_limit_excess =
> +				!res_counter_soft_limit_check_locked(c);
>  		res_counter_uncharge_locked(c, val);
>  		spin_unlock(&c->lock);
>  	}
> ==
> Why just check "c == coutner" case is enough ?
> 

This is a very good question, I think this check might not be
necessary and can also be potentially buggy.

> Thanks,
> -Kame
> 
> 
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
