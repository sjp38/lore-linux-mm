Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 12A496B0055
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 01:53:15 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n555rDSF018159
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 5 Jun 2009 14:53:13 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id CFFAB45DE7B
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:53:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8B19D45DE6E
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:53:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B6B9E08008
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:53:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 106961DB8040
	for <linux-mm@kvack.org>; Fri,  5 Jun 2009 14:53:12 +0900 (JST)
Date: Fri, 5 Jun 2009 14:51:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Low overhead patches for the memory cgroup controller (v3)
Message-Id: <20090605145141.c9d0f4cf.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090605053107.GF11755@balbir.in.ibm.com>
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com>
	<20090515181639.GH4451@balbir.in.ibm.com>
	<20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com>
	<20090531235121.GA6120@balbir.in.ibm.com>
	<20090602085744.2eebf211.kamezawa.hiroyu@jp.fujitsu.com>
	<20090605053107.GF11755@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

On Fri, 5 Jun 2009 13:31:07 +0800
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Here is the new version of the patch with the RFC dropped. Andrew,
> Kame, could you please take a look. I am just about to fly out to get
> back home tomorrow, so there might be some silence, unless I get to
> the next WiFi enabled airport.
> 
> 
> From: Balbir Singh <balbir@linux.vnet.ibm.com>
> 
> Changelog v3 -> v2
> 
> 1. Rebase to mmotm 2nd June 2009
> 2. Test with some of the test cases recommended by Daisuke-San
> 
> Changelog v2 -> v1
> 1. Fix and implement review comments.
> 
> Feature: Remove the overhead associated with the root cgroup
> 
> This patch changes the memory cgroup and removes the overhead associated
> with accounting all pages in the root cgroup. As a side-effect, we can
> no longer set a memory hard limit in the root cgroup.
> 
> A new flag is used to track page_cgroup associated with the root cgroup
> pages. A new flag to track whether the page has been accounted or not
> has been added as well. Flags are now set atomically for page_cgroup,
> pcg_default_flags is now obsolete, but I've not removed it yet. It
> provides some readability to help the code.
> 
> Tests Results:
> 
> Obtained by
> 
> 1. Using tmpfs for mounting filesystem
> 2. Changing sync to be /bin/true (so that sync is not the bottleneck)
> 3. Used -s #cpus*40 -e #cpus*40
> 
> Reaim
> 		withoutpatch	patch
> AIM9		9532.48		9807.59
> dbase		19344.60	19285.71
> new_dbase	20101.65	20163.13
> shared		11827.77	11886.65
> compute		17317.38	17420.05
> 

A few comments.


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
> index 7339c7b..41cc16c 100644
> --- a/include/linux/page_cgroup.h
> +++ b/include/linux/page_cgroup.h
> @@ -26,6 +26,8 @@ enum {
>  	PCG_LOCK,  /* page cgroup is locked */
>  	PCG_CACHE, /* charged as cache */
>  	PCG_USED, /* this object is in use. */
> +	PCG_ROOT, /* page belongs to root cgroup */
> +	PCG_ACCT_LRU, /* page has been accounted for */
>  };
>  
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
> +SETPCGFLAG(AcctLru, ACCT_LRU)
> +CLEARPCGFLAG(AcctLru, ACCT_LRU)
> +TESTPCGFLAG(AcctLru, ACCT_LRU)
>  
I prefer AcctLRU rather than AcctLru. LRU is LRU or lru and not Lru through
the kernel.

