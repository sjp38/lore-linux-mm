Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0979B6B025E
	for <linux-mm@kvack.org>; Wed, 28 Mar 2018 12:55:52 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id g61-v6so2115261plb.10
        for <linux-mm@kvack.org>; Wed, 28 Mar 2018 09:55:52 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id e2si2706028pgs.556.2018.03.28.09.55.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Mar 2018 09:55:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 07/14] mm/page_alloc: Add hook in page allocation path for encrypted pages
Date: Wed, 28 Mar 2018 19:55:33 +0300
Message-Id: <20180328165540.648-8-kirill.shutemov@linux.intel.com>
In-Reply-To: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
References: <20180328165540.648-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Tom Lendacky <thomas.lendacky@amd.com>
Cc: Dave Hansen <dave.hansen@intel.com>, Kai Huang <kai.huang@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Intel MKTME requires cache flushing when changing encryption KeyID for
a page.

Add prep_encrypted_page() hook for this. We need to pass down KeyID to
it through page allocation path.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/gfp.h |  6 +++++
 mm/compaction.c     |  2 +-
 mm/internal.h       |  2 +-
 mm/page_alloc.c     | 65 ++++++++++++++++++++++++++++-------------------------
 mm/page_isolation.c |  2 +-
 5 files changed, 44 insertions(+), 33 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index d9d45f47447d..aff798de9c97 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -446,6 +446,12 @@ static inline void arch_free_page(struct page *page, int order) { }
 static inline void arch_alloc_page(struct page *page, int order) { }
 #endif
 
+#ifndef prep_encrypted_page
+static inline void prep_encrypted_page(struct page *page, int order, int keyid)
+{
+}
+#endif
+
 struct page *
 __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int keyid,
 		int preferred_nid, nodemask_t *nodemask);
diff --git a/mm/compaction.c b/mm/compaction.c
index 2c8999d027ab..cb69620fdf34 100644
--- a/mm/compaction.c
+++ b/mm/compaction.c
@@ -77,7 +77,7 @@ static void map_pages(struct list_head *list)
 		order = page_private(page);
 		nr_pages = 1 << order;
 
-		post_alloc_hook(page, order, __GFP_MOVABLE);
+		post_alloc_hook(page, order, page_keyid(page), __GFP_MOVABLE);
 		if (order)
 			split_page(page, order);
 
diff --git a/mm/internal.h b/mm/internal.h
index e6bd35182dae..d896c8e67669 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -164,7 +164,7 @@ extern int __isolate_free_page(struct page *page, unsigned int order);
 extern void __free_pages_bootmem(struct page *page, unsigned long pfn,
 					unsigned int order);
 extern void prep_compound_page(struct page *page, unsigned int order);
-extern void post_alloc_hook(struct page *page, unsigned int order,
+extern void post_alloc_hook(struct page *page, unsigned int order, int keyid,
 					gfp_t gfp_flags);
 extern int user_min_free_kbytes;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 229cdab065ca..a5097d9c2a51 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1792,7 +1792,7 @@ static bool check_new_pages(struct page *page, unsigned int order)
 	return false;
 }
 
