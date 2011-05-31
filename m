Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 66A8D6B0011
	for <linux-mm@kvack.org>; Tue, 31 May 2011 09:33:51 -0400 (EDT)
Received: by pvc12 with SMTP id 12so2513695pvc.14
        for <linux-mm@kvack.org>; Tue, 31 May 2011 06:33:49 -0700 (PDT)
Date: Tue, 31 May 2011 22:33:40 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] mm: compaction: Abort compaction if too many pages are
 isolated and caller is asynchronous
Message-ID: <20110531133340.GB3490@barrios-laptop>
References: <20110530131300.GQ5044@csn.ul.ie>
 <20110530143109.GH19505@random.random>
 <20110530153748.GS5044@csn.ul.ie>
 <20110530165546.GC5118@suse.de>
 <20110530175334.GI19505@random.random>
 <20110531121620.GA3490@barrios-laptop>
 <20110531122437.GJ19505@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110531122437.GJ19505@random.random>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Mel Gorman <mel@csn.ul.ie>, akpm@linux-foundation.org, Ury Stankevich <urykhy@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, stable@kernel.org

On Tue, May 31, 2011 at 02:24:37PM +0200, Andrea Arcangeli wrote:
> On Tue, May 31, 2011 at 09:16:20PM +0900, Minchan Kim wrote:
> > I am not sure this is related to the problem you have seen.
> > If he used hwpoison by madivse, it is possible.
> 
> CONFIG_ARCH_SUPPORTS_MEMORY_FAILURE=y
> # CONFIG_MEMORY_FAILURE is not set
> 
> > Anyway, we can see negative value by count mismatch in UP build.
> > Let's fix it.
> 
> Definitely let's fix it, but it's probably not related to this one.
> 
> > 
> > From 1d3ebce2e8aa79dcc912da16b7a8d0611b6f9f1a Mon Sep 17 00:00:00 2001
> > From: Minchan Kim <minchan.kim@gmail.com>
> > Date: Tue, 31 May 2011 21:11:58 +0900
> > Subject: [PATCH] Fix page isolated count mismatch
> > 
> > If migration is failed, normally we call putback_lru_pages which
> > decreases NR_ISOLATE_[ANON|FILE].
> > It means we should increase NR_ISOLATE_[ANON|FILE] before calling
> > putback_lru_pages. But soft_offline_page dosn't it.
> > 
> > It can make NR_ISOLATE_[ANON|FILE] with negative value and in UP build,
> > zone_page_state will say huge isolated pages so too_many_isolated
> > functions be deceived completely. At last, some process stuck in D state
> > as it expect while loop ending with congestion_wait.
> > But it's never ending story.
> > 
> > If it is right, it would be -stable stuff.
> > 
> > Cc: Mel Gorman <mel@csn.ul.ie>
> > Cc: Andrea Arcangeli <aarcange@redhat.com>
> > Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> > ---
> >  mm/memory-failure.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> > 
> > diff --git a/mm/memory-failure.c b/mm/memory-failure.c
> > index 5c8f7e0..eac0ba5 100644
> > --- a/mm/memory-failure.c
> > +++ b/mm/memory-failure.c
> > @@ -52,6 +52,7 @@
> >  #include <linux/swapops.h>
> >  #include <linux/hugetlb.h>
> >  #include <linux/memory_hotplug.h>
> > +#include <linux/mm_inline.h>
> >  #include "internal.h"
> >  
> >  int sysctl_memory_failure_early_kill __read_mostly = 0;
> > @@ -1468,7 +1469,8 @@ int soft_offline_page(struct page *page, int flags)
> >  	put_page(page);
> >  	if (!ret) {
> >  		LIST_HEAD(pagelist);
> > -
> > +		inc_zone_page_state(page, NR_ISOLATED_ANON +
> > +					    page_is_file_cache(page));
> >  		list_add(&page->lru, &pagelist);
> >  		ret = migrate_pages(&pagelist, new_page, MPOL_MF_MOVE_ALL,
> >  								0, true);
> 
> Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

Thanks, Andrea.

> 
> Let's check all other migrate_pages callers too...

I checked them before sending patch but I got failed to find strange things. :(
Now I am checking the page's SwapBacked flag can be changed
between before and after of migrate_pages so accounting of NR_ISOLATED_XX can
make mistake. I am approaching the failure, too. Hmm.


-- 
Kind regards
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
