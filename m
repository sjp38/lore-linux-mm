Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8B2D56B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 03:51:39 -0500 (EST)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1A8pak6005831
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Feb 2009 17:51:36 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 734B345DE51
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:51:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 4574B45DE50
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:51:36 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id EE6701DB8037
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:51:35 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9F41DB803B
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:51:32 +0900 (JST)
Date: Tue, 10 Feb 2009 17:50:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] Reduce size of swap_cgroup by CSS ID v2
Message-Id: <20090210175019.b100b279.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090210080700.GC16317@balbir.in.ibm.com>
References: <20090205185959.7971dee4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090209145557.d0754a9f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090210080700.GC16317@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Feb 2009 13:37:00 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-02-09 14:55:57]:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  {
> > -	struct mem_cgroup *mem;
> > +	unsigned short id;
> > +	struct mem_cgroup *mem = NULL;
> >  	swp_entry_t ent;
> > 
> >  	if (!PageSwapCache(page))
> >  		return NULL;
> > 
> >  	ent.val = page_private(page);
> > -	mem = lookup_swap_cgroup(ent);
> > -	if (!mem)
> > -		return NULL;
> > +	id = lookup_swap_cgroup(ent);
> > +	rcu_read_lock();
> > +	mem = mem_cgroup_lookup(id);
> >  	if (!css_tryget(&mem->css))
> > -		return NULL;
> > +		mem = NULL;
> 
> This part is a bit confusing. If the page got swapped out and the CSS
> it belonged to got swapped out, we set mem to NULL. Is this so that it
> can be charged to root cgroup?
IIUC, this charge will go to "current" process's cgroup.

> If so, could you please add a comment indicating the same.
> 
Ah yes, I'll add some comments.


> > +	rcu_read_unlock();
> >  	return mem;
> >  }
> > 
> > @@ -1275,12 +1296,20 @@ int mem_cgroup_cache_charge(struct page 
> > 
> >  	if (do_swap_account && !ret && PageSwapCache(page)) {
> >  		swp_entry_t ent = {.val = page_private(page)};
> > +		unsigned short id;
> >  		/* avoid double counting */
> > -		mem = swap_cgroup_record(ent, NULL);
> > +		id = swap_cgroup_record(ent, 0);
> > +		rcu_read_lock();
> > +		mem = mem_cgroup_lookup(id);
> >  		if (mem) {
> > +			/*
> > +			 * Recorded ID can be obsolete. We avoid calling
> > +			 * css_tryget()
> > +			 */
> >  			res_counter_uncharge(&mem->memsw, PAGE_SIZE);
> >  			mem_cgroup_put(mem);
> >  		}
> 
> If !mem, do we leak charge?
No, it just means some other thread removed the ID before us.

> BTW, We no longer hold css references if the page is swapped out?
> 
The situation is a bit complicated.
When cgroup is obsolete but its mem_cgroup is alive (because of reference
from swap), css_tryget() always fails. swap_cgroup_record() is atomic
compare-and-exchange, so I think we can trust mem_cgroup_put/get refcnt
management and doesn't need to rely on css's refcnt at swap management.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
