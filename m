Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1FC7B8E0002
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 09:39:06 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id c18so4919275edt.23
        for <linux-mm@kvack.org>; Fri, 18 Jan 2019 06:39:06 -0800 (PST)
Received: from outbound-smtp26.blacknight.com (outbound-smtp26.blacknight.com. [81.17.249.194])
        by mx.google.com with ESMTPS id a30-v6si2025055ejn.126.2019.01.18.06.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 Jan 2019 06:39:04 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail02.blacknight.ie [81.17.254.11])
	by outbound-smtp26.blacknight.com (Postfix) with ESMTPS id 3453EB899D
	for <linux-mm@kvack.org>; Fri, 18 Jan 2019 14:39:04 +0000 (GMT)
Date: Fri, 18 Jan 2019 14:39:02 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 24/25] mm, compaction: Capture a page under direct
 compaction
Message-ID: <20190118143902.GR27437@techsingularity.net>
References: <20190104125011.16071-1-mgorman@techsingularity.net>
 <20190104125011.16071-25-mgorman@techsingularity.net>
 <d8a3dfc9-e4f6-ceb6-f29d-832bef14a14a@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <d8a3dfc9-e4f6-ceb6-f29d-832bef14a14a@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Linux-MM <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Andrea Arcangeli <aarcange@redhat.com>, ying.huang@intel.com, kirill@shutemov.name, Andrew Morton <akpm@linux-foundation.org>, Linux List Kernel Mailing <linux-kernel@vger.kernel.org>

On Fri, Jan 18, 2019 at 02:40:00PM +0100, Vlastimil Babka wrote:
> > Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> 
> Great, you crossed off this old TODO item, and didn't need pageblock isolation
> to do that :D
> 

The TODO is not just old, it's ancient! The idea of capture was first
floated in 2008! A version was proposed at https://lwn.net/Articles/301246/
against 2.6.27-rc1-mm1.

> I have just one worry...
> 
> > @@ -837,6 +873,12 @@ static inline void __free_one_page(struct page *page,
> >  
> >  continue_merging:
> >  	while (order < max_order - 1) {
> > +		if (compaction_capture(capc, page, order)) {
> > +			if (likely(!is_migrate_isolate(migratetype)))
> > +				__mod_zone_freepage_state(zone, -(1 << order),
> > +								migratetype);
> > +			return;
> 
> What about MIGRATE_CMA pageblocks and compaction for non-movable allocation,
> won't that violate CMA expecteations?
> And less critically, this will avoid the migratetype stealing decisions and
> actions, potentially resulting in worse fragmentation avoidance?
> 

Both might be issues. How about this (untested)?

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fe089ac8a207..d61174bb0333 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -799,11 +799,26 @@ static inline struct capture_control *task_capc(struct zone *zone)
 }
 
 static inline bool
-compaction_capture(struct capture_control *capc, struct page *page, int order)
+compaction_capture(struct capture_control *capc, struct page *page,
+		   int order, int migratetype)
 {
 	if (!capc || order != capc->cc->order)
 		return false;
 
+	/* Do not accidentally pollute CMA or isolated regions*/
+	if (is_migrate_cma(migratetype) ||
+	    is_migrate_isolate(migratetype))
+		return false;
+
+	/*
+	 * Do not let lower order allocations polluate a movable pageblock.
+	 * This might let an unmovable request use a reclaimable pageblock
+	 * and vice-versa but no more than normal fallback logic which can
+	 * have trouble finding a high-order free page.
+	 */
+	if (order < pageblock_order && migratetype == MIGRATE_MOVABLE)
+		return false;
+
 	capc->page = page;
 	return true;
 }
@@ -815,7 +830,8 @@ static inline struct capture_control *task_capc(struct zone *zone)
 }
 
 static inline bool
-compaction_capture(struct capture_control *capc, struct page *page, int order)
+compaction_capture(struct capture_control *capc, struct page *page,
+		   int order, int migratetype)
 {
 	return false;
 }
@@ -870,7 +886,7 @@ static inline void __free_one_page(struct page *page,
 
 continue_merging:
 	while (order < max_order - 1) {
-		if (compaction_capture(capc, page, order)) {
+		if (compaction_capture(capc, page, order, migratetype)) {
 			if (likely(!is_migrate_isolate(migratetype)))
 				__mod_zone_freepage_state(zone, -(1 << order),
 								migratetype);

-- 
Mel Gorman
SUSE Labs
