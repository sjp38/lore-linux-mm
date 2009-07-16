Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id B30AC6B0062
	for <linux-mm@kvack.org>; Wed, 15 Jul 2009 20:55:42 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6G0tnxA017430
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 16 Jul 2009 09:55:49 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1F4EC45DE50
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:55:49 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id EC26D45DE4F
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:55:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CA59AE08006
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:55:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0F2811DB803C
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 09:55:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com>
Message-Id: <20090716095344.9D10.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 16 Jul 2009 09:55:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

ChangeLog
  Since v5
   - Rewrote the description
   - Treat page migration
  Since v4
   - Changed displaing order in show_free_areas() (as Wu's suggested)
  Since v3
   - Fixed misaccount page bug when lumby reclaim occur
  Since v2
   - Separated IsolateLRU field to Isolated(anon) and Isolated(file)
  Since v1
   - Renamed IsolatePages to IsolatedLRU

==================================
Subject: [PATCH] add isolate pages vmstat

If the system is running a heavy load of processes then concurrent reclaim
can isolate a large numbe of pages from the LRU. /proc/meminfo and the
output generated for an OOM do not show how many pages were isolated.

This patch shows the information about isolated pages.


reproduce way
-----------------------
% ./hackbench 140 process 1000
   => OOM occur

active_anon:146 inactive_anon:0 isolated_anon:49245
 active_file:79 inactive_file:18 isolated_file:113
 unevictable:0 dirty:0 writeback:0 unstable:0 buffer:39
 free:370 slab_reclaimable:309 slab_unreclaimable:5492
 mapped:53 shmem:15 pagetables:28140 bounce:0


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Acked-by: Rik van Riel <riel@redhat.com>
Acked-by: Wu Fengguang <fengguang.wu@intel.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
---
 drivers/base/node.c    |    4 ++++
 fs/proc/meminfo.c      |    4 ++++
 include/linux/mmzone.h |    2 ++
 mm/migrate.c           |   11 +++++++++++
 mm/page_alloc.c        |   12 +++++++++---
 mm/vmscan.c            |   12 +++++++++++-
 mm/vmstat.c            |    2 ++
 7 files changed, 43 insertions(+), 4 deletions(-)

Index: b/fs/proc/meminfo.c
===================================================================
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -65,6 +65,8 @@ static int meminfo_proc_show(struct seq_
 		"Active(file):   %8lu kB\n"
 		"Inactive(file): %8lu kB\n"
 		"Unevictable:    %8lu kB\n"
+		"Isolated(anon): %8lu kB\n"
+		"Isolated(file): %8lu kB\n"
 		"Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		"HighTotal:      %8lu kB\n"
@@ -110,6 +112,8 @@ static int meminfo_proc_show(struct seq_
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_UNEVICTABLE]),
+		K(global_page_state(NR_ISOLATED_ANON)),
+		K(global_page_state(NR_ISOLATED_FILE)),
 		K(global_page_state(NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -100,6 +100,8 @@ enum zone_stat_item {
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
 	NR_WRITEBACK_TEMP,	/* Writeback using temporary buffers */
+	NR_ISOLATED_ANON,	/* Temporary isolated pages from anon lru */
+	NR_ISOLATED_FILE,	/* Temporary isolated pages from file lru */
 	NR_SHMEM,		/* shmem pages (included tmpfs/GEM pages) */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2115,16 +2115,18 @@ void show_free_areas(void)
 		}
 	}
 
-	printk("Active_anon:%lu active_file:%lu inactive_anon:%lu\n"
-		" inactive_file:%lu"
+	printk("active_anon:%lu inactive_anon:%lu isolated_anon:%lu\n"
+		" active_file:%lu inactive_file:%lu isolated_file:%lu\n"
 		" unevictable:%lu"
 		" dirty:%lu writeback:%lu unstable:%lu buffer:%lu\n"
 		" free:%lu slab_reclaimable:%lu slab_unreclaimable:%lu\n"
 		" mapped:%lu shmem:%lu pagetables:%lu bounce:%lu\n",
 		global_page_state(NR_ACTIVE_ANON),
-		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_ANON),
+		global_page_state(NR_ISOLATED_ANON),
+		global_page_state(NR_ACTIVE_FILE),
 		global_page_state(NR_INACTIVE_FILE),
+		global_page_state(NR_ISOLATED_FILE),
 		global_page_state(NR_UNEVICTABLE),
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
@@ -2152,6 +2154,8 @@ void show_free_areas(void)
 			" active_file:%lukB"
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
+			" isolated(anon):%lukB"
+			" isolated(file):%lukB"
 			" present:%lukB"
 			" mlocked:%lukB"
 			" dirty:%lukB"
@@ -2178,6 +2182,8 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
 			K(zone_page_state(zone, NR_UNEVICTABLE)),
+			K(zone_page_state(zone, NR_ISOLATED_ANON)),
+			K(zone_page_state(zone, NR_ISOLATED_FILE)),
 			K(zone->present_pages),
 			K(zone_page_state(zone, NR_MLOCK)),
 			K(zone_page_state(zone, NR_FILE_DIRTY)),
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1067,6 +1067,8 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_active;
 		unsigned int count[NR_LRU_LISTS] = { 0, };
 		int mode = lumpy_reclaim ? ISOLATE_BOTH : ISOLATE_INACTIVE;
+		unsigned long nr_anon;
+		unsigned long nr_file;
 
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
 			     &page_list, &nr_scan, sc->order, mode,
@@ -1097,6 +1099,10 @@ static unsigned long shrink_inactive_lis
 		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
 						-count[LRU_INACTIVE_ANON]);
 
+		nr_anon = count[LRU_ACTIVE_ANON] + count[LRU_INACTIVE_ANON];
+		nr_file = count[LRU_ACTIVE_FILE] + count[LRU_INACTIVE_FILE];
+		__mod_zone_page_state(zone, NR_ISOLATED_ANON, nr_anon);
+		__mod_zone_page_state(zone, NR_ISOLATED_FILE, nr_file);
 
 		reclaim_stat->recent_scanned[0] += count[LRU_INACTIVE_ANON];
 		reclaim_stat->recent_scanned[0] += count[LRU_ACTIVE_ANON];
@@ -1164,6 +1170,9 @@ static unsigned long shrink_inactive_lis
 				spin_lock_irq(&zone->lru_lock);
 			}
 		}
