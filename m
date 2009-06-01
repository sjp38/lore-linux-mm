Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 05EF86B008A
	for <linux-mm@kvack.org>; Mon,  1 Jun 2009 00:38:41 -0400 (EDT)
Date: Mon, 1 Jun 2009 13:25:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC] Low overhead patches for the memory cgroup controller
 (v2)
Message-Id: <20090601132505.2fe9c870.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090517041543.GA5156@balbir.in.ibm.com>
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
	<20090517041543.GA5156@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

I'm sorry for my very late reply.

I've been working on the stale swap cache problem for a long time as you know :)

On Sun, 17 May 2009 12:15:43 +0800, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-05-16 02:45:03]:
> 
> > I think set/clear flag here adds race condtion....because pc->flags is
> > modfied by
> >   pc->flags = pcg_dafault_flags[ctype] in commit_charge()
> > you have to modify above lines to be
> > 
> >   SetPageCgroupCache(pc) or some..
> >   ...
> >   SetPageCgroupUsed(pc)
> > 
> > Then, you can use set_bit() without lock_page_cgroup().
> > (Currently, pc->flags is modified only under lock_page_cgroup(), so,
> >  non atomic code is used.)
> >
> 
> Here is the next version of the patch
> 
> 
> Feature: Remove the overhead associated with the root cgroup
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> This patch changes the memory cgroup and removes the overhead associated
> with accounting all pages in the root cgroup. As a side-effect, we can
> no longer set a memory hard limit in the root cgroup.
> 
I agree to this idea itself.

> A new flag is used to track page_cgroup associated with the root cgroup
> pages. A new flag to track whether the page has been accounted or not
> has been added as well. Flags are now set atomically for page_cgroup,
> pcg_default_flags is now obsolete, but I've not removed it yet. It
> provides some readability to help the code.
> 
> Tests:
> 1. Tested lightly, previous versions showed good performance improvement 10%.
> 
You should test current version :)
And I think you should test this patch under global memory pressure too
to check whether it doesn't cause bug or under/over flow of something, etc.
memcg's LRU handling about SwapCache is different from usual one.

> NOTE:
> I haven't got the time right now to run oprofile and get detailed test results,
> since I am in the middle of travel.
> 
> Please review the code for functional correctness and if you can test
> it even better. I would like to push this in, especially if the %
> performance difference I am seeing is reproducible elsewhere as well.
> 
> Signed-off-by: Balbir Singh <balbir@linux.vnet.ibm.com>
> ---
> 
>  include/linux/page_cgroup.h |   12 ++++++++++++
>  mm/memcontrol.c             |   42 ++++++++++++++++++++++++++++++++++++++----
>  mm/page_cgroup.c            |    1 -
>  3 files changed, 50 insertions(+), 5 deletions(-)
> 
> 
> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
> index 7339c7b..ebdae9a 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -26,6 +26,8 @@ enum {
>  	PCG_LOCK,  /* page cgroup is locked */
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
> +	PCG_ROOT, /* page belongs to root cgroup */
> +	PCG_ACCT, /* page has been accounted for */
>  };
>  
Those new flags are protected by zone->lru_lock, right ?
If so, please add some comments.
And I'm not sure why you need 2 flags. Isn't PCG_ROOT enough for you ?

