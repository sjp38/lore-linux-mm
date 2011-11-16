Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 9BAAC6B0069
	for <linux-mm@kvack.org>; Wed, 16 Nov 2011 04:52:51 -0500 (EST)
Date: Wed, 16 Nov 2011 09:52:44 +0000
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] mm: avoid livelock on !__GFP_FS allocations
Message-ID: <20111116095244.GM27150@suse.de>
References: <20111114140421.GA27150@suse.de>
 <alpine.DEB.2.00.1111151332160.26232@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1111151332160.26232@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Colin Cross <ccross@android.com>, Pekka Enberg <penberg@cs.helsinki.fi>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Tue, Nov 15, 2011 at 01:40:42PM -0800, David Rientjes wrote:
> > <SNIP>
> > @@ -2214,6 +2228,14 @@ rebalance:
> >  
> >  			goto restart;
> >  		}
> > +
> > +		/*
> > +		 * Suspend converts GFP_KERNEL to __GFP_WAIT which can
> > +		 * prevent reclaim making forward progress without
> > +		 * invoking OOM. Bail if we are suspending
> > +		 */
> > +		if (pm_suspending())
> > +			goto nopage;
> >  	}
> >  
> >  	/* Check if we should retry the allocation */
> 
> This allows all __GFP_NOFAIL allocations to fail while 
> pm_restrict_gfp_mask() is in effect, so I disagree with this unless it is 
> moved into the should_alloc_retry() logic.  If you pass did_some_progress 
> into that function and then moved the check for __GFP_NOFAIL right under 
> the check for __GFP_NORETRY and checked for pm_suspending() there (and 
> before the check for PAGE_ALLOC_COSTLY_ORDER) then it would allow the 
> infinite loop for __GFP_NOFAIL which is required if __GFP_WAIT.

Good point. I agree that it would be more consistent although
there is still the risk of infinite looping with __GFP_NOFAIL if
storage devices are disabled.

Colin reported elsewhere in this thread that "the particular allocation
that usually causes the problem is the pgd_alloc for page tables when
re-enabling the 2nd cpu during resume". On X86, those allocations are using
the flags

GFP_KERNEL | __GFP_NOTRACK | __GFP_REPEAT | __GFP_ZERO

so they should not be trapped in an infinite loop due to __GFP_NOFAIL.
On ARM, they use GFP_KERNEL so should also be ok.

That said, this patch is no longer functionally equivalent to what he
tested so I had to remove the tested-by. Colin, can you retest with the
following patch please? If it gets stuck, it's interesting in itself
because it means we were previously failing __GFP_NOFAIL allocations
during suspend on paths that probably don't handle allocation failure
very well.

David, is this what you meant? This patch includes all the
documentation-related updates that were discussed in this thread as well
as updated the check in mm/swapfile.c for hibernation.

==== CUT HERE ====
mm: avoid livelock on !__GFP_FS allocations v2

Changelog since V1
  o Move PM check to should_alloc_retry (David Rientjes)
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
