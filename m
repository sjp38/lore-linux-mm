Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 084C86B0069
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 06:35:09 -0500 (EST)
Date: Thu, 17 Nov 2011 11:35:01 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: mm: avoid livelock on !__GFP_FS allocations v2
Message-ID: <20111117113501.GA20176@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Colin Cross <ccross@android.com>, Minchan Kim <minchan.kim@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

Hi Andrew,

This patch incorporates feedback from David Rientjes, adds some
additional documentation and replaces the following patches in mmotm.

  mm-avoid-livelock-on-__gfp_fs-allocations.patch
  mm-avoid-livelock-on-__gfp_fs-allocations-fix.patch

Minchan is concerned that this adds an additional special case and
that it should be possible to handle this case by altering how suspend
works and how the global variable oom_killer_disabled is used.  At the
time of writing, it's still allowing __GFP_NOFAIL allocations to fail
and it might also impact GFP_NOIO allocations while processes are
frozen (I didn't double check). If that approach reaches maturity,
gets reviewed and confirmed by Colin to fix his problem, it will
supersede this one but it's not there yet. Colin, your tested-by was
removed in this version because it is functionally different to what
you tested. Can you reconfirm this fixes your livelock problem please?

Changelog since V1
  o Move PM check to should_alloc_retry (David Rientjes)
  o Update mm/swapfile.c to use pm_suspended_storage() instead of making
    assumptions on the value of gfp_allowed_mask
  o Add some additional documentation

Colin Cross reported;

  Under the following conditions, __alloc_pages_slowpath can loop forever:
  gfp_mask & __GFP_WAIT is true
  gfp_mask & __GFP_FS is false
  reclaim and compaction make no progress
  order <= PAGE_ALLOC_COSTLY_ORDER

  These conditions happen very often during suspend and resume,
  when pm_restrict_gfp_mask() effectively converts all GFP_KERNEL
  allocations into __GFP_WAIT.

  The oom killer is not run because gfp_mask & __GFP_FS is false,
  but should_alloc_retry will always return true when order is less
  than PAGE_ALLOC_COSTLY_ORDER.

In his fix, he avoided retrying the allocation if reclaim made no
progress and __GFP_FS was not set. The problem is that this would
result in GFP_NOIO allocations failing that previously succeeded
which would be very unfortunate.

The big difference between GFP_NOIO and suspend converting GFP_KERNEL
to behave like GFP_NOIO is that normally flushers will be cleaning
pages and kswapd reclaims pages allowing GFP_NOIO to succeed after
a short delay. The same does not necessarily apply during suspend as
the storage device may be suspended.

This patch special cases the suspend case to fail the page allocation
if reclaim cannot make progress and adds some documentation on how
gfp_allowed_mask is currently used. Failing allocations like this
may cause suspend to abort but that is better than a livelock.

[mgorman@suse.de: Rework fix to be suspend specific]
[rientjes@google.com: Move suspended device check to should_alloc_retry]
Reported-by: Colin Cross <ccross@android.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
Acked-by: David Rientjes <rientjes@google.com>
---
 include/linux/gfp.h |   16 ++++++++++++++++
 mm/page_alloc.c     |   30 ++++++++++++++++++++++--------
 mm/swapfile.c       |    6 +++---
 3 files changed, 41 insertions(+), 11 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 3a76faf..033f55f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -367,9 +367,25 @@ void drain_zone_pages(struct zone *zone, struct per_cpu_pages *pcp);
 void drain_all_pages(void);
 void drain_local_pages(void *dummy);
 
+/*
+ * gfp_allowed_mask is set to GFP_BOOT_MASK during early boot to restrict what
+ * GFP flags are used before interrupts are enabled. Once interrupts are
+ * enabled, it is set to __GFP_BITS_MASK while the system is running. During
+ * hibernation, it is used by PM to avoid I/O during memory allocation while
+ * devices are suspended.
+ */
 extern gfp_t gfp_allowed_mask;
 
 extern void pm_restrict_gfp_mask(void);
 extern void pm_restore_gfp_mask(void);
 
+#ifdef CONFIG_PM_SLEEP
+extern bool pm_suspended_storage(void);
+#else
+static inline bool pm_suspended_storage(void)
+{
+	return false;
+}
+#endif /* CONFIG_PM_SLEEP */
+
 #endif /* __LINUX_GFP_H */
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 9dd443d..a72cbf9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -127,6 +127,13 @@ void pm_restrict_gfp_mask(void)
 	saved_gfp_mask = gfp_allowed_mask;
 	gfp_allowed_mask &= ~GFP_IOFS;
 }
+
+bool pm_suspended_storage(void)
+{
+	if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
+		return false;
+	return true;
+}
 #endif /* CONFIG_PM_SLEEP */
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
@@ -1795,12 +1802,25 @@ void warn_alloc_failed(gfp_t gfp_mask, int order, const char *fmt, ...)
 
 static inline int
 should_alloc_retry(gfp_t gfp_mask, unsigned int order,
+				unsigned long did_some_progress,
 				unsigned long pages_reclaimed)
 {
 	/* Do not loop if specifically requested */
 	if (gfp_mask & __GFP_NORETRY)
 		return 0;
 
+	/* Always retry if specifically requested */
+	if (gfp_mask & __GFP_NOFAIL)
+		return 1;
+
+	/*
+	 * Suspend converts GFP_KERNEL to __GFP_WAIT which can prevent reclaim
+	 * making forward progress without invoking OOM. Suspend also disables
+	 * storage devices so kswapd will not help. Bail if we are suspending.
+	 */
+	if (!did_some_progress && pm_suspended_storage())
+		return 0;
+
 	/*
 	 * In this implementation, order <= PAGE_ALLOC_COSTLY_ORDER
 	 * means __GFP_NOFAIL, but that may not be true in other
@@ -1819,13 +1839,6 @@ should_alloc_retry(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_REPEAT && pages_reclaimed < (1 << order))
 		return 1;
 
-	/*
-	 * Don't let big-order allocations loop unless the caller
-	 * explicitly requests that.
-	 */
-	if (gfp_mask & __GFP_NOFAIL)
-		return 1;
-
 	return 0;
 }
 
@@ -2218,7 +2231,8 @@ rebalance:
 
 	/* Check if we should retry the allocation */
 	pages_reclaimed += did_some_progress;
-	if (should_alloc_retry(gfp_mask, order, pages_reclaimed)) {
+	if (should_alloc_retry(gfp_mask, order, did_some_progress,
+						pages_reclaimed)) {
 		/* Wait for some write requests to complete then retry */
 		wait_iff_congested(preferred_zone, BLK_RW_ASYNC, HZ/50);
 		goto rebalance;
diff --git a/mm/swapfile.c b/mm/swapfile.c
index b1cd120..9520592 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -667,10 +667,10 @@ int try_to_free_swap(struct page *page)
 	 * original page might be freed under memory pressure, then
 	 * later read back in from swap, now with the wrong data.
 	 *
-	 * Hibernation clears bits from gfp_allowed_mask to prevent
-	 * memory reclaim from writing to disk, so check that here.
+	 * Hibration suspends storage while it is writing the image
+	 * to disk so check that here.
 	 */
-	if (!(gfp_allowed_mask & __GFP_IO))
+	if (pm_suspended_storage())
 		return 0;
 
 	delete_from_swap_cache(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
