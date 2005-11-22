Date: Tue, 22 Nov 2005 18:07:34 +0000
Subject: [PATCH 1/2] flatmem split out memory model
Message-ID: <20051122180734.GA10849@shadowen.org>
References: <exportbomb.1132682844@pinky>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
From: Andy Whitcroft <apw@shadowen.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, kravetz@us.ibm.com, anton@samba.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

pfn_to_nid is memory model specific

The pfn_to_nid() call is memory model specific.  It represents the
locality identifier for the memory passed.  Classically this would
be a NUMA node, but not a chunk of memory under DISCONTIGMEM.

The SPARSEMEM and FLATMEM memory model non-NUMA versions of
pfn_to_nid() are folded together under NEED_MULTIPLE_NODES, while
DISCONTIGMEM has its own optimisation.  This is all very confusing.

This patch splits out each implementation of pfn_to_nid() so that we
can see them and the optimisations to each.

Signed-off-by: Andy Whitcroft <apw@shadowen.org>
---
 mmzone.h |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletion(-)
diff -upN reference/include/linux/mmzone.h current/include/linux/mmzone.h
--- reference/include/linux/mmzone.h
+++ current/include/linux/mmzone.h
@@ -445,7 +445,6 @@ extern struct pglist_data contig_page_da
 #define NODE_DATA(nid)		(&contig_page_data)
 #define NODE_MEM_MAP(nid)	mem_map
 #define MAX_NODES_SHIFT		1
-#define pfn_to_nid(pfn)		(0)
 
 #else /* CONFIG_NEED_MULTIPLE_NODES */
 
@@ -480,6 +479,10 @@ extern struct pglist_data contig_page_da
 #define early_pfn_to_nid(nid)  (0UL)
 #endif
 
+#ifdef CONFIG_FLATMEM
+#define pfn_to_nid(pfn)		(0)
+#endif
+
 #define pfn_to_section_nr(pfn) ((pfn) >> PFN_SECTION_SHIFT)
 #define section_nr_to_pfn(sec) ((sec) << PFN_SECTION_SHIFT)
 
@@ -604,6 +607,8 @@ static inline int pfn_valid(unsigned lon
  */
 #ifdef CONFIG_NUMA
 #define pfn_to_nid		early_pfn_to_nid
+#else
+#define pfn_to_nid(pfn)		(0)
 #endif
 
 #define early_pfn_valid(pfn)	pfn_valid(pfn)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
