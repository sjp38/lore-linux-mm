Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id CEC1E6B0047
	for <linux-mm@kvack.org>; Fri,  3 Sep 2010 00:44:18 -0400 (EDT)
From: Ying Han <yinghan@google.com>
Subject: [PATCH] [RFC]Dirty page accounting on lru basis.
Date: Thu,  2 Sep 2010 21:43:02 -0700
Message-Id: <1283488982-19361-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: riel@redhat.com, minchan.kim@gmail.com, hugh.dickins@tiscali.co.uk, kamezawa.hiroyu@jp.fujitsu.com, fengguang.wu@intel.com, mel@csn.ul.ie, npiggin@suse.de, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For each active, inactive and unevictable lru list, we would like to count the
number of dirty file pages. This becomes useful when we start monitoring and
tracking the efficiency of page reclaim path while doing some heavy IO workloads.

We export the new accounting now through global proc/meminfo as well as per-node
meminfo. Ideally, the accounting should work as:

Dirty = ActiveDirty(file) + InactiveDirty(file) + Unevict_Dirty(file)

Example output:
$ ddtest -D /export/hda3/dd -b 1024 -n 1048576 -t 5 &

$ cat /proc/meminfo
ActiveDirty(file):       4044 kB
InactiveDirty(file):     8800 kB
Unevict_Dirty(file):        0 kB
Dirty:                  12844 kB

$ cat /sys/devices/system/node/node0/meminfo
Node 0 Active_Dirty(file):        656 kB
Node 0 Inactive_Dirty(file):     6336 kB
Node 0 Unevict_Dirty(file):         0 kB
Node 0 Dirty:                    6992 kB

The current patch doesn't do the work perfectly. Over certain period of time,
I observed a few pages difference on the two counters(total lru dirty vs dirty).
That is because the page can go from dirty->clean, and clean->dirty while on lru.
There is no lock I can grab to prevent that. A race would happen like:

1. account_page_dirtied
    if page on active
    -> __inc_zone_page_state_dirty on active
2. isolate_lru_pages from active
    if page is dirty
     -> dec_zone_page_state_dirty on active

Page can become dirty to clean between 1 and 2. So we end up have 1 more page count
on ActiveDirty.

At this moment, I would like to collect feedbacks from upstream if there is a
feasible way of solving the race condition here.

Signed-off-by: Ying Han <yinghan@google.com>
---
 drivers/base/node.c       |   64 ++++++++++++++++++---------------
 fs/proc/meminfo.c         |   86 ++++++++++++++++++++++++---------------------
 include/linux/mm.h        |    1 +
 include/linux/mm_inline.h |   35 ++++++++++++++++++
 include/linux/mmzone.h    |    3 ++
 include/linux/vmstat.h    |   15 ++++++++
 mm/filemap.c              |    2 +
 mm/page-writeback.c       |    6 +++
 mm/page_alloc.c           |    6 +++
 mm/truncate.c             |    2 +
 mm/vmscan.c               |   28 ++++++++++++++-
 mm/vmstat.c               |   41 +++++++++++++++++++++
 12 files changed, 219 insertions(+), 70 deletions(-)

