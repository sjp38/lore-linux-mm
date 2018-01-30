Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21E106B0005
	for <linux-mm@kvack.org>; Tue, 30 Jan 2018 09:36:40 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id y18so8161322wrh.12
        for <linux-mm@kvack.org>; Tue, 30 Jan 2018 06:36:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h13si1508166wrc.145.2018.01.30.06.36.38
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 30 Jan 2018 06:36:38 -0800 (PST)
Date: Tue, 30 Jan 2018 15:36:35 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC] mm/migrate: Consolidate page allocation helper functions
Message-ID: <20180130143635.GF21609@dhcp22.suse.cz>
References: <20180130050642.19834-1-khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180130050642.19834-1-khandual@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Tue 30-01-18 10:36:42, Anshuman Khandual wrote:
> Allocation helper functions for migrate_pages() remmain scattered with
> similar names making them really confusing. Rename these functions based
> on the context for the migration and move them all into common migration
> header. Functionality remains unchanged.

OK, I do not rememeber why I was getting header dependecy issues here.
Maybe I've just screwed something. So good if we can make most of the
callbacks at the single place. It will hopefully prevent from reinventig
the weel again. I do not like your renames though. You are making them
specific to the caller rather than their semantic.

> +#ifdef CONFIG_MIGRATION
> +/*
> + * Allocate a new page for page migration based on vma policy.
> + * Start by assuming the page is mapped by the same vma as contains @start.
> + * Search forward from there, if not.  N.B., this assumes that the
> + * list of pages handed to migrate_pages()--which is how we get here--
> + * is in virtual address order.
> + */
> +static inline struct page *new_page_alloc_mbind(struct page *page, unsigned long start)

new_page_alloc_mempolicy or new_page_alloc_vma

> +{
> +	struct vm_area_struct *vma;
> +	unsigned long uninitialized_var(address);
> +
> +	vma = find_vma(current->mm, start);
> +	while (vma) {
> +		address = page_address_in_vma(page, vma);
> +		if (address != -EFAULT)
> +			break;
> +		vma = vma->vm_next;
> +	}
> +
> +	if (PageHuge(page)) {
> +		return alloc_huge_page_vma(page_hstate(compound_head(page)),
> +				vma, address);
> +	} else if (PageTransHuge(page)) {
> +		struct page *thp;
> +
> +		thp = alloc_hugepage_vma(GFP_TRANSHUGE, vma, address,
> +					 HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	}
> +	/*
> +	 * if !vma, alloc_page_vma() will use task or system default policy
> +	 */
> +	return alloc_page_vma(GFP_HIGHUSER_MOVABLE | __GFP_RETRY_MAYFAIL,
> +			vma, address);
> +}
> +
> +/* page allocation callback for NUMA node migration */
> +static inline struct page *new_page_alloc_syscall(struct page *page, unsigned long node)

new_page_alloc_node. The important thing about this one is that it
doesn't fall back to any other node. And the comment should be explicit
about that fact.

> +{
> +	if (PageHuge(page))
> +		return alloc_huge_page_node(page_hstate(compound_head(page)),
> +					node);
> +	else if (PageTransHuge(page)) {
> +		struct page *thp;
> +
> +		thp = alloc_pages_node(node,
> +			(GFP_TRANSHUGE | __GFP_THISNODE),
> +			HPAGE_PMD_ORDER);
> +		if (!thp)
> +			return NULL;
> +		prep_transhuge_page(thp);
> +		return thp;
> +	} else
> +		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
> +						    __GFP_THISNODE, 0);
> +}
> +
> +
> +static inline struct page *new_page_alloc_misplaced(struct page *page,
> +					   unsigned long data)

This is so special cased that I even wouldn't expose it. Who is going to
reuse it?

> +{
> +	int nid = (int) data;
> +	struct page *newpage;
> +
> +	newpage = __alloc_pages_node(nid,
> +					 (GFP_HIGHUSER_MOVABLE |
> +					  __GFP_THISNODE | __GFP_NOMEMALLOC |
> +					  __GFP_NORETRY | __GFP_NOWARN) &
> +					 ~__GFP_RECLAIM, 0);

this also deserves one hell of a comment.

> +
> +	return newpage;
> +}
> +
>  static inline struct page *new_page_nodemask(struct page *page,
>  				int preferred_nid, nodemask_t *nodemask)
>  {
> @@ -59,7 +138,34 @@ static inline struct page *new_page_nodemask(struct page *page,
>  	return new_page;
>  }
>  
> -#ifdef CONFIG_MIGRATION
> +static inline struct page *new_page_alloc_failure(struct page *p, unsigned long private)

This function in fact allocates arbitrary page with preference of the
original page's node. It is by no means specific to HWPoison and
_failure in the name is just confusing.

new_page_alloc_keepnode

> +{
> +	int nid = page_to_nid(p);
> +
> +	return new_page_nodemask(p, nid, &node_states[N_MEMORY]);
> +}
> +
> +/*
> + * Try to allocate from a different node but reuse this node if there
> + * are no other online nodes to be used (e.g. we are offlining a part
> + * of the only existing node).
> + */
> +static inline struct page *new_page_alloc_hotplug(struct page *page, unsigned long private)

Does anybody ever want to use the same function? We try hard to allocate
from any other than original node.

> +{
> +	int nid = page_to_nid(page);
> +	nodemask_t nmask = node_states[N_MEMORY];
> +
> +	node_clear(nid, nmask);
> +	if (nodes_empty(nmask))
> +		node_set(nid, nmask);
> +
> +	return new_page_nodemask(page, nid, &nmask);
> +}
> +
> +static inline struct page *new_page_alloc_contig(struct page *page, unsigned long private)

What does this name acutally means? Why not simply new_page_alloc? It
simply allocates from any node with the local node preference. So
basically alloc_pages like.

> +{
> +	return new_page_nodemask(page, numa_node_id(), &node_states[N_MEMORY]);
> +}
>  
>  extern void putback_movable_pages(struct list_head *l);
>  extern int migrate_page(struct address_space *mapping,
> @@ -81,6 +187,10 @@ extern int migrate_page_move_mapping(struct address_space *mapping,
>  		struct buffer_head *head, enum migrate_mode mode,
>  		int extra_count);
>  #else
> +static inline struct page *new_page_alloc_mbind(struct page *page, unsigned long start)
> +{
> +	return NULL;
> +}
>  
>  static inline void putback_movable_pages(struct list_head *l) {}
>  static inline int migrate_pages(struct list_head *l, new_page_t new,
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
