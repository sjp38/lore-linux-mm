Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 2BF6E6B0096
	for <linux-mm@kvack.org>; Wed, 21 Nov 2012 05:22:55 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 35/46] mm: numa: Introduce last_nid to the page frame
Date: Wed, 21 Nov 2012 10:21:41 +0000
Message-Id: <1353493312-8069-36-git-send-email-mgorman@suse.de>
In-Reply-To: <1353493312-8069-1-git-send-email-mgorman@suse.de>
References: <1353493312-8069-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Alex Shi <lkml.alex@gmail.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch introduces a last_nid field to the page struct. This is used
to build a two-stage filter in the next patch that is aimed at
mitigating a problem whereby pages migrate to the wrong node when
referenced by a process that was running off its home node.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h       |   30 ++++++++++++++++++++++++++++++
 include/linux/mm_types.h |    4 ++++
 mm/page_alloc.c          |    2 ++
 3 files changed, 36 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index d04c2f0..a0834e1 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -693,6 +693,36 @@ static inline int page_to_nid(const struct page *page)
 }
 #endif
 
+#ifdef CONFIG_BALANCE_NUMA
+static inline int page_xchg_last_nid(struct page *page, int nid)
+{
+	return xchg(&page->_last_nid, nid);
+}
+
+static inline int page_last_nid(struct page *page)
+{
+	return page->_last_nid;
+}
+static inline void reset_page_last_nid(struct page *page)
+{
+	page->_last_nid = -1;
+}
+#else
+static inline int page_xchg_last_nid(struct page *page, int nid)
+{
+	return page_to_nid(page);
+}
+
+static inline int page_last_nid(struct page *page)
+{
+	return page_to_nid(page);
+}
+
+static inline void reset_page_last_nid(struct page *page)
+{
+}
+#endif
+
 static inline struct zone *page_zone(const struct page *page)
 {
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index b40f4ef..6b478ff 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -175,6 +175,10 @@ struct page {
 	 */
 	void *shadow;
 #endif
+
+#ifdef CONFIG_BALANCE_NUMA
+	int _last_nid;
+#endif
 }
 /*
  * The struct page can be forced to be double word aligned so that atomic ops
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index df58654..fd6a073 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -608,6 +608,7 @@ static inline int free_pages_check(struct page *page)
 		bad_page(page);
 		return 1;
 	}
+	reset_page_last_nid(page);
 	if (page->flags & PAGE_FLAGS_CHECK_AT_PREP)
 		page->flags &= ~PAGE_FLAGS_CHECK_AT_PREP;
 	return 0;
@@ -3826,6 +3827,7 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		mminit_verify_page_links(page, zone, nid, pfn);
 		init_page_count(page);
 		reset_page_mapcount(page);
+		reset_page_last_nid(page);
 		SetPageReserved(page);
 		/*
 		 * Mark the block movable so that blocks are reserved for
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
