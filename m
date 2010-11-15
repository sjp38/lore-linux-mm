Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3071A8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 23:36:30 -0500 (EST)
Date: Mon, 15 Nov 2010 15:36:24 +1100
From: Nick Piggin <npiggin@kernel.dk>
Subject: Re: [patch] mm: find_get_pages_contig fixlet
Message-ID: <20101115043624.GA3572@amd>
References: <20101111075455.GA10210@amd>
 <20101111220553.64911bfd.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101111220553.64911bfd.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@kernel.dk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 11, 2010 at 10:05:53PM -0800, Andrew Morton wrote:
> On Thu, 11 Nov 2010 18:54:55 +1100 Nick Piggin <npiggin@kernel.dk> wrote:
> 
> > Testing ->mapping and ->index without a ref is not stable as the page
> > may have been reused at this point.
> > 
> > Signed-off-by: Nick Piggin <npiggin@kernel.dk>
> > ---
> >  mm/filemap.c |   13 ++++++++++---
> >  1 file changed, 10 insertions(+), 3 deletions(-)
> > 
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c	2010-11-11 18:51:51.000000000 +1100
> > +++ linux-2.6/mm/filemap.c	2010-11-11 18:51:52.000000000 +1100
> > @@ -835,9 +835,6 @@ unsigned find_get_pages_contig(struct ad
> >  		if (radix_tree_deref_retry(page))
> >  			goto restart;
> >  
> > -		if (page->mapping == NULL || page->index != index)
> > -			break;
> > -
> >  		if (!page_cache_get_speculative(page))
> >  			goto repeat;
> >  
> > @@ -847,6 +844,16 @@ unsigned find_get_pages_contig(struct ad
> >  			goto repeat;
> >  		}
> >  
> > +		/*
> > +		 * must check mapping and index after taking the ref.
> > +		 * otherwise we can get both false positives and false
> > +		 * negatives, which is just confusing to the caller.
> > +		 */
> > +		if (page->mapping == NULL || page->index != index) {
> > +			page_cache_release(page);
> > +			break;
> > +		}
> > +
> 
> Dumb question: if it's been "reused" then what prevents the page from
> having a non-NULL ->mapping and a matching index?

Nothing, but the following check will catch that it has moved. If it has
been removed then inserted back to the _same_ place, then it doesn't
matter does it? It is, in fact, "the page we are looking for " :).

In the previous sequence of checking mapping and index _before_ taking
the ref, it is possible with a small window that they had changed to
some values we expected to see to satisfy a contiguous range, but the
lack of a ref means that they may subsequently change after that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
