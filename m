Subject: Re: [RFC] 2/4 Migration Cache - add mm checks
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
In-Reply-To: <Pine.LNX.4.64.0602170826000.30999@schroedinger.engr.sgi.com>
References: <1140190631.5219.23.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0602170826000.30999@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Fri, 17 Feb 2006 12:09:48 -0500
Message-Id: <1140196188.5219.87.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2006-02-17 at 08:32 -0800, Christoph Lameter wrote:
> On Fri, 17 Feb 2006, Lee Schermerhorn wrote:
> 
> > Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
> > ===================================================================
> > --- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 10:50:43.000000000 -0500
> > +++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-15 10:50:53.000000000 -0500
> > @@ -457,11 +457,19 @@ static unsigned long shrink_page_list(st
> >  		 * Anonymous process memory has backing store?
> >  		 * Try to allocate it some swap space here.
> >  		 */
> > -		if (PageAnon(page) && !PageSwapCache(page)) {
> > -			if (!sc->may_swap)
> > +		if (PageAnon(page)) {
> > +			if (!PageSwapCache(page)) {
> > +				if (!sc->may_swap)
> > +					goto keep_locked;
> > +				if (!add_to_swap(page, GFP_ATOMIC))
> > +					goto activate_locked;
> > +			} else if (page_is_migration(page)) {
> > +				/*
> > +				 * For now, skip migration cache pages.
> > +				 * TODO:  move to swap cache [difficult?]
> > +				 */
> >  				goto keep_locked;
> > -			if (!add_to_swap(page, GFP_ATOMIC))
> > -				goto activate_locked;
> > +			}
> >  		}
> >  #endif /* CONFIG_SWAP */
> 
> 
> Would it not be simpler to modify add_to_swap to switch from migration
> pte to a real swap pte or simply fail? Then you wont have to touch 
> shrink_page().

I can look into that.  This is new, untested code for comment, so
thanks.

> 
> > Index: linux-2.6.16-rc3-mm1/mm/rmap.c
> > ===================================================================
> > --- linux-2.6.16-rc3-mm1.orig/mm/rmap.c	2006-02-15 10:50:43.000000000 -0500
> > +++ linux-2.6.16-rc3-mm1/mm/rmap.c	2006-02-15 10:50:53.000000000 -0500
> > @@ -232,7 +232,13 @@ void remove_from_swap(struct page *page)
> >  
> >  	spin_unlock(&anon_vma->lock);
> >  
> > -	delete_from_swap_cache(page);
> > +	if (PageSwapCache(page))
> > +		delete_from_swap_cache(page);
> > +	/*
> > +	 * if page was in migration cache, it will have been
> > +	 * removed when the last swap pte referencing the entry
> > +	 * was removed by the loop above.
> > +	 */
> >  }
> >  EXPORT_SYMBOL(remove_from_swap);
> >  #endif
> 
> Hmmm. That points to inconsistent behavior of the swap functions in case 
> these are working on the migration cache. Could you keep PageSwapCache
> until delete_from_swap_cache is called?

Well, one could redesign the migration cache such that the cache held a
ref
on the entry, like the swap cache.  Then we'd need an explicit call
later to
destroy the entry.  I guess this would happen when we free the page.
Pages
would just tend to hang around in the migration cache for no reason
after
all ptes references had been removed.  Short of that, I don't think we
can
keep the PageSwapCache() set when the page really isn't in either the
swap
nor migration cache.

A simpler, but perhaps riskier?, approach would be to have 
delete_from_swap_cache() silently ingnore pages that are no longer in
the swap cache.  Currently, the lower level __delete_from_swap_cache()
will BUG_ON this case.  Making delete_from_swap_cache() forgiving in 
this case would handle the call from remove_from_swap() above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
