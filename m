Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id F21A36B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 16:53:39 -0400 (EDT)
Date: Mon, 22 Jun 2009 21:55:18 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
Message-ID: <20090622205518.GH3981@csn.ul.ie>
References: <1245506908.6327.36.camel@localhost> <4A3CFFEC.1000805@gmail.com> <20090622113652.21E7.A69D9226@jp.fujitsu.com> <1245656529.18751.22.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1245656529.18751.22.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 22, 2009 at 10:42:09AM +0300, Pekka Enberg wrote:
> On Mon, 2009-06-22 at 11:39 +0900, KOSAKI Motohiro wrote:
> > (cc to Mel and some reviewer)
> > 
> > > Flags are:
> > > 0000000000400000 -- __PG_MLOCKED
> > > 800000000050000c -- my page flags
> > >         3650000c -- Maxim's page flags
> > > 0000000000693ce1 -- my PAGE_FLAGS_CHECK_AT_FREE
> > 
> > I guess commit da456f14d (page allocator: do not disable interrupts in
> > free_page_mlock()) is a bit wrong.
> > 
> > current code is:
> > -------------------------------------------------------------
> > static void free_hot_cold_page(struct page *page, int cold)
> > {
> > (snip)
> >         int clearMlocked = PageMlocked(page);
> > (snip)
> >         if (free_pages_check(page))
> >                 return;
> > (snip)
> >         local_irq_save(flags);
> >         if (unlikely(clearMlocked))
> >                 free_page_mlock(page);
> > -------------------------------------------------------------
> > 
> > Oh well, we remove PG_Mlocked *after* free_pages_check().
> > Then, it makes false-positive warning.
> > 
> > Sorry, my review was also wrong. I think reverting this patch is better ;)
> 
> Well, I am not sure we need to revert the patch. I'd argue it's simply a
> bug in free_pages_check() that can be fixed with something like this.
> Mel, what do you think?
> 

I think you removed the check for the wrong flag - PG_locked vs
PG_mlocked :).

That aside, I reckon your intention was not far off the mark. I posted a
separate patch to see about warning once when PG_mlocked is set and
counting the event. When the warning appears, it's not world ending but
chances are it's something that needs to be fixed up.

> 			Pekka
> 
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index d6792f8..b002b65 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -385,7 +385,7 @@ static inline void __ClearPageTail(struct page *page)
>   * these flags set.  It they are, there is a problem.
>   */
>  #define PAGE_FLAGS_CHECK_AT_FREE \
> -	(1 << PG_lru	 | 1 << PG_locked    | \
> +	(1 << PG_lru	 | \
>  	 1 << PG_private | 1 << PG_private_2 | \
>  	 1 << PG_buddy	 | 1 << PG_writeback | 1 << PG_reserved | \
>  	 1 << PG_slab	 | 1 << PG_swapcache | 1 << PG_active | \
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index a5f3c27..ff7c713 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -497,6 +497,11 @@ static void free_page_mlock(struct page *page) { }
>  
>  static inline int free_pages_check(struct page *page)
>  {
> +	/*
> +	 * Note: the page can have PG_mlock set here because we clear it
> +	 * lazily to avoid unnecessary disabling and enabling of interrupts in
> +	 * page free fastpath.
> +	 */
>  	if (unlikely(page_mapcount(page) |
>  		(page->mapping != NULL)  |
>  		(atomic_read(&page->_count) != 0) |
> 
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
