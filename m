Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2AFAC6B004D
	for <linux-mm@kvack.org>; Wed, 19 Aug 2009 08:01:35 -0400 (EDT)
Date: Wed, 19 Aug 2009 20:01:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [RFC] respect the referenced bit of KVM guest pages?
Message-ID: <20090819120117.GB7306@localhost>
References: <20090816051502.GB13740@localhost> <20090816112910.GA3208@localhost> <20090818234310.A64B.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090818234310.A64B.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>, Jeff Dike <jdike@addtoit.com>, Avi Kivity <avi@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, "Yu, Wilfred" <wilfred.yu@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 18, 2009 at 11:57:54PM +0800, KOSAKI Motohiro wrote:
> > > Yes it does. I said 'mostly' because there is a small hole that an
> > > unevictable page may be scanned but still not moved to unevictable
> > > list: when a page is mapped in two places, the first pte has the
> > > referenced bit set, the _second_ VMA has VM_LOCKED bit set, then
> > > page_referenced() will return 1 and shrink_page_list() will move it
> > > into active list instead of unevictable list. Shall we fix this rare
> > > case?
> > 
> > How about this fix?
> 
> Good spotting.
> Yes, this is rare case. but I also don't think your patch introduce
> performance degression.

Thanks.

> However, I think your patch have one bug.

Hehe, sorry for being careless :)

> > 
> > ---
> > mm: stop circulating of referenced mlocked pages
> > 
> > Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> > ---
> > 
> > --- linux.orig/mm/rmap.c	2009-08-16 19:11:13.000000000 +0800
> > +++ linux/mm/rmap.c	2009-08-16 19:22:46.000000000 +0800
> > @@ -358,6 +358,7 @@ static int page_referenced_one(struct pa
> >  	 */
> >  	if (vma->vm_flags & VM_LOCKED) {
> >  		*mapcount = 1;	/* break early from loop */
> > +		*vm_flags |= VM_LOCKED;
> >  		goto out_unmap;
> >  	}
> >  
> > @@ -482,6 +483,8 @@ static int page_referenced_file(struct p
> >  	}
> >  
> >  	spin_unlock(&mapping->i_mmap_lock);
> > +	if (*vm_flags & VM_LOCKED)
> > +		referenced = 0;
> >  	return referenced;
> >  }
> >  
> 
> page_referenced_file?
> I think we should change page_referenced().

Yeah, good catch.

> 
> Instead, How about this?
> ==============================================
> 
> Subject: [PATCH] mm: stop circulating of referenced mlocked pages
> 
> Currently, mlock() systemcall doesn't gurantee to mark the page PG_Mlocked

                                                    mark PG_mlocked

> because some race prevent page grabbing.
> In that case, instead vmscan move the page to unevictable lru.
> 
> However, Recently Wu Fengguang pointed out current vmscan logic isn't so
> efficient.
> mlocked page can move circulatly active and inactive list because
> vmscan check the page is referenced _before_ cull mlocked page.
> 
> Plus, vmscan should mark PG_Mlocked when cull mlocked page.

                           PG_mlocked

> Otherwise vm stastics show strange number.
> 
> This patch does that.

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

> Reported-by: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/internal.h |    5 +++--
>  mm/rmap.c     |    8 +++++++-
>  mm/vmscan.c   |    2 +-
>  3 files changed, 11 insertions(+), 4 deletions(-)
> 
> Index: b/mm/internal.h
> ===================================================================
> --- a/mm/internal.h	2009-06-26 21:06:43.000000000 +0900
> +++ b/mm/internal.h	2009-08-18 23:31:11.000000000 +0900
> @@ -91,7 +91,8 @@ static inline void unevictable_migrate_p
>   * to determine if it's being mapped into a LOCKED vma.
>   * If so, mark page as mlocked.
>   */
> -static inline int is_mlocked_vma(struct vm_area_struct *vma, struct page *page)
> +static inline int try_set_page_mlocked(struct vm_area_struct *vma,
> +				       struct page *page)
>  {
>  	VM_BUG_ON(PageLRU(page));
>  
> @@ -144,7 +145,7 @@ static inline void mlock_migrate_page(st
>  }
>  
>  #else /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
> -static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
> +static inline int try_set_page_mlocked(struct vm_area_struct *v, struct page *p)
>  {
>  	return 0;
>  }
> Index: b/mm/rmap.c
> ===================================================================
> --- a/mm/rmap.c	2009-08-18 19:48:14.000000000 +0900
> +++ b/mm/rmap.c	2009-08-18 23:47:34.000000000 +0900
> @@ -362,7 +362,9 @@ static int page_referenced_one(struct pa
>  	 * unevictable list.
>  	 */
>  	if (vma->vm_flags & VM_LOCKED) {
> -		*mapcount = 1;	/* break early from loop */
> +		*mapcount = 1;		/* break early from loop */
> +		*vm_flags |= VM_LOCKED;	/* for prevent to move active list */

> +		try_set_page_mlocked(vma, page);

That call is not absolutely necessary?

Thanks,
Fengguang

>  		goto out_unmap;
>  	}
>  
> @@ -531,6 +533,9 @@ int page_referenced(struct page *page,
>  	if (page_test_and_clear_young(page))
>  		referenced++;
>  
> +	if (unlikely(*vm_flags & VM_LOCKED))
> +		referenced = 0;
> +
>  	return referenced;
>  }
>  
> @@ -784,6 +789,7 @@ static int try_to_unmap_one(struct page 
>  	 */
>  	if (!(flags & TTU_IGNORE_MLOCK)) {
>  		if (vma->vm_flags & VM_LOCKED) {
> +			try_set_page_mlocked(vma, page);
>  			ret = SWAP_MLOCK;
>  			goto out_unmap;
>  		}
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c	2009-08-18 19:48:14.000000000 +0900
> +++ b/mm/vmscan.c	2009-08-18 23:30:51.000000000 +0900
> @@ -2666,7 +2666,7 @@ int page_evictable(struct page *page, st
>  	if (mapping_unevictable(page_mapping(page)))
>  		return 0;
>  
> -	if (PageMlocked(page) || (vma && is_mlocked_vma(vma, page)))
> +	if (PageMlocked(page) || (vma && try_set_page_mlocked(vma, page)))
>  		return 0;
>  
>  	return 1;
> 
> 
> 
> 
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
