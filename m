Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 283B86B0038
	for <linux-mm@kvack.org>; Fri, 25 Nov 2016 13:55:38 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id i131so24255796wmf.3
        for <linux-mm@kvack.org>; Fri, 25 Nov 2016 10:55:38 -0800 (PST)
Received: from mailapp01.imgtec.com (mailapp01.imgtec.com. [195.59.15.196])
        by mx.google.com with ESMTP id y21si15392737wmd.102.2016.11.25.10.55.36
        for <linux-mm@kvack.org>;
        Fri, 25 Nov 2016 10:55:37 -0800 (PST)
From: Paul Burton <paul.burton@imgtec.com>
Subject: [PATCH] mm: page_alloc: Skip over regions of invalid pfns where possible
Date: Fri, 25 Nov 2016 18:55:18 +0000
Message-ID: <20161125185518.29885-1-paul.burton@imgtec.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Paul Burton <paul.burton@imgtec.com>, James Hartley <james.hartley@imgtec.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

When using a sparse memory model memmap_init_zone() when invoked with
the MEMMAP_EARLY context will skip over pages which aren't valid - ie.
which aren't in a populated region of the sparse memory map. However if
the memory map is extremely sparse then it can spend a long time
linearly checking each PFN in a large non-populated region of the memory
map & skipping it in turn.

When CONFIG_HAVE_MEMBLOCK_NODE_MAP is enabled, we have sufficient
information to quickly discover the next valid PFN given an invalid one
by searching through the list of memory regions & skipping forwards to
the first PFN covered by the memory region to the right of the
non-populated region. Implement this in order to speed up
memmap_init_zone() for systems with extremely sparse memory maps.

Signed-off-by: Paul Burton <paul.burton@imgtec.com>
Cc: James Hartley <james.hartley@imgtec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org

---

 include/linux/memblock.h |  1 +
 mm/memblock.c            | 25 +++++++++++++++++++++++++
 mm/page_alloc.c          | 11 ++++++++++-
 3 files changed, 36 insertions(+), 1 deletion(-)

diff --git a/include/linux/memblock.h b/include/linux/memblock.h
index 5b759c9..38bcf00 100644
--- a/include/linux/memblock.h
+++ b/include/linux/memblock.h
@@ -203,6 +203,7 @@ int memblock_search_pfn_nid(unsigned long pfn, unsigned long *start_pfn,
 			    unsigned long  *end_pfn);
 void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
 			  unsigned long *out_end_pfn, int *out_nid);
+unsigned long memblock_next_valid_pfn(unsigned long pfn, unsigned long max_pfn);
 
 /**
  * for_each_mem_pfn_range - early memory pfn range iterator
diff --git a/mm/memblock.c b/mm/memblock.c
index 7608bc3..a476d28 100644
--- a/mm/memblock.c
+++ b/mm/memblock.c
@@ -1105,6 +1105,31 @@ void __init_memblock __next_mem_pfn_range(int *idx, int nid,
 		*out_nid = r->nid;
 }
 
+unsigned long __init_memblock memblock_next_valid_pfn(unsigned long pfn,
+						      unsigned long max_pfn)
+{
+	struct memblock_type *type = &memblock.memory;
+	unsigned int right = type->cnt;
+	unsigned int mid, left = 0;
+	phys_addr_t addr = PFN_PHYS(pfn + 1);
+
+	do {
+		mid = (right + left) / 2;
+
+		if (addr < type->regions[mid].base)
+			right = mid;
+		else if (addr >= (type->regions[mid].base +
+				  type->regions[mid].size))
+			left = mid + 1;
+		else {
+			/* addr is within the region, so pfn + 1 is valid */
+			return min(pfn + 1, max_pfn);
+		}
+	} while (left < right);
+
+	return min(PHYS_PFN(type->regions[right].base), max_pfn);
+}
+
 /**
  * memblock_set_node - set node ID on memblock regions
  * @base: base of area to set node ID for
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 6de9440..f16f1b6 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5013,8 +5013,17 @@ void __meminit memmap_init_zone(unsigned long size, int nid, unsigned long zone,
 		if (context != MEMMAP_EARLY)
 			goto not_early;
 
-		if (!early_pfn_valid(pfn))
+		if (!early_pfn_valid(pfn)) {
+#ifdef CONFIG_HAVE_MEMBLOCK_NODE_MAP
+			/*
+			 * Skip to the pfn preceding the next valid one (or
+			 * end_pfn), such that we hit a valid pfn (or end_pfn)
+			 * on our next iteration of the loop.
+			 */
+			pfn = memblock_next_valid_pfn(pfn, end_pfn) - 1;
+#endif
 			continue;
+		}
 		if (!early_pfn_in_nid(pfn, nid))
 			continue;
 		if (!update_defer_init(pgdat, pfn, end_pfn, &nr_initialised))
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
