Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 137026B01E3
	for <linux-mm@kvack.org>; Wed,  7 Apr 2010 14:29:38 -0400 (EDT)
Date: Wed, 7 Apr 2010 19:29:16 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 11/14] Direct compact when a high-order allocation fails
Message-ID: <20100407182916.GY17882@csn.ul.ie>
References: <1270224168-14775-1-git-send-email-mel@csn.ul.ie> <1270224168-14775-12-git-send-email-mel@csn.ul.ie> <20100406170603.8a999dc2.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100406170603.8a999dc2.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 05:06:03PM -0700, Andrew Morton wrote:
> > @@ -896,6 +904,9 @@ static const char * const vmstat_text[] = {
> >  	"compact_blocks_moved",
> >  	"compact_pages_moved",
> >  	"compact_pagemigrate_failed",
> > +	"compact_stall",
> > +	"compact_fail",
> > +	"compact_success",
> 
> CONFIG_COMPACTION=n?
> 

This patch goes on top of the series. It looks big but it's mainly
moving code.

==== CUT HERE ====
mm,compaction: Do not display compaction-related stats when !CONFIG_COMPACTION

Although compaction can be disabled from .config, the vmstat entries
still exist. This patch removes the vmstat entries. As page_alloc.c
refers directly to the counters, the patch introduces
__alloc_pages_direct_compact() to isolate use of the counters.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 include/linux/vmstat.h |    2 +
 mm/page_alloc.c        |   92 ++++++++++++++++++++++++++++++++---------------
 mm/vmstat.c            |    2 +
 3 files changed, 66 insertions(+), 30 deletions(-)

diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index b4b4d34..7f43ccd 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -43,8 +43,10 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
 		KSWAPD_LOW_WMARK_HIT_QUICKLY, KSWAPD_HIGH_WMARK_HIT_QUICKLY,
 		KSWAPD_SKIP_CONGESTION_WAIT,
 		PAGEOUTRUN, ALLOCSTALL, PGROTATED,
+#ifdef CONFIG_COMPACTION
 		COMPACTBLOCKS, COMPACTPAGES, COMPACTPAGEFAILED,
 		COMPACTSTALL, COMPACTFAIL, COMPACTSUCCESS,
+#endif
 #ifdef CONFIG_HUGETLB_PAGE
 		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 46f6be4..514cc96 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1756,6 +1756,59 @@ out:
 	return page;
 }
 
+#ifdef CONFIG_COMPACTION
+/* Try memory compaction for high-order allocations before reclaim */
+static struct page *
+__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	int migratetype, unsigned long *did_some_progress)
+{
+	struct page *page;
+
+	if (!order)
+		return NULL;
+
+	*did_some_progress = try_to_compact_pages(zonelist, order, gfp_mask,
+								nodemask);
+	if (*did_some_progress != COMPACT_SKIPPED) {
+
+		/* Page migration frees to the PCP lists but we want merging */
+		drain_pages(get_cpu());
+		put_cpu();
+
+		page = get_page_from_freelist(gfp_mask, nodemask,
+				order, zonelist, high_zoneidx,
+				alloc_flags, preferred_zone,
+				migratetype);
+		if (page) {
+			__count_vm_event(COMPACTSUCCESS);
+			return page;
+		}
+
+		/*
+		 * It's bad if compaction run occurs and fails.
+		 * The most likely reason is that pages exist,
+		 * but not enough to satisfy watermarks.
+		 */
+		count_vm_event(COMPACTFAIL);
+
+		cond_resched();
+	}
+
+	return NULL;
+}
+#else
+static inline struct page *
+__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
+	struct zonelist *zonelist, enum zone_type high_zoneidx,
+	nodemask_t *nodemask, int alloc_flags, struct zone *preferred_zone,
+	int migratetype, unsigned long *did_some_progress)
+{
+	return NULL;
+}
+#endif /* CONFIG_COMPACTION */
+
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
 __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
@@ -1769,36 +1822,6 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 
 	cond_resched();
 
-	/* Try memory compaction for high-order allocations before reclaim */
-	if (order) {
-		*did_some_progress = try_to_compact_pages(zonelist,
-						order, gfp_mask, nodemask);
-		if (*did_some_progress != COMPACT_SKIPPED) {
-
-			/* Page migration frees to the PCP lists but we want merging */
-			drain_pages(get_cpu());
-			put_cpu();
-
-			page = get_page_from_freelist(gfp_mask, nodemask,
-					order, zonelist, high_zoneidx,
-					alloc_flags, preferred_zone,
-					migratetype);
-			if (page) {
-				__count_vm_event(COMPACTSUCCESS);
-				return page;
-			}
-
-			/*
-			 * It's bad if compaction run occurs and fails.
-			 * The most likely reason is that pages exist,
-			 * but not enough to satisfy watermarks.
-			 */
-			count_vm_event(COMPACTFAIL);
-
-			cond_resched();
-		}
-	}
-
 	/* We now go into synchronous reclaim */
 	cpuset_memory_pressure_bump();
 	p->flags |= PF_MEMALLOC;
@@ -1972,6 +1995,15 @@ rebalance:
 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
 		goto nopage;
 
+	/* Try direct compaction */
+	page = __alloc_pages_direct_compact(gfp_mask, order,
+					zonelist, high_zoneidx,
+					nodemask,
+					alloc_flags, preferred_zone,
+					migratetype, &did_some_progress);
+	if (page)
+		goto got_pg;
+
 	/* Try direct reclaim and then allocating */
 	page = __alloc_pages_direct_reclaim(gfp_mask, order,
 					zonelist, high_zoneidx,
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 2780a36..0a58cbe 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -901,12 +901,14 @@ static const char * const vmstat_text[] = {
 
 	"pgrotated",
 
+#ifdef CONFIG_COMPACTION
 	"compact_blocks_moved",
 	"compact_pages_moved",
 	"compact_pagemigrate_failed",
 	"compact_stall",
 	"compact_fail",
 	"compact_success",
+#endif
 
 #ifdef CONFIG_HUGETLB_PAGE
 	"htlb_buddy_alloc_success",

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
