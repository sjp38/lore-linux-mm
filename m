Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1E9DC6B0005
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 06:33:38 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id r12so8821949wme.0
        for <linux-mm@kvack.org>; Tue, 26 Apr 2016 03:33:38 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id y10si17623830wmb.17.2016.04.26.03.33.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Apr 2016 03:33:37 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 6B3E59907E
	for <linux-mm@kvack.org>; Tue, 26 Apr 2016 10:33:36 +0000 (UTC)
Date: Tue, 26 Apr 2016 11:33:34 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 01/28] mm, page_alloc: Only check PageCompound for
 high-order pages
Message-ID: <20160426103334.GB2858@techsingularity.net>
References: <1460710760-32601-1-git-send-email-mgorman@techsingularity.net>
 <1460710760-32601-2-git-send-email-mgorman@techsingularity.net>
 <571DE45B.2050504@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <571DE45B.2050504@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jesper Dangaard Brouer <brouer@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Mon, Apr 25, 2016 at 11:33:15AM +0200, Vlastimil Babka wrote:
> On 04/15/2016 10:58 AM, Mel Gorman wrote:
> >order-0 pages by definition cannot be compound so avoid the check in the
> >fast path for those pages.
> >
> >Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Suggestion to improve below:
> 
> >---
> >  mm/page_alloc.c | 25 +++++++++++++++++--------
> >  1 file changed, 17 insertions(+), 8 deletions(-)
> >
> >diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> >index 59de90d5d3a3..5d205bcfe10d 100644
> >--- a/mm/page_alloc.c
> >+++ b/mm/page_alloc.c
> >@@ -1024,24 +1024,33 @@ void __meminit reserve_bootmem_region(unsigned long start, unsigned long end)
> >
> >  static bool free_pages_prepare(struct page *page, unsigned int order)
> >  {
> >-	bool compound = PageCompound(page);
> >-	int i, bad = 0;
> >+	int bad = 0;
> >
> >  	VM_BUG_ON_PAGE(PageTail(page), page);
> >-	VM_BUG_ON_PAGE(compound && compound_order(page) != order, page);
> >
> >  	trace_mm_page_free(page, order);
> >  	kmemcheck_free_shadow(page, order);
> >  	kasan_free_pages(page, order);
> >
> >+	/*
> >+	 * Check tail pages before head page information is cleared to
> >+	 * avoid checking PageCompound for order-0 pages.
> >+	 */
> >+	if (order) {
> 
> Sticking unlikely() here results in:
> 
> add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-30 (-30)
> function                                     old     new   delta
> free_pages_prepare                           771     741     -30
> 
> And from brief comparison of disassembly it really seems it's moved the
> compound handling towards the end of the function, which should be nicer for
> the instruction cache, branch prediction etc. And since this series is about
> microoptimization, I think the extra step is worth it.
> 

I dithered on this a bit and could not convince myself that the order
case really is unlikely. It depends on the situation as we could be
tearing down a large THP-backed mapping. SLUB is also using compound
pages so it's both workload and configuration dependent whether this
path is really likely or not.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