diff --git a/drivers/base/node.c b/drivers/base/node.c
index 2872e86..de5f198 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -67,17 +67,20 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
 
 	si_meminfo_node(&i, nid);
 	n = sprintf(buf,
-		       "Node %d MemTotal:       %8lu kB\n"
-		       "Node %d MemFree:        %8lu kB\n"
-		       "Node %d MemUsed:        %8lu kB\n"
-		       "Node %d Active:         %8lu kB\n"
-		       "Node %d Inactive:       %8lu kB\n"
-		       "Node %d Active(anon):   %8lu kB\n"
-		       "Node %d Inactive(anon): %8lu kB\n"
-		       "Node %d Active(file):   %8lu kB\n"
-		       "Node %d Inactive(file): %8lu kB\n"
-		       "Node %d Unevictable:    %8lu kB\n"
-		       "Node %d Mlocked:        %8lu kB\n",
+		       "Node %d MemTotal:             %8lu kB\n"
+		       "Node %d MemFree:              %8lu kB\n"
+		       "Node %d MemUsed:              %8lu kB\n"
+		       "Node %d Active:               %8lu kB\n"
+		       "Node %d Inactive:             %8lu kB\n"
+		       "Node %d Active(anon):         %8lu kB\n"
+		       "Node %d Inactive(anon):       %8lu kB\n"
+		       "Node %d Active(file):         %8lu kB\n"
+		       "Node %d Inactive(file):       %8lu kB\n"
+		       "Node %d Unevictable:          %8lu kB\n"
+		       "Node %d Active_Dirty(file):   %8lu kB\n"
+		       "Node %d Inactive_Dirty(file): %8lu kB\n"
+		       "Node %d Unevict_Dirty(file):  %8lu kB\n"
+		       "Node %d Mlocked:              %8lu kB\n",
 		       nid, K(i.totalram),
 		       nid, K(i.freeram),
 		       nid, K(i.totalram - i.freeram),
@@ -90,34 +93,37 @@ static ssize_t node_read_meminfo(struct sys_device * dev,
 		       nid, K(node_page_state(nid, NR_ACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_INACTIVE_FILE)),
 		       nid, K(node_page_state(nid, NR_UNEVICTABLE)),
+		       nid, K(node_page_state(nid, NR_ACTIVE_DIRTY)),
+		       nid, K(node_page_state(nid, NR_INACTIVE_DIRTY)),
+		       nid, K(node_page_state(nid, NR_UNEVICTABLE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_MLOCK)));
 
 #ifdef CONFIG_HIGHMEM
 	n += sprintf(buf + n,
-		       "Node %d HighTotal:      %8lu kB\n"
-		       "Node %d HighFree:       %8lu kB\n"
-		       "Node %d LowTotal:       %8lu kB\n"
-		       "Node %d LowFree:        %8lu kB\n",
+		       "Node %d HighTotal:            %8lu kB\n"
+		       "Node %d HighFree:             %8lu kB\n"
+		       "Node %d LowTotal:             %8lu kB\n"
+		       "Node %d LowFree:              %8lu kB\n",
 		       nid, K(i.totalhigh),
 		       nid, K(i.freehigh),
 		       nid, K(i.totalram - i.totalhigh),
 		       nid, K(i.freeram - i.freehigh));
 #endif
 	n += sprintf(buf + n,
-		       "Node %d Dirty:          %8lu kB\n"
-		       "Node %d Writeback:      %8lu kB\n"
-		       "Node %d FilePages:      %8lu kB\n"
-		       "Node %d Mapped:         %8lu kB\n"
-		       "Node %d AnonPages:      %8lu kB\n"
-		       "Node %d Shmem:          %8lu kB\n"
-		       "Node %d KernelStack:    %8lu kB\n"
-		       "Node %d PageTables:     %8lu kB\n"
-		       "Node %d NFS_Unstable:   %8lu kB\n"
-		       "Node %d Bounce:         %8lu kB\n"
-		       "Node %d WritebackTmp:   %8lu kB\n"
-		       "Node %d Slab:           %8lu kB\n"
-		       "Node %d SReclaimable:   %8lu kB\n"
-		       "Node %d SUnreclaim:     %8lu kB\n",
+		       "Node %d Dirty:                %8lu kB\n"
+		       "Node %d Writeback:            %8lu kB\n"
+		       "Node %d FilePages:            %8lu kB\n"
+		       "Node %d Mapped:               %8lu kB\n"
+		       "Node %d AnonPages:            %8lu kB\n"
+		       "Node %d Shmem:                %8lu kB\n"
+		       "Node %d KernelStack:          %8lu kB\n"
+		       "Node %d PageTables:           %8lu kB\n"
+		       "Node %d NFS_Unstable:         %8lu kB\n"
+		       "Node %d Bounce:               %8lu kB\n"
+		       "Node %d WritebackTmp:         %8lu kB\n"
+		       "Node %d Slab:                 %8lu kB\n"
+		       "Node %d SReclaimable:         %8lu kB\n"
+		       "Node %d SUnreclaim:           %8lu kB\n",
 		       nid, K(node_page_state(nid, NR_FILE_DIRTY)),
 		       nid, K(node_page_state(nid, NR_WRITEBACK)),
 		       nid, K(node_page_state(nid, NR_FILE_PAGES)),
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index a65239c..ac2a664 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -53,53 +53,56 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	 * Tagged format, for easy grepping and expansion.
 	 */
 	seq_printf(m,
-		"MemTotal:       %8lu kB\n"
-		"MemFree:        %8lu kB\n"
-		"Buffers:        %8lu kB\n"
-		"Cached:         %8lu kB\n"
-		"SwapCached:     %8lu kB\n"
-		"Active:         %8lu kB\n"
-		"Inactive:       %8lu kB\n"
-		"Active(anon):   %8lu kB\n"
-		"Inactive(anon): %8lu kB\n"
-		"Active(file):   %8lu kB\n"
-		"Inactive(file): %8lu kB\n"
-		"Unevictable:    %8lu kB\n"
-		"Mlocked:        %8lu kB\n"
+		"MemTotal:            %8lu kB\n"
+		"MemFree:             %8lu kB\n"
+		"Buffers:             %8lu kB\n"
+		"Cached:              %8lu kB\n"
+		"SwapCached:          %8lu kB\n"
+		"Active:              %8lu kB\n"
+		"Inactive:            %8lu kB\n"
+		"Active(anon):        %8lu kB\n"
+		"Inactive(anon):      %8lu kB\n"
+		"Active(file):        %8lu kB\n"
+		"Inactive(file):      %8lu kB\n"
+		"Unevictable:         %8lu kB\n"
+		"ActiveDirty(file):   %8lu kB\n"
+		"InactiveDirty(file): %8lu kB\n"
+		"Unevict_Dirty(file): %8lu kB\n"
+		"Mlocked:             %8lu kB\n"
 #ifdef CONFIG_HIGHMEM
-		"HighTotal:      %8lu kB\n"
-		"HighFree:       %8lu kB\n"
-		"LowTotal:       %8lu kB\n"
-		"LowFree:        %8lu kB\n"
+		"HighTotal:           %8lu kB\n"
+		"HighFree:            %8lu kB\n"
+		"LowTotal:            %8lu kB\n"
+		"LowFree:             %8lu kB\n"
 #endif
 #ifndef CONFIG_MMU
-		"MmapCopy:       %8lu kB\n"
+		"MmapCopy:            %8lu kB\n"
 #endif
-		"SwapTotal:      %8lu kB\n"
-		"SwapFree:       %8lu kB\n"
-		"Dirty:          %8lu kB\n"
-		"Writeback:      %8lu kB\n"
-		"AnonPages:      %8lu kB\n"
-		"Mapped:         %8lu kB\n"
-		"Shmem:          %8lu kB\n"
-		"Slab:           %8lu kB\n"
-		"SReclaimable:   %8lu kB\n"
-		"SUnreclaim:     %8lu kB\n"
-		"KernelStack:    %8lu kB\n"
-		"PageTables:     %8lu kB\n"
+		"SwapTotal:           %8lu kB\n"
+		"SwapFree:            %8lu kB\n"
+		"Dirty:               %8lu kB\n"
+		"Writeback:           %8lu kB\n"
+		"AnonPages:           %8lu kB\n"
+		"Mapped:              %8lu kB\n"
+		"Shmem:               %8lu kB\n"
+		"Slab:                %8lu kB\n"
+		"SReclaimable:        %8lu kB\n"
+		"SUnreclaim:          %8lu kB\n"
+		"KernelStack:         %8lu kB\n"
+		"PageTables:          %8lu kB\n"
 #ifdef CONFIG_QUICKLIST
-		"Quicklists:     %8lu kB\n"
+		"Quicklists:          %8lu kB\n"
 #endif
-		"NFS_Unstable:   %8lu kB\n"
-		"Bounce:         %8lu kB\n"
-		"WritebackTmp:   %8lu kB\n"
-		"CommitLimit:    %8lu kB\n"
-		"Committed_AS:   %8lu kB\n"
-		"VmallocTotal:   %8lu kB\n"
-		"VmallocUsed:    %8lu kB\n"
-		"VmallocChunk:   %8lu kB\n"
+		"NFS_Unstable:        %8lu kB\n"
+		"Bounce:              %8lu kB\n"
+		"WritebackTmp:        %8lu kB\n"
+		"CommitLimit:         %8lu kB\n"
+		"Committed_AS:        %8lu kB\n"
+		"VmallocTotal:        %8lu kB\n"
+		"VmallocUsed:         %8lu kB\n"
+		"VmallocChunk:        %8lu kB\n"
 #ifdef CONFIG_MEMORY_FAILURE
-		"HardwareCorrupted: %5lu kB\n"
+		"HardwareCorrupted:   %5lu kB\n"
 #endif
 		,
 		K(i.totalram),
@@ -114,6 +117,9 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		K(pages[LRU_ACTIVE_FILE]),
 		K(pages[LRU_INACTIVE_FILE]),
 		K(pages[LRU_UNEVICTABLE]),
+		K(global_page_state(NR_ACTIVE_DIRTY)),
+		K(global_page_state(NR_INACTIVE_DIRTY)),
+		K(global_page_state(NR_UNEVICTABLE_DIRTY)),
 		K(global_page_state(NR_MLOCK)),
 #ifdef CONFIG_HIGHMEM
 		K(i.totalhigh),
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e6b1210..9ae8a1a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -14,6 +14,7 @@
 #include <linux/mm_types.h>
 #include <linux/range.h>
 #include <linux/pfn.h>
+#include <linux/backing-dev.h>
 
 struct mempolicy;
 struct anon_vma;
diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
index 8835b87..754cecb 100644
--- a/include/linux/mm_inline.h
+++ b/include/linux/mm_inline.h
@@ -22,17 +22,41 @@ static inline int page_is_file_cache(struct page *page)
 static inline void
 add_page_to_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
+	struct address_space *mapping = page_mapping(page);
+
 	list_add(&page->lru, &zone->lru[l].list);
 	__inc_zone_state(zone, NR_LRU_BASE + l);
 	mem_cgroup_add_lru_list(page, l);
+	if (PageDirty(page) && mapping &&
+			mapping_cap_account_dirty(mapping)) {
+		if (is_active_lru(l))
+			__inc_zone_state(zone, NR_ACTIVE_DIRTY);
+		else if (is_unevictable_lru(l))
+			__inc_zone_state(zone, NR_UNEVICTABLE_DIRTY);
+		else
+			__inc_zone_state(zone, NR_INACTIVE_DIRTY);
+	}
+
 }
 
 static inline void
 del_page_from_lru_list(struct zone *zone, struct page *page, enum lru_list l)
 {
+	struct address_space *mapping = page_mapping(page);
+
 	list_del(&page->lru);
 	__dec_zone_state(zone, NR_LRU_BASE + l);
 	mem_cgroup_del_lru_list(page, l);
+
+	if (PageDirty(page) && mapping &&
+			mapping_cap_account_dirty(mapping)) {
+		if (is_active_lru(l))
+			__dec_zone_state(zone, NR_ACTIVE_DIRTY);
+		else if (is_unevictable_lru(l))
+			__dec_zone_state(zone, NR_UNEVICTABLE_DIRTY);
+		else
+			__dec_zone_state(zone, NR_INACTIVE_DIRTY);
+	}
 }
 
 /**
@@ -54,17 +78,28 @@ static inline void
 del_page_from_lru(struct zone *zone, struct page *page)
 {
 	enum lru_list l;
+	struct address_space *mapping = page_mapping(page);
 
 	list_del(&page->lru);
 	if (PageUnevictable(page)) {
 		__ClearPageUnevictable(page);
 		l = LRU_UNEVICTABLE;
+		if (PageDirty(page) && mapping &&
+				mapping_cap_account_dirty(mapping))
+			__dec_zone_state(zone, NR_UNEVICTABLE_DIRTY);
 	} else {
 		l = page_lru_base_type(page);
 		if (PageActive(page)) {
 			__ClearPageActive(page);
 			l += LRU_ACTIVE;
 		}
+		if (PageDirty(page) && mapping &&
+				mapping_cap_account_dirty(mapping)) {
+			if (is_active_lru(l))
+				__dec_zone_state(zone, NR_ACTIVE_DIRTY);
+			else
+				__dec_zone_state(zone, NR_INACTIVE_DIRTY);
+		}
 	}
 	__dec_zone_state(zone, NR_LRU_BASE + l);
 	mem_cgroup_del_lru_list(page, l);
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 6e6e626..033d1f9 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -85,6 +85,9 @@ enum zone_stat_item {
 	NR_INACTIVE_FILE,	/*  "     "     "   "       "         */
 	NR_ACTIVE_FILE,		/*  "     "     "   "       "         */
 	NR_UNEVICTABLE,		/*  "     "     "   "       "         */
+	NR_INACTIVE_DIRTY,
+	NR_ACTIVE_DIRTY,
+	NR_UNEVICTABLE_DIRTY,
 	NR_MLOCK,		/* mlock()ed pages found and moved off LRU */
 	NR_ANON_PAGES,	/* Mapped anonymous pages */
 	NR_FILE_MAPPED,	/* pagecache pages mapped into pagetables.
diff --git a/include/linux/vmstat.h b/include/linux/vmstat.h
index 7f43ccd..77e5f4f 100644
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -218,12 +218,15 @@ static inline void zap_zone_vm_stats(struct zone *zone)
 extern void inc_zone_state(struct zone *, enum zone_stat_item);
 
 #ifdef CONFIG_SMP
+void __mod_zone_page_state_dirty(struct zone *, enum zone_stat_item item, int);
 void __mod_zone_page_state(struct zone *, enum zone_stat_item item, int);
+void __inc_zone_page_state_dirty(struct page *);
 void __inc_zone_page_state(struct page *, enum zone_stat_item);
 void __dec_zone_page_state(struct page *, enum zone_stat_item);
 
 void mod_zone_page_state(struct zone *, enum zone_stat_item, int);
 void inc_zone_page_state(struct page *, enum zone_stat_item);
+void dec_zone_page_state_dirty(struct page *);
 void dec_zone_page_state(struct page *, enum zone_stat_item);
 
 extern void inc_zone_state(struct zone *, enum zone_stat_item);
@@ -238,6 +241,17 @@ void refresh_cpu_vm_stats(int);
  * We do not maintain differentials in a single processor configuration.
  * The functions directly modify the zone and global counters.
  */
+static inline void __mod_zone_page_state_dirty(struct zone *zone,
+			enum zone_stat_item item, int delta)
+{
+	if (is_active_lru(item))
+		zone_page_state_add(delta, zone, NR_ACTIVE_DIRTY);
+	else if (is_unevictable_lru(item))
+		zone_page_state_add(delta, zone, NR_UNEVICTABLE_DIRTY);
+	else
+		zone_page_state_add(delta, zone, NR_INACTIVE_DIRTY);
+}
+
 static inline void __mod_zone_page_state(struct zone *zone,
 			enum zone_stat_item item, int delta)
 {
@@ -275,6 +289,7 @@ static inline void __dec_zone_page_state(struct page *page,
 #define inc_zone_page_state __inc_zone_page_state
 #define dec_zone_page_state __dec_zone_page_state
 #define mod_zone_page_state __mod_zone_page_state
+#define dec_zone_page_state_dirty __dec_zone_page_state_dirty
 
 static inline void refresh_cpu_vm_stats(int cpu) { }
 #endif
diff --git a/mm/filemap.c b/mm/filemap.c
index 3d4df44..597aca0 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -137,6 +137,8 @@ void __remove_from_page_cache(struct page *page)
 	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
 		dec_zone_page_state(page, NR_FILE_DIRTY);
 		dec_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		if (PageLRU(page))
+			dec_zone_page_state_dirty(page);
 	}
 }
 
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index e3bccac..c65916d 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -1122,7 +1122,10 @@ void account_page_dirtied(struct page *page, struct address_space *mapping)
 	if (mapping_cap_account_dirty(mapping)) {
 		__inc_zone_page_state(page, NR_FILE_DIRTY);
 		__inc_bdi_stat(mapping->backing_dev_info, BDI_RECLAIMABLE);
+		if (PageLRU(page))
+			__inc_zone_page_state_dirty(page);
 		task_dirty_inc(current);
+
 		task_io_account_write(PAGE_CACHE_SIZE);
 	}
 }
@@ -1299,6 +1302,9 @@ int clear_page_dirty_for_io(struct page *page)
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
+			if (PageLRU(page))
+				dec_zone_page_state_dirty(page);
+
 			return 1;
 		}
 		return 0;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a9649f4..1f26a3e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2404,6 +2404,9 @@ void show_free_areas(void)
 			" active_file:%lukB"
 			" inactive_file:%lukB"
 			" unevictable:%lukB"
