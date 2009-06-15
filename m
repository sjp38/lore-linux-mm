Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EEA696B004F
	for <linux-mm@kvack.org>; Sun, 14 Jun 2009 22:23:52 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5F2OY6H008176
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 15 Jun 2009 11:24:34 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A55145DE5A
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:24:33 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D637445DE53
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:24:32 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 6C4891DB8040
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:24:32 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id ED6F01DB8043
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 11:24:31 +0900 (JST)
Date: Mon, 15 Jun 2009 11:23:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Low overhead patches for the memory cgroup controller (v4)
Message-Id: <20090615112300.73ef1d8a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090615111817.84123ea1.nishimura@mxp.nes.nec.co.jp>
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
	<20090515181639.GH4451@balbir.in.ibm.com>
	<20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
	<20090531235121.GA6120@balbir.in.ibm.com>
	<20090602085744.2eebf211.kamezawa.hiroyu@jp.fujitsu.com>
	<20090605053107.GF11755@balbir.in.ibm.com>
	<20090614183740.GD23577@balbir.in.ibm.com>
	<20090615111817.84123ea1.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: balbir@linux.vnet.ibm.com, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Jun 2009 11:18:17 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Mon, 15 Jun 2009 00:07:40 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > Here is v4 of the patches, please review and comment
> > 
> > Feature: Remove the overhead associated with the root cgroup
> > 
> > From: Balbir Singh <balbir@linux.vnet.ibm.com>
> > 
> > changelog v4 -> v3
> > 1. Rebase to mmotm 9th june 2009
> > 2. Remove PageCgroupRoot, we have account LRU flags to indicate that
> >    we do only accounting and no reclaim.
> hmm, I prefer the previous version of PCG_ACCT_LRU meaning. It can be
> used to remove annoying list_empty(&pc->lru) and !pc->mem_cgroup checks.
> 
> > 3. pcg_default_flags has been used again, since PCGF_ROOT is gone,
> >    we set PCGF_ACCT_LRU only in mem_cgroup_add_lru_list
> It might be safe, but I don't think it's a good idea to touch PCGF_ACCT_LRU
> outside of zone->lru_lock.
> 
> IMHO, the most complicated case is a SwapCache which has been read ahead by
> a *different* cpu from the cpu doing do_swap_page(). Those SwapCache can be
> on page_vec and be drained to LRU asymmetrically with do_swap_page().
> Well, yes it would be safe just because PCGF_ACCT_LRU would not be set
> if PCGF_USED has not been set, but I don't think it's a good idea to touch
> PCGF_ACCT_LRU outside of zone->lru_lock anyway.
> 
> 
> Doesn't a patch like below work for you ?
> Lightly tested under global memory pressure(w/o memcg's memory pressure)
> on a small machine(just a bit modified from then though).
> 
This patch includes almost all what I want ;)

Thanks,
-Kame


