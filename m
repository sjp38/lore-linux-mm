Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 439CD6B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 18:38:22 -0400 (EDT)
Date: Mon, 19 Aug 2013 15:38:20 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2 3/7] mm: munlock: batch non-THP page isolation and
 munlock+putback using pagevec
Message-Id: <20130819153820.8d11f06b688aeb4f0e402afd@linux-foundation.org>
In-Reply-To: <1376915022-12741-4-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
	<1376915022-12741-4-git-send-email-vbabka@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: =?ISO-8859-1?Q?J=F6rn?= Engel <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Mon, 19 Aug 2013 14:23:38 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:

> Currently, munlock_vma_range() calls munlock_vma_page on each page in a loop,
> which results in repeated taking and releasing of the lru_lock spinlock for
> isolating pages one by one. This patch batches the munlock operations using
> an on-stack pagevec, so that isolation is done under single lru_lock. For THP
> pages, the old behavior is preserved as they might be split while putting them
> into the pagevec. After this patch, a 9% speedup was measured for munlocking
> a 56GB large memory area with THP disabled.
> 
> A new function __munlock_pagevec() is introduced that takes a pagevec and:
> 1) It clears PageMlocked and isolates all pages under lru_lock. Zone page stats
> can be also updated using the variant which assumes disabled interrupts.
> 2) It finishes the munlock and lru putback on all pages under their lock_page.
> Note that previously, lock_page covered also the PageMlocked clearing and page
> isolation, but it is not needed for those operations.
> 
> ...
>
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
> +			if (PageLRU(page)) {
> +				lruvec = mem_cgroup_page_lruvec(page, zone);
> +				lru = page_lru(page);
> +
> +				get_page(page);
> +				ClearPageLRU(page);
> +				del_page_from_lru_list(page, lruvec, lru);
> +			} else {
> +				__munlock_isolation_failed(page);
> +				goto skip_munlock;
> +			}
> +
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
> +		if (page) {
> +			lock_page(page);
> +			__munlock_isolated_page(page);
> +			unlock_page(page);
> +			put_page(page); /* pin from follow_page_mask() */
> +		}
> +	}
> +	pagevec_reinit(pvec);

A minor thing: it would be a little neater if the pagevec_reinit() was
in the caller, munlock_vma_pages_range().  So the caller remains in
control of the state of the pagevec and the callee treats it in a
read-only fashion.

> +}
>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
