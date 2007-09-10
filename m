Date: Mon, 10 Sep 2007 19:27:13 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [29/35] changes in
 REISER4/REISERFS
Message-Id: <20070910192713.4acfe08f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in reiser4
(sorry, changes for /reiserfs is also included.)

Todo: 
Fix this warning caused by this patch(set). does anyone have an adivce ?
fs/reiser4/page_cache.c: In function ‘reiser4_tree_by_page’:
fs/reiser4/page_cache.c:315: warning: passing argument 1 of ‘page_inode’ discards qualifiers from pointer target type

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/reiser4/as_ops.c                      |   34 ++++++++++++++++---------------
 fs/reiser4/entd.c                        |    6 ++---
 fs/reiser4/jnode.c                       |   18 +++++++++-------
 fs/reiser4/page_cache.c                  |   10 ++++-----
 fs/reiser4/plugin/cluster.h              |   14 ++++++------
 fs/reiser4/plugin/file/cryptcompress.c   |   15 +++++++------
 fs/reiser4/plugin/file/file.c            |   22 ++++++++++----------
 fs/reiser4/plugin/file_ops.c             |    8 +++----
 fs/reiser4/plugin/item/ctail.c           |   16 +++++++-------
 fs/reiser4/plugin/item/extent_file_ops.c |    6 ++---
 fs/reiser4/plugin/item/tail.c            |    6 ++---
 fs/reiser4/wander.c                      |    2 -
 fs/reiserfs/inode.c                      |   16 +++++++-------
 fs/reiserfs/journal.c                    |    3 +-
 fs/reiserfs/tail_conversion.c            |    2 -
 15 files changed, 92 insertions(+), 86 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/reiser4/as_ops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/as_ops.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/as_ops.c
