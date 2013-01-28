Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 9A4E66B0007
	for <linux-mm@kvack.org>; Sun, 27 Jan 2013 21:12:28 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb11so1217308pad.24
        for <linux-mm@kvack.org>; Sun, 27 Jan 2013 18:12:27 -0800 (PST)
Message-ID: <1359339147.6763.25.camel@kernel>
Subject: Re: [PATCH 6/11] ksm: remove old stable nodes more thoroughly
From: Simon Jeons <simon.jeons@gmail.com>
Date: Sun, 27 Jan 2013 20:12:27 -0600
In-Reply-To: <alpine.LNX.2.00.1301251800550.29196@eggly.anvils>
References: <alpine.LNX.2.00.1301251747590.29196@eggly.anvils>
	 <alpine.LNX.2.00.1301251800550.29196@eggly.anvils>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2013-01-25 at 18:01 -0800, Hugh Dickins wrote:
> Switching merge_across_nodes after running KSM is liable to oops on stale
> nodes still left over from the previous stable tree.  It's not something

Since this patch solve the problem, so the description of
merge_across_nodes(Value can be changed only when there is no ksm shared
pages in system) should be changed in this patch.

> that people will often want to do, but it would be lame to demand a reboot
> when they're trying to determine which merge_across_nodes setting is best.
> 
> How can this happen?  We only permit switching merge_across_nodes when
> pages_shared is 0, and usually set run 2 to force that beforehand, which
> ought to unmerge everything: yet oopses still occur when you then run 1.
> 
> Three causes:
> 
> 1. The old stable tree (built according to the inverse merge_across_nodes)
> has not been fully torn down.  A stable node lingers until get_ksm_page()
> notices that the page it references no longer references it: but the page
> is not necessarily freed as soon as expected, particularly when swapcache.
> 
> Fix this with a pass through the old stable tree, applying get_ksm_page()
> to each of the remaining nodes (most found stale and removed immediately),
> with forced removal of any left over.  Unless the page is still mapped:
> I've not seen that case, it shouldn't occur, but better to WARN_ON_ONCE
> and EBUSY than BUG.
> 
> 2. __ksm_enter() has a nice little optimization, to insert the new mm
> just behind ksmd's cursor, so there's a full pass for it to stabilize
> (or be removed) before ksmd addresses it.  Nice when ksmd is running,
> but not so nice when we're trying to unmerge all mms: we were missing
> those mms forked and inserted behind the unmerge cursor.  Easily fixed
> by inserting at the end when KSM_RUN_UNMERGE.
> 
> 3. It is possible for a KSM page to be faulted back from swapcache into
> an mm, just after unmerge_and_remove_all_rmap_items() scanned past it.
> Fix this by copying on fault when KSM_RUN_UNMERGE: but that is private
> to ksm.c, so dissolve the distinction between ksm_might_need_to_copy()
> and ksm_does_need_to_copy(), doing it all in the one call into ksm.c.
> 
> A long outstanding, unrelated bugfix sneaks in with that third fix:
> ksm_does_need_to_copy() would copy from a !PageUptodate page (implying
> I/O error when read in from swap) to a page which it then marks Uptodate.
> Fix this case by not copying, letting do_swap_page() discover the error.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
>  include/linux/ksm.h |   18 ++-------
>  mm/ksm.c            |   83 +++++++++++++++++++++++++++++++++++++++---
>  mm/memory.c         |   19 ++++-----
>  3 files changed, 92 insertions(+), 28 deletions(-)
> 
> --- mmotm.orig/include/linux/ksm.h	2013-01-25 14:27:58.220193250 -0800
> +++ mmotm/include/linux/ksm.h	2013-01-25 14:37:00.764206145 -0800
> @@ -16,9 +16,6 @@
>  struct stable_node;
>  struct mem_cgroup;
>  
> -struct page *ksm_does_need_to_copy(struct page *page,
> -			struct vm_area_struct *vma, unsigned long address);
> -
>  #ifdef CONFIG_KSM
>  int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
>  		unsigned long end, int advice, unsigned long *vm_flags);
> @@ -73,15 +70,8 @@ static inline void set_page_stable_node(
>   * We'd like to make this conditional on vma->vm_flags & VM_MERGEABLE,
>   * but what if the vma was unmerged while the page was swapped out?
>   */
> -static inline int ksm_might_need_to_copy(struct page *page,
> -			struct vm_area_struct *vma, unsigned long address)
> -{
> -	struct anon_vma *anon_vma = page_anon_vma(page);
> -
> -	return anon_vma &&
> -		(anon_vma->root != vma->anon_vma->root ||
> -		 page->index != linear_page_index(vma, address));
> -}
> +struct page *ksm_might_need_to_copy(struct page *page,
> +			struct vm_area_struct *vma, unsigned long address);
>  
>  int page_referenced_ksm(struct page *page,
>  			struct mem_cgroup *memcg, unsigned long *vm_flags);
> @@ -113,10 +103,10 @@ static inline int ksm_madvise(struct vm_
>  	return 0;
>  }
>  
> -static inline int ksm_might_need_to_copy(struct page *page,
> +static inline struct page *ksm_might_need_to_copy(struct page *page,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
> -	return 0;
> +	return page;
>  }
>  
>  static inline int page_referenced_ksm(struct page *page,
> --- mmotm.orig/mm/ksm.c	2013-01-25 14:36:58.856206099 -0800
> +++ mmotm/mm/ksm.c	2013-01-25 14:37:00.768206145 -0800
> @@ -644,6 +644,57 @@ static int unmerge_ksm_pages(struct vm_a
>  /*
>   * Only called through the sysfs control interface:
>   */
> +static int remove_stable_node(struct stable_node *stable_node)
> +{
> +	struct page *page;
> +	int err;
> +
> +	page = get_ksm_page(stable_node, true);
> +	if (!page) {
> +		/*
> +		 * get_ksm_page did remove_node_from_stable_tree itself.
> +		 */
> +		return 0;
> +	}
> +
> +	if (WARN_ON_ONCE(page_mapped(page)))
> +		err = -EBUSY;
> +	else {
> +		/*
> +		 * This page might be in a pagevec waiting to be freed,
> +		 * or it might be PageSwapCache (perhaps under writeback),
> +		 * or it might have been removed from swapcache a moment ago.
> +		 */
> +		set_page_stable_node(page, NULL);
> +		remove_node_from_stable_tree(stable_node);
> +		err = 0;
> +	}
> +
> +	unlock_page(page);
> +	put_page(page);
> +	return err;
> +}
> +
> +static int remove_all_stable_nodes(void)
> +{
> +	struct stable_node *stable_node;
> +	int nid;
> +	int err = 0;
> +
> +	for (nid = 0; nid < nr_node_ids; nid++) {
> +		while (root_stable_tree[nid].rb_node) {
> +			stable_node = rb_entry(root_stable_tree[nid].rb_node,
> +						struct stable_node, node);
> +			if (remove_stable_node(stable_node)) {
> +				err = -EBUSY;
> +				break;	/* proceed to next nid */
> +			}
> +			cond_resched();
> +		}
> +	}
> +	return err;
> +}
> +
>  static int unmerge_and_remove_all_rmap_items(void)
>  {
>  	struct mm_slot *mm_slot;
> @@ -691,6 +742,8 @@ static int unmerge_and_remove_all_rmap_i
>  		}
>  	}
>  
> +	/* Clean up stable nodes, but don't worry if some are still busy */
> +	remove_all_stable_nodes();
>  	ksm_scan.seqnr = 0;
>  	return 0;
>  
> @@ -1586,11 +1639,19 @@ int __ksm_enter(struct mm_struct *mm)
>  	spin_lock(&ksm_mmlist_lock);
>  	insert_to_mm_slots_hash(mm, mm_slot);
>  	/*
> -	 * Insert just behind the scanning cursor, to let the area settle
> +	 * When KSM_RUN_MERGE (or KSM_RUN_STOP),
> +	 * insert just behind the scanning cursor, to let the area settle
>  	 * down a little; when fork is followed by immediate exec, we don't
>  	 * want ksmd to waste time setting up and tearing down an rmap_list.
> +	 *
> +	 * But when KSM_RUN_UNMERGE, it's important to insert ahead of its
> +	 * scanning cursor, otherwise KSM pages in newly forked mms will be
> +	 * missed: then we might as well insert at the end of the list.
>  	 */
> -	list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
> +	if (ksm_run & KSM_RUN_UNMERGE)
> +		list_add_tail(&mm_slot->mm_list, &ksm_mm_head.mm_list);
> +	else
> +		list_add_tail(&mm_slot->mm_list, &ksm_scan.mm_slot->mm_list);
>  	spin_unlock(&ksm_mmlist_lock);
>  
>  	set_bit(MMF_VM_MERGEABLE, &mm->flags);
> @@ -1640,11 +1701,25 @@ void __ksm_exit(struct mm_struct *mm)
>  	}
>  }
>  
> -struct page *ksm_does_need_to_copy(struct page *page,
> +struct page *ksm_might_need_to_copy(struct page *page,
>  			struct vm_area_struct *vma, unsigned long address)
>  {
> +	struct anon_vma *anon_vma = page_anon_vma(page);
>  	struct page *new_page;
>  
> +	if (PageKsm(page)) {
> +		if (page_stable_node(page) &&
> +		    !(ksm_run & KSM_RUN_UNMERGE))
> +			return page;	/* no need to copy it */
> +	} else if (!anon_vma) {
> +		return page;		/* no need to copy it */
> +	} else if (anon_vma->root == vma->anon_vma->root &&
> +		 page->index == linear_page_index(vma, address)) {
> +		return page;		/* still no need to copy it */
> +	}
> +	if (!PageUptodate(page))
> +		return page;		/* let do_swap_page report the error */
> +
>  	new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
>  	if (new_page) {
>  		copy_user_highpage(new_page, page, address, vma);
> @@ -2024,7 +2099,7 @@ static ssize_t merge_across_nodes_store(
>  
>  	mutex_lock(&ksm_thread_mutex);
>  	if (ksm_merge_across_nodes != knob) {
> -		if (ksm_pages_shared)
> +		if (ksm_pages_shared || remove_all_stable_nodes())
>  			err = -EBUSY;
>  		else
>  			ksm_merge_across_nodes = knob;
> --- mmotm.orig/mm/memory.c	2013-01-25 14:27:58.220193250 -0800
> +++ mmotm/mm/memory.c	2013-01-25 14:37:00.768206145 -0800
> @@ -2994,17 +2994,16 @@ static int do_swap_page(struct mm_struct
>  	if (unlikely(!PageSwapCache(page) || page_private(page) != entry.val))
>  		goto out_page;
>  
> -	if (ksm_might_need_to_copy(page, vma, address)) {
> -		swapcache = page;
> -		page = ksm_does_need_to_copy(page, vma, address);
> -
> -		if (unlikely(!page)) {
> -			ret = VM_FAULT_OOM;
> -			page = swapcache;
> -			swapcache = NULL;
> -			goto out_page;
> -		}
> +	swapcache = page;
> +	page = ksm_might_need_to_copy(page, vma, address);
> +	if (unlikely(!page)) {
> +		ret = VM_FAULT_OOM;
> +		page = swapcache;
> +		swapcache = NULL;
> +		goto out_page;
>  	}
> +	if (page == swapcache)
> +		swapcache = NULL;
>  
>  	if (mem_cgroup_try_charge_swapin(mm, page, GFP_KERNEL, &ptr)) {
>  		ret = VM_FAULT_OOM;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
