Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 9CAB96B004D
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 17:14:27 -0400 (EDT)
Received: by iajr24 with SMTP id r24so10907230iaj.14
        for <linux-mm@kvack.org>; Mon, 16 Apr 2012 14:14:26 -0700 (PDT)
Date: Mon, 16 Apr 2012 14:14:09 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [RFC PATCH] s390: mm: rmap: Transfer storage key to struct page
 under the page lock
In-Reply-To: <20120416141423.GD2359@suse.de>
Message-ID: <alpine.LSU.2.00.1204161332120.1675@eggly.anvils>
References: <20120416141423.GD2359@suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, Linux-S390 <linux-s390@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, 16 Apr 2012, Mel Gorman wrote:

> This patch is horribly ugly and there has to be a better way of doing
> it. I'm looking for suggestions on what s390 can do here that is not
> painful or broken. 
> 
> The following bug was reported on s390
> 
> kernel BUG at
> /usr/src/packages/BUILD/kernel-default-3.0.13/linux-3.0/lib/radix-tree.c:477!
> illegal operation: 0001 [#1] SMP
> Modules linked in: ext2 dm_round_robin dm_multipath sg sd_mod crc_t10dif fuse
> loop dm_mod ipv6 qeth_l3 ipv6_lib zfcp scsi_transport_fc scsi_tgt qeth qdio
> ccwgroup ext3 jbd mbcache dasd_eckd_mod dasd_mod scsi_dh_rdac scsi_dh_emc
> scsi_dh_alua scsi_dh_hp_sw scsi_dh scsi_mod
> Supported: Yes
> CPU: 3 Not tainted 3.0.13-0.27-default #1
> Process kpartx_id (pid: 24381, task: 000000004d938138, ksp: 00000000733539f0)
> Krnl PSW : 0404000180000000 000000000037935e
> (radix_tree_tag_set+0xfe/0x118)
>            R:0 T:1 IO:0 EX:0 Key:0 M:1 W:0 P:0 AS:0 CC:0 PM:0 EA:3
> Krnl GPRS: 0000000000000002 0000000000000018 00000000004e82a8 0000000000000000
>            0000000000000007 0000000000000003 00000000004e82a8 00000000007280c0
>            0000000000000000 0000000000000000 00000000fac55d5f 0000000000000000
>            000003e000000006 0000000000529f88 0000000000000000 0000000073353ad0
> Krnl Code: 0000000000379352: a7cafffa           ahi     %r12,-6
>            0000000000379356: a7f4ffb5           brc     15,3792c0
>            000000000037935a: a7f40001           brc     15,37935c
>           >000000000037935e: a7f40000           brc     15,37935e
>            0000000000379362: b90200bb           ltgr    %r11,%r11
>            0000000000379366: a784fff0           brc     8,379346
>            000000000037936a: a7f4ffe1           brc     15,37932c
>            000000000037936e: a7f40001           brc     15,379370
> Call Trace:
> ([<00000000002080ae>] __set_page_dirty_nobuffers+0x10a/0x1d0)
>  [<0000000000234970>] page_remove_rmap+0x100/0x104
>  [<0000000000228608>] zap_pte_range+0x194/0x608
>  [<0000000000228caa>] unmap_page_range+0x22e/0x33c
>  [<0000000000228ec2>] unmap_vmas+0x10a/0x274
>  [<000000000022f2f6>] exit_mmap+0xd2/0x254
>  [<00000000001472d6>] mmput+0x5e/0x144
>  [<000000000014d306>] exit_mm+0x196/0x1d4
>  [<000000000014f650>] do_exit+0x18c/0x408
>  [<000000000014f92c>] do_group_exit+0x60/0xec
>  [<000000000014f9ea>] SyS_exit_group+0x32/0x40
>  [<00000000004e1660>] sysc_noemu+0x16/0x1c
>  [<000003fffd23ab96>] 0x3fffd23ab96
> Last Breaking-Event-Address:
>  [<000000000037935a>] radix_tree_tag_set+0xfa/0x118
> 
> While this bug was reproduced on a 3.0.x kernel, there is no reason why
> it should not happen in mainline.
> 
> The bug was triggered because a page had a valid mapping but by the time
> set_page_dirty() was called there was no valid entry in the radix tree.
> This was reproduced while underlying storage was unplugged but this may
> be indirectly related to the problem.
> 
> This bug only triggers on s390 and may be explained by a race. Normally
> when pages are being readahead in read_cache_pages(), an attempt is made
> to add the page to the page cache. If that fails, the page is invalidated
> by locking it, giving it a valid mapping, calling do_invalidatepage()
> and then setting mapping to NULL again. It's similar with page cache is
> being deleted. The page is locked, the tree lock is taken, it's removed
> from the radix tree and the mapping is set to NULL.
> 
> In many cases looking up the radix tree is protected by a combination of
> the page lock and the tree lock. When zapping pages, the page lock is not
> taken which does not matter as most architectures do nothing special with
> the mapping and for file-backed pages, the mapping should be pinned by
> the open file. However, s390 also calls set_dirty_page() for
> PageSwapCache() pages where it is potentially racing against
> reuse_swap_page() for example.
> 
> This patch splits the propagation of the storage key into a separate
> function and introduces a new variant of page_remove_rmap() called
> page_remove_rmap_nolock() which is only used during page table zapping
> that attempts to acquire the page lock. The approach is ugly although it
> works in that the bug can no longer be triggered. At the time the page
> lock is required, the PTL is held so it cannot sleep so it busy waits on
> trylock_page(). That potentially deadlocks against reclaim which holds
> the page table lock and is trying to acquire the pagetable lock so in
> some cases there is no choice except to race. In the file-backed case,
> this is ok because the address space will be valid (zap_pte_range() makes
> the same assumption. However, s390 needs a better way of guarding against
> PageSwapCache pages being removed from the radix tree while set_page_dirty()
> is being called. The patch would be marginally better if in the PageSwapCache
> case we simply tried to lock once and in the contended case just fail to
> propogate the storage key. I lack familiarity with the s390 architecture
> to be certain if this is safe or not. Suggestions on a better fix?
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

I'm very confused - and wonder if you are too ;)

Please forgive me if I've not been patient enough in reading through
all you've written, and knocking it into my skull: ask me to go back
and read again.

But it seems to me that you're approaching this from the wrong end
(page_remove_rmap), instead of from the end that's giving rise to the
problem - perhaps because you've not yet identified that other end?

I'm confused as to whether you see this problem with file pages,
or with anon-swap-cache pages, or with both, or not yet determined.

The obvious places which set page->mapping = NULL or ClearPageSwapCache,
once they've been visible to the outside world, are careful to do so at
the same time as removing the radix_tree entry, holding mapping->tree_lock.

And __set_page_dirty_nobuffers(), the set_page_dirty variant implicated
in the trace above, is careful to recheck mapping under tree_lock, as I
think are the others.  There is an issue if mapping itself could vanish
while in there, but that's not a danger in page_remove_rmap().

(You do remind me that I meant years ago to switch swapper_space over
to the much simpler __set_page_dirty_no_writeback(), which shmem has
used for ages; but as far as this problem goes, that would probably
be at best a workaround, rather than the proper fix.)

You indicate read_cache_pages_invalidate_page() above, and yes that's
weird the way it sets and unsets page->mapping; I never came across it
before, but IIUC it's safe because those pages have not yet been made
visible to the outside world.  (Or do we have a speculative pagecache
issue here?)

You compare do_invalidatepage() with deletion from page cache, but I hope
that's mistaken: aren't such pages usually being invalidated precisely
because they raced with pages found already there in the page cache,
which need to be left in place?

So, is there somewhere which is setting page->mapping = NULL, or
doing ClearPageSwapCache, in a separate block from removing that
page's entry from the radix_tree?  If there is, then I think it
could pose a problem on more than s390.

Hmm, mm/migrate.c.

Hugh

> ---
>  include/linux/rmap.h |    1 +
>  mm/memory.c          |    2 +-
>  mm/rmap.c            |  109 +++++++++++++++++++++++++++++++++++++++++++-------
>  3 files changed, 96 insertions(+), 16 deletions(-)
> 
> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> index 2148b12..59146af 100644
> --- a/include/linux/rmap.h
> +++ b/include/linux/rmap.h
> @@ -142,6 +142,7 @@ void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
>  void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
>  void page_add_file_rmap(struct page *);
>  void page_remove_rmap(struct page *);
> +void page_remove_rmap_nolock(struct page *);
>  
>  void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
>  			    unsigned long);
> diff --git a/mm/memory.c b/mm/memory.c
> index f1d788e..4f1bf96 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -1184,7 +1184,7 @@ again:
>  					mark_page_accessed(page);
>  				rss[MM_FILEPAGES]--;
>  			}
> -			page_remove_rmap(page);
> +			page_remove_rmap_nolock(page);
>  			if (unlikely(page_mapcount(page) < 0))
>  				print_bad_pte(vma, addr, ptent, page);
>  			force_flush = !__tlb_remove_page(tlb, page);
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 6546da9..9d2279b 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1114,29 +1114,81 @@ void page_add_file_rmap(struct page *page)
>  	}
>  }
>  
> -/**
> - * page_remove_rmap - take down pte mapping from a page
> - * @page: page to remove mapping from
> +/*
> + * When the late PTE has gone, s390 must transfer the dirty flag from the
> + * storage key to struct page. We can usually skip this if the page is anon,
> + * so about to be freed; but perhaps not if it's in swapcache - there might
> + * be another pte slot containing the swap entry, but page not yet written to
> + * swap.
>   *
> - * The caller needs to hold the pte lock.
> + * set_page_dirty() is called while the page_mapcount is still postive and
> + * under the page lock to avoid races with the mapping being invalidated.
>   */
> -void page_remove_rmap(struct page *page)
> +static void propogate_storage_key(struct page *page, bool lock_required)
> +{
> +	if (page_mapcount(page) == 1 &&
> +			(!PageAnon(page) || PageSwapCache(page)) &&
> +	    		page_test_and_clear_dirty(page_to_pfn(page), 1)) {
> +		if (lock_required) {
> +			bool locked;
> +
> +			/*
> +			 * This is called from zap_pte_range which holds the
> +			 * PTL. The page lock is normally needed to avoid
> +			 * truncation races and cannot sleep as a result.
> +			 * During zap_pte_range, it is assumed that the open
> +			 * file pins the mapping and a check is made under the
> +			 * tree_lock. The same does not hold true for SwapCache
> +			 * pages because it may be getting reused.
> +			 *
> +			 * Ideally we would take the page lock but in this
> +			 * context the PTL is held so we can't sleep. We
> +			 * are also potentially contending with processes
> +			 * in reclaim context that hold the page lock but
> +			 * are trying to acquire the PTL which leads to
> +			 * an ABBA deadlock.
> +			 *
> +			 * Hence this resulting mess. s390 needs a better
> +			 * way to guard against races. Suggestions?
> +			 */
> +			while ((locked = trylock_page(page)) == false) {
> +				cpu_relax();
> +
> +				if (need_resched())
> +					break;
> +			}
> +
> +			/* If the page is locked, it's safe to call set_page_dirty */
> +			if (locked) {
> +				set_page_dirty(page);
> +				unlock_page(page);
> +			} else {
> +
> +				/*
> +				 * For swap cache pages, we have no real choice
> +				 * except to lose the storage key information
> +				 * and expect the new user to preserve dirty
> +				 * information.
> +				 *
> +				 * For file-backed pages, the open file should
> +				 * be enough to pin the mapping similar which
> +				 * is also assumed by zap_pte_range().
> +				 */
> +				if (WARN_ON_ONCE(!PageSwapCache(page)))
> +					set_page_dirty(page);
> +			}
> +		} else
> +			set_page_dirty(page);
> +	}
> +}
> +
> +static void __page_remove_rmap(struct page *page)
>  {
>  	/* page still mapped by someone else? */
>  	if (!atomic_add_negative(-1, &page->_mapcount))
>  		return;
>  
>  	/*
> -	 * Now that the last pte has gone, s390 must transfer dirty
> -	 * flag from storage key to struct page.  We can usually skip
> -	 * this if the page is anon, so about to be freed; but perhaps
> -	 * not if it's in swapcache - there might be another pte slot
> -	 * containing the swap entry, but page not yet written to swap.
> -	 */
> -	if ((!PageAnon(page) || PageSwapCache(page)) &&
> -	    page_test_and_clear_dirty(page_to_pfn(page), 1))
> -		set_page_dirty(page);
> -	/*
>  	 * Hugepages are not counted in NR_ANON_PAGES nor NR_FILE_MAPPED
>  	 * and not charged by memcg for now.
>  	 */
> @@ -1164,6 +1216,33 @@ void page_remove_rmap(struct page *page)
>  	 */
>  }
>  
> +/**
> + * page_remove_rmap - take down pte mapping from an unlocked page
> + * @page: page to remove mapping from
> + *
> + * The caller needs to hold the pte lock.
> + */
> +void page_remove_rmap(struct page *page)
> +{
> +	propogate_storage_key(page, false);
> +	__page_remove_rmap(page);
> +}
> +
> +/**
> + * page_remove_rmap_nolock - take down pte mapping where the caller does not have the mapping pinned
> + * @page: page to remove mapping from
> + *
> + * The caller needs to hold the PTE lock and is called from a context where
> + * the page is neither locked nor the mapping->host pinned. On s390 in this
> + * case the page lock will be taken to pin the mapping if the page needs to
> + * be set dirty.
> + */
> +void page_remove_rmap_nolock(struct page *page)
> +{
> +	propogate_storage_key(page, true);
> +	__page_remove_rmap(page);
> +}
> +
>  /*
>   * Subfunctions of try_to_unmap: try_to_unmap_one called
>   * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
