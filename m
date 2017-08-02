Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 20A546B05AA
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 04:29:19 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id x28so4960022wma.7
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 01:29:19 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 60si26686076wrq.87.2017.08.02.01.29.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 01:29:17 -0700 (PDT)
Date: Wed, 2 Aug 2017 10:29:14 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 1/2] mm, oom: do not rely on TIF_MEMDIE for memory
 reserves access
Message-ID: <20170802082914.GF2524@dhcp22.suse.cz>
References: <20170727090357.3205-1-mhocko@kernel.org>
 <20170727090357.3205-2-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170727090357.3205-2-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guro@fb.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

With the follow up changes based on Tetsuo review. I have dropped
Roman's Tested-by because at least the allocation exit for oom victim
behavior has changed.
---
commit b1cfab26a98d48d69dc106d0e0ab616728b04992
Author: Michal Hocko <mhocko@suse.com>
Date:   Wed Jul 26 16:38:40 2017 +0200

    mm, oom: do not rely on TIF_MEMDIE for memory reserves access
    
    For ages we have been relying on TIF_MEMDIE thread flag to mark OOM
    victims and then, among other things, to give these threads full
    access to memory reserves. There are few shortcomings of this
    implementation, though.
    
    First of all and the most serious one is that the full access to memory
    reserves is quite dangerous because we leave no safety room for the
    system to operate and potentially do last emergency steps to move on.
    
    Secondly this flag is per task_struct while the OOM killer operates
    on mm_struct granularity so all processes sharing the given mm are
    killed. Giving the full access to all these task_structs could lead to
    a quick memory reserves depletion. We have tried to reduce this risk by
    giving TIF_MEMDIE only to the main thread and the currently allocating
    task but that doesn't really solve this problem while it surely opens up
    a room for corner cases - e.g. GFP_NO{FS,IO} requests might loop inside
    the allocator without access to memory reserves because a particular
    thread was not the group leader.
    
    Now that we have the oom reaper and that all oom victims are reapable
    after 1b51e65eab64 ("oom, oom_reaper: allow to reap mm shared by the
    kthreads") we can be more conservative and grant only partial access to
    memory reserves because there are reasonable chances of the parallel
    memory freeing. We still want some access to reserves because we do not
    want other consumers to eat up the victim's freed memory. oom victims
    will still contend with __GFP_HIGH users but those shouldn't be so
    aggressive to starve oom victims completely.
    
    Introduce ALLOC_OOM flag and give all tsk_is_oom_victim tasks access to
    the half of the reserves. This makes the access to reserves independent
    on which task has passed through mark_oom_victim. Also drop any
    usage of TIF_MEMDIE from the page allocator proper and replace it by
    tsk_is_oom_victim as well which will make page_alloc.c completely
    TIF_MEMDIE free finally.
    
    CONFIG_MMU=n doesn't have oom reaper so let's stick to the original
    ALLOC_NO_WATERMARKS approach.
    
    There is a demand to make the oom killer memcg aware which will imply
    many tasks killed at once. This change will allow such a usecase without
    worrying about complete memory reserves depletion.
    
    Changes since v1
    - do not play tricks with nommu and grant access to memory reserves as
      long as TIF_MEMDIE is set
    - break out from allocation properly for oom victims as per Tetsuo
    - distinguish oom victims from other consumers of memory reserves in
      __gfp_pfmemalloc_flags - per Tetsuo
    
    Signed-off-by: Michal Hocko <mhocko@suse.com>

diff --git a/mm/internal.h b/mm/internal.h
index 24d88f084705..1ebcb1ed01b5 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -480,6 +480,17 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 /* Mask to get the watermark bits */
 #define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
 
+/*
+ * Only MMU archs have async oom victim reclaim - aka oom_reaper so we
+ * cannot assume a reduced access to memory reserves is sufficient for
+ * !MMU
+ */
+#ifdef CONFIG_MMU
+#define ALLOC_OOM		0x08
+#else
+#define ALLOC_OOM		ALLOC_NO_WATERMARKS
+#endif
+
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
 #define ALLOC_CPUSET		0x40 /* check for correct cpuset */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f030c1c..c9f3569a76c7 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -824,7 +824,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
-	 * its children or threads, just set TIF_MEMDIE so it can die quickly
+	 * its children or threads, just give it access to memory reserves
+	 * so it can die quickly
 	 */
 	task_lock(p);
 	if (task_will_free_mem(p)) {
@@ -889,9 +890,9 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	count_memcg_event_mm(mm, OOM_KILL);
 
 	/*
-	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
-	 * the OOM victim from depleting the memory reserves from the user
-	 * space under its control.
+	 * We should send SIGKILL before granting access to memory reserves
+	 * in order to prevent the OOM victim from depleting the memory
+	 * reserves from the user space under its control.
 	 */
 	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
 	mark_oom_victim(victim);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 80e4adb4c360..7ae0f6d45614 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2930,7 +2930,7 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 {
 	long min = mark;
 	int o;
-	const bool alloc_harder = (alloc_flags & ALLOC_HARDER);
+	const bool alloc_harder = (alloc_flags & (ALLOC_HARDER|ALLOC_OOM));
 
 	/* free_pages may go negative - that's OK */
 	free_pages -= (1 << order) - 1;
@@ -2943,10 +2943,19 @@ bool __zone_watermark_ok(struct zone *z, unsigned int order, unsigned long mark,
 	 * the high-atomic reserves. This will over-estimate the size of the
 	 * atomic reserve but it avoids a search.
 	 */
-	if (likely(!alloc_harder))
+	if (likely(!alloc_harder)) {
 		free_pages -= z->nr_reserved_highatomic;
-	else
-		min -= min / 4;
+	} else {
+		/*
+		 * OOM victims can try even harder than normal ALLOC_HARDER
+		 * users
+		 */
+		if (alloc_flags & ALLOC_OOM)
+			min -= min / 2;
+		else
+			min -= min / 4;
+	}
+
 
 #ifdef CONFIG_CMA
 	/* If allocation can't use CMA areas don't use free CMA pages */
@@ -3184,7 +3193,7 @@ static void warn_alloc_show_mem(gfp_t gfp_mask, nodemask_t *nodemask)
 	 * of allowed nodes.
 	 */
 	if (!(gfp_mask & __GFP_NOMEMALLOC))
-		if (test_thread_flag(TIF_MEMDIE) ||
+		if (tsk_is_oom_victim(current) ||
 		    (current->flags & (PF_MEMALLOC | PF_EXITING)))
 			filter &= ~SHOW_MEM_FILTER_NODES;
 	if (in_interrupt() || !(gfp_mask & __GFP_DIRECT_RECLAIM))
@@ -3603,21 +3612,46 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
 	return alloc_flags;
 }
 
-bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
+static bool oom_reserves_allowed(struct task_struct *tsk)
 {
-	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
+	if (!tsk_is_oom_victim(tsk))
+		return false;
+
+	/*
+	 * !MMU doesn't have oom reaper so give access to memory reserves
+	 * only to the thread with TIF_MEMDIE set
+	 */
+	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
 		return false;
 
+	return true;
+}
+
+/*
+ * Distinguish requests which really need access to full memory
+ * reserves from oom victims which can live with a portion of it
+ */
+static inline int __gfp_pfmemalloc_flags(gfp_t gfp_mask)
+{
+	if (unlikely(gfp_mask & __GFP_NOMEMALLOC))
+		return 0;
 	if (gfp_mask & __GFP_MEMALLOC)
-		return true;
+		return ALLOC_NO_WATERMARKS;
 	if (in_serving_softirq() && (current->flags & PF_MEMALLOC))
-		return true;
-	if (!in_interrupt() &&
-			((current->flags & PF_MEMALLOC) ||
-			 unlikely(test_thread_flag(TIF_MEMDIE))))
-		return true;
+		return ALLOC_NO_WATERMARKS;
+	if (!in_interrupt()) {
+		if (current->flags & PF_MEMALLOC)
+			return ALLOC_NO_WATERMARKS;
+		else if (oom_reserves_allowed(current))
+			return ALLOC_OOM;
+	}
 
-	return false;
+	return 0;
+}
+
+bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
+{
+	return __gfp_pfmemalloc_flags(gfp_mask) > 0;
 }
 
 /*
@@ -3770,6 +3804,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	unsigned long alloc_start = jiffies;
 	unsigned int stall_timeout = 10 * HZ;
 	unsigned int cpuset_mems_cookie;
+	int reserves;
 
 	/*
 	 * In the slowpath, we sanity check order to avoid ever trying to
@@ -3875,15 +3910,16 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	if (gfp_mask & __GFP_KSWAPD_RECLAIM)
 		wake_all_kswapds(order, ac);
 
-	if (gfp_pfmemalloc_allowed(gfp_mask))
-		alloc_flags = ALLOC_NO_WATERMARKS;
+	reserves = __gfp_pfmemalloc_flags(gfp_mask);
+	if (reserves)
+		alloc_flags = reserves;
 
 	/*
 	 * Reset the zonelist iterators if memory policies can be ignored.
 	 * These allocations are high priority and system rather than user
 	 * orientated.
 	 */
-	if (!(alloc_flags & ALLOC_CPUSET) || (alloc_flags & ALLOC_NO_WATERMARKS)) {
+	if (!(alloc_flags & ALLOC_CPUSET) || reserves) {
 		ac->zonelist = node_zonelist(numa_node_id(), gfp_mask);
 		ac->preferred_zoneref = first_zones_zonelist(ac->zonelist,
 					ac->high_zoneidx, ac->nodemask);
@@ -3960,8 +3996,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto got_pg;
 
 	/* Avoid allocations with no watermarks from looping endlessly */
-	if (test_thread_flag(TIF_MEMDIE) &&
-	    (alloc_flags == ALLOC_NO_WATERMARKS ||
+	if (tsk_is_oom_victim(current) &&
+	    (alloc_flags == ALLOC_OOM ||
 	     (gfp_mask & __GFP_NOMEMALLOC)))
 		goto nopage;
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
