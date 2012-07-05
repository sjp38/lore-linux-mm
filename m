Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 977766B0074
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 06:45:34 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so15280601pbb.14
        for <linux-mm@kvack.org>; Thu, 05 Jul 2012 03:45:33 -0700 (PDT)
Date: Thu, 5 Jul 2012 16:15:20 +0530
From: Rabin Vincent <rabin@rab.in>
Subject: Re: Bad use of highmem with buffer_migrate_page?
Message-ID: <20120705104520.GA6773@latitude>
References: <4FAC200D.2080306@codeaurora.org>
 <02fc01cd2f50$5d77e4c0$1867ae40$%szyprowski@samsung.com>
 <4FAD89DC.2090307@codeaurora.org>
 <CAH+eYFBhO9P7V7Nf+yi+vFPveBks7SFKRHfkz3JOQMBKqnkkUQ@mail.gmail.com>
 <015f01cd5a95$c1525dc0$43f71940$%szyprowski@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <015f01cd5a95$c1525dc0$43f71940$%szyprowski@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marek Szyprowski <m.szyprowski@samsung.com>
Cc: 'Michal Nazarewicz' <mina86@mina86.com>, 'Laura Abbott' <lauraa@codeaurora.org>, linaro-mm-sig@lists.linaro.org, linux-arm-msm@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 'LKML' <linux-kernel@vger.kernel.org>

On Thu, Jul 05, 2012 at 12:05:45PM +0200, Marek Szyprowski wrote:
> On Thursday, July 05, 2012 11:28 AM Rabin Vincent wrote:
> > The problem is still present on latest mainline.  The filesystem layer
> > expects that the pages in the block device's mapping are not in highmem
> > (the mapping's gfp mask is set in bdget()), but CMA replaces lowmem
> > pages with highmem pages leading to the crashes.
> > 
> > The above fix should work, but perhaps the following is preferable since
> > it should allow moving highmem pages to other highmem pages?
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 4403009..4a4f921 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -5635,7 +5635,12 @@ static struct page *
> >  __alloc_contig_migrate_alloc(struct page *page, unsigned long private,
> >  			     int **resultp)
> >  {
> > -	return alloc_page(GFP_HIGHUSER_MOVABLE);
> > +	gfp_t gfp_mask = GFP_USER | __GFP_MOVABLE;
> > +
> > +	if (PageHighMem(page))
> > +		gfp_mask |= __GFP_HIGHMEM;
> > +
> > +	return alloc_page(gfp_mask);
> >  }
> > 
> >  /* [start, end) must belong to a single zone. */
> 
> 
> The patch looks fine and does it job well. Could you resend it as a complete 
> patch with commit message and signed-off-by/reported-by lines? I will handle
> merging it to mainline then.

Thanks, here it is:

8<----
