Date: Fri, 3 Oct 2008 19:11:00 +0100
From: Andy Whitcroft <apw@shadowen.org>
Subject: Re: [PATCH 1/1] handle initialising compound pages at orders
	greater than MAX_ORDER
Message-ID: <20081003181100.GB8809@brain>
References: <1222964396-25031-1-git-send-email-apw@shadowen.org> <20081002143004.5fec3952.akpm@linux-foundation.org> <200810031643.28731.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200810031643.28731.nickpiggin@yahoo.com.au>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kniht@linux.vnet.ibm.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

On Fri, Oct 03, 2008 at 04:43:28PM +1000, Nick Piggin wrote:
> On Friday 03 October 2008 07:30, Andrew Morton wrote:
> > On Thu,  2 Oct 2008 17:19:56 +0100
> >
> > Andy Whitcroft <apw@shadowen.org> wrote:
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -268,13 +268,14 @@ void prep_compound_page(struct page *page, unsigned
> > > long order) {
> > >  	int i;
> > >  	int nr_pages = 1 << order;
> > > +	struct page *p = page + 1;
> > >
> > >  	set_compound_page_dtor(page, free_compound_page);
> > >  	set_compound_order(page, order);
> > >  	__SetPageHead(page);
> > > -	for (i = 1; i < nr_pages; i++) {
> > > -		struct page *p = page + i;
> > > -
> > > +	for (i = 1; i < nr_pages; i++, p++) {
> > > +		if (unlikely((i & (MAX_ORDER_NR_PAGES - 1)) == 0))
> > > +			p = pfn_to_page(page_to_pfn(page) + i);
> > >  		__SetPageTail(p);
> > >  		p->first_page = page;
> > >  	}
> >
> > gad.  Wouldn't it be clearer to do
> >
> > 	for (i = 1; i < nr_pages; i++) {
> > 		struct page *p = pfn_to_page(i);
> > 		__SetPageTail(p);
> > 		p->first_page = page;
> > 	}
> >
> > Oh well, I guess we can go with the obfuscated, uncommented version for
> > now :(
> >
> > This patch applies to 2.6.26 (and possibly earlier) but I don't think
> > those kernels can trigger the bug?
> 
> I think the problem is that pfn_to_page isn't always trivial. I would
> prefer to have seen a new function for hugetlb to use, and keep the
> branch-less version for the page allocator itself.

Yes that would probabally be a better way forward overall.  I see that
the current one has gone upstream which at least pluggs the hole we have
right now.  We are still testing and when that is done we will know if
there are any other issues.  As part of that I will look at pulling out
a gigantic page specific version of the destructor on top of this one.

-apw

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
