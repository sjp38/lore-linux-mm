Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3BA146B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 03:26:49 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id c193so22675351pfb.7
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 00:26:49 -0800 (PST)
Received: from tyo162.gate.nec.co.jp (tyo162.gate.nec.co.jp. [114.179.232.162])
        by mx.google.com with ESMTPS id z29si1784605pgc.417.2017.02.24.00.26.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 00:26:47 -0800 (PST)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [RFC PATCH 08/14] mm: migrate: Add concurrent page migration
 into move_pages syscall.
Date: Fri, 24 Feb 2017 08:25:41 +0000
Message-ID: <20170224082540.GA27769@hori1.linux.bs1.fc.nec.co.jp>
References: <20170217150551.117028-1-zi.yan@sent.com>
 <20170217150551.117028-9-zi.yan@sent.com>
In-Reply-To: <20170217150551.117028-9-zi.yan@sent.com>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <FC2ADCFC5E3858489A110B2AD3E6324F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "dnellans@nvidia.com" <dnellans@nvidia.com>, "apopple@au1.ibm.com" <apopple@au1.ibm.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>, "khandual@linux.vnet.ibm.com" <khandual@linux.vnet.ibm.com>, "zi.yan@cs.rutgers.edu" <zi.yan@cs.rutgers.edu>

On Fri, Feb 17, 2017 at 10:05:45AM -0500, Zi Yan wrote:
> From: Zi Yan <ziy@nvidia.com>
>
> Concurrent page migration moves a list of pages all together,
> concurrently via multi-threaded. This is different from
> existing page migration process which migrate pages sequentially.
> Current implementation only migrates anonymous pages.

Please explain more about your new migration scheme, especially
difference from original page migration code is very imporatant
for reviewers and other developers to understand your work quickly.

>
> Signed-off-by: Zi Yan <ziy@nvidia.com>
> ---
>  include/linux/migrate_mode.h   |   1 +
>  include/uapi/linux/mempolicy.h |   1 +
>  mm/migrate.c                   | 495 +++++++++++++++++++++++++++++++++++=
+++++-
>  3 files changed, 492 insertions(+), 5 deletions(-)
>
> diff --git a/include/linux/migrate_mode.h b/include/linux/migrate_mode.h
> index d344ad60f499..2bd849d89122 100644
> --- a/include/linux/migrate_mode.h
> +++ b/include/linux/migrate_mode.h
> @@ -13,6 +13,7 @@ enum migrate_mode {
>  	MIGRATE_SYNC		=3D 1<<2,
>  	MIGRATE_ST		=3D 1<<3,
>  	MIGRATE_MT		=3D 1<<4,
> +	MIGRATE_CONCUR		=3D 1<<5,

This new flag MIGRATE_CONCUR seems unused from other code, so is it unneede=
d
now, or is there a typo somewhere?

>  };
>
>  #endif		/* MIGRATE_MODE_H_INCLUDED */
> diff --git a/include/uapi/linux/mempolicy.h b/include/uapi/linux/mempolic=
y.h
> index 8f1db2e2d677..6d9758a32053 100644
> --- a/include/uapi/linux/mempolicy.h
> +++ b/include/uapi/linux/mempolicy.h
> @@ -54,6 +54,7 @@ enum mpol_rebind_step {
>  #define MPOL_MF_LAZY	 (1<<3)	/* Modifies '_MOVE:  lazy migrate on fault =
*/
>  #define MPOL_MF_INTERNAL (1<<4)	/* Internal flags start here */
>  #define MPOL_MF_MOVE_MT  (1<<6)	/* Use multi-threaded page copy routine =
*/
> +#define MPOL_MF_MOVE_CONCUR  (1<<7)	/* Migrate a list of pages concurren=
tly */
>
>  #define MPOL_MF_VALID	(MPOL_MF_STRICT   | 	\
>  			 MPOL_MF_MOVE     | 	\
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 0e9b1f17cf8b..a35e6fd43a50 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -50,6 +50,14 @@
>
>  int mt_page_copy =3D 0;
>
> +
> +struct page_migration_work_item {
> +	struct page *old_page;
> +	struct page *new_page;
> +	struct anon_vma *anon_vma;
> +	struct list_head list;
> +};
> +
>  /*
>   * migrate_prep() needs to be called before we start compiling a list of=
 pages
>   * to be migrated using isolate_lru_page(). If scheduling work on other =
CPUs is
> @@ -1312,6 +1320,471 @@ static int unmap_and_move_huge_page(new_page_t ge=
t_new_page,
>  	return rc;
>  }
>
> +static int __unmap_page_concur(struct page *page, struct page *newpage,

Most code of this function is a copy of __unmap_and_move(), so please defin=
e
a new subfunction, and make __unmap_page_concur() and __unmap_and_move()
call it.

> +				struct anon_vma **anon_vma,
> +				int force, enum migrate_mode mode)
> +{
> +	int rc =3D -EAGAIN;
> +
> +	if (!trylock_page(page)) {
> +		if (!force || mode =3D=3D MIGRATE_ASYNC)
> +			goto out;
> +
> +		/*
> +		 * It's not safe for direct compaction to call lock_page.
> +		 * For example, during page readahead pages are added locked
> +		 * to the LRU. Later, when the IO completes the pages are
> +		 * marked uptodate and unlocked. However, the queueing
> +		 * could be merging multiple pages for one bio (e.g.
> +		 * mpage_readpages). If an allocation happens for the
> +		 * second or third page, the process can end up locking
> +		 * the same page twice and deadlocking. Rather than
> +		 * trying to be clever about what pages can be locked,
> +		 * avoid the use of lock_page for direct compaction
> +		 * altogether.
> +		 */
> +		if (current->flags & PF_MEMALLOC)
> +			goto out;
> +
> +		lock_page(page);
> +	}
> +
> +	/* We are working on page_mapping(page) =3D=3D NULL */
> +	VM_BUG_ON_PAGE(PageWriteback(page), page);

