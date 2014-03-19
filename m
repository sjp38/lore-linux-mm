Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 40C066B0132
	for <linux-mm@kvack.org>; Tue, 18 Mar 2014 21:22:49 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id lj1so8056809pab.8
        for <linux-mm@kvack.org>; Tue, 18 Mar 2014 18:22:48 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id qe9si11867399pbb.192.2014.03.18.18.22.46
        for <linux-mm@kvack.org>;
        Tue, 18 Mar 2014 18:22:48 -0700 (PDT)
Date: Wed, 19 Mar 2014 10:22:48 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 3/6] mm: support madvise(MADV_FREE)
Message-ID: <20140319012248.GD13475@bbox>
References: <1394779070-8545-1-git-send-email-minchan@kernel.org>
 <1394779070-8545-4-git-send-email-minchan@kernel.org>
 <20140318182621.GH14688@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140318182621.GH14688@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, John Stultz <john.stultz@linaro.org>, Jason Evans <je@fb.com>

Hello Hannes,

On Tue, Mar 18, 2014 at 02:26:21PM -0400, Johannes Weiner wrote:
> On Fri, Mar 14, 2014 at 03:37:47PM +0900, Minchan Kim wrote:
> > Linux doesn't have an ability to free pages lazy while other OS
> > already have been supported that named by madvise(MADV_FREE).
> > 
> > The gain is clear that kernel can evict freed pages rather than
> > swapping out or OOM if memory pressure happens.
> > 
> > Without memory pressure, freed pages would be reused by userspace
> > without another additional overhead(ex, page fault + + page allocation
> > + page zeroing).
> > 
> > Firstly, heavy users would be general allocators(ex, jemalloc,
> > I hope ptmalloc support it) and jemalloc already have supported
> > the feature for other OS(ex, FreeBSD)
> > 
> > At the moment, this patch would break build other ARCHs which have
> > own TLB flush scheme other than that x86 but if there is no objection
> > in this direction, I will add patches for handling other ARCHs
> > in next iteration.
> > 
> > Signed-off-by: Minchan Kim <minchan@kernel.org>
> 
> > @@ -284,8 +286,17 @@ static long madvise_dontneed(struct vm_area_struct *vma,
> >  			.last_index = ULONG_MAX,
> >  		};
> >  		zap_page_range(vma, start, end - start, &details);
> > +	} else if (behavior == MADV_FREE) {
> > +		struct zap_details details = {
> > +			.lazy_free = 1,
> > +		};
> > +
> > +		if (vma->vm_file)
> > +			return -EINVAL;
> > +		zap_page_range(vma, start, end - start, &details);
> 
> Wouldn't a custom page table walker to clear dirty bits and move pages
> be better?  It's awkward to hook this into the freeing code and then
> special case the pages and not actually free them.

NP.

> 
> > @@ -817,6 +817,25 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> >  
> >  		sc->nr_scanned++;
> >  
> > +		if (PageLazyFree(page)) {
> > +			switch (try_to_unmap(page, ttu_flags)) {
> 
> I don't get why we need a page flag for this.  page_check_references()
> could use the rmap walk to also check if any pte/pmd is dirty.  If so,
> you have to swap the page.  If all are clean, it can be discarded.

Ugh, you're right. I guess it could work.
I will look into that in next iteration.

Thanks!

> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
