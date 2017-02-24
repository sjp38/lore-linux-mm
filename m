Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 979FA6B0387
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 01:14:38 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id n76so20098869ybg.0
        for <linux-mm@kvack.org>; Thu, 23 Feb 2017 22:14:38 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id e4si1844519ywh.194.2017.02.23.22.14.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Feb 2017 22:14:37 -0800 (PST)
Date: Thu, 23 Feb 2017 22:14:13 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V4 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170224061412.GA86912@brenorobert-mbp.dhcp.thefacebook.com>
References: <cover.1487788131.git.shli@fb.com>
 <94eccf0fcf927f31377a60d7a9f900b7e743fb06.1487788131.git.shli@fb.com>
 <20170224021218.GD9818@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170224021218.GD9818@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Fri, Feb 24, 2017 at 11:12:18AM +0900, Minchan Kim wrote:
> On Wed, Feb 22, 2017 at 10:50:42AM -0800, Shaohua Li wrote:
> > When memory pressure is high, we free MADV_FREE pages. If the pages are
> > not dirty in pte, the pages could be freed immediately. Otherwise we
> > can't reclaim them. We put the pages back to anonumous LRU list (by
> > setting SwapBacked flag) and the pages will be reclaimed in normal
> > swapout way.
> > 
> > We use normal page reclaim policy. Since MADV_FREE pages are put into
> > inactive file list, such pages and inactive file pages are reclaimed
> > according to their age. This is expected, because we don't want to
> > reclaim too many MADV_FREE pages before used once pages.
> > 
> > Based on Minchan's original patch
> > 
> > Cc: Michal Hocko <mhocko@suse.com>
> > Cc: Minchan Kim <minchan@kernel.org>
> > Cc: Hugh Dickins <hughd@google.com>
> > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > Cc: Rik van Riel <riel@redhat.com>
> > Cc: Mel Gorman <mgorman@techsingularity.net>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Signed-off-by: Shaohua Li <shli@fb.com>
> > ---
> >  include/linux/rmap.h |  2 +-
> >  mm/huge_memory.c     |  2 ++
> >  mm/madvise.c         |  1 +
> >  mm/rmap.c            | 10 ++++++++--
> >  mm/vmscan.c          | 34 ++++++++++++++++++++++------------
> >  5 files changed, 34 insertions(+), 15 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index e2cd8f9..2bfd8c6 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -300,6 +300,6 @@ static inline int page_mkclean(struct page *page)
> >  #define SWAP_AGAIN	1
> >  #define SWAP_FAIL	2
> >  #define SWAP_MLOCK	3
> > -#define SWAP_LZFREE	4
> > +#define SWAP_DIRTY	4
> 
> Could you write down about SWAP_DIRTY in try_to_unmap's description?
> 
> < snip >
> 
> > diff --git a/mm/rmap.c b/mm/rmap.c
> > index c621088..083f32e 100644
> > --- a/mm/rmap.c
> > +++ b/mm/rmap.c
> > @@ -1424,6 +1424,12 @@ static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> >  				dec_mm_counter(mm, MM_ANONPAGES);
> >  				rp->lazyfreed++;
> >  				goto discard;
> > +			} else if (!PageSwapBacked(page)) {
> > +				/* dirty MADV_FREE page */
> > +				set_pte_at(mm, address, pvmw.pte, pteval);
> > +				ret = SWAP_DIRTY;
> > +				page_vma_mapped_walk_done(&pvmw);
> > +				break;
> >  			}
> >  
> >  			if (swap_duplicate(entry) < 0) {
> > @@ -1525,8 +1531,8 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
> >  
> >  	if (ret != SWAP_MLOCK && !page_mapcount(page)) {
> >  		ret = SWAP_SUCCESS;
> > -		if (rp.lazyfreed && !PageDirty(page))
> > -			ret = SWAP_LZFREE;
> > +		if (rp.lazyfreed && PageDirty(page))
> > +			ret = SWAP_DIRTY;
> 
> Hmm, I don't understand why we need to introduce new return value.
> Can't we set SetPageSwapBacked and return SWAP_FAIL in try_to_unmap_one?

Original idea in my mind is to activate page in SWAP_DIRTY but not activate
page in SWAP_FAIL for other failures. But later we choose to ignore all corner
cases and always activate pages for all failures. So you are right, we don't
need the new return value right now.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
