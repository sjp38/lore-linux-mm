Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 446426B0387
	for <linux-mm@kvack.org>; Tue, 28 Feb 2017 00:02:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id u62so2660060pfk.1
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 21:02:20 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id u28si661109pgo.265.2017.02.27.21.02.18
        for <linux-mm@kvack.org>;
        Mon, 27 Feb 2017 21:02:19 -0800 (PST)
Date: Tue, 28 Feb 2017 14:02:16 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH V5 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170228050216.GB2702@bbox>
References: <cover.1487965799.git.shli@fb.com>
 <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
 <20170227063315.GC23612@bbox>
 <20170227161907.GC62304@shli-mbp.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170227161907.GC62304@shli-mbp.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@fb.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Mon, Feb 27, 2017 at 08:19:08AM -0800, Shaohua Li wrote:
> On Mon, Feb 27, 2017 at 03:33:15PM +0900, Minchan Kim wrote:
> > Hi Shaohua,
> > 
> > On Fri, Feb 24, 2017 at 01:31:47PM -0800, Shaohua Li wrote:
> > > When memory pressure is high, we free MADV_FREE pages. If the pages are
> > > not dirty in pte, the pages could be freed immediately. Otherwise we
> > > can't reclaim them. We put the pages back to anonumous LRU list (by
> > > setting SwapBacked flag) and the pages will be reclaimed in normal
> > > swapout way.
> > > 
> > > We use normal page reclaim policy. Since MADV_FREE pages are put into
> > > inactive file list, such pages and inactive file pages are reclaimed
> > > according to their age. This is expected, because we don't want to
> > > reclaim too many MADV_FREE pages before used once pages.
> > > 
> > > Based on Minchan's original patch
> > > 
> > > Cc: Michal Hocko <mhocko@suse.com>
> > > Cc: Minchan Kim <minchan@kernel.org>
> > > Cc: Hugh Dickins <hughd@google.com>
> > > Cc: Johannes Weiner <hannes@cmpxchg.org>
> > > Cc: Rik van Riel <riel@redhat.com>
> > > Cc: Mel Gorman <mgorman@techsingularity.net>
> > > Cc: Andrew Morton <akpm@linux-foundation.org>
> > > Signed-off-by: Shaohua Li <shli@fb.com>
> > > ---
> > >  include/linux/rmap.h |  2 +-
> > >  mm/huge_memory.c     |  2 ++
> > >  mm/madvise.c         |  1 +
> > >  mm/rmap.c            | 40 +++++++++++++++++-----------------------
> > >  mm/vmscan.c          | 34 ++++++++++++++++++++++------------
> > >  5 files changed, 43 insertions(+), 36 deletions(-)
> > > 
> > > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > > index 7a39414..fee10d7 100644
> > > --- a/include/linux/rmap.h
> > > +++ b/include/linux/rmap.h
> > > @@ -298,6 +298,6 @@ static inline int page_mkclean(struct page *page)
> > >  #define SWAP_AGAIN	1
> > >  #define SWAP_FAIL	2
> > >  #define SWAP_MLOCK	3
> > > -#define SWAP_LZFREE	4
> > > +#define SWAP_DIRTY	4
> > 
> > I still don't convinced why we should introduce SWAP_DIRTY in try_to_unmap.
> > https://marc.info/?l=linux-mm&m=148797879123238&w=2
> > 
> > We have been SetPageMlocked in there but why cannot we SetPageSwapBacked
> > in there? It's not a thing to change LRU type but it's just indication
> > we found the page's status changed in late.
> 
> This one I don't have strong preference. Personally I agree with Johannes,
> handling failure in vmscan sounds better. But since the failure handling is
> just one statement, this probably doesn't make too much difference. If Johannes
> and you made an agreement, I'll follow.

I don't want to add unnecessary new return value(i.e., SWAP_DIRTY).
If VM found lazyfree page dirty in try_to_unmap_one, it means "non-swappable page"
so it's natural to set SetPageSwapBacked in there and return just SWAP_FAIL to
activate it in vmscan.c. SWAP_FAIL means the page is non-swappable so it should be
activated. I don't see any problem in there like software engineering pov.

However, it seems everyone are happy with introdcuing SWAP_DIRTY so I don't
insist on it which is not critical for this patchset.
I looked over try_to_unmap and callers. Now, I think we could remove SWAP_MLOCK
and maybe SWAP_AGAIN as well as SWAP_DIRTY that is to make try_to_unmap *bool*.
So, it could be done by separate patchset. I will look into that in more.

Acked-by: Minchan Kim <minchan@kernel.org>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
