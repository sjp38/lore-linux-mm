Date: Wed, 24 Nov 2004 14:32:16 -0200
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [PATCH]: 1/4 batch mark_page_accessed()
Message-ID: <20041124163216.GB11432@logos.cnet>
References: <16800.47044.75874.56255@gargle.gargle.HOWL>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16800.47044.75874.56255@gargle.gargle.HOWL>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Linux Kernel Mailing List <Linux-Kernel@vger.kernel.org>, Andrew Morton <AKPM@Osdl.ORG>, Linux MM Mailing List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi Nikita,

On Sun, Nov 21, 2004 at 06:44:04PM +0300, Nikita Danilov wrote:
> Batch mark_page_accessed() (a la lru_cache_add() and lru_cache_add_active()):
> page to be marked accessed is placed into per-cpu pagevec
> (page_accessed_pvec). When pagevec is filled up, all pages are processed in a
> batch.
> 
> This is supposed to decrease contention on zone->lru_lock.
> 
> (Patch is for 2.6.10-rc2)
> 
> Signed-off-by: Nikita Danilov <nikita@clusterfs.com>
> 
>  mm/swap.c |   47 ++++++++++++++++++++++++++++++++++++++++-------
>  1 files changed, 40 insertions(+), 7 deletions(-)
> 
> diff -puN mm/swap.c~batch-mark_page_accessed mm/swap.c
> --- bk-linux/mm/swap.c~batch-mark_page_accessed	2004-11-21 17:01:02.061618792 +0300
> +++ bk-linux-nikita/mm/swap.c	2004-11-21 17:01:02.063618488 +0300
> @@ -113,6 +113,39 @@ void fastcall activate_page(struct page 
>  	spin_unlock_irq(&zone->lru_lock);
>  }
>  
> +static void __pagevec_mark_accessed(struct pagevec *pvec)
> +{
> +	int i;
> +	struct zone *zone = NULL;
> +
> +	for (i = 0; i < pagevec_count(pvec); i++) {
> +		struct page *page = pvec->pages[i];
> +		struct zone *pagezone = page_zone(page);
> +
> +		if (pagezone != zone) {
> +			if (zone)
> +				local_unlock_irq(&zone->lru_lock);

You surely meant spin_{un}lock_irq and not local{un}lock_irq.

Started the STP tests on 4way/8way boxes.

> +			zone = pagezone;
> +			local_lock_irq(&zone->lru_lock);
> +		}
> +		if (!PageActive(page) && PageReferenced(page) && PageLRU(page)) {
> +			del_page_from_inactive_list(zone, page);
> +			SetPageActive(page);
> +			add_page_to_active_list(zone, page);
> +			inc_page_state(pgactivate);
> +			ClearPageReferenced(page);
> +		} else if (!PageReferenced(page)) {
> +			SetPageReferenced(page);
> +		}
> +	}
> +	if (zone)
> +		local_unlock_irq(&zone->lru_lock);
> +	release_pages(pvec->pages, pvec->nr, pvec->cold);
> +	pagevec_reinit(pvec);
> +}
> +
> +static DEFINE_PER_CPU(struct pagevec, page_accessed_pvec) = { 0, };
> +



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
