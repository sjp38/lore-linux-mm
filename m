Date: Mon, 12 Nov 2007 12:21:10 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 3/6] mm: speculative get page
In-Reply-To: <20071111085004.GF19816@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0711121216150.27479@schroedinger.engr.sgi.com>
References: <20071111084556.GC19816@wotan.suse.de> <20071111085004.GF19816@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Hugh Dickins <hugh@veritas.com>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Nov 2007, Nick Piggin wrote:

> +static inline int page_freeze_refs(struct page *page, int count)
> +{
> +	return likely(atomic_cmpxchg(&page->_count, count, 0) == count);
> +}
> +
> +static inline void page_unfreeze_refs(struct page *page, int count)
> +{
> +	VM_BUG_ON(page_count(page) != 0);
> +	VM_BUG_ON(count == 0);
> +
> +	atomic_set(&page->_count, count);
> +}

Good idea. That avoids another page bit.

> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c
> +++ linux-2.6/mm/migrate.c
> @@ -294,6 +294,7 @@ out:
>  static int migrate_page_move_mapping(struct address_space *mapping,
>  		struct page *newpage, struct page *page)
>  {
> +	int expected_count;
>  	void **pslot;
>  
>  	if (!mapping) {
> @@ -308,12 +309,18 @@ static int migrate_page_move_mapping(str
>  	pslot = radix_tree_lookup_slot(&mapping->page_tree,
>   					page_index(page));
>  
> -	if (page_count(page) != 2 + !!PagePrivate(page) ||
> +	expected_count = 2 + !!PagePrivate(page);
> +	if (page_count(page) != expected_count ||
>  			(struct page *)radix_tree_deref_slot(pslot) != page) {
>  		write_unlock_irq(&mapping->tree_lock);
>  		return -EAGAIN;
>  	}
>  
> +	if (!page_freeze_refs(page, expected_count))
> +		write_unlock_irq(&mapping->tree_lock);
> +		return -EAGAIN;
> +	}
> +

Looks okay but I think you could remove the earlier performance check. We 
already modified the page struct by obtaining the page lock so we hold it 
exclusively. And the failure rate here is typicalyvery low.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
