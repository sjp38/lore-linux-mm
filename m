Message-ID: <392E916F.E102551D@norran.net>
Date: Fri, 26 May 2000 16:59:59 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [patch] page aging and deferred swapping for 2.4.0-test1
References: <Pine.LNX.4.21.0005251936390.7453-100000@duckman.distro.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Shouldn't lru_cache_add in swap.h initialize age?


#define	lru_cache_add(page)			\
do {						\
	spin_lock(&pagemap_lru_lock);		\
	list_add(&(page)->lru, &lru_cache);	\
        (page)->age = 5;                        \
	nr_lru_pages++;				\
	spin_unlock(&pagemap_lru_lock);		\
} while (0)


Rik van Riel wrote:

> --- linux-2.4.0-test1/mm/page_alloc.c.orig      Thu May 25 12:27:47 2000
> +++ linux-2.4.0-test1/mm/page_alloc.c   Thu May 25 18:37:44 2000
> @@ -94,6 +94,8 @@
>         if (PageDecrAfter(page))
>                 BUG();
> 
> +       page->age = 2;
> +

hmm...
If this is a page that has beed used much, isn't it penalized to
much, and don't we loose information...??? (all fread pages are the
same)

how about:
	page->age /= 2;

Ok, it could race (read/write)...


and in try_to_swap_out (mm/vmscan.c) we could change to
	/* Don't look at this pte if it's been accessed recently. */
	if (pte_young(pte)) {
		/*
		 * Transfer the "accessed" bit from the page
		 * tables to the global page map.
		 */
		set_pte(page_table, pte_mkold(pte));
                page->age += 3;
		goto out_failed;
	}

	/* Can only do this if we age all active pages. */
	// if (page->age > 1)
	//	goto out_failed;

this would free a bit (PG_referenced would not be needed).
But it can race (read, write)

The races when updating page->age should not be critical.
(statistics...)

/RogerL
 
--
Home page:
  http://www.norran.net/nra02596/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
