Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 010516B0085
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 04:03:02 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n698I3Co012108
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 9 Jul 2009 17:18:03 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8795E45DE65
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:18:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 647DB45DE5D
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:18:03 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4214F1DB803B
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:18:03 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id C7EFA1DB8041
	for <linux-mm@kvack.org>; Thu,  9 Jul 2009 17:18:02 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 5/5] add shmem vmstat
In-Reply-To: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
References: <20090709165820.23B7.A69D9226@jp.fujitsu.com>
Message-Id: <20090709171452.23C9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  9 Jul 2009 17:18:01 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

ChangeLog
  Since v1
   - Fixed misaccounting bug on page migration

========================
Subject: [PATCH] add shmem vmstat

Recently, We faced several OOM problem by plenty GEM cache. and generally,
plenty Shmem/Tmpfs potentially makes memory shortage problem.

We often use following calculation to know shmem pages,
  shmem = NR_ACTIVE_ANON + NR_INACTIVE_ANON - NR_ANON_PAGES
but it is wrong expression. it doesn't consider isolated page and
mlocked page.

Then, This patch make explicit Shmem/Tmpfs vm-stat accounting.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 drivers/base/node.c    |    2 ++
 fs/proc/meminfo.c      |    2 ++
 include/linux/mmzone.h |    1 +
 mm/filemap.c           |    4 ++++
 mm/migrate.c           |    4 ++++
 mm/page_alloc.c        |    5 ++++-
 mm/vmstat.c            |    1 +
 7 files changed, 18 insertions(+), 1 deletion(-)

Index: b/drivers/base/node.c
===================================================================
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -87,6 +87,7 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d FilePages:      %8lu kB\n"
 		       "Node %d Mapped:         %8lu kB\n"
 		       "Node %d AnonPages:      %8lu kB\n"
+		       "Node %d Shmem:          %8lu kB\n"
 		       "Node %d KernelStack:    %8lu kB\n"
 		       "Node %d PageTables:     %8lu kB\n"
 		       "Node %d NFS_Unstable:   %8lu kB\n"
@@ -121,6 +122,7 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
 		       nid, K(node_page_state(nid, NR_FILE_MAPPED)),
 		       nid, K(node_page_state(nid, NR_ANON_PAGES)),
+		       nid, K(node_page_state(nid, NR_SHMEM)),
 		       nid, node_page_state(nid, NR_KERNEL_STACK) *
 				THREAD_SIZE / 1024,
 		       nid, K(node_page_state(nid, NR_PAGETABLE)),
Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -83,6 +83,7 @@ static int meminfo_proc_show(struct seq_
 		"Writeback:      %8lu kB\n"
 		"AnonPages:      %8lu kB\n"
 		"Mapped:         %8lu kB\n"
+		"Shmem:          %8lu kB\n"
 		"Slab:           %8lu kB\n"
 		"SReclaimable:   %8lu kB\n"
 		"SUnreclaim:     %8lu kB\n"
@@ -129,6 +130,7 @@ static int meminfo_proc_show(struct seq_
 		K(global_page_state(NR_WRITEBACK)),
 		K(global_page_state(NR_ANON_PAGES)),
 		K(global_page_state(NR_FILE_MAPPED)),
+		K(global_page_state(NR_SHMEM)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE) +
 				global_page_state(NR_SLAB_UNRECLAIMABLE)),
 		K(global_page_state(NR_SLAB_RECLAIMABLE)),
Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -102,6 +102,7 @@ enum zone_stat_item {
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
 	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
 	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
+	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
Index: b/mm/filemap.c
===================================================================
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -120,6 +120,8 @@ void __remove_from_page_cache(struct pag
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
+	if (PageSwapBacked(page))
+		__dec_zone_page_state(page, NR_SHMEM);
 	BUG_ON(page_mapped(page));
 
 	/*
@@ -476,6 +478,8 @@ int add_to_page_cache_locked(struct page
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
+			if (PageSwapBacked(page))
+				__inc_zone_page_state(page, NR_SHMEM);
 			spin_unlock_irq(&mapping->tree_lock);
 		} else {
 			page->mapping = NULL;
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -646,6 +646,7 @@ static const char * const vmstat_text[] 
 	"nr_writeback_temp",
 	"nr_isolated_anon",
 	"nr_isolated_file",
+	"nr_shmem",
 #ifdef CONFIG_NUMA
 	"numa_hit",
 	"numa_miss",
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2120,7 +2120,7 @@ void show_free_areas(void)
 		" unevictable:%lu\n"
 		" dirty:%lu writeback:%lu unstable:%lu buffer:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
-		" mapped:%lu pagetables:%lu bounce:%lu\n",
+		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
 		global_page_state(NR_INACTIVE_ANON),
 		global_page_state(NR_ISOLATED_ANON),
@@ -2136,6 +2136,7 @@ void show_free_areas(void)
 		global_page_state(NR_SLAB_RECLAIMABLE),
 		global_page_state(NR_SLAB_UNRECLAIMABLE),
 		global_page_state(NR_FILE_MAPPED),
+		global_page_state(NR_SHMEM),
 		global_page_state(NR_PAGETABLE),
 		global_page_state(NR_BOUNCE));
 
@@ -2160,6 +2161,7 @@ void show_free_areas(void)
 			" dirty:%lukB"
 			" writeback:%lukB"
 			" mapped:%lukB"
+			" shmem:%lukB"
 			" slab_reclaimable:%lukB"
 			" slab_unreclaimable:%lukB"
 			" kernel_stack:%lukB"
@@ -2187,6 +2189,7 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_FILE_DIRTY)),
 			K(zone_page_state(zone, NR_WRITEBACK)),
 			K(zone_page_state(zone, NR_FILE_MAPPED)),
+			K(zone_page_state(zone, NR_SHMEM)),
 			K(zone_page_state(zone, NR_SLAB_RECLAIMABLE)),
 			K(zone_page_state(zone, NR_SLAB_UNRECLAIMABLE)),
 			zone_page_state(zone, NR_KERNEL_STACK) *
Index: b/mm/migrate.c
===================================================================
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -312,7 +312,11 @@ static int migrate_page_move_mapping(str
 	 */
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
+	if (PageSwapBacked(page)) {
+		__dec_zone_page_state(page, NR_SHMEM);
+		__inc_zone_page_state(newpage, NR_SHMEM);
 
+	}
 	spin_unlock_irq(&mapping->tree_lock);
 
 	return 0;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
