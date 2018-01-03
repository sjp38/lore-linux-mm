Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 0067A6B0309
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:42:32 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id g49so764815qta.8
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:42:31 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q63si444905qtd.202.2018.01.03.00.42.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Jan 2018 00:42:30 -0800 (PST)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id w038d4Wb176672
	for <linux-mm@kvack.org>; Wed, 3 Jan 2018 03:42:30 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2f8qxkyncm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Jan 2018 03:42:29 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 3 Jan 2018 08:42:27 -0000
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
Date: Wed, 3 Jan 2018 14:12:17 +0530
MIME-Version: 1.0
In-Reply-To: <20171208161559.27313-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Message-Id: <7dd106bd-460a-73a7-bae8-17ffe66a69ee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org
Cc: Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On 12/08/2017 09:45 PM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
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
>  mm/migrate.c   | 306 +++++++++++++++++++++++++--------------------------------
>  3 files changed, 139 insertions(+), 173 deletions(-)
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

This reuses the existing page allocation helper from migrate_pages() system
call. But all these allocator helper names for migrate_pages() function are
really confusing. Even in this case alloc_new_node_page and the original
new_node_page() which is still getting used in do_migrate_range() sounds
similar even if their implementation is quite different. IMHO either all of
them should be moved to the header file with proper differentiating names
or let them be there in their respective files with these generic names and
clean them up later.

> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4d0be47a322a..9d7252ea2acd 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1444,141 +1444,104 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
>  }
>  
>  #ifdef CONFIG_NUMA
> -/*
> - * Move a list of individual pages
> - */
> -struct page_to_node {
> -	unsigned long addr;
> -	struct page *page;
> -	int node;
> -	int status;
> -};
>  
> -static struct page *new_page_node(struct page *p, unsigned long private,
> -		int **result)
> +static int store_status(int __user *status, int start, int value, int nr)
>  {
> -	struct page_to_node *pm = (struct page_to_node *)private;
> -
> -	while (pm->node != MAX_NUMNODES && pm->page != p)
> -		pm++;
> +	while (nr-- > 0) {
> +		if (put_user(value, status + start))
> +			return -EFAULT;
> +		start++;
> +	}
>  
> -	if (pm->node == MAX_NUMNODES)
> -		return NULL;
> +	return 0;
> +}


Just a nit. new_page_node() and store_status() seems different. Then why
the git diff looks so clumsy.

>  
> -	*result = &pm->status;
> +static int do_move_pages_to_node(struct mm_struct *mm,
> +		struct list_head *pagelist, int node)
> +{
> +	int err;
>  
> -	if (PageHuge(p))
> -		return alloc_huge_page_node(page_hstate(compound_head(p)),
> -					pm->node);
> -	else if (thp_migration_supported() && PageTransHuge(p)) {
> -		struct page *thp;
> +	if (list_empty(pagelist))
> +		return 0;
>  
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
> +	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
> +			MIGRATE_SYNC, MR_SYSCALL);
> +	if (err)
> +		putback_movable_pages(pagelist);
> +	return err;
>  }

Even this one. IIUC, do_move_pages_to_node() migrate a chunk of pages
at a time which belong to the same target node. Perhaps the name should
suggest so. All these helper page migration helper functions sound so
similar.

