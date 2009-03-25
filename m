Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A23AF6B009A
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 01:05:07 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp01.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2P5UKv5027711
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 11:00:20 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2P5UD5B4436148
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 11:00:13 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2P5U4Wi016235
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 16:30:04 +1100
Date: Wed, 25 Mar 2009 10:59:47 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-ID: <20090325052945.GI24227@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain> <20090319165735.27274.96091.sendpatchset@localhost.localdomain> <20090325135900.dc82f133.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090325135900.dc82f133.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 13:59:00]:

> On Thu, 19 Mar 2009 22:27:35 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > Feature: Organize cgroups over soft limit in a RB-Tree
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > Changelog v7...v6
> > 1. Refactor the check and update logic. The goal is to allow the
> >    check logic to be modular, so that it can be revisited in the future
> >    if something more appropriate is found to be useful.
> > 
> > Changelog v6...v5
> > 1. Update the key before inserting into RB tree. Without the current change
> >    it could take an additional iteration to get the key correct.
> > 
> > Changelog v5...v4
> > 1. res_counter_uncharge has an additional parameter to indicate if the
> >    counter was over its soft limit, before uncharge.
> > 
> > Changelog v4...v3
> > 1. Optimizations to ensure we don't uncessarily get res_counter values
> > 2. Fixed a bug in usage of time_after()
> > 
> > Changelog v3...v2
> > 1. Add only the ancestor to the RB-Tree
> > 2. Use css_tryget/css_put instead of mem_cgroup_get/mem_cgroup_put
> > 
> > Changelog v2...v1
> > 1. Add support for hierarchies
> > 2. The res_counter that is highest in the hierarchy is returned on soft
> >    limit being exceeded. Since we do hierarchical reclaim and add all
> >    groups exceeding their soft limits, this approach seems to work well
> >    in practice.
> > 
> > This patch introduces a RB-Tree for storing memory cgroups that are over their
> > soft limit. The overall goal is to
> > 
> > 1. Add a memory cgroup to the RB-Tree when the soft limit is exceeded.
> >    We are careful about updates, updates take place only after a particular
> >    time interval has passed
> > 2. We remove the node from the RB-Tree when the usage goes below the soft
> >    limit
> > 
> > The next set of patches will exploit the RB-Tree to get the group that is
> > over its soft limit by the largest amount and reclaim from it, when we
> > face memory contention.
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> > 
> >  include/linux/res_counter.h |    6 +-
> >  kernel/res_counter.c        |   18 +++++
> >  mm/memcontrol.c             |  149 ++++++++++++++++++++++++++++++++++++++-----
> >  3 files changed, 151 insertions(+), 22 deletions(-)
> > 
> > 
> > diff --git a/include/linux/res_counter.h b/include/linux/res_counter.h
> > index 5c821fd..5bbf8b1 100644
> > --- a/include/linux/res_counter.h
> > +++ b/include/linux/res_counter.h
> > @@ -112,7 +112,8 @@ void res_counter_init(struct res_counter *counter, struct res_counter *parent);
> >  int __must_check res_counter_charge_locked(struct res_counter *counter,
> >  		unsigned long val);
> >  int __must_check res_counter_charge(struct res_counter *counter,
> > -		unsigned long val, struct res_counter **limit_fail_at);
> > +		unsigned long val, struct res_counter **limit_fail_at,
> > +		struct res_counter **soft_limit_at);
> >  
> >  /*
> >   * uncharge - tell that some portion of the resource is released
> > @@ -125,7 +126,8 @@ int __must_check res_counter_charge(struct res_counter *counter,
> >   */
> >  
> >  void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val);
> > -void res_counter_uncharge(struct res_counter *counter, unsigned long val);
> > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > +				bool *was_soft_limit_excess);
> >  
> >  static inline bool res_counter_limit_check_locked(struct res_counter *cnt)
> >  {
> > diff --git a/kernel/res_counter.c b/kernel/res_counter.c
> > index 4e6dafe..51ec438 100644
> > --- a/kernel/res_counter.c
> > +++ b/kernel/res_counter.c
> > @@ -37,17 +37,27 @@ int res_counter_charge_locked(struct res_counter *counter, unsigned long val)
> >  }
> >  
> >  int res_counter_charge(struct res_counter *counter, unsigned long val,
> > -			struct res_counter **limit_fail_at)
> > +			struct res_counter **limit_fail_at,
> > +			struct res_counter **soft_limit_fail_at)
> >  {
> >  	int ret;
> >  	unsigned long flags;
> >  	struct res_counter *c, *u;
> >  
> >  	*limit_fail_at = NULL;
> > +	if (soft_limit_fail_at)
> > +		*soft_limit_fail_at = NULL;
> >  	local_irq_save(flags);
> >  	for (c = counter; c != NULL; c = c->parent) {
> >  		spin_lock(&c->lock);
> >  		ret = res_counter_charge_locked(c, val);
> > +		/*
> > +		 * With soft limits, we return the highest ancestor
> > +		 * that exceeds its soft limit
> > +		 */
> > +		if (soft_limit_fail_at &&
> > +			!res_counter_soft_limit_check_locked(c))
> > +			*soft_limit_fail_at = c;
> >  		spin_unlock(&c->lock);
> 
> I'm not sure this works as intended or not. Could you clarify ? (see below)
> 
>     In following hierarchy,
> 
>          A/   soft_limit=1G, usage=1.2G.
>            B  soft_limit=200M, usage=1G
>            C  soft_limit=800M, usage=200M
> 
>    This function returns only "A". 
>    And memory will be reclaimed from B and C, at first.
>    

Yes, A will be put on the RB-Tree, earlier we were putting both A and
B, but you were opposed to it (I can't remember why). Memory will be
reclaimed from A, B and C through hierarchical reclaim.

> 
> 
> >  		if (ret < 0) {
> >  			*limit_fail_at = c;
> > @@ -75,7 +85,8 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> >  	counter->usage -= val;
> >  }
> >  
> > -void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > +				bool *was_soft_limit_excess)
> >  {
> >  	unsigned long flags;
> >  	struct res_counter *c;
> > @@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> >  	local_irq_save(flags);
> >  	for (c = counter; c != NULL; c = c->parent) {
> >  		spin_lock(&c->lock);
> > +		if (c == counter && was_soft_limit_excess)
> > +			*was_soft_limit_excess =
> > +				!res_counter_soft_limit_check_locked(c);
> >  		res_counter_uncharge_locked(c, val);
> >  		spin_unlock(&c->lock);
> >  	}
> Does this work as intended ?
> Assume following hierarchy
> 
>    A/  softlimit=1G usage=300M
>      B/ softlimit=200M usage=300M.
>      C/ softlimit=800M usage=0M
> 
> *was_soft_limit_excess will be false and no tree update, forever.
>

No.. was_soft_limit_excess checks the soft limit before uncharge to
see if we were over soft limit, when a page gets uncharged from B,
since B is over soft limit and on tree, we will update the tree. Why
do you say that was_soft_limit_excess will return false? 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
