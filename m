Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 2DC056B004F
	for <linux-mm@kvack.org>; Tue, 12 May 2009 03:10:32 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4C7AbXZ026788
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 12 May 2009 16:10:39 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A479D45DE57
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:10:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 347A845DE54
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:10:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 14B951DB8037
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:10:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8ADD11DB803B
	for <linux-mm@kvack.org>; Tue, 12 May 2009 16:10:31 +0900 (JST)
Date: Tue, 12 May 2009 16:09:01 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 4/3] memcg: call uncharge_swapcache outside of tree_lock
 (Re: [PATCH 0/3] fix stale swap cache account leak  in memcg v7)
Message-Id: <20090512160901.8a6c5f64.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090512140648.0974cb10.nishimura@mxp.nes.nec.co.jp>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512140648.0974cb10.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009 14:06:48 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> On Tue, 12 May 2009 10:44:01 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > I hope this version gets acks..
> > ==
> > As Nishimura reported, there is a race at handling swap cache.
> > 
> > Typical cases are following (from Nishimura's mail)
> > 
> > 
> > == Type-1 ==
> >   If some pages of processA has been swapped out, it calls free_swap_and_cache().
> >   And if at the same time, processB is calling read_swap_cache_async() about
> >   a swap entry *that is used by processA*, a race like below can happen.
> > 
> >             processA                   |           processB
> >   -------------------------------------+-------------------------------------
> >     (free_swap_and_cache())            |  (read_swap_cache_async())
> >                                        |    swap_duplicate()
> >                                        |    __set_page_locked()
> >                                        |    add_to_swap_cache()
> >       swap_entry_free() == 0           |
> >       find_get_page() -> found         |
> >       try_lock_page() -> fail & return |
> >                                        |    lru_cache_add_anon()
> >                                        |      doesn't link this page to memcg's
> >                                        |      LRU, because of !PageCgroupUsed.
> > 
> >   This type of leak can be avoided by setting /proc/sys/vm/page-cluster to 0.
> > 
> > 
> > == Type-2 ==
> >     Assume processA is exiting and pte points to a page(!PageSwapCache).
> >     And processB is trying reclaim the page.
> > 
> >               processA                   |           processB
> >     -------------------------------------+-------------------------------------
> >       (page_remove_rmap())               |  (shrink_page_list())
> >          mem_cgroup_uncharge_page()      |
> >             ->uncharged because it's not |
> >               PageSwapCache yet.         |
> >               So, both mem/memsw.usage   |
> >               are decremented.           |
> >                                          |    add_to_swap() -> added to swap cache.
> > 
> >     If this page goes thorough without being freed for some reason, this page
> >     doesn't goes back to memcg's LRU because of !PageCgroupUsed.
> > 
> > 
> > Considering Type-1, it's better to avoid swapin-readahead when memcg is used.
> > swapin-readahead just read swp_entries which are near to requested entry. So,
> > pages not to be used can be on memory (on global LRU). When memcg is used,
> > this is not good behavior anyway.
> > 
> > Considering Type-2, the page should be freed from SwapCache right after WriteBack.
> > Free swapped out pages as soon as possible is a good nature to memcg, anyway.
> > 
> > The patch set includes followng
> >  [1/3] add mem_cgroup_is_activated() function. which tell us memcg is _really_ used.
> >  [2/3] fix swap cache handling race by avoidng readahead.
> >  [3/3] fix swap cache handling race by check swapcount again.
> > 
> > Result is good under my test.
> > 
> These patches seem to work well on my side too.
> 
> 
> BTW, we need one more fix which I found in a long term test last week.
> After this patch, it survived all through the weekend in my test.
> 
> I don't know why we've never hit this bug so far.
> I think I hit it because my memcg_free_unused_swapcache() patch increases
> the possibility of calling mem_cgroup_uncharge_swapcache().
> 
> Thanks,
> Daisuke Nishimura.
> ===
> From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> memcg: call mem_cgroup_uncharge_swapcache() outside of tree_lock
> 
> It's rare, but I hit a spinlock lockup.
> 
>     BUG: spinlock lockup on CPU#2, page01/24205, ffffffff806faf18
>     Pid: 24205, comm: page01 Not tainted 2.6.30-rc4-5845621d #1
>     Call Trace:
>      <IRQ>  [<ffffffff80294f93>] ? test_clear_page_writeback+0x4d/0xff
>      [<ffffffff803752bc>] ? _raw_spin_lock+0xfb/0x122
>      [<ffffffff804ee9ba>] ? _spin_lock_irqsave+0x59/0x70
>      [<ffffffff80294f93>] ? test_clear_page_writeback+0x4d/0xff
>      [<ffffffff8029649c>] ? rotate_reclaimable_page+0x87/0x8e
>      [<ffffffff80294f93>] ? test_clear_page_writeback+0x4d/0xff
>      [<ffffffff8028d4ed>] ? end_page_writeback+0x1c/0x3d
>      [<ffffffff802ac4c6>] ? end_swap_bio_write+0x57/0x65
>      [<ffffffff803516d9>] ? __end_that_request_first+0x1f3/0x2e4
>      [<ffffffff803515f2>] ? __end_that_request_first+0x10c/0x2e4
>      [<ffffffff803517e5>] ? end_that_request_data+0x1b/0x4c
>      [<ffffffff8035225a>] ? blk_end_io+0x1c/0x76
>      [<ffffffffa0060702>] ? scsi_io_completion+0x1dc/0x467 [scsi_mod]
>      [<ffffffff80356394>] ? blk_done_softirq+0x66/0x76
>      [<ffffffff8024002e>] ? __do_softirq+0xae/0x182
>      [<ffffffff8020cb3c>] ? call_softirq+0x1c/0x2a
>      [<ffffffff8020de9a>] ? do_softirq+0x31/0x83
>      [<ffffffff8020d57b>] ? do_IRQ+0xa9/0xbf
>      [<ffffffff8020c393>] ? ret_from_intr+0x0/0xf
>      <EOI>  [<ffffffff8026fd56>] ? res_counter_uncharge+0x67/0x70
>      [<ffffffff802bf04a>] ? __mem_cgroup_uncharge_common+0xbd/0x158
>      [<ffffffff802a0f55>] ? unmap_vmas+0x7ef/0x829
>      [<ffffffff802a8a3a>] ? page_remove_rmap+0x1b/0x36
>      [<ffffffff802a0c11>] ? unmap_vmas+0x4ab/0x829
>      [<ffffffff802a5243>] ? exit_mmap+0xa7/0x11c
>      [<ffffffff80239009>] ? mmput+0x41/0x9f
>      [<ffffffff8023cf7b>] ? exit_mm+0x101/0x10c
>      [<ffffffff8023e481>] ? do_exit+0x1a4/0x61e
>      [<ffffffff80259391>] ? trace_hardirqs_on_caller+0x11d/0x148
>      [<ffffffff8023e96e>] ? do_group_exit+0x73/0xa5
>      [<ffffffff8023e9b2>] ? sys_exit_group+0x12/0x16
>      [<ffffffff8020b96b>] ? system_call_fastpath+0x16/0x1b
> 
> This is caused when:
> 
> CPU1: __mem_cgroup_uncharge_common(), which is holding page_cgroup lock,
>       is interuppted and end_swap_bio_write(), which tries to hold
>       swapper_space.tree_lock, is called in the interrupt context.
> CPU2: mem_cgroup_uncharge_swapcache(), which is called under swapper_space.tree_lock,
>       is spinning at lock_page_cgroup() in __mem_cgroup_uncharge_common().
> 
> IIUC, there is no need that mem_cgroup_uncharge_swapcache() should be called under
> swapper_space.tree.lock, so move it outside the tree_lock.
> 

I understand the problem, but, wait a bit. NACK to this patch itself.

1. I placed _uncharge_ inside tree_lock because __remove_from_page_cache() does.
   (i.e. using the same logic.)
   So, plz change both logic at once.(change caller of  mem_cgroup_uncharge_cache_page())

2. Shouldn't we disable IRQ while __mem_cgroup_uncharge_common() rather than moving
   function ?

Thanks,
-Kame





> Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> ---
>  include/linux/swap.h |    5 +++++
>  mm/memcontrol.c      |    2 +-
>  mm/swap_state.c      |    4 +---
>  mm/vmscan.c          |    1 +
>  4 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index caf0767..6ea541d 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -431,6 +431,11 @@ static inline swp_entry_t get_swap_page(void)
>  #define has_swap_token(x) 0
>  #define disable_swap_token() do { } while(0)
>  
> +static inline void
> +mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> +{
> +}
> +
>  #endif /* CONFIG_SWAP */
>  #endif /* __KERNEL__*/
>  #endif /* _LINUX_SWAP_H */
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 0c9c1ad..379f200 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1489,7 +1489,7 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
>  }
>  
>  /*
> - * called from __delete_from_swap_cache() and drop "page" account.
> + * called after __delete_from_swap_cache() and drop "page" account.
>   * memcg information is recorded to swap_cgroup of "ent"
>   */
>  void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index e389ef2..7624c89 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -109,8 +109,6 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
>   */
>  void __delete_from_swap_cache(struct page *page)
>  {
> -	swp_entry_t ent = {.val = page_private(page)};
> -
>  	VM_BUG_ON(!PageLocked(page));
>  	VM_BUG_ON(!PageSwapCache(page));
>  	VM_BUG_ON(PageWriteback(page));
> @@ -121,7 +119,6 @@ void __delete_from_swap_cache(struct page *page)
>  	total_swapcache_pages--;
>  	__dec_zone_page_state(page, NR_FILE_PAGES);
>  	INC_CACHE_INFO(del_total);
> -	mem_cgroup_uncharge_swapcache(page, ent);
>  }
>  
>  /**
> @@ -191,6 +188,7 @@ void delete_from_swap_cache(struct page *page)
>  	__delete_from_swap_cache(page);
>  	spin_unlock_irq(&swapper_space.tree_lock);
>  
> +	mem_cgroup_uncharge_swapcache(page, entry);
>  	swap_free(entry);
>  	page_cache_release(page);
>  }
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 337be66..e674cd1 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -470,6 +470,7 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
>  		swp_entry_t swap = { .val = page_private(page) };
>  		__delete_from_swap_cache(page);
>  		spin_unlock_irq(&mapping->tree_lock);
> +		mem_cgroup_uncharge_swapcache(page, swap);
>  		swap_free(swap);
>  	} else {
>  		__remove_from_page_cache(page);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