+			" active_dirty:%lukB"
+			" inactive_dirty:%lukB"
+			" unevictable_dirty:%lukB"
 			" isolated(anon):%lukB"
 			" isolated(file):%lukB"
 			" present:%lukB"
@@ -2432,6 +2435,9 @@ void show_free_areas(void)
 			K(zone_page_state(zone, NR_ACTIVE_FILE)),
 			K(zone_page_state(zone, NR_INACTIVE_FILE)),
 			K(zone_page_state(zone, NR_UNEVICTABLE)),
+			K(zone_page_state(zone, NR_ACTIVE_DIRTY)),
+			K(zone_page_state(zone, NR_INACTIVE_DIRTY)),
+			K(zone_page_state(zone, NR_UNEVICTABLE_DIRTY)),
 			K(zone_page_state(zone, NR_ISOLATED_ANON)),
 			K(zone_page_state(zone, NR_ISOLATED_FILE)),
 			K(zone->present_pages),
diff --git a/mm/truncate.c b/mm/truncate.c
index ba887bf..1659420 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -77,6 +77,8 @@ void cancel_dirty_page(struct page *page, unsigned int account_size)
 			dec_zone_page_state(page, NR_FILE_DIRTY);
 			dec_bdi_stat(mapping->backing_dev_info,
 					BDI_RECLAIMABLE);
