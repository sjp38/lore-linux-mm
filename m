Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 1745B6B0062
	for <linux-mm@kvack.org>; Tue,  5 Jun 2012 19:02:06 -0400 (EDT)
Date: Wed, 6 Jun 2012 01:02:03 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: Make vb_alloc() more foolproof
Message-ID: <20120605230203.GA4402@quack.suse.cz>
References: <1338936056-4092-1-git-send-email-jack@suse.cz>
 <20120605155601.738bde7c.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120605155601.738bde7c.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, linux-mm@kvack.org

On Tue 05-06-12 15:56:01, Andrew Morton wrote:
> On Wed,  6 Jun 2012 00:40:56 +0200
> Jan Kara <jack@suse.cz> wrote:
> 
> > If someone calls vb_alloc() (or vm_map_ram() for that matter) to allocate
> > 0 bytes (0 pages), get_order() returns BITS_PER_LONG - PAGE_CACHE_SHIFT
> > and interesting stuff happens. So make debugging such problems easier and
> > warn about 0-size allocation.
> > 
> > Signed-off-by: Jan Kara <jack@suse.cz>
> > ---
> >  mm/vmalloc.c |    9 +++++++++
> >  1 files changed, 9 insertions(+), 0 deletions(-)
> > 
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index 2aad499..bebee70 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -904,6 +904,15 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
> >  
> >  	BUG_ON(size & ~PAGE_MASK);
> >  	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
> > +	if (size == 0) {
> > +		/*
> > +		 * Allocating 0 bytes isn't what caller wants since
> > +		 * get_order(0) returns funny result. Just warn and terminate
> > +		 * early.
> > +		 */
> > +		WARN_ON(1);
> > +		return NULL;
> > +	}
> >  	order = get_order(size);
> 
> Spose so.  You got bitten, I assume ;)
  Yup ;)

> We can neaten the implementation:
> 
> --- a/mm/vmalloc.c~mm-make-vb_alloc-more-foolproof-fix
> +++ a/mm/vmalloc.c
> @@ -904,13 +904,12 @@ static void *vb_alloc(unsigned long size
>  
>  	BUG_ON(size & ~PAGE_MASK);
>  	BUG_ON(size > PAGE_SIZE*VMAP_MAX_ALLOC);
> -	if (size == 0) {
> +	if (WARN_ON(size == 0)) {
  Ah, nice trick :) Thanks.

>  		/*
>  		 * Allocating 0 bytes isn't what caller wants since
>  		 * get_order(0) returns funny result. Just warn and terminate
>  		 * early.
>  		 */
> -		WARN_ON(1);
>  		return NULL;
>  	}
>  	order = get_order(size);
> 
> and that gives us the unlikely() hit too.

								Honza
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
