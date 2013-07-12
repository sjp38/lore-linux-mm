Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 5810C6B0033
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 22:04:07 -0400 (EDT)
From: Robin Holt <holt@sgi.com>
Subject: [RFC 1/4] memblock: Introduce a for_each_reserved_mem_region iterator.
Date: Thu, 11 Jul 2013 21:03:52 -0500
Message-Id: <1373594635-131067-2-git-send-email-holt@sgi.com>
In-Reply-To: <1373594635-131067-1-git-send-email-holt@sgi.com>
References: <1373594635-131067-1-git-send-email-holt@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>
Cc: Robin Holt <holt@sgi.com>, Nate Zimmer <nzimmer@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Rob Landley <rob@landley.net>, Mike Travis <travis@sgi.com>, Daniel J Blueman <daniel@numascale-asia.com>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@linuxfoundation.org>, Yinghai Lu <yinghai@kernel.org>, Mel Gorman <mgorman@suse.de>

As part of initializing struct page's in 2MiB chunks, we noticed that
at the end of free_all_bootmem(), there was nothing which had forced
the reserved/allocated 4KiB pages to be initialized.

This helper function will be used for that expansion.

Signed-off-by: Robin Holt <holt@sgi.com>
Signed-off-by: Nate Zimmer <nzimmer@sgi.com>
To: "H. Peter Anvin" <hpa@zytor.com>
To: Ingo Molnar <mingo@kernel.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: Linux MM <linux-mm@kvack.org>
Cc: Rob Landley <rob@landley.net>
Cc: Mike Travis <travis@sgi.com>
Cc: Daniel J Blueman <daniel@numascale-asia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg KH <gregkh@linuxfoundation.org>
Cc: Yinghai Lu <yinghai@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>
---
 include/linux/memblock.h | 18 ++++++++++++++++++
 mm/memblock.c            | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index f388203..e99bbd1 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -118,6 +118,24 @@ void __next_free_mem_range_rev(u64 *idx, int nid, phys_addr_t *out_start,
 	     i != (u64)ULLONG_MAX;					\
 	     __next_free_mem_range_rev(&i, nid, p_start, p_end, p_nid))
 
+void __next_reserved_mem_region(u64 *idx, phys_addr_t *out_start,
+			       phys_addr_t *out_end);
+
+/**
+ * for_earch_reserved_mem_region - iterate over all reserved memblock areas
+ * @i: u64 used as loop variable
+ * @p_start: ptr to phys_addr_t for start address of the range, can be %NULL
+ * @p_end: ptr to phys_addr_t for end address of the range, can be %NULL
+ *
+ * Walks over reserved areas of memblock in. Available as soon as memblock
+ * is initialized.
+ */
+#define for_each_reserved_mem_region(i, p_start, p_end)			\
+	for (i = 0UL,							\
+	     __next_reserved_mem_region(&i, p_start, p_end);		\
+	     i != (u64)ULLONG_MAX;					\
+	     __next_reserved_mem_region(&i, p_start, p_end))
+
 #ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
 int memblock_set_node(phys_addr_t base, phys_addr_t size, int nid);
 
diff --git a/mm/memblock.c b/mm/memblock.c
index c5fad93..0d7d6e7 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -564,6 +564,38 @@ int __init_memblock memblock_reserve(phys_addr_t base, phys_addr_t size)
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
  * __next_free_mem_range - next function for for_each_free_mem_range()
  * @idx: pointer to u64 loop variable
  * @nid: nid: node selector, %MAX_NUMNODES for all nodes
-- 
1.8.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
