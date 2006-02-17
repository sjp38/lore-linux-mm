Date: Fri, 17 Feb 2006 08:32:52 -0800 (PST)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [RFC] 2/4 Migration Cache - add mm checks
In-Reply-To: <1140190631.5219.23.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0602170826000.30999@schroedinger.engr.sgi.com>
References: <1140190631.5219.23.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <lee.schermerhorn@hp.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 17 Feb 2006, Lee Schermerhorn wrote:

> Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
> ===================================================================
> --- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 10:50:43.000000000 -0500
> +++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-15 10:50:53.000000000 -0500
> @@ -457,11 +457,19 @@ static unsigned long shrink_page_list(st
>  		 * Anonymous process memory has backing store?
>  		 * Try to allocate it some swap space here.
>  		 */
> -		if (PageAnon(page) && !PageSwapCache(page)) {
> -			if (!sc->may_swap)
> +		if (PageAnon(page)) {
> +			if (!PageSwapCache(page)) {
> +				if (!sc->may_swap)
> +					goto keep_locked;
> +				if (!add_to_swap(page, GFP_ATOMIC))
> +					goto activate_locked;
> +			} else if (page_is_migration(page)) {
> +				/*
> +				 * For now, skip migration cache pages.
> +				 * TODO:  move to swap cache [difficult?]
> +				 */
>  				goto keep_locked;
> -			if (!add_to_swap(page, GFP_ATOMIC))
> -				goto activate_locked;
> +			}
>  		}
>  #endif /* CONFIG_SWAP */


Would it not be simpler to modify add_to_swap to switch from migration
pte to a real swap pte or simply fail? Then you wont have to touch 
shrink_page().

> Index: linux-2.6.16-rc3-mm1/mm/rmap.c
> ===================================================================
> --- linux-2.6.16-rc3-mm1.orig/mm/rmap.c	2006-02-15 10:50:43.000000000 -0500
> +++ linux-2.6.16-rc3-mm1/mm/rmap.c	2006-02-15 10:50:53.000000000 -0500
> @@ -232,7 +232,13 @@ void remove_from_swap(struct page *page)
>  
>  	spin_unlock(&anon_vma->lock);
>  
> -	delete_from_swap_cache(page);
> +	if (PageSwapCache(page))
> +		delete_from_swap_cache(page);
> +	/*
> +	 * if page was in migration cache, it will have been
> +	 * removed when the last swap pte referencing the entry
> +	 * was removed by the loop above.
> +	 */
>  }
>  EXPORT_SYMBOL(remove_from_swap);
>  #endif

Hmmm. That points to inconsistent behavior of the swap functions in case 
these are working on the migration cache. Could you keep PageSwapCache
until delete_from_swap_cache is called?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
