Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mAO5iU8w011736
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 24 Nov 2008 14:44:30 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 393E945DE4F
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 14:44:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E2A745DD72
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 14:44:30 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id EE34CE08002
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 14:44:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A6C02E08001
	for <linux-mm@kvack.org>; Mon, 24 Nov 2008 14:44:29 +0900 (JST)
Date: Mon, 24 Nov 2008 14:43:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] memcg: memswap controller core swapcache fixes
Message-Id: <20081124144344.d2703a60.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0811232208380.6437@blonde.site>
References: <Pine.LNX.4.64.0811232151400.3748@blonde.site>
	<Pine.LNX.4.64.0811232156120.4142@blonde.site>
	<Pine.LNX.4.64.0811232208380.6437@blonde.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 23 Nov 2008 22:11:07 +0000 (GMT)
Hugh Dickins <hugh@veritas.com> wrote:

> Two SwapCache bug fixes to mmotm's memcg-memswap-controller-core.patch:
> 
> One bug is independent of my current changes: there is no guarantee that
> the page passed to mem_cgroup_try_charge_swapin() is still in SwapCache.
> 

Ah, yes. I'm wrong that the page may not be SwapCache when lock_page() is
called...

Thanks!
-Kame

> The other bug is a consequence of my changes, but the fix is okay without
> them: mem_cgroup_commit_charge_swapin() expects swp_entry in page->private,
> but now reuse_swap_page() (formerly can_share_swap_page()) might already
> have done delete_from_swap_cache(): move commit_charge_swapin() earlier.
> 
> Signed-off-by: Hugh Dickins <hugh@veritas.com>
> ---
> 
>  mm/memcontrol.c |    8 ++++++++
>  mm/memory.c     |   15 +++++++++++++--
>  2 files changed, 21 insertions(+), 2 deletions(-)
> 
> --- mmotm.orig/mm/memcontrol.c	2008-11-23 21:03:48.000000000 +0000
> +++ mmotm/mm/memcontrol.c	2008-11-23 21:06:12.000000000 +0000
> @@ -847,6 +847,14 @@ int mem_cgroup_try_charge_swapin(struct 
>  	if (!do_swap_account)
>  		goto charge_cur_mm;
>  
> +	/*
> +	 * A racing thread's fault, or swapoff, may have already updated
> +	 * the pte, and even removed page from swap cache: return success
> +	 * to go on to do_swap_page()'s pte_same() test, which should fail.
> +	 */
> +	if (!PageSwapCache(page))
> +		return 0;
> +
>  	ent.val = page_private(page);
>  
>  	mem = lookup_swap_cgroup(ent);
> --- mmotm.orig/mm/memory.c	2008-11-23 21:03:48.000000000 +0000
> +++ mmotm/mm/memory.c	2008-11-23 21:06:12.000000000 +0000
> @@ -2361,8 +2361,20 @@ static int do_swap_page(struct mm_struct
>  		goto out_nomap;
>  	}
>  
> -	/* The page isn't present yet, go ahead with the fault. */
> +	/*
> +	 * The page isn't present yet, go ahead with the fault.
> +	 *
> +	 * Be careful about the sequence of operations here.
> +	 * To get its accounting right, reuse_swap_page() must be called
> +	 * while the page is counted on swap but not yet in mapcount i.e.
> +	 * before page_add_anon_rmap() and swap_free(); try_to_free_swap()
> +	 * must be called after the swap_free(), or it will never succeed.
> +	 * And mem_cgroup_commit_charge_swapin(), which uses the swp_entry
> +	 * in page->private, must be called before reuse_swap_page(),
> +	 * which may delete_from_swap_cache().
> +	 */
>  
> +	mem_cgroup_commit_charge_swapin(page, ptr);
>  	inc_mm_counter(mm, anon_rss);
>  	pte = mk_pte(page, vma->vm_page_prot);
>  	if (write_access && reuse_swap_page(page)) {
> @@ -2373,7 +2385,6 @@ static int do_swap_page(struct mm_struct
>  	flush_icache_page(vma, page);
>  	set_pte_at(mm, address, page_table, pte);
>  	page_add_anon_rmap(page, vma, address);
> -	mem_cgroup_commit_charge_swapin(page, ptr);
>  
>  	swap_free(entry);
>  	if (vm_swap_full() || (vma->vm_flags & VM_LOCKED) || PageMlocked(page))
> 
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
