Date: Sat, 3 Nov 2007 19:01:58 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [RFC PATCH 6/10] split anon and file LRUs
Message-ID: <20071103190158.34b4650e@bree.surriel.com>
In-Reply-To: <20071103184229.3f20e2f0@bree.surriel.com>
References: <20071103184229.3f20e2f0@bree.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Split the LRU lists in two, one set for pages that are backed by
real file systems ("file") and one for pages that are backed by
memory and swap ("anon").  The latter includes tmpfs.

Eventually mlocked pages will be taken off the LRUs alltogether.
A patch for that already exists and just needs to be integrated
into this series.

This patch mostly has the infrastructure and a basic policy to
balance how much we scan the anon lists and how much we scan
the file lists. Fancy policy changes will be in separate patches.

Signed-off-by: Rik van Riel <riel@redhat.com>
Signed-off-by: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

Index: linux-2.6.23-mm1/fs/proc/proc_misc.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/proc/proc_misc.c
+++ linux-2.6.23-mm1/fs/proc/proc_misc.c
@@ -149,43 +149,47 @@ static int meminfo_read_proc(char *page,
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
+		K(global_page_state(NR_ACTIVE_ANON)),
+		K(global_page_state(NR_INACTIVE_ANON)),
+		K(global_page_state(NR_ACTIVE_FILE)),
+		K(global_page_state(NR_INACTIVE_FILE)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
 		K(i.freehigh),
Index: linux-2.6.23-mm1/fs/cifs/file.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/cifs/file.c
+++ linux-2.6.23-mm1/fs/cifs/file.c
@@ -1740,7 +1740,7 @@ static void cifs_copy_cache_pages(struct
 		SetPageUptodate(page);
 		unlock_page(page);
 		if (!pagevec_add(plru_pvec, page))
-			__pagevec_lru_add(plru_pvec);
+			__pagevec_lru_add_file(plru_pvec);
 		data += PAGE_CACHE_SIZE;
 	}
 	return;
@@ -1878,7 +1878,7 @@ static int cifs_readpages(struct file *f
 		bytes_read = 0;
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 
 /* need to free smb_read_data buf before exit */
 	if (smb_read_data) {
Index: linux-2.6.23-mm1/fs/ntfs/file.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/ntfs/file.c
+++ linux-2.6.23-mm1/fs/ntfs/file.c
@@ -439,7 +439,7 @@ static inline int __ntfs_grab_cache_page
 			pages[nr] = *cached_page;
 			page_cache_get(*cached_page);
 			if (unlikely(!pagevec_add(lru_pvec, *cached_page)))
-				__pagevec_lru_add(lru_pvec);
+				__pagevec_lru_add_file(lru_pvec);
 			*cached_page = NULL;
 		}
 		index++;
@@ -2087,7 +2087,7 @@ err_out:
 						OSYNC_METADATA|OSYNC_DATA);
 		}
   	}
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_file(&lru_pvec);
 	ntfs_debug("Done.  Returning %s (written 0x%lx, status %li).",
 			written ? "written" : "status", (unsigned long)written,
 			(long)status);
Index: linux-2.6.23-mm1/fs/nfs/dir.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/nfs/dir.c
+++ linux-2.6.23-mm1/fs/nfs/dir.c
@@ -1488,7 +1488,7 @@ static int nfs_symlink(struct inode *dir
 	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
 		pagevec_add(&lru_pvec, page);
-		pagevec_lru_add(&lru_pvec);
+		pagevec_lru_add_file(&lru_pvec);
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else
Index: linux-2.6.23-mm1/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.23-mm1.orig/fs/ramfs/file-nommu.c
+++ linux-2.6.23-mm1/fs/ramfs/file-nommu.c
@@ -110,13 +110,15 @@ static int ramfs_nommu_expand_for_mappin
 		if (ret < 0)
 			goto add_error;
 
+//TODO:  how does this interact w/ vmscan and use of page_file_cache()?
+//       don't want to test ramfs there...
 		if (!pagevec_add(&lru_pvec, page))
-			__pagevec_lru_add(&lru_pvec);
+			__pagevec_lru_add_anon(&lru_pvec);
 
 		unlock_page(page);
 	}
 
-	pagevec_lru_add(&lru_pvec);
+	pagevec_lru_add_anon(&lru_pvec);
 	return 0;
 
  fsize_exceeded:
Index: linux-2.6.23-mm1/drivers/base/node.c
===================================================================
--- linux-2.6.23-mm1.orig/drivers/base/node.c
+++ linux-2.6.23-mm1/drivers/base/node.c
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
Index: linux-2.6.23-mm1/mm/memory.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/memory.c
+++ linux-2.6.23-mm1/mm/memory.c
@@ -1670,7 +1670,7 @@ gotten:
 		set_pte_at(mm, address, page_table, entry);
 		update_mmu_cache(vma, address, entry);
 		SetPageSwapBacked(new_page);
-		lru_cache_add_active(new_page);
+		lru_cache_add_active_anon(new_page);
 		page_add_new_anon_rmap(new_page, vma, address);
 
 		/* Free the old page.. */
