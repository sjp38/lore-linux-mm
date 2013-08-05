Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 56C116B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 14:54:18 -0400 (EDT)
Date: Mon, 5 Aug 2013 13:21:43 -0400
From: =?utf-8?B?SsO2cm4=?= Engel <joern@logfs.org>
Subject: Re: [RFC PATCH 3/6] mm: munlock: batch non-THP page isolation and
 munlock+putback using pagevec
Message-ID: <20130805172142.GB470@logfs.org>
References: <1375713125-18163-1-git-send-email-vbabka@suse.cz>
 <1375713125-18163-4-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <1375713125-18163-4-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: mgorman@suse.de, linux-mm@kvack.org

On Mon, 5 August 2013 16:32:02 +0200, Vlastimil Babka wrote:
>  
>  /*
> + * Munlock a batch of pages from the same zone
> + *
> + * The work is split to two main phases. First phase clears the Mlocked flag
> + * and attempts to isolate the pages, all under a single zone lru lock.
> + * The second phase finishes the munlock only for pages where isolation
> + * succeeded.
> + */
> +static void __munlock_pagevec(struct pagevec *pvec, struct zone *zone)
> +{
> +	int i;
> +	int nr = pagevec_count(pvec);
> +
> +	/* Phase 1: page isolation */
> +	spin_lock_irq(&zone->lru_lock);
> +	for (i = 0; i < nr; i++) {
> +		struct page *page = pvec->pages[i];
> +
> +		if (TestClearPageMlocked(page)) {
> +			struct lruvec *lruvec;
> +			int lru;
> +
> +			/* we have disabled interrupts */
> +			__mod_zone_page_state(zone, NR_MLOCK, -1);
> +
> +			switch (__isolate_lru_page(page,
> +						ISOLATE_UNEVICTABLE)) {
> +			case 0:
> +				lruvec = mem_cgroup_page_lruvec(page, zone);
> +				lru = page_lru(page);
> +				del_page_from_lru_list(page, lruvec, lru);
> +				break;
> +
> +			case -EINVAL:
> +				__munlock_isolation_failed(page);
> +				goto skip_munlock;
> +
> +			default:
> +				BUG();
> +			}

On purely aesthetic grounds I don't like the switch too much.  A bit
more serious is that you don't handle -EBUSY gracefully.  I guess you
would have to mlock() the empty zero page to excercise this code path.

> +		} else {
> +skip_munlock:
> +			/*
> +			 * We won't be munlocking this page in the next phase
> +			 * but we still need to release the follow_page_mask()
> +			 * pin.
> +			 */
> +			pvec->pages[i] = NULL;
> +			put_page(page);
> +		}
> +	}
> +	spin_unlock_irq(&zone->lru_lock);
> +
> +	/* Phase 2: page munlock and putback */
> +	for (i = 0; i < nr; i++) {
> +		struct page *page = pvec->pages[i];
> +
> +		if (unlikely(!page))
> +			continue;

Whenever I see likely() or unlikely() I wonder whether it really makes
a difference or whether it is just cargo-cult programming.  My best
guess is that about half of them are cargo-cult.

> +		lock_page(page);
> +		__munlock_isolated_page(page);
> +		unlock_page(page);
> +		put_page(page); /* pin from follow_page_mask() */
> +	}
> +	pagevec_reinit(pvec);
> +}
> +
> +/*
>   * munlock_vma_pages_range() - munlock all pages in the vma range.'
>   * @vma - vma containing range to be munlock()ed.
>   * @start - start address in @vma of the range
> @@ -230,11 +315,16 @@ static int __mlock_posix_error_return(long retval)
>  void munlock_vma_pages_range(struct vm_area_struct *vma,
>  			     unsigned long start, unsigned long end)
>  {
> +	struct pagevec pvec;
> +	struct zone *zone = NULL;
> +
> +	pagevec_init(&pvec, 0);
>  	vma->vm_flags &= ~VM_LOCKED;
>  
>  	while (start < end) {
>  		struct page *page;
>  		unsigned int page_mask, page_increm;
> +		struct zone *pagezone;
>  
>  		/*
>  		 * Although FOLL_DUMP is intended for get_dump_page(),
> @@ -246,20 +336,47 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
>  		page = follow_page_mask(vma, start, FOLL_GET | FOLL_DUMP,
>  					&page_mask);
>  		if (page && !IS_ERR(page)) {
> -			lock_page(page);
> -			/*
> -			 * Any THP page found by follow_page_mask() may have
> -			 * gotten split before reaching munlock_vma_page(),
> -			 * so we need to recompute the page_mask here.
> -			 */
> -			page_mask = munlock_vma_page(page);
> -			unlock_page(page);
> -			put_page(page);
> +			pagezone = page_zone(page);
> +			/* The whole pagevec must be in the same zone */
> +			if (pagezone != zone) {
> +				if (pagevec_count(&pvec))
> +					__munlock_pagevec(&pvec, zone);
> +				zone = pagezone;
> +			}
> +			if (PageTransHuge(page)) {
> +				/*
> +				 * THP pages are not handled by pagevec due
> +				 * to their possible split (see below).
> +				 */
> +				if (pagevec_count(&pvec))
> +					__munlock_pagevec(&pvec, zone);

Should you re-initialize the pvec after this call?

> +				lock_page(page);
> +				/*
> +				 * Any THP page found by follow_page_mask() may
> +				 * have gotten split before reaching
> +				 * munlock_vma_page(), so we need to recompute
> +				 * the page_mask here.
> +				 */
> +				page_mask = munlock_vma_page(page);
> +				unlock_page(page);
> +				put_page(page); /* follow_page_mask() */
> +			} else {
> +				/*
> +				 * Non-huge pages are handled in batches
> +				 * via pagevec. The pin from
> +				 * follow_page_mask() prevents them from
> +				 * collapsing by THP.
> +				 */
> +				if (pagevec_add(&pvec, page) == 0)
> +					__munlock_pagevec(&pvec, zone);
> +			}
>  		}
>  		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
>  		start += page_increm * PAGE_SIZE;
>  		cond_resched();
>  	}
> +	if (pagevec_count(&pvec))
> +		__munlock_pagevec(&pvec, zone);
>  }

The rest looks good to my untrained eyes.

JA?rn

--
One of my most productive days was throwing away 1000 lines of code.
-- Ken Thompson.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
