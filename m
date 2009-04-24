Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id BA2726B003D
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 07:51:31 -0400 (EDT)
Subject: Re: [PATCH 15/22] Do not disable interrupts in free_page_mlock()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090424113312.GG14283@csn.ul.ie>
References: <1240408407-21848-16-git-send-email-mel@csn.ul.ie>
	 <20090423155951.6778bdd3.akpm@linux-foundation.org>
	 <20090424090721.1047.A69D9226@jp.fujitsu.com>
	 <20090424113312.GG14283@csn.ul.ie>
Content-Type: text/plain
Date: Fri, 24 Apr 2009 07:52:16 -0400
Message-Id: <1240573936.4315.2.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi, Dave Hansen <dave@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2009-04-24 at 12:33 +0100, Mel Gorman wrote: 
> On Fri, Apr 24, 2009 at 09:33:50AM +0900, KOSAKI Motohiro wrote:
> > > > @@ -157,14 +157,9 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
> > > >   */
> > > >  static inline void free_page_mlock(struct page *page)
> > > >  {
> > > > -	if (unlikely(TestClearPageMlocked(page))) {
> > > > -		unsigned long flags;
> > > > -
> > > > -		local_irq_save(flags);
> > > > -		__dec_zone_page_state(page, NR_MLOCK);
> > > > -		__count_vm_event(UNEVICTABLE_MLOCKFREED);
> > > > -		local_irq_restore(flags);
> > > > -	}
> > > > +	__ClearPageMlocked(page);
> > > > +	__dec_zone_page_state(page, NR_MLOCK);
> > > > +	__count_vm_event(UNEVICTABLE_MLOCKFREED);
> > > >  }
> > > 
> > > The conscientuous reviewer runs around and checks for free_page_mlock()
> > > callers in other .c files which might be affected.
> > > 
> > > Only there are no such callers.
> > > 
> > > The reviewer's job would be reduced if free_page_mlock() wasn't
> > > needlessly placed in a header file!
> > 
> > very sorry.
> > 
> > How about this?
> > 
> > =============================================
> > Subject: [PATCH] move free_page_mlock() to page_alloc.c
> > 
> > Currently, free_page_mlock() is only called from page_alloc.c.
> > Thus, we can move it to page_alloc.c.
> > 
> 
> Looks good, but here is a version rebased on top of the patch series
> where it would be easier to merge with "Do not disable interrupts in
> free_page_mlock()".
> 
> I do note why it might be in the header though - it keeps all the
> CONFIG_HAVE_MLOCKED_PAGE_BIT-related helper functions together making it
> easier to find them. Lee, was that the intention?

Yes.  Having been dinged one too many times for adding extraneous
#ifdef's to .c's I try to avoid that...

Note that in page-flags.h, we define MLOCK_PAGES as 0 or 1 based on
CONFIG_HAVE_MLOCKED_PAGE_BIT, so you could test that in
free_page_mlock() to eliminate the #ifdef in page_alloc.c as we do in
try_to_unmap_*() over in rmap.c.  Guess I could have done that when I
added MLOCK_PAGES.  Got lost in the heat of the battle.

Lee


> 
> =======
> From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> 
> Move free_page_mlock() from mm/internal.h to mm/page_alloc.c
> 
> Currently, free_page_mlock() is only called from page_alloc.c. This patch
> moves it from a header to to page_alloc.c.
> 
> [mel@csn.ul.ie: Rebase on top of page allocator patches]
> Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
> Cc: Christoph Lameter <cl@linux-foundation.org>
> Cc: Pekka Enberg <penberg@cs.helsinki.fi>
> Cc: Dave Hansen <dave@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> ---
>  mm/internal.h   |   13 -------------
>  mm/page_alloc.c |   16 ++++++++++++++++
>  2 files changed, 16 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/internal.h b/mm/internal.h
> index 58ec1bc..4b1672a 100644
> --- a/mm/internal.h
> +++ b/mm/internal.h
> @@ -150,18 +150,6 @@ static inline void mlock_migrate_page(struct page *newpage, struct page *page)
>  	}
>  }
>  
> -/*
> - * free_page_mlock() -- clean up attempts to free and mlocked() page.
> - * Page should not be on lru, so no need to fix that up.
> - * free_pages_check() will verify...
> - */
> -static inline void free_page_mlock(struct page *page)
> -{
> -	__ClearPageMlocked(page);
> -	__dec_zone_page_state(page, NR_MLOCK);
> -	__count_vm_event(UNEVICTABLE_MLOCKFREED);
> -}
> -
>  #else /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
>  static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
>  {
> @@ -170,7 +158,6 @@ static inline int is_mlocked_vma(struct vm_area_struct *v, struct page *p)
>  static inline void clear_page_mlock(struct page *page) { }
>  static inline void mlock_vma_page(struct page *page) { }
>  static inline void mlock_migrate_page(struct page *new, struct page *old) { }
> -static inline void free_page_mlock(struct page *page) { }
>  
>  #endif /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index f08b4cb..3db5f57 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -433,6 +433,22 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
>  	return 0;
>  }
>  
> +#ifdef CONFIG_HAVE_MLOCKED_PAGE_BIT
> +/*
> + * free_page_mlock() -- clean up attempts to free and mlocked() page.
> + * Page should not be on lru, so no need to fix that up.
> + * free_pages_check() will verify...
> + */
> +static inline void free_page_mlock(struct page *page)
> +{
> +	__ClearPageMlocked(page);
> +	__dec_zone_page_state(page, NR_MLOCK);
> +	__count_vm_event(UNEVICTABLE_MLOCKFREED);
> +}
> +#else
> +static inline void free_page_mlock(struct page *page) { }
> +#endif /* CONFIG_HAVE_MLOCKED_PAGE_BIT */
> +
>  /*
>   * Freeing function for a buddy system allocator.
>   *
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
