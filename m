Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 573EB6B003D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 04:28:25 -0400 (EDT)
Date: Tue, 24 Mar 2009 17:32:18 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090324173218.4de33b90.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090323142242.f6659457.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
	<20090318125154.f8ffe652.nishimura@mxp.nes.nec.co.jp>
	<20090318175734.f5a8a446.kamezawa.hiroyu@jp.fujitsu.com>
	<20090318231738.4e042cbd.d-nishimura@mtf.biglobe.ne.jp>
	<20090319084523.1fbcc3cb.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319111629.dcc9fe43.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319180631.44b0130f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090319190118.db8a1dd7.nishimura@mxp.nes.nec.co.jp>
	<20090319191321.6be9b5e8.nishimura@mxp.nes.nec.co.jp>
	<100477cfc6c3c775abc7aecd4ce8c46e.squirrel@webmail-b.css.fujitsu.com>
	<432ace3655a26d2d492a56303369a88a.squirrel@webmail-b.css.fujitsu.com>
	<20090320164520.f969907a.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323104555.cb7cd059.nishimura@mxp.nes.nec.co.jp>
	<20090323114118.8b45105f.kamezawa.hiroyu@jp.fujitsu.com>
	<20090323140419.40235ce3.nishimura@mxp.nes.nec.co.jp>
	<20090323142242.f6659457.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 14:22:42 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Mon, 23 Mar 2009 14:04:19 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > Nice clean-up here :)
> > > 
> > Thanks, I'll send a cleanup patch for this part later.
> > 
> Thank you, I'll look into.
> 
> > > > @@ -1359,18 +1373,40 @@ charge_cur_mm:
> > > >  	return __mem_cgroup_try_charge(mm, mask, ptr, true);
> > > >  }
> > > >  
> > > > -void mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr)
> > > > +static void
> > > > +__mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> > > > +					enum charge_type ctype)
> > > >  {
> > > > -	struct page_cgroup *pc;
> > > > +	unsigned long flags;
> > > > +	struct zone *zone = page_zone(page);
> > > > +	struct page_cgroup *pc = lookup_page_cgroup(page);
> > > > +	int locked = 0;
> > > >  
> > > >  	if (mem_cgroup_disabled())
> > > >  		return;
> > > >  	if (!ptr)
> > > >  		return;
> > > > -	pc = lookup_page_cgroup(page);
> > > > -	mem_cgroup_lru_del_before_commit_swapcache(page);
> > > > -	__mem_cgroup_commit_charge(ptr, pc, MEM_CGROUP_CHARGE_TYPE_MAPPED);
> > > > -	mem_cgroup_lru_add_after_commit_swapcache(page);
> > > > +
> > > > +	/*
> > > > +	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
> > > > +	 * is guarded by lock_page() because the page is SwapCache.
> > > > +	 * If this pc is on orphan LRU, it is also removed from orphan LRU here.
> > > > +	 */
> > > > +	if (!PageCgroupUsed(pc)) {
> > > > +		locked = 1;
> > > > +		spin_lock_irqsave(&zone->lru_lock, flags);
> > > > +		mem_cgroup_del_lru_list(page, page_lru(page));
> > > > +	}
> > > Maybe nice. I tried to use lock_page_cgroup() in add_list but I can't ;(
> > > I think this works well. But I wonder...why you have to check PageCgroupUsed() ?
> > > And is it correct ? Removing PageCgroupUsed() bit check is nice.
> > > (This will be "usually returns true" check, anyway)
> > > 
> > I've just copied lru_del_before_commit_swapcache.
> > 
> ya, considering now, it seems to be silly quick-hack.
> 
> > As you say, this check will return false only in (C) case in memcg_test.txt,
> > and even in (C) case calling mem_cgroup_del_lru_list(and mem_cgroup_add_lru_list later)
> > would be no problem.
> > 
> > OK, I'll remove this check.
> > 
> Thanks,
> 
> > This is the updated version(w/o cache_charge cleanup).
> > 
> > BTW, Should I merge reclaim part based on your patch and post it ?
> > 
> I think not necessary. keeping changes minimum is important as BUGFIX.
> We can visit here again when new -RC stage starts.
> 
> no problem from my review.
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
Just FYI, this version of orphan list framework works fine
w/o causing BUG more than 24h.

So, I believe we can implement reclaim part based on this
to fix the original problem.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
