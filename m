Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 51CBD6B0005
	for <linux-mm@kvack.org>; Wed, 11 Apr 2018 05:26:18 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id m190so408648pgm.4
        for <linux-mm@kvack.org>; Wed, 11 Apr 2018 02:26:18 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y73-v6si742756plh.393.2018.04.11.02.26.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Apr 2018 02:26:17 -0700 (PDT)
Date: Wed, 11 Apr 2018 11:26:11 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: shmem: enable thp migration (Re: [PATCH v1] mm:
 consider non-anonymous thp as unmovable page)
Message-ID: <20180411092611.GE23400@dhcp22.suse.cz>
References: <20180403083451.GG5501@dhcp22.suse.cz>
 <20180403105411.hknofkbn6rzs26oz@node.shutemov.name>
 <20180405085927.GC6312@dhcp22.suse.cz>
 <20180405122838.6a6b35psizem4tcy@node.shutemov.name>
 <20180405124830.GJ6312@dhcp22.suse.cz>
 <20180405134045.7axuun6d7ufobzj4@node.shutemov.name>
 <20180405150547.GN6312@dhcp22.suse.cz>
 <20180405155551.wchleyaf4rxooj6m@node.shutemov.name>
 <20180405160317.GP6312@dhcp22.suse.cz>
 <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180406030706.GA2434@hori1.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Zi Yan <zi.yan@sent.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Vlastimil Babka <vbabka@suse.cz>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Fri 06-04-18 03:07:11, Naoya Horiguchi wrote:
> >From e31ec037701d1cc76b26226e4b66d8c783d40889 Mon Sep 17 00:00:00 2001
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Fri, 6 Apr 2018 10:58:35 +0900
> Subject: [PATCH] mm: enable thp migration for shmem thp
> 
> My testing for the latest kernel supporting thp migration showed an
> infinite loop in offlining the memory block that is filled with shmem
> thps.  We can get out of the loop with a signal, but kernel should
> return with failure in this case.
> 
> What happens in the loop is that scan_movable_pages() repeats returning
> the same pfn without any progress. That's because page migration always
> fails for shmem thps.
> 
> In memory offline code, memory blocks containing unmovable pages should
> be prevented from being offline targets by has_unmovable_pages() inside
> start_isolate_page_range().
>
> So it's possible to change migratability
> for non-anonymous thps to avoid the issue, but it introduces more complex
> and thp-specific handling in migration code, so it might not good.
> 
> So this patch is suggesting to fix the issue by enabling thp migration
> for shmem thp. Both of anon/shmem thp are migratable so we don't need
> precheck about the type of thps.
> 
> Fixes: commit 72b39cfc4d75 ("mm, memory_hotplug: do not fail offlining too early")
> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: stable@vger.kernel.org # v4.15+

I do not really feel qualified to give my ack but this is the right
approach for the fix. We simply do expect that LRU pages are migrateable
as well as zone_movable pages.

Andrew, do you plan to take it (with Kirill's ack).

Thanks!

> ---
>  mm/huge_memory.c |  5 ++++-
>  mm/migrate.c     | 19 ++++++++++++++++---
>  mm/rmap.c        |  3 ---
>  3 files changed, 20 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 2aff58624886..933c1bbd3464 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2926,7 +2926,10 @@ void remove_migration_pmd(struct page_vma_mapped_walk *pvmw, struct page *new)
>  		pmde = maybe_pmd_mkwrite(pmde, vma);
>  
>  	flush_cache_range(vma, mmun_start, mmun_start + HPAGE_PMD_SIZE);
> -	page_add_anon_rmap(new, vma, mmun_start, true);
> +	if (PageAnon(new))
> +		page_add_anon_rmap(new, vma, mmun_start, true);
> +	else
> +		page_add_file_rmap(new, true);
>  	set_pmd_at(mm, mmun_start, pvmw->pmd, pmde);
>  	if (vma->vm_flags & VM_LOCKED)
>  		mlock_vma_page(new);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index bdef905b1737..f92dd9f50981 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -472,7 +472,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	pslot = radix_tree_lookup_slot(&mapping->i_pages,
>   					page_index(page));
>  
> -	expected_count += 1 + page_has_private(page);
> +	expected_count += hpage_nr_pages(page) + page_has_private(page);
>  	if (page_count(page) != expected_count ||
>  		radix_tree_deref_slot_protected(pslot,
>  					&mapping->i_pages.xa_lock) != page) {
> @@ -505,7 +505,7 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 */
>  	newpage->index = page->index;
>  	newpage->mapping = page->mapping;
> -	get_page(newpage);	/* add cache reference */
> +	page_ref_add(newpage, hpage_nr_pages(page)); /* add cache reference */
>  	if (PageSwapBacked(page)) {
>  		__SetPageSwapBacked(newpage);
>  		if (PageSwapCache(page)) {
> @@ -524,13 +524,26 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	}
>  
>  	radix_tree_replace_slot(&mapping->i_pages, pslot, newpage);
> +	if (PageTransHuge(page)) {
> +		int i;
> +		int index = page_index(page);
> +
> +		for (i = 0; i < HPAGE_PMD_NR; i++) {
> +			pslot = radix_tree_lookup_slot(&mapping->i_pages,
> +						       index + i);
> +			radix_tree_replace_slot(&mapping->i_pages, pslot,
> +						newpage + i);
> +		}
> +	} else {
> +		radix_tree_replace_slot(&mapping->i_pages, pslot, newpage);
> +	}
>  
>  	/*
>  	 * Drop cache reference from old page by unfreezing
>  	 * to one less reference.
>  	 * We know this isn't the last reference.
>  	 */
> -	page_ref_unfreeze(page, expected_count - 1);
> +	page_ref_unfreeze(page, expected_count - hpage_nr_pages(page));
>  
>  	xa_unlock(&mapping->i_pages);
>  	/* Leave irq disabled to prevent preemption while updating stats */
> diff --git a/mm/rmap.c b/mm/rmap.c
> index f0dd4e4565bc..8d5337fed37b 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1374,9 +1374,6 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>  		if (!pvmw.pte && (flags & TTU_MIGRATION)) {
>  			VM_BUG_ON_PAGE(PageHuge(page) || !PageTransCompound(page), page);
>  
> -			if (!PageAnon(page))
> -				continue;
> -
>  			set_pmd_migration_entry(&pvmw, page);
>  			continue;
>  		}
> -- 
> 2.7.4

-- 
Michal Hocko
SUSE Labs
