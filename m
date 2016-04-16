Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AC7CD828DF
	for <linux-mm@kvack.org>; Fri, 15 Apr 2016 20:24:40 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so215218848pfb.0
        for <linux-mm@kvack.org>; Fri, 15 Apr 2016 17:24:40 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xz4si6983114pab.139.2016.04.15.17.24.20
        for <linux-mm@kvack.org>;
        Fri, 15 Apr 2016 17:24:20 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 21/29] mm, rmap: account shmem thp pages
Date: Sat, 16 Apr 2016 03:23:52 +0300
Message-Id: <1460766240-84565-22-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1460766240-84565-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add ShmemHugePages and ShmemPmdMapped fields into meminfo and
smaps. It indicates how many times we allocate and map shmem THP.

NR_ANON_TRANSPARENT_HUGEPAGES is renamed to NR_ANON_THPS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/base/node.c    | 13 +++++++++----
 fs/proc/meminfo.c      |  7 +++++--
 fs/proc/task_mmu.c     | 10 +++++++++-
 include/linux/mmzone.h |  4 +++-
 mm/huge_memory.c       |  4 +++-
 mm/page_alloc.c        | 19 +++++++++++++++++++
 mm/rmap.c              | 14 ++++++++------
 mm/vmstat.c            |  2 ++
 8 files changed, 58 insertions(+), 15 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 560751bad294..51c7db2c4ee2 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -113,6 +113,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d SUnreclaim:     %8lu kB\n"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
+		       "Node %d ShmemHugePages: %8lu kB\n"
+		       "Node %d ShmemPmdMapped: %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
@@ -131,10 +133,13 @@ static ssize_t node_read_meminfo(struct device *dev,
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
+		       nid, K(node_page_state(nid, NR_SHMEM_THPS) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(nid, NR_SHMEM_PMDMAPPED) *
+				       HPAGE_PMD_NR));
 #else
 		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
 #endif
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 83720460c5bc..cf301a9ef512 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -105,6 +105,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
+		"ShmemHugePages: %8lu kB\n"
+		"ShmemPmdMapped: %8lu kB\n"
 #endif
 #ifdef CONFIG_CMA
 		"CmaTotal:       %8lu kB\n"
@@ -162,8 +164,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		, atomic_long_read(&num_poisoned_pages) << (PAGE_SHIFT - 10)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		, K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
-		   HPAGE_PMD_NR)
+		, K(global_page_state(NR_ANON_THPS) * HPAGE_PMD_NR)
+		, K(global_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR)
+		, K(global_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR)
 #endif
 #ifdef CONFIG_CMA
 		, K(totalcma_pages)
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 229cb546bee0..b51651d9d8ae 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -448,6 +448,7 @@ struct mem_size_stats {
 	unsigned long referenced;
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
+	unsigned long shmem_thp;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -576,7 +577,12 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	page = follow_trans_huge_pmd(vma, addr, pmd, FOLL_DUMP);
 	if (IS_ERR_OR_NULL(page))
 		return;
-	mss->anonymous_thp += HPAGE_PMD_SIZE;
+	if (PageAnon(page))
+		mss->anonymous_thp += HPAGE_PMD_SIZE;
+	else if (PageSwapBacked(page))
+		mss->shmem_thp += HPAGE_PMD_SIZE;
+	else
+		VM_BUG_ON_PAGE(1, page);
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
@@ -770,6 +776,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Referenced:     %8lu kB\n"
 		   "Anonymous:      %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
+		   "ShmemPmdMapped: %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
 		   "Private_Hugetlb: %7lu kB\n"
 		   "Swap:           %8lu kB\n"
@@ -787,6 +794,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.referenced >> 10,
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
+		   mss.shmem_thp >> 10,
 		   mss.shared_hugetlb >> 10,
 		   mss.private_hugetlb >> 10,
 		   mss.swap >> 10,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index c60df9257cc7..13be8a13bbc1 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -158,7 +158,9 @@ enum zone_stat_item {
 	WORKINGSET_REFAULT,
 	WORKINGSET_ACTIVATE,
 	WORKINGSET_NODERECLAIM,
-	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_ANON_THPS,
+	NR_SHMEM_THPS,
+	NR_SHMEM_PMDMAPPED,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7287b45968ce..61f1651bf02f 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3018,7 +3018,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
 		/* Last compound_mapcount is gone. */
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__dec_zone_page_state(page, NR_ANON_THPS);
 		if (TestClearPageDoubleMap(page)) {
 			/* No need in mapcount reference anymore */
 			for (i = 0; i < HPAGE_PMD_NR; i++)
@@ -3437,6 +3437,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			pgdata->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
+		if (mapping)
+			__dec_zone_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
 		ret = 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 4243b400b331..106c38f59e48 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3888,6 +3888,9 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		" anon_thp: %lu shmem_thp: %lu shmem_pmdmapped: %lu\n"
+#endif
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
@@ -3905,6 +3908,11 @@ void show_free_areas(unsigned int filter)
 		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE),
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		global_page_state(NR_ANON_THPS) * HPAGE_PMD_NR,
+		global_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR,
+		global_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR,
+#endif
 		global_page_state(NR_FREE_PAGES),
 		free_pcp,
 		global_page_state(NR_FREE_CMA_PAGES));
@@ -3939,6 +3947,11 @@ void show_free_areas(unsigned int filter)
 			" writeback:%lukB"
 			" mapped:%lukB"
 			" shmem:%lukB"
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+			" shmem_thp: %lukB"
+			" shmem_pmdmapped: %lukB"
+			" anon_thp: %lukB"
+#endif
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
 			" kernel_stack:%lukB"
@@ -3971,6 +3984,12 @@ void show_free_areas(unsigned int filter)
 			K(zone_page_state(zone, NR_WRITEBACK)),
 			K(zone_page_state(zone, NR_FILE_MAPPED)),
 			K(zone_page_state(zone, NR_SHMEM)),
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+			K(zone_page_state(zone, NR_SHMEM_THPS) * HPAGE_PMD_NR),
+			K(zone_page_state(zone, NR_SHMEM_PMDMAPPED)
+					* HPAGE_PMD_NR),
+			K(zone_page_state(zone, NR_ANON_THPS) * HPAGE_PMD_NR),
+#endif
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK) *
diff --git a/mm/rmap.c b/mm/rmap.c
index f67e765869f3..ba0539074ada 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1213,10 +1213,8 @@ void do_page_add_anon_rmap(struct page *page,
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
@@ -1254,7 +1252,7 @@ void page_add_new_anon_rmap(struct page *page,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__inc_zone_page_state(page, NR_ANON_THPS);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1284,6 +1282,8 @@ void page_add_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
+		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (PageTransCompound(page)) {
 			VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -1322,6 +1322,8 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
+		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
 			goto out;
@@ -1355,7 +1357,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__dec_zone_page_state(page, NR_ANON_THPS);
 
 	if (TestClearPageDoubleMap(page)) {
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 904ac95fbf00..4d7921f560b5 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -762,6 +762,8 @@ const char * const vmstat_text[] = {
 	"workingset_activate",
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
+	"nr_shmem_hugepages",
+	"nr_shmem_pmdmapped",
 	"nr_free_cma",
 
 	/* enum writeback_stat_item counters */
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
