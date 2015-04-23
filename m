Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 9E8846B006E
	for <linux-mm@kvack.org>; Thu, 23 Apr 2015 06:33:22 -0400 (EDT)
Received: by widdi4 with SMTP id di4so210319982wid.0
        for <linux-mm@kvack.org>; Thu, 23 Apr 2015 03:33:22 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id lc2si13038713wjb.150.2015.04.23.03.33.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 23 Apr 2015 03:33:19 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 01/13] memblock: Introduce a for_each_reserved_mem_region iterator.
Date: Thu, 23 Apr 2015 11:33:04 +0100
Message-Id: <1429785196-7668-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1429785196-7668-1-git-send-email-mgorman@suse.de>
References: <1429785196-7668-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Nathan Zimmer <nzimmer@sgi.com>, Dave Hansen <dave.hansen@intel.com>, Waiman Long <waiman.long@hp.com>, Scott Norton <scott.norton@hp.com>, Daniel J Blueman <daniel@numascale.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

From: Robin Holt <holt@sgi.com>

As part of initializing struct page's in 2MiB chunks, we noticed that
at the end of free_all_bootmem(), there was nothing which had forced
the reserved/allocated 4KiB pages to be initialized.

This helper function will be used for that expansion.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nate Zimmer <nzimmer@sgi.com>
Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 include/linux/memblock.h | 18 ++++++++++++++++++
 mm/memblock.c            | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index e8cc45307f8f..3075e7673c54 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -93,6 +93,9 @@ void __next_mem_range_rev(u64 *idx, int nid, struct memblock_type *type_a,
 			  struct memblock_type *type_b, phys_addr_t *out_start,
 			  phys_addr_t *out_end, int *out_nid);
 
+void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
+			       phys_addr_t *out_end);
+
 /**
  * for_each_mem_range - iterate through memblock areas from type_a and not
  * included in type_b. Or just type_a if type_b is NULL.
@@ -132,6 +135,21 @@ void __next_mem_range_rev(u64 *idx, int nid, struct memblock_type *type_a,
 	     __next_mem_range_rev(&i, nid, type_a, type_b,		\
 				  p_start, p_end, p_nid))
 
+/**
+ * for_each_reserved_mem_region - iterate over all reserved memblock areas
+ * @i: u64 used as loop variable
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over reserved areas of memblock. Available as soon as memblock
+ * is initialized.
+ */
+#define for_each_reserved_mem_region(i, p_start, p_end)			\
+	for (i = 0UL,							\
+	     __next_reserved_mem_region(&i, p_start, p_end);		\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_reserved_mem_region(&i, p_start, p_end))
+
 #ifdef CONFIG_MOVABLE_NODE
 static inline bool memblock_is_hotpluggable(struct memblock_region *m)
 {
diff --git a/mm/memblock.c b/mm/memblock.c
index 252b77bdf65e..e0cc2d174f74 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -765,6 +765,38 @@ int __init_memblock memblock_clear_hotplug(phys_addr_t base, phys_addr_t size)
 }
 
 /**
+ * __next_reserved_mem_region - next function for for_each_reserved_region()
+ * @idx: pointer to u64 loop variable
+ * @out_start: ptr to phys_addr_t for start address of the region, can be %NULL
+ * @out_end: ptr to phys_addr_t for end address of the region, can be %NULL
+ *
+ * Iterate over all reserved memory regions.
+ */
+void __init_memblock __next_reserved_mem_region(u64 *idx,
+					   phys_addr_t *out_start,
+					   phys_addr_t *out_end)
+{
+	struct memblock_type *rsv = &memblock.reserved;
+
+	if (*idx >= 0 && *idx < rsv->cnt) {
+		struct memblock_region *r = &rsv->regions[*idx];
+		phys_addr_t base = r->base;
+		phys_addr_t size = r->size;
+
+		if (out_start)
+			*out_start = base;
+		if (out_end)
+			*out_end = base + size - 1;
+
+		*idx += 1;
+		return;
+	}
+
+	/* signal end of iteration */
+	*idx = ULLONG_MAX;
+}
+
+/**
  * __next__mem_range - next function for for_each_free_mem_range() etc.
  * @idx: pointer to u64 loop variable
  * @nid: node selector, %NUMA_NO_NODE for all nodes
-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
