Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id C61A66B0088
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 09:58:25 -0400 (EDT)
Received: by wguu7 with SMTP id u7so18252892wgu.3
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 06:58:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t7si4823676wix.46.2015.06.19.06.58.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 06:58:24 -0700 (PDT)
Date: Fri, 19 Jun 2015 14:58:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/6] mm, compaction: always skip compound pages by order
 in migrate scanner
Message-ID: <20150619135820.GC11809@suse.de>
References: <1433928754-966-1-git-send-email-vbabka@suse.cz>
 <1433928754-966-5-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1433928754-966-5-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Nazarewicz <mina86@mina86.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Christoph Lameter <cl@linux.com>, Rik van Riel <riel@redhat.com>, David Rientjes <rientjes@google.com>

On Wed, Jun 10, 2015 at 11:32:32AM +0200, Vlastimil Babka wrote:
> The compaction migrate scanner tries to skip compound pages by their order, to
> reduce number of iterations for pages it cannot isolate. The check is only done
> if PageLRU() is true, which means it applies to THP pages, but not e.g.
> hugetlbfs pages or any other non-LRU compound pages, which we have to iterate
> by base pages.
> 
> This limitation comes from the assumption that it's only safe to read
> compound_order() when we have the zone's lru_lock and THP cannot be split under
> us. But the only danger (after filtering out order values that are not below
> MAX_ORDER, to prevent overflows) is that we skip too much or too little after
> reading a bogus compound_order() due to a rare race. This is the same reasoning
> as patch 99c0fd5e51c4 ("mm, compaction: skip buddy pages by their order in the
> migrate scanner") introduced for unsafely reading PageBuddy() order.
> 
> After this patch, all pages are tested for PageCompound() and we skip them by
> compound_order().  The test is done after the test for balloon_page_movable()
> as we don't want to assume if balloon pages (or other pages with own isolation
> and migration implementation if a generic API gets implemented) are compound
> or not.
> 
> When tested with stress-highalloc from mmtests on 4GB system with 1GB hugetlbfs
> pages, the vmstat compact_migrate_scanned count decreased by 15%.
> 
> Signed-off-by: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Mel Gorman <mgorman@suse.de>

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
