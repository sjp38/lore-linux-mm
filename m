Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E39C5F0001
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 04:12:28 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3H8Cbnf016512
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 17 Apr 2009 17:12:37 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DDD045DE54
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 17:12:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 00CB445DE52
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 17:12:37 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EA3DD1DB8044
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 17:12:36 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 982D0E18002
	for <linux-mm@kvack.org>; Fri, 17 Apr 2009 17:12:36 +0900 (JST)
Date: Fri, 17 Apr 2009 17:11:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] fix unused/stale swap cache handling on memcg  v3
Message-Id: <20090417171106.7d3a6ce9.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
References: <20090317135702.4222e62e.nishimura@mxp.nes.nec.co.jp>
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
	<20090417165036.bdca7163.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Apr 2009 16:50:36 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> > > +	opl = orphan_lru(page_to_nid(page), page_zonenum(page));
> > >  	list_del_init(&pc->lru);
> > > +	opl->count--;
> > >  }
> > >  
> > >  static inline void add_orphan_list(struct page *page, struct page_cgroup *pc)
> > >  {
> > > +	int nid = page_to_nid(page);
> > > +	int zid = page_zonenum(page);
> > >  	struct orphan_list_zone *opl;
> > >  
> > >  	SetPageCgroupOrphan(pc);
> > 
> > here too.
> > 
> I think PCG_ORPHAN is protected by zone->lru_lock.
> 

There is different condition for swap caches from file-cache/anonymous pages.

File Cache and Anon pages are marked as USED before the first call of add_to_lru.
So, commit_charge_swapin()'s following code never breaks page_cgroup->flags.

 948         pc->mem_cgroup = mem;
 949         smp_wmb();
 950         pc->flags = pcg_default_flags[ctype];

Then, pc->flags can be broken.

please notice that

  43 /* Cache flag is set only once (at allocation) */
  44 TESTPCGFLAG(Cache, CACHE)
  45 
  46 TESTPCGFLAG(Used, USED)
  47 CLEARPCGFLAG(Used, USED)

ClearPageCgroupUsed() is only operation which modifes page_cgroup->flags,
but it's done under lock.

If you want to avoid lock_page_cgroup(), please rewrite commit_charge_swapin to do

    SetPageCgroupUsed(pc);
    SetPageCgroupCache(pc);
    ....
    or
   atomic_cmpxchg(&pc->flags, oldval, pcg_dafaule_flags[ctype]);

or some.

I'd like to divide lock bit and flags bit etc.. but cannot find a way to do it.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