> ===
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  include/linux/page_cgroup.h |   13 ++++++++++
>  mm/memcontrol.c             |   54 +++++++++++++++++++++++++++++++-----------
>  2 files changed, 53 insertions(+), 14 deletions(-)
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 7339c7b..debd8ba 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -26,6 +26,7 @@ enum {
>  	PCG_LOCK,  /* page cgroup is locked */
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
> +	PCG_ACCT_LRU, /* page has been accounted for */
>  };
>  
>  #define TESTPCGFLAG(uname, lname)			\
> @@ -40,11 +41,23 @@ static inline void SetPageCgroup##uname(struct page_cgroup *pc)\
>  static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
>  	{ clear_bit(PCG_##lname, &pc->flags);  }
>  
> +#define TESTCLEARPCGFLAG(uname, lname)			\
> +static inline int TestClearPageCgroup##uname(struct page_cgroup *pc)	\
> +	{ return test_and_clear_bit(PCG_##lname, &pc->flags);  }
> +
>  /* Cache flag is set only once (at allocation) */
>  TESTPCGFLAG(Cache, CACHE)
> +CLEARPCGFLAG(Cache, CACHE)
> +SETPCGFLAG(Cache, CACHE)
>  
>  TESTPCGFLAG(Used, USED)
>  CLEARPCGFLAG(Used, USED)
> +SETPCGFLAG(Used, USED)
> +
> +SETPCGFLAG(AcctLRU, ACCT_LRU)
> +CLEARPCGFLAG(AcctLRU, ACCT_LRU)
> +TESTPCGFLAG(AcctLRU, ACCT_LRU)
> +TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
>  
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index dbece65..820f3e6 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -43,6 +43,7 @@
>  
>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
> +struct mem_cgroup *root_mem_cgroup __read_mostly;
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
> @@ -200,13 +201,8 @@ enum charge_type {
>  #define PCGF_CACHE	(1UL << PCG_CACHE)
>  #define PCGF_USED	(1UL << PCG_USED)
>  #define PCGF_LOCK	(1UL << PCG_LOCK)
> -static const unsigned long
> -pcg_default_flags[NR_CHARGE_TYPE] = {
> -	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* File Cache */
> -	PCGF_USED | PCGF_LOCK, /* Anon */
> -	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* Shmem */
> -	0, /* FORCE */
> -};
> +/* Not used, but added here for completeness */
> +#define PCGF_ACCT	(1UL << PCG_ACCT)
>  
>  /* for encoding cft->private value on file */
>  #define _MEM			(0)
> @@ -354,6 +350,11 @@ static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
>  	return ret;
>  }
>  
> +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> +{
> +	return (mem == root_mem_cgroup);
> +}
> +
>  /*
>   * Following LRU functions are allowed to be used without PCG_LOCK.
>   * Operations are called by routine of global LRU independently from memcg.
> @@ -371,22 +372,24 @@ static int mem_cgroup_walk_tree(struct mem_cgroup *root, void *data,
>  void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  {
>  	struct page_cgroup *pc;
> -	struct mem_cgroup *mem;
>  	struct mem_cgroup_per_zone *mz;
>  
>  	if (mem_cgroup_disabled())
>  		return;
>  	pc = lookup_page_cgroup(page);
>  	/* can happen while we handle swapcache. */
> -	if (list_empty(&pc->lru) || !pc->mem_cgroup)
> +	if (!TestClearPageCgroupAcctLRU(pc))
>  		return;
> +	VM_BUG_ON(!pc->mem_cgroup);
>  	/*
>  	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
>  	 * removed from global LRU.
>  	 */
>  	mz = page_cgroup_zoneinfo(pc);
> -	mem = pc->mem_cgroup;
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> +	if (mem_cgroup_is_root(pc->mem_cgroup))
> +		return;
> +	VM_BUG_ON(list_empty(&pc->lru));
>  	list_del_init(&pc->lru);
>  	return;
>  }
> @@ -410,8 +413,8 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
>  	 */
>  	smp_rmb();
> -	/* unused page is not rotated. */
> -	if (!PageCgroupUsed(pc))
> +	/* unused or root page is not rotated. */
> +	if (!PageCgroupUsed(pc) || PageCgroupAcctLRU(pc))
>  		return;
>  	mz = page_cgroup_zoneinfo(pc);
>  	list_move(&pc->lru, &mz->lists[lru]);
> @@ -425,6 +428,7 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  	if (mem_cgroup_disabled())
>  		return;
>  	pc = lookup_page_cgroup(page);
> +	VM_BUG_ON(PageCgroupAcctLRU(pc));
>  	/*
>  	 * Used bit is set without atomic ops but after smp_wmb().
>  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> @@ -435,6 +439,9 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  
>  	mz = page_cgroup_zoneinfo(pc);
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> +	SetPageCgroupAcctLRU(pc);
> +	if (mem_cgroup_is_root(pc->mem_cgroup))
> +		return;
>  	list_add(&pc->lru, &mz->lists[lru]);
>  }
>  
> @@ -469,7 +476,7 @@ static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
>  
>  	spin_lock_irqsave(&zone->lru_lock, flags);
>  	/* link when the page is linked to LRU but page_cgroup isn't */
> -	if (PageLRU(page) && list_empty(&pc->lru))
> +	if (PageLRU(page) && !PageCgroupAcctLRU(pc))
>  		mem_cgroup_add_lru_list(page, page_lru(page));
>  	spin_unlock_irqrestore(&zone->lru_lock, flags);
>  }
> @@ -1106,9 +1113,22 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
>  		css_put(&mem->css);
>  		return;
>  	}
> +
>  	pc->mem_cgroup = mem;
>  	smp_wmb();
> -	pc->flags = pcg_default_flags[ctype];
> +	switch (ctype) {
> +	case MEM_CGROUP_CHARGE_TYPE_CACHE:
> +	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
> +		SetPageCgroupCache(pc);
> +		SetPageCgroupUsed(pc);
> +		break;
> +	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
> +		ClearPageCgroupCache(pc);
> +		SetPageCgroupUsed(pc);
> +		break;
> +	default:
> +		break;
> +	}
>  
>  	mem_cgroup_charge_statistics(mem, pc, true);
>  
> @@ -2047,6 +2067,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  	name = MEMFILE_ATTR(cft->private);
>  	switch (name) {
>  	case RES_LIMIT:
> +		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
> +			ret = -EINVAL;
> +			break;
> +		}
>  		/* This function does all necessary parse...reuse it */
>  		ret = res_counter_memparse_write_strategy(buffer, &val);
>  		if (ret)
> @@ -2513,6 +2537,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
>  		parent = NULL;
> +		root_mem_cgroup = mem;
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
> @@ -2541,6 +2566,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> +	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
>  
>  
> ===
> 
> 
> Thanks,
> Daisuke Nishimura.
> 
> > 4. More LRU functions are aware of PageCgroupAcctLRU
> > 
> > Changelog v3 -> v2
> > 
> > 1. Rebase to mmotm 2nd June 2009
> > 2. Test with some of the test cases recommended by Daisuke-San
> > 
> > Changelog v2 -> v1
> > 1. Rebase to latest mmotm
> > 
> > This patch changes the memory cgroup and removes the overhead associated
> > with accounting all pages in the root cgroup. As a side-effect, we can
> > no longer set a memory hard limit in the root cgroup.
> > 
> > A new flag to track whether the page has been accounted or not
> > has been added as well. Flags are now set atomically for page_cgroup,
> > 
> > Tests:
> > 
> > Results (for v2)
> > 
> > Obtained by
> > 
> > 1. Using tmpfs for mounting filesystem
> > 2. Changing sync to be /bin/true (so that sync is not the bottleneck)
> > 3. Used -s #cpus*40 -e #cpus*40
> > 
> > Reaim
> > 		withoutpatch	patch
> > AIM9		9532.48		9807.59
> > dbase		19344.60	19285.71
> > new_dbase	20101.65	20163.13
> > shared		11827.77	11886.65
> > compute		17317.38	17420.05
> > 
> > Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> > ---
> > 
> >  include/linux/page_cgroup.h |    5 ++++
> >  mm/memcontrol.c             |   59 ++++++++++++++++++++++++++++++++++++-------
> >  2 files changed, 54 insertions(+), 10 deletions(-)
> > 
> > 
> > diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> > index 7339c7b..57c4d50 100644
> > --- a/include/linux/page_cgroup.h
> > +++ b/include/linux/page_cgroup.h
> > @@ -26,6 +26,7 @@ enum {
> >  	PCG_LOCK,  /* page cgroup is locked */
> >  	PCG_CACHE, /* charged as cache */
> >  	PCG_USED, /* this object is in use. */
> > +	PCG_ACCT_LRU, /* page has been accounted for */
> >  };
> >  
> >  #define TESTPCGFLAG(uname, lname)			\
> > @@ -46,6 +47,10 @@ TESTPCGFLAG(Cache, CACHE)
> >  TESTPCGFLAG(Used, USED)
> >  CLEARPCGFLAG(Used, USED)
> >  
> > +SETPCGFLAG(AcctLRU, ACCT_LRU)
> > +CLEARPCGFLAG(AcctLRU, ACCT_LRU)
> > +TESTPCGFLAG(AcctLRU, ACCT_LRU)
> > +
> >  static inline int page_cgroup_nid(struct page_cgroup *pc)
> >  {
> >  	return page_to_nid(pc->page);
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 6ceb6f2..399d416 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -43,6 +43,7 @@
> >  
> >  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
> >  #define MEM_CGROUP_RECLAIM_RETRIES	5
> > +struct mem_cgroup *root_mem_cgroup __read_mostly;
> >  
> >  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
> >  /* Turned on only when memory cgroup is enabled && really_do_swap_account = 1 */
> > @@ -219,6 +220,11 @@ static void mem_cgroup_get(struct mem_cgroup *mem);
> >  static void mem_cgroup_put(struct mem_cgroup *mem);
> >  static struct mem_cgroup *parent_mem_cgroup(struct mem_cgroup *mem);
> >  
> > +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> > +{
> > +	return (mem == root_mem_cgroup);
> > +}
> > +
> >  static void mem_cgroup_charge_statistics(struct mem_cgroup *mem,
> >  					 struct page_cgroup *pc,
> >  					 bool charge)
> > @@ -378,15 +384,25 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
> >  		return;
> >  	pc = lookup_page_cgroup(page);
> >  	/* can happen while we handle swapcache. */
> > -	if (list_empty(&pc->lru) || !pc->mem_cgroup)
> > +	mem = pc->mem_cgroup;
> > +	if (!mem)
> > +		return;
> > +	if (mem_cgroup_is_root(mem)) {
> > +		if (!PageCgroupAcctLRU(pc))
> > +			return;
> > +	} else if (list_empty(&pc->lru))
> >  		return;
> > +
> >  	/*
> >  	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
> >  	 * removed from global LRU.
> >  	 */
> >  	mz = page_cgroup_zoneinfo(pc);
> > -	mem = pc->mem_cgroup;
> >  	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> > +	if (PageCgroupAcctLRU(pc)) {
> > +		ClearPageCgroupAcctLRU(pc);
> > +		return;
> > +	}
> >  	list_del_init(&pc->lru);
> >  	return;
> >  }
> > @@ -410,8 +426,8 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
> >  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
> >  	 */
> >  	smp_rmb();
> > -	/* unused page is not rotated. */
> > -	if (!PageCgroupUsed(pc))
> > +	/* unused or root page is not rotated. */
> > +	if (!PageCgroupUsed(pc) || PageCgroupAcctLRU(pc))
> >  		return;
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	list_move(&pc->lru, &mz->lists[lru]);
> > @@ -435,6 +451,10 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
> >  
> >  	mz = page_cgroup_zoneinfo(pc);
> >  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> > +	if (mem_cgroup_is_root(pc->mem_cgroup)) {
> > +		SetPageCgroupAcctLRU(pc);
> > +		return;
> > +	}
> >  	list_add(&pc->lru, &mz->lists[lru]);
> >  }
> >  
> > @@ -445,12 +465,15 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
> >   * it again. This function is only used to charge SwapCache. It's done under
> >   * lock_page and expected that zone->lru_lock is never held.
> >   */
> > -static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
> > +static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page,
> > +							struct page_cgroup *pc)
> >  {
> >  	unsigned long flags;
> >  	struct zone *zone = page_zone(page);
> > -	struct page_cgroup *pc = lookup_page_cgroup(page);
> >  
> > +	if (!pc->mem_cgroup ||
> > +		(!PageCgroupAcctLRU(pc) && mem_cgroup_is_root(pc->mem_cgroup)))
> > +		return;
> >  	spin_lock_irqsave(&zone->lru_lock, flags);
> >  	/*
> >  	 * Forget old LRU when this page_cgroup is *not* used. This Used bit
> > @@ -461,12 +484,15 @@ static void mem_cgroup_lru_del_before_commit_swapcache(struct page *page)
> >  	spin_unlock_irqrestore(&zone->lru_lock, flags);
> >  }
> >  
> > -static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
> > +static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page,
> > +							struct page_cgroup *pc)
> >  {
> >  	unsigned long flags;
> >  	struct zone *zone = page_zone(page);
> > -	struct page_cgroup *pc = lookup_page_cgroup(page);
> >  
> > +	if (!pc->mem_cgroup ||
> > +		(!PageCgroupAcctLRU(pc) && mem_cgroup_is_root(pc->mem_cgroup)))
> > +		return;
> >  	spin_lock_irqsave(&zone->lru_lock, flags);
> >  	/* link when the page is linked to LRU but page_cgroup isn't */
> >  	if (PageLRU(page) && list_empty(&pc->lru))
> > @@ -478,8 +504,13 @@ static void mem_cgroup_lru_add_after_commit_swapcache(struct page *page)
> >  void mem_cgroup_move_lists(struct page *page,
> >  			   enum lru_list from, enum lru_list to)
> >  {
> > +	struct page_cgroup *pc = lookup_page_cgroup(page);
> >  	if (mem_cgroup_disabled())
> >  		return;
> > +	smp_rmb();
> > +	if (!pc->mem_cgroup ||
> > +		(!PageCgroupAcctLRU(pc) && mem_cgroup_is_root(pc->mem_cgroup)))
> > +		return;
> >  	mem_cgroup_del_lru_list(page, from);
> >  	mem_cgroup_add_lru_list(page, to);
> >  }
> > @@ -1114,6 +1145,7 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
> >  		css_put(&mem->css);
> >  		return;
> >  	}
> > +
> >  	pc->mem_cgroup = mem;
> >  	smp_wmb();
> >  	pc->flags = pcg_default_flags[ctype];
> > @@ -1418,9 +1450,10 @@ __mem_cgroup_commit_charge_swapin(struct page *page, struct mem_cgroup *ptr,
> >  	if (!ptr)
> >  		return;
> >  	pc = lookup_page_cgroup(page);
> > -	mem_cgroup_lru_del_before_commit_swapcache(page);
> > +	smp_rmb();
> > +	mem_cgroup_lru_del_before_commit_swapcache(page, pc);
> >  	__mem_cgroup_commit_charge(ptr, pc, ctype);
> > -	mem_cgroup_lru_add_after_commit_swapcache(page);
> > +	mem_cgroup_lru_add_after_commit_swapcache(page, pc);
> >  	/*
> >  	 * Now swap is on-memory. This means this page may be
> >  	 * counted both as mem and swap....double count.
> > @@ -2055,6 +2088,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
> >  	name = MEMFILE_ATTR(cft->private);
> >  	switch (name) {
> >  	case RES_LIMIT:
> > +		if (mem_cgroup_is_root(memcg)) { /* Can't set limit on root */
> > +			ret = -EINVAL;
> > +			break;
> > +		}
> >  		/* This function does all necessary parse...reuse it */
> >  		ret = res_counter_memparse_write_strategy(buffer, &val);
> >  		if (ret)
> > @@ -2521,6 +2558,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	if (cont->parent == NULL) {
> >  		enable_swap_cgroup();
> >  		parent = NULL;
> > +		root_mem_cgroup = mem;
> >  	} else {
> >  		parent = mem_cgroup_from_cont(cont->parent);
> >  		mem->use_hierarchy = parent->use_hierarchy;
> > @@ -2549,6 +2587,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
> >  	return &mem->css;
> >  free_out:
> >  	__mem_cgroup_free(mem);
> > +	root_mem_cgroup = NULL;
> >  	return ERR_PTR(error);
> >  }
> >  
> > 
> > -- 
> > 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