Although anonymous page shouldn't have PageWriteback, but existing migratio=
n
code (below) doesn't call VM_BUG_ON_PAGE even in that case. Any special rea=
son
to do differently for concurrent migration?

        if (PageWriteback(page)) {
                /*
                 * Only in the case of a full synchronous migration is it
                 * necessary to wait for PageWriteback. In the async case,
                 * the retry loop is too short and in the sync-light case,
                 * the overhead of stalling is too much
                 */
                if (mode !=3D MIGRATE_SYNC) {
                        rc =3D -EBUSY;
                        goto out_unlock;
                }
                if (!force)
                        goto out_unlock;
                wait_on_page_writeback(page);
        }

> +
> +	/*
> +	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
> +	 * we cannot notice that anon_vma is freed while we migrates a page.
> +	 * This get_anon_vma() delays freeing anon_vma pointer until the end
> +	 * of migration. File cache pages are no problem because of page_lock()
> +	 * File Caches may use write_page() or lock_page() in migration, then,
> +	 * just care Anon page here.
> +	 *
> +	 * Only page_get_anon_vma() understands the subtleties of
> +	 * getting a hold on an anon_vma from outside one of its mms.
> +	 * But if we cannot get anon_vma, then we won't need it anyway,
> +	 * because that implies that the anon page is no longer mapped
> +	 * (and cannot be remapped so long as we hold the page lock).
> +	 */
> +	if (PageAnon(page) && !PageKsm(page))
> +		*anon_vma =3D page_get_anon_vma(page);
> +
> +	/*
> +	 * Block others from accessing the new page when we get around to
> +	 * establishing additional references. We are usually the only one
> +	 * holding a reference to newpage at this point. We used to have a BUG
> +	 * here if trylock_page(newpage) fails, but would like to allow for
> +	 * cases where there might be a race with the previous use of newpage.
> +	 * This is much like races on refcount of oldpage: just don't BUG().
> +	 */
> +	if (unlikely(!trylock_page(newpage)))
> +		goto out_unlock;
> +
> +	/*
> +	 * Corner case handling:
> +	 * 1. When a new swap-cache page is read into, it is added to the LRU
> +	 * and treated as swapcache but it has no rmap yet.
> +	 * Calling try_to_unmap() against a page->mapping=3D=3DNULL page will
> +	 * trigger a BUG.  So handle it here.
> +	 * 2. An orphaned page (see truncate_complete_page) might have
> +	 * fs-private metadata. The page can be picked up due to memory
> +	 * offlining.  Everywhere else except page reclaim, the page is
> +	 * invisible to the vm, so the page can not be migrated.  So try to
> +	 * free the metadata, so the page can be freed.
> +	 */
> +	if (!page->mapping) {
> +		VM_BUG_ON_PAGE(PageAnon(page), page);
> +		if (page_has_private(page)) {
> +			try_to_free_buffers(page);
> +			goto out_unlock_both;
> +		}
> +	} else {
> +		VM_BUG_ON_PAGE(!page_mapped(page), page);
> +		/* Establish migration ptes */
> +		VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !*anon_vma,
> +				page);
> +		rc =3D try_to_unmap(page,
> +			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> +	}
> +
> +	return rc;
> +
> +out_unlock_both:
> +	unlock_page(newpage);
> +out_unlock:
> +	/* Drop an anon_vma reference if we took one */
> +	if (*anon_vma)
> +		put_anon_vma(*anon_vma);
> +	unlock_page(page);
> +out:
> +	return rc;
> +}
> +
> +static int unmap_pages_and_get_new_concur(new_page_t get_new_page,
> +				free_page_t put_new_page, unsigned long private,
> +				struct page_migration_work_item *item,
> +				int force,
> +				enum migrate_mode mode, int reason)

