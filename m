Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0BD006B0005
	for <linux-mm@kvack.org>; Mon, 29 Jan 2018 17:06:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id t130so5787434pgb.4
        for <linux-mm@kvack.org>; Mon, 29 Jan 2018 14:06:25 -0800 (PST)
Received: from NAM03-BY2-obe.outbound.protection.outlook.com (mail-by2nam03on0130.outbound.protection.outlook.com. [104.47.42.130])
        by mx.google.com with ESMTPS id q7-v6si10282283pls.349.2018.01.29.14.06.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 29 Jan 2018 14:06:23 -0800 (PST)
From: "Zi Yan" <zi.yan@cs.rutgers.edu>
Subject: Re: [PATCH 1/3] mm, numa: rework do_pages_move
Date: Mon, 29 Jan 2018 17:06:14 -0500
Message-ID: <8ECFD324-D8A0-47DC-A6FD-B9F7D29445DC@cs.rutgers.edu>
In-Reply-To: <20180103082555.14592-2-mhocko@kernel.org>
References: <20180103082555.14592-1-mhocko@kernel.org>
 <20180103082555.14592-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed;
 boundary="=_MailMate_20A6E0EC-1FE1-43CC-A91A-F9813CA0E004_=";
 micalg=pgp-sha512; protocol="application/pgp-signature"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrea Reale <ar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

This is an OpenPGP/MIME signed message (RFC 3156 and 4880).

--=_MailMate_20A6E0EC-1FE1-43CC-A91A-F9813CA0E004_=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi Michal,

I discover that this patch does not hold mmap_sem while migrating pages i=
n
do_move_pages_to_node().

A simple fix below moves mmap_sem from add_page_for_migration()
to the outmost do_pages_move():


