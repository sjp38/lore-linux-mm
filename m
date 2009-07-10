Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 1F3E26B0082
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 02:55:25 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6A7I6FX002550
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 10 Jul 2009 16:18:06 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 563DE45DE52
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:18:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B60A45DE50
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:18:06 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 13D3EE0800A
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:18:06 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A650CE08007
	for <linux-mm@kvack.org>; Fri, 10 Jul 2009 16:18:05 +0900 (JST)
Date: Fri, 10 Jul 2009 16:16:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/5] Memory controller soft limit organize cgroups
 (v8)
Message-Id: <20090710161623.294bbd5f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090710064723.GA20129@balbir.in.ibm.com>
References: <20090709171441.8080.85983.sendpatchset@balbir-laptop>
	<20090709171501.8080.85138.sendpatchset@balbir-laptop>
	<20090710142135.8079cd22.kamezawa.hiroyu@jp.fujitsu.com>
	<20090710064723.GA20129@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, 10 Jul 2009 12:17:23 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-07-10 14:21:35]:
> 
> > On Thu, 09 Jul 2009 22:45:01 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > Feature: Organize cgroups over soft limit in a RB-Tree
> > > 
> > > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > > +	while (*p) {
> > 
> > I feel this *p should be loaded after taking spinlock(&stz->lock) rather than top
> > of function. No?
> 
> No.. since the root remains constant once loaded. Am I missing
> something?
> 
No, I just missed it.


> 
> > 
> > > +		parent = *p;
> > > +		mz_node = rb_entry(parent, struct mem_cgroup_per_zone,
> > > +					tree_node);
> > > +		if (mz->usage_in_excess < mz_node->usage_in_excess)
> > > +			p = &(*p)->rb_left;
> > > +		/*
> > > +		 * We can't avoid mem cgroups that are over their soft
> > > +		 * limit by the same amount
> > > +		 */
> > > +		else if (mz->usage_in_excess >= mz_node->usage_in_excess)
> > > +			p = &(*p)->rb_right;
> > > +	}
> > > +	rb_link_node(&mz->tree_node, parent, p);
> > > +	rb_insert_color(&mz->tree_node, &stz->rb_root);
> > > +	mz->last_tree_update = jiffies;
> > > +	spin_unlock_irqrestore(&stz->lock, flags);
> > > +}
> > > +
> > > +static void
> > > +mem_cgroup_remove_exceeded(struct mem_cgroup *mem,
> > > +				struct mem_cgroup_per_zone *mz,
> > > +				struct mem_cgroup_soft_limit_tree_per_zone *stz)
> > > +{
> > > +	unsigned long flags;
> > > +	spin_lock_irqsave(&stz->lock, flags);
> > why IRQ save ? again.
> >
> 
> Will remove
>  
> > > +	rb_erase(&mz->tree_node, &stz->rb_root);
> > > +	spin_unlock_irqrestore(&stz->lock, flags);
> > > +}
> > > +
> > > +static bool mem_cgroup_soft_limit_check(struct mem_cgroup *mem,
> > > +					bool over_soft_limit,
> > > +					struct page *page)
> > > +{
> > > +	unsigned long next_update;
> > > +	struct page_cgroup *pc;
> > > +	struct mem_cgroup_per_zone *mz;
> > > +
> > > +	if (!over_soft_limit)
> > > +		return false;
> > > +
> > > +	pc = lookup_page_cgroup(page);
> > > +	if (unlikely(!pc))
> > > +		return false;
> > > +	mz = mem_cgroup_zoneinfo(mem, page_cgroup_nid(pc), page_cgroup_zid(pc));
> > 
> > mz = page_cgroup_zoneinfo(pc)
> > or
> > mz = mem_cgroup_zoneinfo(mem, page_to_nid(page), page_zid(page))
> >
> 
> Will change it.
>  
> > > +
> > > +	next_update = mz->last_tree_update + MEM_CGROUP_TREE_UPDATE_INTERVAL;
> > > +	if (time_after(jiffies, next_update))
> > > +		return true;
> > > +
> > > +	return false;
> > > +}
> > > +
> > > +static void mem_cgroup_update_tree(struct mem_cgroup *mem, struct page *page)
> > > +{
> > > +	unsigned long long prev_usage_in_excess, new_usage_in_excess;
> > > +	bool updated_tree = false;
> > > +	unsigned long flags;
> > > +	struct page_cgroup *pc;
> > > +	struct mem_cgroup_per_zone *mz;
> > > +	struct mem_cgroup_soft_limit_tree_per_zone *stz;
> > > +
> > > +	/*
> > > +	 * As long as the page is around, pc's are always
> > > +	 * around and so is the mz, in the remove path
> > > +	 * we are yet to do the css_put(). I don't think
> > > +	 * we need to hold page cgroup lock.
> > > +	 */
> > IIUC, at updating tree,we grab this page which is near-to-be-mapped or
> > near-to-be-in-radix-treee. If so, not necessary to be annoyied.
> 
> Not sure I understand your comment about annoyied (annoyed?)
> 
Ah, sorry, I wanted to say "pc is always valid here"

> > 
> > > +	pc = lookup_page_cgroup(page);
> > > +	if (unlikely(!pc))
> > > +		return;
> > 
> > I bet this can be BUG_ON().
> 
> In the new version we will not need pc
> 
ok.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
