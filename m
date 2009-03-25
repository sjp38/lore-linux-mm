Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2699D6B00A3
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 01:55:46 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2P5sFif004824
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 11:24:15 +0530
Received: from d28av04.in.ibm.com (d28av04.in.ibm.com [9.184.220.66])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2P6M3NN217148
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 11:52:03 +0530
Received: from d28av04.in.ibm.com (loopback [127.0.0.1])
	by d28av04.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2P6Ls4d029199
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 17:21:54 +1100
Date: Wed, 25 Mar 2009 11:51:40 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-ID: <20090325062140.GM24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165735.27274.96091.sendpatchset@localhost.localdomain> <20090325135900.dc82f133.kamezawa.hiroyu@jp.fujitsu.com> <20090325052945.GI24227@balbir.in.ibm.com> <20090325143953.beba2e02.kamezawa.hiroyu@jp.fujitsu.com> <20090325055354.GK24227@balbir.in.ibm.com> <20090325150109.b127a7af.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090325150109.b127a7af.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 15:01:09]:

> On Wed, 25 Mar 2009 11:23:54 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > > ==
> > > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > > +				bool *was_soft_limit_excess)
> > >  {
> > >  	unsigned long flags;
> > >  	struct res_counter *c;
> > > @@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > >  	local_irq_save(flags);
> > >  	for (c = counter; c != NULL; c = c->parent) {
> > >  		spin_lock(&c->lock);
> > > +		if (c == counter && was_soft_limit_excess)
> > > +			*was_soft_limit_excess =
> > > +				!res_counter_soft_limit_check_locked(c);
> > >  		res_counter_uncharge_locked(c, val);
> > >  		spin_unlock(&c->lock);
> > >  	}
> > > ==
> > > Why just check "c == coutner" case is enough ?
> > > 
> > 
> > This is a very good question, I think this check might not be
> > necessary and can also be potentially buggy.
> > 
> I feel so, but can't think of good clean up.
> 
> Don't we remove this check at uncharge ? Anyway status can be updated at
>   - charge().
>   - reclaim
> 
> I'll seek this way in mine...

The check can be removed, let me do that and re-run the overhead
tests.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
