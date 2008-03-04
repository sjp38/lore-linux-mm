Message-Id: <20080304225227.135854906@redhat.com>
References: <20080304225157.573336066@redhat.com>
Date: Tue, 04 Mar 2008 17:52:03 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 06/20] split LRU lists into anon & file sets
Content-Disposition: inline; filename=rvr-02-linux-2.6-vm-split-lrus.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Split the LRU lists in two, one set for pages that are backed by
real file systems ("file") and one for pages that are backed by
memory and swap ("anon").  The latter includes tmpfs.

Eventually mlocked pages will be taken off the LRUs alltogether.
A patch for that already exists and just needs to be integrated
into this series.

This patch mostly has the infrastructure and a basic policy to
balance how much we scan the anon lists and how much we scan
the file lists. The big policy changes are in separate patches.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Index: linux-2.6.25-rc3-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/fs/proc/proc_misc.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/fs/proc/proc_misc.c	2008-03-04 15:30:20.000000000 -0500
@@ -131,6 +131,10 @@ static int meminfo_read_proc(char *page,
 	unsigned long allowed;
 	struct vmalloc_info vmi;
 	long cached;
+	unsigned long inactive_anon;
+	unsigned long active_anon;
+	unsigned long inactive_file;
+	unsigned long active_file;
 
 /*
  * display in kilobytes.
@@ -149,47 +153,60 @@ static int meminfo_read_proc(char *page,
 
 	get_vmalloc_info(&vmi);
 
+	inactive_anon = global_page_state(NR_INACTIVE_ANON);
+	active_anon   = global_page_state(NR_ACTIVE_ANON);
+	inactive_file = global_page_state(NR_INACTIVE_FILE);
+	active_file   = global_page_state(NR_ACTIVE_FILE);
+
 	/*
 	 * Tagged format, for easy grepping and expansion.
 	 */
 	len = sprintf(page,
-		"MemTotal:     %8lu kB\n"
-		"MemFree:      %8lu kB\n"
-		"Buffers:      %8lu kB\n"
-		"Cached:       %8lu kB\n"
-		"SwapCached:   %8lu kB\n"
-		"Active:       %8lu kB\n"
-		"Inactive:     %8lu kB\n"
+		"MemTotal:       %8lu kB\n"
+		"MemFree:        %8lu kB\n"
+		"Buffers:        %8lu kB\n"
+		"Cached:         %8lu kB\n"
+		"SwapCached:     %8lu kB\n"
+		"Active:         %8lu kB\n"
+		"Inactive:       %8lu kB\n"
+		"Active(anon):   %8lu kB\n"
+		"Inactive(anon): %8lu kB\n"
+		"Active(file):   %8lu kB\n"
+		"Inactive(file): %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
-		"HighTotal:    %8lu kB\n"
-		"HighFree:     %8lu kB\n"
-		"LowTotal:     %8lu kB\n"
-		"LowFree:      %8lu kB\n"
-#endif
-		"SwapTotal:    %8lu kB\n"
-		"SwapFree:     %8lu kB\n"
-		"Dirty:        %8lu kB\n"
-		"Writeback:    %8lu kB\n"
-		"AnonPages:    %8lu kB\n"
-		"Mapped:       %8lu kB\n"
-		"Slab:         %8lu kB\n"
-		"SReclaimable: %8lu kB\n"
-		"SUnreclaim:   %8lu kB\n"
-		"PageTables:   %8lu kB\n"
-		"NFS_Unstable: %8lu kB\n"
-		"Bounce:       %8lu kB\n"
-		"CommitLimit:  %8lu kB\n"
-		"Committed_AS: %8lu kB\n"
-		"VmallocTotal: %8lu kB\n"
-		"VmallocUsed:  %8lu kB\n"
-		"VmallocChunk: %8lu kB\n",
+		"HighTotal:      %8lu kB\n"
+		"HighFree:       %8lu kB\n"
+		"LowTotal:       %8lu kB\n"
+		"LowFree:        %8lu kB\n"
+#endif
+		"SwapTotal:      %8lu kB\n"
+		"SwapFree:       %8lu kB\n"
+		"Dirty:          %8lu kB\n"
+		"Writeback:      %8lu kB\n"
+		"AnonPages:      %8lu kB\n"
+		"Mapped:         %8lu kB\n"
+		"Slab:           %8lu kB\n"
+		"SReclaimable:   %8lu kB\n"
+		"SUnreclaim:     %8lu kB\n"
+		"PageTables:     %8lu kB\n"
+		"NFS_Unstable:   %8lu kB\n"
+		"Bounce:         %8lu kB\n"
+		"CommitLimit:    %8lu kB\n"
+		"Committed_AS:   %8lu kB\n"
+		"VmallocTotal:   %8lu kB\n"
+		"VmallocUsed:    %8lu kB\n"
+		"VmallocChunk:   %8lu kB\n",
 		K(i.totalram),
 		K(i.freeram),
 		K(i.bufferram),
 		K(cached),
 		K(total_swapcache_pages),
-		K(global_page_state(NR_ACTIVE)),
-		K(global_page_state(NR_INACTIVE)),
+		K(active_anon   + active_file),
+		K(inactive_anon + inactive_file),
+		K(active_anon),
+		K(inactive_anon),
+		K(active_file),
+		K(inactive_file),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
Index: linux-2.6.25-rc3-mm1/fs/cifs/file.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/fs/cifs/file.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/fs/cifs/file.c	2008-03-04 15:30:20.000000000 -0500
@@ -1778,7 +1778,7 @@ static void cifs_copy_cache_pages(struct
 		SetPageUptodate(page);
 		unlock_page(page);
 		if (!pagevec_add(plru_pvec, page))
-			__pagevec_lru_add(plru_pvec);
+			__pagevec_lru_add_file(plru_pvec);
 		data += PAGE_CACHE_SIZE;
 	}
 	return;
@@ -1912,7 +1912,7 @@ static int cifs_readpages(struct file *f
 		bytes_read = 0;
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 
 /* need to free smb_read_data buf before exit */
 	if (smb_read_data) {
Index: linux-2.6.25-rc3-mm1/fs/ntfs/file.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/fs/ntfs/file.c	2008-03-04 14:12:39.000000000 -0500
+++ linux-2.6.25-rc3-mm1/fs/ntfs/file.c	2008-03-04 15:30:20.000000000 -0500
@@ -439,7 +439,7 @@ static inline int __ntfs_grab_cache_page
 			pages[nr] = *cached_page;
 			page_cache_get(*cached_page);
 			if (unlikely(!pagevec_add(lru_pvec, *cached_page)))
-				__pagevec_lru_add(lru_pvec);
+				__pagevec_lru_add_file(lru_pvec);
 			*cached_page = NULL;
 		}
 		index++;
@@ -2084,7 +2084,7 @@ err_out:
 						OSYNC_METADATA|OSYNC_DATA);
 		}
   	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	ntfs_debug("Done.  Returning %s (written 0x%lx, status %li).",
 			written ? "written" : "status", (unsigned long)written,
 			(long)status);
Index: linux-2.6.25-rc3-mm1/fs/nfs/dir.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/fs/nfs/dir.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/fs/nfs/dir.c	2008-03-04 15:30:20.000000000 -0500
@@ -1522,7 +1522,7 @@ static int nfs_symlink(struct inode *dir
 	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
 		pagevec_add(&lru_pvec, page);
-		pagevec_lru_add(&lru_pvec);
+		pagevec_lru_add_file(&lru_pvec);
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else
Index: linux-2.6.25-rc3-mm1/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/fs/ramfs/file-nommu.c	2008-03-04 14:12:20.000000000 -0500
+++ linux-2.6.25-rc3-mm1/fs/ramfs/file-nommu.c	2008-03-04 15:30:20.000000000 -0500
@@ -111,12 +111,12 @@ static int ramfs_nommu_expand_for_mappin
 			goto add_error;
 
 		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+			__pagevec_lru_add_file(&lru_pvec);
 
 		unlock_page(page);
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	return 0;
 
  fsize_exceeded:
Index: linux-2.6.25-rc3-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/drivers/base/node.c	2008-03-04 14:12:51.000000000 -0500
+++ linux-2.6.25-rc3-mm1/drivers/base/node.c	2008-03-04 15:30:20.000000000 -0500
@@ -45,33 +45,37 @@ static ssize_t node_read_meminfo(struct 
 	si_meminfo_node(&i, nid);
 
 	n = sprintf(buf, "\n"
-		       "Node %d MemTotal:     %8lu kB\n"
-		       "Node %d MemFree:      %8lu kB\n"
-		       "Node %d MemUsed:      %8lu kB\n"
-		       "Node %d Active:       %8lu kB\n"
-		       "Node %d Inactive:     %8lu kB\n"
+		       "Node %d MemTotal:       %8lu kB\n"
+		       "Node %d MemFree:        %8lu kB\n"
+		       "Node %d MemUsed:        %8lu kB\n"
+		       "Node %d Active(anon):   %8lu kB\n"
+		       "Node %d Inactive(anon): %8lu kB\n"
+		       "Node %d Active(file):   %8lu kB\n"
+		       "Node %d Inactive(file): %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
-		       "Node %d HighTotal:    %8lu kB\n"
-		       "Node %d HighFree:     %8lu kB\n"
-		       "Node %d LowTotal:     %8lu kB\n"
-		       "Node %d LowFree:      %8lu kB\n"
+		       "Node %d HighTotal:      %8lu kB\n"
+		       "Node %d HighFree:       %8lu kB\n"
+		       "Node %d LowTotal:       %8lu kB\n"
+		       "Node %d LowFree:        %8lu kB\n"
 #endif
-		       "Node %d Dirty:        %8lu kB\n"
-		       "Node %d Writeback:    %8lu kB\n"
-		       "Node %d FilePages:    %8lu kB\n"
-		       "Node %d Mapped:       %8lu kB\n"
-		       "Node %d AnonPages:    %8lu kB\n"
-		       "Node %d PageTables:   %8lu kB\n"
-		       "Node %d NFS_Unstable: %8lu kB\n"
-		       "Node %d Bounce:       %8lu kB\n"
-		       "Node %d Slab:         %8lu kB\n"
-		       "Node %d SReclaimable: %8lu kB\n"
-		       "Node %d SUnreclaim:   %8lu kB\n",
+		       "Node %d Dirty:          %8lu kB\n"
+		       "Node %d Writeback:      %8lu kB\n"
+		       "Node %d FilePages:      %8lu kB\n"
+		       "Node %d Mapped:         %8lu kB\n"
+		       "Node %d AnonPages:      %8lu kB\n"
+		       "Node %d PageTables:     %8lu kB\n"
+		       "Node %d NFS_Unstable:   %8lu kB\n"
+		       "Node %d Bounce:         %8lu kB\n"
+		       "Node %d Slab:           %8lu kB\n"
+		       "Node %d SReclaimable:   %8lu kB\n"
+		       "Node %d SUnreclaim:     %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
-		       nid, node_page_state(nid, NR_ACTIVE),
-		       nid, node_page_state(nid, NR_INACTIVE),
+		       nid, node_page_state(nid, NR_ACTIVE_ANON),
+		       nid, node_page_state(nid, NR_INACTIVE_ANON),
+		       nid, node_page_state(nid, NR_ACTIVE_FILE),
+		       nid, node_page_state(nid, NR_INACTIVE_FILE),
 #ifdef CONFIG_HIGHMEM
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
Index: linux-2.6.25-rc3-mm1/mm/memory.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/memory.c	2008-03-04 15:30:02.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/memory.c	2008-03-04 15:30:20.000000000 -0500
@@ -1678,7 +1678,7 @@ gotten:
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		SetPageSwapBacked(new_page);
-		lru_cache_add_active(new_page);
+		lru_cache_add_active_anon(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2147,7 +2147,7 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	SetPageSwapBacked(page);
-	lru_cache_add_active(page);
+	lru_cache_add_active_anon(page);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2291,7 +2291,7 @@ static int __do_fault(struct mm_struct *
 		if (anon) {
                         inc_mm_counter(mm, anon_rss);
 			SetPageSwapBacked(page);
-                        lru_cache_add_active(page);
+                        lru_cache_add_active_anon(page);
                         page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
Index: linux-2.6.25-rc3-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/page_alloc.c	2008-03-04 15:30:02.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/page_alloc.c	2008-03-04 15:30:20.000000000 -0500
@@ -1904,10 +1904,13 @@ void show_free_areas(void)
 		}
 	}
 
-	printk("Active:%lu inactive:%lu dirty:%lu writeback:%lu unstable:%lu\n"
+	printk("Active_anon:%lu active_file:%lu inactive_anon%lu\n"
+		" inactive_file:%lu dirty:%lu writeback:%lu unstable:%lu\n"
 		" free:%lu slab:%lu mapped:%lu pagetables:%lu bounce:%lu\n",
-		global_page_state(NR_ACTIVE),
-		global_page_state(NR_INACTIVE),
+		global_page_state(NR_ACTIVE_ANON),
+		global_page_state(NR_ACTIVE_FILE),
+		global_page_state(NR_INACTIVE_ANON),
+		global_page_state(NR_INACTIVE_FILE),
 		global_page_state(NR_FILE_DIRTY),
 		global_page_state(NR_WRITEBACK),
 		global_page_state(NR_UNSTABLE_NFS),
@@ -1930,8 +1933,10 @@ void show_free_areas(void)
 			" min:%lukB"
 			" low:%lukB"
 			" high:%lukB"
-			" active:%lukB"
-			" inactive:%lukB"
+			" active_anon:%lukB"
+			" inactive_anon:%lukB"
+			" active_file:%lukB"
+			" inactive_file:%lukB"
 			" present:%lukB"
 			" pages_scanned:%lu"
 			" all_unreclaimable? %s"
@@ -1941,8 +1946,10 @@ void show_free_areas(void)
 			K(zone->pages_min),
 			K(zone->pages_low),
 			K(zone->pages_high),
-			K(zone_page_state(zone, NR_ACTIVE)),
-			K(zone_page_state(zone, NR_INACTIVE)),
+			K(zone_page_state(zone, NR_ACTIVE_ANON)),
+			K(zone_page_state(zone, NR_INACTIVE_ANON)),
+			K(zone_page_state(zone, NR_ACTIVE_FILE)),
+			K(zone_page_state(zone, NR_INACTIVE_FILE)),
 			K(zone->present_pages),
 			zone->pages_scanned,
 			(zone_is_all_unreclaimable(zone) ? "yes" : "no")
@@ -3476,6 +3483,9 @@ static void __paginginit free_area_init_
 			INIT_LIST_HEAD(&zone->list[l]);
 			zone->nr_scan[l] = 0;
 		}
+		zone->recent_rotated_anon = 0;
+		zone->recent_rotated_file = 0;
+//TODO recent_scanned_* ???
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
Index: linux-2.6.25-rc3-mm1/mm/swap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/swap.c	2008-03-04 15:29:50.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/swap.c	2008-03-04 15:30:20.000000000 -0500
@@ -109,6 +109,7 @@ enum lru_list page_lru(struct page *page
 
 	if (PageActive(page))
 		lru += LRU_ACTIVE;
+	lru += page_file_cache(page);
 
 	return lru;
 }
@@ -134,7 +135,8 @@ static void pagevec_move_tail(struct pag
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page)) {
-			list_move_tail(&page->lru, &zone->list[LRU_INACTIVE]);
+			int lru = page_file_cache(page);
+			list_move_tail(&page->lru, &zone->list[lru]);
 			pgmoved++;
 		}
 	}
@@ -188,9 +190,13 @@ void activate_page(struct page *page)
 
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
+		int lru = LRU_BASE;
+		lru += page_file_cache(page);
+		del_page_from_lru_list(zone, page, lru);
+
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		lru += LRU_ACTIVE;
+		add_page_to_lru_list(zone, page, lru);
 		__count_vm_event(PGACTIVATE);
 		mem_cgroup_move_lists(page, true);
 	}
Index: linux-2.6.25-rc3-mm1/mm/readahead.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/readahead.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/readahead.c	2008-03-04 15:30:20.000000000 -0500
@@ -229,7 +229,7 @@ int do_page_cache_readahead(struct addre
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
+	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
 
Index: linux-2.6.25-rc3-mm1/mm/filemap.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/filemap.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/filemap.c	2008-03-04 15:30:20.000000000 -0500
@@ -34,6 +34,7 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/mm_inline.h> /* for page_file_cache() */
 #include "internal.h"
 
 /*
@@ -493,8 +494,12 @@ int add_to_page_cache_lru(struct page *p
 				pgoff_t offset, gfp_t gfp_mask)
 {
 	int ret = add_to_page_cache(page, mapping, offset, gfp_mask);
-	if (ret == 0)
-		lru_cache_add(page);
+	if (ret == 0) {
+		if (page_file_cache(page))
+			lru_cache_add_file(page);
+		else
+			lru_cache_add_active_anon(page);
+	}
 	return ret;
 }
 
Index: linux-2.6.25-rc3-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/vmstat.c	2008-03-04 14:59:31.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/vmstat.c	2008-03-04 15:30:20.000000000 -0500
@@ -686,8 +686,10 @@ const struct seq_operations pagetypeinfo
 static const char * const vmstat_text[] = {
 	/* Zoned VM counters */
 	"nr_free_pages",
-	"nr_inactive",
-	"nr_active",
+	"nr_inactive_anon",
+	"nr_active_anon",
+	"nr_inactive_file",
+	"nr_active_file",
 	"nr_anon_pages",
 	"nr_mapped",
 	"nr_file_pages",
@@ -750,7 +752,7 @@ static void zoneinfo_show_print(struct s
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n        scanned  %lu (a: %lu i: %lu)"
+		   "\n        scanned  %lu (aa: %lu ia: %lu af: %lu if: %lu)"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
@@ -758,8 +760,10 @@ static void zoneinfo_show_print(struct s
 		   zone->pages_low,
 		   zone->pages_high,
 		   zone->pages_scanned,
-		   zone->nr_scan[LRU_ACTIVE],
-		   zone->nr_scan[LRU_INACTIVE],
+		   zone->nr_scan[LRU_ACTIVE_ANON],
+		   zone->nr_scan[LRU_INACTIVE_ANON],
+		   zone->nr_scan[LRU_ACTIVE_FILE],
+		   zone->nr_scan[LRU_INACTIVE_FILE],
 		   zone->spanned_pages,
 		   zone->present_pages);
 
Index: linux-2.6.25-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/vmscan.c	2008-03-04 15:29:50.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/vmscan.c	2008-03-04 15:38:31.000000000 -0500
@@ -71,6 +71,9 @@ struct scan_control {
 
 	int order;
 
+	/* The number of pages moved to the active list this pass. */
+	int activated;
+
 	/*
 	 * Pages that have (or should have) IO pending.  If we run into
 	 * a lot of these, we're better off waiting a little for IO to
@@ -85,7 +88,7 @@ struct scan_control {
 	unsigned long (*isolate_pages)(unsigned long nr, struct list_head *dst,
 			unsigned long *scanned, int order, int mode,
 			struct zone *z, struct mem_cgroup *mem_cont,
-			int active);
+			int active, int file);
 };
 
 #define lru_to_page(_head) (list_entry((_head)->prev, struct page, lru))
@@ -243,27 +246,6 @@ unsigned long shrink_slab(unsigned long 
 	return ret;
 }
 
-/* Called without lock on whether page is mapped, so answer is unstable */
-static inline int page_mapping_inuse(struct page *page)
-{
-	struct address_space *mapping;
-
-	/* Page is in somebody's page tables. */
-	if (page_mapped(page))
-		return 1;
-
-	/* Be more reluctant to reclaim swapcache than pagecache */
-	if (PageSwapCache(page))
-		return 1;
-
-	mapping = page_mapping(page);
-	if (!mapping)
-		return 0;
-
-	/* File is mmap'd by somebody? */
-	return mapping_mapped(mapping);
-}
-
 static inline int is_page_cache_freeable(struct page *page)
 {
 	return page_count(page) - !!PagePrivate(page) == 2;
@@ -527,8 +509,7 @@ static unsigned long shrink_page_list(st
 
 		referenced = page_referenced(page, 1, sc->mem_cgroup);
 		/* In active use or really unfreeable?  Activate it. */
-		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page))
+		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -559,8 +540,6 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
-				goto keep_locked;
 			if (!may_enter_fs) {
 				sc->nr_io_pages++;
 				goto keep_locked;
@@ -647,6 +626,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
+	sc->activated = pgactivate;
 	return nr_reclaimed;
 }
 
@@ -665,7 +645,7 @@ keep:
  *
  * returns 0 on success, -ve errno on failure.
  */
-int __isolate_lru_page(struct page *page, int mode)
+int __isolate_lru_page(struct page *page, int mode, int file)
 {
 	int ret = -EINVAL;
 
@@ -681,6 +661,9 @@ int __isolate_lru_page(struct page *page
 	if (mode != ISOLATE_BOTH && (!PageActive(page) != !mode))
 		return ret;
 
+	if (mode != ISOLATE_BOTH && (!page_file_cache(page) != !file))
+		return ret;
+
 	ret = -EBUSY;
 	if (likely(get_page_unless_zero(page))) {
 		/*
@@ -711,12 +694,13 @@ int __isolate_lru_page(struct page *page
  * @scanned:	The number of pages that were scanned.
  * @order:	The caller's attempted allocation order
  * @mode:	One of the LRU isolation modes
+ * @file:	True [1] if isolating file [!anon] pages
  *
  * returns how many pages were moved onto *@dst.
  */
 static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		struct list_head *src, struct list_head *dst,
-		unsigned long *scanned, int order, int mode)
+		unsigned long *scanned, int order, int mode, int file)
 {
 	unsigned long nr_taken = 0;
 	unsigned long scan;
@@ -733,7 +717,7 @@ static unsigned long isolate_lru_pages(u
 
 		VM_BUG_ON(!PageLRU(page));
 
-		switch (__isolate_lru_page(page, mode)) {
+		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
 			list_move(&page->lru, dst);
 			nr_taken++;
@@ -776,10 +760,11 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			cursor_page = pfn_to_page(pfn);
+
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
-			switch (__isolate_lru_page(cursor_page, mode)) {
+			switch (__isolate_lru_page(cursor_page, mode, file)) {
 			case 0:
 				list_move(&cursor_page->lru, dst);
 				nr_taken++;
@@ -804,30 +789,37 @@ static unsigned long isolate_pages_globa
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active)
+					int active, int file)
 {
+	int lru = LRU_BASE;
 	if (active)
-		return isolate_lru_pages(nr, &z->list[LRU_ACTIVE], dst,
-						scanned, order, mode);
-	else
-		return isolate_lru_pages(nr, &z->list[LRU_INACTIVE], dst,
-						scanned, order, mode);
+		lru += LRU_ACTIVE;
+	if (file)
+		lru += LRU_FILE;
+	return isolate_lru_pages(nr, &z->list[lru], dst, scanned, order,
+								mode, !!file);
 }
 
 /*
  * clear_active_flags() is a helper for shrink_active_list(), clearing
  * any active bits from the pages in the list.
  */
-static unsigned long clear_active_flags(struct list_head *page_list)
+static unsigned long clear_active_flags(struct list_head *page_list,
+					unsigned int *count)
 {
 	int nr_active = 0;
+	int lru;
 	struct page *page;
 
-	list_for_each_entry(page, page_list, lru)
+	list_for_each_entry(page, page_list, lru) {
+		lru = page_file_cache(page);
 		if (PageActive(page)) {
+			lru += LRU_ACTIVE;
 			ClearPageActive(page);
 			nr_active++;
 		}
+		count[lru]++;
+	}
 
 	return nr_active;
 }
@@ -865,12 +857,12 @@ int isolate_lru_page(struct page *page)
 
 		spin_lock_irq(&zone->lru_lock);
 		if (PageLRU(page) && get_page_unless_zero(page)) {
+			int lru = LRU_BASE;
 			ret = 0;
 			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
+
+			lru += page_file_cache(page) + !!PageActive(page);
+			del_page_from_lru_list(zone, page, lru);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
@@ -882,7 +874,7 @@ int isolate_lru_page(struct page *page)
  * of reclaimed pages
  */
 static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+			struct zone *zone, struct scan_control *sc, int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -899,18 +891,25 @@ static unsigned long shrink_inactive_lis
 		unsigned long nr_scan;
 		unsigned long nr_freed;
 		unsigned long nr_active;
+		unsigned int count[NR_LRU_LISTS] = { 0, };
+		int mode = (sc->order > PAGE_ALLOC_COSTLY_ORDER) ?
+					ISOLATE_BOTH : ISOLATE_INACTIVE;
 
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
-			     &page_list, &nr_scan, sc->order,
-			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
-					     ISOLATE_BOTH : ISOLATE_INACTIVE,
-				zone, sc->mem_cgroup, 0);
-		nr_active = clear_active_flags(&page_list);
+			     &page_list, &nr_scan, sc->order, mode,
+				zone, sc->mem_cgroup, 0, file);
+		nr_active = clear_active_flags(&page_list, count);
 		__count_vm_events(PGDEACTIVATE, nr_active);
 
-		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);
-		__mod_zone_page_state(zone, NR_INACTIVE,
-						-(nr_taken - nr_active));
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE,
+						-count[LRU_ACTIVE_FILE]);
+		__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+						-count[LRU_INACTIVE_FILE]);
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON,
+						-count[LRU_ACTIVE_ANON]);
+		__mod_zone_page_state(zone, NR_INACTIVE_ANON,
+						-count[LRU_INACTIVE_ANON]);
+
 		if (scan_global_lru(sc))
 			zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
@@ -932,7 +931,7 @@ static unsigned long shrink_inactive_lis
 			 * The attempt at page out may have made some
 			 * of the pages active, mark them inactive again.
 			 */
-			nr_active = clear_active_flags(&page_list);
+			nr_active = clear_active_flags(&page_list, count);
 			count_vm_events(PGDEACTIVATE, nr_active);
 
 			nr_freed += shrink_page_list(&page_list, sc,
@@ -957,11 +956,20 @@ static unsigned long shrink_inactive_lis
 		 * Put back any unfreeable pages.
 		 */
 		while (!list_empty(&page_list)) {
+			int lru = LRU_BASE;
 			page = lru_to_page(&page_list);
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			add_page_to_lru_list(zone, page, PageActive(page));
+			if (page_file_cache(page)) {
+				lru += LRU_FILE;
+				zone->recent_rotated_file++;
+			} else {
+				zone->recent_rotated_anon++;
+			}
+			if (PageActive(page))
+				lru += LRU_ACTIVE;
+			add_page_to_lru_list(zone, page, lru);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -992,115 +1000,7 @@ static inline void note_zone_scanning_pr
 
 static inline int zone_is_near_oom(struct zone *zone)
 {
-	return zone->pages_scanned >= (zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE))*3;
-}
-
-/*
- * Determine we should try to reclaim mapped pages.
- * This is called only when sc->mem_cgroup is NULL.
- */
-static int calc_reclaim_mapped(struct scan_control *sc, struct zone *zone,
-				int priority)
-{
-	long mapped_ratio;
-	long distress;
-	long swap_tendency;
-	long imbalance;
-	int reclaim_mapped = 0;
-	int prev_priority;
-
-	if (scan_global_lru(sc) && zone_is_near_oom(zone))
-		return 1;
-	/*
-	 * `distress' is a measure of how much trouble we're having
-	 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
-	 */
-	if (scan_global_lru(sc))
-		prev_priority = zone->prev_priority;
-	else
-		prev_priority = mem_cgroup_get_reclaim_priority(sc->mem_cgroup);
-
-	distress = 100 >> min(prev_priority, priority);
-
-	/*
-	 * The point of this algorithm is to decide when to start
-	 * reclaiming mapped memory instead of just pagecache.  Work out
-	 * how much memory
-	 * is mapped.
-	 */
-	if (scan_global_lru(sc))
-		mapped_ratio = ((global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES)) * 100) /
-					vm_total_pages;
-	else
-		mapped_ratio = mem_cgroup_calc_mapped_ratio(sc->mem_cgroup);
-
-	/*
-	 * Now decide how much we really want to unmap some pages.  The
-	 * mapped ratio is downgraded - just because there's a lot of
-	 * mapped memory doesn't necessarily mean that page reclaim
-	 * isn't succeeding.
-	 *
-	 * The distress ratio is important - we don't want to start
-	 * going oom.
-	 *
-	 * A 100% value of vm_swappiness overrides this algorithm
-	 * altogether.
-	 */
-	swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
-
-	/*
-	 * If there's huge imbalance between active and inactive
-	 * (think active 100 times larger than inactive) we should
-	 * become more permissive, or the system will take too much
-	 * cpu before it start swapping during memory pressure.
-	 * Distress is about avoiding early-oom, this is about
-	 * making swappiness graceful despite setting it to low
-	 * values.
-	 *
-	 * Avoid div by zero with nr_inactive+1, and max resulting
-	 * value is vm_total_pages.
-	 */
-	if (scan_global_lru(sc)) {
-		imbalance  = zone_page_state(zone, NR_ACTIVE);
-		imbalance /= zone_page_state(zone, NR_INACTIVE) + 1;
-	} else
-		imbalance = mem_cgroup_reclaim_imbalance(sc->mem_cgroup);
-
-	/*
-	 * Reduce the effect of imbalance if swappiness is low,
-	 * this means for a swappiness very low, the imbalance
-	 * must be much higher than 100 for this logic to make
-	 * the difference.
-	 *
-	 * Max temporary value is vm_total_pages*100.
-	 */
-	imbalance *= (vm_swappiness + 1);
-	imbalance /= 100;
-
-	/*
-	 * If not much of the ram is mapped, makes the imbalance
-	 * less relevant, it's high priority we refill the inactive
-	 * list with mapped pages only in presence of high ratio of
-	 * mapped pages.
-	 *
-	 * Max temporary value is vm_total_pages*100.
-	 */
-	imbalance *= mapped_ratio;
-	imbalance /= 100;
-
-	/* apply imbalance feedback to swap_tendency */
-	swap_tendency += imbalance;
-
-	/*
-	 * Now use this metric to decide whether to start moving mapped
-	 * memory onto the inactive list.
-	 */
-	if (swap_tendency >= 100)
-		reclaim_mapped = 1;
-
-	return reclaim_mapped;
+	return zone->pages_scanned >= (zone_lru_pages(zone) * 3);
 }
 
 /*
@@ -1123,7 +1023,7 @@ static int calc_reclaim_mapped(struct sc
 
 
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc, int priority)
+			struct scan_control *sc, int priority, int file)
 {
 	unsigned long pgmoved;
 	int pgdeactivate = 0;
@@ -1133,16 +1033,13 @@ static void shrink_active_list(unsigned 
 	LIST_HEAD(l_inactive);
 	struct page *page;
 	struct pagevec pvec;
-	int reclaim_mapped = 0;
-
-	if (sc->may_swap)
-		reclaim_mapped = calc_reclaim_mapped(sc, zone, priority);
+	enum lru_list lru;
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
 					ISOLATE_ACTIVE, zone,
-					sc->mem_cgroup, 1);
+					sc->mem_cgroup, 1, file);
 	/*
 	 * zone->pages_scanned is used for detect zone's oom
 	 * mem_cgroup remembers nr_scan by itself.
@@ -1150,29 +1047,29 @@ static void shrink_active_list(unsigned 
 	if (scan_global_lru(sc))
 		zone->pages_scanned += pgscanned;
 
-	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
+	if (file)
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
+	else
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0, sc->mem_cgroup)) {
-				list_add(&page->lru, &l_active);
-				continue;
-			}
-		} else if (TestClearPageReferenced(page)) {
+		if (page_referenced(page, 0, sc->mem_cgroup))
 			list_add(&page->lru, &l_active);
-			continue;
-		}
-		list_add(&page->lru, &l_inactive);
+		else
+			list_add(&page->lru, &l_inactive);
 	}
 
+	/*
+	 * Now put the pages back on the appropriate [file or anon] inactive
+	 * and active lists.
+	 */
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
+	lru = LRU_BASE + file * LRU_FILE;
 	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
 		page = lru_to_page(&l_inactive);
@@ -1182,11 +1079,12 @@ static void shrink_active_list(unsigned 
 		VM_BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 
-		list_move(&page->lru, &zone->list[LRU_INACTIVE]);
+		list_move(&page->lru, &zone->list[lru]);
 		mem_cgroup_move_lists(page, false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru,
+								pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -1196,7 +1094,7 @@ static void shrink_active_list(unsigned 
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru, pgmoved);
 	pgdeactivate += pgmoved;
 	if (buffer_heads_over_limit) {
 		spin_unlock_irq(&zone->lru_lock);
@@ -1205,6 +1103,7 @@ static void shrink_active_list(unsigned 
 	}
 
 	pgmoved = 0;
+	lru = LRU_ACTIVE + file * LRU_FILE;
 	while (!list_empty(&l_active)) {
 		page = lru_to_page(&l_active);
 		prefetchw_prev_lru_page(page, &l_active, flags);
@@ -1212,11 +1111,12 @@ static void shrink_active_list(unsigned 
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 
-		list_move(&page->lru, &zone->list[LRU_ACTIVE]);
+		list_move(&page->lru, &zone->list[lru]);
 		mem_cgroup_move_lists(page, true);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru,
+								pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			if (vm_swap_full())
@@ -1225,7 +1125,12 @@ static void shrink_active_list(unsigned 
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + lru, pgmoved);
+	if (file) {
+		zone->recent_rotated_file += pgmoved;
+	} else {
+		zone->recent_rotated_anon += pgmoved;
+	}
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
@@ -1236,16 +1141,82 @@ static void shrink_active_list(unsigned 
 	pagevec_release(&pvec);
 }
 
-static unsigned long shrink_list(enum lru_list l, unsigned long nr_to_scan,
+static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
-	if (l == LRU_ACTIVE) {
-		shrink_active_list(nr_to_scan, zone, sc, priority);
+	int file = is_file_lru(lru);
+
+	if (lru == LRU_ACTIVE_ANON || lru == LRU_ACTIVE_FILE) {
+		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
-	return shrink_inactive_list(nr_to_scan, zone, sc);
+	return shrink_inactive_list(nr_to_scan, zone, sc, file);
+}
+
+/*
+ * The utility of the anon and file memory corresponds to the fraction
+ * of pages that were recently referenced in each category.  Pageout
+ * pressure is distributed according to the size of each set, the fraction
+ * of recently referenced pages (except used-once file pages) and the
+ * swappiness parameter.
+ *
+ * We return the relative pressures as percentages so shrink_zone can
+ * easily use them.
+ */
+static void get_scan_ratio(struct zone *zone, struct scan_control * sc,
+					unsigned long *percent)
+{
+	unsigned long anon, file;
+	unsigned long anon_prio, file_prio;
+	unsigned long rotate_sum;
+	unsigned long ap, fp;
+
+	anon  = zone_page_state(zone, NR_ACTIVE_ANON) +
+		zone_page_state(zone, NR_INACTIVE_ANON);
+	file  = zone_page_state(zone, NR_ACTIVE_FILE) +
+		zone_page_state(zone, NR_INACTIVE_FILE);
+
+	rotate_sum = zone->recent_rotated_file + zone->recent_rotated_anon;
+
+	/* Keep a floating average of RECENT references. */
+	if (unlikely(rotate_sum > min(anon, file))) {
+		spin_lock_irq(&zone->lru_lock);
+		zone->recent_rotated_file /= 2;
+		zone->recent_rotated_anon /= 2;
+		spin_unlock_irq(&zone->lru_lock);
+		rotate_sum /= 2;
+	}
+
+	/*
+	 * With swappiness at 100, anonymous and file have the same priority.
+	 * This scanning priority is essentially the inverse of IO cost.
+	 */
+	anon_prio = sc->swappiness;
+	file_prio = 200 - sc->swappiness;
+
+	/*
+	 *                  anon       recent_rotated_anon
+	 * %anon = 100 * ----------- / ------------------- * IO cost
+	 *               anon + file       rotate_sum
+	 */
+	ap = (anon_prio * anon) / (anon + file + 1);
+	ap *= rotate_sum / (zone->recent_rotated_anon + 1);
+	if (ap == 0)
+		ap = 1;
+	else if (ap > 100)
+		ap = 100;
+	percent[0] = ap;
+
+	fp = (file_prio * file) / (anon + file + 1);
+	fp *= rotate_sum / (zone->recent_rotated_file + 1);
+	if (fp == 0)
+		fp = 1;
+	else if (fp > 100)
+		fp = 100;
+	percent[1] = fp;
 }
 
+
 /*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
@@ -1255,36 +1226,38 @@ static unsigned long shrink_zone(int pri
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
 
-	if (scan_global_lru(sc)) {
-		/*
-		 * Add one to nr_to_scan just to make sure that the kernel
-		 * will slowly sift through the active list.
-		 */
-		for_each_lru(l) {
+	get_scan_ratio(zone, sc, percent);
+
+	for_each_lru(l) {
+		if (scan_global_lru(sc)) {
+			int file = is_file_lru(l);
+			/*
+			 * Add one to nr_to_scan just to make sure that the
+			 * kernel will slowly sift through the active list.
+			 */
 			zone->nr_scan[l] += (zone_page_state(zone,
-					NR_INACTIVE + l)  >> priority) + 1;
-			nr[l] = zone->nr_scan[l];
+				NR_INACTIVE_ANON + l) >> priority) + 1;
+			nr[l] = zone->nr_scan[l] * percent[file] / 100;
 			if (nr[l] >= sc->swap_cluster_max)
 				zone->nr_scan[l] = 0;
 			else
 				nr[l] = 0;
+		} else {
+			/*
+			 * This reclaim occurs not because zone memory shortage
+			 * but because memory controller hits its limit.
+			 * Then, don't modify zone reclaim related data.
+			 */
+			nr[l] = mem_cgroup_calc_reclaim(sc->mem_cgroup, zone,
+								priority, l);
 		}
-	} else {
-		/*
-		 * This reclaim occurs not because zone memory shortage but
-		 * because memory controller hits its limit.
-		 * Then, don't modify zone reclaim related data.
-		 */
-		nr[LRU_ACTIVE] = mem_cgroup_calc_reclaim(sc->mem_cgroup,
-					zone, priority, LRU_ACTIVE);
-
-		nr[LRU_INACTIVE] = mem_cgroup_calc_reclaim(sc->mem_cgroup,
-					zone, priority, LRU_INACTIVE);
 	}
 
-	while (nr[LRU_ACTIVE] || nr[LRU_INACTIVE]) {
+	while (nr[LRU_ACTIVE_ANON] || nr[LRU_INACTIVE_ANON] ||
+				nr[LRU_ACTIVE_FILE] || nr[LRU_INACTIVE_FILE]) {
 		for_each_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
@@ -1357,7 +1330,7 @@ static unsigned long shrink_zones(int pr
 
 	return nr_reclaimed;
 }
- 
+
 /*
  * This is the main entry point to direct page reclaim.
  *
@@ -1395,8 +1368,7 @@ static unsigned long do_try_to_free_page
 			if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 				continue;
 
-			lru_pages += zone_page_state(zone, NR_ACTIVE)
-					+ zone_page_state(zone, NR_INACTIVE);
+			lru_pages += zone_lru_pages(zone);
 		}
 	}
 
@@ -1601,8 +1573,7 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone_page_state(zone, NR_ACTIVE)
-					+ zone_page_state(zone, NR_INACTIVE);
+			lru_pages += zone_lru_pages(zone);
 		}
 
 		/*
@@ -1646,8 +1617,7 @@ loop_again:
 			if (zone_is_all_unreclaimable(zone))
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-				(zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE)) * 6)
+						(zone_lru_pages(zone) * 6))
 					zone_set_flag(zone,
 						      ZONE_ALL_UNRECLAIMABLE);
 			/*
@@ -1702,7 +1672,7 @@ out:
 
 /*
  * The background pageout daemon, started as a kernel thread
- * from the init process. 
+ * from the init process.
  *
  * This basically trickles out pages so that we have _some_
  * free memory available even if there is no other activity
@@ -1797,6 +1767,14 @@ void wakeup_kswapd(struct zone *zone, in
 	wake_up_interruptible(&pgdat->kswapd_wait);
 }
 
+unsigned long global_lru_pages(void)
+{
+	return global_page_state(NR_ACTIVE_ANON)
+		+ global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_ANON)
+		+ global_page_state(NR_INACTIVE_FILE);
+}
+
 #ifdef CONFIG_PM
 /*
  * Helper function for shrink_all_memory().  Tries to reclaim 'nr_pages' pages
@@ -1822,17 +1800,18 @@ static unsigned long shrink_all_zones(un
 
 		for_each_lru(l) {
 			/* For pass = 0 we don't shrink the active list */
-			if (pass == 0 && l == LRU_ACTIVE)
+			if (pass == 0 &&
+				(l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE))
 				continue;
 
 			zone->nr_scan[l] +=
-				(zone_page_state(zone, NR_INACTIVE + l)
+				(zone_page_state(zone, NR_INACTIVE_ANON + l)
 								>> prio) + 1;
 			if (zone->nr_scan[l] >= nr_pages || pass > 3) {
 				zone->nr_scan[l] = 0;
 				nr_to_scan = min(nr_pages,
 					zone_page_state(zone,
-							NR_INACTIVE + l));
+							NR_INACTIVE_ANON + l));
 				ret += shrink_list(l, nr_to_scan, zone,
 								sc, prio);
 				if (ret >= nr_pages)
@@ -1844,11 +1823,6 @@ static unsigned long shrink_all_zones(un
 	return ret;
 }
 
-static unsigned long count_lru_pages(void)
-{
-	return global_page_state(NR_ACTIVE) + global_page_state(NR_INACTIVE);
-}
-
 /*
  * Try to free `nr_pages' of memory, system-wide, and return the number of
  * freed pages.
@@ -1874,7 +1848,7 @@ unsigned long shrink_all_memory(unsigned
 
 	current->reclaim_state = &reclaim_state;
 
-	lru_pages = count_lru_pages();
+	lru_pages = global_lru_pages();
 	nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
@@ -1917,7 +1891,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					global_lru_pages());
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1934,7 +1908,7 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
Index: linux-2.6.25-rc3-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/swap_state.c	2008-03-04 15:30:02.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/swap_state.c	2008-03-04 15:30:20.000000000 -0500
@@ -300,7 +300,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			lru_cache_add_active_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
Index: linux-2.6.25-rc3-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/mmzone.h	2008-03-04 15:26:18.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/mmzone.h	2008-03-04 15:30:20.000000000 -0500
@@ -80,21 +80,23 @@ struct zone_padding {
 enum zone_stat_item {
 	/* First 128 byte cacheline (assuming 64 bit words) */
 	NR_FREE_PAGES,
-	NR_INACTIVE,	/* must match order of LRU_[IN]ACTIVE */
-	NR_ACTIVE,	/*  "     "     "   "       "         */
+	NR_INACTIVE_ANON,	/* must match order of LRU_[IN]ACTIVE_* */
+	NR_ACTIVE_ANON,		/*  "     "     "   "       "           */
+	NR_INACTIVE_FILE,	/*  "     "     "   "       "           */
+	NR_ACTIVE_FILE,		/*  "     "     "   "       "           */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
 			   only modified from process context */
 	NR_FILE_PAGES,
 	NR_FILE_DIRTY,
 	NR_WRITEBACK,
-	/* Second 128 byte cacheline */
 	NR_SLAB_RECLAIMABLE,
 	NR_SLAB_UNRECLAIMABLE,
 	NR_PAGETABLE,		/* used for pagetables */
 	NR_UNSTABLE_NFS,	/* NFS unstable pages */
 	NR_BOUNCE,
 	NR_VMSCAN_WRITE,
+	/* Second 128 byte cacheline */
 #ifdef CONFIG_NUMA
 	NUMA_HIT,		/* allocated in intended node */
 	NUMA_MISS,		/* allocated in non intended node */
@@ -105,18 +107,33 @@ enum zone_stat_item {
 #endif
 	NR_VM_ZONE_STAT_ITEMS };
 
+/*
+ * We do arithmetic on the LRU lists in various places in the code,
+ * so it is important to keep the active lists LRU_ACTIVE higher in
+ * the array than the corresponding inactive lists, and to keep
+ * the *_FILE lists LRU_FILE higher than the corresponding _ANON lists.
+ */
 #define LRU_BASE 0
+#define LRU_ACTIVE 1
+#define LRU_FILE 2
 
 enum lru_list {
-	LRU_INACTIVE = LRU_BASE,	/* must match order of NR_[IN]ACTIVE */
-	LRU_ACTIVE,			/*  "     "     "   "       "        */
+	LRU_INACTIVE_ANON = LRU_BASE,
+	LRU_ACTIVE_ANON = LRU_BASE + LRU_ACTIVE,
+	LRU_INACTIVE_FILE = LRU_BASE + LRU_FILE,
+	LRU_ACTIVE_FILE = LRU_BASE + LRU_FILE + LRU_ACTIVE,
 	NR_LRU_LISTS };
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
+static inline int is_file_lru(enum lru_list l)
+{
+	return (l == LRU_INACTIVE_FILE || l == LRU_ACTIVE_FILE);
+}
+
 static inline int is_active_lru(enum lru_list l)
 {
-	return (l == LRU_ACTIVE);
+	return (l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE);
 }
 
 enum lru_list page_lru(struct page *page);
@@ -276,6 +293,10 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	list[NR_LRU_LISTS];
 	unsigned long		nr_scan[NR_LRU_LISTS];
+
+	unsigned long		recent_rotated_anon;
+	unsigned long		recent_rotated_file;
+
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
Index: linux-2.6.25-rc3-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/mm_inline.h	2008-03-04 15:30:02.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/mm_inline.h	2008-03-04 15:30:20.000000000 -0500
@@ -5,7 +5,7 @@
  * page_file_cache - should the page be on a file LRU or anon LRU?
  * @page: the page to test
  *
- * Returns !0 if @page is page cache page backed by a regular filesystem,
+ * Returns LRU_FILE if @page is page cache page backed by a regular filesystem,
  * or 0 if @page is anonymous, tmpfs or otherwise ram or swap backed.
  *
  * We would like to get this info without a page flag, but the state
@@ -18,58 +18,83 @@ static inline int page_file_cache(struct
 		return 0;
 
 	/* The page is page cache backed by a normal filesystem. */
-	return 2;
+	return LRU_FILE;
 }
 
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
 	list_add(&page->lru, &zone->list[l]);
-	__inc_zone_state(zone, NR_INACTIVE + l);
+	__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
 	list_del(&page->lru);
-	__dec_zone_state(zone, NR_INACTIVE + l);
+	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
 static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
+add_page_to_inactive_anon_list(struct zone *zone, struct page *page)
 {
-	add_page_to_lru_list(zone, page, LRU_ACTIVE);
+	add_page_to_lru_list(zone, page, LRU_INACTIVE_ANON);
 }
 
 static inline void
-add_page_to_inactive_list(struct zone *zone, struct page *page)
+add_page_to_active_anon_list(struct zone *zone, struct page *page)
 {
-	add_page_to_lru_list(zone, page, LRU_INACTIVE);
+	add_page_to_lru_list(zone, page, LRU_ACTIVE_ANON);
 }
 
 static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
+add_page_to_inactive_file_list(struct zone *zone, struct page *page)
 {
-	del_page_from_lru_list(zone, page, LRU_ACTIVE);
+	add_page_to_lru_list(zone, page, LRU_INACTIVE_FILE);
 }
 
 static inline void
-del_page_from_inactive_list(struct zone *zone, struct page *page)
+add_page_to_active_file_list(struct zone *zone, struct page *page)
 {
-	del_page_from_lru_list(zone, page, LRU_INACTIVE);
+	add_page_to_lru_list(zone, page, LRU_ACTIVE_FILE);
+}
+
+static inline void
+del_page_from_inactive_anon_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_INACTIVE_ANON);
+}
+
+static inline void
+del_page_from_active_anon_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_ACTIVE_ANON);
+}
+
+static inline void
+del_page_from_inactive_file_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
+}
+
+static inline void
+del_page_from_active_file_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_INACTIVE_FILE);
 }
 
 static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
-	enum lru_list l = LRU_INACTIVE;
+	enum lru_list l = LRU_INACTIVE_ANON;
 
 	list_del(&page->lru);
 	if (PageActive(page)) {
 		__ClearPageActive(page);
-		l = LRU_ACTIVE;
+		l += LRU_ACTIVE;
 	}
-	__dec_zone_state(zone, NR_INACTIVE + l);
+	l += page_file_cache(page);
+	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
 #endif
Index: linux-2.6.25-rc3-mm1/include/linux/pagevec.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/pagevec.h	2008-03-04 15:29:50.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/pagevec.h	2008-03-04 15:30:20.000000000 -0500
@@ -81,20 +81,37 @@ static inline void pagevec_free(struct p
 		__pagevec_free(pvec);
 }
 
-static inline void __pagevec_lru_add(struct pagevec *pvec)
+static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_INACTIVE);
+	____pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
 }
 
-static inline void __pagevec_lru_add_active(struct pagevec *pvec)
+static inline void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
-	____pagevec_lru_add(pvec, LRU_ACTIVE);
+	____pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
 }
 
-static inline void pagevec_lru_add(struct pagevec *pvec)
+static inline void __pagevec_lru_add_file(struct pagevec *pvec)
+{
+	____pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
+}
+
+static inline void __pagevec_lru_add_active_file(struct pagevec *pvec)
+{
+	____pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
+}
+
+
+static inline void pagevec_lru_add_file(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_file(pvec);
+}
+
+static inline void pagevec_lru_add_anon(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add_anon(pvec);
 }
 
 #endif /* _LINUX_PAGEVEC_H */
Index: linux-2.6.25-rc3-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/vmstat.h	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/vmstat.h	2008-03-04 15:30:20.000000000 -0500
@@ -149,6 +149,16 @@ static inline unsigned long zone_page_st
 	return x;
 }
 
+extern unsigned long global_lru_pages(void);
+
+static inline unsigned long zone_lru_pages(struct zone *zone)
+{
+	return (zone_page_state(zone, NR_ACTIVE_ANON)
+		+ zone_page_state(zone, NR_ACTIVE_FILE)
+		+ zone_page_state(zone, NR_INACTIVE_ANON)
+		+ zone_page_state(zone, NR_INACTIVE_FILE));
+}
+
 #ifdef CONFIG_NUMA
 /*
  * Determine the per node value of a stat item. This function
Index: linux-2.6.25-rc3-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/page-writeback.c	2008-03-04 14:12:52.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/page-writeback.c	2008-03-04 15:30:20.000000000 -0500
@@ -320,9 +320,7 @@ static unsigned long highmem_dirtyable_m
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES)
-			+ zone_page_state(z, NR_INACTIVE)
-			+ zone_page_state(z, NR_ACTIVE);
+		x += zone_page_state(z, NR_FREE_PAGES) + zone_lru_pages(z);
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -340,9 +338,7 @@ static unsigned long determine_dirtyable
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES)
-		+ global_page_state(NR_INACTIVE)
-		+ global_page_state(NR_ACTIVE);
+	x = global_page_state(NR_FREE_PAGES) + global_lru_pages();
 
 	if (!vm_highmem_is_dirtyable)
 		x -= highmem_dirtyable_memory(x);
Index: linux-2.6.25-rc3-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/swap.h	2008-03-04 15:26:18.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/swap.h	2008-03-04 15:30:20.000000000 -0500
@@ -184,14 +184,24 @@ extern void swap_setup(void);
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
  */
-static inline void lru_cache_add(struct page *page)
+static inline void lru_cache_add_anon(struct page *page)
 {
-	__lru_cache_add(page, LRU_INACTIVE);
+	__lru_cache_add(page, LRU_INACTIVE_ANON);
 }
 
-static inline void lru_cache_add_active(struct page *page)
+static inline void lru_cache_add_active_anon(struct page *page)
 {
-	__lru_cache_add(page, LRU_ACTIVE);
+	__lru_cache_add(page, LRU_ACTIVE_ANON);
+}
+
+static inline void lru_cache_add_file(struct page *page)
+{
+	__lru_cache_add(page, LRU_INACTIVE_FILE);
+}
+
+static inline void lru_cache_add_active_file(struct page *page)
+{
+	__lru_cache_add(page, LRU_ACTIVE_FILE);
 }
 
 /* linux/mm/vmscan.c */
@@ -199,7 +209,7 @@ extern unsigned long try_to_free_pages(s
 					gfp_t gfp_mask);
 extern unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *mem,
 							gfp_t gfp_mask);
-extern int __isolate_lru_page(struct page *page, int mode);
+extern int __isolate_lru_page(struct page *page, int mode, int file);
 extern unsigned long shrink_all_memory(unsigned long nr_pages);
 extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
Index: linux-2.6.25-rc3-mm1/include/linux/memcontrol.h
===================================================================
--- linux-2.6.25-rc3-mm1.orig/include/linux/memcontrol.h	2008-03-04 14:59:31.000000000 -0500
+++ linux-2.6.25-rc3-mm1/include/linux/memcontrol.h	2008-03-04 15:30:20.000000000 -0500
@@ -44,7 +44,7 @@ extern unsigned long mem_cgroup_isolate_
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active);
+					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 int task_in_mem_cgroup(struct task_struct *task, const struct mem_cgroup *mem);
 