@@ -2200,7 +2200,7 @@ static int do_anonymous_page(struct mm_s
 		goto release;
 	inc_mm_counter(mm, anon_rss);
 	SetPageSwapBacked(page);
-	lru_cache_add_active(page);
+	lru_cache_add_active_anon(page);
 	page_add_new_anon_rmap(page, vma, address);
 	set_pte_at(mm, address, page_table, entry);
 
@@ -2354,7 +2354,7 @@ static int __do_fault(struct mm_struct *
 		if (anon) {
                         inc_mm_counter(mm, anon_rss);
 			SetPageSwapBacked(page);
-                        lru_cache_add_active(page);
+                        lru_cache_add_active_anon(page);
                         page_add_new_anon_rmap(page, vma, address);
 		} else {
 			inc_mm_counter(mm, file_rss);
Index: linux-2.6.23-mm1/mm/page_alloc.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/page_alloc.c
+++ linux-2.6.23-mm1/mm/page_alloc.c
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
@@ -3470,6 +3477,9 @@ static void __meminit free_area_init_cor
 			INIT_LIST_HEAD(&zone->list[l]);
 			zone->nr_scan[l] = 0;
 		}
+		zone->recent_rotated_anon = 0;
+		zone->recent_rotated_file = 0;
+//TODO recent_scanned_* ???
 		zap_zone_vm_stats(zone);
 		zone->flags = 0;
 		if (!size)
Index: linux-2.6.23-mm1/mm/swap.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/swap.c
+++ linux-2.6.23-mm1/mm/swap.c
@@ -34,8 +34,10 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec, lru_add_pvecs) = { 0, };
-static DEFINE_PER_CPU(struct pagevec, lru_add_active_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_file_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_file_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_anon_pvecs) = { 0, };
+static DEFINE_PER_CPU(struct pagevec, lru_add_active_anon_pvecs) = { 0, };
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs) = { 0, };
 
 /*
@@ -118,7 +120,13 @@ static void pagevec_move_tail(struct pag
 			spin_lock(&zone->lru_lock);
 		}
 		if (PageLRU(page) && !PageActive(page)) {
-			list_move_tail(&page->lru, &zone->list[LRU_INACTIVE]);
+			if (page_file_cache(page)) {
+				list_move_tail(&page->lru,
+						&zone->list[LRU_INACTIVE_FILE]);
+			} else {
+				list_move_tail(&page->lru,
+						&zone->list[LRU_INACTIVE_ANON]);
+			}
 			pgmoved++;
 		}
 	}
@@ -172,9 +180,13 @@ void fastcall activate_page(struct page 
 
 	spin_lock_irq(&zone->lru_lock);
 	if (PageLRU(page) && !PageActive(page)) {
-		del_page_from_inactive_list(zone, page);
+		int l = LRU_INACTIVE_ANON;
+		l += page_file_cache(page);
+		del_page_from_lru_list(zone, page, l);
+
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		l += LRU_ACTIVE_ANON - LRU_INACTIVE_ANON;
+		add_page_to_lru_list(zone, page, l);
 		__count_vm_event(PGACTIVATE);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
 	}
@@ -204,26 +216,46 @@ EXPORT_SYMBOL(mark_page_accessed);
  * lru_cache_add: add a page to the page lists
  * @page: the page to add
  */
-void fastcall lru_cache_add(struct page *page)
+void fastcall lru_cache_add_anon(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_anon_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add(pvec);
-	put_cpu_var(lru_add_pvecs);
+		__pagevec_lru_add_anon(pvec);
+	put_cpu_var(lru_add_anon_pvecs);
 }
 
-void fastcall lru_cache_add_active(struct page *page)
+void fastcall lru_cache_add_file(struct page *page)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_active_pvecs);
+	struct pagevec *pvec = &get_cpu_var(lru_add_file_pvecs);
 
 	page_cache_get(page);
 	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add_active(pvec);
+		__pagevec_lru_add_file(pvec);
+	put_cpu_var(lru_add_file_pvecs);
+}
+
+void fastcall lru_cache_add_active_anon(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_anon_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_active_anon(pvec);
 	put_cpu_var(lru_add_active_pvecs);
 }
 
