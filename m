Message-Id: <20080603100940.217098052@amd.local0.net>
References: <20080603095956.781009952@amd.local0.net>
Date: Tue, 03 Jun 2008 20:00:12 +1000
From: npiggin@suse.de
Subject: [patch 16/21] hugetlb: allow arch overried hugepage allocation
Content-Disposition: inline; filename=hugetlb-allow-arch-override-hugepage-allocation.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: Nishanth Aravamudan <nacc@us.ibm.com>, linux-mm@kvack.org, Adam Litke <agl@us.ibm.com>, Jon Tollefson <kniht@linux.vnet.ibm.com>, kniht@us.ibm.com, andi@firstfloor.org, abh@cray.com, joachim.deguara@amd.com
List-ID: <linux-mm.kvack.org>

Allow alloc_bootmem_huge_page() to be overridden by architectures that can't
always use bootmem. This requires huge_boot_pages to be available for
use by this function. The 16G pages on ppc64 have to be reserved prior
to boot-time. The location of these pages are indicated in the device
tree.

Acked-by: Adam Litke <agl@us.ibm.com>
Signed-off-by: Jon Tollefson <kniht@linux.vnet.ibm.com>
Signed-off-by: Nick Piggin <npiggin@suse.de>
---

 include/linux/hugetlb.h |   10 ++++++++++
 mm/hugetlb.c            |   12 ++++--------
 2 files changed, 14 insertions(+), 8 deletions(-)


Index: linux-2.6/include/linux/hugetlb.h
===================================================================
--- linux-2.6.orig/include/linux/hugetlb.h	2008-06-03 19:56:55.000000000 +1000
+++ linux-2.6/include/linux/hugetlb.h	2008-06-03 19:57:00.000000000 +1000
@@ -39,6 +39,7 @@ void hugetlb_unreserve_pages(struct inod
 extern unsigned long hugepages_treat_as_movable;
 extern const unsigned long hugetlb_zero, hugetlb_infinity;
 extern int sysctl_hugetlb_shm_group;
+extern struct list_head huge_boot_pages;
 
 /* arch callbacks */
 
@@ -188,6 +189,14 @@ struct hstate {
 	char name[HSTATE_NAME_LEN];
 };
 
+struct huge_bootmem_page {
+	struct list_head list;
+	struct hstate *hstate;
+};
+
+/* arch callback */
+int __init alloc_bootmem_huge_page(struct hstate *h);
+
 void __init hugetlb_add_hstate(unsigned order);
 struct hstate *size_to_hstate(unsigned long size);
 
@@ -254,6 +263,7 @@ static inline struct hstate *page_hstate
 
 #else
 struct hstate {};
+#define alloc_bootmem_huge_page(h) NULL
 #define hstate_file(f) NULL
 #define hstate_vma(v) NULL
 #define hstate_inode(i) NULL
Index: linux-2.6/mm/hugetlb.c
===================================================================
--- linux-2.6.orig/mm/hugetlb.c	2008-06-03 19:56:59.000000000 +1000
+++ linux-2.6/mm/hugetlb.c	2008-06-03 19:57:00.000000000 +1000
@@ -31,6 +31,8 @@ static int max_hstate = 0;
 unsigned int default_hstate_idx;
 struct hstate hstates[HUGE_MAX_HSTATE];
 
+__initdata LIST_HEAD(huge_boot_pages);
+
 /* for command line parsing */
 static struct hstate * __initdata parsed_hstate = NULL;
 static unsigned long __initdata default_hstate_max_huge_pages = 0;
@@ -850,14 +852,7 @@ static struct page *alloc_huge_page(stru
 	return page;
 }
 
-static __initdata LIST_HEAD(huge_boot_pages);
-
-struct huge_bootmem_page {
-	struct list_head list;
-	struct hstate *hstate;
-};
-
-static int __init alloc_bootmem_huge_page(struct hstate *h)
+__attribute__((weak)) int alloc_bootmem_huge_page(struct hstate *h)
 {
 	struct huge_bootmem_page *m;
 	int nr_nodes = nodes_weight(node_online_map);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
