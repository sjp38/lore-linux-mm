Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 369536B00A9
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 07:58:22 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv3, RFC 09/34] thp: represent file thp pages in meminfo and friends
Date: Fri,  5 Apr 2013 14:59:33 +0300
Message-Id: <1365163198-29726-10-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1365163198-29726-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

The patch adds new zone stat to count file transparent huge pages and
adjust related places.

For now we don't count mapped or dirty file thp pages separately.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 drivers/base/node.c    |   10 ++++++++++
 fs/proc/meminfo.c      |    6 ++++++
 include/linux/mmzone.h |    1 +
 mm/mmap.c              |    3 +++
 mm/page_alloc.c        |    7 ++++++-
 5 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index fac124a..eed3763 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -118,11 +118,18 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d SUnreclaim:     %8lu kB\n"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
+		       "Node %d FileHugePages:  %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE
+		       nid, K(node_page_state(nid, NR_FILE_PAGES)
+			+ node_page_state(nid, NR_FILE_TRANSPARENT_HUGEPAGES) *
+			HPAGE_PMD_NR),
+#else
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
+#endif
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)
@@ -145,6 +152,9 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE))
 			, nid,
 			K(node_page_state(nid, NR_ANON_TRANSPARENT_HUGEPAGES) *
+			HPAGE_PMD_NR)
+			, nid,
+			K(node_page_state(nid, NR_FILE_TRANSPARENT_HUGEPAGES) *
 			HPAGE_PMD_NR));
 #else
 		       nid, K(node_page_state(nid, NR_SLAB_UNRECLAIMABLE)));
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 1efaaa1..747ec70 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -41,6 +41,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 
 	cached = global_page_state(NR_FILE_PAGES) -
 			total_swapcache_pages() - i.bufferram;
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		cached += global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
+			HPAGE_PMD_NR;
 	if (cached < 0)
 		cached = 0;
 
@@ -103,6 +106,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
+		"FileHugePages:  %8lu kB\n"
 #endif
 		,
 		K(i.totalram),
@@ -163,6 +167,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
 		   HPAGE_PMD_NR)
+		,K(global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
+		   HPAGE_PMD_NR)
 #endif
 		);
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index ab20a60..91fadd6 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -142,6 +142,7 @@ enum zone_stat_item {
 	NUMA_OTHER,		/* allocation from other node */
 #endif
 	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_FILE_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 49dc7d5..afb9088 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -135,6 +135,9 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	if (sysctl_overcommit_memory == OVERCOMMIT_GUESS) {
 		free = global_page_state(NR_FREE_PAGES);
 		free += global_page_state(NR_FILE_PAGES);
+		if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+			free += global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES)
+				* HPAGE_PMD_NR;
 
 		/*
 		 * shmem pages shouldn't be counted as free in this
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ca7b01e..7a26038 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2963,6 +2963,7 @@ void show_free_areas(unsigned int filter)
 {
 	int cpu;
 	struct zone *zone;
+	long cached;
 
 	for_each_populated_zone(zone) {
 		if (skip_free_areas_node(filter, zone_to_nid(zone)))
@@ -3112,7 +3113,11 @@ void show_free_areas(unsigned int filter)
 		printk("= %lukB\n", K(total));
 	}
 
-	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
+	cached = global_page_state(NR_FILE_PAGES);
+	if (IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE))
+		cached += global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
+			HPAGE_PMD_NR;
+	printk("%ld total pagecache pages\n", cached);
 
 	show_swap_cache_info();
 }
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
