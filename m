Message-ID: <3918B66D.C7B7C777@norran.net>
Date: Wed, 10 May 2000 03:07:57 +0200
From: Roger Larsson <roger.larsson@norran.net>
MIME-Version: 1.0
Subject: Re: [patch] active/inactive queues for pre7-4
References: <Pine.LNX.4.21.0005091226260.25637-100000@duckman.conectiva>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Arjan van de Ven <arjan@fenrus.demon.nl>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think I found one bug in __page_reactivate

see below...


> --- linux-2.3.99-pre7-4/mm/filemap.c.orig       Thu May  4 11:38:24 2000
> +++ linux-2.3.99-pre7-4/mm/filemap.c    Tue May  9 12:09:42 2000
> @@ -233,61 +233,205 @@
>         spin_unlock(&pagecache_lock);
>  }
> 
> -int shrink_mmap(int priority, int gfp_mask, zone_t *zone)
> +/* basically lru_cache_del() and lru_cache_add() merged together */
> +static void __page_reactivate(struct page *page)
> +{
> +       struct zone_struct * zone = page->zone;
> +       pg_data_t * pgdat = zone->zone_pgdat;
> +       extern wait_queue_head_t kswapd_wait;
> +
> +       list_del(&(page)->lru);
> +       pgdat->inactive_pages--;
> +       zone->inactive_pages--;
> +       PageClearInactive(page);
> +
> +       list_add(&(page)->lru, &pgdat->active_list);

> +       pgdat->active_pages++;
> +       pgdat->active_pages++;

pgdat->active_pages is incremented twice!
second one should IMHO be
 zone->active_pages

/RogerL
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
