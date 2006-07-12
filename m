From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Wed, 12 Jul 2006 16:41:42 +0200
Message-Id: <20060712144142.16998.48555.sendpatchset@lappy>
In-Reply-To: <20060712143659.16998.6444.sendpatchset@lappy>
References: <20060712143659.16998.6444.sendpatchset@lappy>
Subject: [PATCH 24/39] mm: pgrep: generic shrinker logic
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

Add a general shrinker that policies can make use of.
The policy defines MM_POLICY_HAS_SHRINKER when it does _NOT_ want
to make use of this framework.

API:

Return the number of pages in the scanlist for this zone.

	unsigned long __pgrep_nr_scan(struct zone *);

Fill the @list with at most @nr pages from @zone.

	void pgrep_get_candidates(struct zone *, int, unsigned long, 
                                  struct list_head *, unsigned long *);

Reinsert @list into @zone where @nr pages were freed - reinsert those 
pages that could not be freed.

	void pgrep_put_candidates(struct zone *, struct list_head *,
                                  unsigned long, int);

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
Signed-off-by: Marcelo Tosatti <marcelo.tosatti@cyclades.com>

 include/linux/mm_page_replace.h    |    7 ++++
 include/linux/mm_use_once_policy.h |    2 +
 mm/vmscan.c                        |   60 +++++++++++++++++++++++++++++++++++++
 3 files changed, 69 insertions(+)

Index: linux-2.6/include/linux/mm_page_replace.h
===================================================================
--- linux-2.6.orig/include/linux/mm_page_replace.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_page_replace.h	2006-07-12 16:11:29.000000000 +0200
@@ -114,5 +114,12 @@ static inline void pgrep_add_drain(void)
 	put_cpu();
 }
 
+#if ! defined MM_POLICY_HAS_SHRINKER
+/* unsigned long __pgrep_nr_scan(struct zone *); */
+void __pgrep_get_candidates(struct zone *, int, unsigned long, struct list_head *,
+		unsigned long *);
+void pgrep_put_candidates(struct zone *, struct list_head *, unsigned long, int);
+#endif
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_PAGE_REPLACE_H */
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/mm/vmscan.c	2006-07-12 16:09:19.000000000 +0200
@@ -592,6 +592,66 @@ int should_reclaim_mapped(struct zone *z
 	return 0;
 }
 
+#if ! defined MM_POLICY_HAS_SHRINKER
+unsigned long pgrep_shrink_zone(int priority, struct zone *zone,
+		struct scan_control *sc)
+{
+	unsigned long nr_reclaimed = 0;
+	unsigned long nr_scan = 0;
+
+	atomic_inc(&zone->reclaim_in_progress);
+
+	if (unlikely(sc->swap_cluster_max > SWAP_CLUSTER_MAX)) {
+		nr_scan = zone->policy.nr_scan;
+		zone->policy.nr_scan =
+			sc->swap_cluster_max + SWAP_CLUSTER_MAX - 1;
+	} else
+		zone->policy.nr_scan +=
+			(__pgrep_nr_scan(zone) >> priority) + 1;
+
+	while (zone->policy.nr_scan >= SWAP_CLUSTER_MAX) {
+		LIST_HEAD(page_list);
+		unsigned long nr_scan, nr_freed;
+
+		zone->policy.nr_scan -= SWAP_CLUSTER_MAX;
+
+		pgrep_add_drain();
+		spin_lock_irq(&zone->lru_lock);
+
+		__pgrep_get_candidates(zone, priority, SWAP_CLUSTER_MAX,
+				&page_list, &nr_scan);
+
+		spin_unlock(&zone->lru_lock);
+		if (current_is_kswapd())
+			__mod_page_state_zone(zone, pgscan_kswapd, nr_scan);
+		else
+			__mod_page_state_zone(zone, pgscan_direct, nr_scan);
+		local_irq_enable();
+
+		if (list_empty(&page_list))
+			continue;
+
+		nr_freed = shrink_page_list(&page_list, sc);
+		nr_reclaimed += nr_freed;
+
+		local_irq_disable();
+		if (current_is_kswapd())
+			__mod_page_state(kswapd_steal, nr_freed);
+		__mod_page_state_zone(zone, pgsteal, nr_freed);
+		local_irq_enable();
+
+		pgrep_put_candidates(zone, &page_list, nr_freed, sc->may_swap);
+	}
+	if (nr_scan)
+		zone->policy.nr_scan = nr_scan;
+
+	atomic_dec(&zone->reclaim_in_progress);
+
+	throttle_vm_writeout();
+	return nr_reclaimed;
+}
+#endif
+
 /*
  * This is the direct reclaim path, for page-allocating processes.  We only
  * try to reclaim pages from zones which will satisfy the caller's allocation
Index: linux-2.6/include/linux/mm_use_once_policy.h
===================================================================
--- linux-2.6.orig/include/linux/mm_use_once_policy.h	2006-07-12 16:09:19.000000000 +0200
+++ linux-2.6/include/linux/mm_use_once_policy.h	2006-07-12 16:11:31.000000000 +0200
@@ -173,5 +173,7 @@ static inline unsigned long __pgrep_nr_p
 	return zone->policy.nr_active + zone->policy.nr_inactive;
 }
 
+#define MM_POLICY_HAS_SHRINKER
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_USEONCE_POLICY_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
