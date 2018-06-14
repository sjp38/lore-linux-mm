Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2E296B0003
	for <linux-mm@kvack.org>; Thu, 14 Jun 2018 11:57:20 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id a12-v6so3166040pfn.12
        for <linux-mm@kvack.org>; Thu, 14 Jun 2018 08:57:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id s9-v6si4613763pgr.474.2018.06.14.08.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Jun 2018 08:57:17 -0700 (PDT)
Date: Thu, 14 Jun 2018 18:57:13 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: [PATCHv3 04/17] mm/page_alloc: Handle allocation for encrypted
 memory
Message-ID: <20180614155713.kfuzoovnyoldf7vr@black.fi.intel.com>
References: <20180612143915.68065-1-kirill.shutemov@linux.intel.com>
 <20180612143915.68065-5-kirill.shutemov@linux.intel.com>
 <e0ecf890-2621-83a0-cd01-edce4a158ff1@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0ecf890-2621-83a0-cd01-edce4a158ff1@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>, Kai Huang <kai.huang@linux.intel.com>, Jacob Pan <jacob.jun.pan@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Jun 13, 2018 at 06:07:40PM +0000, Dave Hansen wrote:
> On 06/12/2018 07:39 AM, Kirill A. Shutemov wrote:
> > For encrypted memory, we need to allocated pages for a specific
> > encryption KeyID.
> 
> "allocate"                         ^
> 
> > There are two cases when we need to allocate a page for encryption:
> > 
> >  - Allocation for an encrypted VMA;
> > 
> >  - Allocation for migration of encrypted page;
> > 
> > The first case can be covered within alloc_page_vma().
> 
> ... because we know the KeyID from the VMA?

Right. I'll update commit message.

> > The second case requires few new page allocation routines that would
> > allocate the page for a specific KeyID.
> > 
> > Encrypted page has to be cleared after KeyID set. This is handled by
> 
> "An encrypted page has ... "
> 
> This description lacks a description of the performance impact of the
> approach in this patch both when allocating encrypted and normal pages.

You are right. I'll measure for the next iteration.

> > --- a/arch/alpha/include/asm/page.h
> > +++ b/arch/alpha/include/asm/page.h
> > @@ -18,7 +18,7 @@ extern void clear_page(void *page);
> >  #define clear_user_page(page, vaddr, pg)	clear_page(page)
> >  
> >  #define __alloc_zeroed_user_highpage(movableflags, vma, vaddr) \
> > -	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vmaddr)
> > +	alloc_page_vma(GFP_HIGHUSER | __GFP_ZERO | movableflags, vma, vaddr)
> >  #define __HAVE_ARCH_ALLOC_ZEROED_USER_HIGHPAGE
> 
> Does this compile?  Wouldn't "vmaddr" be undefined?

Yes, it compiles.

Before I reorganized macros around alloc_page_vma(), the argument was
ignored for non-NUMA systems. NUMA on Alpha marked BROKEN and never
enabled.

> > +#define alloc_hugepage_vma(gfp_mask, vma, addr, order) \
> > +	alloc_pages_vma(gfp_mask, order, vma, addr, numa_node_id(), true)
> 
> The argument addition should be broken out into a preparatory patch.

There's no new argument. I've just unified alloc_hugepage_vma() codepath
for NUMA and non-NUMA.

But sure I'll split it into a separate patch.

> >  extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
> >  extern unsigned long get_zeroed_page(gfp_t gfp_mask);
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index f2b4abbca55e..6da504bad841 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -38,9 +38,11 @@ static inline struct page *new_page_nodemask(struct page *page,
> >  	unsigned int order = 0;
> >  	struct page *new_page = NULL;
> >  
> > -	if (PageHuge(page))
> > +	if (PageHuge(page)) {
> > +		WARN_ON(page_keyid(page));
> >  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> >  				preferred_nid, nodemask);
> > +	}
> 
> Comment on the warning, please.

Sure.

> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 9ac49ef17b4e..00bccbececea 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -920,22 +920,24 @@ static void migrate_page_add(struct page *page, struct list_head *pagelist,
> >  /* page allocation callback for NUMA node migration */
> >  struct page *alloc_new_node_page(struct page *page, unsigned long node)
> >  {
> > -	if (PageHuge(page))
> > +	if (PageHuge(page)) {
> > +		WARN_ON(page_keyid(page));
> >  		return alloc_huge_page_node(page_hstate(compound_head(page)),
> >  					node);
> 
> Comments, please.
> 
> > @@ -2012,9 +2014,16 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  {
> >  	struct mempolicy *pol;
> >  	struct page *page;
> > -	int preferred_nid;
> > +	bool zero = false;
> > +	int keyid, preferred_nid;
> >  	nodemask_t *nmask;
> >  
> > +	keyid = vma_keyid(vma);
> > +	if (keyid && gfp & __GFP_ZERO) {
> > +		zero = true;
> > +		gfp &= ~__GFP_ZERO;
> > +	}
> 
> I totally read that wrong.
> 
> "zero" needs to be named: "page_need_zeroing".
> 
> It also badly needs a comment.

Got it.

> >  	pol = get_vma_policy(vma, addr);
> >  
> >  	if (pol->mode == MPOL_INTERLEAVE) {
> > @@ -2057,6 +2066,8 @@ alloc_pages_vma(gfp_t gfp, int order, struct vm_area_struct *vma,
> >  	page = __alloc_pages_nodemask(gfp, order, preferred_nid, nmask);
> >  	mpol_cond_put(pol);
> >  out:
> > +	if (page && keyid)
> > +		prep_encrypted_page(page, order, keyid, zero);
> >  	return page;
> >  }
> 
> I'd just have prep_encrypted_page() do the keyid-0 opt-out of the prep
> work.  It'll be less to patch when you

Makes sense.

> > diff --git a/mm/migrate.c b/mm/migrate.c
> > index 8c0af0f7cab1..eb8dea219dcb 100644
> > --- a/mm/migrate.c
> > +++ b/mm/migrate.c
> > @@ -1847,7 +1847,7 @@ static struct page *alloc_misplaced_dst_page(struct page *page,
> >  	int nid = (int) data;
> >  	struct page *newpage;
> >  
> > -	newpage = __alloc_pages_node(nid,
> > +	newpage = __alloc_pages_node_keyid(nid, page_keyid(page),
> >  					 (GFP_HIGHUSER_MOVABLE |
> >  					  __GFP_THISNODE | __GFP_NOMEMALLOC |
> >  					  __GFP_NORETRY | __GFP_NOWARN) &
> 
> I thought folks asked you not to change all of the calling conventions
> across the page allocator.  It seems like you're still doing that,
> though.  A reviewer might think you've ignored their earlier feedback.
> Did you?

No. I asked to implement encrypted page allocation as a wrappers on top of
existing routines.

> > +#ifndef CONFIG_NUMA
> > +struct page *alloc_pages_vma(gfp_t gfp_mask, int order,
> > +		struct vm_area_struct *vma, unsigned long addr,
> > +		int node, bool hugepage)
> > +{
> > +	struct page *page;
> > +	bool zero = false;
> > +	int keyid = vma_keyid(vma);
> > +
> > +	if (keyid && (gfp_mask & __GFP_ZERO)) {
> 
> Please at least do your parenthesis consistently. :)

Okay.

> > +		zero = true;
> > +		gfp_mask &= ~__GFP_ZERO;
> > +	}
> > +
> > +	page = alloc_pages(gfp_mask, order);
> > +	if (page && keyid)
> > +		prep_encrypted_page(page, order, keyid, zero);
> > +
> > +	return page;
> > +}
> > +#endif
> 
> I'm also confused by the #ifdef.  What is it for?

We already have alloc_pages_vma() for NUMA. See mm/mempolicy.c.

> > +struct page * __alloc_pages_node_keyid(int nid, int keyid,
> > +		gfp_t gfp_mask, unsigned int order)
> > +{
> > +	struct page *page;
> > +	bool zero = false;
> > +
> > +	VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES);
> > +	VM_WARN_ON(!node_online(nid));
> > +
> > +	if (keyid && (gfp_mask & __GFP_ZERO)) {
> > +		zero = true;
> > +		gfp_mask &= ~__GFP_ZERO;
> > +	}
> 
> OK, so this is the third time I've seen that pattern.  Are you *sure*
> you don't want to consolidate the sites?

I'll see what I can do here.

Not sure if a wrapper will be cleaner for a reader: we need to return two
values new gfp_mask and page_need_zeroing.

> > +	page = __alloc_pages(gfp_mask, order, nid);
> > +	if (page && keyid)
> > +		prep_encrypted_page(page, order, keyid, zero);
> > +
> > +	return page;
> > +}
> > +
> >  #ifdef CONFIG_LOCKDEP
> >  struct lockdep_map __fs_reclaim_map =
> >  	STATIC_LOCKDEP_MAP_INIT("fs_reclaim", &__fs_reclaim_map);
> > @@ -4396,6 +4439,26 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int preferred_nid,
> >  }
> >  EXPORT_SYMBOL(__alloc_pages_nodemask);
> >  
> > +struct page *
> > +__alloc_pages_nodemask_keyid(gfp_t gfp_mask, unsigned int order,
> > +		int preferred_nid, nodemask_t *nodemask, int keyid)
> > +{
> > +	struct page *page;
> > +	bool zero = false;
> > +
> > +	if (keyid && (gfp_mask & __GFP_ZERO)) {
> > +		zero = true;
> > +		gfp_mask &= ~__GFP_ZERO;
> > +	}
> 
> Fourth one. :)
> 

-- 
 Kirill A. Shutemov
