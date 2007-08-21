Date: Tue, 21 Aug 2007 13:53:53 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 3/7] shrink_page_list: Support isolating dirty pages on
 laundry list
In-Reply-To: <20070821150440.GK11329@skynet.ie>
Message-ID: <Pine.LNX.4.64.0708211351210.3082@schroedinger.engr.sgi.com>
References: <20070820215040.937296148@sgi.com> <20070820215316.526397437@sgi.com>
 <20070821150440.GK11329@skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@skynet.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, dkegel@google.com, Peter Zijlstra <a.p.zijlstra@chello.nl>, David Miller <davem@davemloft.net>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Tue, 21 Aug 2007, Mel Gorman wrote:

> > +	if (list_empty(page_list))
> > +		return 0;
> > +
> 
> This needs a comment to explain why shrink_page_list() would be called
> with an empty list.

Ok.

> > @@ -407,10 +413,11 @@ static unsigned long shrink_page_list(st
> >  		if (TestSetPageLocked(page))
> >  			goto keep;
> >  
> > -		VM_BUG_ON(PageActive(page));
> > -
> 
> This needs explanation in the leader. It implies that later you expect active
> and inactive pages to be passed to shrink_page. i.e. We now need to keep an
> eye out for where shrink_active_list() is sending pages to shrink_page_list()
> instead of simply rotating the active list to the inactive.

Ok.

> 
> >  		sc->nr_scanned++;
> >  
> > +		if (PageActive(page))
> > +			goto keep_locked;
> > +
> >  		if (!sc->may_swap && page_mapped(page))
> >  			goto keep_locked;
> >  
> > @@ -506,6 +513,12 @@ static unsigned long shrink_page_list(st
> >  			if (!may_write_to_queue(mapping->backing_dev_info))
> >  				goto keep_locked;
> >  
> > +			if (laundry) {
> > +				list_add(&page->lru, laundry);
> > +				unlock_page(page);
> > +				continue;
> > +			}
> 
> This needs a comment. What you are doing is explained in the leader but
> it may not help a future reader of the code.
> 
> Also, with laundry specified there is no longer a check for PagePrivate
> to see if the buffers can be freed and got rid of. According to the
> comments in the next code block;

The check for buffers comes after the writeout. Writeout occurs when 
laundry == NULL.

> 
>                  * We do this even if the page is PageDirty().
>                  * try_to_release_page() does not perform I/O, but it is
>                  * possible for a page to have PageDirty set, but it is actually
>                  * clean (all its buffers are clean)
> 
> Is this intentional?

Yes buffers will be removed after writeout. Writeout requires buffers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
