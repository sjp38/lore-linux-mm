Message-Id: <20080228192929.369262007@redhat.com>
References: <20080228192908.126720629@redhat.com>
Date: Thu, 28 Feb 2008 14:29:24 -0500
From: Rik van Riel <riel@redhat.com>
Subject: [patch 16/21] SHM_LOCKED pages are nonreclaimable
Content-Disposition: inline; filename=noreclaim-03-SHM_LOCKed-pages-are-nonreclaimable.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Lee Schermerhorn <lee.schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

V2 -> V3:
+ rebase to 23-mm1 atop RvR's split LRU series.
+ Use scan_mapping_noreclaim_page() on unlock.  See below.

V1 -> V2:
+  modify to use reworked 'scan_all_zones_noreclaim_pages()'
   See 'TODO' below - still pending.

While working with Nick Piggin's mlock patches, I noticed that
shmem segments locked via shmctl(SHM_LOCKED) were not being handled.
SHM_LOCKed pages work like ramdisk pages--the writeback function
just redirties the page so that it can't be reclaimed.  Deal with
these using the same approach as for ram disk pages.

Use the AS_NORECLAIM flag to mark address_space of SHM_LOCKed
shared memory regions as non-reclaimable.  Then these pages
will be culled off the normal LRU lists during vmscan.

Add new wrapper function to clear the mapping's noreclaim state
when/if shared memory segment is munlocked.

Add 'scan_mapping_noreclaim_page()' to mm/vmscan.c to scan all
pages in the shmem segment's mapping [struct address_space] for
reclaimability now that they're no longer locked.  If so, move
them to the appropriate zone lru list.

Changes depend on [CONFIG_]NORECLAIM.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

Index: linux-2.6.25-rc2-mm1/mm/shmem.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/shmem.c	2008-02-28 00:26:04.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/shmem.c	2008-02-28 12:48:57.000000000 -0500
@@ -1525,10 +1525,13 @@ int shmem_lock(struct file *file, int lo
 		if (!user_shm_lock(inode->i_size, user))
 			goto out_nomem;
 		info->flags |= VM_LOCKED;
+		mapping_set_noreclaim(file->f_mapping);
 	}
 	if (!lock && (info->flags & VM_LOCKED) && user) {
 		user_shm_unlock(inode->i_size, user);
 		info->flags &= ~VM_LOCKED;
+		mapping_clear_noreclaim(file->f_mapping);
+		scan_mapping_noreclaim_pages(file->f_mapping);
 	}
 	retval = 0;
 out_nomem:
Index: linux-2.6.25-rc2-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/pagemap.h	2008-02-28 12:48:52.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/pagemap.h	2008-02-28 12:48:57.000000000 -0500
@@ -38,14 +38,20 @@ static inline void mapping_set_noreclaim
 	set_bit(AS_NORECLAIM, &mapping->flags);
 }
 
+static inline void mapping_clear_noreclaim(struct address_space *mapping)
+{
+	clear_bit(AS_NORECLAIM, &mapping->flags);
+}
+
 static inline int mapping_non_reclaimable(struct address_space *mapping)
 {
-	if (mapping && (mapping->flags & AS_NORECLAIM))
-		return 1;
+	if (mapping)
+		return test_bit(AS_NORECLAIM, &mapping->flags);
 	return 0;
 }
 #else
 static inline void mapping_set_noreclaim(struct address_space *mapping) { }