Here many duplicates too, but you give struct page_migration_work_item
as an argument, so this duplicates might be OK.

> +{
> +	int rc =3D MIGRATEPAGE_SUCCESS;
> +	int *result =3D NULL;
> +
> +
> +	item->new_page =3D get_new_page(item->old_page, private, &result);
> +
> +	if (!item->new_page) {
> +		rc =3D -ENOMEM;
> +		return rc;
> +	}
> +
> +	if (page_count(item->old_page) =3D=3D 1) {
> +		rc =3D -ECANCELED;
> +		goto out;
> +	}
> +
> +	if (unlikely(PageTransHuge(item->old_page) &&
> +		!PageTransHuge(item->new_page))) {
> +		lock_page(item->old_page);
> +		rc =3D split_huge_page(item->old_page);
> +		unlock_page(item->old_page);
> +		if (rc)
> +			goto out;
> +	}
> +
> +	rc =3D __unmap_page_concur(item->old_page, item->new_page, &item->anon_=
vma,
> +							force, mode);
> +	if (rc =3D=3D MIGRATEPAGE_SUCCESS) {
> +		put_new_page =3D NULL;
> +		return rc;
> +	}
> +
> +out:
> +	if (rc !=3D -EAGAIN) {
> +		list_del(&item->old_page->lru);
> +		dec_zone_page_state(item->old_page, NR_ISOLATED_ANON +
> +				page_is_file_cache(item->old_page));
> +
> +		putback_lru_page(item->old_page);
> +	}
> +
> +	/*
> +	 * If migration was not successful and there's a freeing callback, use
> +	 * it.  Otherwise, putback_lru_page() will drop the reference grabbed
> +	 * during isolation.
> +	 */
> +	if (put_new_page)
> +		put_new_page(item->new_page, private);
> +	else
> +		putback_lru_page(item->new_page);
> +
> +	if (result) {
> +		if (rc)
> +			*result =3D rc;
> +		else
> +			*result =3D page_to_nid(item->new_page);
> +	}
> +
> +	return rc;
> +}
> +
> +static int move_mapping_concurr(struct list_head *unmapped_list_ptr,
> +					   struct list_head *wip_list_ptr,
> +					   enum migrate_mode mode)
> +{
> +	struct page_migration_work_item *iterator, *iterator2;
> +	struct address_space *mapping;
> +
> +	list_for_each_entry_safe(iterator, iterator2, unmapped_list_ptr, list) =
{
> +		VM_BUG_ON_PAGE(!PageLocked(iterator->old_page), iterator->old_page);
> +		VM_BUG_ON_PAGE(!PageLocked(iterator->new_page), iterator->new_page);
> +
> +		mapping =3D page_mapping(iterator->old_page);
> +
> +		VM_BUG_ON(mapping);
> +
> +		VM_BUG_ON(PageWriteback(iterator->old_page));
> +
> +		if (page_count(iterator->old_page) !=3D 1) {
> +			list_move(&iterator->list, wip_list_ptr);
> +			continue;
> +		}
> +
> +		iterator->new_page->index =3D iterator->old_page->index;
> +		iterator->new_page->mapping =3D iterator->old_page->mapping;
> +		if (PageSwapBacked(iterator->old_page))
> +			SetPageSwapBacked(iterator->new_page);
> +	}
> +
> +	return 0;
> +}
> +
> +static void migrate_page_copy_page_flags(struct page *newpage, struct pa=
ge *page)

This function is nearly identical with migrate_page_copy(), so please make
it call this function inside it.

