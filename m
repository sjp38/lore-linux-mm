Message-Id: <20080212003804.127584761@sgi.com>
References: <20080212003643.536643832@sgi.com>
Date: Mon, 11 Feb 2008 16:36:46 -0800
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 3/3] Remove cold field from pagevec
Content-Disposition: inline; filename=hotcold_3
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

We have removed the distinction between hot/cold in the page
allocator and also the use of GFP_COLD. Then we also do not need the
cold field in the pagevecs anymore.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/afs/write.c                |    4 ++--
 fs/cifs/file.c                |    4 ++--
 fs/gfs2/ops_address.c         |    2 +-
 fs/hugetlbfs/inode.c          |    2 +-
 fs/nfs/dir.c                  |    2 +-
 fs/ntfs/file.c                |    2 +-
 fs/ramfs/file-nommu.c         |    2 +-
 fs/reiser4/plugin/file/file.c |    2 +-
 fs/xfs/linux-2.6/xfs_aops.c   |    4 ++--
 include/linux/pagemap.h       |    2 +-
 include/linux/pagevec.h       |    4 +---
 mm/filemap.c                  |    2 +-
 mm/page-writeback.c           |    2 +-
 mm/swap.c                     |   14 +++++++-------
 mm/swap_state.c               |    2 +-
 mm/truncate.c                 |    6 +++---
 mm/vmscan.c                   |    6 +++---
 17 files changed, 30 insertions(+), 32 deletions(-)

