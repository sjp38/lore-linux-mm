Date: Tue, 19 Aug 2008 12:07:00 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: pagecache insertion fewer atomics
Message-ID: <20080819100700.GE10447@wotan.suse.de>
References: <20080818122428.GA9062@wotan.suse.de> <20080819143922.60DD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080819143922.60DD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 02:41:50PM +0900, KOSAKI Motohiro wrote:
> Hi Nick,
> 
> > Setting and clearing the page locked when inserting it into swapcache /
> > pagecache when it has no other references can use non-atomic page flags
> > operations because no other CPU may be operating on it at this time.
> > 
> > This saves one atomic operation when inserting a page into pagecache.
> > 
> > Signed-off-by: Nick Piggin <npiggin@suse.de>
> > ---
> >  include/linux/pagemap.h |   37 +++++++++++++++++++++++++++++++++----
> >  mm/swap_state.c         |    4 ++--
> >  2 files changed, 35 insertions(+), 6 deletions(-)
> > 
> > Index: linux-2.6/mm/swap_state.c
> > ===================================================================
> > --- linux-2.6.orig/mm/swap_state.c
> > +++ linux-2.6/mm/swap_state.c
> > @@ -302,7 +302,7 @@ struct page *read_swap_cache_async(swp_e
> >  		 * re-using the just freed swap entry for an existing page.
> >  		 * May fail (-ENOMEM) if radix-tree node allocation failed.
> >  		 */
> > -		set_page_locked(new_page);
> > +		__set_page_locked(new_page);
> >  		err = add_to_swap_cache(new_page, entry, gfp_mask & GFP_KERNEL);
> >  		if (likely(!err)) {
> >  			/*
> 
> What version do you working on?
> 
> 2.6.27-rc1-mm1 is not contain set_page_locked().
> mmotm?

Upstream actually, because -mm was so far behind :) I forgot to check
mmotm, sorry.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