@@ -64,24 +64,25 @@
 int reiser4_set_page_dirty(struct page *page)
 {
 	/* this page can be unformatted only */
-	assert("vs-1734", (page->mapping &&
-			   page->mapping->host &&
-			   reiser4_get_super_fake(page->mapping->host->i_sb) !=
-			   page->mapping->host
-			   && reiser4_get_cc_fake(page->mapping->host->i_sb) !=
-			   page->mapping->host
-			   && reiser4_get_bitmap_fake(page->mapping->host->i_sb) !=
-			   page->mapping->host));
+	assert("vs-1734", (page_mapping_cache(page) &&
+			   page_inode(page) &&
+			   reiser4_get_super_fake(page_inode(page)->i_sb) !=
+			   page_inode(page)
+			   && reiser4_get_cc_fake(page_inode(page)->i_sb) !=
+			   page_inode(page)
+			   && reiser4_get_bitmap_fake(page_inode(page)->i_sb) !=
+			   page_inode(page)));
 
 	if (!TestSetPageDirty(page)) {
-		struct address_space *mapping = page->mapping;
+		struct address_space *mapping = page_mapping_cache(page);
 
 		if (mapping) {
 			write_lock_irq(&mapping->tree_lock);
 
 			/* check for race with truncate */
-			if (page->mapping) {
-				assert("vs-1652", page->mapping == mapping);
+			if (page_is_pagecache(page)) {
+				assert("vs-1652",
+					page_mapping_cache(page) == mapping);
 				if (mapping_cap_account_dirty(mapping))
 					inc_zone_page_state(page,
 							NR_FILE_DIRTY);
@@ -140,7 +141,7 @@ void reiser4_invalidatepage(struct page 
 
 	assert("nikita-3137", PageLocked(page));
 	assert("nikita-3138", !PageWriteback(page));
-	inode = page->mapping->host;
+	inode = page_inode(page);
 
 	/*
 	 * ->invalidatepage() should only be called for the unformatted
@@ -157,7 +158,8 @@ void reiser4_invalidatepage(struct page 
 		return;
 	assert("vs-1426", PagePrivate(page));
 	assert("vs-1427",
-	       page->mapping == jnode_get_mapping(jnode_by_page(page)));
+	       pagecache_consistent(page,
+			jnode_get_mapping(jnode_by_page(page))));
 	assert("", jprivate(page) != NULL);
 	assert("", ergo(inode_file_plugin(inode) !=
 			file_plugin_by_id(CRYPTCOMPRESS_FILE_PLUGIN_ID),
@@ -287,8 +289,8 @@ int reiser4_releasepage(struct page *pag
 
 	node = jnode_by_page(page);
 	assert("nikita-2258", node != NULL);
-	assert("reiser4-4", page->mapping != NULL);
-	assert("reiser4-5", page->mapping->host != NULL);
+	assert("reiser4-4", page_mapping_cache(page) != NULL);
+	assert("reiser4-5", page_inode(page) != NULL);
 
 	if (PageDirty(page))
 		return 0;
@@ -305,7 +307,7 @@ int reiser4_releasepage(struct page *pag
 	if (jnode_is_releasable(node)) {
 		struct address_space *mapping;
 
-		mapping = page->mapping;
+		mapping = page_mapping_cache(page);
 		jref(node);
 		/* there is no need to synchronize against
 		 * jnode_extent_write() here, because pages seen by
Index: test-2.6.23-rc4-mm1/fs/reiser4/entd.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/entd.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/entd.c
@@ -266,9 +266,9 @@ int write_page_by_ent(struct page *page,
 	struct wbq rq;
 
 	assert("", PageLocked(page));
-	assert("", page->mapping != NULL);
+	assert("", page_mapping_cache(page) != NULL);
 
-	sb = page->mapping->host->i_sb;
+	sb = page_inode(page)->i_sb;
 	ent = get_entd_context(sb);
 	assert("", ent && ent->done == 0);
 
@@ -283,7 +283,7 @@ int write_page_by_ent(struct page *page,
 	 * pin inode in memory, unlock page, entd_flush will iput. We can not
 	 * iput here becasue we can not allow delete_inode to be called here
 	 */
-	inode = igrab(page->mapping->host);
+	inode = igrab(page_inode(page));
 	unlock_page(page);
 	if (inode == NULL)
 		/* inode is getting freed */
Index: test-2.6.23-rc4-mm1/fs/reiser4/jnode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/jnode.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/jnode.c
@@ -594,7 +594,7 @@ static jnode *do_jget(reiser4_tree * tre
 	 */
 
 	jnode *result;
-	oid_t oid = get_inode_oid(pg->mapping->host);
+	oid_t oid = get_inode_oid(page_inode(pg));
 
 	assert("umka-176", pg != NULL);
 	assert("nikita-2394", PageLocked(pg));
@@ -606,18 +606,18 @@ static jnode *do_jget(reiser4_tree * tre
 	tree = reiser4_tree_by_page(pg);
 
 	/* check hash-table first */
-	result = jfind(pg->mapping, pg->index);
+	result = jfind(page_mapping_cache(pg), pg->index);
 	if (unlikely(result != NULL)) {
 		spin_lock_jnode(result);
 		jnode_attach_page(result, pg);
 		spin_unlock_jnode(result);
-		result->key.j.mapping = pg->mapping;
+		result->key.j.mapping = page_mapping_cache(pg);
 		return result;
 	}
 
 	/* since page is locked, jnode should be allocated with GFP_NOFS flag */
 	reiser4_ctx_gfp_mask_force(GFP_NOFS);
-	result = find_get_jnode(tree, pg->mapping, oid, pg->index);
+	result = find_get_jnode(tree, page_mapping_cache(pg), oid, pg->index);
 	if (unlikely(IS_ERR(result)))
 		return result;
 	/* attach jnode to page */
@@ -646,13 +646,14 @@ jnode *jnode_of_page(struct page * pg)
 			assert("nikita-2364",
 			       jprivate(pg)->key.j.index == pg->index);
 			assert("nikita-2367",
-			       jprivate(pg)->key.j.mapping == pg->mapping);
+			       jprivate(pg)->key.j.mapping ==
+				page_mapping_cache(pg));
 			assert("nikita-2365",
 			       jprivate(pg)->key.j.objectid ==
-			       get_inode_oid(pg->mapping->host));
+			       get_inode_oid(page_inode(pg)));
 			assert("vs-1200",
 			       jprivate(pg)->key.j.objectid ==
-			       pg->mapping->host->i_ino);
+			       page_inode(pg)->i_ino);
 			assert("nikita-2356",
 			       jnode_is_unformatted(jnode_by_page(pg)));
 		}
@@ -812,7 +813,8 @@ static struct page *jnode_get_page_locke
 		page_cache_get(page);
 		spin_unlock_jnode(node);
 		lock_page(page);
-		assert("nikita-3134", page->mapping == jnode_get_mapping(node));
+		assert("nikita-3134",
+			page_mapping_cache(page) == jnode_get_mapping(node));
 	}
 
 	spin_lock_jnode(node);
Index: test-2.6.23-rc4-mm1/fs/reiser4/page_cache.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/page_cache.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/page_cache.c
@@ -312,7 +312,7 @@ void reiser4_wait_page_writeback(struct 
 reiser4_tree *reiser4_tree_by_page(const struct page *page /* page to query */ )
 {
 	assert("nikita-2461", page != NULL);
-	return &get_super_private(page->mapping->host->i_sb)->tree;
+	return &get_super_private(page_inode(page)->i_sb)->tree;
 }
 
 /* completion handler for single page bio-based read.
@@ -400,7 +400,7 @@ int reiser4_page_io(struct page *page, j
 	assert("nikita-2893", rw == READ || rw == WRITE);
 
 	if (rw) {
-		if (unlikely(page->mapping->host->i_sb->s_flags & MS_RDONLY)) {
+		if (unlikely(page_inode(page)->i_sb->s_flags & MS_RDONLY)) {
 			unlock_page(page);
 			return 0;
 		}
@@ -441,7 +441,7 @@ static struct bio *page_bio(struct page 
 		struct super_block *super;
 		reiser4_block_nr blocknr;
 
-		super = page->mapping->host->i_sb;
+		super = page_inode(page)->i_sb;
 		assert("nikita-2029", super != NULL);
 		blksz = super->s_blocksize;
 		assert("nikita-2028", blksz == (int)PAGE_CACHE_SIZE);
@@ -479,7 +479,7 @@ int reiser4_set_page_dirty_internal(stru
 {
 	struct address_space *mapping;
 
-	mapping = page->mapping;
+	mapping = page_mapping_cache(page);
 	BUG_ON(mapping == NULL);
 
 	if (!TestSetPageDirty(page)) {
@@ -528,7 +528,7 @@ int reiser4_writepage(struct page *page,
 
 	assert("vs-828", PageLocked(page));
 
-	s = page->mapping->host->i_sb;
+	s = page_inode(page)->i_sb;
 	ctx = get_current_context_check();
 
 	//assert("", can_hit_entd(ctx, s));
Index: test-2.6.23-rc4-mm1/fs/reiser4/wander.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/wander.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/wander.c
@@ -765,7 +765,7 @@ static int write_jnodes_to_disk_extent(
 
 			spin_lock_jnode(cur);
 			assert("nikita-3166",
-			       pg->mapping == jnode_get_mapping(cur));
+			      page_mapping_cache(pg) == jnode_get_mapping(cur));
 			assert("zam-912", !JF_ISSET(cur, JNODE_WRITEBACK));
 #if REISER4_DEBUG
 			spin_lock(&cur->load);
Index: test-2.6.23-rc4-mm1/fs/reiserfs/inode.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiserfs/inode.c
+++ test-2.6.23-rc4-mm1/fs/reiserfs/inode.c
@@ -2331,7 +2331,7 @@ static int map_block_for_writepage(struc
 static int reiserfs_write_full_page(struct page *page,
 				    struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	unsigned long end_index = inode->i_size >> PAGE_CACHE_SHIFT;
 	int error = 0;
 	unsigned long block;
@@ -2546,7 +2546,7 @@ static int reiserfs_readpage(struct file
 
 static int reiserfs_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	reiserfs_wait_on_write_block(inode->i_sb);
 	return reiserfs_write_full_page(page, wbc);
 }
@@ -2624,7 +2624,7 @@ static int reiserfs_write_begin(struct f
 int reiserfs_prepare_write(struct file *f, struct page *page,
 			   unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int ret;
 	int old_ref = 0;
 
@@ -2679,7 +2679,7 @@ static int reiserfs_write_end(struct fil
 			      loff_t pos, unsigned len, unsigned copied,
 			      struct page *page, void *fsdata)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	int ret = 0;
 	int update_sd = 0;
 	struct reiserfs_transaction_handle *th;
@@ -2772,7 +2772,7 @@ static int reiserfs_write_end(struct fil
 int reiserfs_commit_write(struct file *f, struct page *page,
 			  unsigned from, unsigned to)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	loff_t pos = ((loff_t) page->index << PAGE_CACHE_SHIFT) + to;
 	int ret = 0;
 	int update_sd = 0;
@@ -2951,7 +2951,7 @@ static int invalidatepage_can_drop(struc
 static void reiserfs_invalidatepage(struct page *page, unsigned long offset)
 {
 	struct buffer_head *head, *bh, *next;
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	unsigned int curr_off = 0;
 	int ret = 1;
 
@@ -2997,7 +2997,7 @@ static void reiserfs_invalidatepage(stru
 
 static int reiserfs_set_page_dirty(struct page *page)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	if (reiserfs_file_data_log(inode)) {
 		SetPageChecked(page);
 		return __set_page_dirty_nobuffers(page);
@@ -3016,7 +3016,7 @@ static int reiserfs_set_page_dirty(struc
  */
 static int reiserfs_releasepage(struct page *page, gfp_t unused_gfp_flags)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct reiserfs_journal *j = SB_JOURNAL(inode->i_sb);
 	struct buffer_head *head;
 	struct buffer_head *bh;
Index: test-2.6.23-rc4-mm1/fs/reiserfs/journal.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiserfs/journal.c
+++ test-2.6.23-rc4-mm1/fs/reiserfs/journal.c
@@ -889,7 +889,8 @@ static int write_ordered_buffers(spinloc
 		 * the buffer. We're safe if we write the page one last time
 		 * after freeing the journal header.
 		 */
-		if (buffer_dirty(bh) && unlikely(bh->b_page->mapping == NULL)) {
+		if (buffer_dirty(bh) &&
+		    unlikely(!page_mapping_cache(bh->b_page))) {
 			spin_unlock(lock);
 			ll_rw_block(WRITE, 1, &bh);
 			spin_lock(lock);
Index: test-2.6.23-rc4-mm1/fs/reiserfs/tail_conversion.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiserfs/tail_conversion.c
+++ test-2.6.23-rc4-mm1/fs/reiserfs/tail_conversion.c
@@ -151,7 +151,7 @@ void reiserfs_unmap_buffer(struct buffer
 	   interested in removing it from per-sb j_dirty_buffers list, to avoid
 	   BUG() on attempt to write not mapped buffer */
 	if ((!list_empty(&bh->b_assoc_buffers) || bh->b_private) && bh->b_page) {
-		struct inode *inode = bh->b_page->mapping->host;
+		struct inode *inode = page_inode(bh->b_page);
 		struct reiserfs_journal *j = SB_JOURNAL(inode->i_sb);
 		spin_lock(&j->j_dirty_buffers_lock);
 		list_del_init(&bh->b_assoc_buffers);
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/cluster.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/cluster.h
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/cluster.h
@@ -92,9 +92,9 @@ static inline unsigned off_to_cloff(loff
 static inline  pgoff_t offset_in_clust(struct page * page)
 {
 	assert("edward-1488", page != NULL);
-	assert("edward-1489", page->mapping != NULL);
+	assert("edward-1489", page_mapping_cache(page) != NULL);
 
-	return page_index(page) & ((cluster_nrpages(page->mapping->host)) - 1);
+	return page_index(page) & ((cluster_nrpages(page_inode(page))) - 1);
 }
 
 static inline int first_page_in_cluster(struct page * page)
@@ -105,7 +105,7 @@ static inline int first_page_in_cluster(
 static inline int last_page_in_cluster(struct page * page)
 {
 	return offset_in_clust(page) ==
-		cluster_nrpages(page->mapping->host) - 1;
+		cluster_nrpages(page_inode(page)) - 1;
 }
 
 static inline unsigned
@@ -200,11 +200,11 @@ static inline int same_page_cluster(stru
 {
 	assert("edward-1490", p1 != NULL);
 	assert("edward-1491", p2 != NULL);
-	assert("edward-1492", p1->mapping != NULL);
-	assert("edward-1493", p2->mapping != NULL);
+	assert("edward-1492", page_is_pagecache(p1));
+	assert("edward-1493", page_is_pagecache(p2));
 
-	return (pg_to_clust(page_index(p1), p1->mapping->host) ==
-		pg_to_clust(page_index(p2), p2->mapping->host));
+	return (pg_to_clust(page_index(p1), page_inode(p1)) ==
+		pg_to_clust(page_index(p2), page_inode(p2)));
 }
 
 static inline int cluster_is_complete(struct cluster_handle * clust,
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/cryptcompress.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/file/cryptcompress.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/cryptcompress.c
@@ -1233,16 +1233,16 @@ int readpage_cryptcompress(struct file *
 
 	assert("edward-88", PageLocked(page));
 	assert("vs-976", !PageUptodate(page));
-	assert("edward-89", page->mapping && page->mapping->host);
+	assert("edward-89", page_mapping_cache(page) && page_inode(page));
 
-	ctx = reiser4_init_context(page->mapping->host->i_sb);
+	ctx = reiser4_init_context(page_inode(page)->i_sb);
 	if (IS_ERR(ctx)) {
 		unlock_page(page);
 		return PTR_ERR(ctx);
 	}
 	assert("edward-113",
 	       ergo(file != NULL,
-		    page->mapping == file->f_dentry->d_inode->i_mapping));
+		    pagecache_consistent(page, file->f_dentry->d_inode->i_mapping)));
 
 	if (PageUptodate(page)) {
 		warning("edward-1338", "page is already uptodate\n");
@@ -1873,7 +1873,8 @@ static void checkout_page_cluster(struct
 			assert("edward-1480",
 			       i_size_read(inode) <= page_offset(clust->pages[i]));
 			assert("edward-1481",
-			       clust->pages[i]->mapping != inode->i_mapping);
+			       !pagecache_consistent(clust->pages[i],
+						 	inode->i_mapping));
 			unlock_page(clust->pages[i]);
 			break;
 		}
@@ -2651,13 +2652,13 @@ int set_cluster_by_page(struct cluster_h
 
 	assert("edward-1358", clust != NULL);
 	assert("edward-1359", page != NULL);
-	assert("edward-1360", page->mapping != NULL);
-	assert("edward-1361", page->mapping->host != NULL);
+	assert("edward-1360", page_mapping_cache(page) != NULL);
+	assert("edward-1361", page_inode(page) != NULL);
 
 	setting_actor =
 		(clust->pages ? reset_cluster_pgset : alloc_cluster_pgset);
 	result = setting_actor(clust, count);
-	clust->index = pg_to_clust(page->index, page->mapping->host);
+	clust->index = pg_to_clust(page->index, page_inode(page));
 	return result;
 }
 
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/file.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/file/file.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/file/file.c
@@ -790,8 +790,8 @@ int find_or_create_extent(struct page *p
 
 	jnode *node;
 
-	assert("vs-1065", page->mapping && page->mapping->host);
-	inode = page->mapping->host;
+	assert("vs-1065", page_mapping_cache(page) && page_inode(page));
+	inode = page_inode(page);
 
 	lock_page(page);
 	node = jnode_of_page(page);
@@ -866,8 +866,8 @@ static int capture_page_and_create_exten
 	int result;
 	struct inode *inode;
 
-	assert("vs-1084", page->mapping && page->mapping->host);
-	inode = page->mapping->host;
+	assert("vs-1084", page_mapping_cache(page) && page_inode(page));
+	inode = page_inode(page);
 	assert("vs-1139",
 	       unix_file_inode_data(inode)->container == UF_CONTAINER_EXTENTS);
 	/* page belongs to file */
@@ -905,8 +905,8 @@ commit_write_unix_file(struct file *file
 
 	SetPageUptodate(page);
 
-	inode = page->mapping->host;
-	ctx = reiser4_init_context(page->mapping->host->i_sb);
+	inode = page_inode(page);
+	ctx = reiser4_init_context(page_inode(page)->i_sb);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	page_cache_get(page);
@@ -1433,9 +1433,9 @@ int readpage_unix_file(struct file *file
 
 	assert("vs-1062", PageLocked(page));
 	assert("vs-976", !PageUptodate(page));
-	assert("vs-1061", page->mapping && page->mapping->host);
+	assert("vs-1061", page_mapping_cache(page) && page_inode(page));
 
-	if (page->mapping->host->i_size <= page_offset(page)) {
+	if (page_inode(page)->i_size <= page_offset(page)) {
 		/* page is out of file */
 		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
 		SetPageUptodate(page);
@@ -1443,7 +1443,7 @@ int readpage_unix_file(struct file *file
 		return 0;
 	}
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	ctx = reiser4_init_context(inode->i_sb);
 	if (IS_ERR(ctx)) {
 		unlock_page(page);
@@ -1476,7 +1476,7 @@ int readpage_unix_file(struct file *file
 	lock_page(page);
 	page_cache_release(page);
 
-	if (page->mapping == NULL) {
+	if (!page_is_pagecache(page)) {
 		/*
 		 * readpage allows truncate to run concurrently. Page was
 		 * truncated while it was not locked
@@ -1604,7 +1604,7 @@ static int uf_readpages_filler(void * da
 	reiser4_extent *ext;
 	__u64 ext_index;
 	int cbk_done = 0;
-	struct address_space * mapping = page->mapping;
+	struct address_space * mapping = page_mapping_cache(page);
 
 	if (PageUptodate(page)) {
 		unlock_page(page);
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/file_ops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/file_ops.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/file_ops.c
@@ -93,7 +93,7 @@ prepare_write_common(struct file *file, 
 	reiser4_context *ctx;
 	int result;
 
-	ctx = reiser4_init_context(page->mapping->host->i_sb);
+	ctx = reiser4_init_context(page_inode(page)->i_sb);
 	result = do_prepare_write(file, page, from, to);
 
 	/* don't commit transaction under inode semaphore */
@@ -120,13 +120,13 @@ do_prepare_write(struct file *file, stru
 	if (to - from == PAGE_CACHE_SIZE || PageUptodate(page))
 		return 0;
 
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	fplug = inode_file_plugin(inode);
 
-	if (page->mapping->a_ops->readpage == NULL)
+	if (page_mapping_cache(page)->a_ops->readpage == NULL)
 		return RETERR(-EINVAL);
 
-	result = page->mapping->a_ops->readpage(file, page);
+	result = page_mapping_cache(page)->a_ops->readpage(file, page);
 	if (result != 0) {
 		SetPageError(page);
 		ClearPageUptodate(page);
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/ctail.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/item/ctail.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/ctail.c
@@ -580,7 +580,7 @@ static int ctail_read_disk_cluster(struc
 	 */
 	assert("edward-1528", znode_is_any_locked(clust->hint->lh.node));
 
-	if (page->mapping != inode->i_mapping) {
+	if (pagecache_consistent(page, inode->i_mapping)) {
 		/* page was truncated */
 		reiser4_unset_hint(clust->hint);
 		reset_cluster_params(clust);
@@ -632,7 +632,7 @@ int do_readpage_ctail(struct inode * ino
 
 	assert("edward-212", PageLocked(page));
 
-	if (unlikely(page->mapping != inode->i_mapping))
+	if (unlikely(pagecache_consistent(page, inode->i_mapping)))
 		return AOP_TRUNCATED_PAGE;
 	if (PageUptodate(page))
 		goto exit;
@@ -713,7 +713,7 @@ int readpage_ctail(void *vp, struct page
 	assert("edward-114", clust != NULL);
 	assert("edward-115", PageLocked(page));
 	assert("edward-116", !PageUptodate(page));
-	assert("edward-118", page->mapping && page->mapping->host);
+	assert("edward-118", page_mapping_cache(page) && page_inode(page));
 	assert("edward-867", !tfm_cluster_is_uptodate(&clust->tc));
 
 	hint = kmalloc(sizeof(*hint), reiser4_ctx_gfp_mask_get());
@@ -730,7 +730,7 @@ int readpage_ctail(void *vp, struct page
 	}
 	assert("vs-25", hint->ext_coord.lh == &hint->lh);
 
-	result = do_readpage_ctail(page->mapping->host, clust, page,
+	result = do_readpage_ctail(page_inode(page), clust, page,
 				   ZNODE_READ_LOCK);
 	assert("edward-213", PageLocked(page));
 	assert("edward-1163", ergo(!result, PageUptodate(page)));
@@ -781,7 +781,7 @@ static int ctail_readpages_filler(void *
 	struct cluster_handle * clust = data;
 	struct inode * inode = clust->file->f_dentry->d_inode;
 
-	assert("edward-1525", page->mapping == inode->i_mapping);
+	assert("edward-1525", pagecache_consistent(page, inode->i_mapping));
 
 	if (PageUptodate(page)) {
 		unlock_page(page);
@@ -1110,7 +1110,7 @@ int scan_ctail(flush_scan * scan)
 	assert("edward-639", znode_is_write_locked(scan->parent_lock.node));
 
 	page = jnode_page(node);
-	inode = page->mapping->host;
+	inode = page_inode(page);
 
 	if (!reiser4_scanning_left(scan))
 		return result;
@@ -1516,9 +1516,9 @@ int convert_ctail(flush_pos_t * pos)
 			assert("edward-264", pos->child != NULL);
 			assert("edward-265", jnode_page(pos->child) != NULL);
 			assert("edward-266",
-			       jnode_page(pos->child)->mapping != NULL);
+			    page_mapping_cache(jnode_page(pos->child)) != NULL);
 
-			inode = jnode_page(pos->child)->mapping->host;
+			inode = page_inode(jnode_page(pos->child));
 
 			assert("edward-267", inode != NULL);
 
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/extent_file_ops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/item/extent_file_ops.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/extent_file_ops.c
@@ -1124,7 +1124,7 @@ int reiser4_do_readpage_extent(reiser4_e
 	oid_t oid;
 	reiser4_block_nr block;
 
-	mapping = page->mapping;
+	mapping = page_mapping_cache(page);
 	oid = get_inode_oid(mapping->host);
 	index = page->index;
 
@@ -1324,14 +1324,14 @@ int reiser4_readpage_extent(void *vp, st
 
 	assert("vs-1040", PageLocked(page));
 	assert("vs-1050", !PageUptodate(page));
-	assert("vs-1039", page->mapping && page->mapping->host);
+	assert("vs-1039", page_mapping_cache(page) && page_inode(page));
 
 	assert("vs-1044", znode_is_loaded(coord->node));
 	assert("vs-758", item_is_extent(coord));
 	assert("vs-1046", coord_is_existing_unit(coord));
 	assert("vs-1045", znode_is_rlocked(coord->node));
 	assert("vs-1047",
-	       page->mapping->host->i_ino ==
+	       page_inode(page)->i_ino ==
 	       get_key_objectid(item_key_by_coord(coord, &key)));
 	check_uf_coord(uf_coord, NULL);
 
Index: test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/tail.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/reiser4/plugin/item/tail.c
+++ test-2.6.23-rc4-mm1/fs/reiser4/plugin/item/tail.c
@@ -317,7 +317,7 @@ static int do_readpage_tail(uf_coord_t *
 	/* saving passed coord in order to do not move it by tap. */
 	init_lh(&lh);
 	copy_lh(&lh, uf_coord->lh);
-	inode = page->mapping->host;
+	inode = page_inode(page);
 	coord_dup(&coord, &uf_coord->coord);
 
 	reiser4_tap_init(&tap, &coord, &lh, ZNODE_READ_LOCK);
@@ -421,14 +421,14 @@ int readpage_tail(void *vp, struct page 
 	assert("umka-2515", PageLocked(page));
 	assert("umka-2516", !PageUptodate(page));
 	assert("umka-2517", !jprivate(page) && !PagePrivate(page));
-	assert("umka-2518", page->mapping && page->mapping->host);
+	assert("umka-2518", page_mapping_cache(page) && page_inode(page));
 
 	assert("umka-2519", znode_is_loaded(coord->node));
 	assert("umka-2520", item_is_tail(coord));
 	assert("umka-2521", coord_is_existing_unit(coord));
 	assert("umka-2522", znode_is_rlocked(coord->node));
 	assert("umka-2523",
-	       page->mapping->host->i_ino ==
+	       page_inode(page)->i_ino ==
 	       get_key_objectid(item_key_by_coord(coord, &key)));
 
 	return do_readpage_tail(uf_coord, page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
