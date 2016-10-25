Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id AB52E6B0281
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 20:14:36 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id r16so132113863pfg.4
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 17:14:36 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id n21si9885520pgj.254.2016.10.24.17.14.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 17:14:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 09/43] mm, rmap: account file thp pages
Date: Tue, 25 Oct 2016 03:13:08 +0300
Message-Id: <20161025001342.76126-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
References: <20161025001342.76126-1-kirill.shutemov@linux.intel.com>
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
index 8a428498d6b2..8396843be7a7 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -146,6 +146,10 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		    global_node_page_state(NR_SHMEM_THPS) * HPAGE_PMD_NR);
 	show_val_kb(m, "ShmemPmdMapped: ",
 		    global_node_page_state(NR_SHMEM_PMDMAPPED) * HPAGE_PMD_NR);
+	show_val_kb(m, "FileHugePages: ",
+		    global_node_page_state(NR_FILE_THPS) * HPAGE_PMD_NR);
+	show_val_kb(m, "FilePmdMapped: ",
+		    global_node_page_state(NR_FILE_PMDMAPPED) * HPAGE_PMD_NR);
 #endif
 
 #ifdef CONFIG_CMA
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 35b92d81692f..bb8b7f93528e 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -442,6 +442,7 @@ struct mem_size_stats {
 	unsigned long anonymous;
 	unsigned long anonymous_thp;
 	unsigned long shmem_thp;
+	unsigned long file_thp;
 	unsigned long swap;
 	unsigned long shared_hugetlb;
 	unsigned long private_hugetlb;
@@ -577,7 +578,7 @@ static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
 	else if (is_zone_device_page(page))
 		/* pass */;
 	else
-		VM_BUG_ON_PAGE(1, page);
+		mss->file_thp += HPAGE_PMD_SIZE;
 	smaps_account(mss, page, true, pmd_young(*pmd), pmd_dirty(*pmd));
 }
 #else
@@ -772,6 +773,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   "Anonymous:      %8lu kB\n"
 		   "AnonHugePages:  %8lu kB\n"
 		   "ShmemPmdMapped: %8lu kB\n"
+		   "FilePmdMapped:  %8lu kB\n"
 		   "Shared_Hugetlb: %8lu kB\n"
 		   "Private_Hugetlb: %7lu kB\n"
 		   "Swap:           %8lu kB\n"
@@ -790,6 +792,7 @@ static int show_smap(struct seq_file *m, void *v, int is_pid)
 		   mss.anonymous >> 10,
 		   mss.anonymous_thp >> 10,
 		   mss.shmem_thp >> 10,
+		   mss.file_thp >> 10,
 		   mss.shared_hugetlb >> 10,
 		   mss.private_hugetlb >> 10,
 		   mss.swap >> 10,
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 7f2ae99e5daf..20c5fce13697 100644
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
index 23fbbb61725c..e9376610ad3c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -293,7 +293,8 @@ void __delete_from_page_cache(struct page *page, void *shadow)
 		if (PageTransHuge(page))
 			__dec_node_page_state(page, NR_SHMEM_THPS);
 	} else {
-		VM_BUG_ON_PAGE(PageTransHuge(page) && !PageHuge(page), page);
+		if (PageTransHuge(page) && !PageHuge(page))
+			__dec_node_page_state(page, NR_FILE_THPS);
 	}
 
 	/*
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 9888dbec1d01..e7cda8e86f2c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1892,7 +1892,10 @@ static void __split_huge_page(struct page *page, struct list_head *list,
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
index 2b3bf6767d54..447499b7054d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4293,6 +4293,8 @@ void show_free_areas(unsigned int filter)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 			" shmem_thp: %lukB"
 			" shmem_pmdmapped: %lukB"
+			" file_thp: %lukB"
+			" file_pmdmapped: %lukB"
 			" anon_thp: %lukB"
 #endif
 			" writeback_tmp:%lukB"
@@ -4315,6 +4317,9 @@ void show_free_areas(unsigned int filter)
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
index 1ef36404e7b2..48c7310639bd 100644
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
index 604f26a4f696..04dc6bd8ee43 100644
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
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
