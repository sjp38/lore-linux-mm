Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 4E8666B0072
	for <linux-mm@kvack.org>; Mon, 13 Apr 2015 06:17:23 -0400 (EDT)
Received: by wizk4 with SMTP id k4so66080620wiz.1
        for <linux-mm@kvack.org>; Mon, 13 Apr 2015 03:17:23 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id fb2si13273479wib.18.2015.04.13.03.17.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 13 Apr 2015 03:17:15 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 05/14] mm: meminit: Make __early_pfn_to_nid SMP-safe and introduce meminit_pfn_in_nid
Date: Mon, 13 Apr 2015 11:16:57 +0100
Message-Id: <1428920226-18147-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1428920226-18147-1-git-send-email-mgorman@suse.de>
References: <1428920226-18147-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Robin Holt <holt@sgi.com>, Nathan Zimmer <nzimmer@sgi.com>, Daniel Rahn <drahn@suse.com>, Davidlohr Bueso <dbueso@suse.com>, Dave Hansen <dave.hansen@intel.com>, Tom Vaden <tom.vaden@hp.com>, Scott Norton <scott.norton@hp.com>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

__early_pfn_to_nid() in the generic and arch-specific implementations use
static variables to cache recent lookups. Without the cache boot times
are much higher due to the excessive memblock lookups but it assumes that
memory initialisation is single-threaded. Parallel memory initialisation will
break that assumption so this patch makes __early_pfn_to_nid() SMP-safe by
requiring the caller to cache recent search information. early_pfn_to_nid()
keeps the same interface but is only safe to use early in boot due to
the use of a global static variable. meminit_pfn_in_nid() is an SMP-safe
version that callers must maintain their own state for.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 arch/ia64/mm/numa.c    | 19 +++++++------------
 include/linux/mm.h     |  8 ++++++--
 include/linux/mmzone.h | 16 +++++++++++++++-
 mm/page_alloc.c        | 40 +++++++++++++++++++++++++---------------
 4 files changed, 53 insertions(+), 30 deletions(-)

diff --git a/arch/ia64/mm/numa.c b/arch/ia64/mm/numa.c
index ea21d4cad540..aa19b7ac8222 100644
--- a/arch/ia64/mm/numa.c
+++ b/arch/ia64/mm/numa.c
@@ -58,27 +58,22 @@ paddr_to_nid(unsigned long paddr)
  * SPARSEMEM to allocate the SPARSEMEM sectionmap on the NUMA node where
  * the section resides.
  */
-int __meminit __early_pfn_to_nid(unsigned long pfn)
+int __meminit __early_pfn_to_nid(unsigned long pfn,
+					struct mminit_pfnnid_cache *state)
 {
 	int i, section = pfn >> PFN_SECTION_SHIFT, ssec, esec;
-	/*
-	 * NOTE: The following SMP-unsafe globals are only used early in boot
-	 * when the kernel is running single-threaded.
-	 */
-	static int __meminitdata last_ssec, last_esec;
-	static int __meminitdata last_nid;
 
-	if (section >= last_ssec && section < last_esec)
-		return last_nid;
+	if (section >= state->last_start && section < state->last_end)
+		return state->last_nid;
 
 	for (i = 0; i < num_node_memblks; i++) {
 		ssec = node_memblk[i].start_paddr >> PA_SECTION_SHIFT;
 		esec = (node_memblk[i].start_paddr + node_memblk[i].size +
 			((1L << PA_SECTION_SHIFT) - 1)) >> PA_SECTION_SHIFT;
 		if (section >= ssec && section < esec) {
-			last_ssec = ssec;
-			last_esec = esec;
-			last_nid = node_memblk[i].nid;
+			state->last_start = ssec;
+			state->last_end = esec;
+			state->last_nid = node_memblk[i].nid;
 			return node_memblk[i].nid;
 		}
 	}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b6f82a31028a..3a4c9f72c080 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1802,7 +1802,8 @@ extern void sparse_memory_present_with_active_regions(int nid);
 
 #if !defined(CONFIG_HAVE_MEMBLOCK_NODE_MAP) && \
     !defined(CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID)
-static inline int __early_pfn_to_nid(unsigned long pfn)
+static inline int __early_pfn_to_nid(unsigned long pfn,
+					struct mminit_pfnnid_cache *state)
 {
 	return 0;
 }
@@ -1810,7 +1811,10 @@ static inline int __early_pfn_to_nid(unsigned long pfn)
 /* please see mm/page_alloc.c */
 extern int __meminit early_pfn_to_nid(unsigned long pfn);
 /* there is a per-arch backend function. */
-extern int __meminit __early_pfn_to_nid(unsigned long pfn);
+extern int __meminit __early_pfn_to_nid(unsigned long pfn,
+					struct mminit_pfnnid_cache *state);
+bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
+					struct mminit_pfnnid_cache *state);
 #endif
 
 extern void set_dma_reserve(unsigned long new_dma_reserve);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index f279d9c158cd..4ac0037de2f1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1217,10 +1217,24 @@ void sparse_init(void);
 #define sparse_index_init(_sec, _nid)  do {} while (0)
 #endif /* CONFIG_SPARSEMEM */
 
