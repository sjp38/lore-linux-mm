Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D9E7E6B0036
	for <linux-mm@kvack.org>; Fri,  5 Sep 2014 11:39:52 -0400 (EDT)
Received: by mail-wg0-f52.google.com with SMTP id m15so11851132wgh.35
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 08:39:52 -0700 (PDT)
Received: from mail-we0-x22e.google.com (mail-we0-x22e.google.com [2a00:1450:400c:c03::22e])
        by mx.google.com with ESMTPS id r6si4014014wif.64.2014.09.05.08.39.51
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Sep 2014 08:39:51 -0700 (PDT)
Received: by mail-we0-f174.google.com with SMTP id w61so541399wes.33
        for <linux-mm@kvack.org>; Fri, 05 Sep 2014 08:39:50 -0700 (PDT)
Date: Fri, 5 Sep 2014 17:39:48 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: regression caused by cgroups optimization in 3.17-rc2
Message-ID: <20140905153948.GH26243@dhcp22.suse.cz>
References: <54061505.8020500@sr71.net>
 <5406262F.4050705@intel.com>
 <54062F32.5070504@sr71.net>
 <20140904142721.GB14548@dhcp22.suse.cz>
 <5408CB2E.3080101@sr71.net>
 <20140905092537.GC26243@dhcp22.suse.cz>
 <20140905144723.GB13392@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140905144723.GB13392@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dave Hansen <dave@sr71.net>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Tejun Heo <tj@kernel.org>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Vladimir Davydov <vdavydov@parallels.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 05-09-14 10:47:23, Johannes Weiner wrote:
> On Fri, Sep 05, 2014 at 11:25:37AM +0200, Michal Hocko wrote:
> > @@ -900,10 +900,10 @@ void lru_add_drain_all(void)
> >   * grabbed the page via the LRU.  If it did, give up: shrink_inactive_list()
> >   * will free it.
> >   */
> > -void release_pages(struct page **pages, int nr, bool cold)
> > +static void release_lru_pages(struct page **pages, int nr,
> > +			      struct list_head *pages_to_free)
> >  {
> >  	int i;
> > -	LIST_HEAD(pages_to_free);
> >  	struct zone *zone = NULL;
> >  	struct lruvec *lruvec;
> >  	unsigned long uninitialized_var(flags);
> > @@ -943,11 +943,26 @@ void release_pages(struct page **pages, int nr, bool cold)
> >  		/* Clear Active bit in case of parallel mark_page_accessed */
> >  		__ClearPageActive(page);
> >  
> > -		list_add(&page->lru, &pages_to_free);
> > +		list_add(&page->lru, pages_to_free);
> >  	}
> >  	if (zone)
> >  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> > +}
> > +/*
> > + * Batched page_cache_release(). Frees and uncharges all given pages
> > + * for which the reference count drops to 0.
> > + */
> > +void release_pages(struct page **pages, int nr, bool cold)
> > +{
> > +	LIST_HEAD(pages_to_free);
> >  
> > +	while (nr) {
> > +		int batch = min(nr, PAGEVEC_SIZE);
> > +
> > +		release_lru_pages(pages, batch, &pages_to_free);
> > +		pages += batch;
> > +		nr -= batch;
> > +	}
> 
> We might be able to process a lot more pages in one go if nobody else
> needs the lock or the CPU.  Can't we just cycle the lock or reschedule
> if necessary?

Is it safe to cond_resched here for all callers? I hope it is but there
are way too many callers to check so I am not 100% sure.

Besides that spin_needbreak doesn't seem to be available for all architectures.
git grep "arch_spin_is_contended(" -- arch/
arch/arm/include/asm/spinlock.h:static inline int arch_spin_is_contended(arch_spinlock_t *lock)
arch/arm64/include/asm/spinlock.h:static inline int arch_spin_is_contended(arch_spinlock_t *lock)
arch/ia64/include/asm/spinlock.h:static inline int arch_spin_is_contended(arch_spinlock_t *lock)
arch/mips/include/asm/spinlock.h:static inline int arch_spin_is_contended(arch_spinlock_t *lock)
arch/x86/include/asm/spinlock.h:static inline int arch_spin_is_contended(arch_spinlock_t *lock)

Moreover it doesn't seem to do anything for !CONFIG_PREEMPT but this
should be trivial to fix.

I am also not sure this will work well in all cases. If we have a heavy
reclaim activity on other CPUs then this path might be interrupted too
often resulting in too much lock bouncing. So I guess we want at least
few pages to be processed in one run. On the other hand if the lock is
not contended then doing batches and retake the lock shouldn't add too
much overhead, no?

> diff --git a/mm/swap.c b/mm/swap.c
> index 6b2dc3897cd5..ee0cf21dd521 100644
> --- a/mm/swap.c
> +++ b/mm/swap.c
> @@ -944,6 +944,15 @@ void release_pages(struct page **pages, int nr, bool cold)
>  		__ClearPageActive(page);
>  
>  		list_add(&page->lru, &pages_to_free);
> +
> +		if (should_resched() ||
> +		    (zone && spin_needbreak(&zone->lru_lock))) {
> +			if (zone) {
> +				spin_unlock_irqrestore(&zone->lru_lock, flags);
> +				zone = NULL;
> +			}
> +			cond_resched();
> +		}
>  	}
>  	if (zone)
>  		spin_unlock_irqrestore(&zone->lru_lock, flags);
> diff --git a/mm/swap_state.c b/mm/swap_state.c
> index 3e0ec83d000c..c487ca4682a4 100644
> --- a/mm/swap_state.c
> +++ b/mm/swap_state.c
> @@ -262,19 +262,12 @@ void free_page_and_swap_cache(struct page *page)
>   */
>  void free_pages_and_swap_cache(struct page **pages, int nr)
>  {
> -	struct page **pagep = pages;
> +	int i;
>  
>  	lru_add_drain();
> -	while (nr) {
> -		int todo = min(nr, PAGEVEC_SIZE);
> -		int i;
> -
> -		for (i = 0; i < todo; i++)
> -			free_swap_cache(pagep[i]);
> -		release_pages(pagep, todo, false);
> -		pagep += todo;
> -		nr -= todo;
> -	}
> +	for (i = 0; i < nr; i++)
> +		free_swap_cache(pages[i]);
> +	release_pages(pages, nr, false);
>  }
>  
>  /*

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
