Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id CF7366B0005
	for <linux-mm@kvack.org>; Thu, 28 Apr 2016 22:45:46 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id x7so234109456qkd.2
        for <linux-mm@kvack.org>; Thu, 28 Apr 2016 19:45:46 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a190si6400763qke.76.2016.04.28.19.45.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 28 Apr 2016 19:45:46 -0700 (PDT)
Date: Thu, 28 Apr 2016 20:45:42 -0600
From: Alex Williamson <alex.williamson@redhat.com>
Subject: Re: [BUG] vfio device assignment regression with THP ref counting
 redesign
Message-ID: <20160428204542.5f2053f7@ul30vt.home>
In-Reply-To: <20160429005106.GB2847@node.shutemov.name>
References: <20160428102051.17d1c728@t450s.home>
	<20160428181726.GA2847@node.shutemov.name>
	<20160428125808.29ad59e5@t450s.home>
	<20160428232127.GL11700@redhat.com>
	<20160429005106.GB2847@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, 29 Apr 2016 03:51:06 +0300
"Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Fri, Apr 29, 2016 at 01:21:27AM +0200, Andrea Arcangeli wrote:
> > Hello Alex and Kirill,
> > 
> > On Thu, Apr 28, 2016 at 12:58:08PM -0600, Alex Williamson wrote:  
> > > > > specific fix to this code is not applicable.  It also still occurs on
> > > > > kernels as recent as v4.6-rc5, so the issue hasn't been silently fixed
> > > > > yet.  I'm able to reproduce this fairly quickly with the above test,
> > > > > but it's not hard to imagine a test w/o any iommu dependencies which
> > > > > simply does a user directed get_user_pages_fast() on a set of userspace
> > > > > addresses, retains the reference, and at some point later rechecks that
> > > > > a new get_user_pages_fast() results in the same page address.  It  
> > 
> > Can you try to "git revert 1f25fe20a76af0d960172fb104d4b13697cafa84"
> > and then apply the below patch on top of the revert?
> > 
> > Totally untested... if I missed something and it isn't correct, I hope
> > this brings us in the right direction faster at least.
> > 
> > Overall the problem I think is that we need to restore full accuracy
> > and we can't deal with false positive COWs (which aren't entirely
> > cheap either... reading 512 cachelines should be much faster than
> > copying 2MB and using 4MB of CPU cache). 32k vs 4MB. The problem of
> > course is when we really need a COW, we'll waste an additional 32k,
> > but then it doesn't matter that much as we'd be forced to load 4MB of
> > cache anyway in such case. There's room for optimizations but even the
> > simple below patch would be ok for now.
> > 
> > From 09e3d1ff10b49fb9c3ab77f0b96a862848e30067 Mon Sep 17 00:00:00 2001
> > From: Andrea Arcangeli <aarcange@redhat.com>
> > Date: Fri, 29 Apr 2016 01:05:06 +0200
> > Subject: [PATCH 1/1] mm: thp: calculate page_mapcount() correctly for THP
> >  pages
> > 
> > This allows to revert commit 1f25fe20a76af0d960172fb104d4b13697cafa84
> > and it provides fully accuracy with wrprotect faults so page pinning
> > will stop causing false positive copy-on-writes.
> > 
> > Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
> > ---
> >  mm/util.c | 5 +++--
> >  1 file changed, 3 insertions(+), 2 deletions(-)
> > 
> > diff --git a/mm/util.c b/mm/util.c
> > index 6cc81e7..a0b9f63 100644
> > --- a/mm/util.c
> > +++ b/mm/util.c
> > @@ -383,9 +383,10 @@ struct address_space *page_mapping(struct page *page)
> >  /* Slow path of page_mapcount() for compound pages */
> >  int __page_mapcount(struct page *page)
> >  {
> > -	int ret;
> > +	int ret = 0, i;
> >  
> > -	ret = atomic_read(&page->_mapcount) + 1;
> > +	for (i = 0; i < HPAGE_PMD_NR; i++)
> > +		ret = max(ret, atomic_read(&page->_mapcount) + 1);
> >  	page = compound_head(page);
> >  	ret += atomic_read(compound_mapcount_ptr(page)) + 1;
> >  	if (PageDoubleMap(page))  
> 
> You are right about the cause. I spend some time on wrong path: I was only
> able to trigger the bug with numa balancing enabled, so I assumed
> something is wrong in that code...
> 
> I would like to preserve current page_mapcount() behaviouts.
> I think this fix is better:

This also seems to work in my testing, but assuming all else being
equal, there is a performance difference between the two for this test
case in favor of Andrea's solution.  Modifying the test to exit after
the first set of iterations, my system takes on average 107s to complete
with the solution below or 103.5s with the other approach.  Please note
that I have every mm debugging option I could find enabled and THP
scanning full speed on the system, so I don't know how this would play
out in a more tuned configuration.

The only reason I noticed is that I added a side test to sleep a random
number of seconds and kill the test program because sometimes killing
the test triggers errors.  I didn't see any errors with either of these
solutions, but suspected the first solution was completing more
iterations for similar intervals.  Modifying the test to exit seems to
prove that true.

I can't speak to which is the more architecturally correct solution,
but there may be a measurable performance difference to consider.
Thanks,

Alex

> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 86f9f8b82f8e..163c10f48e1b 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1298,15 +1298,9 @@ int do_huge_pmd_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
>         VM_BUG_ON_PAGE(!PageCompound(page) || !PageHead(page), page);
>         /*
>          * We can only reuse the page if nobody else maps the huge page or it's
> -        * part. We can do it by checking page_mapcount() on each sub-page, but
> -        * it's expensive.
> -        * The cheaper way is to check page_count() to be equal 1: every
> -        * mapcount takes page reference reference, so this way we can
> -        * guarantee, that the PMD is the only mapping.
> -        * This can give false negative if somebody pinned the page, but that's
> -        * fine.
> +        * part.
>          */
> -       if (page_mapcount(page) == 1 && page_count(page) == 1) {
> +       if (total_mapcount(page) == 1) {
>                 pmd_t entry;
>                 entry = pmd_mkyoung(orig_pmd);
>                 entry = maybe_pmd_mkwrite(pmd_mkdirty(entry), vma);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
