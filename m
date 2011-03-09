Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 56C998D0039
	for <linux-mm@kvack.org>; Wed,  9 Mar 2011 18:43:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 64A5F3EE0B5
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:43:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4B8CE45DE4E
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:43:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 313D545DD73
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:43:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1D14C1DB803F
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:43:23 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C121B1DB803A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 08:43:22 +0900 (JST)
Date: Thu, 10 Mar 2011 08:36:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3] memcg: fix leak on wrong LRU with FUSE
Message-Id: <20110310083659.fd8b1c3f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110309100020.GD30778@cmpxchg.org>
References: <20110308135612.e971e1f3.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308181832.6386da5f.nishimura@mxp.nes.nec.co.jp>
	<20110309150750.d570798c.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309164801.3a4c8d10.kamezawa.hiroyu@jp.fujitsu.com>
	<20110309100020.GD30778@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

On Wed, 9 Mar 2011 11:00:20 +0100
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Wed, Mar 09, 2011 at 04:48:01PM +0900, KAMEZAWA Hiroyuki wrote:
> > On Wed, 9 Mar 2011 15:07:50 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > 
> > > > } else {
> > > > 	/* shmem */
> > > > 	if (PageSwapCache(page)) {
> > > > 		..
> > > > 	} else {
> > > > 		..
> > > > 	}
> > > > }
> > > > 
> > > > Otherwise, the page cache will be charged twice.
> > > > 
> > > 
> > > Ahh, thanks. I'll send v3.
> > > 
> > 
> > Okay, this is a fixed one.
> > ==
> > 
> > fs/fuse/dev.c::fuse_try_move_page() does
> > 
> >    (1) remove a page by ->steal()
> >    (2) re-add the page to page cache 
> >    (3) link the page to LRU if it was not on LRU at (1)
> > 
> > This implies the page is _on_ LRU when it's added to radix-tree.
> > So, the page is added to  memory cgroup while it's on LRU.
> > because LRU is lazy and no one flushs it.
> > 
> > This is the same behavior as SwapCache and needs special care as
> >  - remove page from LRU before overwrite pc->mem_cgroup.
> >  - add page to LRU after overwrite pc->mem_cgroup.
> > 
> > And we need to taking care of pagevec.
> > 
> > If PageLRU(page) is set before we add PCG_USED bit, the page
> > will not be added to memcg's LRU (in short period).
> > So, regardlress of PageLRU(page) value before commit_charge(),
> > we need to check PageLRU(page) after commit_charge().
> > 
> > Changelog v2=>v3:
> >   - fixed double accounting.
> > 
> > Changelog v1=>v2:
> >   - clean up.
> >   - cover !PageLRU() by pagevec case.
> > 
> > 
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Thanks for the fix.  I have a few comments below.  Only nitpicks
> though, the patch looks correct to me.
> 
> Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
> 

Thank you for review.


> > @@ -2431,9 +2430,28 @@ static void
> >  __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> >  					enum charge_type ctype);
> >  
> > +static void
> > +__mem_cgroup_commit_charge_lrucare(struct page *page, struct mem_cgroup *mem,
> > +					enum charge_type ctype)
> > +{
> > +	struct page_cgroup *pc = lookup_page_cgroup(page);
> > +	/*
> > +	 * In some case, SwapCache, FUSE(splice_buf->radixtree), the page
> > +	 * is already on LRU. It means the page may on some other page_cgroup's
> > +	 * LRU. Take care of it.
> > +	 */
> > +	if (unlikely(PageLRU(page)))
> > +		mem_cgroup_lru_del_before_commit(page);
> 
> Do we need the extra check?  mem_cgroup_lru_del_before_commit() will
> do the right thing if the page is not on the list.
> 

lru_del_before_commit does checks under zone->lru_lock. So, it's very very heavy.
Hmm, I'll move the check under mem_cgroup_lru_del_before_commit() before lock.


> > +	__mem_cgroup_commit_charge(mem, page, 1, pc, ctype);
> > +	if (unlikely(PageLRU(page)))
> > +		mem_cgroup_lru_add_after_commit(page);
> 
> Same here, mem_cgroup_lru_add_after_commit() has its own check for
> PG_lru.
> 

I'll move the check.


> > @@ -2468,14 +2486,16 @@ int mem_cgroup_cache_charge(struct page 
> >  	if (unlikely(!mm))
> >  		mm = &init_mm;
> >  
> > -	if (page_is_file_cache(page))
> > -		return mem_cgroup_charge_common(page, mm, gfp_mask,
> > -				MEM_CGROUP_CHARGE_TYPE_CACHE);
> > -
> > +	if (page_is_file_cache(page)) {
> > +		ret = __mem_cgroup_try_charge(mm, gfp_mask, 1, &mem, true);
> > +		if (ret || !mem)
> > +			return ret;
> > +		__mem_cgroup_commit_charge_lrucare(page, mem,
> > +					MEM_CGROUP_CHARGE_TYPE_CACHE);
> 
> I think the comment about why we need to take care of the LRU status
> would make more sense here (rather than in the _lrucare function),
> because it is here where you make handling the lru a consequence of
> the page being a file page.
> 
Sure.

> How about this?
> 
> 		/*
> 		 * FUSE reuses pages without going through the final
> 		 * put that would remove them from the LRU list, make
> 		 * sure that they get relinked properly.
> 		 */


will add. Thank you !

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
