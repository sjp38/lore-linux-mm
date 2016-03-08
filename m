Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f51.google.com (mail-wm0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id 572CC6B0005
	for <linux-mm@kvack.org>; Tue,  8 Mar 2016 05:10:19 -0500 (EST)
Received: by mail-wm0-f51.google.com with SMTP id p65so142753366wmp.1
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 02:10:19 -0800 (PST)
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com. [74.125.82.52])
        by mx.google.com with ESMTPS id q8si2851924wjz.13.2016.03.08.02.10.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Mar 2016 02:10:18 -0800 (PST)
Received: by mail-wm0-f52.google.com with SMTP id l68so123878398wml.0
        for <linux-mm@kvack.org>; Tue, 08 Mar 2016 02:10:18 -0800 (PST)
Date: Tue, 8 Mar 2016 11:10:16 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: protect !costly allocations some more
Message-ID: <20160308101016.GC13542@dhcp22.suse.cz>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
 <20160203132718.GI6757@dhcp22.suse.cz>
 <alpine.LSU.2.11.1602241832160.15564@eggly.anvils>
 <20160225092315.GD17573@dhcp22.suse.cz>
 <20160229210213.GX16930@dhcp22.suse.cz>
 <20160307160838.GB5028@dhcp22.suse.cz>
 <56DE9A68.2010301@suse.cz>
 <20160308094612.GB13542@dhcp22.suse.cz>
 <56DEA0CF.2070902@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56DEA0CF.2070902@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <js1304@gmail.com>

On Tue 08-03-16 10:52:15, Vlastimil Babka wrote:
> On 03/08/2016 10:46 AM, Michal Hocko wrote:
[...]
> >>> @@ -3294,6 +3289,18 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
> >>>  				 did_some_progress > 0, no_progress_loops))
> >>>  		goto retry;
> >>>  
> >>> +	/*
> >>> +	 * !costly allocations are really important and we have to make sure
> >>> +	 * the compaction wasn't deferred or didn't bail out early due to locks
> >>> +	 * contention before we go OOM.
> >>> +	 */
> >>> +	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
> >>> +		if (compact_result <= COMPACT_CONTINUE)
> >>
> >> Same here.
> >> I was going to say that this didn't have effect on Sergey's test, but
> >> turns out it did :)
> > 
> > This should work as expected because compact_result is unsigned long
> > and so this is the unsigned arithmetic. I can make
> > #define COMPACT_NONE            -1UL
> > 
> > to make the intention more obvious if you prefer, though.
> 
> Well, what wasn't obvious to me is actually that here (unlike in the
> test above) it was actually intended that COMPACT_NONE doesn't result in
> a retry. But it makes sense, otherwise we would retry endlessly if
> reclaim couldn't form a higher-order page, right.

Yeah, that was the whole point. An alternative would be moving the test
into should_compact_retry(order, compact_result, contended_compaction)
which would be CONFIG_COMPACTION specific so we can get rid of the
COMPACT_NONE altogether. Something like the following. We would lose the
always initialized compact_result but this would matter only for
order==0 and we check for that. Even gcc doesn't complain.

A more important question is whether the criteria I have chosen are
reasonable and reasonably independent on the particular implementation
of the compaction. I still cannot convince myself about the convergence
here. Is it possible that the compaction would keep returning 
compact_result <= COMPACT_CONTINUE while not making any progress at all?

Sure we can see a case where somebody is stealing the compacted blocks
but that is very same with the order-0 where parallel mem eaters will
piggy back on the reclaimer and there is no upper boundary as well well.

---
diff --git a/include/linux/compaction.h b/include/linux/compaction.h
index a4cec4a03f7d..4cd4ddf64cc7 100644
--- a/include/linux/compaction.h
+++ b/include/linux/compaction.h
@@ -1,8 +1,6 @@
 #ifndef _LINUX_COMPACTION_H
 #define _LINUX_COMPACTION_H
 
-/* compaction disabled */
-#define COMPACT_NONE		-1
 /* Return values for compact_zone() and try_to_compact_pages() */
 /* compaction didn't start as it was deferred due to past failures */
 #define COMPACT_DEFERRED	0
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f89e3cbfdf90..c5932a218fc6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2823,10 +2823,8 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 {
 	struct page *page;
 
-	if (!order) {
-		*compact_result = COMPACT_NONE;
+	if (!order)
 		return NULL;
-	}
 
 	current->flags |= PF_MEMALLOC;
 	*compact_result = try_to_compact_pages(gfp_mask, order, alloc_flags, ac,
@@ -2864,6 +2862,25 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 
 	return NULL;
 }
+
+static inline bool
+should_compact_retry(unsigned int order, unsigned long compact_result,
+		     int contended_compaction)
+{
+	/*
+	 * !costly allocations are really important and we have to make sure
+	 * the compaction wasn't deferred or didn't bail out early due to locks
+	 * contention before we go OOM.
+	 */
+	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
+		if (compact_result <= COMPACT_CONTINUE)
+			return true;
+		if (contended_compaction > COMPACT_CONTENDED_NONE)
+			return true;
+	}
+
+	return false;
+}
 #else
 static inline struct page *
 __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
@@ -2871,9 +2888,15 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 		enum migrate_mode mode, int *contended_compaction,
 		unsigned long *compact_result)
 {
-	*compact_result = COMPACT_NONE;
 	return NULL;
 }
+
+static inline bool
+should_compact_retry(unsigned int order, unsigned long compact_result,
+		     int contended_compaction)
+{
+	return false;
+}
 #endif /* CONFIG_COMPACTION */
 
 /* Perform direct synchronous page reclaim */
@@ -3289,17 +3312,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 				 did_some_progress > 0, no_progress_loops))
 		goto retry;
 
-	/*
-	 * !costly allocations are really important and we have to make sure
-	 * the compaction wasn't deferred or didn't bail out early due to locks
-	 * contention before we go OOM.
-	 */
-	if (order && order <= PAGE_ALLOC_COSTLY_ORDER) {
-		if (compact_result <= COMPACT_CONTINUE)
-			goto retry;
-		if (contended_compaction > COMPACT_CONTENDED_NONE)
-			goto retry;
-	}
+	if (should_compact_retry(order, compact_result, contended_compaction))
+		goto retry;
 
 	/* Reclaim has failed us, start killing things */
 	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
