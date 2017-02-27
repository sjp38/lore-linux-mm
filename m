Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id A43786B0038
	for <linux-mm@kvack.org>; Mon, 27 Feb 2017 11:19:32 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n127so139599065qkf.3
        for <linux-mm@kvack.org>; Mon, 27 Feb 2017 08:19:32 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id i7si12121657qkf.334.2017.02.27.08.19.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Feb 2017 08:19:31 -0800 (PST)
Date: Mon, 27 Feb 2017 08:19:08 -0800
From: Shaohua Li <shli@fb.com>
Subject: Re: [PATCH V5 4/6] mm: reclaim MADV_FREE pages
Message-ID: <20170227161907.GC62304@shli-mbp.local>
References: <cover.1487965799.git.shli@fb.com>
 <14b8eb1d3f6bf6cc492833f183ac8c304e560484.1487965799.git.shli@fb.com>
 <20170227063315.GC23612@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170227063315.GC23612@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kernel-team@fb.com, mhocko@suse.com, hughd@google.com, hannes@cmpxchg.org, riel@redhat.com, mgorman@techsingularity.net, akpm@linux-foundation.org

On Mon, Feb 27, 2017 at 03:33:15PM +0900, Minchan Kim wrote:
> Hi Shaohua,
> 
> On Fri, Feb 24, 2017 at 01:31:47PM -0800, Shaohua Li wrote:
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
> >  mm/rmap.c            | 40 +++++++++++++++++-----------------------
> >  mm/vmscan.c          | 34 ++++++++++++++++++++++------------
> >  5 files changed, 43 insertions(+), 36 deletions(-)
> > 
> > diff --git a/include/linux/rmap.h b/include/linux/rmap.h
> > index 7a39414..fee10d7 100644
> > --- a/include/linux/rmap.h
> > +++ b/include/linux/rmap.h
> > @@ -298,6 +298,6 @@ static inline int page_mkclean(struct page *page)
> >  #define SWAP_AGAIN	1
> >  #define SWAP_FAIL	2
> >  #define SWAP_MLOCK	3
> > -#define SWAP_LZFREE	4
> > +#define SWAP_DIRTY	4
> 
> I still don't convinced why we should introduce SWAP_DIRTY in try_to_unmap.
> https://marc.info/?l=linux-mm&m=148797879123238&w=2
> 
> We have been SetPageMlocked in there but why cannot we SetPageSwapBacked
> in there? It's not a thing to change LRU type but it's just indication
> we found the page's status changed in late.

This one I don't have strong preference. Personally I agree with Johannes,
handling failure in vmscan sounds better. But since the failure handling is
just one statement, this probably doesn't make too much difference. If Johannes
and you made an agreement, I'll follow.

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
