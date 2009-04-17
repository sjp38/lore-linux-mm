Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 514DA5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 03:53:31 -0400 (EDT)
Date: Fri, 17 Apr 2009 16:50:36 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090417155411.76901324.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
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
	<20090324173218.4de33b90.nishimura@mxp.nes.nec.co.jp>
	<20090325085713.6f0b7b74.kamezawa.hiroyu@jp.fujitsu.com>
	<20090417153455.c6fe2ba6.nishimura@mxp.nes.nec.co.jp>
	<20090417155411.76901324.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: nishimura@mxp.nes.nec.co.jp, Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 15:54:11 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> On Fri, 17 Apr 2009 15:34:55 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > I made a patch for reclaiming SwapCache from orphan LRU based on your patch,
> > and have been testing it these days.
> > 
> Good trial! 
> Honestly, I've written a patch to fix this problem in these days but seems to
> be over-kill ;)
> 
> 
> > Major changes from your version:
> > - count the number of orphan pages per zone and make the threshold per zone(4MB).
> > - As for type 2 of orphan SwapCache, they are usually set dirty by add_to_swap.
> >   But try_to_drop_swapcache(__remove_mapping) can't free dirty pages,
> >   so add a check and try_to_free_swap to the end of shrink_page_list.
> > 
> > It seems work fine, no "pseud leak" of SwapCache can be seen.
> > 
> > What do you think ?
> > If it's all right, I'll merge this with the orphan list framework patch
> > and send it to Andrew with other fixes of memcg that I have.
> > 
> I'm sorry but my answer is "please wait". The reason is..
> 
> 1. When global LRU works, the pages will be reclaimed.
> 2. Global LRU will work finally.
> 3. While testing, "stale" swap cache cannot be big amount.
> 
Hmm, I can't understand 2.

If (memsize on system) >> (swapsize on system), global LRU doesn't run
and all the swap space can be used up by these SwapCache.
This means setting mem.limit can use up all the swap space on the system.
I've tested with 50MB size of swap and it can be used up in less than 24h.
I think it's not small.

> But, after "soft limit", the situaion will change.
> 1. Even when global LRU works, page selection is influenced by memcg.
> 2. So, when we implement soft-limit, we need to handle swap-cache.
> 
> Your patch will be necessary finally in near future. But, now, it just
> adds code and cannot be very much help, I think.
> 
> So, my answer is "please wait"
> 
> 
> > @@ -399,19 +403,29 @@ static inline struct orphan_list_zone *orphan_lru(int nid, int zid)
> >  	return  &orphan_list[nid]->zone[zid];
> >  }
> >  
> > -static inline void remove_orphan_list(struct page_cgroup *pc)
> > +static inline void remove_orphan_list(struct page *page, struct page_cgroup *pc)
> >  {
> > +	struct orphan_list_zone *opl;
> > +
> >  	ClearPageCgroupOrphan(pc);
> 
> I wonder lock_page_cgroup() is necessary or not here..
> 
> 
> > +	opl = orphan_lru(page_to_nid(page), page_zonenum(page));
> >  	list_del_init(&pc->lru);
> > +	opl->count--;
> >  }
> >  
> >  static inline void add_orphan_list(struct page *page, struct page_cgroup *pc)
> >  {
> > +	int nid = page_to_nid(page);
> > +	int zid = page_zonenum(page);
> >  	struct orphan_list_zone *opl;
> >  
> >  	SetPageCgroupOrphan(pc);
> 
> here too.
> 
I think PCG_ORPHAN is protected by zone->lru_lock.

Thanks,
Daisuke Nishimura.

> I'm sorry plz give me time. I'd like to new version of post soft-limit patches
> in the next week. I'm sorry for delayed my works.
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
