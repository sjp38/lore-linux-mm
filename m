Subject: Re: [PATCH]: VM 8/8 shrink_list(): set PG_reclaimed
From: Nick Piggin <nickpiggin@yahoo.com.au>
In-Reply-To: <17006.5376.606064.533068@gargle.gargle.HOWL>
References: <16994.40728.397980.431164@gargle.gargle.HOWL>
	 <20050425212911.31cf6b43.akpm@osdl.org>
	 <17006.5376.606064.533068@gargle.gargle.HOWL>
Content-Type: text/plain
Date: Tue, 26 Apr 2005 20:32:01 +1000
Message-Id: <1114511521.5097.18.camel@npiggin-nld.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nikita Danilov <nikita@clusterfs.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2005-04-26 at 14:16 +0400, Nikita Danilov wrote:
> Andrew Morton writes:
> 
> [...]
> 
>  > 
>  > To address the race which Nick identified I think we can do it this way?
> 
> I think that instead of fixing that race we'd better to make it valid:
> let's redefine PG_reclaim to mean
> 
>        "page has been seen on the tail of the inactive list, but VM
>        failed to reclaim it right away either because it was dirty, or
>        there was some race. Reclaim this page as soon as possible."
> 
> Nikita.
> 
> set PG_reclaimed bit on pages that are under writeback when shrink_list()
> looks at them: these pages are at end of the inactive list, and it only makes
> sense to reclaim them as soon as possible when writeout finishes.
> 
> Signed-off-by: Nikita Danilov <nikita@clusterfs.com>
> 
> 
>  mm/filemap.c    |   10 +++++----
>  mm/page_alloc.c |    3 +-
>  mm/swap.c       |   12 +----------
>  mm/vmscan.c     |   60 +++++++++++++++++++++++++++++++++++++++++---------------
>  4 files changed, 54 insertions(+), 31 deletions(-)
> 
> diff -puN mm/vmscan.c~SetPageReclaimed-inactive-tail mm/vmscan.c
> --- bk-linux/mm/vmscan.c~SetPageReclaimed-inactive-tail	2005-04-22 12:09:59.000000000 +0400
> +++ bk-linux-nikita/mm/vmscan.c	2005-04-22 12:11:31.000000000 +0400

[...]

> diff -puN mm/page_alloc.c~SetPageReclaimed-inactive-tail mm/page_alloc.c
> --- bk-linux/mm/page_alloc.c~SetPageReclaimed-inactive-tail	2005-04-22 12:09:59.000000000 +0400
> +++ bk-linux-nikita/mm/page_alloc.c	2005-04-22 12:09:59.000000000 +0400
> @@ -319,13 +319,14 @@ static inline void free_pages_check(cons
>  			1 << PG_private |
>  			1 << PG_locked	|
>  			1 << PG_active	|
> -			1 << PG_reclaim	|
>  			1 << PG_slab	|
>  			1 << PG_swapcache |
>  			1 << PG_writeback )))
>  		bad_page(function, page);
>  	if (PageDirty(page))
>  		ClearPageDirty(page);
> +	if (PageReclaim(page))
> +		ClearPageReclaim(page);
>  }
>  
>  /*

A bit ugly for maybe little improvement. I agree it makes fine
of sense in theory, but possibly not worthwhile if it doesn't
actually help (but I'm not saying it doesn't).

-- 
SUSE Labs, Novell Inc.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
