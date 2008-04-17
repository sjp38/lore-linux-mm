Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m3H1e0kV027755
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 21:40:00 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3H1duhj180684
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 19:40:00 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3H1dtaY009109
	for <linux-mm@kvack.org>; Wed, 16 Apr 2008 19:39:56 -0600
Date: Wed, 16 Apr 2008 18:39:49 -0700
From: Nishanth Aravamudan <nacc@us.ibm.com>
Subject: [UPDATED][PATCH 2/3] Smarter retry of costly-order allocations
Message-ID: <20080417013949.GA17076@us.ibm.com>
References: <20080411233500.GA19078@us.ibm.com> <20080411233553.GB19078@us.ibm.com> <20080415000745.9af1b269.akpm@linux-foundation.org> <20080415172614.GE15840@us.ibm.com> <20080415121834.0aa406c4.akpm@linux-foundation.org> <20080416000010.GF15840@us.ibm.com> <20080415170902.4ec7aae5.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080415170902.4ec7aae5.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mel@csn.ul.ie, clameter@sgi.com, apw@shadowen.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 15.04.2008 [17:09:02 -0700], Andrew Morton wrote:
> On Tue, 15 Apr 2008 17:00:10 -0700
> Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> 
> > On 15.04.2008 [12:18:34 -0700], Andrew Morton wrote:
> > > On Tue, 15 Apr 2008 10:26:14 -0700
> > > Nishanth Aravamudan <nacc@us.ibm.com> wrote:
> > > 
> > > > > So... would like to see some firmer-looking testing results, please.
> > > > 
> > > > Do Mel's e-mails cover this sufficiently?
> > > 
> > > I guess so.
> > > 
> > > Could you please pull together a new set of changelogs sometime?
> > 
> > Will do it tomorrow, for sure.
> > 
> > > The big-picture change here is that we now use GFP_REPEAT for hugepages,
> > > which makes the allocations work better.  But I assume that you hit some
> > > problem with that which led you to reduce the amount of effort which
> > > GFP_REPEAT will expend for larger pages, yes?
> > > 
> > > If so, a description of that problem would be appropriate as well.
> > 
> > Will add that, as well.
> > 
> > Would you like me to repost the patch with the new changelog and just
> > ask you therein to drop and replace? Patches 1/3 and 3/3 should be
> > unchanged.
> > 
> 
> Sure, whatever, I'll work it out ;)

Because of page order checks in __alloc_pages(), hugepage (and similarly
large order) allocations will not retry unless explicitly marked
__GFP_REPEAT. However, the current retry logic is nearly an infinite
loop (or until reclaim does no progress whatsoever). For these costly
allocations, that seems like overkill and could potentially never
terminate. Mel observed that allowing current __GFP_REPEAT semantics for
hugepage allocations essentially killed the system. I believe this is
because we may continue to reclaim small orders of pages all over, but
never have enough to satisfy the hugepage allocation request. This is
clearly only a problem for large order allocations, of which hugepages
are the most obvious (to me).

Modify try_to_free_pages() to indicate how many pages were reclaimed.
Use that information in __alloc_pages() to eventually fail a large
__GFP_REPEAT allocation when we've reclaimed an order of pages equal to
or greater than the allocation's order. This relies on lumpy reclaim
functioning as advertised. Due to fragmentation, lumpy reclaim may not
be able to free up the order needed in one invocation, so multiple
iterations may be requred. In other words, the more fragmented memory
is, the more retry attempts __GFP_REPEAT will make (particularly for
higher order allocations).

This changes the semantics of __GFP_REPEAT subtly, but *only* for
allocations > PAGE_ALLOC_COSTLY_ORDER. With this patch, for those size
allocations, we will try up to some point (at least 1<<order reclaimed
pages), rather than forever (which is the case for allocations <=
PAGE_ALLOC_COSTLY_ORDER).

