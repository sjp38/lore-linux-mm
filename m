Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 02E2F6B008C
	for <linux-mm@kvack.org>; Sun, 22 Feb 2009 18:16:40 -0500 (EST)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 20/20] Get rid of the concept of hot/cold page freeing
Date: Sun, 22 Feb 2009 23:17:29 +0000
Message-Id: <1235344649-18265-21-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
References: <1235344649-18265-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>, Linux Memory Management List <linux-mm@kvack.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Lin Ming <ming.m.lin@intel.com>, Zhang Yanmin <yanmin_zhang@linux.intel.com>
List-ID: <linux-mm.kvack.org>

Currently an effort is made to determine if a page is hot or cold when
it is being freed so that cache hot pages can be allocated to callers if
possible. However, the reasoning used whether to mark something hot or
cold is a bit spurious. A profile run of kernbench showed that "cold"
pages were never freed so it either doesn't happen generally or is so
rare, it's barely measurable.

It's dubious as to whether pages are being correctly marked hot and cold
anyway. Things like page cache and pages being truncated are are considered
"hot" but there is no guarantee that these pages have been recently used
and are cache hot. Pages being reclaimed from the LRU are considered
cold which is logical because they cannot have been referenced recently
but if the system is reclaiming pages, then we have entered allocator
slowpaths and are not going to notice any potential performance boost
because a "hot" page was freed.

This patch just deletes the concept of freeing hot or cold pages and
just frees them all as hot.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
---
 fs/afs/write.c              |    4 ++--
 fs/btrfs/compression.c      |    2 +-
 fs/btrfs/extent_io.c        |    4 ++--
 fs/btrfs/ordered-data.c     |    2 +-
 fs/cifs/file.c              |    4 ++--
 fs/gfs2/ops_address.c       |    2 +-
 fs/hugetlbfs/inode.c        |    2 +-
 fs/nfs/dir.c                |    2 +-
 fs/ntfs/file.c              |    2 +-
 fs/ramfs/file-nommu.c       |    2 +-
 fs/xfs/linux-2.6/xfs_aops.c |    4 ++--
 include/linux/gfp.h         |    3 +--
 include/linux/pagemap.h     |    2 +-
 include/linux/pagevec.h     |    4 +---
 include/linux/swap.h        |    2 +-
 mm/filemap.c                |    2 +-
 mm/page-writeback.c         |    2 +-
 mm/page_alloc.c             |   21 ++++++---------------
 mm/swap.c                   |   12 ++++++------
 mm/swap_state.c             |    2 +-
 mm/truncate.c               |    6 +++---
 mm/vmscan.c                 |    8 ++++----
 22 files changed, 41 insertions(+), 53 deletions(-)

