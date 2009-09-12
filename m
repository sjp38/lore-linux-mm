Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id AD5496B004D
	for <linux-mm@kvack.org>; Fri, 11 Sep 2009 21:56:36 -0400 (EDT)
Received: from fgwmail6.fujitsu.co.jp (fgwmail6.fujitsu.co.jp [192.51.44.36])
	by fgwmail9.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8C0lpR6016265
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 12 Sep 2009 09:47:51 +0900
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n8C0lGpE018623
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 12 Sep 2009 09:47:16 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 23DC045DE7F
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:47:16 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id DF20445DE6E
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:47:15 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCBA1E18006
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:47:15 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5E9AA1DB8041
	for <linux-mm@kvack.org>; Sat, 12 Sep 2009 09:47:15 +0900 (JST)
Message-ID: <e95a8951d7a678983b26830ef535a108.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090911112221.GA20629@localhost>
References: <20090911112221.GA20629@localhost>
Date: Sat, 12 Sep 2009 09:47:14 +0900 (JST)
Subject: Re: [PATCH 1/2] memcg: rename and export
 try_get_mem_cgroup_from_page()
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hugh@veritas.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Wu Fengguang wrote:
> So that the hwpoison injector can get mem_cgroup for arbitrary page
> and thus know whether it is owned by some mem_cgroup task(s).
>

I have no strong objections to these 2 patches.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

But it's in merge-window. I recommend you to repost again with
codes for caller(hwpoison itself).

-Kame

So if you

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
> -static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page
> *page)
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
>   * commit a charge got by __mem_cgroup_try_charge() and makes page_cgroup
> to be
> @@ -1753,7 +1751,7 @@ int mem_cgroup_try_charge_swapin(struct
>  	 */
>  	if (!PageSwapCache(page))
>  		return 0;
> -	mem = try_get_mem_cgroup_from_swapcache(page);
> +	mem = try_get_mem_cgroup_from_page(page);
>  	if (!mem)
>  		goto charge_cur_mm;
>  	*ptr = mem;
> --- linux-mm.orig/include/linux/memcontrol.h	2009-09-11 18:51:13.000000000
> +0800
> +++ linux-mm/include/linux/memcontrol.h	2009-09-11 18:52:14.000000000
> +0800
> @@ -68,6 +68,7 @@ extern unsigned long mem_cgroup_isolate_
>  extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t
> gfp_mask);
>  int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup
> *mem);
>
> +extern struct mem_cgroup *try_get_mem_cgroup_from_page(struct page
> *page);
>  extern struct mem_cgroup *mem_cgroup_from_task(struct task_struct *p);
>
>  static inline
> @@ -189,6 +190,11 @@ mem_cgroup_move_lists(struct page *page,
>  {
>  }
>
> +static inline struct mem_cgroup *try_get_mem_cgroup_from_page(struct page
> *page)
> +{
> +	return NULL;
> +}
> +
>  static inline int mm_match_cgroup(struct mm_struct *mm, struct mem_cgroup
> *mem)
>  {
>  	return 1;
>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
