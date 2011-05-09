Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2D8C06B0022
	for <linux-mm@kvack.org>; Mon,  9 May 2011 15:37:16 -0400 (EDT)
Date: Mon, 9 May 2011 15:36:50 -0400
From: Stephen Wilson <wilsons@start.ca>
Subject: Re: [PATCH 2/8] mm: use walk_page_range() instead of custom page
 table walking code
Message-ID: <20110509193650.GA2865@wicker.gateway.2wire.net>
References: <1303947349-3620-1-git-send-email-wilsons@start.ca>
 <1303947349-3620-3-git-send-email-wilsons@start.ca>
 <20110509164034.164C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110509164034.164C.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Stephen Wilson <wilsons@start.ca>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, May 09, 2011 at 04:38:49PM +0900, KOSAKI Motohiro wrote:
> Hello,
> 
> sorry for the long delay.

Please, no apologies.  Thank you for the review!

> > In the specific case of show_numa_map(), the custom page table walking
> > logic implemented in mempolicy.c does not provide any special service
> > beyond that provided by walk_page_range().
> > 
> > Also, converting show_numa_map() to use the generic routine decouples
> > the function from mempolicy.c, allowing it to be moved out of the mm
> > subsystem and into fs/proc.
> > 
> > Signed-off-by: Stephen Wilson <wilsons@start.ca>
> > ---
> >  mm/mempolicy.c |   53 ++++++++++++++++++++++++++++++++++++++++++++++-------
> >  1 files changed, 46 insertions(+), 7 deletions(-)
> > 
> > diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> > index 5bfb03e..dfe27e3 100644
> > --- a/mm/mempolicy.c
> > +++ b/mm/mempolicy.c
> > @@ -2568,6 +2568,22 @@ static void gather_stats(struct page *page, void *private, int pte_dirty)
> >  	md->node[page_to_nid(page)]++;
> >  }
> >  
> > +static int gather_pte_stats(pte_t *pte, unsigned long addr,
> > +		unsigned long pte_size, struct mm_walk *walk)
> > +{
> > +	struct page *page;
> > +
> > +	if (pte_none(*pte))
> > +		return 0;
> > +
> > +	page = pte_page(*pte);
> > +	if (!page)
> > +		return 0;
> 
> original check_pte_range() has following logic.
> 
>         orig_pte = pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
>         do {
>                 struct page *page;
>                 int nid;
> 
>                 if (!pte_present(*pte))
>                         continue;
>                 page = vm_normal_page(vma, addr, *pte);
>                 if (!page)
>                         continue;
>                 /*
>                  * vm_normal_page() filters out zero pages, but there might
>                  * still be PageReserved pages to skip, perhaps in a VDSO.
>                  * And we cannot move PageKsm pages sensibly or safely yet.
>                  */
>                 if (PageReserved(page) || PageKsm(page))
>                         continue;
>                 gather_stats(page, private, pte_dirty(*pte));
> 
> Why did you drop a lot of check? Is it safe?

I must have been confused.  For one, walk_page_range() does not even
lock the pmd entry when iterating over the pte's.  I completely
overlooked that fact and so with that, the series is totally broken.

I am currently testing a slightly reworked set based on the following
variation.  When finished I will send v2 of the series which will
address all issues raised so far.

Thanks again for the review!
