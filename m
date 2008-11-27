Date: Thu, 27 Nov 2008 11:01:27 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 1/2] mm: pagecache allocation gfp fixes
Message-ID: <20081127100127.GH28285@wotan.suse.de>
References: <20081127093401.GE28285@wotan.suse.de> <84144f020811270152i5d5c50a8i9dbd78aa4a7da646@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <84144f020811270152i5d5c50a8i9dbd78aa4a7da646@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Pekka,

On Thu, Nov 27, 2008 at 11:52:40AM +0200, Pekka Enberg wrote:
> Hi Nick,
> 
> On Thu, Nov 27, 2008 at 11:34 AM, Nick Piggin <npiggin@suse.de> wrote:
> > Filesystems should be careful about exactly what semantics they want and what
> > they get when fiddling with gfp_t masks to allocate pagecache. One should be
> > as liberal as possible with the type of memory that can be used, and same
> > for the the context specific flags.
> >
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> > Index: linux-2.6/mm/filemap.c
> > ===================================================================
> > --- linux-2.6.orig/mm/filemap.c
> > +++ linux-2.6/mm/filemap.c
> > @@ -741,7 +741,8 @@ repeat:
> >                page = __page_cache_alloc(gfp_mask);
> >                if (!page)
> >                        return NULL;
> > -               err = add_to_page_cache_lru(page, mapping, index, gfp_mask);
> > +               err = add_to_page_cache_lru(page, mapping, index,
> > +                       (gfp_mask & (__GFP_FS|__GFP_IO|__GFP_WAIT|__GFP_HIGH)));
> 
> Can we use GFP_RECLAIM_MASK here? I mean, surely we need to pass
> __GFP_NOFAIL, for example, down to radix_tree_preload() et al?

Ah, yes I thought a #define would be handy for this, but obviously didn't
look hard enough. GFP_RECLAIM_MASK looks good (but God help any filesystem
passing __GFP_NOFAIL into here ;)).

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