+		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
+		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
+
   	} while (nr_scanned < max_scan);
 
 done:
@@ -1274,6 +1283,7 @@ static void shrink_active_list(unsigned 
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_taken);
 	else
 		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_taken);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
@@ -1324,7 +1334,7 @@ static void shrink_active_list(unsigned 
 						LRU_ACTIVE + file * LRU_FILE);
 	move_active_pages_to_lru(zone, &l_inactive,
 						LRU_BASE   + file * LRU_FILE);
-
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
 	spin_unlock_irq(&zone->lru_lock);
 }
 
Index: b/mm/vmstat.c
===================================================================
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -644,6 +644,8 @@ static const char * const vmstat_text[] 
 	"nr_bounce",
 	"nr_vmscan_write",
 	"nr_writeback_temp",
+	"nr_isolated_anon",
+	"nr_isolated_file",
 	"nr_shmem",
 #ifdef CONFIG_NUMA
 	"numa_hit",
Index: b/drivers/base/node.c
===================================================================
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -73,6 +73,8 @@ static ssize_t node_read_meminfo(struct 
 		       "Node %d Active(file):   %8lu kB\n"
 		       "Node %d Inactive(file): %8lu kB\n"
 		       "Node %d Unevictable:    %8lu kB\n"
+		       "Node %d Isolated(anon): %8lu kB\n"
+		       "Node %d Isolated(file): %8lu kB\n"
 		       "Node %d Mlocked:        %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
 		       "Node %d HighTotal:      %8lu kB\n"
@@ -106,6 +108,8 @@ static ssize_t node_read_meminfo(struct 
 		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(node_page_state(nid, NR_ISOLATED_ANON)),
+		       nid, K(node_page_state(nid, NR_ISOLATED_FILE)),
 		       nid, K(node_page_state(nid, NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
Index: b/mm/migrate.c
===================================================================
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -67,6 +67,8 @@ int putback_lru_pages(struct list_head *
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				    !!page_is_file_cache(page));
 		putback_lru_page(page);
 		count++;
 	}
@@ -696,6 +698,8 @@ unlock:
  		 * restored.
  		 */
  		list_del(&page->lru);
+		dec_zone_page_state(page, NR_ISOLATED_ANON +
+				    !!page_is_file_cache(page));
 		putback_lru_page(page);
 	}
 
@@ -740,6 +744,13 @@ int migrate_pages(struct list_head *from
 	struct page *page2;
 	int swapwrite = current->flags & PF_SWAPWRITE;
 	int rc;
+	int flags;
+
+	local_irq_save(flags);
+	list_for_each_entry(page, from, lru)
+		__inc_zone_page_state(page, NR_ISOLATED_ANON +
+				      !!page_is_file_cache(page));
+	local_irq_restore(flags);
 
 	if (!swapwrite)
 		current->flags |= PF_SWAPWRITE;


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
