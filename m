Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 222886B004D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 19:23:45 -0400 (EDT)
Date: Mon, 23 Mar 2009 09:13:37 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [BUGFIX][PATCH mmotm] memcg: try_get_mem_cgroup_from_swapcache
 fix
Message-Id: <20090323091337.0a800858.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090322184015.GE24227@balbir.in.ibm.com>
References: <20090323000238.e650c65e.d-nishimura@mtf.biglobe.ne.jp>
	<20090322184015.GE24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: nishimura@mxp.nes.nec.co.jp, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Mar 2009 00:10:15 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> [2009-03-23 00:02:38]:
> 
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > css_tryget can be called twice in !PageCgroupUsed case.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > ---
> > This is a fix for cgroups-use-css-id-in-swap-cgroup-for-saving-memory-v5.patch
> > 
> >  mm/memcontrol.c |   10 ++++------
> >  1 files changed, 4 insertions(+), 6 deletions(-)
> > 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 5de6be9..55dea59 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -1027,9 +1027,11 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  	/*
> >  	 * Used bit of swapcache is solid under page lock.
> >  	 */
> > -	if (PageCgroupUsed(pc))
> > +	if (PageCgroupUsed(pc)) {
> >  		mem = pc->mem_cgroup;
> > -	else {
> > +		if (mem && !css_tryget(&mem->css))
> > +			mem = NULL;
> > +	} else {
> >  		ent.val = page_private(page);
> >  		id = lookup_swap_cgroup(ent);
> >  		rcu_read_lock();
> > @@ -1038,10 +1040,6 @@ static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> >  			mem = NULL;
> >  		rcu_read_unlock();
> >  	}
> > -	if (!mem)
> > -		return NULL;
> > -	if (!css_tryget(&mem->css))
> > -		return NULL;
> >  	return mem;
> >  }
> 
> How did you detect the problem? Any test case/steps to reproduce the issue?
> 
I found this when rebasing my patch onto mmotm and reviewing it.

I suppose this bug can leads to an unremovable directory.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