+/*
+ * During memory init memblocks map pfns to nids. The search is expensive and
+ * this caches recent lookups. The implementation of __early_pfn_to_nid
+ * may treat start/end as pfns or sections.
+ */
+struct mminit_pfnnid_cache {
+	unsigned long last_start;
+	unsigned long last_end;
+	int last_nid;
+};
+
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
 bool early_pfn_in_nid(unsigned long pfn, int nid);
+bool meminit_pfn_in_nid(unsigned long pfn, int node,
+			struct mminit_pfnnid_cache *state);
 #else
-#define early_pfn_in_nid(pfn, nid)	(1)
+#define early_pfn_in_nid(pfn, nid)		(1)
+#define meminit_pfn_in_nid(pfn, nid, state)	(1)
 #endif
 
 #ifndef early_pfn_valid
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 0a0e0f280d87..f556ed63b964 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4457,39 +4457,41 @@ int __meminit init_currently_empty_zone(struct zone *zone,
 
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 #ifndef CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID
+
 /*
  * Required by SPARSEMEM. Given a PFN, return what node the PFN is on.
  */
-int __meminit __early_pfn_to_nid(unsigned long pfn)
+int __meminit __early_pfn_to_nid(unsigned long pfn,
+					struct mminit_pfnnid_cache *state)
 {
 	unsigned long start_pfn, end_pfn;
 	int nid;
-	/*
-	 * NOTE: The following SMP-unsafe globals are only used early in boot
-	 * when the kernel is running single-threaded.
-	 */
-	static unsigned long __meminitdata last_start_pfn, last_end_pfn;
-	static int __meminitdata last_nid;
 
-	if (last_start_pfn <= pfn && pfn < last_end_pfn)
-		return last_nid;
+	if (state->last_start <= pfn && pfn < state->last_end)
+		return state->last_nid;
 
 	nid = memblock_search_pfn_nid(pfn, &start_pfn, &end_pfn);
 	if (nid != -1) {
-		last_start_pfn = start_pfn;
-		last_end_pfn = end_pfn;
-		last_nid = nid;
+		state->last_start = start_pfn;
+		state->last_end = end_pfn;
+		state->last_nid = nid;
 	}
 
 	return nid;
 }
 #endif /* CONFIG_HAVE_ARCH_EARLY_PFN_TO_NID */
 
+struct __meminitdata mminit_pfnnid_cache global_init_state;
+
+/* Only safe to use early in boot when initialisation is single-threaded */
 int __meminit early_pfn_to_nid(unsigned long pfn)
 {
 	int nid;
 
-	nid = __early_pfn_to_nid(pfn);
+	/* The system will behave unpredictably otherwise */
+	BUG_ON(system_state != SYSTEM_BOOTING);
+
+	nid = __early_pfn_to_nid(pfn, &global_init_state);
 	if (nid >= 0)
 		return nid;
 	/* just returns 0 */
@@ -4497,15 +4499,23 @@ int __meminit early_pfn_to_nid(unsigned long pfn)
 }
 
 #ifdef CONFIG_NODES_SPAN_OTHER_NODES
-bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
+bool __meminit meminit_pfn_in_nid(unsigned long pfn, int node,
+					struct mminit_pfnnid_cache *state)
 {
 	int nid;
 
-	nid = __early_pfn_to_nid(pfn);
+	nid = __early_pfn_to_nid(pfn, state);
 	if (nid >= 0 && nid != node)
 		return false;
 	return true;
 }
+
+/* Only safe to use early in boot when initialisation is single-threaded */
+bool __meminit early_pfn_in_nid(unsigned long pfn, int node)
+{
+	return meminit_pfn_in_nid(pfn, node, &global_init_state);
+}
+
 #endif
 
 /**
-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
