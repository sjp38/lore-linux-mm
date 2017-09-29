Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16CD46B0069
	for <linux-mm@kvack.org>; Fri, 29 Sep 2017 10:08:30 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id y17so3683264pgc.2
        for <linux-mm@kvack.org>; Fri, 29 Sep 2017 07:08:30 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id q11si3433813pgc.56.2017.09.29.07.08.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Sep 2017 07:08:28 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 1/6] mm/sparsemem: Allocate mem_section at runtime for SPARSEMEM_EXTREME
Date: Fri, 29 Sep 2017 17:08:16 +0300
Message-Id: <20170929140821.37654-2-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
References: <20170929140821.37654-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Size of mem_section array depends on size of physical address space.

In preparation for boot-time switching between paging modes on x86-64
we need to make allocation of mem_section dynamic.

With CONFIG_NODE_SHIFT=10, mem_section size if 32k for 4-level paging
and 2M for 5-level paging mode.

The patch allocates the array on the first call to
sparse_memory_present_with_active_regions().

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/mmzone.h |  6 +++++-
 mm/page_alloc.c        | 10 ++++++++++
 mm/sparse.c            | 17 +++++++++++------
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 356a814e7c8e..a48b55fbb502 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -1144,13 +1144,17 @@ struct mem_section {
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
index c841af88836a..8034651b916e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -5645,6 +5645,16 @@ void __init sparse_memory_present_with_active_regions(int nid)
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
index 83b3bf6461af..b00a97398795 100644
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
@@ -100,7 +99,7 @@ static inline int sparse_index_init(unsigned long section_nr, int nid)
 int __section_nr(struct mem_section* ms)
 {
 	unsigned long root_nr;
-	struct mem_section* root;
+	struct mem_section *root = NULL;
 
 	for (root_nr = 0; root_nr < NR_SECTION_ROOTS; root_nr++) {
 		root = __nr_to_section(root_nr * SECTIONS_PER_ROOT);
@@ -111,7 +110,7 @@ int __section_nr(struct mem_section* ms)
 		     break;
 	}
 
-	VM_BUG_ON(root_nr == NR_SECTION_ROOTS);
+	VM_BUG_ON(!root);
 
 	return (root_nr * SECTIONS_PER_ROOT) + (ms - root);
 }
@@ -329,11 +328,17 @@ sparse_early_usemaps_alloc_pgdat_section(struct pglist_data *pgdat,
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
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
