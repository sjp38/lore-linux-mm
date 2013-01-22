Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 108836B0010
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 12:12:44 -0500 (EST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 5/6] mm: Fold page->_last_nid into page->flags where possible
Date: Tue, 22 Jan 2013 17:12:41 +0000
Message-Id: <1358874762-19717-6-git-send-email-mgorman@suse.de>
In-Reply-To: <1358874762-19717-1-git-send-email-mgorman@suse.de>
References: <1358874762-19717-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@kernel.org>, Simon Jeons <simon.jeons@gmail.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

page->_last_nid fits into page->flags on 64-bit. The unlikely 32-bit NUMA
configuration with NUMA Balancing will still need an extra page field.
As Peter notes "Completely dropping 32bit support for CONFIG_NUMA_BALANCING
would simplify things, but it would also remove the warning if we grow
enough 64bit only page-flags to push the last-cpu out."

[mgorman@suse.de: Minor modifications]
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/mm.h                |   33 ++++++++++++++++++++++++++++++++-
 include/linux/mm_types.h          |    2 +-
 include/linux/page-flags-layout.h |   33 +++++++++++++++++++++++++--------
 mm/memory.c                       |    4 ++++
 4 files changed, 62 insertions(+), 10 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 87420e6..e25d47f 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -580,10 +580,11 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
  * sets it, so none of the operations on it need to be atomic.
  */
 
-/* Page flags: | [SECTION] | [NODE] | ZONE | ... | FLAGS | */
+/* Page flags: | [SECTION] | [NODE] | ZONE | [LAST_NID] | ... | FLAGS | */
 #define SECTIONS_PGOFF		((sizeof(unsigned long)*8) - SECTIONS_WIDTH)
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
+#define LAST_NID_PGOFF		(ZONES_PGOFF - LAST_NID_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -593,6 +594,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define SECTIONS_PGSHIFT	(SECTIONS_PGOFF * (SECTIONS_WIDTH != 0))
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
+#define LAST_NID_PGSHIFT	(LAST_NID_PGOFF * (LAST_NID_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -614,6 +616,7 @@ static inline pte_t maybe_mkwrite(pte_t pte, struct vm_area_struct *vma)
 #define ZONES_MASK		((1UL << ZONES_WIDTH) - 1)
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
+#define LAST_NID_MASK		((1UL << LAST_NID_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -653,6 +656,7 @@ static inline int page_to_nid(const struct page *page)
 #endif
 
 #ifdef CONFIG_NUMA_BALANCING
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
 static inline int page_xchg_last_nid(struct page *page, int nid)
 {
 	return xchg(&page->_last_nid, nid);
@@ -667,6 +671,33 @@ static inline void reset_page_last_nid(struct page *page)
 	page->_last_nid = -1;
 }
 #else
+static inline int page_last_nid(struct page *page)
+{
+	return (page->flags >> LAST_NID_PGSHIFT) & LAST_NID_MASK;
+}
+
+static inline int page_xchg_last_nid(struct page *page, int nid)
+{
+	unsigned long old_flags, flags;
+	int last_nid;
+
+	do {
+		old_flags = flags = page->flags;
+		last_nid = page_last_nid(page);
+
+		flags &= ~(LAST_NID_MASK << LAST_NID_PGSHIFT);
+		flags |= (nid & LAST_NID_MASK) << LAST_NID_PGSHIFT;
+	} while (unlikely(cmpxchg(&page->flags, old_flags, flags) != old_flags));
+
+	return last_nid;
+}
+
+static inline void reset_page_last_nid(struct page *page)
+{
+	page_xchg_last_nid(page, (1 << LAST_NID_SHIFT) - 1);
+}
+#endif /* LAST_NID_NOT_IN_PAGE_FLAGS */
+#else
 static inline int page_xchg_last_nid(struct page *page, int nid)
 {
 	return page_to_nid(page);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d05d632..ace9a5f 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -174,7 +174,7 @@ struct page {
 	void *shadow;
 #endif
 
-#ifdef CONFIG_NUMA_BALANCING
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
 	int _last_nid;
 #endif
 }
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index 316805d..93506a1 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -32,15 +32,16 @@
 /*
  * page->flags layout:
  *
- * There are three possibilities for how page->flags get
- * laid out.  The first is for the normal case, without
- * sparsemem.  The second is for sparsemem when there is
- * plenty of space for node and section.  The last is when
- * we have run out of space and have to fall back to an
- * alternate (slower) way of determining the node.
+ * There are five possibilities for how page->flags get laid out.  The first
+ * pair is for the normal case without sparsemem. The second pair is for
+ * sparsemem when there is plenty of space for node and section information.
+ * The last is when there is insufficient space in page->flags and a separate
+ * lookup is necessary.
  *
- * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE | ... | FLAGS |
- * classic sparse with space for node:| SECTION | NODE | ZONE | ... | FLAGS |
+ * No sparsemem or sparsemem vmemmap: |       NODE     | ZONE |          ... | FLAGS |
+ *         " plus space for last_nid: |       NODE     | ZONE | LAST_NID ... | FLAGS |
+ * classic sparse with space for node:| SECTION | NODE | ZONE |          ... | FLAGS |
+ *         " plus space for last_nid: | SECTION | NODE | ZONE | LAST_NID ... | FLAGS |
  * classic sparse no space for node:  | SECTION |     ZONE    | ... | FLAGS |
  */
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
@@ -60,6 +61,18 @@
 #define NODES_WIDTH		0
 #endif
 
+#ifdef CONFIG_NUMA_BALANCING
+#define LAST_NID_SHIFT NODES_SHIFT
+#else
+#define LAST_NID_SHIFT 0
+#endif
+
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_NID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#define LAST_NID_WIDTH LAST_NID_SHIFT
+#else
+#define LAST_NID_WIDTH 0
+#endif
+
 /*
  * We are going to use the flags for the page to node mapping if its in
  * there.  This includes the case where there is no node, so it is implicit.
@@ -68,4 +81,8 @@
 #define NODE_NOT_IN_PAGE_FLAGS
 #endif
 
+#if defined(CONFIG_NUMA_BALANCING) && LAST_NID_WIDTH == 0
+#define LAST_NID_NOT_IN_PAGE_FLAGS
+#endif
+
 #endif /* _LINUX_PAGE_FLAGS_LAYOUT */
diff --git a/mm/memory.c b/mm/memory.c
index bb1369f..16e697c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -69,6 +69,10 @@
 
 #include "internal.h"
 
+#ifdef LAST_NID_NOT_IN_PAGE_FLAGS
+#warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_nid.
+#endif
+
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 /* use the per-pgdat data instead for discontigmem - mbligh */
 unsigned long max_mapnr;
-- 
1.7.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
