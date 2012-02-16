Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id 14B2C6B007E
	for <linux-mm@kvack.org>; Thu, 16 Feb 2012 18:56:00 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 27B343EE0BC
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 08:55:58 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0B62F45DE9E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 08:55:58 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA0D845DE7E
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 08:55:57 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id DD6261DB803B
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 08:55:57 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 903EE1DB8038
	for <linux-mm@kvack.org>; Fri, 17 Feb 2012 08:55:57 +0900 (JST)
Date: Fri, 17 Feb 2012 08:54:31 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH RFC 00/15] mm: memory book keeping and lru_lock
 splitting
Message-Id: <20120217085431.80daa020.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4F3CE243.9050203@openvz.org>
References: <20120215224221.22050.80605.stgit@zurg>
	<20120216110408.f35c3448.kamezawa.hiroyu@jp.fujitsu.com>
	<4F3C9798.7050800@openvz.org>
	<20120216172409.5fa18608.kamezawa.hiroyu@jp.fujitsu.com>
	<4F3CE243.9050203@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Hugh Dickins <hughd@google.com>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Thu, 16 Feb 2012 15:02:27 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> KAMEZAWA Hiroyuki wrote:
> > On Thu, 16 Feb 2012 09:43:52 +0400
> > Konstantin Khlebnikov<khlebnikov@openvz.org>  wrote:
> >
> >> KAMEZAWA Hiroyuki wrote:
> >>> On Thu, 16 Feb 2012 02:57:04 +0400
> >>> Konstantin Khlebnikov<khlebnikov@openvz.org>   wrote:
> >
> >>>> * optimize page to book translations, move it upper in the call stack,
> >>>>     replace some struct zone arguments with struct book pointer.
> >>>>
> >>>
> >>> a page->book transrater from patch 2/15
> >>>
> >>> +struct book *page_book(struct page *page)
> >>> +{
> >>> +	struct mem_cgroup_per_zone *mz;
> >>> +	struct page_cgroup *pc;
> >>> +
> >>> +	if (mem_cgroup_disabled())
> >>> +		return&page_zone(page)->book;
> >>> +
> >>> +	pc = lookup_page_cgroup(page);
> >>> +	if (!PageCgroupUsed(pc))
> >>> +		return&page_zone(page)->book;
> >>> +	/* Ensure pc->mem_cgroup is visible after reading PCG_USED. */
> >>> +	smp_rmb();
> >>> +	mz = mem_cgroup_zoneinfo(pc->mem_cgroup,
> >>> +			page_to_nid(page), page_zonenum(page));
> >>> +	return&mz->book;
> >>> +}
> >>>
> >>> What happens when pc->mem_cgroup is rewritten by move_account() ?
> >>> Where is the guard for lockless access of this ?
> >>
> >> Initially this suppose to be protected with lru_lock, in final patch they are protected with rcu.
> >
> > Hmm, VM_BUG_ON(!PageLRU(page)) ?
> 
> Where?
> 

You said this is guarded by lru_lock. So, page should be on LRU.



> >
> > move_account() overwrites pc->mem_cgroup with isolating page from LRU.
> > but it doesn't take lru_lock.
> 
> There three kinds of lock_page_book() users:
> 1) caller want to catch page in LRU, it will lock either old or new book and
>     recheck PageLRU() after locking, if page not it in LRU it don't touch anything.
>     some of these functions has stable reference to page, some of them not.
>   [ There actually exist small race, I knew about it, just forget to pick this chunk from old code. See below. ]
> 2) page is isolated by caller, it want to put it back. book link is stable. no problems.
> 3) page-release functions. page-counter is zero. no references -- no problems.
> 
> race for 1)
> 
> catcher					switcher
> 
> 					# isolate
> 					old_book = lock_page_book(page)
> 					ClearPageLRU(page)
> 					unlock_book(old_book)				
> 					# charge
> old_book = lock_page_book(page)		
> 					# switch
> 					page->book = new_book
> 					# putback
> 					lock_book(new_book)
> 					SetPageLRU(page)
> 					unlock_book(new_book)
> if (PageLRU(page))
> 	oops, page actually in new_book
> unlock_book(old_book)
> 
> 
> I'll protect "switch" phase with old_book lru-lock:
> 
In linex-next, pc->mem_cgroup is modified only when Page is on LRU.

When we need to touch "book", if !PageLRU() ?


> lock_book(old_book)
> page->book = new_book
> unlock_book(old_book)
> 
> The other option is recheck in "catcher" page book after PageLRU()
> maybe there exists some other variants.
> 
> > BTW, what amount of perfomance benefit ?
> 
> It depends, but usually lru_lock is very-very hot.
> This lock splitting can be used without cgroups and containers,
> now huge zones can be easily sliced into arbitrary pieces, for example one book per 256Mb.
> 
I personally think reducing lock by pagevec works enough well.
So, want to see perforamance on real machine with real apps.


> 
> According to my experience, one of complicated thing there is how to postpone "book" destroying
> if some its pages are isolated. For example lumpy reclaim and memory compaction isolates pages
> from several books. And they wants to put them back. Currently this can be broken, if someone removes
> cgroup in wrong moment. There appears funny races with three players: catcher, switcher and destroyer.

Thank you for pointing out. Hmm... it can happen ? Currently, at cgroup destroying,
force_empty() works 

  1. find a page from LRU
  2. remove it from LRU
  3. move it or reclaim it (you said "switcher")
  4. if res.usage != 0 goto 1.

I think "4" will finally keep cgroup from being destroyed.


> This can be fixed with some extra reference-counting or some other sleepable synchronizing.
> In my rhel6-based implementation I uses extra reference-counting, and it looks ugly. So I want to invent something better.
> Other option is just never release books, reuse them after rcu grace period for rcu-list iterating.
> 

Another reference counting is very very bad.



Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
