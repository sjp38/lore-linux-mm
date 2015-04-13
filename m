Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f41.google.com (mail-wg0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id D62C26B0074
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:25 -0400 (EDT)
Received: by wgso17 with SMTP id o17so75477291wgs.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ey9si13255410wid.37.2015.04.13.03.17.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:16 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 06/14] mm: meminit: Inline some helper functions
Date: Mon, 13 Apr 2015 11:16:58 +0100
Message-Id: <1428920226-18147-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

early_pfn_in_nid() and meminit_pfn_in_nid() are small functions that are
unnecessarily visible outside memory initialisation. As well as unnecessary
visibility, it's unnecessary function call overhead when initialising pages.
This patch moves the helpers inline.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h     |  2 --
 include/linux/mmzone.h |  9 -------
 mm/page_alloc.c        | 72 ++++++++++++++++++++++++--------------------------
 3 files changed, 35 insertions(+), 48 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3a4c9f72c080..a8a8b161fd65 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1813,8 +1813,6 @@ extern int __meminit early_pfn_to_nid(unsigned long pfn);
 /* there is a per-arch backend function. */
 extern int __meminit __early_pfn_to_nid(unsigned long pfn,
 					struct mminit_pfnnid_cache *state);
-bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
-					struct mminit_pfnnid_cache *state);
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 4ac0037de2f1..c75df05dc8e8 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1228,15 +1228,6 @@ struct mminit_pfnnid_cache {
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
index f556ed63b964..cadf37c09e6b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -907,6 +907,41 @@ void __init __free_pages_bootmem(struct page *page, unsigned long pfn,
 	__free_pages(page, order);
 }
 
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
@@ -4481,43 +4516,6 @@ int __meminit __early_pfn_to_nid(unsigned long pfn,
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
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