+			if (PageLRU(page))
+				dec_zone_page_state_dirty(page);
 			if (account_size)
 				task_io_account_cancelled_write(account_size);
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c391c32..b67f785 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -952,8 +952,10 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		unsigned long end_pfn;
 		unsigned long page_pfn;
 		int zone_id;
+		struct address_space *mapping;
 
 		page = lru_to_page(src);
+		mapping = page_mapping(page);
 		prefetchw_prev_lru_page(page, src, flags);
 
 		VM_BUG_ON(!PageLRU(page));
@@ -963,6 +965,9 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 			list_move(&page->lru, dst);
 			mem_cgroup_del_lru(page);
 			nr_taken++;
+			if (PageDirty(page) && mapping &&
+					mapping_cap_account_dirty(mapping))
+				dec_zone_page_state_dirty(page);
 			break;
 
 		case -EBUSY:
@@ -993,6 +998,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 		end_pfn = pfn + (1 << order);
 		for (; pfn < end_pfn; pfn++) {
 			struct page *cursor_page;
+			struct address_space *mapping;
 
 			/* The target page is in the block, ignore it. */
 			if (unlikely(pfn == page_pfn))
@@ -1003,6 +1009,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				break;
 
 			cursor_page = pfn_to_page(pfn);
+			mapping = page_mapping(cursor_page);
 
 			/* Check that we have not crossed a zone boundary. */
 			if (unlikely(page_zone_id(cursor_page) != zone_id))
@@ -1024,6 +1031,10 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
 				nr_lumpy_taken++;
 				if (PageDirty(cursor_page))
 					nr_lumpy_dirty++;
+
+				if (PageDirty(cursor_page) && mapping &&
+				    mapping_cap_account_dirty(mapping))
+					dec_zone_page_state_dirty(cursor_page);
 				scan++;
 			} else {
 				if (mode == ISOLATE_BOTH &&
@@ -1149,7 +1160,6 @@ static int too_many_isolated(struct zone *zone, int file,
 		inactive = zone_page_state(zone, NR_INACTIVE_ANON);
 		isolated = zone_page_state(zone, NR_ISOLATED_ANON);
 	}
-
 	return isolated > inactive;
 }
 
@@ -1385,19 +1395,25 @@ static void move_active_pages_to_lru(struct zone *zone,
 				     enum lru_list lru)
 {
 	unsigned long pgmoved = 0;
+	unsigned long pgdirty = 0;
 	struct pagevec pvec;
 	struct page *page;
+	struct address_space *mapping;
 
 	pagevec_init(&pvec, 1);
 
 	while (!list_empty(list)) {
 		page = lru_to_page(list);
+		mapping = page_mapping(page);
 
 		VM_BUG_ON(PageLRU(page));
 		SetPageLRU(page);
 
 		list_move(&page->lru, &zone->lru[lru].list);
 		mem_cgroup_add_lru_list(page, lru);
+		if (PageDirty(page) && mapping &&
+				mapping_cap_account_dirty(mapping))
+			pgdirty++;
 		pgmoved++;
 
 		if (!pagevec_add(&pvec, page) || list_empty(list)) {
@@ -1409,6 +1425,8 @@ static void move_active_pages_to_lru(struct zone *zone,
 		}
 	}
 	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	__mod_zone_page_state_dirty(zone, lru, pgdirty);
+
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1774,6 +1792,7 @@ static void shrink_zone(int priority, struct zone *zone,
 		 */
 		if (nr_reclaimed >= nr_to_reclaim && priority < DEF_PRIORITY)
 			break;
+
 	}
 
 	sc->nr_reclaimed = nr_reclaimed;
@@ -2800,6 +2819,7 @@ int page_evictable(struct page *page, struct vm_area_struct *vma)
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
 {
+	struct address_space *mapping = page_mapping(page);
 	VM_BUG_ON(PageActive(page));
 
 retry:
@@ -2812,6 +2832,12 @@ retry:
 		mem_cgroup_move_lists(page, LRU_UNEVICTABLE, l);
 		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
 		__count_vm_event(UNEVICTABLE_PGRESCUED);
+		if (PageDirty(page) && mapping &&
+				mapping_cap_account_dirty(mapping)) {
+			__dec_zone_state(zone, NR_UNEVICTABLE_DIRTY);
+			__inc_zone_state(zone, NR_INACTIVE_DIRTY);
+		}
+
 	} else {
 		/*
 		 * rotate unevictable list
diff --git a/mm/vmstat.c b/mm/vmstat.c
index f389168..ee738b7 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -146,6 +146,18 @@ static void refresh_zone_stat_thresholds(void)
 	}
 }
 
+void __mod_zone_page_state_dirty(struct zone *zone,
+				enum zone_stat_item item, int delta)
+{
+	if (is_active_lru(item))
+		__mod_zone_page_state(zone, NR_ACTIVE_DIRTY, delta);
+	else if (is_unevictable_lru(item))
+		__mod_zone_page_state(zone, NR_UNEVICTABLE_DIRTY, delta);
+	else
+		__mod_zone_page_state(zone, NR_INACTIVE_DIRTY, delta);
+}
+EXPORT_SYMBOL(__mod_zone_page_state_dirty);
+
 /*
  * For use when we know that interrupts are disabled.
  */
@@ -219,6 +231,17 @@ void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
 	}
 }
 
+void __inc_zone_page_state_dirty(struct page *page)
+{
+	if (PageActive(page))
+		__inc_zone_page_state(page, NR_ACTIVE_DIRTY);
+	else if (PageUnevictable(page))
+		__inc_zone_page_state(page, NR_UNEVICTABLE_DIRTY);
+	else
+		__inc_zone_page_state(page, NR_INACTIVE_DIRTY);
+}
+EXPORT_SYMBOL(__inc_zone_page_state_dirty);
+
 void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	__inc_zone_state(page_zone(page), item);
@@ -267,6 +290,21 @@ void inc_zone_page_state(struct page *page, enum zone_stat_item item)
 }
 EXPORT_SYMBOL(inc_zone_page_state);
 
+void dec_zone_page_state_dirty(struct page *page)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	if (PageActive(page))
+		__dec_zone_page_state(page, NR_ACTIVE_DIRTY);
+	else if (PageUnevictable(page))
+		__dec_zone_page_state(page, NR_UNEVICTABLE_DIRTY);
+	else
+		__dec_zone_page_state(page, NR_INACTIVE_DIRTY);
+	local_irq_restore(flags);
+}
+EXPORT_SYMBOL(dec_zone_page_state_dirty);
+
 void dec_zone_page_state(struct page *page, enum zone_stat_item item)
 {
 	unsigned long flags;
@@ -715,6 +753,9 @@ static const char * const vmstat_text[] = {
 	"nr_inactive_file",
 	"nr_active_file",
 	"nr_unevictable",
+	"nr_inactive_dirty",
+	"nr_active_dirty",
+	"nr_unevictable_dirty",
 	"nr_mlock",
 	"nr_anon_pages",
 	"nr_mapped",
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
