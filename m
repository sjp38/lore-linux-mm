Date: Mon, 1 Dec 2008 08:47:22 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/8] badpage: simplify page_alloc flag check+clear
In-Reply-To: <Pine.LNX.4.64.0812010038220.11401@blonde.site>
Message-ID: <Pine.LNX.4.64.0812010843230.15331@quilx.com>
References: <Pine.LNX.4.64.0812010032210.10131@blonde.site>
 <Pine.LNX.4.64.0812010038220.11401@blonde.site>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russ Anderson <rja@sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Dave Jones <davej@redhat.com>, Arjan van de Ven <arjan@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 1 Dec 2008, Hugh Dickins wrote:

>  /*
>   * Flags checked when a page is freed.  Pages being freed should not have
>   * these flags set.  It they are, there is a problem.
>   */
> -#define PAGE_FLAGS_CHECK_AT_FREE (PAGE_FLAGS | 1 << PG_reserved)
> +#define PAGE_FLAGS_CHECK_AT_FREE \
> +	(1 << PG_lru   | 1 << PG_private   | 1 << PG_locked | \
> +	 1 << PG_buddy | 1 << PG_writeback | 1 << PG_reserved | \
> +	 1 << PG_slab  | 1 << PG_swapcache | 1 << PG_active | \
> +	 __PG_UNEVICTABLE | __PG_MLOCKED)

Rename this to PAGE_FLAGS_CLEAR_WHEN_FREE?

> + * Pages being prepped should not have any flags set.  It they are set,
> + * there has been a kernel bug or struct page corruption.
>   */
> -#define PAGE_FLAGS_CHECK_AT_PREP (PAGE_FLAGS | \
> -		1 << PG_reserved | 1 << PG_dirty | 1 << PG_swapbacked)
> +#define PAGE_FLAGS_CHECK_AT_PREP	((1 << NR_PAGEFLAGS) - 1)

These are all the bits. Can we get rid of this definition?

>  	/*
>  	 * For now, we report if PG_reserved was found set, but do not
>  	 * clear it, and do not free the page.  But we shall soon need
>  	 * to do more, for when the ZERO_PAGE count wraps negative.
>  	 */
> -	return PageReserved(page);
> +	if (PageReserved(page))
> +		return 1;
> +	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
> +		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
> +	return 0;

The name PAGE_FLAGS_CHECK_AT_PREP is strange. We clear these flags without
message. This is equal to

page->flags &=~PAGE_FLAGS_CHECK_AT_PREP;

You can drop the if...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
