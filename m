Date: Mon, 19 Jun 2000 14:00:20 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] -ac21 don't set referenced bit
In-Reply-To: <Pine.LNX.4.21.0006191819560.5562-100000@inspiron.random>
Message-ID: <Pine.LNX.4.21.0006191359160.13200-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org, los@lsdb.bwl.uni-mannheim.de
List-ID: <linux-mm.kvack.org>

On Mon, 19 Jun 2000, Andrea Arcangeli wrote:
> On Mon, 19 Jun 2000, Rik van Riel wrote:
> 
> >the patch below, against -ac21, does two things:
> >
> >1) do not set the referenced bit when we add a page to
> >   one of the caches ... this allows us to distinguish
> 
> Glad to see you agreed with that. You forgot the buffer cache, hint from:

No I didn't ... ;)

> @@ -2338,7 +2362,8 @@
>         spin_unlock(&free_list[isize].lock);
>  
>         page->buffers = bh;
> -       lru_cache_add(page);
> +       page->flags &= ~(1 << PG_referenced);
> +       lru_cache_add(page, LRU_NORMAL_CACHE);
>         atomic_inc(&buffermem_pages);
>         return 1;

>From include/linux/swap.h:

#define lru_cache_add(page)                     \
do {                                            \
        spin_lock(&pagemap_lru_lock);           \
        list_add(&(page)->lru, &lru_cache);     \
        nr_lru_pages++;                         \
        page->age = PG_AGE_START;               \
        ClearPageReferenced(page);              \
        SetPageActive(page);                    \
        spin_unlock(&pagemap_lru_lock);         \
} while (0)

We've had this for a number of kernel versions now...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
