Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id AD2E96B003D
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 00:34:39 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2A4YaNM010282
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 10 Mar 2009 13:34:36 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 16C9D45DD79
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:34:36 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E0D6A45DE51
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:34:35 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C43981DB803E
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:34:35 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 62DE21DB8043
	for <linux-mm@kvack.org>; Tue, 10 Mar 2009 13:34:35 +0900 (JST)
Date: Tue, 10 Mar 2009 13:33:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] memcg: charge swapcache to proper memcg
Message-Id: <20090310133316.b56d3319.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
References: <20090310100707.e0640b0b.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Mar 2009 10:07:07 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> memcg_test.txt says at 4.1:
> 
> 	This swap-in is one of the most complicated work. In do_swap_page(),
> 	following events occur when pte is unchanged.
> 
> 	(1) the page (SwapCache) is looked up.
> 	(2) lock_page()
> 	(3) try_charge_swapin()
> 	(4) reuse_swap_page() (may call delete_swap_cache())
> 	(5) commit_charge_swapin()
> 	(6) swap_free().
> 
> 	Considering following situation for example.
> 
> 	(A) The page has not been charged before (2) and reuse_swap_page()
> 	    doesn't call delete_from_swap_cache().
> 	(B) The page has not been charged before (2) and reuse_swap_page()
> 	    calls delete_from_swap_cache().
> 	(C) The page has been charged before (2) and reuse_swap_page() doesn't
> 	    call delete_from_swap_cache().
> 	(D) The page has been charged before (2) and reuse_swap_page() calls
> 	    delete_from_swap_cache().
> 
> 	    memory.usage/memsw.usage changes to this page/swp_entry will be
> 	 Case          (A)      (B)       (C)     (D)
>          Event
>        Before (2)     0/ 1     0/ 1      1/ 1    1/ 1
>           ===========================================
>           (3)        +1/+1    +1/+1     +1/+1   +1/+1
>           (4)          -       0/ 0       -     -1/ 0
>           (5)         0/-1     0/ 0     -1/-1    0/ 0
>           (6)          -       0/-1       -      0/-1
>           ===========================================
>        Result         1/ 1     1/ 1      1/ 1    1/ 1
> 
>        In any cases, charges to this page should be 1/ 1.
> 
> In case of (D), mem_cgroup_try_get_from_swapcache() returns NULL
> (because lookup_swap_cgroup() returns NULL), so "+1/+1" at (3) means
> charges to the memcg("foo") to which the "current" belongs.
> OTOH, "-1/0" at (4) and "0/-1" at (6) means uncharges from the memcg("baa")
> to which the page has been charged.
> 
> So, if the "foo" and "baa" is different(for example because of task move),
> this charge will be moved from "baa" to "foo".
> 
> I think this is an unexpected behavior.
> 
> This patch fixes this by modifying mem_cgroup_try_get_from_swapcache()
> to return the memcg to which the swapcache has been charged if PCG_USED bit
> is set.
> IIUC, checking PCG_USED bit of swapcache is safe under page lock.
> 
> 
> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  mm/memcontrol.c |   15 +++++++++++++--
>  1 files changed, 13 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 73c51c8..f2efbc0 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -909,13 +909,24 @@ nomem:
>  static struct mem_cgroup *try_get_mem_cgroup_from_swapcache(struct page *page)
>  {
>  	struct mem_cgroup *mem;
> +	struct page_cgroup *pc;
>  	swp_entry_t ent;
>  
> +	VM_BUG_ON(!PageLocked(page));
> +
>  	if (!PageSwapCache(page))
>  		return NULL;
>  
> -	ent.val = page_private(page);
> -	mem = lookup_swap_cgroup(ent);
> +	pc = lookup_page_cgroup(page);
> +	/*
> +	 * Used bit of swapcache is solid under page lock.
> +	 */
> +	if (PageCgroupUsed(pc))
> +		mem = pc->mem_cgroup;

I've already acked but how about returning NULL here ?

THanks
-Kame

> +	else {
> +		ent.val = page_private(page);
> +		mem = lookup_swap_cgroup(ent);
> +	}
>  	if (!mem)
>  		return NULL;
>  	if (!css_tryget(&mem->css))
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
