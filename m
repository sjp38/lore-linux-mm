Date: Mon, 29 Jan 2001 19:30:01 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] guard mm->rss with page_table_lock (241p11)
In-Reply-To: <20010129222337.F603@jaquet.dk>
Message-ID: <Pine.LNX.4.21.0101291929120.1321-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rasmus Andersen <rasmus@jaquet.dk>
Cc: torvalds@transmeta.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 29 Jan 2001, Rasmus Andersen wrote:

> Please comment. Or else I will continue to sumbit it :)

The following will hang the kernel on SMP, since you're
already holding the spinlock here. Try compiling with
CONFIG_SMP and see what happens...

> diff -aur linux-2.4.1-pre11-clean/mm/vmscan.c linux/mm/vmscan.c
> --- linux-2.4.1-pre11-clean/mm/vmscan.c	Sun Jan 28 20:53:13 2001
> +++ linux/mm/vmscan.c	Mon Jan 29 22:09:18 2001
> @@ -72,7 +72,9 @@
>  		swap_duplicate(entry);
>  		set_pte(page_table, swp_entry_to_pte(entry));
>  drop_pte:
> +		spin_lock(&mm->page_table_lock);
>  		mm->rss--;
> +		spin_unlock(&mm->page_table_lock);
>  		if (!page->age)
>  			deactivate_page(page);
>  		UnlockPage(page);

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
