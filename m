Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B8826B04C9
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 08:03:49 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w27so734281pfi.9
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 05:03:49 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id u91si986989plb.1010.2017.08.23.05.03.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 05:03:47 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 01/19] mm/sparsemem: Allocate mem_section at runtime for SPARSEMEM_EXTREME
Date: Wed, 23 Aug 2017 15:03:14 +0300
Message-Id: <20170823120332.2288-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
References: <20170823120332.2288-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Size of mem_section array depends on size of physical address space.

In preparation for boot-time switching between paging modes on x86-64
we need to make allocation of mem_section dynamic.

The patch allocates the array on the first call to
sparse_memory_present_with_active_regions().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mmzone.h |  6 +++++-
 mm/page_alloc.c        | 10 ++++++++++
 mm/sparse.c            | 17 +++++++++++------
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index fc14b8b3f6ce..9c6c001a8c6c 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1137,13 +1137,17 @@ struct mem_section {
 #define SECTION_ROOT_MASK	(SECTIONS_PER_ROOT - 1)
 
 #ifdef CONFIG_SPARSEMEM_EXTREME
-extern struct mem_section *mem_section[NR_SECTION_ROOTS];
+extern struct mem_section **mem_section;
 #else
 extern struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT];
 #endif
 
 static inline struct mem_section *__nr_to_section(unsigned long nr)
 {
+#ifdef CONFIG_SPARSEMEM_EXTREME
+	if (!mem_section)
+		return NULL;
+#endif
 	if (!mem_section[SECTION_NR_TO_ROOT(nr)])
 		return NULL;
 	return &mem_section[SECTION_NR_TO_ROOT(nr)][nr & SECTION_ROOT_MASK];
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 471b0526b876..87cd173bc83e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5731,6 +5731,16 @@ void __init sparse_memory_present_with_active_regions(int nid)
 	unsigned long start_pfn, end_pfn;
 	int i, this_nid;
 
+#ifdef CONFIG_SPARSEMEM_EXTREME
+	if (!mem_section) {
+		unsigned long size, align;
+
+		size = sizeof(struct mem_section) * NR_SECTION_ROOTS;
+		align = 1 << (INTERNODE_CACHE_SHIFT);
+		mem_section = memblock_virt_alloc(size, align);
+	}
+#endif
+
 	for_each_mem_pfn_range(i, nid, &start_pfn, &end_pfn, &this_nid)
 		memory_present(this_nid, start_pfn, end_pfn);
 }
diff --git a/mm/sparse.c b/mm/sparse.c
index 7b4be3fd5cac..79407b6ca9f8 100644
--- a/mm/sparse.c
+++ b/mm/sparse.c
@@ -22,8 +22,7 @@
  * 1) mem_section	- memory sections, mem_map's for valid memory
  */
 #ifdef CONFIG_SPARSEMEM_EXTREME
-struct mem_section *mem_section[NR_SECTION_ROOTS]
-	____cacheline_internodealigned_in_smp;
+struct mem_section **mem_section;
 #else
 struct mem_section mem_section[NR_SECTION_ROOTS][SECTIONS_PER_ROOT]
 	____cacheline_internodealigned_in_smp;
@@ -104,7 +103,7 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
 int __section_nr(struct mem_section* ms)
 {
 	unsigned long root_nr;
-	struct mem_section* root;
+	struct mem_section *root = NULL;
 
 	for (root_nr = 0; root_nr < NR_SECTION_ROOTS; root_nr++) {
 		root = __nr_to_section(root_nr * SECTIONS_PER_ROOT);
@@ -115,7 +114,7 @@ int __section_nr(struct mem_section* ms)
 		     break;
 	}
 
-	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
+	VM_BUG_ON(!root);
 
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
@@ -333,11 +332,17 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
 static void __init check_usemap_section_nr(int nid, unsigned long *usemap)
 {
 	unsigned long usemap_snr, pgdat_snr;
-	static unsigned long old_usemap_snr = NR_MEM_SECTIONS;
-	static unsigned long old_pgdat_snr = NR_MEM_SECTIONS;
+	static unsigned long old_usemap_snr;
+	static unsigned long old_pgdat_snr;
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	int usemap_nid;
 
+	/* First call */
+	if (!old_usemap_snr) {
+		old_usemap_snr = NR_MEM_SECTIONS;
+		old_pgdat_snr = NR_MEM_SECTIONS;
+	}
+
 	usemap_snr = pfn_to_section_nr(__pa(usemap) >> PAGE_SHIFT);
 	pgdat_snr = pfn_to_section_nr(__pa(pgdat) >> PAGE_SHIFT);
 	if (usemap_snr == pgdat_snr)
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
