Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4CED46B0007
	for <linux-mm@kvack.org>; Mon, 26 Feb 2018 22:16:10 -0500 (EST)
Received: by mail-pl0-f70.google.com with SMTP id t2so8597745plr.15
        for <linux-mm@kvack.org>; Mon, 26 Feb 2018 19:16:10 -0800 (PST)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id u3si6371622pgr.447.2018.02.26.19.16.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Feb 2018 19:16:09 -0800 (PST)
Date: Tue, 27 Feb 2018 11:17:07 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [PATCH v3 2/3] mm/free_pcppages_bulk: do not hold lock when
 picking pages to free
Message-ID: <20180227031707.GB28977@intel.com>
References: <20180226135346.7208-1-aaron.lu@intel.com>
 <20180226135346.7208-3-aaron.lu@intel.com>
 <alpine.DEB.2.20.1802261352160.135844@chino.kir.corp.google.com>
 <20180227020058.GB9141@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180227020058.GB9141@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>

On Tue, Feb 27, 2018 at 10:00:58AM +0800, Aaron Lu wrote:
> On Mon, Feb 26, 2018 at 01:53:10PM -0800, David Rientjes wrote:
> > On Mon, 26 Feb 2018, Aaron Lu wrote:
> > 
> > > @@ -1144,26 +1142,31 @@ static void free_pcppages_bulk(struct zone *zone, int count,
> > >  			batch_free = count;
> > >  
> > >  		do {
> > > -			int mt;	/* migratetype of the to-be-freed page */
> > > -
> > >  			page = list_last_entry(list, struct page, lru);
> > >  			/* must delete as __free_one_page list manipulates */
> > 
> > Looks good in general, but I'm not sure how I reconcile this comment with 
> > the new implementation that later links page->lru again.
> 
> Thanks for pointing this out.
> 
> I think the comment is useless now since there is a list_add_tail right
> below so it's obvious we need to take the page off its original list.
> I'll remove the comment in an update.

Thinking again, I think I'll change the comment to:

-			/* must delete as __free_one_page list manipulates */
+			/* must delete to avoid corrupting pcp list */
 			list_del(&page->lru);
 			pcp->count--;
 
Meanwhile, I'll add one more comment about why list_for_each_entry_safe
is used:

+	/*
+	 * Use safe version since after __free_one_page(),
+	 * page->lru.next will not point to original list.
+	 */
+	list_for_each_entry_safe(page, tmp, &head, lru) {
+		int mt = get_pcppage_migratetype(page);
+		/* MIGRATE_ISOLATE page should not go to pcplists */
+		VM_BUG_ON_PAGE(is_migrate_isolate(mt), page);
+		/* Pageblock could have been isolated meanwhile */
+		if (unlikely(isolated_pageblocks))
+			mt = get_pageblock_migratetype(page);
+
+		__free_one_page(page, page_to_pfn(page), zone, 0, mt);
+		trace_mm_page_pcpu_drain(page, 0, mt);
+	}
 	spin_unlock(&zone->lock);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