Index: linux-2.6.25-rc3-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.25-rc3-mm1.orig/mm/memcontrol.c	2008-03-04 15:03:06.000000000 -0500
+++ linux-2.6.25-rc3-mm1/mm/memcontrol.c	2008-03-04 15:32:23.000000000 -0500
@@ -158,6 +158,7 @@ struct page_cgroup {
 };
 #define PAGE_CGROUP_FLAG_CACHE	(0x1)	/* charged as cache */
 #define PAGE_CGROUP_FLAG_ACTIVE (0x2)	/* page is active in this cgroup */
+#define PAGE_CGROUP_FLAG_FILE	(0x4)	/* page is file system backed */
 
 static int page_cgroup_nid(struct page_cgroup *pc)
 {
@@ -282,10 +283,12 @@ static void unlock_page_cgroup(struct pa
 static void __mem_cgroup_remove_list(struct page_cgroup *pc)
 {
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
-	int lru = LRU_INACTIVE;
+	int lru = LRU_BASE;
 
 	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
 		lru += LRU_ACTIVE;
+	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		lru += LRU_FILE;
 
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
@@ -296,10 +299,12 @@ static void __mem_cgroup_remove_list(str
 static void __mem_cgroup_add_list(struct page_cgroup *pc)
 {
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
-	int lru = LRU_INACTIVE;
+	int lru = LRU_BASE;
 
 	if (pc->flags & PAGE_CGROUP_FLAG_ACTIVE)
 		lru += LRU_ACTIVE;
+	if (pc->flags & PAGE_CGROUP_FLAG_FILE)
+		lru += LRU_FILE;
 
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_add(&pc->lru, &mz->lists[lru]);
@@ -310,8 +315,9 @@ static void __mem_cgroup_add_list(struct
 static void __mem_cgroup_move_lists(struct page_cgroup *pc, bool active)
 {
 	int from = pc->flags & PAGE_CGROUP_FLAG_ACTIVE;
+	int file = pc->flags & PAGE_CGROUP_FLAG_FILE;
 	struct mem_cgroup_per_zone *mz = page_cgroup_zoneinfo(pc);
-	int lru = !!from;
+	int lru = LRU_FILE * !!file + !!from;
 
 	MEM_CGROUP_ZSTAT(mz, lru) -= 1;
 
@@ -320,7 +326,7 @@ static void __mem_cgroup_move_lists(stru
 	else
 		pc->flags &= ~PAGE_CGROUP_FLAG_ACTIVE;
 
-	lru = !!active;
+	lru = LRU_FILE * !!file + !!active;
 	MEM_CGROUP_ZSTAT(mz, lru) += 1;
 	list_move(&pc->lru, &mz->lists[lru]);
 }
@@ -382,21 +388,6 @@ int mem_cgroup_calc_mapped_ratio(struct 
 }
 
 /*
- * This function is called from vmscan.c. In page reclaiming loop. balance
- * between active and inactive list is calculated. For memory controller
- * page reclaiming, we should use using mem_cgroup's imbalance rather than
- * zone's global lru imbalance.
- */
-long mem_cgroup_reclaim_imbalance(struct mem_cgroup *mem)
-{
-	unsigned long active, inactive;
-	/* active and inactive are the number of pages. 'long' is ok.*/
-	active = mem_cgroup_get_all_zonestat(mem, LRU_ACTIVE);
-	inactive = mem_cgroup_get_all_zonestat(mem, LRU_INACTIVE);
-	return (long) (active / (inactive + 1));
-}
-
-/*
  * prev_priority control...this will be used in memory reclaim path.
  */
 int mem_cgroup_get_reclaim_priority(struct mem_cgroup *mem)
@@ -441,7 +432,7 @@ unsigned long mem_cgroup_isolate_pages(u
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active)
+					int active, int file)
 {
 	unsigned long nr_taken = 0;
 	struct page *page;
@@ -452,7 +443,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	int nid = z->zone_pgdat->node_id;
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
-	int lru = !!active;
+	int lru = LRU_FILE * !!file + !!active;
 
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
 	src = &mz->lists[lru];
@@ -467,6 +458,9 @@ unsigned long mem_cgroup_isolate_pages(u
 		if (unlikely(!PageLRU(page)))
 			continue;
 
+		/*
+		 * TODO: play better with lumpy reclaim, grabbing anything.
+		 */
 		if (PageActive(page) && !active) {
 			__mem_cgroup_move_lists(pc, true);
 			continue;
@@ -479,7 +473,7 @@ unsigned long mem_cgroup_isolate_pages(u
 		scan++;
 		list_move(&pc->lru, &pc_list);
 
-		if (__isolate_lru_page(page, mode) == 0) {
+		if (__isolate_lru_page(page, mode, file) == 0) {
 			list_move(&page->lru, dst);
 			nr_taken++;
 		}
@@ -582,6 +576,8 @@ retry:
 	pc->flags = PAGE_CGROUP_FLAG_ACTIVE;
 	if (ctype == MEM_CGROUP_CHARGE_TYPE_CACHE)
 		pc->flags |= PAGE_CGROUP_FLAG_CACHE;
+	if (page_file_cache(page))
+		pc->flags |= PAGE_CGROUP_FLAG_FILE;
 
 	lock_page_cgroup(page);
 	if (page_get_page_cgroup(page)) {
@@ -862,14 +858,21 @@ static int mem_control_stat_show(struct 
 	}
 	/* showing # of active pages */
 	{
-		unsigned long active, inactive;
+		unsigned long active_anon, inactive_anon;
+		unsigned long active_file, inactive_file;
 
-		inactive = mem_cgroup_get_all_zonestat(mem_cont,
-						LRU_INACTIVE);
-		active = mem_cgroup_get_all_zonestat(mem_cont,
-						LRU_ACTIVE);
-		cb->fill(cb, "active", (active) * PAGE_SIZE);
-		cb->fill(cb, "inactive", (inactive) * PAGE_SIZE);
+		inactive_anon = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_INACTIVE_ANON);
+		active_anon = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_ACTIVE_ANON);
+		inactive_file = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_INACTIVE_FILE);
+		active_file = mem_cgroup_get_all_zonestat(mem_cont,
+						LRU_ACTIVE_FILE);
+		cb->fill(cb, "active_anon", (active_anon) * PAGE_SIZE);
+		cb->fill(cb, "inactive_anon", (inactive_anon) * PAGE_SIZE);
+		cb->fill(cb, "active_file", (active_file) * PAGE_SIZE);
+		cb->fill(cb, "inactive_file", (inactive_file) * PAGE_SIZE);
 	}
 	return 0;
 }

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
