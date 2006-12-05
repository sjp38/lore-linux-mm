Date: Tue, 5 Dec 2006 22:09:06 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] vmemmap on sparsemem v2 [4/5] optimized pfn_valid
Message-Id: <20061205220906.f1d24dfc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
References: <20061205214517.5ad924f6.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, clameter@engr.sgi.com, apw@shadowen.org
List-ID: <linux-mm.kvack.org>

This implements pfn_valid() as ia64's vmem_map does.
This eliminates access to mem_section[] array by usual ops.

Because vmemmap on sparsemem is aligned. access check function can be easier
than ia64's.

Signed-Off-By: KAMEZAWA Hiruyoki <kamezawa.hiroyu@jp.fujitsu.com>

 include/linux/mmzone.h |   14 ++++++++++++++
 mm/sparse.c            |   23 +++++++++++++++++++++++
 2 files changed, 37 insertions(+)

Index: devel-2.6.19-rc6-mm2/include/linux/mmzone.h
===================================================================
--- devel-2.6.19-rc6-mm2.orig/include/linux/mmzone.h	2006-12-05 21:25:43.000000000 +0900
+++ devel-2.6.19-rc6-mm2/include/linux/mmzone.h	2006-12-05 21:45:21.000000000 +0900
@@ -752,12 +752,27 @@
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
+#if defined(SPARSEMEM_VMEM_MAP) && defined(CONFIG_USE_OPT_PFN_VALID)
+/*
+ * Uses hardware assist instead of mem_section[] table walking.
+ * good for SPARSEMEM_EXTREME
+ * To use this, you may need arch support in page fault handler.
+ */
+static inline int pfn_valid(unsigned long pfn)
+{
+	struct page *pg = pfn_to_page(pfn);
+	return (VIRTUAL_MEM_MAP <= pg &&
+		pg < (VIRUTAL_MEM_MAP + VIRTUAL_MEM_MAP_SIZE) &&
+		check_valid_memmap(pg));
+}
+#else
 static inline int pfn_valid(unsigned long pfn)
 {
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+#endif
 
 /*
  * These are _only_ used during initialisation, therefore they
Index: devel-2.6.19-rc6-mm2/mm/sparse.c
===================================================================
--- devel-2.6.19-rc6-mm2.orig/mm/sparse.c	2006-12-05 21:25:43.000000000 +0900
+++ devel-2.6.19-rc6-mm2/mm/sparse.c	2006-12-05 21:47:21.000000000 +0900
@@ -103,6 +103,22 @@
 
 
 #ifdef CONFIG_SPARSEMEM_VMEMMAP
+#ifdef CONFIG_USE_OPT_PFN_VALID
+
+/* check mem_map is valid or not by accessing it.
+   Because virtual mem_map/sparse mem is always alined, just __get_user()
+   check is necessary.
+ */
+int check_valid_memmap(struct page *pg)
+{
+	char byte;
+	if (__get_user(byte, (char __user*)pg) == 0)
+		return 1;
+	return 0;
+}
+
+EXPORT_SYMBOL(check_valid_memmap);
+#endif
 
 static void* __meminit pte_alloc_vmem_map(int node)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
