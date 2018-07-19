Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 39B806B000E
	for <linux-mm@kvack.org>; Thu, 19 Jul 2018 04:27:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id v9-v6so3715958pff.4
        for <linux-mm@kvack.org>; Thu, 19 Jul 2018 01:27:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q1-v6sor1826263plb.62.2018.07.19.01.27.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Jul 2018 01:27:31 -0700 (PDT)
Date: Thu, 19 Jul 2018 11:27:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv5 05/19] mm/page_alloc: Handle allocation for encrypted
 memory
Message-ID: <20180719082724.4qvfdp6q4kuhxskn@kshutemo-mobl1>
References: <20180717112029.42378-1-kirill.shutemov@linux.intel.com>
 <20180717112029.42378-6-kirill.shutemov@linux.intel.com>
 <95ce19cb-332c-44f5-b3a1-6cfebd870127@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <95ce19cb-332c-44f5-b3a1-6cfebd870127@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Michal Hocko <mhocko@suse.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jul 18, 2018 at 04:03:53PM -0700, Dave Hansen wrote:
> I asked about this before and it still isn't covered in the description:
> You were specifically asked (maybe in person at LSF/MM?) not to modify
> allocator to pass the keyid around.  Please specifically mention how
> this design addresses that feedback in the patch description.
> 
> You were told, "don't change the core allocator", so I think you just
> added new functions that wrap the core allocator and called them from
> the majority of sites that call into the core allocator.  Personally, I
> think that misses the point of the original request.
> 
> Do I have a better way?  Nope, not really.

+Michal.

IIRC, Michal was not happy that I propagate the KeyID to very core
allcoator and we've talked about wrappers around existing APIs as a better
solution.

Michal, is it correct?

> > +/*
> > + * Encrypted page has to be cleared once keyid is set, not on allocation.
> > + */
> > +static inline bool encrypted_page_needs_zero(int keyid, gfp_t *gfp_mask)
> > +{
> > +	if (!keyid)
> > +		return false;
> > +
> > +	if (*gfp_mask & __GFP_ZERO) {
> > +		*gfp_mask &= ~__GFP_ZERO;
> > +		return true;
> > +	}
> > +
> > +	return false;
> > +}
> 
> Shouldn't this be zero_page_at_alloc()?
> 
> Otherwise, it gets confusing about whether the page needs zeroing at
> *all*, vs at alloc vs. free.

I like your idea with deferred_page_zero() below. I'll go with it.

> > +static inline struct page *alloc_pages_node_keyid(int nid, int keyid,
> > +		gfp_t gfp_mask, unsigned int order)
> > +{
> > +	if (nid == NUMA_NO_NODE)
> > +		nid = numa_mem_id();
> > +
> > +	return __alloc_pages_node_keyid(nid, keyid, gfp_mask, order);
> > +}
> 
> We have an innumerable number of (__)?alloc_pages* functions.  This adds
> two more.  I'm not a big fan of making this worse.
> 
> Do I have a better idea?  Not really.  The best I have is to start being
> more careful about all of the arguments and actually formalize the list
> of things that we need to succeed in an allocation in a struct
> alloc_args or something.

Sounds like a separate project to me :)

> >  #define alloc_page(gfp_mask) alloc_pages(gfp_mask, 0)
> >  #define alloc_page_vma(gfp_mask, vma, addr)			\
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index f2b4abbca55e..fede9bfa89d9 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -38,9 +38,15 @@ static inline struct page *new_page_nodemask(struct page *page,
> >  	unsigned int order = 0;
> >  	struct page *new_page = NULL;
> >  
> > -	if (PageHuge(page))
> > +	if (PageHuge(page)) {
> > +		/*
> > +		 * HugeTLB doesn't support encryption. We shouldn't see
> > +		 * such pages.
> > +		 */
> > +		WARN_ON(page_keyid(page));
> >  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> >  				preferred_nid, nodemask);
> > +	}
> 
> Shouldn't we be returning NULL?  Seems like failing the allocation is
> much less likely to result in bad things happening.

Okay.

