Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 08B706B0259
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 21:38:50 -0500 (EST)
Received: by igcmv3 with SMTP id mv3so64179352igc.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 18:38:49 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTPS id j84si3872238iof.79.2015.11.24.18.38.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 24 Nov 2015 18:38:49 -0800 (PST)
Date: Wed, 25 Nov 2015 11:39:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 3/3] mm/cma: always check which page cause allocation
 failure
Message-ID: <20151125023913.GA9563@js1304-P5Q-DELUXE>
References: <1447381428-12445-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1447381428-12445-3-git-send-email-iamjoonsoo.kim@lge.com>
 <565481FC.4090500@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <565481FC.4090500@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Nazarewicz <mina86@mina86.com>, Minchan Kim <minchan@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Nov 24, 2015 at 04:27:56PM +0100, Vlastimil Babka wrote:
> On 11/13/2015 03:23 AM, Joonsoo Kim wrote:
> >Now, we have tracepoint in test_pages_isolated() to notify
> >pfn which cannot be isolated. But, in alloc_contig_range(),
> >some error path doesn't call test_pages_isolated() so it's still
> >hard to know exact pfn that causes allocation failure.
> >
> >This patch change this situation by calling test_pages_isolated()
> >in almost error path. In allocation failure case, some overhead
> >is added by this change, but, allocation failure is really rare
> >event so it would not matter.
> >
> >In fatal signal pending case, we don't call test_pages_isolated()
> >because this failure is intentional one.
> >
> >Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >---
> >  mm/page_alloc.c | 10 +++++++---
> >  1 file changed, 7 insertions(+), 3 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index d89960d..e78d78f 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -6756,8 +6756,12 @@ int alloc_contig_range(unsigned long start, unsigned long end,
> >  	if (ret)
> >  		return ret;
> >
> >+	/*
> >+	 * In case of -EBUSY, we'd like to know which page causes problem.
> >+	 * So, just fall through. We will check it in test_pages_isolated().
> >+	 */
> >  	ret = __alloc_contig_migrate_range(&cc, start, end);
> >-	if (ret)
> >+	if (ret && ret != -EBUSY)
> >  		goto done;
> >
> >  	/*
> >@@ -6784,8 +6788,8 @@ int alloc_contig_range(unsigned long start, unsigned long end,
> >  	outer_start = start;
> >  	while (!PageBuddy(pfn_to_page(outer_start))) {
> >  		if (++order >= MAX_ORDER) {
> >-			ret = -EBUSY;
> >-			goto done;
> >+			outer_start = start;
> >+			break;
> >  		}
> >  		outer_start &= ~0UL << order;
> >  	}
> 
> Ugh isn't this crazy loop broken? Shouldn't it test that the buddy
> it finds has order high enough? e.g.:
>   buddy = pfn_to_page(outer_start)
>   outer_start + (1UL << page_order(buddy)) > start
> 
> Otherwise you might end up with something like:
> - at "start" there's a page that CMA failed to freed
> - at "start-1" there's another non-buddy page
> - at "start-3" there's an order-1 buddy, so you set outer_start to start-3
> - test_pages_isolated() will complain (via the new tracepoint) about
> pfn of start-1, but actually you would like it to complain about pfn
> of "start"?
> 
> So the loop has been broken before your patch, but it didn't matter,
> just potentially wasted some time by picking bogus outer_start. But
> now your tracepoint will give you weird results.

Good catch. I will fix it.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
