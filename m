Date: Mon, 23 Apr 2007 19:23:16 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [RFC 01/16] Free up page->private for compound pages
In-Reply-To: <1177380741.17122.52.camel@localhost.localdomain>
Message-ID: <Pine.LNX.4.64.0704231919270.4099@schroedinger.engr.sgi.com>
References: <20070423064845.5458.2190.sendpatchset@schroedinger.engr.sgi.com>
  <20070423064850.5458.64307.sendpatchset@schroedinger.engr.sgi.com>
 <1177380741.17122.52.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <hansendc@us.ibm.com>
Cc: linux-mm@kvack.org, William Lee Irwin III <wli@holomorphy.com>, Jens Axboe <jens.axboe@oracle.com>, David Chinner <dgc@sgi.com>, Badari Pulavarty <pbadari@gmail.com>, Adam Litke <aglitke@gmail.com>, Avi Kivity <avi@argo.co.il>, Mel Gorman <mel@skynet.ie>
List-ID: <linux-mm.kvack.org>

On Mon, 23 Apr 2007, Dave Hansen wrote:

> OK, so the end result is that we're freeing up page->private for the
> head page of compound pages, but not _all_ of them, right?  You might
> want to make that a bit clearer in the patch description.

Correct.
 
> Can we be more clever about this, and not have to eat yet another page
> flag?

Look at the recent compound changes in mm. That one does not eat a 
page flag.

> > +static inline int base_pages(struct page *page)
> > +{
> > + 	return 1 << compound_order(page);
> > +}
> 
> Perhaps base_pages_in_compound(), instead?  

I renamed it to compound_page() for V3... But base_pages_in_compound is a 
bit long.

> >  static void free_compound_page(struct page *page)
> >  {
> > -	__free_pages_ok(page, (unsigned long)page[1].lru.prev);
> > +	__free_pages_ok(page, compound_order(page));
> >  }
> 
> These substitutions are great, even outside of this patch set.  Nice.

They are already in mm.

> > +	for (i = 1; i < nr_pages; i++) {
> >  		struct page *p = page + i;
> >  
> > -		if (unlikely(!PageCompound(p) |
> > -				(page_private(p) != (unsigned long)page)))
> > +		if (unlikely(!PageCompound(p) | !PageTail(p) |
> > +				((struct page *)p->private != page)))
> 
> Should there be a compound_page_head() function to get rid of these
> open-coded references?

There is in mm. This one is a fixup patch to get the patch to work against 
upstream.

> I guess it doesn't matter, but it might be nice to turn those binary |'s
> into logical ||'s.

That would generate more branches. But them mm is different again.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
