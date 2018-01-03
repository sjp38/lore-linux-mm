Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 181486B030F
	for <linux-mm@kvack.org>; Wed,  3 Jan 2018 03:58:08 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id w74so351556wmf.0
        for <linux-mm@kvack.org>; Wed, 03 Jan 2018 00:58:08 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g188si480373wmd.86.2018.01.03.00.58.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 03 Jan 2018 00:58:06 -0800 (PST)
Date: Wed, 3 Jan 2018 09:58:04 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 1/3] mm, numa: rework do_pages_move
Message-ID: <20180103085804.GA11319@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-2-mhocko@kernel.org>
 <7dd106bd-460a-73a7-bae8-17ffe66a69ee@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7dd106bd-460a-73a7-bae8-17ffe66a69ee@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, Zi Yan <zi.yan@cs.rutgers.edu>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Wed 03-01-18 14:12:17, Anshuman Khandual wrote:
> On 12/08/2017 09:45 PM, Michal Hocko wrote:
[...]
> > @@ -986,7 +987,7 @@ static int migrate_to_node(struct mm_struct *mm, int source, int dest,
> >  			flags | MPOL_MF_DISCONTIG_OK, &pagelist);
> >  
> >  	if (!list_empty(&pagelist)) {
> > -		err = migrate_pages(&pagelist, new_node_page, NULL, dest,
> > +		err = migrate_pages(&pagelist, alloc_new_node_page, NULL, dest,
> >  					MIGRATE_SYNC, MR_SYSCALL);
> >  		if (err)
> >  			putback_movable_pages(&pagelist);
> 
> This reuses the existing page allocation helper from migrate_pages() system
> call. But all these allocator helper names for migrate_pages() function are
> really confusing. Even in this case alloc_new_node_page and the original
> new_node_page() which is still getting used in do_migrate_range() sounds
> similar even if their implementation is quite different. IMHO either all of
> them should be moved to the header file with proper differentiating names
> or let them be there in their respective files with these generic names and
> clean them up later.

I believe I've tried that but I couldn't make them into a single header
file easily because of header file dependencies. I agree that their
names are quite confusing. Feel free to send a patch to clean this up.

> 
> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 4d0be47a322a..9d7252ea2acd 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1444,141 +1444,104 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >  }
> >  
> >  #ifdef CONFIG_NUMA
> > -/*
> > - * Move a list of individual pages
> > - */
> > -struct page_to_node {
> > -	unsigned long addr;
> > -	struct page *page;
> > -	int node;
> > -	int status;
> > -};
> >  
> > -static struct page *new_page_node(struct page *p, unsigned long private,
> > -		int **result)
> > +static int store_status(int __user *status, int start, int value, int nr)
> >  {
> > -	struct page_to_node *pm = (struct page_to_node *)private;
> > -
> > -	while (pm->node != MAX_NUMNODES && pm->page != p)
> > -		pm++;
> > +	while (nr-- > 0) {
> > +		if (put_user(value, status + start))
> > +			return -EFAULT;
> > +		start++;
> > +	}
> >  
> > -	if (pm->node == MAX_NUMNODES)
> > -		return NULL;
> > +	return 0;
> > +}
> 
> 
> Just a nit. new_page_node() and store_status() seems different. Then why
> the git diff looks so clumsy.

Kirill was suggesting to use --patience to general the diff which leads
to a slightly better output. It has been posted as a separate email [1].
Maybe you will find that one easier to review.

[1] http://lkml.kernel.org/r/20171213143948.GM25185@dhcp22.suse.cz

> >  
> > -	*result = &pm->status;
> > +static int do_move_pages_to_node(struct mm_struct *mm,
> > +		struct list_head *pagelist, int node)
> > +{
> > +	int err;
> >  
> > -	if (PageHuge(p))
> > -		return alloc_huge_page_node(page_hstate(compound_head(p)),
> > -					pm->node);
> > -	else if (thp_migration_supported() && PageTransHuge(p)) {
> > -		struct page *thp;
> > +	if (list_empty(pagelist))
> > +		return 0;
> >  
> > -		thp = alloc_pages_node(pm->node,
> > -			(GFP_TRANSHUGE | __GFP_THISNODE) & ~__GFP_RECLAIM,
> > -			HPAGE_PMD_ORDER);
> > -		if (!thp)
> > -			return NULL;
> > -		prep_transhuge_page(thp);
> > -		return thp;
> > -	} else
> > -		return __alloc_pages_node(pm->node,
> > -				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
> > +	err = migrate_pages(pagelist, alloc_new_node_page, NULL, node,
> > +			MIGRATE_SYNC, MR_SYSCALL);
> > +	if (err)
> > +		putback_movable_pages(pagelist);
> > +	return err;
> >  }
> 
> Even this one. IIUC, do_move_pages_to_node() migrate a chunk of pages
> at a time which belong to the same target node. Perhaps the name should
> suggest so. All these helper page migration helper functions sound so
> similar.

What do you suggest? I find do_move_pages_to_node quite explicit on its
purpose.

> >  /*
> > - * Move a set of pages as indicated in the pm array. The addr
> > - * field must be set to the virtual address of the page to be moved
> > - * and the node number must contain a valid target node.
> > - * The pm array ends with node = MAX_NUMNODES.
> > + * Resolves the given address to a struct page, isolates it from the LRU and
> > + * puts it to the given pagelist.
> > + * Returns -errno if the page cannot be found/isolated or 0 when it has been
> > + * queued or the page doesn't need to be migrated because it is already on
> > + * the target node
> >   */
> > -static int do_move_page_to_node_array(struct mm_struct *mm,
> > -				      struct page_to_node *pm,
> > -				      int migrate_all)
> > +static int add_page_for_migration(struct mm_struct *mm, unsigned long addr,
> > +		int node, struct list_head *pagelist, bool migrate_all)
> >  {
> > +	struct vm_area_struct *vma;
> > +	struct page *page;
> > +	unsigned int follflags;
> >  	int err;
> > -	struct page_to_node *pp;
> > -	LIST_HEAD(pagelist);
> >  
> >  	down_read(&mm->mmap_sem);
> 
> Holding mmap_sem for individual pages makes sense. Current
> implementation is holding it for an entire batch.

I didn't bother to optimize this path to be honest. It is true that lock
batching can lead to improvements but that would complicate the code
(how many patches to batch?) so I've left that for later if somebody
actually sees any problem.

> > +	err = -EFAULT;
> > +	vma = find_vma(mm, addr);
> > +	if (!vma || addr < vma->vm_start || !vma_migratable(vma))
> 
> While here, should not we add 'addr > vma->vm_end' into this condition ?

No. See what find_vma does.

[...]

Please cut out the quoted reply to minimum

> > @@ -1593,79 +1556,80 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
> >  			 const int __user *nodes,
> >  			 int __user *status, int flags)
> >  {
> > -	struct page_to_node *pm;
> > -	unsigned long chunk_nr_pages;
> > -	unsigned long chunk_start;
> > -	int err;
> > -
> > -	err = -ENOMEM;
> > -	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
> > -	if (!pm)
> > -		goto out;
> > +	int chunk_node = NUMA_NO_NODE;
> > +	LIST_HEAD(pagelist);
> > +	int chunk_start, i;
> > +	int err = 0, err1;
> 
> err init might not be required, its getting assigned to -EFAULT right away.

No, nr_pages might be 0 AFAICS.

[...]
> > +		if (chunk_node == NUMA_NO_NODE) {
> > +			chunk_node = node;
> > +			chunk_start = i;
> > +		} else if (node != chunk_node) {
> > +			err = do_move_pages_to_node(mm, &pagelist, chunk_node);
> > +			if (err)
> > +				goto out;
> > +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
> > +			if (err)
> > +				goto out;
> > +			chunk_start = i;
> > +			chunk_node = node;
> >  		}
> >  
> > -		/* End marker for this chunk */
> > -		pm[chunk_nr_pages].node = MAX_NUMNODES;
> > +		/*
> > +		 * Errors in the page lookup or isolation are not fatal and we simply
> > +		 * report them via status
> > +		 */
> > +		err = add_page_for_migration(mm, addr, chunk_node,
> > +				&pagelist, flags & MPOL_MF_MOVE_ALL);
> > +		if (!err)
> > +			continue;
> >  
> > -		/* Migrate this chunk */
> > -		err = do_move_page_to_node_array(mm, pm,
> > -						 flags & MPOL_MF_MOVE_ALL);
> > -		if (err < 0)
> > -			goto out_pm;
> > +		err = store_status(status, i, err, 1);
> > +		if (err)
> > +			goto out_flush;
> >  
> > -		/* Return status information */
> > -		for (j = 0; j < chunk_nr_pages; j++)
> > -			if (put_user(pm[j].status, status + j + chunk_start)) {
> > -				err = -EFAULT;
> > -				goto out_pm;
> > -			}
> > +		err = do_move_pages_to_node(mm, &pagelist, chunk_node);
> > +		if (err)
> > +			goto out;
> > +		if (i > chunk_start) {
> > +			err = store_status(status, chunk_start, chunk_node, i - chunk_start);
> > +			if (err)
> > +				goto out;
> > +		}
> > +		chunk_node = NUMA_NO_NODE;
> 
> This block of code is bit confusing.

I believe this is easier to grasp when looking at the resulting code.
> 
> 1) Why attempt to migrate when just one page could not be isolated ?
> 2) 'i' is always greater than chunk_start except the starting page
> 3) Why reset chunk_node as NUMA_NO_NODE ?

This is all about flushing the pending state on an error and
distinguising a fresh batch.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
