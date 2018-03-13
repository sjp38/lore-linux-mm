Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A6F916B0005
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 03:03:00 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g66so6985184pfj.11
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 00:03:00 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e15si3063478pfl.284.2018.03.13.00.02.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Mar 2018 00:02:59 -0700 (PDT)
Date: Tue, 13 Mar 2018 15:04:04 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v4 3/3 update] mm/free_pcppages_bulk: prefetch buddy
 while not holding lock
Message-ID: <20180313070404.GA7501@intel.com>
References: <20180301062845.26038-1-aaron.lu@intel.com>
 <20180301062845.26038-4-aaron.lu@intel.com>
 <20180301160950.b561d6b8b561217bad511229@linux-foundation.org>
 <20180302082756.GC6356@intel.com>
 <20180309082431.GB30868@intel.com>
 <988ce376-bdc4-0989-5133-612bfa3f7c45@intel.com>
 <20180313033519.GC13782@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180313033519.GC13782@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, David Rientjes <rientjes@google.com>

On Tue, Mar 13, 2018 at 11:35:19AM +0800, Aaron Lu wrote:
> On Mon, Mar 12, 2018 at 10:32:32AM -0700, Dave Hansen wrote:
> > On 03/09/2018 12:24 AM, Aaron Lu wrote:
> > > +			/*
> > > +			 * We are going to put the page back to the global
> > > +			 * pool, prefetch its buddy to speed up later access
> > > +			 * under zone->lock. It is believed the overhead of
> > > +			 * an additional test and calculating buddy_pfn here
> > > +			 * can be offset by reduced memory latency later. To
> > > +			 * avoid excessive prefetching due to large count, only
> > > +			 * prefetch buddy for the last pcp->batch nr of pages.
> > > +			 */
> > > +			if (count > pcp->batch)
> > > +				continue;
> > > +			pfn = page_to_pfn(page);
> > > +			buddy_pfn = __find_buddy_pfn(pfn, 0);
> > > +			buddy = page + (buddy_pfn - pfn);
> > > +			prefetch(buddy);
> > 
> > FWIW, I think this needs to go into a helper function.  Is that possible?
> 
> I'll give it a try.
> 
> > 
> > There's too much logic happening here.  Also, 'count' going from
> > batch_size->0 is totally non-obvious from the patch context.  It makes
> > this hunk look totally wrong by itself.

I tried to avoid adding one more local variable but looks like it caused
a lot of pain. What about the following? It doesn't use count any more
but prefetch_nr to indicate how many prefetches have happened.

Also, I think it's not worth the risk of disordering pages in free_list
by changing list_add_tail() to list_add() as Andrew reminded so I
dropped that change too.


diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index dafdcdec9c1f..00ea4483f679 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1099,6 +1099,15 @@ static bool bulkfree_pcp_prepare(struct page *page)
 }
 #endif /* CONFIG_DEBUG_VM */
 
+static inline void prefetch_buddy(struct page *page)
+{
+	unsigned long pfn = page_to_pfn(page);
+	unsigned long buddy_pfn = __find_buddy_pfn(pfn, 0);
+	struct page *buddy = page + (buddy_pfn - pfn);
+
+	prefetch(buddy);
+}
+
 /*
  * Frees a number of pages from the PCP lists
  * Assumes all pages on list are in same zone, and of same order.
@@ -1115,6 +1124,7 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 {
 	int migratetype = 0;
 	int batch_free = 0;
+	int prefetch_nr = 0;
 	bool isolated_pageblocks;
 	struct page *page, *tmp;
 	LIST_HEAD(head);
@@ -1150,6 +1160,18 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 				continue;
 
 			list_add_tail(&page->lru, &head);
+
+			/*
+			 * We are going to put the page back to the global
+			 * pool, prefetch its buddy to speed up later access
+			 * under zone->lock. It is believed the overhead of
+			 * an additional test and calculating buddy_pfn here
+			 * can be offset by reduced memory latency later. To
+			 * avoid excessive prefetching due to large count, only
+			 * prefetch buddy for the first pcp->batch nr of pages.
+			 */
+			if (prefetch_nr++ < pcp->batch)
+				prefetch_buddy(page);
 		} while (--count && --batch_free && !list_empty(list));
 	}
 
-- 
2.14.3
