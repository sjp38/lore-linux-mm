Received: by fenrus.demon.nl
	via sendmail from stdin
	id <m12p9Ls-000OWuC@amadeus.home.nl> (Debian Smail3.2.0.102)
	for linux-mm@kvack.org; Tue, 9 May 2000 14:43:04 +0200 (CEST)
Message-Id: <m12p9Ls-000OWuC@amadeus.home.nl>
Date: Tue, 9 May 2000 14:43:04 +0200 (CEST)
From: arjan@fenrus.demon.nl (Arjan van de Ven)
Subject: Re: [patch] active/inactive lists
In-Reply-To: <Pine.LNX.4.21.0005090714500.25637-100000@duckman.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

in filemap.c, you first do

> +int free_inactive_pages(int priority, int gfp_mask, zone_t *zone)
> +{

[snip]


> +	while ((page_lru = page_lru->prev) != &pgdat->inactive_list &&
> +			count) {
> +next_page:
> +		/* Catch it if we loop back to next_page. */
> +		if (page_lru == &pgdat->inactive_list)
> +			break;

[snip]

> +		/* We'll list_del the page, so get the next pointer now. */
> +		page_lru = page_lru->prev;

[snip]
> +		spin_unlock(&pgdat->page_list_lock);

>  unlock_continue:
[snip]
> +		/* Damn, failed ... re-take lock and put page back the list. */
> +		spin_lock(&pgdat->page_list_lock);
> +		list_add(&(page)->lru, &pgdat->inactive_list);
> +		pgdat->inactive_pages++;
> +		zone->inactive_pages++;
> +		PageSetInactive(page);
>  		UnlockPage(page);
>  		put_page(page);
> +		goto next_page;
>  	}

Where the last goto enters the loop again. But what stops others (including
other CPUs in the same funcion) from puting the new page_lru on another
queue or mess with it in an other way? The "goto next_page" probably should
be changed into something that starts at a point that is guaranteed to be in
the correct queue.

Greetings,
   Arjan van de Ven
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
