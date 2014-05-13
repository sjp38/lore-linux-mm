Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f53.google.com (mail-ee0-f53.google.com [74.125.83.53])
	by kanga.kvack.org (Postfix) with ESMTP id 1C71B6B0038
	for <linux-mm@kvack.org>; Tue, 13 May 2014 10:23:11 -0400 (EDT)
Received: by mail-ee0-f53.google.com with SMTP id c13so477695eek.40
        for <linux-mm@kvack.org>; Tue, 13 May 2014 07:23:10 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r2si13273636eem.306.2014.05.13.07.23.09
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 13 May 2014 07:23:09 -0700 (PDT)
Date: Tue, 13 May 2014 15:23:05 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/19] mm: page_alloc: Lookup pageblock migratetype with
 IRQs enabled during free
Message-ID: <20140513142305.GT23991@suse.de>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de>
 <1399974350-11089-12-git-send-email-mgorman@suse.de>
 <53721FD9.6000106@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53721FD9.6000106@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, May 13, 2014 at 03:36:25PM +0200, Vlastimil Babka wrote:
> On 05/13/2014 11:45 AM, Mel Gorman wrote:
> >get_pageblock_migratetype() is called during free with IRQs disabled. This
> >is unnecessary and disables IRQs for longer than necessary.
> >
> >Signed-off-by: Mel Gorman <mgorman@suse.de>
> >Acked-by: Rik van Riel <riel@redhat.com>
> 
> With a comment below,
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks

> >---
> >  mm/page_alloc.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 3948f0a..fcbf637 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -773,9 +773,9 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	if (!free_pages_prepare(page, order))
> >  		return;
> >
> >+	migratetype = get_pfnblock_migratetype(page, pfn);
> >  	local_irq_save(flags);
> >  	__count_vm_events(PGFREE, 1 << order);
> >-	migratetype = get_pfnblock_migratetype(page, pfn);
> >  	set_freepage_migratetype(page, migratetype);
> 
> The line above could be also outside disabled IRQ, no?
> 

I guess it could but the difference would be marginal at
best. get_pfnblock_migratetype is a lookup of the pageblock bitfield and is
an expensive operation. set_freepage_migratetype() on the other hand is just

static inline void set_freepage_migratetype(struct page *page, int migratetype)
{
        page->index = migratetype;
}

If anything the line could be just removed as right now nothing below
that level is actually using the information (it's primarily of interest
in the per-cpu allocator) but that would be outside the scope of this
patch as move_freepages would also need addressing. I feel the gain is
too marginal to justify the churn.

> >  	free_one_page(page_zone(page), page, pfn, order, migratetype);
> >  	local_irq_restore(flags);
> >
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
