Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id D309B6B0005
	for <linux-mm@kvack.org>; Wed, 23 Mar 2016 20:06:58 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id u190so42703589pfb.3
        for <linux-mm@kvack.org>; Wed, 23 Mar 2016 17:06:58 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id f86si7650454pfd.122.2016.03.23.17.06.54
        for <linux-mm@kvack.org>;
        Wed, 23 Mar 2016 17:06:55 -0700 (PDT)
Date: Thu, 24 Mar 2016 09:08:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 4/6] mm/vmstat: add zone range overlapping check
Message-ID: <20160324000831.GA7194@js1304-P5Q-DELUXE>
References: <1457940697-2278-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1457940697-2278-5-git-send-email-iamjoonsoo.kim@lge.com>
 <56F2AC92.9070600@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56F2AC92.9070600@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>

On Wed, Mar 23, 2016 at 03:47:46PM +0100, Vlastimil Babka wrote:
> On 03/14/2016 08:31 AM, js1304@gmail.com wrote:
> >From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >
> >There is a system that node's pfn are overlapped like as following.
> >
> >-----pfn-------->
> >N0 N1 N2 N0 N1 N2
> >
> >Therefore, we need to care this overlapping when iterating pfn range.
> >
> >There are two places in vmstat.c that iterates pfn range and
> >they don't consider this overlapping. Add it.
> >
> >Without this patch, above system could over count pageblock number
> >on a zone.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/vmstat.c | 7 +++++++
> >  1 file changed, 7 insertions(+)
> >
> >diff --git a/mm/vmstat.c b/mm/vmstat.c
> >index 5e43004..0a726e3 100644
> >--- a/mm/vmstat.c
> >+++ b/mm/vmstat.c
> >@@ -1010,6 +1010,9 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
> >  		if (!memmap_valid_within(pfn, page, zone))
> >  			continue;
> 
> The above already does this for each page within the block, but it's
> guarded by CONFIG_ARCH_HAS_HOLES_MEMORYMODEL. I guess that's not the
> case of your system, right?
> 
> I guess your added check should go above this, though. Also what
> about employing pageblock_pfn_to_page() here and in all other
> applicable places, so it's unified and optimized by
> zone->contiguous?

Comment on memmap_valid_within() in mmzone.h says that page_zone()
linkages could be broken in that system even if pfn_valid() returns
true. So, we cannot do zone check before it.

In fact, I wonder how that system works fine under the situation where
there are many pfn interators which doesn't check
memmap_valid_within(). I guess there may be enough constraint.
Anyway, I think that it is another issue and would be revisited later.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