>  
>  /*
> - * Move a set of pages as indicated in the pm array. The addr
> - * field must be set to the virtual address of the page to be moved
> - * and the node number must contain a valid target node.
> - * The pm array ends with node = MAX_NUMNODES.
> + * Resolves the given address to a struct page, isolates it from the LRU and
> + * puts it to the given pagelist.
> + * Returns -errno if the page cannot be found/isolated or 0 when it has been
> + * queued or the page doesn't need to be migrated because it is already on
> + * the target node
>   */
> -static int do_move_page_to_node_array(struct mm_struct *mm,
> -				      struct page_to_node *pm,
> -				      int migrate_all)
> +static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
> +		int node, struct list_head *pagelist, bool migrate_all)
>  {
> +	struct vm_area_struct *vma;
> +	struct page *page;
> +	unsigned int follflags;
>  	int err;
> -	struct page_to_node *pp;
> -	LIST_HEAD(pagelist);
>  
>  	down_read(&mm->mmap_sem);

Holding mmap_sem for individual pages makes sense. Current
implementation is holding it for an entire batch.

> +	err = -EFAULT;
> +	vma = find_vma(mm, addr);
> +	if (!vma || addr < vma->vm_start || !vma_migratable(vma))

While here, should not we add 'addr > vma->vm_end' into this condition ?

> +		goto out;
>  
> -	/*
> -	 * Build a list of pages to migrate
> -	 */
> -	for (pp = pm; pp->node != MAX_NUMNODES; pp++) {
> -		struct vm_area_struct *vma;
> -		struct page *page;
> -		struct page *head;
> -		unsigned int follflags;
> -
> -		err = -EFAULT;
> -		vma = find_vma(mm, pp->addr);
> -		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
> -			goto set_status;
> -
> -		/* FOLL_DUMP to ignore special (like zero) pages */
> -		follflags = FOLL_GET | FOLL_DUMP;
> -		if (!thp_migration_supported())
> -			follflags |= FOLL_SPLIT;
> -		page = follow_page(vma, pp->addr, follflags);
> +	/* FOLL_DUMP to ignore special (like zero) pages */
> +	follflags = FOLL_GET | FOLL_DUMP;
> +	if (!thp_migration_supported())
> +		follflags |= FOLL_SPLIT;
> +	page = follow_page(vma, addr, follflags);
>  
> -		err = PTR_ERR(page);
> -		if (IS_ERR(page))
> -			goto set_status;
> +	err = PTR_ERR(page);
> +	if (IS_ERR(page))
> +		goto out;
>  
> -		err = -ENOENT;
> -		if (!page)
> -			goto set_status;
> +	err = -ENOENT;
> +	if (!page)
> +		goto out;
>  
> -		err = page_to_nid(page);
> +	err = 0;
> +	if (page_to_nid(page) == node)
> +		goto out_putpage;
>  
> -		if (err == pp->node)
> -			/*
> -			 * Node already in the right place
> -			 */
> -			goto put_and_set;
> +	err = -EACCES;
> +	if (page_mapcount(page) > 1 &&
> +			!migrate_all)
> +		goto out_putpage;
>  
> -		err = -EACCES;
> -		if (page_mapcount(page) > 1 &&
> -				!migrate_all)
> -			goto put_and_set;
> -
> -		if (PageHuge(page)) {
> -			if (PageHead(page)) {
> -				isolate_huge_page(page, &pagelist);
> -				err = 0;
> -				pp->page = page;
> -			}
> -			goto put_and_set;
> +	if (PageHuge(page)) {
> +		if (PageHead(page)) {
> +			isolate_huge_page(page, pagelist);
> +			err = 0;
>  		}
> +	} else {
> +		struct page *head;
>  
> -		pp->page = compound_head(page);
>  		head = compound_head(page);
>  		err = isolate_lru_page(head);
> -		if (!err) {
> -			list_add_tail(&head->lru, &pagelist);
> -			mod_node_page_state(page_pgdat(head),
> -				NR_ISOLATED_ANON + page_is_file_cache(head),
> -				hpage_nr_pages(head));
> -		}
> -put_and_set:
> -		/*
> -		 * Either remove the duplicate refcount from
> -		 * isolate_lru_page() or drop the page ref if it was
> -		 * not isolated.
> -		 */
> -		put_page(page);
> -set_status:
> -		pp->status = err;
> -	}
> -
> -	err = 0;
> -	if (!list_empty(&pagelist)) {
> -		err = migrate_pages(&pagelist, new_page_node, NULL,
> -				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
>  		if (err)
> -			putback_movable_pages(&pagelist);
> -	}
> +			goto out_putpage;
>  
> +		err = 0;
> +		list_add_tail(&head->lru, pagelist);
> +		mod_node_page_state(page_pgdat(head),
> +			NR_ISOLATED_ANON + page_is_file_cache(head),
> +			hpage_nr_pages(head));
> +	}
> +out_putpage:
> +	/*
> +	 * Either remove the duplicate refcount from
> +	 * isolate_lru_page() or drop the page ref if it was
> +	 * not isolated.
> +	 */
> +	put_page(page);
> +out:
>  	up_read(&mm->mmap_sem);
>  	return err;
>  }
> @@ -1593,79 +1556,80 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
>  			 const int __user *nodes,
>  			 int __user *status, int flags)
>  {
> -	struct page_to_node *pm;
> -	unsigned long chunk_nr_pages;
> -	unsigned long chunk_start;
> -	int err;
> -
> -	err = -ENOMEM;
> -	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
> -	if (!pm)
> -		goto out;
> +	int chunk_node = NUMA_NO_NODE;
> +	LIST_HEAD(pagelist);
> +	int chunk_start, i;
> +	int err = 0, err1;

err init might not be required, its getting assigned to -EFAULT right away.

>  
>  	migrate_prep();
>  
> -	/*
> -	 * Store a chunk of page_to_node array in a page,
> -	 * but keep the last one as a marker
> -	 */
> -	chunk_nr_pages = (PAGE_SIZE / sizeof(struct page_to_node)) - 1;
> -
> -	for (chunk_start = 0;
> -	     chunk_start < nr_pages;
> -	     chunk_start += chunk_nr_pages) {
> -		int j;
> -
> -		if (chunk_start + chunk_nr_pages > nr_pages)
> -			chunk_nr_pages = nr_pages - chunk_start;
> -
> -		/* fill the chunk pm with addrs and nodes from user-space */
> -		for (j = 0; j < chunk_nr_pages; j++) {
> -			const void __user *p;
> -			int node;
> -
> -			err = -EFAULT;
> -			if (get_user(p, pages + j + chunk_start))
> -				goto out_pm;
> -			pm[j].addr = (unsigned long) p;
> -
> -			if (get_user(node, nodes + j + chunk_start))
> -				goto out_pm;
> -
> -			err = -ENODEV;
> -			if (node < 0 || node >= MAX_NUMNODES)
> -				goto out_pm;
> +	for (i = chunk_start = 0; i < nr_pages; i++) {
> +		const void __user *p;
> +		unsigned long addr;
> +		int node;
>  
> -			if (!node_state(node, N_MEMORY))
> -				goto out_pm;
> -
> -			err = -EACCES;
> -			if (!node_isset(node, task_nodes))
> -				goto out_pm;
> +		err = -EFAULT;
> +		if (get_user(p, pages + i))
> +			goto out_flush;
> +		if (get_user(node, nodes + i))
> +			goto out_flush;
> +		addr = (unsigned long)p;
> +
> +		err = -ENODEV;
> +		if (node < 0 || node >= MAX_NUMNODES)
> +			goto out_flush;
> +		if (!node_state(node, N_MEMORY))
> +			goto out_flush;
>  
> -			pm[j].node = node;
> +		err = -EACCES;
> +		if (!node_isset(node, task_nodes))
> +			goto out_flush;
> +
> +		if (chunk_node == NUMA_NO_NODE) {
> +			chunk_node = node;
> +			chunk_start = i;
> +		} else if (node != chunk_node) {
> +			err = do_move_pages_to_node(mm, &pagelist, chunk_node);
> +			if (err)
> +				goto out;
> +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
> +			if (err)
> +				goto out;
> +			chunk_start = i;
> +			chunk_node = node;
>  		}
>  
> -		/* End marker for this chunk */
> -		pm[chunk_nr_pages].node = MAX_NUMNODES;
> +		/*
> +		 * Errors in the page lookup or isolation are not fatal and we simply
> +		 * report them via status
> +		 */
> +		err = add_page_for_migration(mm, addr, chunk_node,
> +				&pagelist, flags & MPOL_MF_MOVE_ALL);
> +		if (!err)
> +			continue;
>  
> -		/* Migrate this chunk */
> -		err = do_move_page_to_node_array(mm, pm,
> -						 flags & MPOL_MF_MOVE_ALL);
> -		if (err < 0)
> -			goto out_pm;
> +		err = store_status(status, i, err, 1);
> +		if (err)
> +			goto out_flush;
>  
> -		/* Return status information */
> -		for (j = 0; j < chunk_nr_pages; j++)
> -			if (put_user(pm[j].status, status + j + chunk_start)) {
> -				err = -EFAULT;
> -				goto out_pm;
> -			}
> +		err = do_move_pages_to_node(mm, &pagelist, chunk_node);
> +		if (err)
> +			goto out;
> +		if (i > chunk_start) {
> +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
> +			if (err)
> +				goto out;
> +		}
> +		chunk_node = NUMA_NO_NODE;

This block of code is bit confusing.

1) Why attempt to migrate when just one page could not be isolated ?
2) 'i' is always greater than chunk_start except the starting page
3) Why reset chunk_node as NUMA_NO_NODE ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
