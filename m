Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f180.google.com (mail-pf0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E5DBB82F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:49:55 -0400 (EDT)
Received: by mail-pf0-f180.google.com with SMTP id n5so237580842pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:49:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id hc1si9272707pac.16.2016.03.20.11.41.46
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 25/71] cifs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:32 +0300
Message-Id: <1458499278-1516-26-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Steve French <sfrench@samba.org>

PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} macros were introduced *long* time ago
with promise that one day it will be possible to implement page cache with
bigger chunks than PAGE_SIZE.

This promise never materialized. And unlikely will.

We have many places where PAGE_CACHE_SIZE assumed to be equal to
PAGE_SIZE. And it's constant source of confusion on whether PAGE_CACHE_*
or PAGE_* constant should be used in a particular case, especially on the
border between fs and mm.

Global switching to PAGE_CACHE_SIZE != PAGE_SIZE would cause to much
breakage to be doable.

Let's stop pretending that pages in page cache are special. They are not.

The changes are pretty straight-forward:

 - <foo> << (PAGE_CACHE_SHIFT - PAGE_SHIFT) -> <foo>;

 - PAGE_CACHE_{SIZE,SHIFT,MASK,ALIGN} -> PAGE_{SIZE,SHIFT,MASK,ALIGN};

 - page_cache_get() -> get_page();

 - page_cache_release() -> put_page();

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Steve French <sfrench@samba.org>
---
 fs/cifs/cifsfs.c   |  2 +-
 fs/cifs/cifsglob.h |  4 +--
 fs/cifs/cifssmb.c  | 16 ++++-----
 fs/cifs/connect.c  |  2 +-
 fs/cifs/file.c     | 96 +++++++++++++++++++++++++++---------------------------
 fs/cifs/inode.c    | 10 +++---
 6 files changed, 65 insertions(+), 65 deletions(-)

diff --git a/fs/cifs/cifsfs.c b/fs/cifs/cifsfs.c
index 1d86fc620e5c..89201564c346 100644
--- a/fs/cifs/cifsfs.c
+++ b/fs/cifs/cifsfs.c
@@ -962,7 +962,7 @@ static int cifs_clone_file_range(struct file *src_file, loff_t off,
 	cifs_dbg(FYI, "about to flush pages\n");
 	/* should we flush first and last page first */
 	truncate_inode_pages_range(&target_inode->i_data, destoff,
-				   PAGE_CACHE_ALIGN(destoff + len)-1);
+				   PAGE_ALIGN(destoff + len)-1);
 
 	if (target_tcon->ses->server->ops->duplicate_extents)
 		rc = target_tcon->ses->server->ops->duplicate_extents(xid,
diff --git a/fs/cifs/cifsglob.h b/fs/cifs/cifsglob.h
index d21da9f05bae..f2cc0b3d1af7 100644
--- a/fs/cifs/cifsglob.h
+++ b/fs/cifs/cifsglob.h
@@ -714,7 +714,7 @@ compare_mid(__u16 mid, const struct smb_hdr *smb)
  *
  * Note that this might make for "interesting" allocation problems during
  * writeback however as we have to allocate an array of pointers for the
- * pages. A 16M write means ~32kb page array with PAGE_CACHE_SIZE == 4096.
+ * pages. A 16M write means ~32kb page array with PAGE_SIZE == 4096.
  *
  * For reads, there is a similar problem as we need to allocate an array
  * of kvecs to handle the receive, though that should only need to be done
@@ -733,7 +733,7 @@ compare_mid(__u16 mid, const struct smb_hdr *smb)
 
 /*
  * The default wsize is 1M. find_get_pages seems to return a maximum of 256
- * pages in a single call. With PAGE_CACHE_SIZE == 4k, this means we can fill
+ * pages in a single call. With PAGE_SIZE == 4k, this means we can fill
  * a single wsize request with a single call.
  */
 #define CIFS_DEFAULT_IOSIZE (1024 * 1024)
diff --git a/fs/cifs/cifssmb.c b/fs/cifs/cifssmb.c
index 76fcb50295a3..a894bf809ff7 100644
--- a/fs/cifs/cifssmb.c
+++ b/fs/cifs/cifssmb.c
@@ -1929,17 +1929,17 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 
 		wsize = server->ops->wp_retry_size(inode);
 		if (wsize < rest_len) {
-			nr_pages = wsize / PAGE_CACHE_SIZE;
+			nr_pages = wsize / PAGE_SIZE;
 			if (!nr_pages) {
 				rc = -ENOTSUPP;
 				break;
 			}
-			cur_len = nr_pages * PAGE_CACHE_SIZE;
-			tailsz = PAGE_CACHE_SIZE;
+			cur_len = nr_pages * PAGE_SIZE;
+			tailsz = PAGE_SIZE;
 		} else {
-			nr_pages = DIV_ROUND_UP(rest_len, PAGE_CACHE_SIZE);
+			nr_pages = DIV_ROUND_UP(rest_len, PAGE_SIZE);
 			cur_len = rest_len;
-			tailsz = rest_len - (nr_pages - 1) * PAGE_CACHE_SIZE;
+			tailsz = rest_len - (nr_pages - 1) * PAGE_SIZE;
 		}
 
 		wdata2 = cifs_writedata_alloc(nr_pages, cifs_writev_complete);
@@ -1957,7 +1957,7 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 		wdata2->sync_mode = wdata->sync_mode;
 		wdata2->nr_pages = nr_pages;
 		wdata2->offset = page_offset(wdata2->pages[0]);
-		wdata2->pagesz = PAGE_CACHE_SIZE;
+		wdata2->pagesz = PAGE_SIZE;
 		wdata2->tailsz = tailsz;
 		wdata2->bytes = cur_len;
 
@@ -1975,7 +1975,7 @@ cifs_writev_requeue(struct cifs_writedata *wdata)
 			if (rc != 0 && rc != -EAGAIN) {
 				SetPageError(wdata2->pages[j]);
 				end_page_writeback(wdata2->pages[j]);
-				page_cache_release(wdata2->pages[j]);
+				put_page(wdata2->pages[j]);
 			}
 		}
 
