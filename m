Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C2EC66B0280
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 16:13:10 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so50263156pad.1
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 13:13:10 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id wa12si5647479pac.138.2016.06.15.13.07.04
        for <linux-mm@kvack.org>;
        Wed, 15 Jun 2016 13:07:04 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv9-rebased2 26/37] mm, rmap: account shmem thp pages
Date: Wed, 15 Jun 2016 23:06:31 +0300
Message-Id: <1466021202-61880-27-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1465222029-45942-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1466021202-61880-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ebru Akagunduz <ebru.akagunduz@gmail.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
index 4648c7f63ae2..187d84ef9de9 100644
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
index 3d7ab30d4940..19425e988bdc 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -154,7 +154,9 @@ enum zone_stat_item {
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
index 6ee521dd0353..24c08b44724b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3071,7 +3071,7 @@ static void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
 
 	if (atomic_add_negative(-1, compound_mapcount_ptr(page))) {
 		/* Last compound_mapcount is gone. */
-		__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__dec_zone_page_state(page, NR_ANON_THPS);
 		if (TestClearPageDoubleMap(page)) {
 			/* No need in mapcount reference anymore */
 			for (i = 0; i < HPAGE_PMD_NR; i++)
@@ -3550,6 +3550,8 @@ int split_huge_page_to_list(struct page *page, struct list_head *list)
 			pgdata->split_queue_len--;
 			list_del(page_deferred_list(head));
 		}
+		if (mapping)
+			__dec_zone_page_state(page, NR_SHMEM_THPS);
 		spin_unlock(&pgdata->split_queue_lock);
 		__split_huge_page(page, list, flags);
 		ret = 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d35a907d7a07..b9ea6189c037 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4309,6 +4309,9 @@ void show_free_areas(unsigned int filter)
 		" unevictable:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n"
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		" anon_thp: %lu shmem_thp: %lu shmem_pmdmapped: %lu\n"
+#endif
 		" free:%lu free_pcp:%lu free_cma:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
@@ -4326,6 +4329,11 @@ void show_free_areas(unsigned int filter)
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
@@ -4360,6 +4368,11 @@ void show_free_areas(unsigned int filter)
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
@@ -4392,6 +4405,12 @@ void show_free_areas(unsigned int filter)
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
index 26e3e784ad75..256e585c67ef 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1215,10 +1215,8 @@ void do_page_add_anon_rmap(struct page *page,
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
@@ -1256,7 +1254,7 @@ void page_add_new_anon_rmap(struct page *page,
 		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
 		/* increment count (starts at -1) */
 		atomic_set(compound_mapcount_ptr(page), 0);
-		__inc_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+		__inc_zone_page_state(page, NR_ANON_THPS);
 	} else {
 		/* Anon THP always mapped first with PMD */
 		VM_BUG_ON_PAGE(PageTransCompound(page), page);
@@ -1286,6 +1284,8 @@ void page_add_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
+		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+		__inc_zone_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (PageTransCompound(page)) {
 			VM_BUG_ON_PAGE(!PageLocked(page), page);
@@ -1324,6 +1324,8 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
+		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
+		__dec_zone_page_state(page, NR_SHMEM_PMDMAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
 			goto out;
@@ -1357,7 +1359,7 @@ static void page_remove_anon_compound_rmap(struct page *page)
 	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
 		return;
 
-	__dec_zone_page_state(page, NR_ANON_TRANSPARENT_HUGEPAGES);
+	__dec_zone_page_state(page, NR_ANON_THPS);
 
 	if (TestClearPageDoubleMap(page)) {
 		/*
diff --git a/mm/vmstat.c b/mm/vmstat.c
index cff2f4ec9cce..7997f52935c9 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -733,6 +733,8 @@ const char * const vmstat_text[] = {
 	"workingset_activate",
 	"workingset_nodereclaim",
 	"nr_anon_transparent_hugepages",
+	"nr_shmem_hugepages",
+	"nr_shmem_pmdmapped",
 	"nr_free_cma",
 
 	/* enum writeback_stat_item counters */
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
