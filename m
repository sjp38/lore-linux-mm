Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DDB4E6B025E
	for <linux-mm@kvack.org>; Thu, 11 Feb 2016 09:22:42 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id q63so30191471pfb.0
        for <linux-mm@kvack.org>; Thu, 11 Feb 2016 06:22:42 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id o4si12946166pfo.19.2016.02.11.06.22.10
        for <linux-mm@kvack.org>;
        Thu, 11 Feb 2016 06:22:10 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 11/28] mm, rmap: account file thp pages
Date: Thu, 11 Feb 2016 17:21:39 +0300
Message-Id: <1455200516-132137-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1455200516-132137-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add FileHugePages field into meminfo.

NR_ANON_TRANSPARENT_HUGEPAGES is renames to NR_ANON_THPS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/base/node.c    | 10 ++++++----
 fs/proc/meminfo.c      |  5 +++--
 include/linux/mmzone.h |  3 ++-
 mm/huge_memory.c       |  2 +-
 mm/rmap.c              | 12 ++++++------
 mm/vmstat.c            |  1 +
 6 files changed, 19 insertions(+), 14 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 560751bad294..57b6c1ed0330 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -113,6 +113,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d SUnreclaim:     %8lu kB\n"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
+		       "Node %d FileHugePages:  %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
@@ -131,10 +132,11 @@ static ssize_t node_read_meminfo(struct device *dev,
 				node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
 		       nid, K(node_page_state(nid, NR_SLAB_RECLAIMABLE)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
-			, nid,
-			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
-			HPAGE_PMD_NR));
+		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)),
+		       nid, K(node_page_state(nid, NR_ANON_THPS) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(nid, NR_FILE_THP_MAPPED) *
+				       HPAGE_PMD_NR));
 #else
 		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 #endif
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index df4661abadc4..df07256c71a7 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -134,6 +134,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
+		"FileHugePages:  %8lu kB\n"
 #endif
 #ifdef CONFIG_CMA
 		"CmaTotal:       %8lu kB\n"
@@ -191,8 +192,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
-		   HPAGE_PMD_NR)
+		, K(global_page_state(NR_ANON_THPS) * HPAGE_PMD_NR)
+		, K(global_page_state(NR_FILE_THP_MAPPED) * HPAGE_PMD_NR)
 #endif
 #ifdef CONFIG_CMA
 		, K(totalcma_pages)
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 03cbdd906f55..a29a87ab05a4 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -158,7 +158,8 @@ enum zone_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
-	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_ANON_THPS,
+	NR_FILE_THP_MAPPED,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9d614cee994f..732bda42ca80 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -2946,7 +2946,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
 		/* Last compound_mapcount is gone. */
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__dec_zone_page_state(page, NR_ANON_THPS);
 		if (TestClearPageDoubleMap(page)) {
 			/* No need in mapcount reference anymore */
 			for (i = 0; i < HPAGE_PMD_NR; i++)
diff --git a/mm/rmap.c b/mm/rmap.c
index b550bf637ce3..765e001836dc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1227,10 +1227,8 @@ void do_page_add_anon_rmap(struct page *page,
 		 * pte lock(a spinlock) is held, which implies preemption
 		 * disabled.
 		 */
-		if (compound) {
-			__inc_zone_page_state(page,
-					      NR_ANON_TRANSPARENT_HUGEPAGES);
-		}
+		if (compound)
+			__inc_zone_page_state(page, NR_ANON_THPS);
 		__mod_zone_page_state(page_zone(page), NR_ANON_PAGES, nr);
 	}
 	if (unlikely(PageKsm(page)))
@@ -1268,7 +1266,7 @@ void page_add_new_anon_rmap(struct page *page,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__inc_zone_page_state(page, NR_ANON_THPS);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1298,6 +1296,7 @@ void page_add_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
+		__inc_zone_page_state(page, NR_FILE_THP_MAPPED);
 	} else {
 		if (!atomic_inc_and_test(&page->_mapcount))
 			goto out;
@@ -1330,6 +1329,7 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
+		__dec_zone_page_state(page, NR_FILE_THP_MAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
 			goto out;
@@ -1363,7 +1363,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__dec_zone_page_state(page, NR_ANON_THPS);
 
 	if (TestClearPageDoubleMap(page)) {
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 05c6ba2534fe..801e6b18fb94 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -762,6 +762,7 @@ const char * const vmstat_text[] = {
 	"workingset_activate",
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
+	"nr_file_transparent_hugepages",
 	"nr_free_cma",
 
 	/* enum writeback_stat_item counters */
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
