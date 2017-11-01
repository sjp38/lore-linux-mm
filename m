Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 02AF76B0033
	for <linux-mm@kvack.org>; Wed,  1 Nov 2017 02:25:17 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id b79so1390806pfk.9
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 23:25:16 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id s19si3884736pgn.150.2017.10.31.23.25.15
        for <linux-mm@kvack.org>;
        Tue, 31 Oct 2017 23:25:15 -0700 (PDT)
Date: Wed, 1 Nov 2017 15:25:12 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 2/2] mm:swap: unify cluster-based and vma-based swap
 readahead
Message-ID: <20171101062512.GA17739@bbox>
References: <1509514103-17550-1-git-send-email-minchan@kernel.org>
 <1509514103-17550-3-git-send-email-minchan@kernel.org>
 <87375y5xqq.fsf@yhuang-dev.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87375y5xqq.fsf@yhuang-dev.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Huang, Ying" <ying.huang@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hugh Dickins <hughd@google.com>, kernel-team <kernel-team@lge.com>

On Wed, Nov 01, 2017 at 02:17:17PM +0800, Huang, Ying wrote:
> Minchan Kim <minchan@kernel.org> writes:
> 
> > This patch makes do_swap_page no need to be aware of two different
> > swap readahead algorithm. Just unify cluster-based and vma-based
> > readahead function call.
> >
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > ---
> >  include/linux/swap.h | 17 ++++++++++++-----
> >  mm/memory.c          | 11 ++++-------
> >  mm/shmem.c           |  5 ++++-
> >  mm/swap_state.c      | 21 +++++++++++++++------
> >  4 files changed, 35 insertions(+), 19 deletions(-)
> >
> > diff --git a/include/linux/swap.h b/include/linux/swap.h
> > index 7c7c8b344bc9..9cc330360eac 100644
> > --- a/include/linux/swap.h
> > +++ b/include/linux/swap.h
> > @@ -425,9 +425,11 @@ extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
> >  extern struct page *__read_swap_cache_async(swp_entry_t, gfp_t,
> >  			struct vm_area_struct *vma, unsigned long addr,
> >  			bool *new_page_allocated);
> > -extern struct page *swapin_readahead(swp_entry_t, gfp_t,
> > -			struct vm_area_struct *vma, unsigned long addr);
> > -extern struct page *do_swap_page_readahead(swp_entry_t fentry, gfp_t gfp_mask,
> > +extern struct page *cluster_readahead(swp_entry_t entry, gfp_t flag,
> > +				struct vm_fault *vmf);
> 
> In addition to swap readahead, there are file readahead too.  So better
> add swap in name, such as swap_cluster_readahead()?

Yub.

> 
> > +extern struct page *swapin_readahead(swp_entry_t entry, gfp_t flag,
> > +				struct vm_fault *vmf);
> > +extern struct page *vma_readahead(swp_entry_t fentry, gfp_t gfp_mask,
> >  					   struct vm_fault *vmf);
> 
> I don't find vma_readahead() is used outside of page_state.c, why
> declare it here?

By wrapping function, it's pointless to declare.
Yub, Let's drop it.


> 
> >  
> >  /* linux/mm/swapfile.c */
> > @@ -536,8 +538,13 @@ static inline void put_swap_page(struct page *page, swp_entry_t swp)
> >  {
> >  }
> >  
> > +static inline struct page *cluster_readahead(swp_entry_t, gfp_t gfp_mask
> > +						struct vm_fault *vmf)
> > +{
> > +}
> > +
> >  static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
> > -			struct vm_area_struct *vma, unsigned long addr)
> > +			struct vm_fault *vmf)
> >  {
> >  	return NULL;
> >  }
> > @@ -547,7 +554,7 @@ static inline bool swap_use_vma_readahead(void)
> >  	return false;
> >  }
> 
> Now swap_use_vma_readahead() is used in swap_state.c only, so we can
> remove it from the header file?

Will do.

