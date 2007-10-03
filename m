Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l93IxPUn018769
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 14:59:25 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l93IxPQD563974
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 14:59:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l93IxJAr017018
	for <linux-mm@kvack.org>; Wed, 3 Oct 2007 14:59:19 -0400
Subject: Re: [PATCH] hugetlb: Fix pool resizing corner case
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1191436392.19775.43.camel@localhost.localdomain>
References: <20071003154748.19516.90317.stgit@kernel>
	 <1191433248.4939.79.camel@localhost>
	 <1191436392.19775.43.camel@localhost.localdomain>
Content-Type: text/plain
Date: Wed, 03 Oct 2007 11:59:08 -0700
Message-Id: <1191437948.4939.105.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 2007-10-03 at 13:33 -0500, Adam Litke wrote:
> On Wed, 2007-10-03 at 10:40 -0700, Dave Hansen wrote:
> > > diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> > > index 84c795e..7af3908 100644
> > > --- a/mm/hugetlb.c
> > > +++ b/mm/hugetlb.c
> > > @@ -224,14 +224,14 @@ static void try_to_free_low(unsigned long count)
> > >  	for (i = 0; i < MAX_NUMNODES; ++i) {
> > >  		struct page *page, *next;
> > >  		list_for_each_entry_safe(page, next, &hugepage_freelists[i], lru) {
> > > +			if (count >= nr_huge_pages)
> > > +				return;
> > >  			if (PageHighMem(page))
> > >  				continue;
> > >  			list_del(&page->lru);
> > >  			update_and_free_page(page);
> > >  			free_huge_pages--;
> > >  			free_huge_pages_node[page_to_nid(page)]--;
> > > -			if (count >= nr_huge_pages)
> > > -				return;
> > >  		}
> > >  	}
> > >  }
> > 
> > That's an excellent problem description.  I'm just a bit hazy on how the
> > patch fixes it. :)
> > 
> > What is the actual error in this loop?  The fact that we can go trying
> > to free pages when the count is actually OK?
> 
> The above hunk serves only to change the behavior of try_to_free_low()
> so that rather than always freeing _at_least_ one huge page, it can
> return without having freed any pages. 

OK, that makes sense.  Can you include that in the patch description?

> > BTW, try_to_free_low(count) kinda sucks for a function name.  Is that
> > count the number of pages we're trying to end up with, or the total
> > number of low pages that we're trying to free?
> 
> I agree the name sucks, but this is a bugfix patch.

Oh, yeah, none of what I was suggesting belongs in this patch.  But,
they'd make good followups.  I was just trying to get you to look at
what caused that bug to be introduced in the first place.  

> > We could rewrite the original max() line this way:
> > 
> > 	if (resv_huge_pages > nr_of_pages_to_end_up_with)
> > 		nr_of_pages_to_end_up_with = resv_huge_pages;
> > 	try_to_make_the_total_nr_of_hpages(nr_of_pages_to_end_up_with);
> > 
> > Which makes it more clear that you're setting the number of total pages
> > to the number of reserved pages, which is obviously screwy.
> > 
> > OK, so this is actually saying: "count can never go below
> > resv_huge_pages+nr_huge_pages"?
> 
> Not quite.  Count can never go below the number of reserved pages plus
> pages allocated to MAP_PRIVATE mappings.  That number is computed by:
> (resv + (total - free)).

So, (total - free) equals the number of MAP_PRIVATE pages?  Does that
imply that all reserved pages are shared and that all shared pages are
reserved?

This would be clearer even with

static inline int nr_map_private_hpages(void)
{
	return total - free;
}

Especially, if we could get the "shared" name somewhere into the
reserved variable.  

It makes a whole ton of sense to see:

	int total_in_use = nr_shared() + nr_private();
	if (nr_requested_pages < total_in_use)
		uh_oh_cant_do_that();

That'd be a wonderful cleanup.

> > Could we change try_to_free_low() to free a distinct number of pages?
> > 
> > 	if (count > free_huge_pages)
> > 		count = free_huge_pages;
> > 	try_to_free_nr_huge_pages(count);
> > 
> > I feel a bit sketchy about the "resv_huge_pages + nr_huge_pages -
> > free_huge_pages" logic.  Could you elaborate a bit there on what the
> > rules are?
> 
> The key is that we don't want to shrink the pool below the number of
> pages we are committed to keeping around.  Before this patch, we only
> accounted for the pages we plan to hand out (reserved huge pages) but
> not the ones we've already handed out (total - free).  Does that make
> sense?

Yes.  I'm just starting to get the idea that pages are committed in
different ways.  So, it makes good sense to have a nice function like
total_committed_hpages(), which explains all of this, and is called to
compare agaist the evil "count" variable. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