> +{
> +	int cpupid;
> +
> +	if (PageError(page))
> +		SetPageError(newpage);
> +	if (PageReferenced(page))
> +		SetPageReferenced(newpage);
> +	if (PageUptodate(page))
> +		SetPageUptodate(newpage);
> +	if (TestClearPageActive(page)) {
> +		VM_BUG_ON_PAGE(PageUnevictable(page), page);
> +		SetPageActive(newpage);
> +	} else if (TestClearPageUnevictable(page))
> +		SetPageUnevictable(newpage);
> +	if (PageChecked(page))
> +		SetPageChecked(newpage);
> +	if (PageMappedToDisk(page))
> +		SetPageMappedToDisk(newpage);
> +
> +	/* Move dirty on pages not done by migrate_page_move_mapping() */
> +	if (PageDirty(page))
> +		SetPageDirty(newpage);
> +
> +	if (page_is_young(page))
> +		set_page_young(newpage);
> +	if (page_is_idle(page))
> +		set_page_idle(newpage);
> +
> +	/*
> +	 * Copy NUMA information to the new page, to prevent over-eager
> +	 * future migrations of this same page.
> +	 */
> +	cpupid =3D page_cpupid_xchg_last(page, -1);
> +	page_cpupid_xchg_last(newpage, cpupid);
> +
> +	ksm_migrate_page(newpage, page);
> +	/*
> +	 * Please do not reorder this without considering how mm/ksm.c's
> +	 * get_ksm_page() depends upon ksm_migrate_page() and PageSwapCache().
> +	 */
> +	if (PageSwapCache(page))
> +		ClearPageSwapCache(page);
> +	ClearPagePrivate(page);
> +	set_page_private(page, 0);
> +
> +	/*
> +	 * If any waiters have accumulated on the new page then
> +	 * wake them up.
> +	 */
> +	if (PageWriteback(newpage))
> +		end_page_writeback(newpage);
> +
> +	copy_page_owner(page, newpage);
> +
> +	mem_cgroup_migrate(page, newpage);
> +}
> +
> +
> +static int copy_to_new_pages_concur(struct list_head *unmapped_list_ptr,
> +				enum migrate_mode mode)
> +{
> +	struct page_migration_work_item *iterator;
> +	int num_pages =3D 0, idx =3D 0;
> +	struct page **src_page_list =3D NULL, **dst_page_list =3D NULL;
> +	unsigned long size =3D 0;
> +	int rc =3D -EFAULT;
> +
> +	list_for_each_entry(iterator, unmapped_list_ptr, list) {
> +		++num_pages;
> +		size +=3D PAGE_SIZE * hpage_nr_pages(iterator->old_page);
> +	}
> +
> +	src_page_list =3D kzalloc(sizeof(struct page *)*num_pages, GFP_KERNEL);
> +	if (!src_page_list)
> +		return -ENOMEM;
> +	dst_page_list =3D kzalloc(sizeof(struct page *)*num_pages, GFP_KERNEL);
> +	if (!dst_page_list)
> +		return -ENOMEM;
> +
> +	list_for_each_entry(iterator, unmapped_list_ptr, list) {
> +		src_page_list[idx] =3D iterator->old_page;
> +		dst_page_list[idx] =3D iterator->new_page;
> +		++idx;
> +	}
> +
> +	BUG_ON(idx !=3D num_pages);
> +
> +	if (mode & MIGRATE_MT)

just my guessing, you mean MIGRATE_CONCUR?

> +		rc =3D copy_page_lists_mthread(dst_page_list, src_page_list,
> +							num_pages);
> +
> +	if (rc)
> +		list_for_each_entry(iterator, unmapped_list_ptr, list) {
> +			if (PageHuge(iterator->old_page) ||
> +				PageTransHuge(iterator->old_page))
> +				copy_huge_page(iterator->new_page, iterator->old_page, 0);
> +			else
> +				copy_highpage(iterator->new_page, iterator->old_page);
> +		}
> +
> +	kfree(src_page_list);
> +	kfree(dst_page_list);
> +
> +	list_for_each_entry(iterator, unmapped_list_ptr, list) {
> +		migrate_page_copy_page_flags(iterator->new_page, iterator->old_page);
> +	}
> +
> +	return 0;
> +}
> +
> +static int remove_migration_ptes_concurr(struct list_head *unmapped_list=
_ptr)
> +{
> +	struct page_migration_work_item *iterator, *iterator2;
> +
> +	list_for_each_entry_safe(iterator, iterator2, unmapped_list_ptr, list) =
{
> +		remove_migration_ptes(iterator->old_page, iterator->new_page, false);
> +
> +		unlock_page(iterator->new_page);
> +
> +		if (iterator->anon_vma)
> +			put_anon_vma(iterator->anon_vma);
> +
> +		unlock_page(iterator->old_page);
> +
> +		list_del(&iterator->old_page->lru);
> +		dec_zone_page_state(iterator->old_page, NR_ISOLATED_ANON +
> +				page_is_file_cache(iterator->old_page));
> +
> +		putback_lru_page(iterator->old_page);
> +		iterator->old_page =3D NULL;
> +
> +		putback_lru_page(iterator->new_page);
> +		iterator->new_page =3D NULL;
> +	}
> +
> +	return 0;
> +}
> +
> +int migrate_pages_concur(struct list_head *from, new_page_t get_new_page=
,
> +		free_page_t put_new_page, unsigned long private,
> +		enum migrate_mode mode, int reason)
> +{
> +	int retry =3D 1;
> +	int nr_failed =3D 0;
> +	int nr_succeeded =3D 0;
> +	int pass =3D 0;
> +	struct page *page;
> +	int swapwrite =3D current->flags & PF_SWAPWRITE;
> +	int rc;
> +	int total_num_pages =3D 0, idx;
> +	struct page_migration_work_item *item_list;
> +	struct page_migration_work_item *iterator, *iterator2;
> +	int item_list_order =3D 0;
> +
> +	LIST_HEAD(wip_list);
> +	LIST_HEAD(unmapped_list);
> +	LIST_HEAD(serialized_list);
> +	LIST_HEAD(failed_list);
> +
> +	if (!swapwrite)
> +		current->flags |=3D PF_SWAPWRITE;
> +
> +	list_for_each_entry(page, from, lru)
> +		++total_num_pages;
> +
> +	item_list_order =3D get_order(total_num_pages *
> +		sizeof(struct page_migration_work_item));
> +
> +	if (item_list_order > MAX_ORDER) {
> +		item_list =3D alloc_pages_exact(total_num_pages *
> +			sizeof(struct page_migration_work_item), GFP_ATOMIC);
> +		memset(item_list, 0, total_num_pages *
> +			sizeof(struct page_migration_work_item));
> +	} else {
> +		item_list =3D (struct page_migration_work_item *)__get_free_pages(GFP_=
ATOMIC,
> +						item_list_order);

The allocation could fail, so error handling is needed here.

> +		memset(item_list, 0, PAGE_SIZE<<item_list_order);
> +	}
> +
> +	idx =3D 0;
> +	list_for_each_entry(page, from, lru) {
> +		item_list[idx].old_page =3D page;
> +		item_list[idx].new_page =3D NULL;
> +		INIT_LIST_HEAD(&item_list[idx].list);
> +		list_add_tail(&item_list[idx].list, &wip_list);
> +		idx +=3D 1;
> +	}

At this point, all migration target pages are moved to wip_list, so
the list 'from' (passed from and returned back to the caller) becomes empty=
.
When all migration trial are done and there still remain pages on wip_list
and/or serialized_list, the remaining pages should be moved back to 'from'.

> +
> +	for(pass =3D 0; pass < 1 && retry; pass++) {
> +		retry =3D 0;
> +
> +		/* unmap and get new page for page_mapping(page) =3D=3D NULL */
> +		list_for_each_entry_safe(iterator, iterator2, &wip_list, list) {
> +			cond_resched();
> +
> +			if (iterator->new_page)
> +				continue;
> +
> +			/* We do not migrate huge pages, file-backed, or swapcached pages */

Just "huge page" are confusing, maybe you mean hugetlb.

> +			if (PageHuge(iterator->old_page))
> +				rc =3D -ENODEV;
> +			else if ((page_mapping(iterator->old_page) !=3D NULL))
> +				rc =3D -ENODEV;
> +			else
> +				rc =3D unmap_pages_and_get_new_concur(get_new_page, put_new_page,
> +						private, iterator, pass > 2, mode,
> +						reason);
> +
> +			switch(rc) {
> +			case -ENODEV:
> +				list_move(&iterator->list, &serialized_list);
> +				break;
> +			case -ENOMEM:
> +				goto out;
> +			case -EAGAIN:
> +				retry++;
> +				break;
> +			case MIGRATEPAGE_SUCCESS:
> +				list_move(&iterator->list, &unmapped_list);
> +				nr_succeeded++;
> +				break;
> +			default:
> +				/*
> +				 * Permanent failure (-EBUSY, -ENOSYS, etc.):
> +				 * unlike -EAGAIN case, the failed page is
> +				 * removed from migration page list and not
> +				 * retried in the next outer loop.
> +				 */
> +				list_move(&iterator->list, &failed_list);
> +				nr_failed++;
> +				break;
> +			}
> +		}
> +		/* move page->mapping to new page, only -EAGAIN could happen  */
> +		move_mapping_concurr(&unmapped_list, &wip_list, mode);
> +		/* copy pages in unmapped_list */
> +		copy_to_new_pages_concur(&unmapped_list, mode);
> +		/* remove migration pte, if old_page is NULL?, unlock old and new
> +		 * pages, put anon_vma, put old and new pages */
> +		remove_migration_ptes_concurr(&unmapped_list);
> +	}
> +	nr_failed +=3D retry;
> +	rc =3D nr_failed;
> +
> +	if (!list_empty(&serialized_list))
> +		rc =3D migrate_pages(from, get_new_page, put_new_page,

You should give &serialized_list instead of from, right?

Thanks,
Naoya Horiguchi

> +				private, mode, reason);
> +out:
> +	if (nr_succeeded)
> +		count_vm_events(PGMIGRATE_SUCCESS, nr_succeeded);
> +	if (nr_failed)
> +		count_vm_events(PGMIGRATE_FAIL, nr_failed);
> +	trace_mm_migrate_pages(nr_succeeded, nr_failed, mode, reason);
> +
> +	if (item_list_order >=3D MAX_ORDER)
> +		free_pages_exact(item_list, total_num_pages *
> +			sizeof(struct page_migration_work_item));
> +	else
> +		free_pages((unsigned long)item_list, item_list_order);
> +
> +	if (!swapwrite)
> +		current->flags &=3D ~PF_SWAPWRITE;
> +
> +	return rc;
> +}
> +
>  /*
>   * migrate_pages - migrate the pages specified in a list, to the free pa=
ges
>   *		   supplied as the target for the page migration
> @@ -1452,7 +1925,8 @@ static struct page *new_page_node(struct page *p, u=
nsigned long private,
>  static int do_move_page_to_node_array(struct mm_struct *mm,
>  				      struct page_to_node *pm,
>  				      int migrate_all,
> -					  int migrate_use_mt)
> +					  int migrate_use_mt,
> +					  int migrate_concur)
>  {
>  	int err;
>  	struct page_to_node *pp;
> @@ -1536,8 +2010,16 @@ static int do_move_page_to_node_array(struct mm_st=
ruct *mm,
>
>  	err =3D 0;
>  	if (!list_empty(&pagelist)) {
> -		err =3D migrate_pages(&pagelist, new_page_node, NULL,
> -				(unsigned long)pm, mode, MR_SYSCALL);
> +		if (migrate_concur)
> +			err =3D migrate_pages_concur(&pagelist, new_page_node, NULL,
> +					(unsigned long)pm,
> +					mode,
> +					MR_SYSCALL);
> +		else
> +			err =3D migrate_pages(&pagelist, new_page_node, NULL,
> +					(unsigned long)pm,
> +					mode,
> +					MR_SYSCALL);
>  		if (err)
>  			putback_movable_pages(&pagelist);
>  	}
> @@ -1615,7 +2097,8 @@ static int do_pages_move(struct mm_struct *mm, node=
mask_t task_nodes,
>  		/* Migrate this chunk */
>  		err =3D do_move_page_to_node_array(mm, pm,
>  						 flags & MPOL_MF_MOVE_ALL,
> -						 flags & MPOL_MF_MOVE_MT);
> +						 flags & MPOL_MF_MOVE_MT,
> +						 flags & MPOL_MF_MOVE_CONCUR);
>  		if (err < 0)
>  			goto out_pm;
>
> @@ -1722,7 +2205,9 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned lo=
ng, nr_pages,
>  	nodemask_t task_nodes;
>
>  	/* Check flags */
> -	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|MPOL_MF_MOVE_MT))
> +	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL|
> +				  MPOL_MF_MOVE_MT|
> +				  MPOL_MF_MOVE_CONCUR))
>  		return -EINVAL;
>
>  	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
> --
> 2.11.0
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=3Dmailto:"dont@kvack.org"> email@kvack.org </a>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
