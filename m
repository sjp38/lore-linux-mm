Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1711B6B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 18:00:17 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hh10so106716761pac.3
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 15:00:17 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id u9si5520860pfi.142.2016.07.20.15.00.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 15:00:16 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id iw10so21956776pac.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 15:00:15 -0700 (PDT)
Date: Wed, 20 Jul 2016 15:00:08 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 3/8] mm, page_alloc: don't retry initial attempt in
 slowpath
In-Reply-To: <7f97c5e0-731c-0431-e9f6-b53cd8f87f61@suse.cz>
Message-ID: <alpine.DEB.2.10.1607201459170.29381@chino.kir.corp.google.com>
References: <20160718112302.27381-1-vbabka@suse.cz> <20160718112302.27381-4-vbabka@suse.cz> <alpine.DEB.2.10.1607191532520.19940@chino.kir.corp.google.com> <7f97c5e0-731c-0431-e9f6-b53cd8f87f61@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>

On Wed, 20 Jul 2016, Vlastimil Babka wrote:

> >> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >> index eb1968a1041e..30443804f156 100644
> >> --- a/mm/page_alloc.c
> >> +++ b/mm/page_alloc.c
> >> @@ -3541,35 +3541,42 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >>  	 */
> >>  	alloc_flags = gfp_to_alloc_flags(gfp_mask);
> >>  
> >> +	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
> >> +		wake_all_kswapds(order, ac);
> >> +
> >> +	/*
> >> +	 * The adjusted alloc_flags might result in immediate success, so try
> >> +	 * that first
> >> +	 */
> >> +	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
> >> +	if (page)
> >> +		goto got_pg;
> > 
> > Any reason to not test gfp_pfmemalloc_allowed() here?  For contexts where 
> > it returns true, it seems like the above would be an unneeded failure if 
> > ALLOC_WMARK_MIN would have failed.  No strong opinion.
> 
> Yeah, two reasons:
> 1 - less overhead (for the test) if we went to slowpath just to wake up
> kswapd and then succeed on min watermark
> 2 - try all zones with min watermark before resorting to no watermark
> (if allowed), so we don't needlessly put below min watermark the first
> zone in zonelist, while some later zone would still be above watermark
> 

The second point makes sense, thanks!

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
