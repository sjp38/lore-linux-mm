Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 338B46B00D8
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 02:16:51 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n1P7GmRd006649
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Feb 2009 16:16:48 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B1B045DE51
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 16:16:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 61E3E45DE4D
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 16:16:48 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 42B66E08005
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 16:16:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DF1B9E08001
	for <linux-mm@kvack.org>; Wed, 25 Feb 2009 16:16:47 +0900 (JST)
Date: Wed, 25 Feb 2009 16:15:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] use CSS ID in swap_cgroup for saving memory
Message-Id: <20090225161533.6fcf5760.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <49A4EEA0.3010309@cn.fujitsu.com>
References: <20090225152617.df4eeb35.kamezawa.hiroyu@jp.fujitsu.com>
	<49A4EEA0.3010309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "menage@google.com" <menage@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Feb 2009 15:09:20 +0800
Li Zefan <lizf@cn.fujitsu.com> wrote:

> >  static inline
> > -struct mem_cgroup *swap_cgroup_record(swp_entry_t ent, struct mem_cgroup *mem)
> > +unsigned short swap_cgroup_record(swp_entry_t ent, unsigned short id)
> >  {
> >  	return NULL;
> 
> return 0;
> 
should be..

> >  }
> >  
> >  static inline
> > -struct mem_cgroup *lookup_swap_cgroup(swp_entry_t ent)
> > +unsigned short lookup_swap_cgroup(swp_entry_t ent)
> >  {
> >  	return NULL;
> 
> return 0;
> 
ok

> >  }
> 
> > @@ -1265,12 +1286,20 @@ int mem_cgroup_cache_charge(struct page 
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
> > +		rcu_read_unlock();
> >  	}
> >  	return ret;
> >  }
> > @@ -1335,13 +1364,21 @@ void mem_cgroup_commit_charge_swapin(str
> >  	 */
> >  	if (do_swap_account && PageSwapCache(page)) {
> >  		swp_entry_t ent = {.val = page_private(page)};
> > +		unsigned short id;
> >  		struct mem_cgroup *memcg;
> > -		memcg = swap_cgroup_record(ent, NULL);
> > +
> > +		id = swap_cgroup_record(ent, 0);
> > +		rcu_read_lock();
> > +		memcg = mem_cgroup_lookup(id);
> >  		if (memcg) {
> > +			/*
> > +			 * This recorded memcg can be obsolete one. So, avoid
> > +			 * calling css_tryget
> > +			 */
> >  			res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> >  			mem_cgroup_put(memcg);
> >  		}
> > -
> > +		rcu_read_unlock();
> >  	}
> >  	/* add this page(page_cgroup) to the LRU we want. */
> >  
> > @@ -1462,7 +1499,7 @@ void mem_cgroup_uncharge_swapcache(struc
> >  					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
> >  	/* record memcg information */
> >  	if (do_swap_account && memcg) {
> > -		swap_cgroup_record(ent, memcg);
> > +		swap_cgroup_record(ent, css_id(&memcg->css));
> >  		mem_cgroup_get(memcg);
> >  	}
> >  	if (memcg)
> > @@ -1477,15 +1514,22 @@ void mem_cgroup_uncharge_swapcache(struc
> >  void mem_cgroup_uncharge_swap(swp_entry_t ent)
> >  {
> >  	struct mem_cgroup *memcg;
> > +	unsigned short id;
> >  
> >  	if (!do_swap_account)
> >  		return;
> >  
> > -	memcg = swap_cgroup_record(ent, NULL);
> > +	id = swap_cgroup_record(ent, 0);
> > +	rcu_read_lock();
> > +	memcg = mem_cgroup_lookup(id);
> >  	if (memcg) {
> > +		/*
> > +		 * This memcg can be obsolete one. We avoid calling css_tryget
> > +		 */
> >  		res_counter_uncharge(&memcg->memsw, PAGE_SIZE);
> >  		mem_cgroup_put(memcg);
> >  	}
> > +	rcu_read_unlock();
> 
> can we have a common function for the above 3 pieces of code?
> 

I don't think it's better. All are under rcu_read_lock() and does
"charge" management in diffferent meanings/context.
These small pieces of code are worth to be open coded.




> >  }
> >  #endif
> >  
> > Index: mmotm-2.6.29-Feb24/mm/page_cgroup.c
> > ===================================================================
> > --- mmotm-2.6.29-Feb24.orig/mm/page_cgroup.c
> > +++ mmotm-2.6.29-Feb24/mm/page_cgroup.c
> > @@ -290,7 +290,7 @@ struct swap_cgroup_ctrl swap_cgroup_ctrl
> >   * cgroup rather than pointer.
> >   */
> 
> this comment should be updated/removed:
> 
> /*
>  * This 8bytes seems big..maybe we can reduce this when we can use "id" for
>  * cgroup rather than pointer.
>  */
> 
Ah, I missed this.

I'll update and post tomorrow, again if no "don't do that"

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
