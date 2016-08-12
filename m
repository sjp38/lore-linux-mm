Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 778296B0262
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:38:54 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ez1so5608784pab.1
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:38:54 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k84si10104810pfa.56.2016.08.12.11.38.44
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:44 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 10/41] mm, rmap: account file thp pages
Date: Fri, 12 Aug 2016 21:37:53 +0300
Message-Id: <1471027104-115213-11-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Let's add FileHugePages and FilePmdMapped fields into meminfo and smaps.
It indicates how many times we allocate and map file THP.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/base/node.c    |  6 ++++++
 fs/proc/meminfo.c      |  4 ++++
 fs/proc/task_mmu.c     |  5 ++++-
 include/linux/mmzone.h |  2 ++
 mm/filemap.c           |  3 ++-
 mm/huge_memory.c       |  5 ++++-
 mm/page_alloc.c        |  5 +++++
 mm/rmap.c              | 12 ++++++++----
 mm/vmstat.c            |  2 ++
 9 files changed, 37 insertions(+), 7 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 5548f9686016..45be0ddb84ed 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -116,6 +116,8 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d AnonHugePages:  %8lu kB\n"
 		       "Node %d ShmemHugePages: %8lu kB\n"
 		       "Node %d ShmemPmdMapped: %8lu kB\n"
+		       "Node %d FileHugePages: %8lu kB\n"
+		       "Node %d FilePmdMapped: %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(pgdat, NR_FILE_DIRTY)),
@@ -139,6 +141,10 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(pgdat, NR_FILE_THPS) *
+				       HPAGE_PMD_NR),
+		       nid, K(node_page_state(pgdat, NR_FILE_PMDMAPPED) *
 				       HPAGE_PMD_NR));
 #else
 		       nid, K(sum_zone_node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 09e18fdf61e5..201a060f2c6c 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -107,6 +107,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		"AnonHugePages:  %8lu kB\n"
 		"ShmemHugePages: %8lu kB\n"
 		"ShmemPmdMapped: %8lu kB\n"
+		"FileHugePages:  %8lu kB\n"
+		"FilePmdMapped:  %8lu kB\n"
 #endif
 #ifdef CONFIG_CMA
 		"CmaTotal:       %8lu kB\n"
@@ -167,6 +169,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		, K(global_node_page_state(NR_ANON_THPS) * HPAGE_PMD_NR)
 		, K(global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR)
 		, K(global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR)
+		, K(global_node_page_state(NR_FILE_THPS) * HPAGE_PMD_NR)
+		, K(global_node_page_state(NR_FILE_PMDMAPPED) * HPAGE_PMD_NR)
 #endif
 #ifdef CONFIG_CMA
 		, K(totalcma_pages)
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 187d84ef9de9..de698238a451 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -449,6 +449,7 @@ struct mem_size_stats {
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
+	unsigned long file_thp;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -582,7 +583,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	else if (PageSwapBacked(page))
 		mss->shmem_thp += HPAGE_PMD_SIZE;
 	else
-		VM_BUG_ON_PAGE(1, page);
+		mss->file_thp += HPAGE_PMD_SIZE;
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
@@ -777,6 +778,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Anonymous:      %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
 		   "ShmemPmdMapped: %8lu kB\n"
+		   "FilePmdMapped:  %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
 		   "Private_Hugetlb: %7lu kB\n"
 		   "Swap:           %8lu kB\n"
@@ -795,6 +797,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
 		   mss.shmem_thp >> 10,
+		   mss.file_thp >> 10,
 		   mss.shared_hugetlb >> 10,
 		   mss.private_hugetlb >> 10,
 		   mss.swap >> 10,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index d572b78b65e1..181c94df965a 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -163,6 +163,8 @@ enum node_stat_item {
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 	NR_SHMEM_THPS,
 	NR_SHMEM_PMDMAPPED,
+	NR_FILE_THPS,
+	NR_FILE_PMDMAPPED,
 	NR_ANON_THPS,
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_VMSCAN_WRITE,
diff --git a/mm/filemap.c b/mm/filemap.c
index eca8740d2d02..f2640fe345dd 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -220,7 +220,8 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 		if (PageTransHuge(page))
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page) && !PageHuge(page), page);
+		if (PageTransHuge(page) && !PageHuge(page))
+			__dec_node_page_state(page, NR_FILE_THPS);
 	}
 
 	/*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7937f723c96e..73e80d49c32e 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1833,7 +1833,10 @@ static void __split_huge_page(struct page *page, struct list_head *list,
 		struct radix_tree_iter iter;
 		void **slot;
 
-		__dec_node_page_state(head, NR_SHMEM_THPS);
+		if (PageSwapBacked(page))
+			__dec_node_page_state(page, NR_SHMEM_THPS);
+		else
+			__dec_node_page_state(page, NR_FILE_THPS);
 
 		radix_tree_split(&mapping->page_tree, head->index, 0);
 		radix_tree_for_each_slot(slot, &mapping->page_tree, &iter,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ee5a4b20daf4..af9b73563da9 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4290,6 +4290,8 @@ void show_free_areas(unsigned int filter)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			" shmem_thp: %lukB"
 			" shmem_pmdmapped: %lukB"
+			" file_thp: %lukB"
+			" file_pmdmapped: %lukB"
 			" anon_thp: %lukB"
 #endif
 			" writeback_tmp:%lukB"
@@ -4312,6 +4314,9 @@ void show_free_areas(unsigned int filter)
 			K(node_page_state(pgdat, NR_SHMEM_THPS) * HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED)
 					* HPAGE_PMD_NR),
+			K(node_page_state(pgdat, NR_FILE_THPS) * HPAGE_PMD_NR),
+			K(node_page_state(pgdat, NR_FILE_PMDMAPPED)
+					* HPAGE_PMD_NR),
 			K(node_page_state(pgdat, NR_ANON_THPS) * HPAGE_PMD_NR),
 #endif
 			K(node_page_state(pgdat, NR_SHMEM)),
diff --git a/mm/rmap.c b/mm/rmap.c
index d4f56060ba3f..f071d6f7a986 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1281,8 +1281,10 @@ void page_add_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
 			goto out;
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
-		__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		if (PageSwapBacked(page))
+			__inc_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		else
+			__inc_node_page_state(page, NR_FILE_PMDMAPPED);
 	} else {
 		if (PageTransCompound(page) && page_mapping(page)) {
 			VM_WARN_ON_ONCE(!PageLocked(page));
@@ -1322,8 +1324,10 @@ static void page_remove_file_rmap(struct page *page, bool compound)
 		}
 		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
 			goto out;
-		VM_BUG_ON_PAGE(!PageSwapBacked(page), page);
-		__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		if (PageSwapBacked(page))
+			__dec_node_page_state(page, NR_SHMEM_PMDMAPPED);
+		else
+			__dec_node_page_state(page, NR_FILE_PMDMAPPED);
 	} else {
 		if (!atomic_add_negative(-1, &page->_mapcount))
 			goto out;
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 84397e8eca54..714c91728ddd 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -967,6 +967,8 @@ const char * const vmstat_text[] = {
 	"nr_shmem",
 	"nr_shmem_hugepages",
 	"nr_shmem_pmdmapped",
+	"nr_file_hugepaged",
+	"nr_file_pmdmapped",
 	"nr_anon_transparent_hugepages",
 	"nr_unstable",
 	"nr_vmscan_write",
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
