Date: Tue, 21 Feb 2006 12:40:16 -0600
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: [RFC] 0/4 Migration Cache Overview
Message-ID: <20060221184016.GA19696@dmt.cnet>
References: <1140190593.5219.22.camel@localhost.localdomain> <Pine.LNX.4.64.0602170816530.30999@schroedinger.engr.sgi.com> <1140195598.5219.77.camel@localhost.localdomain> <Pine.LNX.4.64.0602170906030.31408@schroedinger.engr.sgi.com> <43FA8690.3070608@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <43FA8690.3070608@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

On Tue, Feb 21, 2006 at 02:18:40PM +1100, Nick Piggin wrote:
> Christoph Lameter wrote:
> >On Fri, 17 Feb 2006, Lee Schermerhorn wrote:
> >
> >
> >>>Could add a justification of this feature? What is the benefit of having 
> >>>a migration cache instead of using swap pte (current migration is not 
> >>>really using swap space per se)?
> >>
> >>I think Marcello covered that in his original posts, which I linked.  
> >>I can go back and extract his arguments.  My primary interest is for
> >>"lazy page migration" where anon pages can hang around the the cache
> >>until the task faults them in [possibly migrating] or exits, if ever.
> >>I think the desire to avoid using swap for this case is even stronger.
> >
> >
> >I am bit confused. A task faults in a page from the migration cache? Isnt 
> >this swap behavior? I thought the migration cache was just to avoid using
> >swap page numbers for the intermediate pte values during migration?

Exactly, the aim of the migration cache is to avoid using swap map
entries.

> It really does seem like the swapcache does everything required. The
> swapcache is just a pagecache mapping for anonymous pages. Adding an
> extra "somethingcache" for anonymous pages shouldn't add anything. I
> guess I'm missing something as well.

The idea was to create a "partition" inside the swapcache which allows
for mapping+offset->pfn translation _without_ actually occupying space
in the swap map (an idr table is used instead).

But apparently Christoph's mechanism adds the PFN number into
the page table entry itself, thus fulfilling the requirement for
"mapping+offset"->pfn indexing required for removal of pages underneath
a living process. Is that right?

Cheers


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
