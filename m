Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D916F6B0047
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:27:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2N0Kq3P016777
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 23 Mar 2009 09:20:52 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B115945DE57
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:20:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C7E545DE50
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:20:51 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 75AA31DB803E
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:20:51 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3056D1DB8042
	for <linux-mm@kvack.org>; Mon, 23 Mar 2009 09:20:51 +0900 (JST)
Date: Mon, 23 Mar 2009 09:19:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH mmotm] memcg: try_get_mem_cgroup_from_swapcache
 fix
Message-Id: <20090323091925.d7a8c1d2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090323091337.0a800858.nishimura@mxp.nes.nec.co.jp>
References: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
	<20090322184015.GE24227@balbir.in.ibm.com>
	<20090323091337.0a800858.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 09:13:37 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 23 Mar 2009 00:10:15 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > * Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-03-23 00:02:38]:
> > 
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > 
> > > css_tryget can be called twice in !PageCgroupUsed case.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > ---
> > > This is a fix for cgroups-use-css-id-in-swap-cgroup-for-saving-memory-v5.patch
> > > 
> > >  mm/memcontrol.c |   10 ++++------
> > >  1 files changed, 4 insertions(+), 6 deletions(-)
> > > 
> > > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > > index 5de6be9..55dea59 100644
> > > --- a/mm/memcontrol.c
> > > +++ b/mm/memcontrol.c
> > > @@ -1027,9 +1027,11 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> > >  	/*
> > >  	 * Used bit of swapcache is solid under page lock.
> > >  	 */
> > > -	if (PageCgroupUsed(pc))
> > > +	if (PageCgroupUsed(pc)) {
> > >  		mem = pc->mem_cgroup;
> > > -	else {
> > > +		if (mem && !css_tryget(&mem->css))
> > > +			mem = NULL;
> > > +	} else {
> > >  		ent.val = page_private(page);
> > >  		id = lookup_swap_cgroup(ent);
> > >  		rcu_read_lock();
> > > @@ -1038,10 +1040,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> > >  			mem = NULL;
> > >  		rcu_read_unlock();
> > >  	}
> > > -	if (!mem)
> > > -		return NULL;
> > > -	if (!css_tryget(&mem->css))
> > > -		return NULL;
> > >  	return mem;
> > >  }
> > 
> > How did you detect the problem? Any test case/steps to reproduce the issue?
> > 
> I found this when rebasing my patch onto mmotm and reviewing it.
> 
> I suppose this bug can leads to an unremovable directory.
> 

I think I saw this in the weekend but couldn't find why ;(
Thank you!
-Kame

> 
> Thanks,
> Daisuke Nishimura.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
