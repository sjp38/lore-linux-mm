Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7EA566B005C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 05:19:43 -0400 (EDT)
Date: Thu, 17 Sep 2009 10:19:50 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 2/3] Helper which returns the huge page at a given
	address (Take 3)
Message-ID: <20090917091950.GD13002@csn.ul.ie>
References: <202cde0e0909132218k70c31a5u922636914e603ad4@mail.gmail.com> <20090915122632.GC31840@csn.ul.ie> <202cde0e0909160521v41a0d9f2wb1e4fe1e379e8971@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <202cde0e0909160521v41a0d9f2wb1e4fe1e379e8971@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Alexey Korolev <akorolex@gmail.com>
Cc: Eric Munson <linux-mm@mgebm.net>, Alexey Korolev <akorolev@infradead.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Sep 17, 2009 at 12:21:42AM +1200, Alexey Korolev wrote:
> On Wed, Sep 16, 2009 at 12:26 AM, Mel Gorman <mel@csn.ul.ie> wrote:
> > On Mon, Sep 14, 2009 at 05:18:53PM +1200, Alexey Korolev wrote:
> >> This patch provides helper function which returns the huge page at a
> >> given address for population before the page has been faulted.
> >> It is possible to call hugetlb_get_user_page function in file mmap
> >> procedure to get pages before they have been requested by user level.
> >>
> >
> > Worth spelling out that this is similar in principal to get_user_pages()
> > but not as painful to use in this specific context.
> >
> 
> Right. I'll do this. Seems it is important to clearly mention that
> this function do not introduce new functionality.
> 

Indeed.

> >> include/linux/hugetlb.h |    3 +++
> >> mm/hugetlb.c            |   23 +++++++++++++++++++++++
> >> 2 files changed, 26 insertions(+)
> >>
> >> ---
> >> Signed-off-by: Alexey Korolev <akorolev@infradead.org>
> >
> > Patch formatting nit.
> >
> > diffstat goes below the --- and signed-off-bys go above it.
> >
>
> Right. To be fixed.
> 

Thanks

> >>
> >> +/*
> >> + * hugetlb_get_user_page returns the page at a given address for population
> >> + * before the page has been faulted.
> >> + */
> >> +struct page *hugetlb_get_user_page(struct vm_area_struct *vma,
> >> +                                 unsigned long address)
> >> +{
> >
> > Your leader and comments say that the function can be used before the pages
> > have been faulted. It would presumably require that this function be called
> > from within a mmap() handler.
> >
> > What is happening because you call follow_hugetlb_page() is that the pages
> > get faulted as part of your mmap() operation. This might make the overall
> > operation more expensive than you expected. I don't know if what you really
> > intended was to allocate the huge page, insert it into the page cache and
> > have it faulted later if the process actually references the page.
> >
> > Similarly the leader and comments imply that you expect this to be
> > called as part of the mmap() operation. However, nothing would appear to
> > prevent the driver calling this function once the page is already
> > faulted. Is this intentional?
> 
> The implication was not intende. You are correct, the function can be
> called later. The leader and comment can be rewritten to make this
> clear.
> 

Because it can be called later and you do not expect that, consider making
it impossible or at least very difficult. Assuming you convert this to a
page cache lookup and insert instead of a page fault, you could BUG_ON if
the page was already in the page cache for example. This would catch already
faulted pages as a side-effect.

> >> +     int ret;
> >> +     int cnt = 1;
> >> +     struct page *pg;
> >> +     struct hstate *h = hstate_vma(vma);
> >> +
> >> +     address = address & huge_page_mask(h);
> >> +     ret = follow_hugetlb_page(vma->vm_mm, vma, &pg,
> >> +                             NULL, &address, &cnt, 0, 0);
> >> +     if (ret < 0)
> >> +             return ERR_PTR(ret);
> >> +     put_page(pg);
> >> +
> >> +     return pg;
> >> +}
> >
> > I think the caller should be responsible for calling put_page().  Otherwise
> > there is an outside chance that the page would disappear from you unexpectedly
> > depending on exactly how the driver was implemented. It would also
> > behave slightly more like get_user_pages().
> >
> Correct. Lets have behaviour similar to get_user_pages in order to prevent
> misunderstanding. Put_page will be removed.
> 
> Thank you very much for review. Now I am about to clear out the
> mistakes and will pay a lot more attention to patch descriptions and
> comments.
> 

Thanks

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
