Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 8A4B36B0038
	for <linux-mm@kvack.org>; Mon, 26 Oct 2015 23:44:20 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so208381505pad.1
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 20:44:20 -0700 (PDT)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id of6si58312721pbc.54.2015.10.26.20.44.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Oct 2015 20:44:19 -0700 (PDT)
Received: by pasz6 with SMTP id z6so207990899pas.2
        for <linux-mm@kvack.org>; Mon, 26 Oct 2015 20:44:19 -0700 (PDT)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.0 \(3094\))
Subject: Re: [PATCH 4/5] mm: simplify reclaim path for MADV_FREE
From: yalin wang <yalin.wang2010@gmail.com>
In-Reply-To: <alpine.LSU.2.11.1510261828350.10825@eggly.anvils>
Date: Tue, 27 Oct 2015 11:44:09 +0800
Content-Transfer-Encoding: quoted-printable
Message-Id: <EDCE64A3-D874-4FE3-91B5-DE5E26A452F5@gmail.com>
References: <1445236307-895-1-git-send-email-minchan@kernel.org> <1445236307-895-5-git-send-email-minchan@kernel.org> <alpine.LSU.2.11.1510261828350.10825@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "open list:MEMORY MANAGEMENT" <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>


> On Oct 27, 2015, at 10:09, Hugh Dickins <hughd@google.com> wrote:
>=20
> On Mon, 19 Oct 2015, Minchan Kim wrote:
>=20
>> I made reclaim path mess to check and free MADV_FREEed page.
>> This patch simplify it with tweaking add_to_swap.
>>=20
>> So far, we mark page as PG_dirty when we add the page into
>> swap cache(ie, add_to_swap) to page out to swap device but
>> this patch moves PG_dirty marking under try_to_unmap_one
>> when we decide to change pte from anon to swapent so if
>> any process's pte has swapent for the page, the page must
>> be swapped out. IOW, there should be no funcional behavior
>> change. It makes relcaim path really simple for MADV_FREE
>> because we just need to check PG_dirty of page to decide
>> discarding the page or not.
>>=20
>> Other thing this patch does is to pass TTU_BATCH_FLUSH to
>> try_to_unmap when we handle freeable page because I don't
>> see any reason to prevent it.
>>=20
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Signed-off-by: Minchan Kim <minchan@kernel.org>
>=20
> Acked-by: Hugh Dickins <hughd@google.com>
>=20
> This is sooooooo much nicer than the code it replaces!  Really good.
> Kudos also to Hannes for suggesting this approach originally, I think.
>=20
> I hope this implementation satisfies a good proportion of the people
> who have been wanting MADV_FREE: I'm not among them, and have long
> lost touch with those discussions, so won't judge how usable it is.
>=20
> I assume you'll refactor the series again before it goes to Linus,
> so the previous messier implementations vanish?  I notice Andrew
> has this "mm: simplify reclaim path for MADV_FREE" in mmotm as
> mm-dont-split-thp-page-when-syscall-is-called-fix-6.patch:
> I guess it all got much too messy to divide up in a hurry.
>=20
> I've noticed no problems in testing (unlike the first time you moved
> to working with pte_dirty); though of course I've not been using
> MADV_FREE itself at all.
>=20
> One aspect has worried me for a while, but I think I've reached the
> conclusion that it doesn't matter at all.  The swap that's allocated
> in add_to_swap() would normally get freed again (after try_to_unmap
> found it was a MADV_FREE !pte_dirty !PageDirty case) at the bottom
> of shrink_page_list(), in __remove_mapping(), yes?
>=20
> The bit that worried me is that on rare occasions, something unknown
> might take a speculative reference to the page, and __remove_mapping()
> fail to freeze refs for that reason.  Much too rare to worry over not
> freeing that page immediately, but it leaves us with a PageUptodate
> PageSwapCache !PageDirty page, yet its contents are not the contents
> of that location on swap.
>=20
> But since this can only happen when you have *not* inserted the
> corresponding swapent anywhere, I cannot think of anything that would
> have a legitimate interest in its contents matching that location on =
swap.
> So I don't think it's worth looking for somewhere to add a =
SetPageDirty
> (or a delete_from_swap_cache) just to regularize that case.
>=20
>> ---
>> include/linux/rmap.h |  6 +----
>> mm/huge_memory.c     |  5 ----
>> mm/rmap.c            | 42 ++++++----------------------------
>> mm/swap_state.c      |  5 ++--
>> mm/vmscan.c          | 64 =
++++++++++++++++------------------------------------
>> 5 files changed, 30 insertions(+), 92 deletions(-)
>>=20
>> diff --git a/include/linux/rmap.h b/include/linux/rmap.h
>> index 6b6233fafb53..978f65066fd5 100644
>> --- a/include/linux/rmap.h
>> +++ b/include/linux/rmap.h
>> @@ -193,8 +193,7 @@ static inline void page_dup_rmap(struct page =
*page, bool compound)
>>  * Called from mm/vmscan.c to handle paging out
>>  */
>> int page_referenced(struct page *, int is_locked,
>> -			struct mem_cgroup *memcg, unsigned long =
*vm_flags,
>> -			int *is_pte_dirty);
>> +			struct mem_cgroup *memcg, unsigned long =
*vm_flags);
>>=20
>> #define TTU_ACTION(x) ((x) & TTU_ACTION_MASK)
>>=20
>> @@ -272,11 +271,8 @@ int rmap_walk(struct page *page, struct =
rmap_walk_control *rwc);
>> static inline int page_referenced(struct page *page, int is_locked,
>> 				  struct mem_cgroup *memcg,
>> 				  unsigned long *vm_flags,
>> -				  int *is_pte_dirty)
>> {
>> 	*vm_flags =3D 0;
>> -	if (is_pte_dirty)
>> -		*is_pte_dirty =3D 0;
>> 	return 0;
>> }
>>=20
>> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
>> index 269ed99493f0..adccfb48ce57 100644
>> --- a/mm/huge_memory.c
>> +++ b/mm/huge_memory.c
>> @@ -1753,11 +1753,6 @@ pmd_t *page_check_address_pmd(struct page =
*page,
>> 	return NULL;
>> }
>>=20
>> -int pmd_freeable(pmd_t pmd)
>> -{
>> -	return !pmd_dirty(pmd);
>> -}
>> -
>> #define VM_NO_THP (VM_SPECIAL | VM_HUGETLB | VM_SHARED | VM_MAYSHARE)
>>=20
>> int hugepage_madvise(struct vm_area_struct *vma,
>> diff --git a/mm/rmap.c b/mm/rmap.c
>> index 94ee372e238b..fd64f79c87c4 100644
>> --- a/mm/rmap.c
>> +++ b/mm/rmap.c
>> @@ -797,7 +797,6 @@ int page_mapped_in_vma(struct page *page, struct =
vm_area_struct *vma)
>> }
>>=20
>> struct page_referenced_arg {
>> -	int dirtied;
>> 	int mapcount;
>> 	int referenced;
>> 	unsigned long vm_flags;
>> @@ -812,7 +811,6 @@ static int page_referenced_one(struct page *page, =
struct vm_area_struct *vma,
>> 	struct mm_struct *mm =3D vma->vm_mm;
>> 	spinlock_t *ptl;
>> 	int referenced =3D 0;
>> -	int dirty =3D 0;
>> 	struct page_referenced_arg *pra =3D arg;
>>=20
>> 	if (unlikely(PageTransHuge(page))) {
>> @@ -835,14 +833,6 @@ static int page_referenced_one(struct page =
*page, struct vm_area_struct *vma,
>> 		if (pmdp_clear_flush_young_notify(vma, address, pmd))
>> 			referenced++;
>>=20
>> -		/*
>> -		 * Use pmd_freeable instead of raw pmd_dirty because in =
some
>> -		 * of architecture, pmd_dirty is not defined unless
>> -		 * CONFIG_TRANSPARENT_HUGEPAGE is enabled
>> -		 */
>> -		if (!pmd_freeable(*pmd))
>> -			dirty++;
>> -
>> 		spin_unlock(ptl);
>> 	} else {
>> 		pte_t *pte;
>> @@ -873,9 +863,6 @@ static int page_referenced_one(struct page *page, =
struct vm_area_struct *vma,
>> 				referenced++;
>> 		}
>>=20
>> -		if (pte_dirty(*pte))
>> -			dirty++;
>> -
>> 		pte_unmap_unlock(pte, ptl);
>> 	}
>>=20
>> @@ -889,9 +876,6 @@ static int page_referenced_one(struct page *page, =
struct vm_area_struct *vma,
>> 		pra->vm_flags |=3D vma->vm_flags;
>> 	}
>>=20
>> -	if (dirty)
>> -		pra->dirtied++;
>> -
>> 	pra->mapcount--;
>> 	if (!pra->mapcount)
>> 		return SWAP_SUCCESS; /* To break the loop */
>> @@ -916,7 +900,6 @@ static bool invalid_page_referenced_vma(struct =
vm_area_struct *vma, void *arg)
>>  * @is_locked: caller holds lock on the page
>>  * @memcg: target memory cgroup
>>  * @vm_flags: collect encountered vma->vm_flags who actually =
referenced the page
>> - * @is_pte_dirty: ptes which have marked dirty bit - used for =
lazyfree page
>>  *
>>  * Quick test_and_clear_referenced for all mappings to a page,
>>  * returns the number of ptes which referenced the page.
>> @@ -924,8 +907,7 @@ static bool invalid_page_referenced_vma(struct =
vm_area_struct *vma, void *arg)
>> int page_referenced(struct page *page,
>> 		    int is_locked,
>> 		    struct mem_cgroup *memcg,
>> -		    unsigned long *vm_flags,
>> -		    int *is_pte_dirty)
>> +		    unsigned long *vm_flags)
>> {
>> 	int ret;
>> 	int we_locked =3D 0;
>> @@ -940,8 +922,6 @@ int page_referenced(struct page *page,
>> 	};
>>=20
>> 	*vm_flags =3D 0;
>> -	if (is_pte_dirty)
>> -		*is_pte_dirty =3D 0;
>>=20
>> 	if (!page_mapped(page))
>> 		return 0;
>> @@ -970,9 +950,6 @@ int page_referenced(struct page *page,
>> 	if (we_locked)
>> 		unlock_page(page);
>>=20
>> -	if (is_pte_dirty)
>> -		*is_pte_dirty =3D pra.dirtied;
>> -
>> 	return pra.referenced;
>> }
>>=20
>> @@ -1453,17 +1430,10 @@ static int try_to_unmap_one(struct page =
*page, struct vm_area_struct *vma,
>> 		swp_entry_t entry =3D { .val =3D page_private(page) };
>> 		pte_t swp_pte;
>>=20
>> -		if (flags & TTU_FREE) {
>> -			VM_BUG_ON_PAGE(PageSwapCache(page), page);
>> -			if (!PageDirty(page)) {
>> -				/* It's a freeable page by MADV_FREE */
>> -				dec_mm_counter(mm, MM_ANONPAGES);
>> -				goto discard;
>> -			} else {
>> -				set_pte_at(mm, address, pte, pteval);
>> -				ret =3D SWAP_FAIL;
>> -				goto out_unmap;
>> -			}
>> +		if (!PageDirty(page) && (flags & TTU_FREE)) {
>> +			/* It's a freeable page by MADV_FREE */
>> +			dec_mm_counter(mm, MM_ANONPAGES);
>> +			goto discard;
>> 		}
>>=20
>> 		if (PageSwapCache(page)) {
>> @@ -1476,6 +1446,8 @@ static int try_to_unmap_one(struct page *page, =
struct vm_area_struct *vma,
>> 				ret =3D SWAP_FAIL;
>> 				goto out_unmap;
>> 			}
>> +			if (!PageDirty(page))
>> +				SetPageDirty(page);
>> 			if (list_empty(&mm->mmlist)) {
>> 				spin_lock(&mmlist_lock);
>> 				if (list_empty(&mm->mmlist))
>> diff --git a/mm/swap_state.c b/mm/swap_state.c
>> index d783872d746c..676ff2991380 100644
>> --- a/mm/swap_state.c
>> +++ b/mm/swap_state.c
>> @@ -185,13 +185,12 @@ int add_to_swap(struct page *page, struct =
list_head *list)
>> 	 * deadlock in the swap out path.
>> 	 */
>> 	/*
>> -	 * Add it to the swap cache and mark it dirty
>> +	 * Add it to the swap cache.
>> 	 */
>> 	err =3D add_to_swap_cache(page, entry,
>> 			__GFP_HIGH|__GFP_NOMEMALLOC|__GFP_NOWARN);
>>=20
>> -	if (!err) {	/* Success */
>> -		SetPageDirty(page);
>> +	if (!err) {
>> 		return 1;
>> 	} else {	/* -ENOMEM radix-tree allocation failure */
>> 		/*
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index 27d580b5e853..9b52ecf91194 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -791,17 +791,15 @@ enum page_references {
>> };
>>=20
>> static enum page_references page_check_references(struct page *page,
>> -						  struct scan_control =
*sc,
>> -						  bool *freeable)
>> +						  struct scan_control =
*sc)
>> {
>> 	int referenced_ptes, referenced_page;
>> 	unsigned long vm_flags;
>> -	int pte_dirty;
>>=20
>> 	VM_BUG_ON_PAGE(!PageLocked(page), page);
>>=20
>> 	referenced_ptes =3D page_referenced(page, 1, =
sc->target_mem_cgroup,
>> -					  &vm_flags, &pte_dirty);
>> +					  &vm_flags);
>> 	referenced_page =3D TestClearPageReferenced(page);
>>=20
>> 	/*
>> @@ -842,10 +840,6 @@ static enum page_references =
page_check_references(struct page *page,
>> 		return PAGEREF_KEEP;
>> 	}
>>=20
>> -	if (PageAnon(page) && !pte_dirty && !PageSwapCache(page) &&
>> -			!PageDirty(page))
>> -		*freeable =3D true;
>> -
>> 	/* Reclaim if clean, defer dirty pages to writeback */
>> 	if (referenced_page && !PageSwapBacked(page))
>> 		return PAGEREF_RECLAIM_CLEAN;
>> @@ -1037,8 +1031,7 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,
>> 		}
>>=20
>> 		if (!force_reclaim)
>> -			references =3D page_check_references(page, sc,
>> -							&freeable);
>> +			references =3D page_check_references(page, sc);
>>=20
>> 		switch (references) {
>> 		case PAGEREF_ACTIVATE:
>> @@ -1055,31 +1048,24 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,
>> 		 * Try to allocate it some swap space here.
>> 		 */
>> 		if (PageAnon(page) && !PageSwapCache(page)) {
>> -			if (!freeable) {
>> -				if (!(sc->gfp_mask & __GFP_IO))
>> -					goto keep_locked;
>> -				if (!add_to_swap(page, page_list))
>> -					goto activate_locked;
>> -				may_enter_fs =3D 1;
>> -				/* Adding to swap updated mapping */
>> -				mapping =3D page_mapping(page);
>> -			} else {
>> -				if (likely(!PageTransHuge(page)))
>> -					goto unmap;
>> -				/* try_to_unmap isn't aware of THP page =
*/
>> -				if =
(unlikely(split_huge_page_to_list(page,
>> -								=
page_list)))
>> -					goto keep_locked;
>> -			}
>> +			if (!(sc->gfp_mask & __GFP_IO))
>> +				goto keep_locked;
>> +			if (!add_to_swap(page, page_list))
>> +				goto activate_locked;
>> +			freeable =3D true;
>> +			may_enter_fs =3D 1;
>> +			/* Adding to swap updated mapping */
>> +			mapping =3D page_mapping(page);
>> 		}
>> -unmap:
>> +
>> 		/*
>> 		 * The page is mapped into the page tables of one or =
more
>> 		 * processes. Try to unmap it here.
>> 		 */
>> -		if (page_mapped(page) && (mapping || freeable)) {
>> +		if (page_mapped(page) && mapping) {
>> 			switch (try_to_unmap(page, freeable ?
>> -					TTU_FREE : =
ttu_flags|TTU_BATCH_FLUSH)) {
>> +					ttu_flags | TTU_BATCH_FLUSH | =
TTU_FREE :
>> +					ttu_flags | TTU_BATCH_FLUSH)) {
>> 			case SWAP_FAIL:
>> 				goto activate_locked;
>> 			case SWAP_AGAIN:
>> @@ -1087,20 +1073,7 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,
>> 			case SWAP_MLOCK:
>> 				goto cull_mlocked;
>> 			case SWAP_SUCCESS:
>> -				/* try to free the page below */
>> -				if (!freeable)
>> -					break;
>> -				/*
>> -				 * Freeable anon page doesn't have =
mapping
>> -				 * due to skipping of swapcache so we =
free
>> -				 * page in here rather than =
__remove_mapping.
>> -				 */
>> -				VM_BUG_ON_PAGE(PageSwapCache(page), =
page);
>> -				if (!page_freeze_refs(page, 1))
>> -					goto keep_locked;
>> -				__ClearPageLocked(page);
>> -				count_vm_event(PGLAZYFREED);
>> -				goto free_it;
>> +				; /* try to free the page below */
>> 			}
>> 		}
>>=20
>> @@ -1217,6 +1190,9 @@ static unsigned long shrink_page_list(struct =
list_head *page_list,
>> 		 */
>> 		__ClearPageLocked(page);
>> free_it:
>> +		if (freeable && !PageDirty(page))
>> +			count_vm_event(PGLAZYFREED);
>> +
>> 		nr_reclaimed++;
>>=20
>> 		/*
>> @@ -1847,7 +1823,7 @@ static void shrink_active_list(unsigned long =
nr_to_scan,
>> 		}
>>=20
>> 		if (page_referenced(page, 0, sc->target_mem_cgroup,
>> -				    &vm_flags, NULL)) {
>> +				    &vm_flags)) {
>> 			nr_rotated +=3D hpage_nr_pages(page);
>> 			/*
>> 			 * Identify referenced, file-backed active pages =
and
>> --=20
>> 1.9.1
> --
> To unsubscribe from this list: send the line "unsubscribe =
linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
it is wrong here if you only check PageDirty() to decide if the page is =
freezable or not .
The Anon page are shared by multiple process, _mapcount > 1 ,
so you must check all pt_dirty bit during page_referenced() function,
see this mail thread:
http://ns1.ske-art.com/lists/kernel/msg1934021.html
Thanks









--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
