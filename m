Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 07CCA6B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:10:53 -0400 (EDT)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp07.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2C4Ahcn019818
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:40:43 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2C47Vlo3629096
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 09:37:31 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2C4AgRK003258
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 15:10:42 +1100
Date: Thu, 12 Mar 2009 09:40:38 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 2/5] add softlimit to res_counter
Message-ID: <20090312041038.GF23583@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com> <20090312095612.4a7758e1.kamezawa.hiroyu@jp.fujitsu.com> <20090312035444.GC23583@balbir.in.ibm.com> <20090312125839.3b01e20c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312125839.3b01e20c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-12 12:58:39]:

> On Thu, 12 Mar 2009 09:24:44 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> >
> > > +int res_counter_set_softlimit(struct res_counter *cnt, unsigned long long val)
> > > +{
> > > +	unsigned long flags;
> > > +
> > > +	spin_lock_irqsave(&cnt->lock, flags);
> > > +	cnt->softlimit = val;
> > > +	spin_unlock_irqrestore(&cnt->lock, flags);
> > > +	return 0;
> > > +}
> > > +
> > > +bool res_counter_check_under_softlimit(struct res_counter *cnt)
> > > +{
> > > +	struct res_counter *c;
> > > +	unsigned long flags;
> > > +	bool ret = true;
> > > +
> > > +	local_irq_save(flags);
> > > +	for (c = cnt; ret && c != NULL; c = c->parent) {
> > > +		spin_lock(&c->lock);
> > > +		if (c->softlimit < c->usage)
> > > +			ret = false;
> > 
> > So if a child was under the soft limit and the parent is *not*, we
> > _override_ ret and return false?
> > 
> yes. If you don't want this behavior I'll rename this to
> res_counter_check_under_softlimit_hierarchical().
> 

That is a nicer name.

> 
> > > +		spin_unlock(&c->lock);
> > > +	}
> > > +	local_irq_restore(flags);
> > > +	return ret;
> > > +}
> > 
> > Why is the check_under_softlimit hierarchical? 
> 
> At checking whether a mem_cgroup is a candidate for softlimit-reclaim,
> we need to check all parents.
> 
> > BTW, this patch is buggy. See above.
> > 
> 
> Not buggy. Just meets my requiremnt.

Correct me if I am wrong, but this boils down to checking if the top
root is above it's soft limit? Instead of checking all the way up in
the hierarchy, can't we do a conditional check for

        c->parent == NULL && (c->softlimit < c->usage)

BTW, I would prefer to split the word softlimit to soft_limit, it is
more readable that way.


-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
