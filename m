Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 07C1A6B0069
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 21:57:38 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id kc8so98917057pab.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 18:57:37 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id i13si13122625pgd.184.2016.10.13.18.57.36
        for <linux-mm@kvack.org>;
        Thu, 13 Oct 2016 18:57:37 -0700 (PDT)
Date: Fri, 14 Oct 2016 10:58:01 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 5/5] mm/page_alloc: support fixed migratetype
 pageblock
Message-ID: <20161014015801.GD4993@js1304-P5Q-DELUXE>
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-6-git-send-email-iamjoonsoo.kim@lge.com>
 <f3d23e61-8418-515c-f5bf-31e742e2f64e@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f3d23e61-8418-515c-f5bf-31e742e2f64e@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Oct 13, 2016 at 01:05:11PM +0200, Vlastimil Babka wrote:
> On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >We have migratetype facility to minimise fragmentation. It dynamically
> >changes migratetype of pageblock based on some criterias but it never
> >be perfect. Some migratetype pages are often placed in the other
> >migratetype pageblock. We call this pageblock as mixed pageblock.
> >
> >There are two types of mixed pageblock. Movable page on unmovable
> >pageblock and unmovable page on movable pageblock. (I simply ignore
> >reclaimble migratetype/pageblock for easy explanation.) Earlier case is
> >not a big problem because movable page is reclaimable or migratable. We can
> >reclaim/migrate it when necessary so it usually doesn't contribute
> >fragmentation. Actual problem is caused by later case. We don't have
> >any way to reclaim/migrate this page and it prevents to make high order
> >freepage.
> >
> >This later case happens when there is too less unmovable freepage. When
> >unmovable freepage runs out, fallback allocation happens and unmovable
> >allocation would be served by movable pageblock.
> >
> >To solve/prevent this problem, we need to have enough unmovable freepage
> >to satisfy all unmovable allocation request by unmovable pageblock.
> >If we set enough unmovable pageblock at boot and fix it's migratetype
> >until power off, we would have more unmovable freepage during runtime and
> >mitigate above problem.
> >
> >This patch provides a way to set minimum number of unmovable pageblock
> >at boot time. In my test, with proper setup, I can't see any mixed
> >pageblock where unmovable allocation stay on movable pageblock.
> 
> So if I get this correctly, the fixed-as-unmovable bit doesn't
> actually prevent fallbacks to such pageblocks? Then I'm surprised
> that's enough to make any difference. Also Johannes's problem is
> that there are too many unmovable pageblocks, so I'm a bit skeptical
> that simply preallocating some will help his workload. But we'll
> see...

This patch standalone would not help the Johannes's problem, but, with
whole series, it would make some difference.

I started this series motivated from Johannes's report but it doesn't
totally focus on his problem. Our android system also has a long
standing fragmentation problem and I hope that this patchset would
help them, too.

> 
> In any case I wouldn't pursue a solution that requires user
> configuration, until as a last resort. Hopefully we can make the
> heuristics good enough so that's not necessary. Sorry for my mostly
> negative feedback to your series, I'm glad you pursuit this as well,
> and hope we'll eventually find a good solution :)

I'm fine with your feedback. It's valuable. I also doesn't pursue the
method that requires your configuration but it would be the case that
it is necessary. Amount of allocation request with specific
migratetype on our system varies a lot. Migratetype of pageblock would
be changed frequently in this situation and frequent changing
migratetype would increase mixed pageblock and cause permanent
fragmentation.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
