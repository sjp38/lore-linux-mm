Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0349A6B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 03:15:12 -0400 (EDT)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp06.au.ibm.com (8.13.1/8.13.1) with ESMTP id n2D7Ev0R002198
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:14:57 +1100
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D7FO6o1102000
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:15:24 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n2D7F6YY026001
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 18:15:07 +1100
Date: Fri, 13 Mar 2009 12:45:01 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 4/4] Memory controller soft limit reclaim on contention
	(v5)
Message-ID: <20090313071501.GK16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <20090312175631.17890.30427.sendpatchset@localhost.localdomain> <d6757939628fe7646a00a0b3b69d277f.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <d6757939628fe7646a00a0b3b69d277f.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-13 15:51:25]:

> Balbir Singh wrote:
> > Feature: Implement reclaim from groups over their soft limit
> >
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> > +unsigned long mem_cgroup_soft_limit_reclaim(struct zonelist *zl, gfp_t
> > gfp_mask)
> > +{
> > +	unsigned long nr_reclaimed = 0;
> > +	struct mem_cgroup *mem;
> > +	unsigned long flags;
> > +	unsigned long reclaimed;
> > +
> > +	/*
> > +	 * This loop can run a while, specially if mem_cgroup's continuously
> > +	 * keep exceeding their soft limit and putting the system under
> > +	 * pressure
> > +	 */
> > +	do {
> > +		mem = mem_cgroup_largest_soft_limit_node();
> > +		if (!mem)
> > +			break;
> > +
> > +		reclaimed = mem_cgroup_hierarchical_reclaim(mem, zl,
> > +						gfp_mask,
> > +						MEM_CGROUP_RECLAIM_SOFT);
> > +		nr_reclaimed += reclaimed;
> > +		spin_lock_irqsave(&memcg_soft_limit_tree_lock, flags);
> > +		mem->usage_in_excess = res_counter_soft_limit_excess(&mem->res);
> > +		__mem_cgroup_remove_exceeded(mem);
> > +		if (mem->usage_in_excess)
> > +			__mem_cgroup_insert_exceeded(mem);
> > +		spin_unlock_irqrestore(&memcg_soft_limit_tree_lock, flags);
> > +		css_put(&mem->css);
> > +		cond_resched();
> > +	} while (!nr_reclaimed);
> > +	return nr_reclaimed;
> > +}
> > +
>  Why do you never consider bad corner case....
>  As I wrote many times, "order of global usage" doesn't mean the
>  biggest user of memcg containes memory in zones which we want.
>  So, please don't pust "mem" back to RB-tree if reclaimed is 0.
> 
>  This routine seems toooo bad as v4.

Are you talking about cases where a particular mem cgroup never
allocated from a node? Thanks.. let me take a look at it

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