>  static inline int page_cgroup_nid(struct page_cgroup *pc)
>  {
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index a83e039..9561d10 100644
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
> @@ -197,6 +198,10 @@ enum charge_type {
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

Could you delete this default_flags ? This is of no use after this patch.


> @@ -375,7 +380,7 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  		return;
>  	pc = lookup_page_cgroup(page);
>  	/* can happen while we handle swapcache. */
> -	if (list_empty(&pc->lru) || !pc->mem_cgroup)
> +	if ((!PageCgroupAcctLru(pc) && list_empty(&pc->lru)) || !pc->mem_cgroup)
>  		return;
I wonder this condition is valid one or not..

IMHO, all check here should be

==
	if (!PageCgroupAcctLru(pc) || !pc->mem_cgroup)
		return;
	mz = page_cgroup_zoneinfo(pc);
	mem = pc->mem_cgroup;
	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
	ClearPageCgroupAcctLru(pc);
	if (PageCgroupRoot(pc))
		return;
	VM_BUGON(list_empty(&pc->lru);
	list_del_init(&pc->lru);
	return;
==

I'm sorry if there is a case
   (PageCgroupAcctLru(pc) && !PageCgroupRoot(pc) && list_empty(&pc->lru))


>  	/*
>  	 * We don't check PCG_USED bit. It's cleared when the "page" is finally
> @@ -384,6 +389,9 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  	mz = page_cgroup_zoneinfo(pc);
>  	mem = pc->mem_cgroup;
>  	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
> +	ClearPageCgroupAcctLru(pc);
> +	if (PageCgroupRoot(pc))
> +		return;
>  	list_del_init(&pc->lru);
>  	return;
>  }
> @@ -407,8 +415,8 @@ void mem_cgroup_rotate_lru_list(struct page *page, enum lru_list lru)
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
> @@ -432,6 +440,9 @@ void mem_cgroup_add_lru_list(struct page *page, enum lru_list lru)
>  
>  	mz = page_cgroup_zoneinfo(pc);
>  	MEM_CGROUP_ZSTAT(mz, lru) += 1;
> +	SetPageCgroupAcctLru(pc);
> +	if (PageCgroupRoot(pc))
> +		return;
>  	list_add(&pc->lru, &mz->lists[lru]);
>  }
>  
> @@ -1107,9 +1118,24 @@ static void __mem_cgroup_commit_charge(struct mem_cgroup *mem,
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
My concern here is there will be a racy moment that pc->flag shows
  PageCgroupUsed(pc) && !PageCgroupRoot(pc) even if pc->mem_cgroup == root_mem_cgroup.

Then, The order of code here should be
==
	if (mem == root_mem_cgroup)
		SetPageCgroupRoot(pc);
	pc->mem_cgroup == mem;;
	smp_wmb();
	switch(type) {
	case....
	}
	// Used bit is set at last.
==

But I wonder it's better to use
==
static inline int page_cgroup_is_under_root(pc)
{
	pc->mem_cgroup == root_mem_cgroup;
}
==
I'm not sure why PageCgroupRoot() "bit" is necessary.
Could you clarify the benefit of Root flag ?



> @@ -1515,6 +1541,8 @@ __mem_cgroup_uncharge_common(struct page *page, enum charge_type ctype)
>  	mem_cgroup_charge_statistics(mem, pc, false);
>  
>  	ClearPageCgroupUsed(pc);
> +	if (mem == root_mem_cgroup)
> +		ClearPageCgroupRoot(pc);
>  	/*
>  	 * pc->mem_cgroup is not cleared here. It will be accessed when it's
>  	 * freed from LRU. This is safe because uncharged page is expected not
> @@ -2036,6 +2064,10 @@ static int mem_cgroup_write(struct cgroup *cont, struct cftype *cft,
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
> @@ -2502,6 +2534,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	if (cont->parent == NULL) {
>  		enable_swap_cgroup();
>  		parent = NULL;
> +		root_mem_cgroup = mem;
>  	} else {
>  		parent = mem_cgroup_from_cont(cont->parent);
>  		mem->use_hierarchy = parent->use_hierarchy;
> @@ -2530,6 +2563,7 @@ mem_cgroup_create(struct cgroup_subsys *ss, struct cgroup *cont)
>  	return &mem->css;
>  free_out:
>  	__mem_cgroup_free(mem);
> +	root_mem_cgroup = NULL;
>  	return ERR_PTR(error);
>  }
>  
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index ecc3918..4406a9c 100644
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
Unnecessary diff here.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
