Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 416416B039E
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 21:51:54 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id e5so65571306pgk.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 18:51:54 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id y6si3657410pgc.350.2017.03.15.18.51.52
        for <linux-mm@kvack.org>;
        Wed, 15 Mar 2017 18:51:53 -0700 (PDT)
Date: Thu, 16 Mar 2017 10:53:23 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v3 4/8] mm, page_alloc: count movable pages when stealing
 from pageblock
Message-ID: <20170316015323.GB14063@js1304-P5Q-DELUXE>
References: <20170307131545.28577-1-vbabka@suse.cz>
 <20170307131545.28577-5-vbabka@suse.cz>
MIME-Version: 1.0
In-Reply-To: <20170307131545.28577-5-vbabka@suse.cz>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, David Rientjes <rientjes@google.com>, kernel-team@fb.com, kernel-team@lge.com

On Tue, Mar 07, 2017 at 02:15:41PM +0100, Vlastimil Babka wrote:
> When stealing pages from pageblock of a different migratetype, we count how
> many free pages were stolen, and change the pageblock's migratetype if more
> than half of the pageblock was free. This might be too conservative, as there
> might be other pages that are not free, but were allocated with the same
> migratetype as our allocation requested.

I think that too conservative is good for movable case. In my experiments,
fragmentation spreads out when unmovable/reclaimable pageblock is
changed to movable pageblock prematurely ('prematurely' means that
allocated unmovable pages remains). As you said below, movable allocations
falling back to other pageblocks don't causes permanent fragmentation.
Therefore, we don't need to be less conservative for movable
allocation. So, how about following change to keep the criteria for
movable allocation conservative even with this counting improvement?

threshold = (1 << (pageblock_order - 1));
if (start_type == MIGRATE_MOVABLE)
        threshold += (1 << (pageblock_order - 2));

if (free_pages + alike_pages >= threshold)
        ...

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
