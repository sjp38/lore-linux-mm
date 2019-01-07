Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 22F8A8E0038
	for <linux-mm@kvack.org>; Mon,  7 Jan 2019 17:39:39 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id d71so921339pgc.1
        for <linux-mm@kvack.org>; Mon, 07 Jan 2019 14:39:39 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id j29si10379212pgm.554.2019.01.07.14.39.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 07 Jan 2019 14:39:37 -0800 (PST)
Date: Mon, 7 Jan 2019 14:39:35 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] mm: Remove redundant test from find_get_pages_contig
Message-ID: <20190107223935.GC6310@bombadil.infradead.org>
References: <20190107200224.13260-1-willy@infradead.org>
 <20190107143319.c74593a70c86441b80e7cccc@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190107143319.c74593a70c86441b80e7cccc@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 07, 2019 at 02:33:19PM -0800, Andrew Morton wrote:
> On Mon,  7 Jan 2019 12:02:24 -0800 Matthew Wilcox <willy@infradead.org> wrote:
> 
> > After we establish a reference on the page, we check the pointer continues
> > to be in the correct position in i_pages.  There's no need to check the
> > page->mapping or page->index afterwards; if those can change after we've
> > got the reference, they can change after we return the page to the caller.
> 
> But that isn't what the comment says.

Right.  That patch from Nick moved the check from before taking the
ref to after taking the ref.  It was racy to have it before.  But it's
unnecessary to have it afterwards -- pages can't move once there's a
ref on them.  Or if they can move, they can move after the ref is taken.

> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -1837,16 +1837,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
> >  		if (unlikely(page != xas_reload(&xas)))
> >  			goto put_page;
> >  
> > -		/*
> > -		 * must check mapping and index after taking the ref.
> > -		 * otherwise we can get both false positives and false
> > -		 * negatives, which is just confusing to the caller.
> > -		 */
> > -		if (!page->mapping || page_to_pgoff(page) != xas.xa_index) {
> > -			put_page(page);
> > -			break;
> > -		}
> 
> The assertion here is that the page's state can alter before we take
> the ref but not afterwards.  Which is contrary to your assertion that
> "they can change after we return the page to the caller".
> 
> This:
> 
> commit 9cbb4cb21b19fff46cf1174d0ed699ef710e641c
> Author:     Nick Piggin <npiggin@kernel.dk>
> AuthorDate: Thu Jan 13 15:45:51 2011 -0800
> Commit:     Linus Torvalds <torvalds@linux-foundation.org>
> CommitDate: Thu Jan 13 17:32:32 2011 -0800
> 
>     mm: find_get_pages_contig fixlet
>     
>     Testing ->mapping and ->index without a ref is not stable as the page
>     may have been reused at this point.
>     
>     Signed-off-by: Nick Piggin <npiggin@kernel.dk>
>     Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>
>     Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
>     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ca389394fa2a..1a3dd5914726 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -837,9 +837,6 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
>  		if (radix_tree_deref_retry(page))
>  			goto restart;
>  
> -		if (page->mapping == NULL || page->index != index)
> -			break;
> -
>  		if (!page_cache_get_speculative(page))
>  			goto repeat;
>  
> @@ -849,6 +846,16 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
>  			goto repeat;
>  		}
>  
> +		/*
> +		 * must check mapping and index after taking the ref.
> +		 * otherwise we can get both false positives and false
> +		 * negatives, which is just confusing to the caller.
> +		 */
> +		if (page->mapping == NULL || page->index != index) {
> +			page_cache_release(page);
> +			break;
> +		}
> +
>  		pages[ret] = page;
>  		ret++;
>  		index++;
> 
> 
