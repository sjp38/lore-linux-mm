Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 81E836B0038
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 09:23:22 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id 64so2879802wme.12
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 06:23:22 -0700 (PDT)
Received: from outbound-smtp12.blacknight.com (outbound-smtp12.blacknight.com. [46.22.139.17])
        by mx.google.com with ESMTPS id n3si187247edb.333.2017.11.02.06.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Nov 2017 06:23:21 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp12.blacknight.com (Postfix) with ESMTPS id 2526E1C1CB6
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 13:23:21 +0000 (GMT)
Date: Thu, 2 Nov 2017 13:23:20 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH] mm, page_alloc: fix potential false positive in
 __zone_watermark_ok
Message-ID: <20171102132320.c5gvc3xttguklwwi@techsingularity.net>
References: <20171102125001.23708-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20171102125001.23708-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>

On Thu, Nov 02, 2017 at 01:50:01PM +0100, Vlastimil Babka wrote:
> Since commit 97a16fc82a7c ("mm, page_alloc: only enforce watermarks for order-0
> allocations"), __zone_watermark_ok() check for high-order allocations will
> shortcut per-migratetype free list checks for ALLOC_HARDER allocations, and
> return true as long as there's free page of any migratetype. The intention is
> that ALLOC_HARDER can allocate from MIGRATE_HIGHATOMIC free lists, while normal
> allocations can't.
> 
> However, as a side effect, the watermark check will then also return true when
> there are pages only on the MIGRATE_ISOLATE list, or (prior to CMA conversion
> to ZONE_MOVABLE) on the MIGRATE_CMA list. Since the allocation cannot actually
> obtain isolated pages, and might not be able to obtain CMA pages, this can
> result in a false positive.
> 
> The condition should be rare and perhaps the outcome is not a fatal one. Still,
> it's better if the watermark check is correct. There also shouldn't be a
> performance tradeoff here.
> 
> Fixes: 97a16fc82a7c ("mm, page_alloc: only enforce watermarks for order-0 allocations")
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

That outcome shouldn't be fatal or even misleading as the subsequent
allocation attempt should fail due to not finding pages on an
appropriate list. Still, as you say, the watermark check should not be
misleading.

Acked-by: Mel Gorman <mgorman@techsingularity.net>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
