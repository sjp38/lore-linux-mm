Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCEC6B0032
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:34 -0400 (EDT)
Received: by wgyo15 with SMTP id o15so13567892wgy.2
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:34 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p3si31313393wia.63.2015.04.23.03.33.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:23 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/13] mm: meminit: Inline some helper functions
Date: Thu, 23 Apr 2015 11:33:09 +0100
Message-Id: <1429785196-7668-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

early_pfn_in_nid() and meminit_pfn_in_nid() are small functions that are
unnecessarily visible outside memory initialisation. As well as unnecessary
visibility, it's unnecessary function call overhead when initialising pages.
This patch moves the helpers inline.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mmzone.h |  9 ------
 mm/page_alloc.c        | 75 +++++++++++++++++++++++++-------------------------
 2 files changed, 38 insertions(+), 46 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index a67b33e52dfe..e3d8a2bd8d78 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1227,15 +1227,6 @@ struct mminit_pfnnid_cache {
 	int last_nid;
 };
 
-#ifdef CONFIG_NODES_SPAN_OTHER_NODES
-bool early_pfn_in_nid(unsigned long pfn, int nid);
-bool meminit_pfn_in_nid(unsigned long pfn, int node,
-			struct mminit_pfnnid_cache *state);
-#else
-#define early_pfn_in_nid(pfn, nid)		(1)
-#define meminit_pfn_in_nid(pfn, nid, state)	(1)
-#endif
-
 #ifndef early_pfn_valid
 #define early_pfn_valid(pfn)	(1)
 #endif
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f556ed63b964..8b4659aa0bc2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -907,6 +907,44 @@ void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 	__free_pages(page, order);
 }
 
+#if defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID) || \
+        defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP)
+/* Only safe to use early in boot when initialisation is single-threaded */
+struct __meminitdata mminit_pfnnid_cache global_init_state;
+int __meminit early_pfn_to_nid(unsigned long pfn)
+{
+	int nid;
+
+	/* The system will behave unpredictably otherwise */
+	BUG_ON(system_state != SYSTEM_BOOTING);
+
+	nid = __early_pfn_to_nid(pfn, &global_init_state);
+	if (nid >= 0)
+		return nid;
+	/* just returns 0 */
+	return 0;
+}
+#endif
+
+#ifdef CONFIG_NODES_SPAN_OTHER_NODES
+static inline bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
+					struct mminit_pfnnid_cache *state)
+{
+	int nid;
+
+	nid = __early_pfn_to_nid(pfn, state);
+	if (nid >= 0 && nid != node)
+		return false;
+	return true;
+}
+
+/* Only safe to use early in boot when initialisation is single-threaded */
+static inline bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
+{
+	return meminit_pfn_in_nid(pfn, node, &global_init_state);
+}
+#endif
+
 #ifdef CONFIG_CMA
 /* Free whole pageblock and set its migration type to MIGRATE_CMA. */
 void __init init_cma_reserved_pageblock(struct page *page)
@@ -4481,43 +4519,6 @@ int __meminit __early_pfn_to_nid(unsigned long pfn,
 }
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 
-struct __meminitdata mminit_pfnnid_cache global_init_state;
-
-/* Only safe to use early in boot when initialisation is single-threaded */
-int __meminit early_pfn_to_nid(unsigned long pfn)
-{
-	int nid;
-
-	/* The system will behave unpredictably otherwise */
-	BUG_ON(system_state != SYSTEM_BOOTING);
-
-	nid = __early_pfn_to_nid(pfn, &global_init_state);
-	if (nid >= 0)
-		return nid;
-	/* just returns 0 */
-	return 0;
-}
-
-#ifdef CONFIG_NODES_SPAN_OTHER_NODES
-bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
-					struct mminit_pfnnid_cache *state)
-{
-	int nid;
-
-	nid = __early_pfn_to_nid(pfn, state);
-	if (nid >= 0 && nid != node)
-		return false;
-	return true;
-}
-
-/* Only safe to use early in boot when initialisation is single-threaded */
-bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
-{
-	return meminit_pfn_in_nid(pfn, node, &global_init_state);
-}
-
-#endif
-
 /**
  * free_bootmem_with_active_regions - Call memblock_free_early_nid for each active range
  * @nid: The node to free memory on. If MAX_NUMNODES, all nodes are freed.
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