diff --git a/fs/afs/write.c b/fs/afs/write.c
index 3fb36d4..172f8ae 100644
--- a/fs/afs/write.c
+++ b/fs/afs/write.c
@@ -285,7 +285,7 @@ static void afs_kill_pages(struct afs_vnode *vnode, bool error,
 	_enter("{%x:%u},%lx-%lx",
 	       vnode->fid.vid, vnode->fid.vnode, first, last);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("kill %lx-%lx", first, last);
@@ -621,7 +621,7 @@ void afs_pages_written_back(struct afs_vnode *vnode, struct afs_call *call)
 
 	ASSERT(wb != NULL);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("done %lx-%lx", first, last);
diff --git a/fs/btrfs/compression.c b/fs/btrfs/compression.c
index ab07627..e141e59 100644
--- a/fs/btrfs/compression.c
+++ b/fs/btrfs/compression.c
@@ -462,7 +462,7 @@ static noinline int add_ra_bio_pages(struct inode *inode,
 
 	end_index = (i_size_read(inode) - 1) >> PAGE_CACHE_SHIFT;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (last_offset < compressed_end) {
 		page_index = last_offset >> PAGE_CACHE_SHIFT;
 
diff --git a/fs/btrfs/extent_io.c b/fs/btrfs/extent_io.c
index ebe6b29..f3cad4b 100644
--- a/fs/btrfs/extent_io.c
+++ b/fs/btrfs/extent_io.c
@@ -2375,7 +2375,7 @@ static int extent_write_cache_pages(struct extent_io_tree *tree,
 	int scanned = 0;
 	int range_whole = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
@@ -2576,7 +2576,7 @@ int extent_readpages(struct extent_io_tree *tree,
 	struct pagevec pvec;
 	unsigned long bio_flags = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
 		struct page *page = list_entry(pages->prev, struct page, lru);
 
diff --git a/fs/btrfs/ordered-data.c b/fs/btrfs/ordered-data.c
index 77c2411..5d8bed2 100644
--- a/fs/btrfs/ordered-data.c
+++ b/fs/btrfs/ordered-data.c
@@ -695,7 +695,7 @@ int btrfs_wait_on_page_writeback_range(struct address_space *mapping,
 	if (end < start)
 		return 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index 12bb656..7552ae8 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1265,7 +1265,7 @@ static int cifs_writepages(struct address_space *mapping,
 
 	xid = GetXid();
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
@@ -1838,7 +1838,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 	cifs_sb = CIFS_SB(file->f_path.dentry->d_sb);
 	pTcon = cifs_sb->tcon;
 
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	cFYI(DBG2, ("rpages: num pages %d", num_pages));
 	for (i = 0; i < num_pages; ) {
 		unsigned contig_pages;
diff --git a/fs/gfs2/ops_address.c b/fs/gfs2/ops_address.c
index 4ddab67..0821b4b 100644
--- a/fs/gfs2/ops_address.c
+++ b/fs/gfs2/ops_address.c
@@ -355,7 +355,7 @@ static int gfs2_write_cache_jdata(struct address_space *mapping,
 		return 0;
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
index 9b800d9..ee68edc 100644
--- a/fs/hugetlbfs/inode.c
+++ b/fs/hugetlbfs/inode.c
@@ -356,7 +356,7 @@ static void truncate_hugepages(struct inode *inode, loff_t lstart)
 	pgoff_t next;
 	int i, freed = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (1) {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e35c819..d4de5ac 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1514,7 +1514,7 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
 	 * No big deal if we can't add this page to the page cache here.
 	 * READLINK will get the missing page from the server if needed.
 	 */
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
 		pagevec_add(&lru_pvec, page);
diff --git a/fs/ntfs/file.c b/fs/ntfs/file.c
index 3140a44..355c821 100644
--- a/fs/ntfs/file.c
+++ b/fs/ntfs/file.c
@@ -1911,7 +1911,7 @@ static ssize_t ntfs_file_buffered_write(struct kiocb *iocb,
 			}
 		}
 	}
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	written = 0;
 	/*
 	 * If the write starts beyond the initialized size, extend it up to the
diff --git a/fs/ramfs/file-nommu.c b/fs/ramfs/file-nommu.c
index b9b567a..294feb0 100644
--- a/fs/ramfs/file-nommu.c
+++ b/fs/ramfs/file-nommu.c
@@ -103,7 +103,7 @@ int ramfs_nommu_expand_for_mapping(struct inode *inode, size_t newsize)
 	memset(data, 0, newsize);
 
 	/* attach all the pages to the inode's address space */
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	for (loop = 0; loop < npages; loop++) {
 		struct page *page = pages + loop;
 
diff --git a/fs/xfs/linux-2.6/xfs_aops.c b/fs/xfs/linux-2.6/xfs_aops.c
index de3a198..bc8ee83 100644
--- a/fs/xfs/linux-2.6/xfs_aops.c
+++ b/fs/xfs/linux-2.6/xfs_aops.c
@@ -691,7 +691,7 @@ xfs_probe_cluster(
 	/* Prune this back to avoid pathological behavior */
 	tloff = min(tlast, startpage->index + 64);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (!done && tindex <= tloff) {
 		unsigned len = min_t(pgoff_t, PAGEVEC_SIZE, tlast - tindex + 1);
 
@@ -922,7 +922,7 @@ xfs_cluster_write(
 	struct pagevec		pvec;
 	int			done = 0, i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (!done && tindex <= tlast) {
 		unsigned len = min_t(pgoff_t, PAGEVEC_SIZE, tlast - tindex + 1);
 
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 581f8a9..c6d70f3 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -222,8 +222,7 @@ void free_pages_exact(void *virt, size_t size);
 
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
-extern void free_hot_page(struct page *page);
-extern void free_cold_page(struct page *page);
+extern void free_zerocount_page(struct page *page);
 
 #define __free_page(page) __free_pages((page), 0)
 #define free_page(addr) free_pages((addr),0)
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 01ca085..6782dc9 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -90,7 +90,7 @@ static inline void mapping_set_gfp_mask(struct address_space *m, gfp_t mask)
 
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
-void release_pages(struct page **pages, int nr, int cold);
+void release_pages(struct page **pages, int nr);
 
 /*
  * speculatively take a reference to a page.
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 7b2886f..001913a 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -16,7 +16,6 @@ struct address_space;
 
 struct pagevec {
 	unsigned long nr;
-	unsigned long cold;
 	struct page *pages[PAGEVEC_SIZE];
 };
 
@@ -31,10 +30,9 @@ unsigned pagevec_lookup_tag(struct pagevec *pvec,
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
 
-static inline void pagevec_init(struct pagevec *pvec, int cold)
+static inline void pagevec_init(struct pagevec *pvec)
 {
 	pvec->nr = 0;
-	pvec->cold = cold;
 }
 
 static inline void pagevec_reinit(struct pagevec *pvec)
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d302155..762fe08 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -363,7 +363,7 @@ static inline void mem_cgroup_uncharge_swap(swp_entry_t ent)
 #define free_page_and_swap_cache(page) \
 	page_cache_release(page)
 #define free_pages_and_swap_cache(pages, nr) \
-	release_pages((pages), (nr), 0);
+	release_pages((pages), (nr));
 
 static inline void show_swap_cache_info(void)
 {
diff --git a/mm/filemap.c b/mm/filemap.c
index 2523d95..7c0f78c 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -274,7 +274,7 @@ int wait_on_page_writeback_range(struct address_space *mapping,
 	if (end < start)
 		return 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 3c84128..fa7c000 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -951,7 +951,7 @@ int write_cache_pages(struct address_space *mapping,
 		return 0;
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		writeback_index = mapping->writeback_index; /* prev offset */
 		index = writeback_index;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 627837c..b3906db 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1034,7 +1034,7 @@ void mark_free_pages(struct zone *zone)
 /*
  * Free a 0-order page
  */
-static void free_hot_cold_page(struct page *page, int cold)
+static void free_pcp_page(struct page *page)
 {
 	struct zone *zone = page_zone(page);
 	struct per_cpu_pages *pcp;
@@ -1074,11 +1074,7 @@ static void free_hot_cold_page(struct page *page, int cold)
 
 	/* Record the migratetype and place on the lists */
 	set_page_private(page, migratetype);
-	if (cold)
-		list_add_tail(&page->lru, &pcp->lists[migratetype]);
-	else
-		list_add(&page->lru, &pcp->lists[migratetype]);
-
+	list_add(&page->lru, &pcp->lists[migratetype]);
 	pcp->count++;
 	if (pcp->count >= pcp->high) {
 		free_pcppages_bulk(zone, pcp->batch, pcp);
@@ -1089,14 +1085,9 @@ out:
 	put_cpu();
 }
 
-void free_hot_page(struct page *page)
-{
-	free_hot_cold_page(page, 0);
-}
-	
-void free_cold_page(struct page *page)
+void free_zerocount_page(struct page *page)
 {
-	free_hot_cold_page(page, 1);
+	free_pcp_page(page);
 }
 
 /*
@@ -1893,14 +1884,14 @@ void __pagevec_free(struct pagevec *pvec)
 	int i = pagevec_count(pvec);
 
 	while (--i >= 0)
-		free_hot_cold_page(pvec->pages[i], pvec->cold);
+		free_pcp_page(pvec->pages[i]);
 }
 
 void __free_pages(struct page *page, unsigned int order)
 {
 	if (put_page_testzero(page)) {
 		if (order == 0)
-			free_hot_page(page);
+			free_pcp_page(page);
 		else
 			__free_pages_ok(page, order, -1);
 	}
diff --git a/mm/swap.c b/mm/swap.c
index 8adb9fe..0fa30bc 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -55,7 +55,7 @@ static void __page_cache_release(struct page *page)
 		del_page_from_lru(zone, page);
 		spin_unlock_irqrestore(&zone->lru_lock, flags);
 	}
-	free_hot_page(page);
+	free_zerocount_page(page);
 }
 
 static void put_compound_page(struct page *page)
@@ -126,7 +126,7 @@ static void pagevec_move_tail(struct pagevec *pvec)
 	if (zone)
 		spin_unlock(&zone->lru_lock);
 	__count_vm_events(PGROTATED, pgmoved);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
 
@@ -324,14 +324,14 @@ int lru_add_drain_all(void)
  * grabbed the page via the LRU.  If it did, give up: shrink_inactive_list()
  * will free it.
  */
-void release_pages(struct page **pages, int nr, int cold)
+void release_pages(struct page **pages, int nr)
 {
 	int i;
 	struct pagevec pages_to_free;
 	struct zone *zone = NULL;
 	unsigned long uninitialized_var(flags);
 
-	pagevec_init(&pages_to_free, cold);
+	pagevec_init(&pages_to_free);
 	for (i = 0; i < nr; i++) {
 		struct page *page = pages[i];
 
@@ -390,7 +390,7 @@ void release_pages(struct page **pages, int nr, int cold)
 void __pagevec_release(struct pagevec *pvec)
 {
 	lru_add_drain();
-	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
+	release_pages(pvec->pages, pagevec_count(pvec));
 	pagevec_reinit(pvec);
 }
 
@@ -432,7 +432,7 @@ void ____pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 3ecea98..a0ad9ec 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -236,7 +236,7 @@ void free_pages_and_swap_cache(struct page **pages, int nr)
 
 		for (i = 0; i < todo; i++)
 			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, 0);
+		release_pages(pagep, todo);
 		pagep += todo;
 		nr -= todo;
 	}
diff --git a/mm/truncate.c b/mm/truncate.c
index 1229211..4d05520 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -174,7 +174,7 @@ void truncate_inode_pages_range(struct address_space *mapping,
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 	end = (lend >> PAGE_CACHE_SHIFT);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (next <= end &&
 	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
@@ -275,7 +275,7 @@ unsigned long __invalidate_mapping_pages(struct address_space *mapping,
 	unsigned long ret = 0;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
@@ -397,7 +397,7 @@ int invalidate_inode_pages2_range(struct address_space *mapping,
 	int did_range_unmap = 0;
 	int wrapped = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (next <= end && !wrapped &&
 		pagevec_lookup(&pvec, mapping, next,
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 9a27c44..9cadc27 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -584,7 +584,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 
 	cond_resched();
 
-	pagevec_init(&freed_pvec, 1);
+	pagevec_init(&freed_pvec);
 	while (!list_empty(page_list)) {
 		struct address_space *mapping;
 		struct page *page;
@@ -1050,7 +1050,7 @@ static unsigned long shrink_inactive_list(unsigned long max_scan,
 	unsigned long nr_reclaimed = 0;
 	struct zone_reclaim_stat *reclaim_stat = get_reclaim_stat(zone, sc);
 
-	pagevec_init(&pvec, 1);
+	pagevec_init(&pvec);
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1261,7 +1261,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	/*
 	 * Move the pages to the [file or anon] inactive list.
 	 */
-	pagevec_init(&pvec, 1);
+	pagevec_init(&pvec);
 	pgmoved = 0;
 	lru = LRU_BASE + file * LRU_FILE;
 
@@ -2488,7 +2488,7 @@ void scan_mapping_unevictable_pages(struct address_space *mapping)
 	if (mapping->nrpages == 0)
 		return;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (next < end &&
 		pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		int i;
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
