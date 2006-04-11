Subject: Re: [PATCH 2.6.17-rc1-mm1 1/6] Migrate-on-fault - separate unmap
	from radix tree replace
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <Pine.LNX.4.64.0604111106550.878@schroedinger.engr.sgi.com>
References: <1144441108.5198.36.camel@localhost.localdomain>
	 <1144441333.5198.39.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0604111106550.878@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Tue, 11 Apr 2006 14:47:18 -0400
Message-Id: <1144781238.5160.35.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-04-11 at 11:08 -0700, Christoph Lameter wrote:
> On Fri, 7 Apr 2006, Lee Schermerhorn wrote:
> 
> > +		struct page *page, int nr_refs)
> > +{
> > +	struct address_space *mapping = page_mapping(page);
> > +        struct page **radix_pointer;
> > +
> 
> Whitespace damage. Some other places as well.

OK.  Not sure how that [and the others] snuck in there....

> 
> >  /*
> >   * Copy the page to its new location
> > @@ -310,10 +338,11 @@ EXPORT_SYMBOL(migrate_page_copy);
> >  int migrate_page(struct page *newpage, struct page *page)
> >  {
> >  	int rc;
> > +	int nr_refs = 2;	/* cache + current */
> 
> Why the nr_refs variables if you do not modify them before passing them 
> to the migration functions?

Couple of reasons:   I prefer symbolic names to magic numbers like '2'.
This value will be passed to a function as arg "nr_refs", so that seemed
like a good name for it here.  It's also a place to hang a comment for
tracking the reference counts.  This was, for me, one of the trickiest
areas in getting migrate on fault to work--keeping track of the page ref
counts.  I wanted to be clear on what ref's we expect where, and what
we're doing to them.  Finally, I'll be adding in the fault path
reference in a subsequent patch in the series.

I thought it made the code easier to read, and I hope the compiler is
smart enough to "do the right thing".

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
