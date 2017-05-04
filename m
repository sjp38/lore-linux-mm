Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 37DD46B0038
	for <linux-mm@kvack.org>; Thu,  4 May 2017 13:44:55 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id o3so16445838pgn.13
        for <linux-mm@kvack.org>; Thu, 04 May 2017 10:44:55 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id u91si2628662plb.202.2017.05.04.10.44.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 May 2017 10:44:54 -0700 (PDT)
Subject: [PATCH] mm, sparsemem: break out of loops early
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Thu, 04 May 2017 10:44:34 -0700
Message-Id: <20170504174434.C45A4735@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, kirill.shutemov@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

There are a number of times that we loop over NR_MEM_SECTIONS,
looking for section_present() on each section.  But, when we have
very large physical address spaces (large MAX_PHYSMEM_BITS),
NR_MEM_SECTIONS becomes very large, making the loops quite long.

With MAX_PHYSMEM_BITS=46 and a section size of 128MB, the current
loops are 512k iterations, which we barely notice on modern
hardware.  But, raising MAX_PHYSMEM_BITS higher (like we will see
on systems that support 5-level paging) makes this 64x longer and
we start to notice, especially on slower systems like simulators.
A 10-second delay for 512k iterations is annoying.  But, a 640-
second delay is crippling.

This does not help if we have extremely sparse physical address
spaces, but those are quite rare.  We expect that most of the
"slow" systems where this matters will also be quite small and
non-sparse.

To fix this, we track the highest section we've ever encountered.
This lets us know when we will *never* see another
section_present(), and lets us break out of the loops earlier.

Doing the whole for_each_present_section_nr() macro is probably
overkill, but it will ensure that any future loop iterations that
we grow are more likely to be correct.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---

 b/drivers/base/memory.c  |    4 +++
 b/include/linux/mmzone.h |    2 +
 b/mm/sparse.c            |   60 ++++++++++++++++++++++++++++++++++++-----------
 3 files changed, 52 insertions(+), 14 deletions(-)

diff -puN mm/sparse.c~highest-section mm/sparse.c
--- a/mm/sparse.c~highest-section	2017-05-03 14:50:10.413117097 -0700
+++ b/mm/sparse.c	2017-05-04 10:43:36.725960272 -0700
@@ -168,6 +168,44 @@ void __meminit mminit_validate_memmodel_
 	}
 }
 
+/*
+ * There are a number of times that we loop over NR_MEM_SECTIONS,
+ * looking for section_present() on each.  But, when we have very
+ * large physical address spaces, NR_MEM_SECTIONS can also be
+ * very large which makes the loops quite long.
+ *
+ * Keeping track of this gives us an easy way to break out of
+ * those loops early.
+ */
+int __highest_present_section_nr;
+static void section_mark_present(struct mem_section *ms)
+{
+	int section_nr = __section_nr(ms);
+
+	if (section_nr > __highest_present_section_nr)
+		__highest_present_section_nr = section_nr;
+
+	ms->section_mem_map |= SECTION_MARKED_PRESENT;
+}
+
+static inline int next_present_section_nr(int section_nr)
+{
+	do {
+		section_nr++;
+		if (present_section_nr(section_nr))
+			return section_nr;
+	} while ((section_nr < NR_MEM_SECTIONS) &&
+		 (section_nr <= __highest_present_section_nr));
+
+	return -1;
+}
+#define for_each_present_section_nr(start, section_nr)		\
+	for (section_nr = next_present_section_nr(start-1);	\
+	     ((section_nr >= 0) &&				\
+	      (section_nr < NR_MEM_SECTIONS) &&			\
+	      (section_nr <= __highest_present_section_nr));	\
+	     section_nr = next_present_section_nr(section_nr))
+
 /* Record a memory area against a node. */
 void __init memory_present(int nid, unsigned long start, unsigned long end)
 {
@@ -183,9 +221,10 @@ void __init memory_present(int nid, unsi
 		set_section_nid(section, nid);
 
 		ms = __nr_to_section(section);
-		if (!ms->section_mem_map)
-			ms->section_mem_map = sparse_encode_early_nid(nid) |
-							SECTION_MARKED_PRESENT;
+		if (!ms->section_mem_map) {
+			ms->section_mem_map = sparse_encode_early_nid(nid);
+			section_mark_present(ms);
+		}
 	}
 }
 
@@ -479,23 +518,19 @@ static void __init alloc_usemap_and_memm
 	int nodeid_begin = 0;
 	unsigned long pnum_begin = 0;
 
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
+	for_each_present_section_nr(0, pnum) {
 		struct mem_section *ms;
 
-		if (!present_section_nr(pnum))
-			continue;
 		ms = __nr_to_section(pnum);
 		nodeid_begin = sparse_early_nid(ms);
 		pnum_begin = pnum;
 		break;
 	}
 	map_count = 1;
-	for (pnum = pnum_begin + 1; pnum < NR_MEM_SECTIONS; pnum++) {
+	for_each_present_section_nr(pnum_begin + 1, pnum) {
 		struct mem_section *ms;
 		int nodeid;
 
-		if (!present_section_nr(pnum))
-			continue;
 		ms = __nr_to_section(pnum);
 		nodeid = sparse_early_nid(ms);
 		if (nodeid == nodeid_begin) {
@@ -564,10 +599,7 @@ void __init sparse_init(void)
 							(void *)map_map);
 #endif
 
-	for (pnum = 0; pnum < NR_MEM_SECTIONS; pnum++) {
-		if (!present_section_nr(pnum))
-			continue;
-
+	for_each_present_section_nr(0, pnum) {
 		usemap = usemap_map[pnum];
 		if (!usemap)
 			continue;
@@ -725,7 +757,7 @@ int __meminit sparse_add_one_section(str
 
 	memset(memmap, 0, sizeof(struct page) * PAGES_PER_SECTION);
 
-	ms->section_mem_map |= SECTION_MARKED_PRESENT;
+	section_mark_present(ms);
 
 	ret = sparse_init_one_section(ms, section_nr, memmap, usemap);
 
diff -puN include/linux/mmzone.h~highest-section include/linux/mmzone.h
--- a/include/linux/mmzone.h~highest-section	2017-05-03 14:50:10.416117232 -0700
+++ b/include/linux/mmzone.h	2017-05-03 14:50:10.437118180 -0700
@@ -1171,6 +1171,8 @@ static inline struct mem_section *__pfn_
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
+extern int __highest_present_section_nr;
+
 #ifndef CONFIG_HAVE_ARCH_PFN_VALID
 static inline int pfn_valid(unsigned long pfn)
 {
diff -puN drivers/base/memory.c~highest-section drivers/base/memory.c
--- a/drivers/base/memory.c~highest-section	2017-05-03 14:50:10.421117458 -0700
+++ b/drivers/base/memory.c	2017-05-03 14:50:10.439118270 -0700
@@ -820,6 +820,10 @@ int __init memory_dev_init(void)
 	 */
 	mutex_lock(&mem_sysfs_mutex);
 	for (i = 0; i < NR_MEM_SECTIONS; i += sections_per_block) {
+		/* Don't iterate over sections we know are !present: */
+		if (i > __highest_present_section_nr)
+			break;
+
 		err = add_memory_block(i);
 		if (!ret)
 			ret = err;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
