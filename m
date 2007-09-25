Message-Id: <20070925233005.845179930@sgi.com>
References: <20070925232543.036615409@sgi.com>
Date: Tue, 25 Sep 2007 16:25:45 -0700
From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 02/14] Reiser4 portion of zero_user cleanup patch
Content-Disposition: inline; filename=zero_user_reiserfs
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Reiser4 only exists in mm. So split this off.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 fs/buffer.c                              |    2 +-
 fs/reiser4/plugin/file/cryptcompress.c   |    8 +++-----
 fs/reiser4/plugin/file/file.c            |    4 ++--
 fs/reiser4/plugin/item/ctail.c           |    8 ++++----
 fs/reiser4/plugin/item/extent_file_ops.c |    4 ++--
 fs/reiser4/plugin/item/tail.c            |    3 +--
 6 files changed, 13 insertions(+), 16 deletions(-)

Index: linux-2.6.23-rc8-mm1/fs/reiser4/plugin/file/cryptcompress.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/reiser4/plugin/file/cryptcompress.c	2007-09-25 15:12:22.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/reiser4/plugin/file/cryptcompress.c	2007-09-25 15:12:51.000000000 -0700
@@ -2056,7 +2056,7 @@ static int write_hole(struct inode *inod
 
 		to_pg = min((typeof(pg_off))PAGE_CACHE_SIZE - pg_off, cl_count);
 		lock_page(page);
-		zero_user_page(page, pg_off, to_pg, KM_USER0);
+		zero_user(page, pg_off, to_pg);
 		SetPageUptodate(page);
 		reiser4_set_page_dirty_internal(page);
 		mark_page_accessed(page);
@@ -2294,8 +2294,7 @@ static int read_some_cluster_pages(struc
 			off = off_to_pgoff(win->off+win->count+win->delta);
 			if (off) {
 				lock_page(pg);
-				zero_user_page(pg, off, PAGE_CACHE_SIZE - off,
-						KM_USER0);
+				zero_user_segment(pg, off, PAGE_CACHE_SIZE);
 				unlock_page(pg);
 			}
 		}
@@ -2342,8 +2341,7 @@ static int read_some_cluster_pages(struc
 
 			offset =
 			    off_to_pgoff(win->off + win->count + win->delta);
-			zero_user_page(pg, offset, PAGE_CACHE_SIZE - offset,
-					KM_USER0);
+			zero_user_segment(pg, offset, PAGE_CACHE_SIZE);
 			unlock_page(pg);
 			/* still not uptodate */
 			break;
Index: linux-2.6.23-rc8-mm1/fs/reiser4/plugin/file/file.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/reiser4/plugin/file/file.c	2007-09-25 15:12:22.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/reiser4/plugin/file/file.c	2007-09-25 15:12:51.000000000 -0700
@@ -532,7 +532,7 @@ static int shorten_file(struct inode *in
 
 	lock_page(page);
 	assert("vs-1066", PageLocked(page));
-	zero_user_page(page, padd_from, PAGE_CACHE_SIZE - padd_from, KM_USER0);
+	zero_user_segment(page, padd_from, PAGE_CACHE_SIZE);
 	unlock_page(page);
 	page_cache_release(page);
 	/* the below does up(sbinfo->delete_mutex). Do not get confused */
@@ -1437,7 +1437,7 @@ int readpage_unix_file(struct file *file
 
 	if (page->mapping->host->i_size <= page_offset(page)) {
 		/* page is out of file */
-		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_CACHE_SIZE);
 		SetPageUptodate(page);
 		unlock_page(page);
 		return 0;
Index: linux-2.6.23-rc8-mm1/fs/reiser4/plugin/item/ctail.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/reiser4/plugin/item/ctail.c	2007-09-25 15:12:22.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/reiser4/plugin/item/ctail.c	2007-09-25 15:12:51.000000000 -0700
@@ -638,7 +638,7 @@ int do_readpage_ctail(struct inode * ino
 		goto exit;
 	to_page = pbytes(page_index(page), inode);
 	if (to_page == 0) {
-		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_CACHE_SIZE);
 		SetPageUptodate(page);
 		goto exit;
 	}
@@ -655,7 +655,7 @@ int do_readpage_ctail(struct inode * ino
 		/* refresh bytes */
 		to_page = pbytes(page_index(page), inode);
 		if (to_page == 0) {
-			zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+			zero_user(page, 0, PAGE_CACHE_SIZE);
 			SetPageUptodate(page);
 			goto exit;
 		}
@@ -678,7 +678,7 @@ int do_readpage_ctail(struct inode * ino
 		 */
 	case FAKE_DISK_CLUSTER:
 		/* fill the page by zeroes */
-		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_CACHE_SIZE);
 		SetPageUptodate(page);
 		break;
 	case PREP_DISK_CLUSTER:
@@ -788,7 +788,7 @@ static int ctail_readpages_filler(void *
 		return 0;
 	}
 	if (pbytes(page_index(page), inode) == 0) {
-		zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+		zero_user(page, 0, PAGE_CACHE_SIZE);
 		SetPageUptodate(page);
 		unlock_page(page);
 		return 0;
Index: linux-2.6.23-rc8-mm1/fs/reiser4/plugin/item/extent_file_ops.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/reiser4/plugin/item/extent_file_ops.c	2007-09-25 15:12:22.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/reiser4/plugin/item/extent_file_ops.c	2007-09-25 15:12:51.000000000 -0700
@@ -1136,7 +1136,7 @@ int reiser4_do_readpage_extent(reiser4_e
 		 */
 		j = jfind(mapping, index);
 		if (j == NULL) {
-			zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+			zero_user(page, 0, PAGE_CACHE_SIZE);
 			SetPageUptodate(page);
 			unlock_page(page);
 			return 0;
@@ -1151,7 +1151,7 @@ int reiser4_do_readpage_extent(reiser4_e
 		block = *jnode_get_io_block(j);
 		spin_unlock_jnode(j);
 		if (block == 0) {
-			zero_user_page(page, 0, PAGE_CACHE_SIZE, KM_USER0);
+			zero_user(page, 0, PAGE_CACHE_SIZE);
 			SetPageUptodate(page);
 			unlock_page(page);
 			jput(j);
Index: linux-2.6.23-rc8-mm1/fs/reiser4/plugin/item/tail.c
===================================================================
--- linux-2.6.23-rc8-mm1.orig/fs/reiser4/plugin/item/tail.c	2007-09-25 15:12:22.000000000 -0700
+++ linux-2.6.23-rc8-mm1/fs/reiser4/plugin/item/tail.c	2007-09-25 15:12:51.000000000 -0700
@@ -392,8 +392,7 @@ static int do_readpage_tail(uf_coord_t *
 
  done:
 	if (mapped != PAGE_CACHE_SIZE)
-		zero_user_page(page, mapped, PAGE_CACHE_SIZE - mapped,
-				KM_USER0);
+		zero_user_segment(page, mapped, PAGE_CACHE_SIZE);
 	SetPageUptodate(page);
  out_unlock_page:
 	unlock_page(page);

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
