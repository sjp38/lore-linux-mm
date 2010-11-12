Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id A93DA6B00B2
	for <linux-mm@kvack.org>; Fri, 12 Nov 2010 01:14:02 -0500 (EST)
Date: Thu, 11 Nov 2010 22:05:53 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch] mm: find_get_pages_contig fixlet
Message-Id: <20101111220553.64911bfd.akpm@linux-foundation.org>
In-Reply-To: <20101111075455.GA10210@amd>
References: <20101111075455.GA10210@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <npiggin@kernel.dk>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Nov 2010 18:54:55 +1100 Nick Piggin <npiggin@kernel.dk> wrote:

> Testing ->mapping and ->index without a ref is not stable as the page
> may have been reused at this point.
> 
> Signed-off-by: Nick Piggin <npiggin@kernel.dk>
> ---
>  mm/filemap.c |   13 ++++++++++---
>  1 file changed, 10 insertions(+), 3 deletions(-)
> 
> Index: linux-2.6/mm/filemap.c
> ===================================================================
> --- linux-2.6.orig/mm/filemap.c	2010-11-11 18:51:51.000000000 +1100
> +++ linux-2.6/mm/filemap.c	2010-11-11 18:51:52.000000000 +1100
> @@ -835,9 +835,6 @@ unsigned find_get_pages_contig(struct ad
>  		if (radix_tree_deref_retry(page))
>  			goto restart;
>  
> -		if (page->mapping == NULL || page->index != index)
> -			break;
> -
>  		if (!page_cache_get_speculative(page))
>  			goto repeat;
>  
> @@ -847,6 +844,16 @@ unsigned find_get_pages_contig(struct ad
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

Dumb question: if it's been "reused" then what prevents the page from
having a non-NULL ->mapping and a matching index?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
