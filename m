Date: Tue, 1 Aug 2006 23:32:03 +0400
From: Oleg Nesterov <oleg@tv-sign.ru>
Subject: Re: [patch 1/2] mm: speculative get_page
Message-ID: <20060801193203.GA191@oleg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Andy Whitcroft <apw@shadowen.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Nick Piggin wrote:
>
> --- linux-2.6.orig/mm/vmscan.c
> +++ linux-2.6/mm/vmscan.c
> @@ -380,6 +380,8 @@ int remove_mapping(struct address_space 
>  	if (!mapping)
>  		return 0;		/* truncate got there first */
>
> +	SetPageNoNewRefs(page);
> +	smp_wmb();
>  	write_lock_irq(&mapping->tree_lock);
>

Is it enough?

PG_nonewrefs could be already set by another add_to_page_cache()/remove_mapping(),
and it will be cleared when we take ->tree_lock. For example:

CPU_0					CPU_1					CPU_3

add_to_page_cache:

    SetPageNoNewRefs();
    write_lock_irq(->tree_lock);
    ...
    write_unlock_irq(->tree_lock);

					remove_mapping:
	
					    SetPageNoNewRefs();

    ClearPageNoNewRefs();
					    write_lock_irq(->tree_lock);

					    check page_count()

										page_cache_get_speculative:

										    increment page_count()

										    no PG_nonewrefs => return

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
