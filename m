Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 728996B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 22:54:21 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D2sEsi019609
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 13 May 2010 11:54:15 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 93F4045DE7B
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:54:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5720945DE79
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:54:14 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 17F1BE08009
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:54:14 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 75306E08001
	for <linux-mm@kvack.org>; Thu, 13 May 2010 11:54:13 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: page_check_references() check low order lumpy reclaim properly
In-Reply-To: <20100416141841.300d2361.akpm@linux-foundation.org>
References: <20100416115437.27AD.A69D9226@jp.fujitsu.com> <20100416141841.300d2361.akpm@linux-foundation.org>
Message-Id: <20100513115316.2155.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 13 May 2010 11:54:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Andreas Mohr <andi@lisas.de>, Jens Axboe <axboe@kernel.dk>, Minchan Kim <minchan.kim@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

> > @@ -77,6 +77,8 @@ struct scan_control {
> >  
> >  	int order;
> >  
> > +	int lumpy_reclaim;
> > +
> 
> Needs a comment explaining its role, please.  Something like "direct
> this reclaim run to perform lumpy reclaim"?
> 
> A clearer name might be "lumpy_relcaim_mode"?
> 
> Making it a `bool' would clarify things too.

Sorry, I've missed your this review comment.
How about this?


---
 mm/vmscan.c |   39 ++++++++++++++++++++++++---------------
 1 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 13d9546..c3bcdd4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -77,7 +77,11 @@ struct scan_control {
 
 	int order;
 
-	int lumpy_reclaim;
+	/*
+	 * Intend to reclaim enough contenious memory rather than to reclaim
+	 * enough amount memory. I.e, it's the mode for high order allocation.
+	 */
+	bool lumpy_reclaim_mode;
 
 	/* Which cgroup do we reclaim from */
 	struct mem_cgroup *mem_cgroup;
@@ -577,7 +581,7 @@ static enum page_references page_check_references(struct page *page,
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
-	if (sc->lumpy_reclaim)
+	if (sc->lumpy_reclaim_mode)
 		return PAGEREF_RECLAIM;
 
 	/*
@@ -1153,7 +1157,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		unsigned long nr_freed;
 		unsigned long nr_active;
 		unsigned int count[NR_LRU_LISTS] = { 0, };
-		int mode = sc->lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
+		int mode = sc->lumpy_reclaim_mode ? ISOLATE_BOTH : ISOLATE_INACTIVE;
 		unsigned long nr_anon;
 		unsigned long nr_file;
 
@@ -1206,7 +1210,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 		 * but that should be acceptable to the caller
 		 */
 		if (nr_freed < nr_taken && !current_is_kswapd() &&
-		    sc->lumpy_reclaim) {
+		    sc->lumpy_reclaim_mode) {
 			congestion_wait(BLK_RW_ASYNC, HZ/10);
 
 			/*
@@ -1609,6 +1613,21 @@ static unsigned long nr_scan_try_batch(unsigned long nr_to_scan,
 	return nr;
 }
 
+static void set_lumpy_reclaim_mode(int priority, struct scan_control *sc)
+{
+	/*
+	 * If we need a large contiguous chunk of memory, or have
+	 * trouble getting a small set of contiguous pages, we
+	 * will reclaim both active and inactive pages.
+	 */
+	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
+		sc->lumpy_reclaim_mode = 1;
+	else if (sc->order && priority < DEF_PRIORITY - 2)
+		sc->lumpy_reclaim_mode = 1;
+	else
+		sc->lumpy_reclaim_mode = 0;
+}
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -1645,17 +1664,7 @@ static void shrink_zone(int priority, struct zone *zone,
 					  &reclaim_stat->nr_saved_scan[l]);
 	}
 
-	/*
-	 * If we need a large contiguous chunk of memory, or have
-	 * trouble getting a small set of contiguous pages, we
-	 * will reclaim both active and inactive pages.
-	 */
-	if (sc->order > PAGE_ALLOC_COSTLY_ORDER)
-		sc->lumpy_reclaim = 1;
-	else if (sc->order && priority < DEF_PRIORITY - 2)
-		sc->lumpy_reclaim = 1;
-	else
-		sc->lumpy_reclaim = 0;
+	set_lumpy_reclaim_mode(priority, sc);
 
 	while (nr[LRU_INACTIVE_ANON] || nr[LRU_ACTIVE_FILE] ||
 					nr[LRU_INACTIVE_FILE]) {
-- 
1.6.5.2





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