> 
> > -static inline struct page *do_swap_page_readahead(swp_entry_t fentry,
> > +static inline struct page *vma_readahead(swp_entry_t fentry,
> >  				gfp_t gfp_mask, struct vm_fault *vmf)
> >  {
> >  	return NULL;
> > diff --git a/mm/memory.c b/mm/memory.c
> > index e955298e4290..ce5e3d7ccc5c 100644
> > --- a/mm/memory.c
> > +++ b/mm/memory.c
> > @@ -2889,7 +2889,8 @@ int do_swap_page(struct vm_fault *vmf)
> >  		if (si->flags & SWP_SYNCHRONOUS_IO &&
> >  				__swap_count(si, entry) == 1) {
> >  			/* skip swapcache */
> > -			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, vmf->address);
> > +			page = alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
> > +							vmf->address);
> >  			if (page) {
> >  				__SetPageLocked(page);
> >  				__SetPageSwapBacked(page);
> > @@ -2898,12 +2899,8 @@ int do_swap_page(struct vm_fault *vmf)
> >  				swap_readpage(page, true);
> >  			}
> >  		} else {
> > -			if (swap_use_vma_readahead())
> > -				page = do_swap_page_readahead(entry,
> > -					GFP_HIGHUSER_MOVABLE, vmf);
> > -			else
> > -				page = swapin_readahead(entry,
> > -				       GFP_HIGHUSER_MOVABLE, vma, vmf->address);
> > +			page = swapin_readahead(entry, GFP_HIGHUSER_MOVABLE,
> > +						vmf);
> >  			swapcache = page;
> >  		}
> >  
> > diff --git a/mm/shmem.c b/mm/shmem.c
> > index 62dfdc097e44..2522bc0958e1 100644
> > --- a/mm/shmem.c
> > +++ b/mm/shmem.c
> > @@ -1413,9 +1413,12 @@ static struct page *shmem_swapin(swp_entry_t swap, gfp_t gfp,
> >  {
> >  	struct vm_area_struct pvma;
> >  	struct page *page;
> > +	struct vm_fault vmf;
> >  
> >  	shmem_pseudo_vma_init(&pvma, info, index);
> > -	page = swapin_readahead(swap, gfp, &pvma, 0);
> > +	vmf.vma = &pvma;
> > +	vmf.address = 0;
> > +	page = cluster_readahead(swap, gfp, &vmf);
> >  	shmem_pseudo_vma_destroy(&pvma);
> >  
> >  	return page;
> > diff --git a/mm/swap_state.c b/mm/swap_state.c
> > index e3c535fcd2df..5ee53d4ee047 100644
> > --- a/mm/swap_state.c
> > +++ b/mm/swap_state.c
> > @@ -538,11 +538,10 @@ static unsigned long swapin_nr_pages(unsigned long offset)
> >  }
> >  
> >  /**
> > - * swapin_readahead - swap in pages in hope we need them soon
> > + * cluster_readahead - swap in pages in hope we need them soon
> >   * @entry: swap entry of this memory
> >   * @gfp_mask: memory allocation flags
> > - * @vma: user vma this address belongs to
> > - * @addr: target address for mempolicy
> > + * @vmf: fault information
> >   *
> >   * Returns the struct page for entry and addr, after queueing swapin.
> >   *
> > @@ -556,8 +555,8 @@ static unsigned long swapin_nr_pages(unsigned long offset)
> >   *
> >   * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
> >   */
> > -struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> > -			struct vm_area_struct *vma, unsigned long addr)
> > +struct page *cluster_readahead(swp_entry_t entry, gfp_t gfp_mask,
> > +				struct vm_fault *vmf)
> >  {
> >  	struct page *page;
> >  	unsigned long entry_offset = swp_offset(entry);
> > @@ -566,6 +565,8 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> >  	unsigned long mask;
> >  	struct blk_plug plug;
> >  	bool do_poll = true, page_allocated;
> > +	struct vm_area_struct *vma = vmf->vma;
> > +	unsigned long addr = vmf->address;
> >  
> >  	mask = swapin_nr_pages(offset) - 1;
> >  	if (!mask)
> > @@ -603,6 +604,14 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> >  	return read_swap_cache_async(entry, gfp_mask, vma, addr, do_poll);
> >  }
> >
> 
> No function document for swapin_readahead()?  It is the main interface
> for swap readahead.

Okay, I will remain original desciription and append some more.

Thanks for the quick review, Huang.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
