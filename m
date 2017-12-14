Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 12B676B0253
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 10:36:03 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id v69so3424140wrb.3
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 07:36:03 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t7sor2812913edc.45.2017.12.14.07.36.01
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Dec 2017 07:36:01 -0800 (PST)
Date: Thu, 14 Dec 2017 18:35:58 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20171214153558.trgov6dbclav6ui7@node.shutemov.name>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <20171213143948.GM25185@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213143948.GM25185@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 13, 2017 at 03:39:48PM +0100, Michal Hocko wrote:
> This patch has been generated with --patience parameter as suggested by
> Kirill and it realy seems to provide a more compact diff.
> ---
> From 1f529769d099ca605888b29059014e7c8f0bfd50 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Fri, 8 Dec 2017 12:28:34 +0100
> Subject: [PATCH] mm, numa: rework do_pages_move
> 
> do_pages_move is supposed to move user defined memory (an array of
> addresses) to the user defined numa nodes (an array of nodes one for
> each address). The user provided status array then contains resulting
> numa node for each address or an error. The semantic of this function is
> little bit confusing because only some errors are reported back. Notably
> migrate_pages error is only reported via the return value. This patch
> doesn't try to address these semantic nuances but rather change the
> underlying implementation.
> 
> Currently we are processing user input (which can be really large)
> in batches which are stored to a temporarily allocated page. Each
> address is resolved to its struct page and stored to page_to_node
> structure along with the requested target numa node. The array of these
> structures is then conveyed down the page migration path via private
> argument. new_page_node then finds the corresponding structure and
> allocates the proper target page.
> 
> What is the problem with the current implementation and why to change
> it? Apart from being quite ugly it also doesn't cope with unexpected
> pages showing up on the migration list inside migrate_pages path.
> That doesn't happen currently but the follow up patch would like to
> make the thp migration code more clear and that would need to split a
> THP into the list for some cases.
> 
> How does the new implementation work? Well, instead of batching into a
> fixed size array we simply batch all pages that should be migrated to
> the same node and isolate all of them into a linked list which doesn't
> require any additional storage. This should work reasonably well because
> page migration usually migrates larger ranges of memory to a specific
> node. So the common case should work equally well as the current
> implementation. Even if somebody constructs an input where the target
> numa nodes would be interleaved we shouldn't see a large performance
> impact because page migration alone doesn't really benefit from
> batching. mmap_sem batching for the lookup is quite questionable and
> isolate_lru_page which would benefit from batching is not using it even
> in the current implementation.
> 
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/internal.h  |   1 +
>  mm/mempolicy.c |   5 +-
>  mm/migrate.c   | 340 ++++++++++++++++++++++++++-------------------------------
>  3 files changed, 156 insertions(+), 190 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index e6bd35182dae..1a1bb5d59c15 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -538,4 +538,5 @@ static inline bool is_migrate_highatomic_page(struct page *page)
>  }
>  
>  void setup_zone_pageset(struct zone *zone);
> +extern struct page *alloc_new_node_page(struct page *page, unsigned long node, int **x);
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f604b22ebb65..66c9c79b21be 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -942,7 +942,8 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
>  	}
>  }
>  
> -static struct page *new_node_page(struct page *page, unsigned long node, int **x)
> +/* page allocation callback for NUMA node migration */
> +struct page *alloc_new_node_page(struct page *page, unsigned long node, int **x)
>  {
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> @@ -986,7 +987,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
>  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
>  
>  	if (!list_empty(&pagelist)) {
> -		err = migrate_pages(&pagelist, new_node_page, NULL, dest,
> +		err = migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
>  					MIGRATE_SYNC, MR_SYSCALL);
>  		if (err)
>  			putback_movable_pages(&pagelist);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4d0be47a322a..9d7252ea2acd 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1444,141 +1444,104 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  }
>  
>  #ifdef CONFIG_NUMA
> +
> +static int store_status(int __user *status, int start, int value, int nr)
> +{
> +	while (nr-- > 0) {
> +		if (put_user(value, status + start))
> +			return -EFAULT;
> +		start++;
> +	}
> +
> +	return 0;
> +}
> +
> +static int do_move_pages_to_node(struct mm_struct *mm,
> +		struct list_head *pagelist, int node)
> +{
> +	int err;
> +
> +	if (list_empty(pagelist))
> +		return 0;
> +
> +	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
> +			MIGRATE_SYNC, MR_SYSCALL);
> +	if (err)
> +		putback_movable_pages(pagelist);
> +	return err;
> +}
> +
>  /*
> - * Move a list of individual pages
> + * Resolves the given address to a struct page, isolates it from the LRU and
> + * puts it to the given pagelist.
> + * Returns -errno if the page cannot be found/isolated or 0 when it has been
> + * queued or the page doesn't need to be migrated because it is already on
> + * the target node
>   */
> -struct page_to_node {
> -	unsigned long addr;
> +static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
> +		int node, struct list_head *pagelist, bool migrate_all)
> +{
> +	struct vm_area_struct *vma;
>  	struct page *page;
> -	int node;
> -	int status;
> -};
> -
> -static struct page *new_page_node(struct page *p, unsigned long private,
> -		int **result)
> -{
> -	struct page_to_node *pm = (struct page_to_node *)private;
> -
> -	while (pm->node != MAX_NUMNODES && pm->page != p)
> -		pm++;
> -
> -	if (pm->node == MAX_NUMNODES)
> -		return NULL;
> -
> -	*result = &pm->status;
> -
> -	if (PageHuge(p))
> -		return alloc_huge_page_node(page_hstate(compound_head(p)),
> -					pm->node);
> -	else if (thp_migration_supported() && PageTransHuge(p)) {
> -		struct page *thp;
> -
> -		thp = alloc_pages_node(pm->node,
> -			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> -			HPAGE_PMD_ORDER);
> -		if (!thp)
> -			return NULL;
> -		prep_transhuge_page(thp);
> -		return thp;
> -	} else
> -		return __alloc_pages_node(pm->node,
> -				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
> -}
> -
> -/*
> - * Move a set of pages as indicated in the pm array. The addr
> - * field must be set to the virtual address of the page to be moved
> - * and the node number must contain a valid target node.
> - * The pm array ends with node = MAX_NUMNODES.
> - */
> -static int do_move_page_to_node_array(struct mm_struct *mm,
> -				      struct page_to_node *pm,
> -				      int migrate_all)
> -{
> +	unsigned int follflags;
>  	int err;
> -	struct page_to_node *pp;
> -	LIST_HEAD(pagelist);
>  
>  	down_read(&mm->mmap_sem);
> +	err = -EFAULT;
> +	vma = find_vma(mm, addr);
> +	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
> +		goto out;
>  
> -	/*
> -	 * Build a list of pages to migrate
> -	 */
> -	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
> -		struct vm_area_struct *vma;
> -		struct page *page;
> +	/* FOLL_DUMP to ignore special (like zero) pages */
> +	follflags = FOLL_GET | FOLL_DUMP;
> +	if (!thp_migration_supported())
> +		follflags |= FOLL_SPLIT;
> +	page = follow_page(vma, addr, follflags);
> +
> +	err = PTR_ERR(page);
> +	if (IS_ERR(page))
> +		goto out;
> +
> +	err = -ENOENT;
> +	if (!page)
> +		goto out;
> +
> +	err = 0;
> +	if (page_to_nid(page) == node)
> +		goto out_putpage;
> +
> +	err = -EACCES;
> +	if (page_mapcount(page) > 1 &&
> +			!migrate_all)

Non-sensible line break.

> +		goto out_putpage;
> +
> +	if (PageHuge(page)) {
> +		if (PageHead(page)) {
> +			isolate_huge_page(page, pagelist);
> +			err = 0;
> +		}
> +	} else {

Hm. I think if the page is PageTail() we have to split the huge page.
If an user asks to migrate part of THP, we shouldn't migrate the whole page,
otherwise it's not transparent anymore.

Otherwise, the patch looks good to me.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
