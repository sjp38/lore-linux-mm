Date: Wed, 17 Jan 2001 18:13:46 +1100 (EST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: Locking issue on try_to_swap_out()
In-Reply-To: <Pine.LNX.4.21.0101141154290.12327-100000@freak.distro.conectiva>
Message-ID: <Pine.LNX.4.31.0101171812460.30841-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Jan 2001, Marcelo Tosatti wrote:

> In theory, there is nothing which guarantees that nobody will
> mess with the page between "UnlockPage" and "deactivate_page"
> (that is pretty hard to happen, I suppose, but anyway)
>
> --- mm/vmscan.c.orig       Sun Jan 14 13:23:55 2001
> +++ mm/vmscan.c    Sun Jan 14 13:24:16 2001
> @@ -72,10 +72,10 @@
>                 swap_duplicate(entry);
>                 set_pte(page_table, swp_entry_to_pte(entry));
>  drop_pte:
> -               UnlockPage(page);
>                 mm->rss--;
>                 if (!page->age)
>                         deactivate_page(page);
> +               UnlockPage(page);
>                 page_cache_release(page);
>                 return;
>         }

Why do you suppose the page_cache_release(page) is BELOW
the deactivate_page(page) call ?

We are still holding a reference on the page when we call
deactivate_page(page), this is what keeps the page from
going away from under us.

regards,

Rik
--
Virtual memory is like a game you can't win;
However, without VM there's truly nothing to lose...

		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com.br/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
