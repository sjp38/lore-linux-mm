Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 0FE3A6B0033
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 06:15:50 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 136so1936338wmu.10
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 03:15:50 -0700 (PDT)
Received: from outbound-smtp13.blacknight.com (outbound-smtp13.blacknight.com. [46.22.139.230])
        by mx.google.com with ESMTPS id p56si3701571eda.49.2017.10.18.03.15.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Oct 2017 03:15:48 -0700 (PDT)
Received: from mail.blacknight.com (unknown [81.17.254.26])
	by outbound-smtp13.blacknight.com (Postfix) with ESMTPS id 5387B1C3036
	for <linux-mm@kvack.org>; Wed, 18 Oct 2017 11:15:48 +0100 (IST)
Date: Wed, 18 Oct 2017 11:15:47 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 1/8] mm, page_alloc: Enable/disable IRQs once when
 freeing a list of pages
Message-ID: <20171018101547.mjycw7zreb66jzpa@techsingularity.net>
References: <20171018075952.10627-1-mgorman@techsingularity.net>
 <20171018075952.10627-2-mgorman@techsingularity.net>
 <bcd95a87-3f63-9f5d-77a0-2b2115f53919@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <bcd95a87-3f63-9f5d-77a0-2b2115f53919@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Jan Kara <jack@suse.cz>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Dave Chinner <david@fromorbit.com>

On Wed, Oct 18, 2017 at 11:02:18AM +0200, Vlastimil Babka wrote:
> On 10/18/2017 09:59 AM, Mel Gorman wrote:
> > Freeing a list of pages current enables/disables IRQs for each page freed.
> > This patch splits freeing a list of pages into two operations -- preparing
> > the pages for freeing and the actual freeing. This is a tradeoff - we're
> > taking two passes of the list to free in exchange for avoiding multiple
> > enable/disable of IRQs.
> 
> There's also some overhead of storing pfn in page->private, but all that
> seems negligible compared to irq disable/enable...
> 

Exactly and it's cheaper than doing a second page to pfn lookup.

> <SNIP>
> Looks good.
> 
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 

Thanks.

> A nit below.
> 
> > @@ -2647,11 +2663,25 @@ void free_hot_cold_page(struct page *page, bool cold)
> >  void free_hot_cold_page_list(struct list_head *list, bool cold)
> >  {
> >  	struct page *page, *next;
> > +	unsigned long flags, pfn;
> > +
> > +	/* Prepare pages for freeing */
> > +	list_for_each_entry_safe(page, next, list, lru) {
> > +		pfn = page_to_pfn(page);
> > +		if (!free_hot_cold_page_prepare(page, pfn))
> > +			list_del(&page->lru);
> > +		page->private = pfn;
> 
> We have (set_)page_private() helpers so better to use them (makes it a
> bit easier to check for all places where page->private is used to e.g.
> avoid a clash)?
> 

Agreed and it's trivial to do so

---8<---
mm, page_alloc: Enable/disable IRQs once when freeing a list of page -fix

Use page_private and set_page_private helpers.

Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
---
 mm/page_alloc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 167e163cf733..092973014c1e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2670,14 +2670,14 @@ void free_hot_cold_page_list(struct list_head *list, bool cold)
 		pfn = page_to_pfn(page);
 		if (!free_hot_cold_page_prepare(page, pfn))
 			list_del(&page->lru);
-		page->private = pfn;
+		set_page_private(page, pfn);
 	}
 
 	local_irq_save(flags);
 	list_for_each_entry_safe(page, next, list, lru) {
-		unsigned long pfn = page->private;
+		unsigned long pfn = page_private(page);
 
-		page->private = 0;
+		set_page_private(page, 0);
 		trace_mm_page_free_batched(page, cold);
 		free_hot_cold_page_commit(page, pfn, cold);
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