Index: linux-2.6/include/linux/pagemap.h
===================================================================
--- linux-2.6.orig/include/linux/pagemap.h	2008-02-11 16:18:47.000000000 -0800
+++ linux-2.6/include/linux/pagemap.h	2008-02-11 16:19:00.000000000 -0800
@@ -60,7 +60,7 @@ static inline void mapping_set_gfp_mask(
 
 #define page_cache_get(page)		get_page(page)
 #define page_cache_release(page)	put_page(page)
-void release_pages(struct page **pages, int nr, int cold);
+void release_pages(struct page **pages, int nr);
 
 #ifdef CONFIG_NUMA
 extern struct page *__page_cache_alloc(gfp_t gfp);
Index: linux-2.6/include/linux/pagevec.h
===================================================================
--- linux-2.6.orig/include/linux/pagevec.h	2007-12-20 14:58:40.000000000 -0800
+++ linux-2.6/include/linux/pagevec.h	2008-02-11 16:19:00.000000000 -0800
@@ -16,7 +16,6 @@ struct address_space;
 
 struct pagevec {
 	unsigned long nr;
-	unsigned long cold;
 	struct page *pages[PAGEVEC_SIZE];
 };
 
@@ -32,10 +31,9 @@ unsigned pagevec_lookup_tag(struct pagev
 		struct address_space *mapping, pgoff_t *index, int tag,
 		unsigned nr_pages);
 
-static inline void pagevec_init(struct pagevec *pvec, int cold)
+static inline void pagevec_init(struct pagevec *pvec)
 {
 	pvec->nr = 0;
-	pvec->cold = cold;
 }
 
 static inline void pagevec_reinit(struct pagevec *pvec)
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2008-02-11 16:18:47.000000000 -0800
+++ linux-2.6/mm/filemap.c	2008-02-11 16:19:00.000000000 -0800
@@ -276,7 +276,7 @@ int wait_on_page_writeback_range(struct 
 	if (end < start)
 		return 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	index = start;
 	while ((index <= end) &&
 			(nr_pages = pagevec_lookup_tag(&pvec, mapping, &index,
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/mm/page-writeback.c	2008-02-11 16:19:00.000000000 -0800
@@ -813,7 +813,7 @@ int write_cache_pages(struct address_spa
 		return 0;
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
Index: linux-2.6/mm/swap.c
===================================================================
--- linux-2.6.orig/mm/swap.c	2008-02-11 16:18:36.000000000 -0800
+++ linux-2.6/mm/swap.c	2008-02-11 16:19:00.000000000 -0800
@@ -125,7 +125,7 @@ static void pagevec_move_tail(struct pag
 	if (zone)
 		spin_unlock(&zone->lru_lock);
 	__count_vm_events(PGROTATED, pgmoved);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
 
@@ -296,14 +296,14 @@ int lru_add_drain_all(void)
  * page count inside the lock to see whether shrink_cache grabbed the page
  * via the LRU.  If it did, give up: shrink_cache will free it.
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
 
@@ -361,7 +361,7 @@ void release_pages(struct page **pages, 
 void __pagevec_release(struct pagevec *pvec)
 {
 	lru_add_drain();
-	release_pages(pvec->pages, pagevec_count(pvec), pvec->cold);
+	release_pages(pvec->pages, pagevec_count(pvec));
 	pagevec_reinit(pvec);
 }
 
@@ -377,7 +377,7 @@ void __pagevec_release_nonlru(struct pag
 	int i;
 	struct pagevec pages_to_free;
 
-	pagevec_init(&pages_to_free, pvec->cold);
+	pagevec_init(&pages_to_free);
 	for (i = 0; i < pagevec_count(pvec); i++) {
 		struct page *page = pvec->pages[i];
 
@@ -414,7 +414,7 @@ void __pagevec_lru_add(struct pagevec *p
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
 
@@ -443,7 +443,7 @@ void __pagevec_lru_add_active(struct pag
 	}
 	if (zone)
 		spin_unlock_irq(&zone->lru_lock);
-	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	release_pages(pvec->pages, pvec->nr);
 	pagevec_reinit(pvec);
 }
 
Index: linux-2.6/mm/truncate.c
===================================================================
--- linux-2.6.orig/mm/truncate.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/mm/truncate.c	2008-02-11 16:19:00.000000000 -0800
@@ -173,7 +173,7 @@ void truncate_inode_pages_range(struct a
 	BUG_ON((lend & (PAGE_CACHE_SIZE - 1)) != (PAGE_CACHE_SIZE - 1));
 	end = (lend >> PAGE_CACHE_SHIFT);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (next <= end &&
 	       pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
@@ -274,7 +274,7 @@ unsigned long __invalidate_mapping_pages
 	unsigned long ret = 0;
 	int i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (next <= end &&
 			pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 		for (i = 0; i < pagevec_count(&pvec); i++) {
@@ -395,7 +395,7 @@ int invalidate_inode_pages2_range(struct
 	int did_range_unmap = 0;
 	int wrapped = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (next <= end && !wrapped &&
 		pagevec_lookup(&pvec, mapping, next,
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/mm/vmscan.c	2008-02-11 16:19:00.000000000 -0800
@@ -472,7 +472,7 @@ static unsigned long shrink_page_list(st
 
 	cond_resched();
 
-	pagevec_init(&freed_pvec, 1);
+	pagevec_init(&freed_pvec);
 	while (!list_empty(page_list)) {
 		struct address_space *mapping;
 		struct page *page;
@@ -834,7 +834,7 @@ static unsigned long shrink_inactive_lis
 	unsigned long nr_scanned = 0;
 	unsigned long nr_reclaimed = 0;
 
-	pagevec_init(&pvec, 1);
+	pagevec_init(&pvec);
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
@@ -1116,7 +1116,7 @@ static void shrink_active_list(unsigned 
 		list_add(&page->lru, &l_inactive);
 	}
 
-	pagevec_init(&pvec, 1);
+	pagevec_init(&pvec);
 	pgmoved = 0;
 	spin_lock_irq(&zone->lru_lock);
 	while (!list_empty(&l_inactive)) {
Index: linux-2.6/fs/afs/write.c
===================================================================
--- linux-2.6.orig/fs/afs/write.c	2007-11-09 19:30:29.000000000 -0800
+++ linux-2.6/fs/afs/write.c	2008-02-11 16:19:00.000000000 -0800
@@ -330,7 +330,7 @@ static void afs_kill_pages(struct afs_vn
 	_enter("{%x:%u},%lx-%lx",
 	       vnode->fid.vid, vnode->fid.vnode, first, last);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("kill %lx-%lx", first, last);
@@ -666,7 +666,7 @@ void afs_pages_written_back(struct afs_v
 
 	ASSERT(wb != NULL);
 
-	pagevec_init(&pv, 0);
+	pagevec_init(&pv);
 
 	do {
 		_debug("done %lx-%lx", first, last);
Index: linux-2.6/fs/cifs/file.c
===================================================================
--- linux-2.6.orig/fs/cifs/file.c	2008-01-29 18:17:21.000000000 -0800
+++ linux-2.6/fs/cifs/file.c	2008-02-11 16:19:00.000000000 -0800
@@ -1248,7 +1248,7 @@ static int cifs_writepages(struct addres
 
 	xid = GetXid();
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
@@ -1813,7 +1813,7 @@ static int cifs_readpages(struct file *f
 	cifs_sb = CIFS_SB(file->f_path.dentry->d_sb);
 	pTcon = cifs_sb->tcon;
 
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 #ifdef CONFIG_CIFS_DEBUG2
 		cFYI(1, ("rpages: num pages %d", num_pages));
 #endif
Index: linux-2.6/fs/hugetlbfs/inode.c
===================================================================
--- linux-2.6.orig/fs/hugetlbfs/inode.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/fs/hugetlbfs/inode.c	2008-02-11 16:19:00.000000000 -0800
@@ -345,7 +345,7 @@ static void truncate_hugepages(struct in
 	pgoff_t next;
 	int i, freed = 0;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	next = start;
 	while (1) {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
Index: linux-2.6/fs/nfs/dir.c
===================================================================
--- linux-2.6.orig/fs/nfs/dir.c	2008-01-30 12:05:02.000000000 -0800
+++ linux-2.6/fs/nfs/dir.c	2008-02-11 16:19:00.000000000 -0800
@@ -1519,7 +1519,7 @@ static int nfs_symlink(struct inode *dir
 	 * No big deal if we can't add this page to the page cache here.
 	 * READLINK will get the missing page from the server if needed.
 	 */
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
 		pagevec_add(&lru_pvec, page);
Index: linux-2.6/fs/ntfs/file.c
===================================================================
--- linux-2.6.orig/fs/ntfs/file.c	2008-02-07 19:07:04.000000000 -0800
+++ linux-2.6/fs/ntfs/file.c	2008-02-11 16:19:00.000000000 -0800
@@ -1911,7 +1911,7 @@ static ssize_t ntfs_file_buffered_write(
 			}
 		}
 	}
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	written = 0;
 	/*
 	 * If the write starts beyond the initialized size, extend it up to the
Index: linux-2.6/fs/ramfs/file-nommu.c
===================================================================
--- linux-2.6.orig/fs/ramfs/file-nommu.c	2007-11-09 19:30:29.000000000 -0800
+++ linux-2.6/fs/ramfs/file-nommu.c	2008-02-11 16:19:00.000000000 -0800
@@ -102,7 +102,7 @@ static int ramfs_nommu_expand_for_mappin
 	memset(data, 0, newsize);
 
 	/* attach all the pages to the inode's address space */
-	pagevec_init(&lru_pvec, 0);
+	pagevec_init(&lru_pvec);
 	for (loop = 0; loop < npages; loop++) {
 		struct page *page = pages + loop;
 
Index: linux-2.6/fs/reiser4/plugin/file/file.c
===================================================================
--- linux-2.6.orig/fs/reiser4/plugin/file/file.c	2007-08-27 22:03:53.000000000 -0700
+++ linux-2.6/fs/reiser4/plugin/file/file.c	2008-02-11 16:19:00.000000000 -0800
@@ -989,7 +989,7 @@ capture_anonymous_pages(struct address_s
 	unsigned int i, count;
 	int nr;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	count = min(pagevec_space(&pvec), to_capture);
 	nr = 0;
 
Index: linux-2.6/fs/xfs/linux-2.6/xfs_aops.c
===================================================================
--- linux-2.6.orig/fs/xfs/linux-2.6/xfs_aops.c	2008-02-08 13:22:14.000000000 -0800
+++ linux-2.6/fs/xfs/linux-2.6/xfs_aops.c	2008-02-11 16:19:00.000000000 -0800
@@ -651,7 +651,7 @@ xfs_probe_cluster(
 	/* Prune this back to avoid pathological behavior */
 	tloff = min(tlast, startpage->index + 64);
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (!done && tindex <= tloff) {
 		unsigned len = min_t(pgoff_t, PAGEVEC_SIZE, tlast - tindex + 1);
 
@@ -882,7 +882,7 @@ xfs_cluster_write(
 	struct pagevec		pvec;
 	int			done = 0, i;
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	while (!done && tindex <= tlast) {
 		unsigned len = min_t(pgoff_t, PAGEVEC_SIZE, tlast - tindex + 1);
 
Index: linux-2.6/mm/swap_state.c
===================================================================
--- linux-2.6.orig/mm/swap_state.c	2008-02-07 19:07:05.000000000 -0800
+++ linux-2.6/mm/swap_state.c	2008-02-11 16:19:00.000000000 -0800
@@ -223,7 +223,7 @@ void free_pages_and_swap_cache(struct pa
 
 		for (i = 0; i < todo; i++)
 			free_swap_cache(pagep[i]);
-		release_pages(pagep, todo, 0);
+		release_pages(pagep, todo);
 		pagep += todo;
 		nr -= todo;
 	}
Index: linux-2.6/fs/gfs2/ops_address.c
===================================================================
--- linux-2.6.orig/fs/gfs2/ops_address.c	2008-02-11 16:23:10.000000000 -0800
+++ linux-2.6/fs/gfs2/ops_address.c	2008-02-11 16:23:17.000000000 -0800
@@ -360,7 +360,7 @@ static int gfs2_write_cache_jdata(struct
 		return 0;
 	}
 
-	pagevec_init(&pvec, 0);
+	pagevec_init(&pvec);
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
