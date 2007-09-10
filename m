Date: Mon, 10 Sep 2007 19:06:07 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] add page->mapping handling interface [16/35] changes in
 GFS2
Message-Id: <20070910190607.cb233242.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070910184048.286dfc6e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: swhiteho@redhat.com, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Changes page->mapping handling in GFS2

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 fs/gfs2/log.c         |    4 ++--
 fs/gfs2/lops.c        |    2 +-
 fs/gfs2/meta_io.c     |    2 +-
 fs/gfs2/ops_address.c |   16 ++++++++--------
 4 files changed, 12 insertions(+), 12 deletions(-)

Index: test-2.6.23-rc4-mm1/fs/gfs2/log.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/log.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/log.c
@@ -229,8 +229,8 @@ static void gfs2_ail2_empty_one(struct g
 		list_del(&bd->bd_ail_st_list);
 		list_del(&bd->bd_ail_gl_list);
 		atomic_dec(&bd->bd_gl->gl_ail_count);
-		if (bd->bd_bh->b_page->mapping) {
-			bh_ip = GFS2_I(bd->bd_bh->b_page->mapping->host);
+		if (page_is_pagecache(bd->bd_bh->b_page)) {
+			bh_ip = GFS2_I(page_inode(bd->bd_bh->b_page));
 			gfs2_meta_cache_flush(bh_ip);
 		}
 		brelse(bd->bd_bh);
Index: test-2.6.23-rc4-mm1/fs/gfs2/lops.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/lops.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/lops.c
@@ -473,7 +473,7 @@ static void databuf_lo_add(struct gfs2_s
 {
 	struct gfs2_bufdata *bd = container_of(le, struct gfs2_bufdata, bd_le);
 	struct gfs2_trans *tr = current->journal_info;
-	struct address_space *mapping = bd->bd_bh->b_page->mapping;
+	struct address_space *mapping = page_mapping_cache(bd->bd_bh->b_page);
 	struct gfs2_inode *ip = GFS2_I(mapping->host);
 
 	gfs2_log_lock(sdp);
Index: test-2.6.23-rc4-mm1/fs/gfs2/meta_io.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/meta_io.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/meta_io.c
@@ -388,7 +388,7 @@ void gfs2_meta_wipe(struct gfs2_inode *i
 			if (test_clear_buffer_pinned(bh)) {
 				struct gfs2_trans *tr = current->journal_info;
 				struct gfs2_inode *bh_ip =
-					GFS2_I(bh->b_page->mapping->host);
+					GFS2_I(page_inode(bh->b_page));
 
 				gfs2_log_lock(sdp);
 				list_del_init(&bd->bd_le.le_list);
Index: test-2.6.23-rc4-mm1/fs/gfs2/ops_address.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/fs/gfs2/ops_address.c
+++ test-2.6.23-rc4-mm1/fs/gfs2/ops_address.c
@@ -114,7 +114,7 @@ static int gfs2_get_block_direct(struct 
 
 static int gfs2_writepage(struct page *page, struct writeback_control *wbc)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	loff_t i_size = i_size_read(inode);
@@ -133,7 +133,7 @@ static int gfs2_writepage(struct page *p
 	/* Is the page fully outside i_size? (truncate in progress) */
         offset = i_size & (PAGE_CACHE_SIZE-1);
 	if (page->index > end_index || (page->index == end_index && !offset)) {
-		page->mapping->a_ops->invalidatepage(page, 0);
+		page_mapping_cache(page)->a_ops->invalidatepage(page, 0);
 		unlock_page(page);
 		return 0; /* don't care */
 	}
@@ -241,8 +241,8 @@ static int stuffed_readpage(struct gfs2_
 
 static int gfs2_readpage(struct file *file, struct page *page)
 {
-	struct gfs2_inode *ip = GFS2_I(page->mapping->host);
-	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
+	struct gfs2_inode *ip = GFS2_I(page_inode(page));
+	struct gfs2_sbd *sdp = GFS2_SB(page_inode(page));
 	struct gfs2_file *gf = NULL;
 	struct gfs2_holder gh;
 	int error;
@@ -560,7 +560,7 @@ static int gfs2_write_end(struct file *f
 			  loff_t pos, unsigned len, unsigned copied,
 			  struct page *page, void *fsdata)
 {
-	struct inode *inode = page->mapping->host;
+	struct inode *inode = page_inode(page);
 	struct gfs2_inode *ip = GFS2_I(inode);
 	struct gfs2_sbd *sdp = GFS2_SB(inode);
 	struct buffer_head *dibh;
@@ -624,8 +624,8 @@ failed:
  
 static int gfs2_set_page_dirty(struct page *page)
 {
-	struct gfs2_inode *ip = GFS2_I(page->mapping->host);
-	struct gfs2_sbd *sdp = GFS2_SB(page->mapping->host);
+	struct gfs2_inode *ip = GFS2_I(page_inode(page));
+	struct gfs2_sbd *sdp = GFS2_SB(page_inode(page));
 
 	if (sdp->sd_args.ar_data == GFS2_DATA_ORDERED || gfs2_is_jdata(ip))
 		SetPageChecked(page);
@@ -746,7 +746,7 @@ out:
 
 int gfs2_releasepage(struct page *page, gfp_t gfp_mask)
 {
-	struct inode *aspace = page->mapping->host;
+	struct inode *aspace = page_inode(page);
 	struct gfs2_sbd *sdp = aspace->i_sb->s_fs_info;
 	struct buffer_head *bh, *head;
 	struct gfs2_bufdata *bd;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