-inline void post_alloc_hook(struct page *page, unsigned int order,
+inline void post_alloc_hook(struct page *page, unsigned int order, int keyid,
 				gfp_t gfp_flags)
 {
 	set_page_private(page, 0);
@@ -1803,14 +1803,15 @@ inline void post_alloc_hook(struct page *page, unsigned int order,
 	kernel_poison_pages(page, 1 << order, 1);
 	kasan_alloc_pages(page, order);
 	set_page_owner(page, order, gfp_flags);
+	prep_encrypted_page(page, order, keyid);
 }
 
-static void prep_new_page(struct page *page, unsigned int order, gfp_t gfp_flags,
-							unsigned int alloc_flags)
+static void prep_new_page(struct page *page, unsigned int order, int keyid,
+		gfp_t gfp_flags, unsigned int alloc_flags)
 {
 	int i;
 
-	post_alloc_hook(page, order, gfp_flags);
+	post_alloc_hook(page, order, keyid, gfp_flags);
 
 	if (!free_pages_prezeroed() && (gfp_flags & __GFP_ZERO))
 		for (i = 0; i < (1 << order); i++)
@@ -3151,8 +3152,8 @@ static bool zone_allows_reclaim(struct zone *local_zone, struct zone *zone)
  * a page.
  */
 static struct page *
-get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
-						const struct alloc_context *ac)
+get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int keyid,
+		int alloc_flags, const struct alloc_context *ac)
 {
 	struct zoneref *z = ac->preferred_zoneref;
 	struct zone *zone;
@@ -3236,7 +3237,8 @@ get_page_from_freelist(gfp_t gfp_mask, unsigned int order, int alloc_flags,
 		page = rmqueue(ac->preferred_zoneref->zone, zone, order,
 				gfp_mask, alloc_flags, ac->migratetype);
 		if (page) {
-			prep_new_page(page, order, gfp_mask, alloc_flags);
+			prep_new_page(page, order, keyid, gfp_mask,
+					alloc_flags);
 
 			/*
 			 * If this is a high-order atomic allocation then check
@@ -3314,27 +3316,27 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 }
 
 static inline struct page *
-__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_cpuset_fallback(gfp_t gfp_mask, unsigned int order, int keyid,
 			      unsigned int alloc_flags,
 			      const struct alloc_context *ac)
 {
 	struct page *page;
 
-	page = get_page_from_freelist(gfp_mask, order,
+	page = get_page_from_freelist(gfp_mask, order, keyid,
 			alloc_flags|ALLOC_CPUSET, ac);
 	/*
 	 * fallback to ignore cpuset restriction if our nodes
 	 * are depleted
 	 */
 	if (!page)
-		page = get_page_from_freelist(gfp_mask, order,
+		page = get_page_from_freelist(gfp_mask, order, keyid,
 				alloc_flags, ac);
 
 	return page;
 }
 
 static inline struct page *
-__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order, int keyid,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
 	struct oom_control oc = {
@@ -3366,7 +3368,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 	 * allocation which will never fail due to oom_lock already held.
 	 */
 	page = get_page_from_freelist((gfp_mask | __GFP_HARDWALL) &
-				      ~__GFP_DIRECT_RECLAIM, order,
+				      ~__GFP_DIRECT_RECLAIM, order, keyid,
 				      ALLOC_WMARK_HIGH|ALLOC_CPUSET, ac);
 	if (page)
 		goto out;
@@ -3414,7 +3416,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 		 */
 		if (gfp_mask & __GFP_NOFAIL)
 			page = __alloc_pages_cpuset_fallback(gfp_mask, order,
-					ALLOC_NO_WATERMARKS, ac);
+					keyid, ALLOC_NO_WATERMARKS, ac);
 	}
 out:
 	mutex_unlock(&oom_lock);
@@ -3430,7 +3432,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
 #ifdef CONFIG_COMPACTION
 /* Try memory compaction for high-order allocations before reclaim */
 static struct page *
-__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order, int keyid,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
@@ -3454,7 +3456,7 @@ __alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
 	 */
 	count_vm_event(COMPACTSTALL);
 
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, keyid, alloc_flags, ac);
 
 	if (page) {
 		struct zone *zone = page_zone(page);
@@ -3547,7 +3549,7 @@ should_compact_retry(struct alloc_context *ac, int order, int alloc_flags,
 }
 #else
 static inline struct page *
-__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_direct_compact(gfp_t gfp_mask, unsigned int order, int keyid,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		enum compact_priority prio, enum compact_result *compact_result)
 {
@@ -3656,7 +3658,7 @@ __perform_reclaim(gfp_t gfp_mask, unsigned int order,
 
 /* The really slow allocator path where we enter direct reclaim */
 static inline struct page *
-__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order, int keyid,
 		unsigned int alloc_flags, const struct alloc_context *ac,
 		unsigned long *did_some_progress)
 {
@@ -3668,7 +3670,7 @@ __alloc_pages_direct_reclaim(gfp_t gfp_mask, unsigned int order,
 		return NULL;
 
 retry:
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, keyid, alloc_flags, ac);
 
 	/*
 	 * If an allocation failed after direct reclaim, it could be because
@@ -3914,7 +3916,7 @@ check_retry_cpuset(int cpuset_mems_cookie, struct alloc_context *ac)
 }
 
 static inline struct page *
-__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order, int keyid,
 						struct alloc_context *ac)
 {
 	bool can_direct_reclaim = gfp_mask & __GFP_DIRECT_RECLAIM;
@@ -3979,7 +3981,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	 * The adjusted alloc_flags might result in immediate success, so try
 	 * that first
 	 */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, keyid, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
@@ -3996,7 +3998,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 			(costly_order ||
 			   (order > 0 && ac->migratetype != MIGRATE_MOVABLE))
 			&& !gfp_pfmemalloc_allowed(gfp_mask)) {
-		page = __alloc_pages_direct_compact(gfp_mask, order,
+		page = __alloc_pages_direct_compact(gfp_mask, order, keyid,
 						alloc_flags, ac,
 						INIT_COMPACT_PRIORITY,
 						&compact_result);
@@ -4049,7 +4051,7 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 	}
 
 	/* Attempt with potentially adjusted zonelist and alloc_flags */
-	page = get_page_from_freelist(gfp_mask, order, alloc_flags, ac);
+	page = get_page_from_freelist(gfp_mask, order, keyid, alloc_flags, ac);
 	if (page)
 		goto got_pg;
 
@@ -4062,14 +4064,14 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto nopage;
 
 	/* Try direct reclaim and then allocating */
-	page = __alloc_pages_direct_reclaim(gfp_mask, order, alloc_flags, ac,
-							&did_some_progress);
+	page = __alloc_pages_direct_reclaim(gfp_mask, order, keyid, alloc_flags,
+			ac, &did_some_progress);
 	if (page)
 		goto got_pg;
 
 	/* Try direct compaction and then allocating */
-	page = __alloc_pages_direct_compact(gfp_mask, order, alloc_flags, ac,
-					compact_priority, &compact_result);
+	page = __alloc_pages_direct_compact(gfp_mask, order, keyid, alloc_flags,
+			ac, compact_priority, &compact_result);
 	if (page)
 		goto got_pg;
 
@@ -4106,7 +4108,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		goto retry_cpuset;
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, order, keyid,
+			ac, &did_some_progress);
 	if (page)
 		goto got_pg;
 
@@ -4160,7 +4163,8 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int order,
 		 * could deplete whole memory reserves which would just make
 		 * the situation worse
 		 */
-		page = __alloc_pages_cpuset_fallback(gfp_mask, order, ALLOC_HARDER, ac);
+		page = __alloc_pages_cpuset_fallback(gfp_mask, order, keyid,
+				ALLOC_HARDER, ac);
 		if (page)
 			goto got_pg;
 
@@ -4242,7 +4246,8 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int keyid,
 	finalise_ac(gfp_mask, order, &ac);
 
 	/* First allocation attempt */
-	page = get_page_from_freelist(alloc_mask, order, alloc_flags, &ac);
+	page = get_page_from_freelist(alloc_mask, order, keyid,
+			alloc_flags, &ac);
 	if (likely(page))
 		goto out;
 
@@ -4262,7 +4267,7 @@ __alloc_pages_nodemask(gfp_t gfp_mask, unsigned int order, int keyid,
 	if (unlikely(ac.nodemask != nodemask))
 		ac.nodemask = nodemask;
 
-	page = __alloc_pages_slowpath(alloc_mask, order, &ac);
+	page = __alloc_pages_slowpath(alloc_mask, order, keyid, &ac);
 
 out:
 	if (memcg_kmem_enabled() && (gfp_mask & __GFP_ACCOUNT) && page &&
diff --git a/mm/page_isolation.c b/mm/page_isolation.c
index 165ed8117bd1..8bf0f9677093 100644
--- a/mm/page_isolation.c
+++ b/mm/page_isolation.c
@@ -131,7 +131,7 @@ static void unset_migratetype_isolate(struct page *page, unsigned migratetype)
 out:
 	spin_unlock_irqrestore(&zone->lock, flags);
 	if (isolated_page) {
-		post_alloc_hook(page, order, __GFP_MOVABLE);
+		post_alloc_hook(page, order, page_keyid(page), __GFP_MOVABLE);
 		__free_pages(page, order);
 	}
 }
-- 
2.16.2