This change improves the /proc/sys/vm/nr_hugepages interface with a
follow-on patch that makes pool allocations use __GFP_REPEAT. Rather
than administrators repeatedly echo'ing a particular value into the
sysctl, and forcing reclaim into action manually, this change allows for
the sysctl to attempt a reasonable effort itself. Similarly, dynamic
pool growth should be more successful under load, as lumpy reclaim can
try to free up pages, rather than failing right away.

Choosing to reclaim only up to the order of the requested allocation
strikes a balance between not failing hugepage allocations and returning
to the caller when it's unlikely to every succeed. Because of lumpy
reclaim, if we have freed the order requested, hopefully it has been in
big chunks and those chunks will allow our allocation to succeed. If
that isn't the case after freeing up the current order, I don't think it
is likely to succeed in the future, although it is possible given a
particular fragmentation pattern.

Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
Tested-by: Mel Gorman <mel@csn.ul.ie>

---
Not sure if this is any better, Andrew. I'll update 3/3 as well, to
include Mel's testing results.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1db36da..1a0cc4d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1541,7 +1541,8 @@ __alloc_pages_internal(gfp_t gfp_mask, unsigned int order,
 	struct task_struct *p = current;
 	int do_retry;
 	int alloc_flags;
-	int did_some_progress;
+	unsigned long did_some_progress;
+	unsigned long pages_reclaimed = 0;
 
 	might_sleep_if(wait);
 
@@ -1691,15 +1692,26 @@ nofail_alloc:
 	 * Don't let big-order allocations loop unless the caller explicitly
 	 * requests that.  Wait for some write requests to complete then retry.
 	 *
-	 * In this implementation, either order <= PAGE_ALLOC_COSTLY_ORDER or
-	 * __GFP_REPEAT mean __GFP_NOFAIL, but that may not be true in other
+	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
+	 * means __GFP_NOFAIL, but that may not be true in other
 	 * implementations.
+	 *
+	 * For order > PAGE_ALLOC_COSTLY_ORDER, if __GFP_REPEAT is
+	 * specified, then we retry until we no longer reclaim any pages
+	 * (above), or we've reclaimed an order of pages at least as
+	 * large as the allocation's order. In both cases, if the
+	 * allocation still fails, we stop retrying.
 	 */
+	pages_reclaimed += did_some_progress;
 	do_retry = 0;
 	if (!(gfp_mask & __GFP_NORETRY)) {
-		if ((order <= PAGE_ALLOC_COSTLY_ORDER) ||
-						(gfp_mask & __GFP_REPEAT))
+		if (order <= PAGE_ALLOC_COSTLY_ORDER) {
 			do_retry = 1;
+		} else {
+			if (gfp_mask & __GFP_REPEAT &&
+				pages_reclaimed < (1 << order))
+					do_retry = 1;
+		}
 		if (gfp_mask & __GFP_NOFAIL)
 			do_retry = 1;
 	}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 83f42c9..d106b2c 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1319,6 +1319,9 @@ static unsigned long shrink_zones(int priority, struct zonelist *zonelist,
  * hope that some of these pages can be written.  But if the allocating task
  * holds filesystem locks which prevent writeout this might not work, and the
  * allocation attempt will fail.
+ *
+ * returns:	0, if no pages reclaimed
+ * 		else, the number of pages reclaimed
  */
 static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					struct scan_control *sc)
@@ -1368,7 +1371,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		}
 		total_scanned += sc->nr_scanned;
 		if (nr_reclaimed >= sc->swap_cluster_max) {
-			ret = 1;
+			ret = nr_reclaimed;
 			goto out;
 		}
 
@@ -1391,7 +1394,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 	}
 	/* top priority shrink_caches still had more to do? don't OOM, then */
 	if (!sc->all_unreclaimable && scan_global_lru(sc))
-		ret = 1;
+		ret = nr_reclaimed;
 out:
 	/*
 	 * Now that we've scanned all the zones at this priority level, note

-- 
Nishanth Aravamudan <nacc@us.ibm.com>
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
