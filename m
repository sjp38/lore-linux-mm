Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 36A506B003D
	for <linux-mm@kvack.org>; Tue,  5 May 2009 04:29:23 -0400 (EDT)
Date: Tue, 5 May 2009 09:29:44 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH] Double check memmap is actually valid with a memmap has
	unexpected holes
Message-ID: <20090505082944.GA25904@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, hartleys@visionengravers.com, mcrapet@gmail.com, linux@arm.linux.org.uk, fred99@carolina.rr.com, linux-arm-kernel@lists.arm.linux.org.uk
List-ID: <linux-mm.kvack.org>

pfn_valid() is meant to be able to tell if a given PFN has valid memmap
associated with it or not. In FLATMEM, it is expected that holes always
have valid memmap as long as there is valid PFNs either side of the hole.
In SPARSEMEM, it is assumed that a valid section has a memmap for the
entire section.

However, ARM and maybe other embedded architectures in the future free
memmap backing holes to save memory on the assumption the memmap is never
used. The page_zone() linkages are then broken even though pfn_valid()
returns true. A walker of the full memmap in this case must do additional
check to ensure the memmap they are looking at is sane by making sure the
zone and PFN linkages are still valid. This is expensive, but walkers of
the full memmap are extremely rare.

This was caught before for FLATMEM and hacked around but it hits again
for SPARSEMEM because the page_zone() linkages can look ok where the PFN
linkages are totally screwed. This looks like a hatchet job but the reality
is that any clean solution would end up consuming all the memory saved
by punching these unexpected holes in the memmap. For example, we tried
marking the memmap within the section invalid but the section size exceeds
the size of the hole in most cases so pfn_valid() starts returning false
where valid memmap exists. Shrinking the size of the section would increase
memory consumption offsetting the gains.

This patch identifies when an architecture is punching unexpected holes
in the memmap that the memory model cannot automatically detect. When set,
walkers of the full memmap must call memmap_valid_within() for each PFN and
passing in what it expects the page and zone to be for that PFN. If it finds
the linkages to be broken, it assumes the memmap is invalid for that PFN.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
--- 
 arch/arm/Kconfig       |    3 +--
 include/linux/mmzone.h |   26 ++++++++++++++++++++++++++
 mm/mmzone.c            |   15 +++++++++++++++
 mm/vmstat.c            |   19 ++++---------------
 4 files changed, 46 insertions(+), 17 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index e02b893..6d79051 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -925,10 +925,9 @@ config OABI_COMPAT
 	  UNPREDICTABLE (in fact it can be predicted that it won't work
 	  at all). If in doubt say Y.
 
-config ARCH_FLATMEM_HAS_HOLES
+config ARCH_HAS_HOLES_MEMORYMODEL
 	bool
 	default y
-	depends on FLATMEM
 
 # Discontigmem is deprecated
 config ARCH_DISCONTIGMEM_ENABLE
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 1ff59fd..d20513a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1104,6 +1104,32 @@ unsigned long __init node_memmap_size_bytes(int, unsigned long, unsigned long);
 #define pfn_valid_within(pfn) (1)
 #endif
 
+#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
+/*
+ * pfn_valid() is meant to be able to tell if a given PFN has valid memmap
+ * associated with it or not. In FLATMEM, it is expected that holes always
+ * have valid memmap as long as there is valid PFNs either side of the hole.
+ * In SPARSEMEM, it is assumed that a valid section has a memmap for the
+ * entire section.
+ *
+ * However, an ARM, and maybe other embedded architectures in the future
+ * free memmap backing holes to save memory on the assumption the memmap is
+ * never used. The page_zone linkages are then broken even though pfn_valid()
+ * returns true. A walker of the full memmap must then do this additional
+ * check to ensure the memmap they are looking at is sane by making sure
+ * the zone and PFN linkages are still valid. This is expensive, but walkers
+ * of the full memmap are extremely rare.
+ */
+int memmap_valid_within(unsigned long pfn,
+					struct page *page, struct zone *zone);
+#else
+static inline int memmap_valid_within(unsigned long pfn,
+					struct page *page, struct zone *zone)
+{
+	return 1;
+}
+#endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
+
 #endif /* !__GENERATING_BOUNDS.H */
 #endif /* !__ASSEMBLY__ */
 #endif /* _LINUX_MMZONE_H */
diff --git a/mm/mmzone.c b/mm/mmzone.c
index 16ce8b9..f5b7d17 100644
--- a/mm/mmzone.c
+++ b/mm/mmzone.c
@@ -6,6 +6,7 @@
 
 
 #include <linux/stddef.h>
+#include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/module.h>
 
@@ -72,3 +73,17 @@ struct zoneref *next_zones_zonelist(struct zoneref *z,
 	*zone = zonelist_zone(z);
 	return z;
 }
+
+#ifdef CONFIG_ARCH_HAS_HOLES_MEMORYMODEL
+int memmap_valid_within(unsigned long pfn,
+					struct page *page, struct zone *zone)
+{
+	if (page_to_pfn(page) != pfn)
+		return 0;
+
+	if (page_zone(page) != zone)
+		return 0;
+
+	return 1;
+}
+#endif /* CONFIG_ARCH_HAS_HOLES_MEMORYMODEL */
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 17f2abb..03ee651 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -509,22 +509,11 @@ static void pagetypeinfo_showblockcount_print(struct seq_file *m,
 			continue;
 
 		page = pfn_to_page(pfn);
-#ifdef CONFIG_ARCH_FLATMEM_HAS_HOLES
-		/*
-		 * Ordinarily, memory holes in flatmem still have a valid
-		 * memmap for the PFN range. However, an architecture for
-		 * embedded systems (e.g. ARM) can free up the memmap backing
-		 * holes to save memory on the assumption the memmap is
-		 * never used. The page_zone linkages are then broken even
-		 * though pfn_valid() returns true. Skip the page if the
-		 * linkages are broken. Even if this test passed, the impact
-		 * is that the counters for the movable type are off but
-		 * fragmentation monitoring is likely meaningless on small
-		 * systems.
-		 */
-		if (page_zone(page) != zone)
+
+		/* Watch for unexpected holes punched in the memmap */
+		if (!memmap_valid_within(pfn, page, zone))
 			continue;
-#endif
+
 		mtype = get_pageblock_migratetype(page);
 
 		if (mtype < MIGRATE_TYPES)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
