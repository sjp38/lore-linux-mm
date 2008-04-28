Message-Id: <20080428181853.486486976@redhat.com>
References: <20080428181835.502876582@redhat.com>
Date: Mon, 28 Apr 2008 14:18:50 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm 15/15] SHM_LOCKED pages are nonreclaimable
Content-Disposition: inline; filename=rvr-14-lts-noreclaim-SHM_LOCKED-pages-are-nonreclaimable.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: lee.schermerhorn@hp.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
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

Changes depend on [CONFIG_]NORECLAIM_LRU.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by:  Rik van Riel <riel@redhat.com>

 include/linux/pagemap.h |   10 ++++-
 include/linux/swap.h    |    4 ++
 mm/shmem.c              |    3 +
 mm/vmscan.c             |   85 ++++++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 100 insertions(+), 2 deletions(-)

Index: linux-2.6.25-mm1/mm/shmem.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/shmem.c	2008-04-24 12:00:01.000000000 -0400
+++ linux-2.6.25-mm1/mm/shmem.c	2008-04-24 12:04:11.000000000 -0400
@@ -1469,10 +1469,13 @@ int shmem_lock(struct file *file, int lo
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
Index: linux-2.6.25-mm1/include/linux/pagemap.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/pagemap.h	2008-04-24 12:04:06.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/pagemap.h	2008-04-24 12:04:11.000000000 -0400
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
Index: linux-2.6.25-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.25-mm1.orig/mm/vmscan.c	2008-04-24 12:04:06.000000000 -0400
+++ linux-2.6.25-mm1/mm/vmscan.c	2008-04-24 12:04:11.000000000 -0400
@@ -2277,4 +2277,89 @@ int page_reclaimable(struct page *page, 
 
 	return 1;
 }
+
+/**
+ * check_move_noreclaim_page - check page for reclaimability and move to appropriate zone lru list
+ * @page: page to check reclaimability and move to appropriate lru list
+ * @zone: zone page is in
+ *
+ * Checks a page for reclaimability and moves the page to the appropriate
+ * zone lru list.
+ *
+ * Restrictions: zone->lru_lock must be held, page must be on LRU and must
+ * have PageNoreclaim set.
+ */
+static void check_move_noreclaim_page(struct page *page, struct zone *zone)
+{
+
+	ClearPageNoreclaim(page); /* for page_reclaimable() */
+	if (page_reclaimable(page, NULL)) {
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
+/**
+ * scan_mapping_noreclaim_pages - scan an address space for reclaimable pages
+ * @mapping: struct address_space to scan for reclaimable pages
+ *
+ * Scan all pages in mapping.  Check non-reclaimable pages for
+ * reclaimability and move them to the appropriate zone lru list.
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
 #endif
Index: linux-2.6.25-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.25-mm1.orig/include/linux/swap.h	2008-04-24 12:03:54.000000000 -0400
+++ linux-2.6.25-mm1/include/linux/swap.h	2008-04-24 12:04:11.000000000 -0400
@@ -242,12 +242,16 @@ static inline int zone_reclaim(struct zo
 
 #ifdef CONFIG_NORECLAIM_LRU
 extern int page_reclaimable(struct page *page, struct vm_area_struct *vma);
+extern void scan_mapping_noreclaim_pages(struct address_space *);
 #else
 static inline int page_reclaimable(struct page *page,
 						struct vm_area_struct *vma)
 {
 	return 1;
 }
+static inline void scan_mapping_noreclaim_pages(struct address_space *mapping)
+{
+}
 #endif
 
 extern int kswapd_run(int nid);

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