+static inline void mapping_clear_noreclaim(struct address_space *mapping) { }
 static inline int mapping_non_reclaimable(struct address_space *mapping)
 {
 	return 0;
Index: linux-2.6.25-rc2-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-rc2-mm1.orig/mm/vmscan.c	2008-02-28 12:48:52.000000000 -0500
+++ linux-2.6.25-rc2-mm1/mm/vmscan.c	2008-02-28 12:48:57.000000000 -0500
@@ -2301,6 +2301,30 @@ int page_reclaimable(struct page *page, 
 	return 1;
 }
 
+/*
+ * check_move_noreclaim_page() -- check @page for reclaimability and move
+ * to appropriate @zone lru list.
+ * @zone->lru_lock held on entry/exit.
+ * @page is on LRU and has PageNoreclaim true
+ */
+static void check_move_noreclaim_page(struct page *page, struct zone* zone)
+{
+
+	ClearPageNoreclaim(page); /* for page_reclaimable() */
+	if(page_reclaimable(page, NULL)) {
+		enum lru_list l = LRU_INACTIVE_ANON + page_file_cache(page);
+		__dec_zone_state(zone, NR_NORECLAIM);
+		list_move(&page->lru, &zone->list[l]);
+		__inc_zone_state(zone, NR_INACTIVE_ANON + l);
+	} else {
+		/*
+		 * rotate noreclaim list
+		 */
+		SetPageNoreclaim(page);
+		list_move(&page->lru, &zone->list[LRU_NORECLAIM]);
+	}
+}
+
 /**
  * scan_zone_noreclaim_pages(@zone)
  * @zone - zone to scan
@@ -2315,8 +2339,6 @@ int page_reclaimable(struct page *page, 
 void scan_zone_noreclaim_pages(struct zone *zone)
 {
 	struct list_head *l_noreclaim = &zone->list[LRU_NORECLAIM];
-	struct list_head *l_inactive_anon  = &zone->list[LRU_INACTIVE_ANON];
-	struct list_head *l_inactive_file  = &zone->list[LRU_INACTIVE_FILE];
 	unsigned long scan;
 	unsigned long nr_to_scan = zone_page_state(zone, NR_NORECLAIM);
 
@@ -2328,26 +2350,15 @@ void scan_zone_noreclaim_pages(struct zo
 		for (scan = 0;  scan < batch_size; scan++) {
 			struct page* page = lru_to_page(l_noreclaim);
 
-			if (unlikely(!PageLRU(page) || !PageNoreclaim(page)))
+			if (TestSetPageLocked(page))
 				continue;
 
 			prefetchw_prev_lru_page(page, l_noreclaim, flags);
 
-			ClearPageNoreclaim(page); /* for page_reclaimable() */
-			if(page_reclaimable(page, NULL)) {
-				__dec_zone_state(zone, NR_NORECLAIM);
-				if (page_file_cache(page)) {
-					list_move(&page->lru, l_inactive_file);
-					__inc_zone_state(zone, NR_INACTIVE_FILE);
-				} else {
-					list_move(&page->lru, l_inactive_anon);
-					__inc_zone_state(zone, NR_INACTIVE_ANON);
-				}
-			} else {
-				SetPageNoreclaim(page);
-				list_move(&page->lru, l_noreclaim);
-			}
+			if (likely(PageLRU(page) && PageNoreclaim(page)))
+				check_move_noreclaim_page(page, zone);
 
+			unlock_page(page);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 
@@ -2377,6 +2388,62 @@ void scan_all_zones_noreclaim_pages(void
 	}
 }
 
+/**
+ * scan_mapping_noreclaim_pages(mapping)
+ * @mapping - struct address_space to scan for reclaimable pages
+ *
+ * scan all pages in mapping.  check non-reclaimable pages for
+ * reclaimabililty and move them to the appropriate zone lru list.
+ */
+void scan_mapping_noreclaim_pages(struct address_space *mapping)
+{
+	pgoff_t next = 0;
+	pgoff_t end   = i_size_read(mapping->host);
+	struct zone *zone;
+	struct pagevec pvec;
+
+	if (mapping->nrpages == 0)
+		return;
+
+	pagevec_init(&pvec, 0);
+	while (next < end &&
+		pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
+		int i;
+
+		zone = NULL;
+
+		for (i = 0; i < pagevec_count(&pvec); i++) {
+			struct page *page = pvec.pages[i];
+			pgoff_t page_index = page->index;
+			struct zone *pagezone = page_zone(page);
+
+			if (page_index > next)
+				next = page_index;
+			next++;
+
+			if (TestSetPageLocked(page))
+				continue;
+
+			if (pagezone != zone) {
+				if (zone)
+					spin_unlock(&zone->lru_lock);
+				zone = pagezone;
+				spin_lock(&zone->lru_lock);
+			}
+
+			if (PageLRU(page) && PageNoreclaim(page))
+				check_move_noreclaim_page(page, zone);
+
+			unlock_page(page);
+
+		}
+		if (zone)
+			spin_unlock(&zone->lru_lock);
+		pagevec_release(&pvec);
+	}
+
+}
+
 /*
  * scan_noreclaim_pages [vm] sysctl handler.  On demand re-scan of
  * all nodes' noreclaim lists for reclaimable pages
Index: linux-2.6.25-rc2-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.25-rc2-mm1.orig/include/linux/swap.h	2008-02-28 12:48:26.000000000 -0500
+++ linux-2.6.25-rc2-mm1/include/linux/swap.h	2008-02-28 12:48:57.000000000 -0500
@@ -247,6 +247,7 @@ static inline int zone_reclaim(struct zo
 extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
 extern void scan_zone_noreclaim_pages(struct zone *);
 extern void scan_all_zones_noreclaim_pages(void);
+extern void scan_mapping_noreclaim_pages(struct address_space *);
 extern unsigned long scan_noreclaim_pages;
 extern int scan_noreclaim_handler(struct ctl_table *, int, struct file *,
 					void __user *, size_t *, loff_t *);
@@ -260,6 +261,9 @@ static inline int page_reclaimable(struc
 }
 static inline void scan_zone_noreclaim_pages(struct zone *z) { }
 static inline void scan_all_zones_noreclaim_pages(void) { }
+static inline void scan_mapping_noreclaim_pages(struct address_space *mapping)
+{
+}
 static inline int scan_noreclaim_register_node(struct node *node)
 {
 	return 0;

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