>  #define TESTPCGFLAG(uname, lname)			\
> @@ -42,9 +44,19 @@ static inline void ClearPageCgroup##uname(struct page_cgroup *pc)	\
>  
>  /* Cache flag is set only once (at allocation) */
>  TESTPCGFLAG(Cache, CACHE)
> +SETPCGFLAG(Cache, CACHE)
>  
>  TESTPCGFLAG(Used, USED)
>  CLEARPCGFLAG(Used, USED)
> +SETPCGFLAG(Used, USED)
> +
> +SETPCGFLAG(Root, ROOT)
> +CLEARPCGFLAG(Root, ROOT)
> +TESTPCGFLAG(Root, ROOT)
> +
> +SETPCGFLAG(Acct, ACCT)
> +CLEARPCGFLAG(Acct, ACCT)
> +TESTPCGFLAG(Acct, ACCT)
>  
>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 9712ef7..35415fc 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -43,6 +43,7 @@
>  
>  struct cgroup_subsys mem_cgroup_subsys __read_mostly;
>  #define MEM_CGROUP_RECLAIM_RETRIES	5
> +struct mem_cgroup *root_mem_cgroup __read_mostly;
>  
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  /* Turned on only when memory cgroup is enabled && really_do_swap_account = 0 */
> @@ -196,6 +197,10 @@ enum charge_type {
>  #define PCGF_CACHE	(1UL << PCG_CACHE)
>  #define PCGF_USED	(1UL << PCG_USED)
>  #define PCGF_LOCK	(1UL << PCG_LOCK)
> +/* Not used, but added here for completeness */
> +#define PCGF_ROOT	(1UL << PCG_ROOT)
> +#define PCGF_ACCT	(1UL << PCG_ACCT)
> +
>  static const unsigned long
>  pcg_default_flags[NR_CHARGE_TYPE] = {
>  	PCGF_CACHE | PCGF_USED | PCGF_LOCK, /* File Cache */
> @@ -420,7 +425,7 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  		return;
>  	pc = lookup_page_cgroup(page);
>  	/* can happen while we handle swapcache. */
> -	if (list_empty(&pc->lru) || !pc->mem_cgroup)
> +	if ((!PageCgroupAcct(pc) && list_empty(&pc->lru)) || !pc->mem_cgroup)
>  		return;
>  	/*
>  	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
> @@ -429,6 +434,9 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  	mz = page_cgroup_zoneinfo(pc);
>  	mem = pc->mem_cgroup;
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> +	ClearPageCgroupAcct(pc);
> +	if (PageCgroupRoot(pc))
> +		return;
>  	list_del_init(&pc->lru);
>  	return;
>  }
> @@ -452,8 +460,8 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
>  	 * For making pc->mem_cgroup visible, insert smp_rmb() here.
>  	 */
>  	smp_rmb();
> -	/* unused page is not rotated. */
> -	if (!PageCgroupUsed(pc))
> +	/* unused or root page is not rotated. */
> +	if (!PageCgroupUsed(pc) || PageCgroupRoot(pc))
>  		return;
>  	mz = page_cgroup_zoneinfo(pc);
>  	list_move(&pc->lru, &mz->lists[lru]);
> @@ -477,6 +485,9 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  
>  	mz = page_cgroup_zoneinfo(pc);
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> +	SetPageCgroupAcct(pc);
> +	if (PageCgroupRoot(pc))
> +		return;
>  	list_add(&pc->lru, &mz->lists[lru]);
>  }
>  
> @@ -1114,9 +1125,24 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
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
> +		SetPageCgroupUsed(pc);
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	if (mem == root_mem_cgroup)
> +		SetPageCgroupRoot(pc);
>  
>  	mem_cgroup_charge_statistics(mem, pc, true);
>  
Shouldn't we set PCG_LOCK ?
unlock_page_cgroup() will be called after this.

Moreover, IIUC, pc->flags is not cleared at page free/alloc, so if a page
is reused, pc->flags has the old value.
PCG_CACHE flag, at least, is used by the decision in mem_cgroup_charge_statistics().

> @@ -1521,6 +1547,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	mem_cgroup_charge_statistics(mem, pc, false);
>  
>  	ClearPageCgroupUsed(pc);
> +	if (mem == root_mem_cgroup)
> +		ClearPageCgroupRoot(pc);
>  	/*
>  	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
>  	 * freed from LRU. This is safe because uncharged page is expected not
> @@ -2038,6 +2066,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
>  	name = MEMFILE_ATTR(cft->private);
>  	switch (name) {
>  	case RES_LIMIT:
> +		if (memcg == root_mem_cgroup) { /* Can't set limit on root */
> +			ret = -EINVAL;
> +			break;
> +		}
>  		/* This function does all necessary parse...reuse it */
>  		ret = res_counter_memparse_write_strategy(buffer, &val);
>  		if (ret)
It's a nitpick, I prefer not to show *.limit_in_bytes if we cannot write to them.


Thanks,
Daisuke Nishimura.

> @@ -2504,6 +2536,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
>  		parent = NULL;
> +		root_mem_cgroup = mem;
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
> @@ -2532,6 +2565,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> +	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
>  
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 09b73c5..6145ff6 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -276,7 +276,6 @@ void __meminit pgdat_page_cgroup_init(struct pglist_data *pgdat)
>  
>  #endif
>  
> -
>  #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
>  
>  static DEFINE_MUTEX(swap_cgroup_mutex);
>  
> 
> -- 
> 	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