diff --git a/mm/migrate.c b/mm/migrate.c
index 5d0dc7b85f90..28b9e126cb38 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1487,7 +1487,6 @@ static int add_page_for_migration(struct mm_struct =
*mm, unsigned long addr,
        unsigned int follflags;
        int err;

-       down_read(&mm->mmap_sem);
        err =3D -EFAULT;
        vma =3D find_vma(mm, addr);
        if (!vma || addr < vma->vm_start || !vma_migratable(vma))
@@ -1540,7 +1539,6 @@ static int add_page_for_migration(struct mm_struct =
*mm, unsigned long addr,
         */
        put_page(page);
 out:
-       up_read(&mm->mmap_sem);
        return err;
 }

@@ -1561,6 +1559,7 @@ static int do_pages_move(struct mm_struct *mm, node=
mask_t task_nodes,

        migrate_prep();

+       down_read(&mm->mmap_sem);
        for (i =3D start =3D 0; i < nr_pages; i++) {
                const void __user *p;
                unsigned long addr;
@@ -1628,6 +1627,7 @@ static int do_pages_move(struct mm_struct *mm, node=
mask_t task_nodes,
        if (!err)
                err =3D err1;
 out:
+       up_read(&mm->mmap_sem);
        return err;
 }


--
Best Regards
Yan Zi

On 3 Jan 2018, at 3:25, Michal Hocko wrote:

> From: Michal Hocko <mhocko@suse.com>
>
> do_pages_move is supposed to move user defined memory (an array of
> addresses) to the user defined numa nodes (an array of nodes one for
> each address). The user provided status array then contains resulting
> numa node for each address or an error. The semantic of this function i=
s
> little bit confusing because only some errors are reported back. Notabl=
y
> migrate_pages error is only reported via the return value. This patch
> doesn't try to address these semantic nuances but rather change the
> underlying implementation.
>
> Currently we are processing user input (which can be really large)
> in batches which are stored to a temporarily allocated page. Each
> address is resolved to its struct page and stored to page_to_node
> structure along with the requested target numa node. The array of these=

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
> require any additional storage. This should work reasonably well becaus=
e
> page migration usually migrates larger ranges of memory to a specific
> node. So the common case should work equally well as the current
> implementation. Even if somebody constructs an input where the target
> numa nodes would be interleaved we shouldn't see a large performance
> impact because page migration alone doesn't really benefit from
> batching. mmap_sem batching for the lookup is quite questionable and
> isolate_lru_page which would benefit from batching is not using it even=

> in the current implementation.
>
> Acked-by: Kirill A. Shutemov <kirill@shutemov.name>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/internal.h  |   1 +
>  mm/mempolicy.c |   5 +-
>  mm/migrate.c   | 306 +++++++++++++++++++++++++------------------------=
--------
>  3 files changed, 138 insertions(+), 174 deletions(-)
>
> diff --git a/mm/internal.h b/mm/internal.h
> index 3e5dc95dc259..745e247aca9c 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -540,4 +540,5 @@ static inline bool is_migrate_highatomic_page(struc=
t page *page)
>  }
>
>  void setup_zone_pageset(struct zone *zone);
> +extern struct page *alloc_new_node_page(struct page *page, unsigned lo=
ng node, int **x);
>  #endif	/* __MM_INTERNAL_H */
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index f604b22ebb65..66c9c79b21be 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -942,7 +942,8 @@ static void migrate_page_add(struct page *page, str=
uct list_head *pagelist,
>  	}
>  }
>
> -static struct page *new_node_page(struct page *page, unsigned long nod=
e, int **x)
> +/* page allocation callback for NUMA node migration */
> +struct page *alloc_new_node_page(struct page *page, unsigned long node=
, int **x)
>  {
>  	if (PageHuge(page))
>  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> @@ -986,7 +987,7 @@ static int migrate_to_node(struct mm_struct *mm, in=
t source, int dest,
>  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
>
>  	if (!list_empty(&pagelist)) {
> -		err =3D migrate_pages(&pagelist, new_node_page, NULL, dest,
> +		err =3D migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
>  					MIGRATE_SYNC, MR_SYSCALL);
>  		if (err)
>  			putback_movable_pages(&pagelist);
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 4d0be47a322a..8fb90bcd44a7 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -1444,141 +1444,103 @@ int migrate_pages(struct list_head *from, new=
_page_t get_new_page,
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
> -static struct page *new_page_node(struct page *p, unsigned long privat=
e,
> -		int **result)
> +static int store_status(int __user *status, int start, int value, int =
nr)
>  {
> -	struct page_to_node *pm =3D (struct page_to_node *)private;
> -
> -	while (pm->node !=3D MAX_NUMNODES && pm->page !=3D p)
> -		pm++;
> +	while (nr-- > 0) {
> +		if (put_user(value, status + start))
> +			return -EFAULT;
> +		start++;
> +	}
>
> -	if (pm->node =3D=3D MAX_NUMNODES)
> -		return NULL;
> +	return 0;
> +}
>
> -	*result =3D &pm->status;
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
> -		thp =3D alloc_pages_node(pm->node,
> -			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> -			HPAGE_PMD_ORDER);
> -		if (!thp)
> -			return NULL;
> -		prep_transhuge_page(thp);
> -		return thp;
> -	} else
> -		return __alloc_pages_node(pm->node,
> -				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
> +	err =3D migrate_pages(pagelist, alloc_new_node_page, NULL, node,
> +			MIGRATE_SYNC, MR_SYSCALL);
> +	if (err)
> +		putback_movable_pages(pagelist);
> +	return err;
>  }
>
>  /*
> - * Move a set of pages as indicated in the pm array. The addr
> - * field must be set to the virtual address of the page to be moved
> - * and the node number must contain a valid target node.
> - * The pm array ends with node =3D MAX_NUMNODES.
> + * Resolves the given address to a struct page, isolates it from the L=
RU and
> + * puts it to the given pagelist.
> + * Returns -errno if the page cannot be found/isolated or 0 when it ha=
s been
> + * queued or the page doesn't need to be migrated because it is alread=
y on
> + * the target node
>   */
> -static int do_move_page_to_node_array(struct mm_struct *mm,
> -				      struct page_to_node *pm,
> -				      int migrate_all)
> +static int add_page_for_migration(struct mm_struct *mm, unsigned long =
addr,
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
> +	err =3D -EFAULT;
> +	vma =3D find_vma(mm, addr);
> +	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
> +		goto out;
>
> -	/*
> -	 * Build a list of pages to migrate
> -	 */
> -	for (pp =3D pm; pp->node !=3D MAX_NUMNODES; pp++) {
> -		struct vm_area_struct *vma;
> -		struct page *page;
> -		struct page *head;
> -		unsigned int follflags;
> -
> -		err =3D -EFAULT;
> -		vma =3D find_vma(mm, pp->addr);
> -		if (!vma || pp->addr < vma->vm_start || !vma_migratable(vma))
> -			goto set_status;
> -
> -		/* FOLL_DUMP to ignore special (like zero) pages */
> -		follflags =3D FOLL_GET | FOLL_DUMP;
> -		if (!thp_migration_supported())
> -			follflags |=3D FOLL_SPLIT;
> -		page =3D follow_page(vma, pp->addr, follflags);
> +	/* FOLL_DUMP to ignore special (like zero) pages */
> +	follflags =3D FOLL_GET | FOLL_DUMP;
> +	if (!thp_migration_supported())
> +		follflags |=3D FOLL_SPLIT;
> +	page =3D follow_page(vma, addr, follflags);
>
> -		err =3D PTR_ERR(page);
> -		if (IS_ERR(page))
> -			goto set_status;
> +	err =3D PTR_ERR(page);
> +	if (IS_ERR(page))
> +		goto out;
>
> -		err =3D -ENOENT;
> -		if (!page)
> -			goto set_status;
> +	err =3D -ENOENT;
> +	if (!page)
> +		goto out;
>
> -		err =3D page_to_nid(page);
> +	err =3D 0;
> +	if (page_to_nid(page) =3D=3D node)
> +		goto out_putpage;
>
> -		if (err =3D=3D pp->node)
> -			/*
> -			 * Node already in the right place
> -			 */
> -			goto put_and_set;
> +	err =3D -EACCES;
> +	if (page_mapcount(page) > 1 && !migrate_all)
> +		goto out_putpage;
>
> -		err =3D -EACCES;
> -		if (page_mapcount(page) > 1 &&
> -				!migrate_all)
> -			goto put_and_set;
> -
> -		if (PageHuge(page)) {
> -			if (PageHead(page)) {
> -				isolate_huge_page(page, &pagelist);
> -				err =3D 0;
> -				pp->page =3D page;
> -			}
> -			goto put_and_set;
> +	if (PageHuge(page)) {
> +		if (PageHead(page)) {
> +			isolate_huge_page(page, pagelist);
> +			err =3D 0;
>  		}
> +	} else {
> +		struct page *head;
>
> -		pp->page =3D compound_head(page);
>  		head =3D compound_head(page);
>  		err =3D isolate_lru_page(head);
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
> -		pp->status =3D err;
> -	}
> -
> -	err =3D 0;
> -	if (!list_empty(&pagelist)) {
> -		err =3D migrate_pages(&pagelist, new_page_node, NULL,
> -				(unsigned long)pm, MIGRATE_SYNC, MR_SYSCALL);
>  		if (err)
> -			putback_movable_pages(&pagelist);
> -	}
> +			goto out_putpage;
>
> +		err =3D 0;
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
> @@ -1593,79 +1555,79 @@ static int do_pages_move(struct mm_struct *mm, =
nodemask_t task_nodes,
>  			 const int __user *nodes,
>  			 int __user *status, int flags)
>  {
> -	struct page_to_node *pm;
> -	unsigned long chunk_nr_pages;
> -	unsigned long chunk_start;
> -	int err;
> -
> -	err =3D -ENOMEM;
> -	pm =3D (struct page_to_node *)__get_free_page(GFP_KERNEL);
> -	if (!pm)
> -		goto out;
> +	int current_node =3D NUMA_NO_NODE;
> +	LIST_HEAD(pagelist);
> +	int start, i;
> +	int err =3D 0, err1;
>
>  	migrate_prep();
>
> -	/*
> -	 * Store a chunk of page_to_node array in a page,
> -	 * but keep the last one as a marker
> -	 */
> -	chunk_nr_pages =3D (PAGE_SIZE / sizeof(struct page_to_node)) - 1;
> -
> -	for (chunk_start =3D 0;
> -	     chunk_start < nr_pages;
> -	     chunk_start +=3D chunk_nr_pages) {
> -		int j;
> +	for (i =3D start =3D 0; i < nr_pages; i++) {
> +		const void __user *p;
> +		unsigned long addr;
> +		int node;
>
> -		if (chunk_start + chunk_nr_pages > nr_pages)
> -			chunk_nr_pages =3D nr_pages - chunk_start;
> -
> -		/* fill the chunk pm with addrs and nodes from user-space */
> -		for (j =3D 0; j < chunk_nr_pages; j++) {
> -			const void __user *p;
> -			int node;
> -
> -			err =3D -EFAULT;
> -			if (get_user(p, pages + j + chunk_start))
> -				goto out_pm;
> -			pm[j].addr =3D (unsigned long) p;
> -
> -			if (get_user(node, nodes + j + chunk_start))
> -				goto out_pm;
> -
> -			err =3D -ENODEV;
> -			if (node < 0 || node >=3D MAX_NUMNODES)
> -				goto out_pm;
> -
> -			if (!node_state(node, N_MEMORY))
> -				goto out_pm;
> -
> -			err =3D -EACCES;
> -			if (!node_isset(node, task_nodes))
> -				goto out_pm;
> +		err =3D -EFAULT;
> +		if (get_user(p, pages + i))
> +			goto out_flush;
> +		if (get_user(node, nodes + i))
> +			goto out_flush;
> +		addr =3D (unsigned long)p;
> +
> +		err =3D -ENODEV;
> +		if (node < 0 || node >=3D MAX_NUMNODES)
> +			goto out_flush;
> +		if (!node_state(node, N_MEMORY))
> +			goto out_flush;
>
> -			pm[j].node =3D node;
> +		err =3D -EACCES;
> +		if (!node_isset(node, task_nodes))
> +			goto out_flush;
> +
> +		if (current_node =3D=3D NUMA_NO_NODE) {
> +			current_node =3D node;
> +			start =3D i;
> +		} else if (node !=3D current_node) {
> +			err =3D do_move_pages_to_node(mm, &pagelist, current_node);
> +			if (err)
> +				goto out;
> +			err =3D store_status(status, start, current_node, i - start);
> +			if (err)
> +				goto out;
> +			start =3D i;
> +			current_node =3D node;
>  		}
>
> -		/* End marker for this chunk */
> -		pm[chunk_nr_pages].node =3D MAX_NUMNODES;
> +		/*
> +		 * Errors in the page lookup or isolation are not fatal and we simpl=
y
> +		 * report them via status
> +		 */
> +		err =3D add_page_for_migration(mm, addr, current_node,
> +				&pagelist, flags & MPOL_MF_MOVE_ALL);
> +		if (!err)
> +			continue;
>
> -		/* Migrate this chunk */
> -		err =3D do_move_page_to_node_array(mm, pm,
> -						 flags & MPOL_MF_MOVE_ALL);
> -		if (err < 0)
> -			goto out_pm;
> +		err =3D store_status(status, i, err, 1);
> +		if (err)
> +			goto out_flush;
>
> -		/* Return status information */
> -		for (j =3D 0; j < chunk_nr_pages; j++)
> -			if (put_user(pm[j].status, status + j + chunk_start)) {
> -				err =3D -EFAULT;
> -				goto out_pm;
> -			}
> +		err =3D do_move_pages_to_node(mm, &pagelist, current_node);
> +		if (err)
> +			goto out;
> +		if (i > start) {
> +			err =3D store_status(status, start, current_node, i - start);
> +			if (err)
> +				goto out;
> +		}
> +		current_node =3D NUMA_NO_NODE;
>  	}
> -	err =3D 0;
> -
> -out_pm:
> -	free_page((unsigned long)pm);
> +out_flush:
> +	/* Make sure we do not overwrite the existing error */
> +	err1 =3D do_move_pages_to_node(mm, &pagelist, current_node);
> +	if (!err1)
> +		err1 =3D store_status(status, start, current_node, i - start);
> +	if (!err)
> +		err =3D err1;
>  out:
>  	return err;
>  }
> -- =

> 2.15.1

--=_MailMate_20A6E0EC-1FE1-43CC-A91A-F9813CA0E004_=
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename=signature.asc
Content-Type: application/pgp-signature; name=signature.asc

-----BEGIN PGP SIGNATURE-----
Comment: GPGTools - https://gpgtools.org

iQEcBAEBCgAGBQJab5rWAAoJEEGLLxGcTqbMl2cIAKl+L5Ny63mpMl93chp1CsgF
g6AX4/aZAdb9E6++dc6+dhYiIG0cpJTjG2jbYiNTSorwk8QN2C8uFOii+m7Sy6Kg
hhVpi8XSznXS/SH7k/0WBpClQf3nHd9obHU3VFlHgRE3GY1hxy4JtoGZgrexstRX
eY6iwbFiut0205lFT1VzA8W/YwGkok/2yEverZzqZVAVX41q8+qnZmMfRZkp6h6a
PplX0GY+mbtTWxsCR1P3fa6aJTrPjIKshmHAQdw77HD2BnTu/BJrQ5diyFyqjT3e
j4yB9iE81MBQ267NLpSSWiS2QMRrrj5VgTzfnj1shD7DoEpgz5KgPO2refy8IVY=
=4UtN
-----END PGP SIGNATURE-----

--=_MailMate_20A6E0EC-1FE1-43CC-A91A-F9813CA0E004_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
