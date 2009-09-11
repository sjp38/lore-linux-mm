Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4E1496B0055
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 07:36:49 -0400 (EDT)
Date: Fri, 11 Sep 2009 19:36:39 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 1/2] memcg: rename and export
	try_get_mem_cgroup_from_page()
Message-ID: <20090911113639.GA21321@localhost>
References: <20090911112221.GA20629@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090911112221.GA20629@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[add CC to new Hugh; will update CC inside patch]

Hi Kame and Balbir,

After your previous reviews, I tried out the pin-pfn idea.
It resulted in many code in both kernel and user space tools.
So I (and Andi) decided that the complexity of tracking pin
states is not worth it. It would be best to reuse the memcg
functionalities for testing hwpoison. It is particular handy
for some fork storm tests.

The change since the initial post is
- don't export the memcg id. we don't need it indeed, and can simply
  try to hwpoison *all* memcg tracked pages.
- generate mem_cgroup_css() code only for CONFIG_HWPOISON_INJECT

Thus no user visible changes and no extra code when hwpoison is
disabled.

Thanks,
Fengguang

On Fri, Sep 11, 2009 at 07:22:21PM +0800, Wu Fengguang wrote:
> So that the hwpoison injector can get mem_cgroup for arbitrary page
> and thus know whether it is owned by some mem_cgroup task(s).
> 
> Background:
> 
> The hwpoison test suite need to inject hwpoison to a collection of
> selected task pages, and must not touch pages not owned by these pages
> and thus kill important system processes such as init. (But it's OK to
> mis-hwpoison free/unowned pages as well as shared clean pages.
> Mis-hwpoison of shared dirty pages will kill all tasks, so the test
> suite will target all or non of such tasks in the first place.)
> 
> The memory cgroup serves this purpose well. We can put the target
> processes under the control of a memory cgroup, and tell the hwpoison
> injection code to only kill pages associated with some active memory
> cgroup.
> 
> The prerequsite for doing hwpoison stress tests with mem_cgroup is,
> the mem_cgroup code tracks task pages _accurately_ (unless page is
> locked).  Which we believe is/should be true.
> 
> The benifits are simplification of hwpoison injector code. Also the
> mem_cgroup code will automatically be tested by hwpoison test cases.
> 
> CC: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> CC: Hugh Dickins <hugh@veritas.com>
> CC: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> CC: Balbir Singh <balbir@linux.vnet.ibm.com>
> CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> ---
>  include/linux/memcontrol.h |    6 ++++++
>  mm/memcontrol.c            |   12 +++++-------
>  2 files changed, 11 insertions(+), 7 deletions(-)
> 
> --- linux-mm.orig/mm/memcontrol.c	2009-09-11 18:51:14.000000000 +0800
> +++ linux-mm/mm/memcontrol.c	2009-09-11 18:52:14.000000000 +0800
> @@ -1389,25 +1389,22 @@ static struct mem_cgroup *mem_cgroup_loo
>  	return container_of(css, struct mem_cgroup, css);
>  }
>  
> -static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
> +struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
>  {
> -	struct mem_cgroup *mem;
> +	struct mem_cgroup *mem = NULL;
>  	struct page_cgroup *pc;
>  	unsigned short id;
>  	swp_entry_t ent;
>  
>  	VM_BUG_ON(!PageLocked(page));
>  
> -	if (!PageSwapCache(page))
> -		return NULL;
> -
>  	pc = lookup_page_cgroup(page);
>  	lock_page_cgroup(pc);
>  	if (PageCgroupUsed(pc)) {
>  		mem = pc->mem_cgroup;
>  		if (mem && !css_tryget(&mem->css))
>  			mem = NULL;
> -	} else {
> +	} else if (PageSwapCache(page)) {
>  		ent.val = page_private(page);
>  		id = lookup_swap_cgroup(ent);
>  		rcu_read_lock();
> @@ -1419,6 +1416,7 @@ static struct mem_cgroup *try_get_mem_cg
>  	unlock_page_cgroup(pc);
>  	return mem;
>  }
> +EXPORT_SYMBOL(try_get_mem_cgroup_from_page);
>  
>  /*
>   * commit a charge got by __mem_cgroup_try_charge() and makes page_cgroup to be
> @@ -1753,7 +1751,7 @@ int mem_cgroup_try_charge_swapin(struct 
>  	 */
>  	if (!PageSwapCache(page))
>  		return 0;
> -	mem = try_get_mem_cgroup_from_swapcache(page);
> +	mem = try_get_mem_cgroup_from_page(page);
>  	if (!mem)
>  		goto charge_cur_mm;
>  	*ptr = mem;
> --- linux-mm.orig/include/linux/memcontrol.h	2009-09-11 18:51:13.000000000 +0800
> +++ linux-mm/include/linux/memcontrol.h	2009-09-11 18:52:14.000000000 +0800
> @@ -68,6 +68,7 @@ extern unsigned long mem_cgroup_isolate_
>  extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
>  
> +extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>  
>  static inline
> @@ -189,6 +190,11 @@ mem_cgroup_move_lists(struct page *page,
>  {
>  }
>  
> +static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page *page)
> +{
> +	return NULL;
> +}
> +
>  static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup *mem)
>  {
>  	return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
