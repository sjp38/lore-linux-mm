Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 985C76B003D
	for <linux-mm@kvack.org>; Wed,  1 Apr 2009 05:50:54 -0400 (EDT)
Date: Wed, 1 Apr 2009 11:49:55 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] vmscan: memcg needs may_swap (Re: [patch] vmscan: rename  sc.may_swap to may_unmap)
Message-ID: <20090401094955.GA1656@cmpxchg.org>
References: <28c262360903301826w6429720es8ceb361cfc088b1@mail.gmail.com> <20090331104237.e689f279.kamezawa.hiroyu@jp.fujitsu.com> <20090331104625.B1C7.A69D9226@jp.fujitsu.com> <20090401040951.GA1548@cmpxchg.org> <20090401180445.80b11d90.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090401180445.80b11d90.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Rik van Riel <riel@redhat.com>, Balbir Singh <balbir@in.ibm.com>
List-ID: <linux-mm.kvack.org>

On Wed, Apr 01, 2009 at 06:04:45PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 1 Apr 2009 06:09:51 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Tue, Mar 31, 2009 at 10:48:32AM +0900, KOSAKI Motohiro wrote:
> > > > > Sorry for too late response.
> > > > > I don't know memcg well.
> > > > > 
> > > > > The memcg managed to use may_swap well with global page reclaim until now.
> > > > > I think that was because may_swap can represent both meaning.
> > > > > Do we need each variables really ?
> > > > > 
> > > > > How about using union variable ?
> > > > 
> > > > or Just removing one of them  ?
> > > 
> > > I hope all may_unmap user convert to using may_swap.
> > > may_swap is more efficient and cleaner meaning.
> > 
> > How about making may_swap mean the following:
> > 
> > 	@@ -642,6 +639,8 @@ static unsigned long shrink_page_list(st
> > 	 		 * Try to allocate it some swap space here.
> > 	 		 */
> > 	 		if (PageAnon(page) && !PageSwapCache(page)) {
> > 	+			if (!sc->map_swap)
> > 	+				goto keep_locked;
> > 	 			if (!(sc->gfp_mask & __GFP_IO))
> > 	 				goto keep_locked;
> > 	 			if (!add_to_swap(page))
> > 
> > try_to_free_pages() always sets it.
> > 
> What is the advantage than _not_ scanning ANON LRU at all ?

I thought we could collect anon pages that don't need swap io.

> > try_to_free_mem_cgroup_pages() sets it depending on whether it really
> > wants swapping, and only swapping, right?  But the above would still
> > reclaim already swapped anon pages and I don't know the memory
> > controller.
> > 
> memory cgroup has 2 calls to this shrink_zone.
>  1. memory usage hits the limit.
>  2. mem+swap usage hits the limit.
> 
> At "2", swap-out doesn't decrease the usage of mem+swap, then set may_swap=0.
> So, we want to kick out only file caches.
> But, we can reclaim file cache and "unmap file cache and reclaim it!" is 
> necessary even if may_swap=0.

Yes.

> Then, scanning only FILE LRU makes sense at may_swap=0 *if* memcg is
> the only user of may_swap=0.
> 
> Let's see others.
> 
>  - __zone_reclaim sets may_unmap to be 0 when they don't want swap-out.
>    .....can be replaced with may_swap.
> 
>  - shrink_all_memory sets may_swap to be 0. Is this called by hibernation ?
>    If you don't want to unmap file caches while hibernation, adding may_unmap
>    as *new* paramter makes sense, I think.

Yep, that was my idea too.  At least for now and then reevaluate
whether it shouldn't just reclaim in lru order without this flag...

> The change you proposed is for dropping unused SwapCache pages. Right ?
> But this will be dropped by kswapd if necessary.
> 
> As far as memcg concerns, scanning ANON LRU even when may_swap=0 is just
> a waste of cpu time.

Okay.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
