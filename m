Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C80F38D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 21:12:50 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 02C633EE0BC
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:12:47 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF59A45DE5C
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:12:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 991D745DE56
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:12:46 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 881FEE18001
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:12:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 44EF0E18003
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 11:12:46 +0900 (JST)
Date: Tue, 8 Mar 2011 11:06:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: fix to leave pages on wrong LRU with FUSE.
Message-Id: <20110308110626.caa02b93.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110308110443.47136fc1.nishimura@mxp.nes.nec.co.jp>
References: <20110307150049.d42d046d.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308095939.58100cfd.nishimura@mxp.nes.nec.co.jp>
	<20110308100242.3075e2c7.kamezawa.hiroyu@jp.fujitsu.com>
	<20110308110443.47136fc1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, miklos@szeredi.hu

On Tue, 8 Mar 2011 11:04:43 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 8 Mar 2011 10:02:42 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > On Tue, 8 Mar 2011 09:59:39 +0900
> > Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > 
> > > On Mon, 7 Mar 2011 15:00:49 +0900
> > > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > 
> > > > At this point, I'm not sure this is a fix for 
> > > >    https://bugzilla.kernel.org/show_bug.cgi?id=30432.
> > > > 
> > > > The behavior seems very similar to SwapCache case and this is a possible
> > > > bug and this patch can be a fix. Nishimura-san, how do you think ?
> > > > 
> > > As long as I can read the source code, I also think this is a possible bug.
> > > 
> > > > But I'm not sure how to test this....please review.
> > > > 
> > > > =
> > > > fs/fuse/dev.c::fuse_try_move_page() does
> > > > 
> > > >    (1) remove a page from page cache by ->steal()
> > > >    (2) re-add the page to page cache 
> > > >    (3) link the page to LRU if it was _not_ on LRU at (1)
> > > > 
> > > > 
> > > > This implies the page can be _on_ LRU when add_to_page_cache_locked() is called.
> > > > So, the page is added to a memory cgroup while it's on LRU.
> > > > 
> > > > This is the same behavior as SwapCache, 'newly charged pages may be on LRU'
> > > > and needs special care as
> > > >  - remove page from old memcg's LRU before overwrite pc->mem_cgroup.
> > > >  - add page to new memcg's LRU after overwrite pc->mem_cgroup.
> > > > 
> > > > So, reusing SwapCache code with renaming for fix.
> > > > 
> > > > Note: a page on pagevec(LRU).
> > > > 
> > > > If a page is not PageLRU(page) but on pagevec(LRU), it may be added to LRU
> > > > while we overwrite page->mapping. But in that case, PCG_USED bit of
> > > > the page_cgroup is not set and the page_cgroup will not be added to
> > > > wrong memcg's LRU. So, this patch's logic will work fine.
> > > > (It has been tested with SwapCache.)
> > > > 
> > > As for SwapCache, mem_cgroup_lru_add_after_commit() will be allways called,
> > > and it will link the page to LRU. But, if I read this patch correctly,
> > > a page cache on pagevec may not be added to a *proper* memcg's LRU.
> > > 
> > >       lru_add_drain()           mem_cgroup_cache_charge()
> > >   ----------------------------------------------------------
> > >                                   if (!PageLRU())
> > >     SetPageLRU()
> > >     add_page_to_lru_list()
> > >       mem_cgroup_add_lru_list()
> > >       -> do nothing
> > >                                     mem_cgroup_charge_common()
> > >                                       mem_cgroup_commit_charge()
> > >                                       -> set PCG_USED
> > > 
> > 
> > Hmm, yes, that's possible case.
> > 
> > So, PageLRU() && !PcgAcctLru(pc) should be checked after commit ?
> > 
> I think so, as mem_cgroup_lru_add_after_commit() does.
> 
> > I think we can add optimization later (add per-memcg-lru-pegecgrou-vec or some)
> > 
> In current mmotm, fuse uses replace_page_cache(), which uses mem_cgroup_(prepare|end)_migration(),
> so I think we can handle this problem in a different way instead of changing
> mem_cgroup_cache_charge(), which I think is a fast-path operation.
> 

Hmm, but a fix for 2.6.37 is a problem... _AND_ this kind of breakage by
some code can be happen, again. I think we need a check in this path.
Let's try and see overheads.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