> >  	if (PageTransHuge(page)) {
> >  		gfp_mask |= GFP_TRANSHUGE;
> > @@ -50,8 +56,8 @@ static inline struct page *new_page_nodemask(struct page *page,
> >  	if (PageHighMem(page) || (zone_idx(page_zone(page)) == ZONE_MOVABLE))
> >  		gfp_mask |= __GFP_HIGHMEM;
> >  
> > -	new_page = __alloc_pages_nodemask(gfp_mask, order,
> > -				preferred_nid, nodemask);
> > +	new_page = __alloc_pages_nodemask_keyid(gfp_mask, order,
> > +				preferred_nid, nodemask, page_keyid(page));
> 
> Needs a comment please.  It's totally non-obvious that this is the
> migration case from the context, new_page_nodemask()'s name, or the name
> of 'page'.
> 
> 	/* Allocate a page with the same KeyID as the source page */

Sure.

> 
> > diff --git a/mm/compaction.c b/mm/compaction.c
> > index faca45ebe62d..fd51aa32ad96 100644
> > --- a/mm/compaction.c
> > +++ b/mm/compaction.c
> > @@ -1187,6 +1187,7 @@ static struct page *compaction_alloc(struct page *migratepage,
> >  	list_del(&freepage->lru);
> >  	cc->nr_freepages--;
> >  
> > +	prep_encrypted_page(freepage, 0, page_keyid(migratepage), false);
> >  	return freepage;
> >  }
> 
> Comments, please.
> 
> Why is this here?

/* Prepare the page using the same KeyID as the source page */

> What other code might need prep_encrypted_page()?

Custom pages allocators if these pages can end up in encrypted VMAs.

It this case compaction creates own pool of pages to be used for
allocation during page migration.

> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 581b729e05a0..ce7b436444b5 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -921,22 +921,28 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
> >  /* page allocation callback for NUMA node migration */
> >  struct page *alloc_new_node_page(struct page *page, unsigned long node)
> >  {
> > -	if (PageHuge(page))
> > +	if (PageHuge(page)) {
> > +		/*
> > +		 * HugeTLB doesn't support encryption. We shouldn't see
> > +		 * such pages.
> > +		 */
> > +		WARN_ON(page_keyid(page));
> >  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> >  					node);
> > -	else if (PageTransHuge(page)) {
> > +	} else if (PageTransHuge(page)) {
> >  		struct page *thp;
> >  
> > -		thp = alloc_pages_node(node,
> > +		thp = alloc_pages_node_keyid(node, page_keyid(page),
> >  			(GFP_TRANSHUGE | __GFP_THISNODE),
> >  			HPAGE_PMD_ORDER);
> >  		if (!thp)
> >  			return NULL;
> >  		prep_transhuge_page(thp);
> >  		return thp;
> > -	} else
> > -		return __alloc_pages_node(node, GFP_HIGHUSER_MOVABLE |
> > -						    __GFP_THISNODE, 0);
> > +	} else {
> > +		return __alloc_pages_node_keyid(node, page_keyid(page),
> > +				GFP_HIGHUSER_MOVABLE | __GFP_THISNODE, 0);
> > +	}
> >  }
> >  
> >  /*
> > @@ -2013,9 +2019,16 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  {
> >  	struct mempolicy *pol;
> >  	struct page *page;
> > -	int preferred_nid;
> > +	bool zero = false;
> > +	int keyid, preferred_nid;
> >  	nodemask_t *nmask;
> >  
> > +	keyid = vma_keyid(vma);
> > +	if (keyid && (gfp & __GFP_ZERO)) {
> > +		zero = true;
> > +		gfp &= ~__GFP_ZERO;
> > +	}
> 
> Comments, please.  'zero' should be 'deferred_zero', at least.
> 
> Also, can't we hide this a _bit_ better?
> 
> 	if (deferred_page_zero(vma))
> 		gfp &= ~__GFP_ZERO;
> 
> Then, later:
> 
> 	deferred_page_prep(vma, page, order);
> 
> and hide everything in deferred_page_zero() and deferred_page_prep().
> 
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -3697,6 +3697,39 @@ should_compact_retry(struct alloc_context *ac, unsigned int order, int alloc_fla
> >  }
> >  #endif /* CONFIG_COMPACTION */
> >  
> > +#ifndef CONFIG_NUMA
> > +struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
> > +		struct vm_area_struct *vma, unsigned long addr,
> > +		int node, bool hugepage)
> > +{
> > +	struct page *page;
> > +	bool need_zero;
> > +	int keyid = vma_keyid(vma);
> > +
> > +	need_zero = encrypted_page_needs_zero(keyid, &gfp_mask);
> > +	page = alloc_pages(gfp_mask, order);
> > +	prep_encrypted_page(page, order, keyid, need_zero);
> > +
> > +	return page;
> > +}
> > +#endif
> 
> Is there *ever* a VMA-based allocation that doesn't need zeroing?

Sure. Any allocations for CoW.

> > +struct page * __alloc_pages_node_keyid(int nid, int keyid,
> > +		gfp_t gfp_mask, unsigned int order)
> > +{
> > +	struct page *page;
> > +	bool need_zero;
> > +
> > +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> > +	VM_WARN_ON(!node_online(nid));
> > +
> > +	need_zero = encrypted_page_needs_zero(keyid, &gfp_mask);
> > +	page = __alloc_pages(gfp_mask, order, nid);
> > +	prep_encrypted_page(page, order, keyid, need_zero);
> > +
> > +	return page;
> > +}
> > +
> >  #ifdef CONFIG_LOCKDEP
> >  static struct lockdep_map __fs_reclaim_map =
> >  	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
> > @@ -4401,6 +4434,20 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >  }
> >  EXPORT_SYMBOL(__alloc_pages_nodemask);
> >  
> > +struct page *
> > +__alloc_pages_nodemask_keyid(gfp_t gfp_mask, unsigned int order,
> > +		int preferred_nid, nodemask_t *nodemask, int keyid)
> > +{
> > +	struct page *page;
> > +	bool need_zero;
> > +
> > +	need_zero = encrypted_page_needs_zero(keyid, &gfp_mask);
> > +	page = __alloc_pages_nodemask(gfp_mask, order, preferred_nid, nodemask);
> > +	prep_encrypted_page(page, order, keyid, need_zero);
> > +	return page;
> > +}
> > +EXPORT_SYMBOL(__alloc_pages_nodemask_keyid);
> 
> That looks like three duplicates of the same code, wrapping three more
> allocator variants.  Do we really have no other alternatives?  Can you
> please go ask the folks that gave you the feedback about the allocator
> modifications and ask them if this is OK explicitly?

Michal, any feedback for the patch?

-- 
G Kirill A. Shutemov
