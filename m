Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 00B5C6B0047
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 19:54:51 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2ANsnNF002732
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 11 Mar 2009 08:54:49 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 13E7F45DD80
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C6D7645DD7B
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81A57E0800A
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14CADE08004
	for <linux-mm@kvack.org>; Wed, 11 Mar 2009 08:54:48 +0900 (JST)
Date: Wed, 11 Mar 2009 08:53:26 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: charge swapcache to proper memcg
Message-Id: <20090311085326.403a211d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090310160856.77deb5c3.akpm@linux-foundation.org>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
	<20090310160856.77deb5c3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, lizf@cn.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Tue, 10 Mar 2009 16:08:56 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 10 Mar 2009 10:07:07 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -909,13 +909,24 @@ nomem:
> >  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  {
> >  	struct mem_cgroup *mem;
> > +	struct page_cgroup *pc;
> >  	swp_entry_t ent;
> >  
> > +	VM_BUG_ON(!PageLocked(page));
> > +
> >  	if (!PageSwapCache(page))
> >  		return NULL;
> >  
> > -	ent.val = page_private(page);
> > -	mem = lookup_swap_cgroup(ent);
> > +	pc = lookup_page_cgroup(page);
> > +	/*
> > +	 * Used bit of swapcache is solid under page lock.
> > +	 */
> > +	if (PageCgroupUsed(pc))
> > +		mem = pc->mem_cgroup;
> > +	else {
> > +		ent.val = page_private(page);
> > +		mem = lookup_swap_cgroup(ent);
> > +	}
> >  	if (!mem)
> >  		return NULL;
> >  	if (!css_tryget(&mem->css))
> 
> This patch made rather a mess of
> use-css-id-in-swap_cgroup-for-saving-memory-v4.patch.
> 
> I temporarily dropped
> use-css-id-in-swap_cgroup-for-saving-memory-v4.patch.  Could I have a
> fixed version please?
Okay.

> 
> Do we think that this patch
> (memcg-charge-swapcache-to-proper-memcg.patch) shouild be in 2.6.29?
> 
please.

Thanks,
-Kame

> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
