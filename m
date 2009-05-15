Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 013306B0082
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:16:42 -0400 (EDT)
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e6.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4FIJ3wb003707
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:19:03 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4FIGk6K152074
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:16:46 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4FIGjZ6004154
	for <linux-mm@kvack.org>; Fri, 15 May 2009 14:16:45 -0400
Date: Fri, 15 May 2009 23:46:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC] Low overhead patches for the memory cgroup controller
	(v2)
Message-ID: <20090515181639.GH4451@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-16 02:45:03]:

> Balbir Singh wrote:
> > Feature: Remove the overhead associated with the root cgroup
> >
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> >
> > This patch changes the memory cgroup and removes the overhead associated
> > with LRU maintenance of all pages in the root cgroup. As a side-effect, we
> > can
> > no longer set a memory hard limit in the root cgroup.
> >
> > A new flag is used to track page_cgroup associated with the root cgroup
> > pages. A new flag to track whether the page has been accounted or not
> > has been added as well.
> >
> > Review comments higly appreciated
> >
> > Tests
> >
> > 1. Tested with allocate, touch and limit test case for a non-root cgroup
> > 2. For the root cgroup tested performance impact with reaim
> >
> >
> > 		+patch		mmtom-08-may-2009
> > AIM9		1362.93		1338.17
> > Dbase		17457.75	16021.58
> > New Dbase	18070.18	16518.54
> > Shared		9681.85		8882.11
> > Compute		16197.79	15226.13
> >
> Hmm, at first impression, I can't convice the numbers...
> Just avoiding list_add/del makes programs _10%_ faster ?
> Could you show changes in cpu cache-miss late if you can ?
> (And why Aim9 goes bad ?)

OK... I'll try but I am away on travel for 3 weeks :( you can try and run
this as well

> Hmm, page_cgroup_zoneinfo() is accessed anyway, then...per zone counter
> is not a problem here..
> 
> Could you show your .config and environment ?
> When I trunst above numbers, it seems there is more optimization/
> prefetch point in usual path
> 
> BTW, how the perfomance changes in children(not default) groups ?
> 

I've not seen the impact of that. I'll try.


> > 3. Tested accounting in root cgroup to make sure it looks sane and
> > correct.
> >
> Not sure but swap and shmem case should be checked carefully..
> 
> 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> >
> >  include/linux/page_cgroup.h |   10 ++++++++++
> >  mm/memcontrol.c             |   29 ++++++++++++++++++++++++++---
> >  mm/page_cgroup.c            |    1 -
> >  3 files changed, 36 insertions(+), 4 deletions(-)
> >
> >
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index 7339c7b..8b85752 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -26,6 +26,8 @@ enum {
> >  	PCG_LOCK,  /* page cgroup is locked */
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> > +	PCG_ROOT, /* page belongs to root cgroup */
> > +	PCG_ACCT, /* page has been accounted for */
> Reading codes, this PCG_ACCT should be PCG_AcctLRU.

OK

> 
> >  };
> >
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -46,6 +48,14 @@ TESTPCGFLAG(Cache, CACHE)
> >  TESTPCGFLAG(Used, USED)
> >  CLEARPCGFLAG(Used, USED)
> >
> > +SETPCGFLAG(Root, ROOT)
> > +CLEARPCGFLAG(Root, ROOT)
> > +TESTPCGFLAG(Root, ROOT)
> > +
> > +SETPCGFLAG(Acct, ACCT)
> > +CLEARPCGFLAG(Acct, ACCT)
> > +TESTPCGFLAG(Acct, ACCT)
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 9712ef7..18d2819 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -43,6 +43,7 @@
> >
> >  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> >  #define MEM_CGROUP_RECLAIM_RETRIES	5
> > +struct mem_cgroup *root_mem_cgroup __read_mostly;
> >
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  /* Turned on only when memory cgroup is enabled && really_do_swap_account
> > = 0 */
> > @@ -196,6 +197,10 @@ enum charge_type {
> >  #define PCGF_CACHE	(1UL << PCG_CACHE)
> >  #define PCGF_USED	(1UL << PCG_USED)
> >  #define PCGF_LOCK	(1UL << PCG_LOCK)
> > +/* Not used, but added here for completeness */
> > +#define PCGF_ROOT	(1UL << PCG_ROOT)
> > +#define PCGF_ACCT	(1UL << PCG_ACCT)
> > +
> >  static const unsigned long
> >  pcg_default_flags[NR_CHARGE_TYPE] = {
> >  	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* File Cache */
> > @@ -420,7 +425,7 @@ void mem_cgroup_del_lru_list(struct page *page, enum
> > lru_list lru)
> >  		return;
> >  	pc = lookup_page_cgroup(page);
> >  	/* can happen while we handle swapcache. */
> > -	if (list_empty(&pc->lru) || !pc->mem_cgroup)
> > +	if ((!PageCgroupAcct(pc) && list_empty(&pc->lru)) || !pc->mem_cgroup)
> >  		return;
> >  	/*
> >  	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
> > @@ -429,6 +434,9 @@ void mem_cgroup_del_lru_list(struct page *page, enum
> > lru_list lru)
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	mem = pc->mem_cgroup;
> >  	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> > +	ClearPageCgroupAcct(pc);
> > +	if (PageCgroupRoot(pc))
> > +		return;
> >  	list_del_init(&pc->lru);
> >  	return;
> >  }
> 
> 
> > @@ -452,8 +460,8 @@ void mem_cgroup_rotate_lru_list(struct page *page,
> > enum lru_list lru)
> >  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> >  	 */
> >  	smp_rmb();
> > -	/* unused page is not rotated. */
> > -	if (!PageCgroupUsed(pc))
> > +	/* unused or root page is not rotated. */
> > +	if (!PageCgroupUsed(pc) || PageCgroupRoot(pc))
> >  		return;
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	list_move(&pc->lru, &mz->lists[lru]);
> > @@ -477,6 +485,9 @@ void mem_cgroup_add_lru_list(struct page *page, enum
> > lru_list lru)
> >
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> > +	SetPageCgroupAcct(pc);
> > +	if (PageCgroupRoot(pc))
> > +		return;
> >  	list_add(&pc->lru, &mz->lists[lru]);
> >  }
> I think set/clear flag here adds race condtion....because pc->flags is
> modfied by
>   pc->flags = pcg_dafault_flags[ctype] in commit_charge()
> you have to modify above lines to be
> 
>   SetPageCgroupCache(pc) or some..
>   ...
>   SetPageCgroupUsed(pc)

Good Point

> 
> Then, you can use set_bit() without lock_page_cgroup().
> (Currently, pc->flags is modified only under lock_page_cgroup(), so,
>  non atomic code is used.)

OK.. I wonder if we can say, the _ACCT and _ROOT flags under
zone->lru_lock. I have not seen the locks held under commit_charge
fully, but we could potentially do that. Need some more thinking.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