@@ -2018,7 +2018,7 @@ cifs_writev_complete(struct work_struct *work)
 		else if (wdata->result < 0)
 			SetPageError(page);
 		end_page_writeback(page);
-		page_cache_release(page);
+		put_page(page);
 	}
 	if (wdata->result != -EAGAIN)
 		mapping_set_error(inode->i_mapping, wdata->result);
diff --git a/fs/cifs/connect.c b/fs/cifs/connect.c
index a763cd3d9e7c..6f62ac821a84 100644
--- a/fs/cifs/connect.c
+++ b/fs/cifs/connect.c
@@ -3630,7 +3630,7 @@ try_mount_again:
 	cifs_sb->rsize = server->ops->negotiate_rsize(tcon, volume_info);
 
 	/* tune readahead according to rsize */
-	cifs_sb->bdi.ra_pages = cifs_sb->rsize / PAGE_CACHE_SIZE;
+	cifs_sb->bdi.ra_pages = cifs_sb->rsize / PAGE_SIZE;
 
 remote_path_check:
 #ifdef CONFIG_CIFS_DFS_UPCALL
diff --git a/fs/cifs/file.c b/fs/cifs/file.c
index ff882aeaccc6..c03d0744648b 100644
--- a/fs/cifs/file.c
+++ b/fs/cifs/file.c
@@ -1833,7 +1833,7 @@ refind_writable:
 static int cifs_partialpagewrite(struct page *page, unsigned from, unsigned to)
 {
 	struct address_space *mapping = page->mapping;
-	loff_t offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	loff_t offset = (loff_t)page->index << PAGE_SHIFT;
 	char *write_data;
 	int rc = -EFAULT;
 	int bytes_written = 0;
@@ -1849,7 +1849,7 @@ static int cifs_partialpagewrite(struct page *page, unsigned from, unsigned to)
 	write_data = kmap(page);
 	write_data += from;
 
-	if ((to > PAGE_CACHE_SIZE) || (from > to)) {
+	if ((to > PAGE_SIZE) || (from > to)) {
 		kunmap(page);
 		return -EIO;
 	}
@@ -1902,7 +1902,7 @@ wdata_alloc_and_fillpages(pgoff_t tofind, struct address_space *mapping,
 	 * find_get_pages_tag seems to return a max of 256 on each
 	 * iteration, so we must call it several times in order to
 	 * fill the array or the wsize is effectively limited to
-	 * 256 * PAGE_CACHE_SIZE.
+	 * 256 * PAGE_SIZE.
 	 */
 	*found_pages = 0;
 	pages = wdata->pages;
@@ -1991,7 +1991,7 @@ wdata_prepare_pages(struct cifs_writedata *wdata, unsigned int found_pages,
 
 	/* put any pages we aren't going to use */
 	for (i = nr_pages; i < found_pages; i++) {
-		page_cache_release(wdata->pages[i]);
+		put_page(wdata->pages[i]);
 		wdata->pages[i] = NULL;
 	}
 
@@ -2009,11 +2009,11 @@ wdata_send_pages(struct cifs_writedata *wdata, unsigned int nr_pages,
 	wdata->sync_mode = wbc->sync_mode;
 	wdata->nr_pages = nr_pages;
 	wdata->offset = page_offset(wdata->pages[0]);
-	wdata->pagesz = PAGE_CACHE_SIZE;
+	wdata->pagesz = PAGE_SIZE;
 	wdata->tailsz = min(i_size_read(mapping->host) -
 			page_offset(wdata->pages[nr_pages - 1]),
-			(loff_t)PAGE_CACHE_SIZE);
-	wdata->bytes = ((nr_pages - 1) * PAGE_CACHE_SIZE) + wdata->tailsz;
+			(loff_t)PAGE_SIZE);
+	wdata->bytes = ((nr_pages - 1) * PAGE_SIZE) + wdata->tailsz;
 
 	if (wdata->cfile != NULL)
 		cifsFileInfo_put(wdata->cfile);
@@ -2047,15 +2047,15 @@ static int cifs_writepages(struct address_space *mapping,
 	 * If wsize is smaller than the page cache size, default to writing
 	 * one page at a time via cifs_writepage
 	 */
-	if (cifs_sb->wsize < PAGE_CACHE_SIZE)
+	if (cifs_sb->wsize < PAGE_SIZE)
 		return generic_writepages(mapping, wbc);
 
 	if (wbc->range_cyclic) {
 		index = mapping->writeback_index; /* Start from prev offset */
 		end = -1;
 	} else {
-		index = wbc->range_start >> PAGE_CACHE_SHIFT;
-		end = wbc->range_end >> PAGE_CACHE_SHIFT;
+		index = wbc->range_start >> PAGE_SHIFT;
+		end = wbc->range_end >> PAGE_SHIFT;
 		if (wbc->range_start == 0 && wbc->range_end == LLONG_MAX)
 			range_whole = true;
 		scanned = true;
@@ -2071,7 +2071,7 @@ retry:
 		if (rc)
 			break;
 
-		tofind = min((wsize / PAGE_CACHE_SIZE) - 1, end - index) + 1;
+		tofind = min((wsize / PAGE_SIZE) - 1, end - index) + 1;
 
 		wdata = wdata_alloc_and_fillpages(tofind, mapping, end, &index,
 						  &found_pages);
@@ -2111,7 +2111,7 @@ retry:
 				else
 					SetPageError(wdata->pages[i]);
 				end_page_writeback(wdata->pages[i]);
-				page_cache_release(wdata->pages[i]);
+				put_page(wdata->pages[i]);
 			}
 			if (rc != -EAGAIN)
 				mapping_set_error(mapping, rc);
@@ -2154,7 +2154,7 @@ cifs_writepage_locked(struct page *page, struct writeback_control *wbc)
 
 	xid = get_xid();
 /* BB add check for wbc flags */
-	page_cache_get(page);
+	get_page(page);
 	if (!PageUptodate(page))
 		cifs_dbg(FYI, "ppw - page not up to date\n");
 
@@ -2170,7 +2170,7 @@ cifs_writepage_locked(struct page *page, struct writeback_control *wbc)
 	 */
 	set_page_writeback(page);
 retry_write:
-	rc = cifs_partialpagewrite(page, 0, PAGE_CACHE_SIZE);
+	rc = cifs_partialpagewrite(page, 0, PAGE_SIZE);
 	if (rc == -EAGAIN && wbc->sync_mode == WB_SYNC_ALL)
 		goto retry_write;
 	else if (rc == -EAGAIN)
@@ -2180,7 +2180,7 @@ retry_write:
 	else
 		SetPageUptodate(page);
 	end_page_writeback(page);
-	page_cache_release(page);
+	put_page(page);
 	free_xid(xid);
 	return rc;
 }
@@ -2214,12 +2214,12 @@ static int cifs_write_end(struct file *file, struct address_space *mapping,
 		if (copied == len)
 			SetPageUptodate(page);
 		ClearPageChecked(page);
-	} else if (!PageUptodate(page) && copied == PAGE_CACHE_SIZE)
+	} else if (!PageUptodate(page) && copied == PAGE_SIZE)
 		SetPageUptodate(page);
 
 	if (!PageUptodate(page)) {
 		char *page_data;
-		unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+		unsigned offset = pos & (PAGE_SIZE - 1);
 		unsigned int xid;
 
 		xid = get_xid();
@@ -2248,7 +2248,7 @@ static int cifs_write_end(struct file *file, struct address_space *mapping,
 	}
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return rc;
 }
@@ -3286,9 +3286,9 @@ cifs_readv_complete(struct work_struct *work)
 		    (rdata->result == -EAGAIN && got_bytes))
 			cifs_readpage_to_fscache(rdata->mapping->host, page);
 
-		got_bytes -= min_t(unsigned int, PAGE_CACHE_SIZE, got_bytes);
+		got_bytes -= min_t(unsigned int, PAGE_SIZE, got_bytes);
 
-		page_cache_release(page);
+		put_page(page);
 		rdata->pages[i] = NULL;
 	}
 	kref_put(&rdata->refcount, cifs_readdata_release);
@@ -3307,21 +3307,21 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 
 	/* determine the eof that the server (probably) has */
 	eof = CIFS_I(rdata->mapping->host)->server_eof;
-	eof_index = eof ? (eof - 1) >> PAGE_CACHE_SHIFT : 0;
+	eof_index = eof ? (eof - 1) >> PAGE_SHIFT : 0;
 	cifs_dbg(FYI, "eof=%llu eof_index=%lu\n", eof, eof_index);
 
 	rdata->got_bytes = 0;
-	rdata->tailsz = PAGE_CACHE_SIZE;
+	rdata->tailsz = PAGE_SIZE;
 	for (i = 0; i < nr_pages; i++) {
 		struct page *page = rdata->pages[i];
 
-		if (len >= PAGE_CACHE_SIZE) {
+		if (len >= PAGE_SIZE) {
 			/* enough data to fill the page */
 			iov.iov_base = kmap(page);
-			iov.iov_len = PAGE_CACHE_SIZE;
+			iov.iov_len = PAGE_SIZE;
 			cifs_dbg(FYI, "%u: idx=%lu iov_base=%p iov_len=%zu\n",
 				 i, page->index, iov.iov_base, iov.iov_len);
-			len -= PAGE_CACHE_SIZE;
+			len -= PAGE_SIZE;
 		} else if (len > 0) {
 			/* enough for partial page, fill and zero the rest */
 			iov.iov_base = kmap(page);
@@ -3329,7 +3329,7 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			cifs_dbg(FYI, "%u: idx=%lu iov_base=%p iov_len=%zu\n",
 				 i, page->index, iov.iov_base, iov.iov_len);
 			memset(iov.iov_base + len,
-				'\0', PAGE_CACHE_SIZE - len);
+				'\0', PAGE_SIZE - len);
 			rdata->tailsz = len;
 			len = 0;
 		} else if (page->index > eof_index) {
@@ -3341,12 +3341,12 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			 * to prevent the VFS from repeatedly attempting to
 			 * fill them until the writes are flushed.
 			 */
-			zero_user(page, 0, PAGE_CACHE_SIZE);
+			zero_user(page, 0, PAGE_SIZE);
 			lru_cache_add_file(page);
 			flush_dcache_page(page);
 			SetPageUptodate(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			rdata->pages[i] = NULL;
 			rdata->nr_pages--;
 			continue;
@@ -3354,7 +3354,7 @@ cifs_readpages_read_into_pages(struct TCP_Server_Info *server,
 			/* no need to hold page hostage */
 			lru_cache_add_file(page);
 			unlock_page(page);
-			page_cache_release(page);
+			put_page(page);
 			rdata->pages[i] = NULL;
 			rdata->nr_pages--;
 			continue;
@@ -3402,8 +3402,8 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 	}
 
 	/* move first page to the tmplist */
-	*offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
-	*bytes = PAGE_CACHE_SIZE;
+	*offset = (loff_t)page->index << PAGE_SHIFT;
+	*bytes = PAGE_SIZE;
 	*nr_pages = 1;
 	list_move_tail(&page->lru, tmplist);
 
@@ -3415,7 +3415,7 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 			break;
 
 		/* would this page push the read over the rsize? */
-		if (*bytes + PAGE_CACHE_SIZE > rsize)
+		if (*bytes + PAGE_SIZE > rsize)
 			break;
 
 		__SetPageLocked(page);
@@ -3424,7 +3424,7 @@ readpages_get_pages(struct address_space *mapping, struct list_head *page_list,
 			break;
 		}
 		list_move_tail(&page->lru, tmplist);
-		(*bytes) += PAGE_CACHE_SIZE;
+		(*bytes) += PAGE_SIZE;
 		expected_index++;
 		(*nr_pages)++;
 	}
@@ -3493,7 +3493,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 		 * reach this point however since we set ra_pages to 0 when the
 		 * rsize is smaller than a cache page.
 		 */
-		if (unlikely(rsize < PAGE_CACHE_SIZE)) {
+		if (unlikely(rsize < PAGE_SIZE)) {
 			add_credits_and_wake_if(server, credits, 0);
 			return 0;
 		}
@@ -3512,7 +3512,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 				list_del(&page->lru);
 				lru_cache_add_file(page);
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 			rc = -ENOMEM;
 			add_credits_and_wake_if(server, credits, 0);
@@ -3524,7 +3524,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 		rdata->offset = offset;
 		rdata->bytes = bytes;
 		rdata->pid = pid;
-		rdata->pagesz = PAGE_CACHE_SIZE;
+		rdata->pagesz = PAGE_SIZE;
 		rdata->read_into_pages = cifs_readpages_read_into_pages;
 		rdata->credits = credits;
 
@@ -3542,7 +3542,7 @@ static int cifs_readpages(struct file *file, struct address_space *mapping,
 				page = rdata->pages[i];
 				lru_cache_add_file(page);
 				unlock_page(page);
-				page_cache_release(page);
+				put_page(page);
 			}
 			/* Fallback to the readpage in error/reconnect cases */
 			kref_put(&rdata->refcount, cifs_readdata_release);
@@ -3577,7 +3577,7 @@ static int cifs_readpage_worker(struct file *file, struct page *page,
 	read_data = kmap(page);
 	/* for reads over a certain size could initiate async read ahead */
 
-	rc = cifs_read(file, read_data, PAGE_CACHE_SIZE, poffset);
+	rc = cifs_read(file, read_data, PAGE_SIZE, poffset);
 
 	if (rc < 0)
 		goto io_error;
@@ -3587,8 +3587,8 @@ static int cifs_readpage_worker(struct file *file, struct page *page,
 	file_inode(file)->i_atime =
 		current_fs_time(file_inode(file)->i_sb);
 
-	if (PAGE_CACHE_SIZE > rc)
-		memset(read_data + rc, 0, PAGE_CACHE_SIZE - rc);
+	if (PAGE_SIZE > rc)
+		memset(read_data + rc, 0, PAGE_SIZE - rc);
 
 	flush_dcache_page(page);
 	SetPageUptodate(page);
@@ -3608,7 +3608,7 @@ read_complete:
 
 static int cifs_readpage(struct file *file, struct page *page)
 {
-	loff_t offset = (loff_t)page->index << PAGE_CACHE_SHIFT;
+	loff_t offset = (loff_t)page->index << PAGE_SHIFT;
 	int rc = -EACCES;
 	unsigned int xid;
 
@@ -3679,8 +3679,8 @@ static int cifs_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	int oncethru = 0;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	loff_t offset = pos & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = pos >> PAGE_SHIFT;
+	loff_t offset = pos & (PAGE_SIZE - 1);
 	loff_t page_start = pos & PAGE_MASK;
 	loff_t i_size;
 	struct page *page;
@@ -3703,7 +3703,7 @@ start:
 	 * the server. If the write is short, we'll end up doing a sync write
 	 * instead.
 	 */
-	if (len == PAGE_CACHE_SIZE)
+	if (len == PAGE_SIZE)
 		goto out;
 
 	/*
@@ -3718,7 +3718,7 @@ start:
 		    (offset == 0 && (pos + len) >= i_size)) {
 			zero_user_segments(page, 0, offset,
 					   offset + len,
-					   PAGE_CACHE_SIZE);
+					   PAGE_SIZE);
 			/*
 			 * PageChecked means that the parts of the page
 			 * to which we're not writing are considered up
@@ -3737,7 +3737,7 @@ start:
 		 * do a sync write instead since PG_uptodate isn't set.
 		 */
 		cifs_readpage_worker(file, page, &page_start);
-		page_cache_release(page);
+		put_page(page);
 		oncethru = 1;
 		goto start;
 	} else {
@@ -3764,7 +3764,7 @@ static void cifs_invalidate_page(struct page *page, unsigned int offset,
 {
 	struct cifsInodeInfo *cifsi = CIFS_I(page->mapping->host);
 
-	if (offset == 0 && length == PAGE_CACHE_SIZE)
+	if (offset == 0 && length == PAGE_SIZE)
 		cifs_fscache_invalidate_page(page, &cifsi->vfs_inode);
 }
 
@@ -3772,7 +3772,7 @@ static int cifs_launder_page(struct page *page)
 {
 	int rc = 0;
 	loff_t range_start = page_offset(page);
-	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
+	loff_t range_end = range_start + (loff_t)(PAGE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 0,
diff --git a/fs/cifs/inode.c b/fs/cifs/inode.c
index aeb26dbfa1bf..5f9ad5c42180 100644
--- a/fs/cifs/inode.c
+++ b/fs/cifs/inode.c
@@ -59,7 +59,7 @@ static void cifs_set_ops(struct inode *inode)
 
 		/* check if server can support readpages */
 		if (cifs_sb_master_tcon(cifs_sb)->ses->server->maxBuf <
-				PAGE_CACHE_SIZE + MAX_CIFS_HDR_SIZE)
+				PAGE_SIZE + MAX_CIFS_HDR_SIZE)
 			inode->i_data.a_ops = &cifs_addr_ops_smallbuf;
 		else
 			inode->i_data.a_ops = &cifs_addr_ops;
@@ -2019,8 +2019,8 @@ int cifs_getattr(struct vfsmount *mnt, struct dentry *dentry,
 
 static int cifs_truncate_page(struct address_space *mapping, loff_t from)
 {
-	pgoff_t index = from >> PAGE_CACHE_SHIFT;
-	unsigned offset = from & (PAGE_CACHE_SIZE - 1);
+	pgoff_t index = from >> PAGE_SHIFT;
+	unsigned offset = from & (PAGE_SIZE - 1);
 	struct page *page;
 	int rc = 0;
 
@@ -2028,9 +2028,9 @@ static int cifs_truncate_page(struct address_space *mapping, loff_t from)
 	if (!page)
 		return -ENOMEM;
 
-	zero_user_segment(page, offset, PAGE_CACHE_SIZE);
+	zero_user_segment(page, offset, PAGE_SIZE);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return rc;
 }
 
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
