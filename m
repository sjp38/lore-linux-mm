Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 2CB636B0039
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:35 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 11/39] thp: represent file thp pages in meminfo and friends
Date: Sun, 12 May 2013 04:23:08 +0300
Message-Id: <1368321816-17719-12-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
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
 drivers/base/node.c    |    4 ++++
 fs/proc/meminfo.c      |    3 +++
 include/linux/mmzone.h |    1 +
 mm/vmstat.c            |    1 +
 4 files changed, 9 insertions(+)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index bc9f43b..de261f5 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -119,6 +119,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d SUnreclaim:     %8lu kB\n"
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		       "Node %d AnonHugePages:  %8lu kB\n"
+		       "Node %d FileHugePages:  %8lu kB\n"
 #endif
 			,
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
@@ -140,6 +141,9 @@ static ssize_t node_read_meminfo(struct device *dev,
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
index 59d85d6..a62952c 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -104,6 +104,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #endif
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		"AnonHugePages:  %8lu kB\n"
+		"FileHugePages:  %8lu kB\n"
 #endif
 		,
 		K(i.totalram),
@@ -158,6 +159,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 		,K(global_page_state(NR_ANON_TRANSPARENT_HUGEPAGES) *
 		   HPAGE_PMD_NR)
+		,K(global_page_state(NR_FILE_TRANSPARENT_HUGEPAGES) *
+		   HPAGE_PMD_NR)
 #endif
 		);
 
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 72e1cb5..33fd258 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -142,6 +142,7 @@ enum zone_stat_item {
 	NUMA_OTHER,		/* allocation from other node */
 #endif
 	NR_ANON_TRANSPARENT_HUGEPAGES,
+	NR_FILE_TRANSPARENT_HUGEPAGES,
 	NR_FREE_CMA_PAGES,
 	NR_VM_ZONE_STAT_ITEMS };
 
diff --git a/mm/vmstat.c b/mm/vmstat.c
index 7a35116..7945285 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -738,6 +738,7 @@ const char * const vmstat_text[] = {
 	"numa_other",
 #endif
 	"nr_anon_transparent_hugepages",
+	"nr_file_transparent_hugepages",
 	"nr_free_cma",
 	"nr_dirty_threshold",
 	"nr_dirty_background_threshold",
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
