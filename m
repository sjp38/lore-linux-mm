Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 40DC76B006E
	for <linux-mm@kvack.org>; Tue, 15 Nov 2011 10:44:03 -0500 (EST)
Date: Tue, 15 Nov 2011 15:43:57 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111115154357.GI27150@suse.de>
References: <20111114140421.GA27150@suse.de>
 <20111114150326.0ee60107.akpm@linux-foundation.org>
 <20111115104223.GC27150@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20111115104223.GC27150@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, David Rientjes <rientjes@google.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> <SNIP>
> It feels overkill to allocate more global storage for it when
> gfp_allowed_mask is already there but I could rename pm_suspending() to
> pm_disabled_storage(), make try_to_free_swap() use the same helper but
> leave the implementation the same. This would clarify the situation.
> 

Something like this? It's on top of your comment update

==== CUT HERE ====
mm: Clarify usage of gfp_allowed_mask

This patch clarifies how gfp_allowed_mask is used and that during
run-time it is PM-specific.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/gfp.h |   16 ++++++++++++++++
 mm/page_alloc.c     |   11 ++---------
 mm/swapfile.c       |    6 +++---
 3 files changed, 21 insertions(+), 12 deletions(-)

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
index 2ee4040..4ace1e0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -128,19 +128,12 @@ void pm_restrict_gfp_mask(void)
 	gfp_allowed_mask &= ~GFP_IOFS;
 }
 
-static bool pm_suspending(void)
+bool pm_suspended_storage(void)
 {
 	if ((gfp_allowed_mask & GFP_IOFS) == GFP_IOFS)
 		return false;
 	return true;
 }
-
-#else
-
-static bool pm_suspending(void)
-{
-	return false;
-}
 #endif /* CONFIG_PM_SLEEP */
 
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
@@ -2235,7 +2228,7 @@ rebalance:
 		 * Suspend also disables storage devices so kswapd cannot save
 		 * us.  Bail if we are suspending.
 		 */
-		if (pm_suspending())
+		if (pm_suspended_storage())
 			goto nopage;
 	}
 
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