+void fastcall lru_cache_add_active_file(struct page *page)
+{
+	struct pagevec *pvec = &get_cpu_var(lru_add_active_file_pvecs);
+
+	page_cache_get(page);
+	if (!pagevec_add(pvec, page))
+		__pagevec_lru_add_active_file(pvec);
+	put_cpu_var(lru_add_active_file_pvecs);
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -233,13 +265,21 @@ static void drain_cpu_pagevecs(int cpu)
 {
 	struct pagevec *pvec;
 
-	pvec = &per_cpu(lru_add_pvecs, cpu);
+	pvec = &per_cpu(lru_add_file_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_file(pvec);
+
+	pvec = &per_cpu(lru_add_anon_pvecs, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add_anon(pvec);
 
-	pvec = &per_cpu(lru_add_active_pvecs, cpu);
+	pvec = &per_cpu(lru_add_active_file_pvecs, cpu);
 	if (pagevec_count(pvec))
-		__pagevec_lru_add_active(pvec);
+		__pagevec_lru_add_active_file(pvec);
+
+	pvec = &per_cpu(lru_add_active_anon_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_active_anon(pvec);
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
@@ -393,7 +433,7 @@ void __pagevec_release_nonlru(struct pag
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void __pagevec_lru_add(struct pagevec *pvec)
+void __pagevec_lru_add_file(struct pagevec *pvec)
 {
 	int i;
 	struct zone *zone = NULL;
@@ -410,7 +450,7 @@ void __pagevec_lru_add(struct pagevec *p
 		}
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
-		add_page_to_inactive_list(zone, page);
+		add_page_to_inactive_file_list(zone, page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
@@ -418,9 +458,60 @@ void __pagevec_lru_add(struct pagevec *p
 	pagevec_reinit(pvec);
 }
 
-EXPORT_SYMBOL(__pagevec_lru_add);
+EXPORT_SYMBOL(__pagevec_lru_add_file);
+void __pagevec_lru_add_active_file(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		VM_BUG_ON(PageActive(page));
+		SetPageActive(page);
+		add_page_to_active_file_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+void __pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		add_page_to_inactive_anon_list(zone, page);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
 
-void __pagevec_lru_add_active(struct pagevec *pvec)
+void __pagevec_lru_add_active_anon(struct pagevec *pvec)
 {
 	int i;
 	struct zone *zone = NULL;
@@ -439,7 +530,7 @@ void __pagevec_lru_add_active(struct pag
 		SetPageLRU(page);
 		VM_BUG_ON(PageActive(page));
 		SetPageActive(page);
-		add_page_to_active_list(zone, page);
+		add_page_to_active_anon_list(zone, page);
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
Index: linux-2.6.23-mm1/mm/migrate.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/migrate.c
+++ linux-2.6.23-mm1/mm/migrate.c
@@ -60,9 +60,15 @@ static inline void move_to_lru(struct pa
 		 * the PG_active bit is off.
 		 */
 		ClearPageActive(page);
-		lru_cache_add_active(page);
+		if (page_file_cache(page))
+			lru_cache_add_active_file(page);
+		else
+			lru_cache_add_active_anon(page);
 	} else {
-		lru_cache_add(page);
+		if (page_file_cache(page))
+			lru_cache_add_file(page);
+		else
+			lru_cache_add_anon(page);
 	}
 	put_page(page);
 }
Index: linux-2.6.23-mm1/mm/readahead.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/readahead.c
+++ linux-2.6.23-mm1/mm/readahead.c
@@ -229,7 +229,7 @@ int do_page_cache_readahead(struct addre
  */
 unsigned long max_sane_readahead(unsigned long nr)
 {
-	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE)
+	return min(nr, (node_page_state(numa_node_id(), NR_INACTIVE_FILE)
 		+ node_page_state(numa_node_id(), NR_FREE_PAGES)) / 2);
 }
 
Index: linux-2.6.23-mm1/mm/filemap.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/filemap.c
+++ linux-2.6.23-mm1/mm/filemap.c
@@ -32,6 +32,7 @@
 #include <linux/cpuset.h>
 #include <linux/hardirq.h> /* for BUG_ON(!in_atomic()) only */
 #include <linux/memcontrol.h>
+#include <linux/mm_inline.h> /* for page_file_cache() */
 #include "internal.h"
 
 /*
@@ -474,8 +475,12 @@ int add_to_page_cache_lru(struct page *p
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
 
Index: linux-2.6.23-mm1/mm/vmstat.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/vmstat.c
+++ linux-2.6.23-mm1/mm/vmstat.c
@@ -684,8 +684,10 @@ const struct seq_operations pagetypeinfo
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
@@ -748,7 +750,7 @@ static void zoneinfo_show_print(struct s
 		   "\n        min      %lu"
 		   "\n        low      %lu"
 		   "\n        high     %lu"
-		   "\n        scanned  %lu (a: %lu i: %lu)"
+		   "\n        scanned  %lu (aa: %lu ia: %lu af: %lu if: %lu)"
 		   "\n        spanned  %lu"
 		   "\n        present  %lu",
 		   zone_page_state(zone, NR_FREE_PAGES),
@@ -756,8 +758,10 @@ static void zoneinfo_show_print(struct s
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
 
Index: linux-2.6.23-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/vmscan.c
+++ linux-2.6.23-mm1/mm/vmscan.c
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
@@ -237,27 +240,6 @@ unsigned long shrink_slab(unsigned long 
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
@@ -521,8 +503,7 @@ static unsigned long shrink_page_list(st
 
 		referenced = page_referenced(page, 1, sc->mem_cgroup);
 		/* In active use or really unfreeable?  Activate it. */
-		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER &&
-					referenced && page_mapping_inuse(page))
+		if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
 			goto activate_locked;
 
 #ifdef CONFIG_SWAP
@@ -553,8 +534,6 @@ static unsigned long shrink_page_list(st
 		}
 
 		if (PageDirty(page)) {
-			if (sc->order <= PAGE_ALLOC_COSTLY_ORDER && referenced)
-				goto keep_locked;
 			if (!may_enter_fs) {
 				sc->nr_io_pages++;
 				goto keep_locked;
@@ -641,6 +620,7 @@ keep:
 	if (pagevec_count(&freed_pvec))
 		__pagevec_release_nonlru(&freed_pvec);
 	count_vm_events(PGACTIVATE, pgactivate);
+	sc->activated = pgactivate;
 	return nr_reclaimed;
 }
 
@@ -705,12 +685,13 @@ int __isolate_lru_page(struct page *page
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
@@ -770,6 +751,11 @@ static unsigned long isolate_lru_pages(u
 				break;
 
 			cursor_page = pfn_to_page(pfn);
+
+			/* Don't lump pages of different types:  file vs anon */
+			if (!PageLRU(page) || (file != !!page_file_cache(cursor_page)))
+				break;
+
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
 				continue;
@@ -798,14 +784,15 @@ static unsigned long isolate_pages_globa
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active)
+					int active, int file)
 {
+	int l = LRU_INACTIVE_ANON;
 	if (active)
-		return isolate_lru_pages(nr, &z->list[LRU_ACTIVE], dst,
-						scanned, order, mode);
-	else
-		return isolate_lru_pages(nr, &z->list[LRU_INACTIVE], dst,
-						scanned, order, mode);
+		l += LRU_ACTIVE_ANON - LRU_INACTIVE_ANON;
+	if (file)
+		l += LRU_INACTIVE_FILE - LRU_INACTIVE_ANON;
+	return isolate_lru_pages(nr, &z->list[l], dst, scanned, order,
+								mode, !!file);
 }
 
 /*
@@ -855,12 +842,12 @@ int isolate_lru_page(struct page *page)
 
 		spin_lock_irq(&zone->lru_lock);
 		if (PageLRU(page) && get_page_unless_zero(page)) {
+			int l = LRU_INACTIVE_ANON;
 			ret = 0;
 			ClearPageLRU(page);
-			if (PageActive(page))
-				del_page_from_active_list(zone, page);
-			else
-				del_page_from_inactive_list(zone, page);
+
+			l += page_file_cache(page) + !!PageActive(page);
+			del_page_from_lru_list(zone, page, l);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 	}
@@ -872,7 +859,7 @@ int isolate_lru_page(struct page *page)
  * of reclaimed pages
  */
 static unsigned long shrink_inactive_list(unsigned long max_scan,
-				struct zone *zone, struct scan_control *sc)
+			struct zone *zone, struct scan_control *sc, int file)
 {
 	LIST_HEAD(page_list);
 	struct pagevec pvec;
@@ -894,13 +881,19 @@ static unsigned long shrink_inactive_lis
 			     &page_list, &nr_scan, sc->order,
 			     (sc->order > PAGE_ALLOC_COSTLY_ORDER)?
 					     ISOLATE_BOTH : ISOLATE_INACTIVE,
-				zone, sc->mem_cgroup, 0);
+				zone, sc->mem_cgroup, 0, file);
 		nr_active = clear_active_flags(&page_list);
 		__count_vm_events(PGDEACTIVATE, nr_active);
 
-		__mod_zone_page_state(zone, NR_ACTIVE, -nr_active);
-		__mod_zone_page_state(zone, NR_INACTIVE,
+		if (file) {
+			__mod_zone_page_state(zone, NR_ACTIVE_FILE, -nr_active);
+			__mod_zone_page_state(zone, NR_INACTIVE_FILE,
+						-(nr_taken - nr_active));
+		} else {
+			__mod_zone_page_state(zone, NR_ACTIVE_ANON, -nr_active);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON,
 						-(nr_taken - nr_active));
+		}
 		zone->pages_scanned += nr_scan;
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -945,11 +938,20 @@ static unsigned long shrink_inactive_lis
 		 * Put back any unfreeable pages.
 		 */
 		while (!list_empty(&page_list)) {
+			int l = LRU_INACTIVE_ANON;
 			page = lru_to_page(&page_list);
 			VM_BUG_ON(PageLRU(page));
 			SetPageLRU(page);
 			list_del(&page->lru);
-			add_page_to_lru_list(zone, page, PageActive(page));
+			if (file) {
+				l += LRU_INACTIVE_FILE - LRU_INACTIVE_ANON;
+				zone->recent_rotated_file += sc->activated;
+			} else {
+				zone->recent_rotated_anon += sc->activated;
+			}
+			if (PageActive(page))
+				l += LRU_ACTIVE_ANON - LRU_INACTIVE_ANON;
+			add_page_to_lru_list(zone, page, l);
 			if (!pagevec_add(&pvec, page)) {
 				spin_unlock_irq(&zone->lru_lock);
 				__pagevec_release(&pvec);
@@ -980,8 +982,7 @@ static inline void note_zone_scanning_pr
 
 static inline int zone_is_near_oom(struct zone *zone)
 {
-	return zone->pages_scanned >= (zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE))*3;
+	return zone->pages_scanned >= (zone_lru_pages(zone) * 3);
 }
 
 /*
@@ -1002,7 +1003,7 @@ static inline int zone_is_near_oom(struc
  * But we had to alter page->flags anyway.
  */
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
-				struct scan_control *sc, int priority)
+				struct scan_control *sc, int priority, int file)
 {
 	unsigned long pgmoved;
 	int pgdeactivate = 0;
@@ -1011,143 +1012,61 @@ static void shrink_active_list(unsigned 
 	struct list_head list[NR_LRU_LISTS];
 	struct page *page;
 	struct pagevec pvec;
-	int reclaim_mapped = 0;
 	enum lru_list l;
 
 	for_each_lru(l)
 		INIT_LIST_HEAD(&list[l]);
 
-	if (sc->may_swap) {
-		long mapped_ratio;
-		long distress;
-		long swap_tendency;
-		long imbalance;
-
-		if (zone_is_near_oom(zone))
-			goto force_reclaim_mapped;
-
-		/*
-		 * `distress' is a measure of how much trouble we're having
-		 * reclaiming pages.  0 -> no problems.  100 -> great trouble.
-		 */
-		distress = 100 >> min(zone->prev_priority, priority);
-
-		/*
-		 * The point of this algorithm is to decide when to start
-		 * reclaiming mapped memory instead of just pagecache.  Work out
-		 * how much memory
-		 * is mapped.
-		 */
-		mapped_ratio = ((global_page_state(NR_FILE_MAPPED) +
-				global_page_state(NR_ANON_PAGES)) * 100) /
-					vm_total_pages;
-
-		/*
-		 * Now decide how much we really want to unmap some pages.  The
-		 * mapped ratio is downgraded - just because there's a lot of
-		 * mapped memory doesn't necessarily mean that page reclaim
-		 * isn't succeeding.
-		 *
-		 * The distress ratio is important - we don't want to start
-		 * going oom.
-		 *
-		 * A 100% value of vm_swappiness overrides this algorithm
-		 * altogether.
-		 */
-		swap_tendency = mapped_ratio / 2 + distress + sc->swappiness;
-
-		/*
-		 * If there's huge imbalance between active and inactive
-		 * (think active 100 times larger than inactive) we should
-		 * become more permissive, or the system will take too much
-		 * cpu before it start swapping during memory pressure.
-		 * Distress is about avoiding early-oom, this is about
-		 * making swappiness graceful despite setting it to low
-		 * values.
-		 *
-		 * Avoid div by zero with nr_inactive+1, and max resulting
-		 * value is vm_total_pages.
-		 */
-		imbalance  = zone_page_state(zone, NR_ACTIVE);
-		imbalance /= zone_page_state(zone, NR_INACTIVE) + 1;
-
-		/*
-		 * Reduce the effect of imbalance if swappiness is low,
-		 * this means for a swappiness very low, the imbalance
-		 * must be much higher than 100 for this logic to make
-		 * the difference.
-		 *
-		 * Max temporary value is vm_total_pages*100.
-		 */
-		imbalance *= (vm_swappiness + 1);
-		imbalance /= 100;
-
-		/*
-		 * If not much of the ram is mapped, makes the imbalance
-		 * less relevant, it's high priority we refill the inactive
-		 * list with mapped pages only in presence of high ratio of
-		 * mapped pages.
-		 *
-		 * Max temporary value is vm_total_pages*100.
-		 */
-		imbalance *= mapped_ratio;
-		imbalance /= 100;
-
-		/* apply imbalance feedback to swap_tendency */
-		swap_tendency += imbalance;
-
-		/*
-		 * Now use this metric to decide whether to start moving mapped
-		 * memory onto the inactive list.
-		 */
-		if (swap_tendency >= 100)
-force_reclaim_mapped:
-			reclaim_mapped = 1;
-	}
-
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
 	pgmoved = sc->isolate_pages(nr_pages, &l_hold, &pgscanned, sc->order,
 					ISOLATE_ACTIVE, zone,
-					sc->mem_cgroup, 1);
+					sc->mem_cgroup, 1, file);
 	zone->pages_scanned += pgscanned;
-	__mod_zone_page_state(zone, NR_ACTIVE, -pgmoved);
+	if (file) {
+		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
+	} else {
+		__mod_zone_page_state(zone, NR_ACTIVE_ANON, -pgmoved);
+	}
 	spin_unlock_irq(&zone->lru_lock);
 
+	/*
+	 * For sorting active vs inactive pages, we'll use the 'anon'
+	 * elements of the local list[] array and sort out the file vs
+	 * anon pages below.
+	 */
 	while (!list_empty(&l_hold)) {
+		l = LRU_INACTIVE_ANON;
 		cond_resched();
 		page = lru_to_page(&l_hold);
 		list_del(&page->lru);
-		if (page_mapped(page)) {
-			if (!reclaim_mapped ||
-			    (total_swap_pages == 0 && PageAnon(page)) ||
-			    page_referenced(page, 0, sc->mem_cgroup)) {
-				list_add(&page->lru, &list[LRU_ACTIVE]);
-				continue;
-			}
-		} else if (TestClearPageReferenced(page)) {
-			list_add(&page->lru, &list[LRU_ACTIVE]);
-			continue;
-		}
-		list_add(&page->lru, &list[LRU_INACTIVE]);
+		if (page_referenced(page, 0, sc->mem_cgroup))
+			l = LRU_ACTIVE_ANON;
+		list_add(&page->lru, &list[l]);
 	}
 
+	/*
+	 * Now put the pages back to the appropriate [file or anon] inactive
+	 * and active lists.
+	 */
 	pagevec_init(&pvec, 1);
 	pgmoved = 0;
+	l = LRU_INACTIVE_ANON + file * (LRU_INACTIVE_FILE - LRU_INACTIVE_ANON);
 	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&list[LRU_INACTIVE])) {
-		page = lru_to_page(&list[LRU_INACTIVE]);
-		prefetchw_prev_lru_page(page, &list[LRU_INACTIVE], flags);
+	while (!list_empty(&list[LRU_INACTIVE_ANON])) {
+		page = lru_to_page(&list[LRU_INACTIVE_ANON]);
+		prefetchw_prev_lru_page(page, &list[LRU_INACTIVE_ANON], flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
 		ClearPageActive(page);
 
-		list_move(&page->lru, &zone->list[LRU_INACTIVE]);
+		list_move(&page->lru, &zone->list[l]);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), false);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON + l,
+								pgmoved);
 			spin_unlock_irq(&zone->lru_lock);
 			pgdeactivate += pgmoved;
 			pgmoved = 0;
@@ -1157,25 +1076,27 @@ force_reclaim_mapped:
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_INACTIVE, pgmoved);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + l, pgmoved);
 	spin_unlock_irq(&zone->lru_lock);
 	pgdeactivate += pgmoved;
 
 	if (buffer_heads_over_limit)
 		pagevec_strip(&pvec);
 	pgmoved = 0;
+	l = LRU_ACTIVE_ANON + file * (LRU_ACTIVE_FILE - LRU_ACTIVE_ANON);
 	spin_lock_irq(&zone->lru_lock);
-	while (!list_empty(&list[LRU_ACTIVE])) {
-		page = lru_to_page(&list[LRU_ACTIVE]);
-		prefetchw_prev_lru_page(page, &list[LRU_ACTIVE], flags);
+	while (!list_empty(&list[LRU_ACTIVE_ANON])) {
+		page = lru_to_page(&list[LRU_ACTIVE_ANON]);
+		prefetchw_prev_lru_page(page, &list[LRU_ACTIVE_ANON], flags);
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 		VM_BUG_ON(!PageActive(page));
-		list_move(&page->lru, &zone->list[LRU_ACTIVE]);
+		list_move(&page->lru, &zone->list[l]);
 		mem_cgroup_move_lists(page_get_page_cgroup(page), true);
 		pgmoved++;
 		if (!pagevec_add(&pvec, page)) {
-			__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+			__mod_zone_page_state(zone, NR_INACTIVE_ANON + l,
+								pgmoved);
 			pgmoved = 0;
 			spin_unlock_irq(&zone->lru_lock);
 			if (vm_swap_full())
@@ -1184,7 +1105,12 @@ force_reclaim_mapped:
 			spin_lock_irq(&zone->lru_lock);
 		}
 	}
-	__mod_zone_page_state(zone, NR_ACTIVE, pgmoved);
+	__mod_zone_page_state(zone, NR_INACTIVE_ANON + l, pgmoved);
+	if (file) {
+		zone->recent_rotated_file += pgmoved;
+	} else {
+		zone->recent_rotated_anon += pgmoved;
+	}
 
 	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	__count_vm_events(PGDEACTIVATE, pgdeactivate);
@@ -1198,14 +1124,80 @@ force_reclaim_mapped:
 static unsigned long shrink_list(enum lru_list l, unsigned long nr_to_scan,
 	struct zone *zone, struct scan_control *sc, int priority)
 {
-	if (l == LRU_ACTIVE) {
-		shrink_active_list(nr_to_scan, zone, sc, priority);
+	int file = is_file_lru(l);
+
+	if (l == LRU_ACTIVE_ANON || l == LRU_ACTIVE_FILE) {
+		shrink_active_list(nr_to_scan, zone, sc, priority, file);
 		return 0;
 	}
-	return shrink_inactive_list(nr_to_scan, zone, sc);
+	return shrink_inactive_list(nr_to_scan, zone, sc, file);
 }
 
 /*
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
+}
+
+
+/*
  * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
  */
 static unsigned long shrink_zone(int priority, struct zone *zone,
@@ -1214,23 +1206,28 @@ static unsigned long shrink_zone(int pri
 	unsigned long nr[NR_LRU_LISTS];
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	unsigned long percent[2];	/* anon @ 0; file @ 1 */
 	enum lru_list l;
 
+	get_scan_ratio(zone, sc, percent);
+
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
 	 * slowly sift through the active list.
 	 */
 	for_each_lru(l) {
-		zone->nr_scan[l] += (zone_page_state(zone, NR_INACTIVE + l)
+		int file = is_file_lru(l);
+		zone->nr_scan[l] += (zone_page_state(zone, NR_INACTIVE_ANON + l)
 							>> priority) + 1;
-		nr[l] = zone->nr_scan[l];
+		nr[l] = zone->nr_scan[l] * percent[file] / 100;
 		if (nr[l] >= sc->swap_cluster_max)
 			zone->nr_scan[l] = 0;
 		else
 			nr[l] = 0;
 	}
 
-	while (nr[LRU_ACTIVE] || nr[LRU_INACTIVE]) {
+	while (nr[LRU_ACTIVE_ANON] || nr[LRU_INACTIVE_ANON] ||
+			nr[LRU_ACTIVE_FILE] || nr[LRU_INACTIVE_FILE]) {
 		for_each_lru(l) {
 			if (nr[l]) {
 				nr_to_scan = min(nr[l],
@@ -1290,7 +1287,7 @@ static unsigned long shrink_zones(int pr
 	}
 	return nr_reclaimed;
 }
- 
+
 /*
  * This is the main entry point to direct page reclaim.
  *
@@ -1323,8 +1320,7 @@ static unsigned long do_try_to_free_page
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
 
-		lru_pages += zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE);
+		lru_pages += zone_lru_pages(zone);
 	}
 
 	for (priority = DEF_PRIORITY; priority >= 0; priority--) {
@@ -1525,8 +1521,7 @@ loop_again:
 		for (i = 0; i <= end_zone; i++) {
 			struct zone *zone = pgdat->node_zones + i;
 
-			lru_pages += zone_page_state(zone, NR_ACTIVE)
-					+ zone_page_state(zone, NR_INACTIVE);
+			lru_pages += zone_lru_pages(zone);
 		}
 
 		/*
@@ -1570,8 +1565,7 @@ loop_again:
 			if (zone_is_all_unreclaimable(zone))
 				continue;
 			if (nr_slab == 0 && zone->pages_scanned >=
-				(zone_page_state(zone, NR_ACTIVE)
-				+ zone_page_state(zone, NR_INACTIVE)) * 6)
+						(zone_lru_pages(zone) * 6))
 					zone_set_flag(zone,
 						      ZONE_ALL_UNRECLAIMABLE);
 			/*
@@ -1626,7 +1620,7 @@ out:
 
 /*
  * The background pageout daemon, started as a kernel thread
- * from the init process. 
+ * from the init process.
  *
  * This basically trickles out pages so that we have _some_
  * free memory available even if there is no other activity
@@ -1746,17 +1740,18 @@ static unsigned long shrink_all_zones(un
 
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
@@ -1768,9 +1763,12 @@ static unsigned long shrink_all_zones(un
 	return ret;
 }
 
-static unsigned long count_lru_pages(void)
+unsigned long global_lru_pages(void)
 {
-	return global_page_state(NR_ACTIVE) + global_page_state(NR_INACTIVE);
+	return global_page_state(NR_ACTIVE_ANON)
+		+ global_page_state(NR_ACTIVE_FILE)
+		+ global_page_state(NR_INACTIVE_ANON)
+		+ global_page_state(NR_INACTIVE_FILE);
 }
 
 /*
@@ -1798,7 +1796,7 @@ unsigned long shrink_all_memory(unsigned
 
 	current->reclaim_state = &reclaim_state;
 
-	lru_pages = count_lru_pages();
+	lru_pages = global_lru_pages();
 	nr_slab = global_page_state(NR_SLAB_RECLAIMABLE);
 	/* If slab caches are huge, it's better to hit them first */
 	while (nr_slab >= lru_pages) {
@@ -1841,7 +1839,7 @@ unsigned long shrink_all_memory(unsigned
 
 			reclaim_state.reclaimed_slab = 0;
 			shrink_slab(sc.nr_scanned, sc.gfp_mask,
-					count_lru_pages());
+					global_lru_pages());
 			ret += reclaim_state.reclaimed_slab;
 			if (ret >= nr_pages)
 				goto out;
@@ -1858,7 +1856,7 @@ unsigned long shrink_all_memory(unsigned
 	if (!ret) {
 		do {
 			reclaim_state.reclaimed_slab = 0;
-			shrink_slab(nr_pages, sc.gfp_mask, count_lru_pages());
+			shrink_slab(nr_pages, sc.gfp_mask, global_lru_pages());
 			ret += reclaim_state.reclaimed_slab;
 		} while (ret < nr_pages && reclaim_state.reclaimed_slab > 0);
 	}
Index: linux-2.6.23-mm1/mm/swap_state.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/swap_state.c
+++ linux-2.6.23-mm1/mm/swap_state.c
@@ -370,7 +370,7 @@ struct page *read_swap_cache_async(swp_e
 			/*
 			 * Initiate read into locked page and return.
 			 */
-			lru_cache_add_active(new_page);
+			lru_cache_add_active_anon(new_page);
 			swap_readpage(NULL, new_page);
 			return new_page;
 		}
Index: linux-2.6.23-mm1/include/linux/mmzone.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/mmzone.h
+++ linux-2.6.23-mm1/include/linux/mmzone.h
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
@@ -106,12 +108,20 @@ enum zone_stat_item {
 	NR_VM_ZONE_STAT_ITEMS };
 
 enum lru_list {
-	LRU_INACTIVE,	/* must match order of NR_[IN]ACTIVE */
-	LRU_ACTIVE,	/*  "     "     "   "       "        */
+	LRU_INACTIVE_ANON,	/* must be first enum  */
+	LRU_ACTIVE_ANON,	/* must match order of NR_[IN]ACTIVE_* */
+	LRU_INACTIVE_FILE,	/*  "     "     "   "       "          */
+	LRU_ACTIVE_FILE,	/*  "     "     "   "       "          */
 	NR_LRU_LISTS };
 
 #define for_each_lru(l) for (l = 0; l < NR_LRU_LISTS; l++)
 
+static inline int is_file_lru(enum lru_list l)
+{
+	BUILD_BUG_ON(LRU_INACTIVE_FILE != 2 || LRU_ACTIVE_FILE != 3);
+	return (l/2 == 1);
+}
+
 struct per_cpu_pages {
 	int count;		/* number of pages in the list */
 	int high;		/* high watermark, emptying needed */
@@ -267,6 +277,10 @@ struct zone {
 	spinlock_t		lru_lock;	
 	struct list_head	list[NR_LRU_LISTS];
 	unsigned long		nr_scan[NR_LRU_LISTS];
+
+	unsigned long		recent_rotated_anon;
+	unsigned long		recent_rotated_file;
+
 	unsigned long		pages_scanned;	   /* since last reclaim */
 	unsigned long		flags;		   /* zone flags, see below */
 
Index: linux-2.6.23-mm1/include/linux/mm_inline.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/mm_inline.h
+++ linux-2.6.23-mm1/include/linux/mm_inline.h
@@ -25,59 +25,84 @@ static inline int page_file_cache(struct
 	WARN_ON(mapping && mapping->a_ops && mapping->a_ops == &shmem_aops);
 
 	/* The page is page cache backed by a normal filesystem. */
-	return 2;
+	return (LRU_INACTIVE_FILE - LRU_INACTIVE_ANON);
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
 
+//TODO:  eventually these can all go away?  just use above 2 fcns?
+static inline void
+add_page_to_active_anon_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_ACTIVE_ANON);
+}
+
+static inline void
+add_page_to_inactive_anon_list(struct zone *zone, struct page *page)
+{
+	add_page_to_lru_list(zone, page, LRU_INACTIVE_ANON);
+}
+
+static inline void
+del_page_from_active_anon_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_ACTIVE_ANON);
+}
+
+static inline void
+del_page_from_inactive_anon_list(struct zone *zone, struct page *page)
+{
+	del_page_from_lru_list(zone, page, LRU_INACTIVE_ANON);
+}
 
 static inline void
-add_page_to_active_list(struct zone *zone, struct page *page)
+add_page_to_active_file_list(struct zone *zone, struct page *page)
 {
-	add_page_to_lru_list(zone, page, LRU_ACTIVE);
+	add_page_to_lru_list(zone, page, LRU_ACTIVE_FILE);
 }
 
 static inline void
-add_page_to_inactive_list(struct zone *zone, struct page *page)
+add_page_to_inactive_file_list(struct zone *zone, struct page *page)
 {
-	add_page_to_lru_list(zone, page, LRU_INACTIVE);
+	add_page_to_lru_list(zone, page, LRU_INACTIVE_FILE);
 }
 
 static inline void
-del_page_from_active_list(struct zone *zone, struct page *page)
+del_page_from_active_file_list(struct zone *zone, struct page *page)
 {
-	del_page_from_lru_list(zone, page, LRU_ACTIVE);
+	del_page_from_lru_list(zone, page, LRU_ACTIVE_FILE);
 }
 
 static inline void
-del_page_from_inactive_list(struct zone *zone, struct page *page)
+del_page_from_inactive_file_list(struct zone *zone, struct page *page)
 {
-	del_page_from_lru_list(zone, page, LRU_INACTIVE);
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
+		l = LRU_ACTIVE_ANON;
 	}
-	__dec_zone_state(zone, NR_INACTIVE + l);
+	l += page_file_cache(page);
+	__dec_zone_state(zone, NR_INACTIVE_ANON + l);
 }
 
 #endif
Index: linux-2.6.23-mm1/include/linux/pagevec.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/pagevec.h
+++ linux-2.6.23-mm1/include/linux/pagevec.h
@@ -23,8 +23,10 @@ struct pagevec {
 void __pagevec_release(struct pagevec *pvec);
 void __pagevec_release_nonlru(struct pagevec *pvec);
 void __pagevec_free(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec);
-void __pagevec_lru_add_active(struct pagevec *pvec);
+void __pagevec_lru_add_file(struct pagevec *pvec);
+void __pagevec_lru_add_active_file(struct pagevec *pvec);
+void __pagevec_lru_add_anon(struct pagevec *pvec);
+void __pagevec_lru_add_active_anon(struct pagevec *pvec);
 void pagevec_strip(struct pagevec *pvec);
 void pagevec_swap_free(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
@@ -82,10 +84,16 @@ static inline void pagevec_free(struct p
 		__pagevec_free(pvec);
 }
 
-static inline void pagevec_lru_add(struct pagevec *pvec)
+static inline void pagevec_lru_add_file(struct pagevec *pvec)
 {
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec);
+		__pagevec_lru_add_file(pvec);
+}
+
+static inline void pagevec_lru_add_anon(struct pagevec *pvec)
+{
+	if (pagevec_count(pvec))
+		__pagevec_lru_add_anon(pvec);
 }
 
 #endif /* _LINUX_PAGEVEC_H */
Index: linux-2.6.23-mm1/include/linux/vmstat.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/vmstat.h
+++ linux-2.6.23-mm1/include/linux/vmstat.h
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
Index: linux-2.6.23-mm1/mm/page-writeback.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/page-writeback.c
+++ linux-2.6.23-mm1/mm/page-writeback.c
@@ -264,9 +264,7 @@ static unsigned long highmem_dirtyable_m
 		struct zone *z =
 			&NODE_DATA(node)->node_zones[ZONE_HIGHMEM];
 
-		x += zone_page_state(z, NR_FREE_PAGES)
-			+ zone_page_state(z, NR_INACTIVE)
-			+ zone_page_state(z, NR_ACTIVE);
+		x += zone_page_state(z, NR_FREE_PAGES) + zone_lru_pages(z);
 	}
 	/*
 	 * Make sure that the number of highmem pages is never larger
@@ -284,9 +282,7 @@ static unsigned long determine_dirtyable
 {
 	unsigned long x;
 
-	x = global_page_state(NR_FREE_PAGES)
-		+ global_page_state(NR_INACTIVE)
-		+ global_page_state(NR_ACTIVE);
+	x = global_page_state(NR_FREE_PAGES) + global_lru_pages();
 	x -= highmem_dirtyable_memory(x);
 	return x + 1;	/* Ensure that we never return 0 */
 }
Index: linux-2.6.23-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/swap.h
+++ linux-2.6.23-mm1/include/linux/swap.h
@@ -174,8 +174,10 @@ extern unsigned int nr_free_pagecache_pa
 
 
 /* linux/mm/swap.c */
-extern void FASTCALL(lru_cache_add(struct page *));
-extern void FASTCALL(lru_cache_add_active(struct page *));
+extern void FASTCALL(lru_cache_add_file(struct page *));
+extern void FASTCALL(lru_cache_add_anon(struct page *));
+extern void FASTCALL(lru_cache_add_active_file(struct page *));
+extern void FASTCALL(lru_cache_add_active_anon(struct page *));
 extern void FASTCALL(activate_page(struct page *));
 extern void FASTCALL(mark_page_accessed(struct page *));
 extern void lru_add_drain(void);
Index: linux-2.6.23-mm1/include/linux/memcontrol.h
===================================================================
--- linux-2.6.23-mm1.orig/include/linux/memcontrol.h
+++ linux-2.6.23-mm1/include/linux/memcontrol.h
@@ -41,7 +41,7 @@ extern unsigned long mem_cgroup_isolate_
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active);
+					int active, int file);
 extern void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask);
 extern int mem_cgroup_cache_charge(struct page *page, struct mm_struct *mm,
 					gfp_t gfp_mask);
Index: linux-2.6.23-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.23-mm1.orig/mm/memcontrol.c
+++ linux-2.6.23-mm1/mm/memcontrol.c
@@ -201,7 +201,7 @@ unsigned long mem_cgroup_isolate_pages(u
 					unsigned long *scanned, int order,
 					int mode, struct zone *z,
 					struct mem_cgroup *mem_cont,
-					int active)
+					int active, int file)
 {
 	unsigned long nr_taken = 0;
 	struct page *page;
@@ -210,6 +210,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	struct list_head *src;
 	struct page_cgroup *pc;
 
+//TODO:  memory container maintain separate file/anon lists?
 	if (active)
 		src = &mem_cont->active_list;
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
