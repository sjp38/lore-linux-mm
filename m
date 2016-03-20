Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f181.google.com (mail-pf0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id 41995828DF
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:42:15 -0400 (EDT)
Received: by mail-pf0-f181.google.com with SMTP id x3so237457369pfb.1
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:42:15 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTP id ol15si14265943pab.45.2016.03.20.11.41.50
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:50 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 50/71] nfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:57 +0300
Message-Id: <1458499278-1516-51-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>

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
Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c      | 24 ++++++++---------
 fs/nfs/blocklayout/blocklayout.h      |  4 +--
 fs/nfs/client.c                       |  8 +++---
 fs/nfs/dir.c                          |  4 +--
 fs/nfs/direct.c                       |  8 +++---
 fs/nfs/file.c                         | 20 +++++++-------
 fs/nfs/internal.h                     |  6 ++---
 fs/nfs/nfs4xdr.c                      |  2 +-
 fs/nfs/objlayout/objio_osd.c          |  2 +-
 fs/nfs/pagelist.c                     |  6 ++---
 fs/nfs/pnfs.c                         |  6 ++---
 fs/nfs/read.c                         | 16 +++++------
 fs/nfs/write.c                        |  4 +--
 include/linux/nfs_page.h              |  6 ++---
 include/linux/sunrpc/svc.h            |  2 +-
 net/sunrpc/auth_gss/auth_gss.c        |  8 +++---
 net/sunrpc/auth_gss/gss_krb5_crypto.c |  2 +-
 net/sunrpc/auth_gss/gss_krb5_wrap.c   |  4 +--
 net/sunrpc/cache.c                    |  4 +--
 net/sunrpc/rpc_pipe.c                 |  4 +--
 net/sunrpc/socklib.c                  |  6 ++---
 net/sunrpc/xdr.c                      | 50 +++++++++++++++++------------------
 22 files changed, 98 insertions(+), 98 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index ddd0138f410c..bba0ba9f7eb1 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -231,7 +231,7 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 	size_t bytes_left = header->args.count;
 	unsigned int pg_offset = header->args.pgbase, pg_len;
 	struct page **pages = header->args.pages;
-	int pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
+	int pg_index = header->args.pgbase >> PAGE_SHIFT;
 	const bool is_dio = (header->dreq != NULL);
 	struct blk_plug plug;
 	int i;
@@ -263,13 +263,13 @@ bl_read_pagelist(struct nfs_pgio_header *header)
 		}
 
 		if (is_dio) {
-			if (pg_offset + bytes_left > PAGE_CACHE_SIZE)
-				pg_len = PAGE_CACHE_SIZE - pg_offset;
+			if (pg_offset + bytes_left > PAGE_SIZE)
+				pg_len = PAGE_SIZE - pg_offset;
 			else
 				pg_len = bytes_left;
 		} else {
 			BUG_ON(pg_offset != 0);
-			pg_len = PAGE_CACHE_SIZE;
+			pg_len = PAGE_SIZE;
 		}
 
 		if (is_hole(&be)) {
@@ -339,9 +339,9 @@ static void bl_write_cleanup(struct work_struct *work)
 
 	if (likely(!hdr->pnfs_error)) {
 		struct pnfs_block_layout *bl = BLK_LSEG2EXT(hdr->lseg);
-		u64 start = hdr->args.offset & (loff_t)PAGE_CACHE_MASK;
+		u64 start = hdr->args.offset & (loff_t)PAGE_MASK;
 		u64 end = (hdr->args.offset + hdr->args.count +
-			PAGE_CACHE_SIZE - 1) & (loff_t)PAGE_CACHE_MASK;
+			PAGE_SIZE - 1) & (loff_t)PAGE_MASK;
 
 		ext_tree_mark_written(bl, start >> SECTOR_SHIFT,
 					(end - start) >> SECTOR_SHIFT);
@@ -373,7 +373,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	loff_t offset = header->args.offset;
 	size_t count = header->args.count;
 	struct page **pages = header->args.pages;
-	int pg_index = header->args.pgbase >> PAGE_CACHE_SHIFT;
+	int pg_index = header->args.pgbase >> PAGE_SHIFT;
 	unsigned int pg_len;
 	struct blk_plug plug;
 	int i;
@@ -392,7 +392,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 	blk_start_plug(&plug);
 
 	/* we always write out the whole page */
-	offset = offset & (loff_t)PAGE_CACHE_MASK;
+	offset = offset & (loff_t)PAGE_MASK;
 	isect = offset >> SECTOR_SHIFT;
 
 	for (i = pg_index; i < header->page_array.npages; i++) {
@@ -408,7 +408,7 @@ bl_write_pagelist(struct nfs_pgio_header *header, int sync)
 			extent_length = be.be_length - (isect - be.be_f_offset);
 		}
 
-		pg_len = PAGE_CACHE_SIZE;
+		pg_len = PAGE_SIZE;
 		bio = do_add_page_to_bio(bio, header->page_array.npages - i,
 					 WRITE, isect, pages[i], &map, &be,
 					 bl_end_io_write, par,
@@ -806,7 +806,7 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 	pgoff_t end;
 
 	/* Optimize common case that writes from 0 to end of file */
-	end = DIV_ROUND_UP(i_size_read(inode), PAGE_CACHE_SIZE);
+	end = DIV_ROUND_UP(i_size_read(inode), PAGE_SIZE);
 	if (end != inode->i_mapping->nrpages) {
 		rcu_read_lock();
 		end = page_cache_next_hole(mapping, idx + 1, ULONG_MAX);
@@ -814,9 +814,9 @@ static u64 pnfs_num_cont_bytes(struct inode *inode, pgoff_t idx)
 	}
 
 	if (!end)
-		return i_size_read(inode) - (idx << PAGE_CACHE_SHIFT);
+		return i_size_read(inode) - (idx << PAGE_SHIFT);
 	else
-		return (end - idx) << PAGE_CACHE_SHIFT;
+		return (end - idx) << PAGE_SHIFT;
 }
 
 static void
diff --git a/fs/nfs/blocklayout/blocklayout.h b/fs/nfs/blocklayout/blocklayout.h
index c556640dcf3b..f99371796c63 100644
--- a/fs/nfs/blocklayout/blocklayout.h
+++ b/fs/nfs/blocklayout/blocklayout.h
@@ -40,8 +40,8 @@
 #include "../pnfs.h"
 #include "../netns.h"
 
-#define PAGE_CACHE_SECTORS (PAGE_CACHE_SIZE >> SECTOR_SHIFT)
-#define PAGE_CACHE_SECTOR_SHIFT (PAGE_CACHE_SHIFT - SECTOR_SHIFT)
+#define PAGE_CACHE_SECTORS (PAGE_SIZE >> SECTOR_SHIFT)
+#define PAGE_CACHE_SECTOR_SHIFT (PAGE_SHIFT - SECTOR_SHIFT)
 #define SECTOR_SIZE (1 << SECTOR_SHIFT)
 
 struct pnfs_block_dev;
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index d6d5d2a48e83..0c96528db94a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -736,7 +736,7 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->rsize = max_rpc_payload;
 	if (server->rsize > NFS_MAX_FILE_IO_SIZE)
 		server->rsize = NFS_MAX_FILE_IO_SIZE;
-	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	server->rpages = (server->rsize + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	server->backing_dev_info.name = "nfs";
 	server->backing_dev_info.ra_pages = server->rpages * NFS_MAX_READAHEAD;
@@ -745,13 +745,13 @@ static void nfs_server_set_fsinfo(struct nfs_server *server,
 		server->wsize = max_rpc_payload;
 	if (server->wsize > NFS_MAX_FILE_IO_SIZE)
 		server->wsize = NFS_MAX_FILE_IO_SIZE;
-	server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
+	server->wpages = (server->wsize + PAGE_SIZE - 1) >> PAGE_SHIFT;
 
 	server->wtmult = nfs_block_bits(fsinfo->wtmult, NULL);
 
 	server->dtsize = nfs_block_size(fsinfo->dtpref, NULL);
-	if (server->dtsize > PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES)
-		server->dtsize = PAGE_CACHE_SIZE * NFS_MAX_READDIR_PAGES;
+	if (server->dtsize > PAGE_SIZE * NFS_MAX_READDIR_PAGES)
+		server->dtsize = PAGE_SIZE * NFS_MAX_READDIR_PAGES;
 	if (server->dtsize > server->rsize)
 		server->dtsize = server->rsize;
 
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4bfa7d8bcade..adef506c5786 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -707,7 +707,7 @@ void cache_page_release(nfs_readdir_descriptor_t *desc)
 {
 	if (!desc->page->mapping)
 		nfs_readdir_clear_array(desc->page);
-	page_cache_release(desc->page);
+	put_page(desc->page);
 	desc->page = NULL;
 }
 
@@ -1923,7 +1923,7 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 		 * add_to_page_cache_lru() grabs an extra page refcount.
 		 * Drop it here to avoid leaking this page later.
 		 */
-		page_cache_release(page);
+		put_page(page);
 	} else
 		__free_page(page);
 
diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 7a0cfd3266e5..c93826e4a8c6 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -269,7 +269,7 @@ static void nfs_direct_release_pages(struct page **pages, unsigned int npages)
 {
 	unsigned int i;
 	for (i = 0; i < npages; i++)
-		page_cache_release(pages[i]);
+		put_page(pages[i]);
 }
 
 void nfs_init_cinfo_from_dreq(struct nfs_commit_info *cinfo,
@@ -1003,7 +1003,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 		      iov_iter_count(iter));
 
 	pos = iocb->ki_pos;
-	end = (pos + iov_iter_count(iter) - 1) >> PAGE_CACHE_SHIFT;
+	end = (pos + iov_iter_count(iter) - 1) >> PAGE_SHIFT;
 
 	inode_lock(inode);
 
@@ -1013,7 +1013,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 
 	if (mapping->nrpages) {
 		result = invalidate_inode_pages2_range(mapping,
-					pos >> PAGE_CACHE_SHIFT, end);
+					pos >> PAGE_SHIFT, end);
 		if (result)
 			goto out_unlock;
 	}
@@ -1042,7 +1042,7 @@ ssize_t nfs_file_direct_write(struct kiocb *iocb, struct iov_iter *iter)
 
 	if (mapping->nrpages) {
 		invalidate_inode_pages2_range(mapping,
-					      pos >> PAGE_CACHE_SHIFT, end);
+					      pos >> PAGE_SHIFT, end);
 	}
 
 	inode_unlock(inode);
diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 748bb813b8ec..1ef3ac728ff4 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -318,7 +318,7 @@ static int nfs_want_read_modify_write(struct file *file, struct page *page,
 			loff_t pos, unsigned len)
 {
 	unsigned int pglen = nfs_page_length(page);
-	unsigned int offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned int offset = pos & (PAGE_SIZE - 1);
 	unsigned int end = offset + len;
 
 	if (pnfs_ld_read_whole_page(file->f_mapping->host)) {
@@ -349,7 +349,7 @@ static int nfs_write_begin(struct file *file, struct address_space *mapping,
 			struct page **pagep, void **fsdata)
 {
 	int ret;
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 	struct page *page;
 	int once_thru = 0;
 
@@ -378,12 +378,12 @@ start:
 	ret = nfs_flush_incompatible(file, page);
 	if (ret) {
 		unlock_page(page);
-		page_cache_release(page);
+		put_page(page);
 	} else if (!once_thru &&
 		   nfs_want_read_modify_write(file, page, pos, len)) {
 		once_thru = 1;
 		ret = nfs_readpage(file, page);
-		page_cache_release(page);
+		put_page(page);
 		if (!ret)
 			goto start;
 	}
@@ -394,7 +394,7 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 			loff_t pos, unsigned len, unsigned copied,
 			struct page *page, void *fsdata)
 {
-	unsigned offset = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned offset = pos & (PAGE_SIZE - 1);
 	struct nfs_open_context *ctx = nfs_file_open_context(file);
 	int status;
 
@@ -411,20 +411,20 @@ static int nfs_write_end(struct file *file, struct address_space *mapping,
 
 		if (pglen == 0) {
 			zero_user_segments(page, 0, offset,
-					end, PAGE_CACHE_SIZE);
+					end, PAGE_SIZE);
 			SetPageUptodate(page);
 		} else if (end >= pglen) {
-			zero_user_segment(page, end, PAGE_CACHE_SIZE);
+			zero_user_segment(page, end, PAGE_SIZE);
 			if (offset == 0)
 				SetPageUptodate(page);
 		} else
-			zero_user_segment(page, pglen, PAGE_CACHE_SIZE);
+			zero_user_segment(page, pglen, PAGE_SIZE);
 	}
 
 	status = nfs_updatepage(file, page, offset, copied);
 
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	if (status < 0)
 		return status;
@@ -452,7 +452,7 @@ static void nfs_invalidate_page(struct page *page, unsigned int offset,
 	dfprintk(PAGECACHE, "NFS: invalidate_page(%p, %u, %u)\n",
 		 page, offset, length);
 
-	if (offset != 0 || length < PAGE_CACHE_SIZE)
+	if (offset != 0 || length < PAGE_SIZE)
 		return;
 	/* Cancel any unstarted writes on this page */
 	nfs_wb_page_cancel(page_file_mapping(page)->host, page);
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 9a547aa3ec8e..dd822c9a052d 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -642,11 +642,11 @@ unsigned int nfs_page_length(struct page *page)
 
 	if (i_size > 0) {
 		pgoff_t page_index = page_file_index(page);
-		pgoff_t end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+		pgoff_t end_index = (i_size - 1) >> PAGE_SHIFT;
 		if (page_index < end_index)
-			return PAGE_CACHE_SIZE;
+			return PAGE_SIZE;
 		if (page_index == end_index)
-			return ((i_size - 1) & ~PAGE_CACHE_MASK) + 1;
+			return ((i_size - 1) & ~PAGE_MASK) + 1;
 	}
 	return 0;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e4441216804..88474a4fc669 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -5001,7 +5001,7 @@ static int decode_space_limit(struct xdr_stream *xdr,
 		blocksize = be32_to_cpup(p);
 		maxsize = (uint64_t)nblocks * (uint64_t)blocksize;
 	}
-	maxsize >>= PAGE_CACHE_SHIFT;
+	maxsize >>= PAGE_SHIFT;
 	*pagemod_limit = min_t(u64, maxsize, ULONG_MAX);
 	return 0;
 out_overflow:
diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
index 9aebffb40505..049c1b1f2932 100644
--- a/fs/nfs/objlayout/objio_osd.c
+++ b/fs/nfs/objlayout/objio_osd.c
@@ -486,7 +486,7 @@ static void __r4w_put_page(void *priv, struct page *page)
 	dprintk("%s: index=0x%lx\n", __func__,
 		(page == ZERO_PAGE(0)) ? -1UL : page->index);
 	if (ZERO_PAGE(0) != page)
-		page_cache_release(page);
+		put_page(page);
 	return;
 }
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 8ce4f61cbaa5..1f6db4231057 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -342,7 +342,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
 	req->wb_index	= page_file_index(page);
-	page_cache_get(page);
+	get_page(page);
 	req->wb_offset  = offset;
 	req->wb_pgbase	= offset;
 	req->wb_bytes   = count;
@@ -392,7 +392,7 @@ static void nfs_clear_request(struct nfs_page *req)
 	struct nfs_lock_context *l_ctx = req->wb_lock_context;
 
 	if (page != NULL) {
-		page_cache_release(page);
+		put_page(page);
 		req->wb_page = NULL;
 	}
 	if (l_ctx != NULL) {
@@ -904,7 +904,7 @@ static bool nfs_can_coalesce_requests(struct nfs_page *prev,
 				return false;
 		} else {
 			if (req->wb_pgbase != 0 ||
-			    prev->wb_pgbase + prev->wb_bytes != PAGE_CACHE_SIZE)
+			    prev->wb_pgbase + prev->wb_bytes != PAGE_SIZE)
 				return false;
 		}
 	}
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 2fa483e6dbe2..89a5ef4df08a 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -841,7 +841,7 @@ send_layoutget(struct pnfs_layout_hdr *lo,
 
 		i_size = i_size_read(ino);
 
-		lgp->args.minlength = PAGE_CACHE_SIZE;
+		lgp->args.minlength = PAGE_SIZE;
 		if (lgp->args.minlength > range->length)
 			lgp->args.minlength = range->length;
 		if (range->iomode == IOMODE_READ) {
@@ -1618,13 +1618,13 @@ lookup_again:
 		spin_unlock(&clp->cl_lock);
 	}
 
-	pg_offset = arg.offset & ~PAGE_CACHE_MASK;
+	pg_offset = arg.offset & ~PAGE_MASK;
 	if (pg_offset) {
 		arg.offset -= pg_offset;
 		arg.length += pg_offset;
 	}
 	if (arg.length != NFS4_MAX_UINT64)
-		arg.length = PAGE_CACHE_ALIGN(arg.length);
+		arg.length = PAGE_ALIGN(arg.length);
 
 	lseg = send_layoutget(lo, ctx, &arg, gfp_flags);
 	atomic_dec(&lo->plh_outstanding);
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index eb31e23e7def..6776d7a7839e 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -46,7 +46,7 @@ static void nfs_readhdr_free(struct nfs_pgio_header *rhdr)
 static
 int nfs_return_empty_page(struct page *page)
 {
-	zero_user(page, 0, PAGE_CACHE_SIZE);
+	zero_user(page, 0, PAGE_SIZE);
 	SetPageUptodate(page);
 	unlock_page(page);
 	return 0;
@@ -118,8 +118,8 @@ int nfs_readpage_async(struct nfs_open_context *ctx, struct inode *inode,
 		unlock_page(page);
 		return PTR_ERR(new);
 	}
-	if (len < PAGE_CACHE_SIZE)
-		zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	if (len < PAGE_SIZE)
+		zero_user_segment(page, len, PAGE_SIZE);
 
 	nfs_pageio_init_read(&pgio, inode, false,
 			     &nfs_async_read_completion_ops);
@@ -295,7 +295,7 @@ int nfs_readpage(struct file *file, struct page *page)
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_CACHE_SIZE, page_file_index(page));
+		page, PAGE_SIZE, page_file_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
@@ -361,8 +361,8 @@ readpage_async_filler(void *data, struct page *page)
 	if (IS_ERR(new))
 		goto out_error;
 
-	if (len < PAGE_CACHE_SIZE)
-		zero_user_segment(page, len, PAGE_CACHE_SIZE);
+	if (len < PAGE_SIZE)
+		zero_user_segment(page, len, PAGE_SIZE);
 	if (!nfs_pageio_add_request(desc->pgio, new)) {
 		nfs_list_remove_request(new);
 		nfs_readpage_release(new);
@@ -424,8 +424,8 @@ int nfs_readpages(struct file *filp, struct address_space *mapping,
 
 	pgm = &pgio.pg_mirrors[0];
 	NFS_I(inode)->read_io += pgm->pg_bytes_written;
-	npages = (pgm->pg_bytes_written + PAGE_CACHE_SIZE - 1) >>
-		 PAGE_CACHE_SHIFT;
+	npages = (pgm->pg_bytes_written + PAGE_SIZE - 1) >>
+		 PAGE_SHIFT;
 	nfs_add_stats(inode, NFSIOS_READPAGES, npages);
 read_complete:
 	put_nfs_open_context(desc.ctx);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 5754835a2886..5f4fd53e5764 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -150,7 +150,7 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
-	end_index = (i_size - 1) >> PAGE_CACHE_SHIFT;
+	end_index = (i_size - 1) >> PAGE_SHIFT;
 	if (i_size > 0 && page_file_index(page) < end_index)
 		goto out;
 	end = page_file_offset(page) + ((loff_t)offset+count);
@@ -1942,7 +1942,7 @@ int nfs_wb_page_cancel(struct inode *inode, struct page *page)
 int nfs_wb_single_page(struct inode *inode, struct page *page, bool launder)
 {
 	loff_t range_start = page_file_offset(page);
-	loff_t range_end = range_start + (loff_t)(PAGE_CACHE_SIZE - 1);
+	loff_t range_end = range_start + (loff_t)(PAGE_SIZE - 1);
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_ALL,
 		.nr_to_write = 0,
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index f2f650f136ee..957049f72290 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -41,8 +41,8 @@ struct nfs_page {
 	struct page		*wb_page;	/* page to read in/write out */
 	struct nfs_open_context	*wb_context;	/* File state context info */
 	struct nfs_lock_context	*wb_lock_context;	/* lock context info */
-	pgoff_t			wb_index;	/* Offset >> PAGE_CACHE_SHIFT */
-	unsigned int		wb_offset,	/* Offset & ~PAGE_CACHE_MASK */
+	pgoff_t			wb_index;	/* Offset >> PAGE_SHIFT */
+	unsigned int		wb_offset,	/* Offset & ~PAGE_MASK */
 				wb_pgbase,	/* Start of page data */
 				wb_bytes;	/* Length of request */
 	struct kref		wb_kref;	/* reference count */
@@ -184,7 +184,7 @@ nfs_list_entry(struct list_head *head)
 static inline
 loff_t req_offset(struct nfs_page *req)
 {
-	return (((loff_t)req->wb_index) << PAGE_CACHE_SHIFT) + req->wb_offset;
+	return (((loff_t)req->wb_index) << PAGE_SHIFT) + req->wb_offset;
 }
 
 #endif /* _LINUX_NFS_PAGE_H */
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index cc0fc712bb82..7ca44fb5b675 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -129,7 +129,7 @@ static inline void svc_get(struct svc_serv *serv)
  *
  * These happen to all be powers of 2, which is not strictly
  * necessary but helps enforce the real limitation, which is
- * that they should be multiples of PAGE_CACHE_SIZE.
+ * that they should be multiples of PAGE_SIZE.
  *
  * For UDP transports, a block plus NFS,RPC, and UDP headers
  * has to fit into the IP datagram limit of 64K.  The largest
diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index cabf586f47d7..a9fc819429ef 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1728,8 +1728,8 @@ alloc_enc_pages(struct rpc_rqst *rqstp)
 		return 0;
 	}
 
-	first = snd_buf->page_base >> PAGE_CACHE_SHIFT;
-	last = (snd_buf->page_base + snd_buf->page_len - 1) >> PAGE_CACHE_SHIFT;
+	first = snd_buf->page_base >> PAGE_SHIFT;
+	last = (snd_buf->page_base + snd_buf->page_len - 1) >> PAGE_SHIFT;
 	rqstp->rq_enc_pages_num = last - first + 1 + 1;
 	rqstp->rq_enc_pages
 		= kmalloc(rqstp->rq_enc_pages_num * sizeof(struct page *),
@@ -1775,10 +1775,10 @@ gss_wrap_req_priv(struct rpc_cred *cred, struct gss_cl_ctx *ctx,
 	status = alloc_enc_pages(rqstp);
 	if (status)
 		return status;
-	first = snd_buf->page_base >> PAGE_CACHE_SHIFT;
+	first = snd_buf->page_base >> PAGE_SHIFT;
 	inpages = snd_buf->pages + first;
 	snd_buf->pages = rqstp->rq_enc_pages;
-	snd_buf->page_base -= first << PAGE_CACHE_SHIFT;
+	snd_buf->page_base -= first << PAGE_SHIFT;
 	/*
 	 * Give the tail its own page, in case we need extra space in the
 	 * head when wrapping:
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index d94a8e1e9f05..045e11ecd332 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -465,7 +465,7 @@ encryptor(struct scatterlist *sg, void *data)
 	page_pos = desc->pos - outbuf->head[0].iov_len;
 	if (page_pos >= 0 && page_pos < outbuf->page_len) {
 		/* pages are not in place: */
-		int i = (page_pos + outbuf->page_base) >> PAGE_CACHE_SHIFT;
+		int i = (page_pos + outbuf->page_base) >> PAGE_SHIFT;
 		in_page = desc->pages[i];
 	} else {
 		in_page = sg_page(sg);
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_krb5_wrap.c
index 765088e4ad84..a737c2da0837 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -79,9 +79,9 @@ gss_krb5_remove_padding(struct xdr_buf *buf, int blocksize)
 		len -= buf->head[0].iov_len;
 	if (len <= buf->page_len) {
 		unsigned int last = (buf->page_base + len - 1)
-					>>PAGE_CACHE_SHIFT;
+					>>PAGE_SHIFT;
 		unsigned int offset = (buf->page_base + len - 1)
-					& (PAGE_CACHE_SIZE - 1);
+					& (PAGE_SIZE - 1);
 		ptr = kmap_atomic(buf->pages[last]);
 		pad = *(ptr + offset);
 		kunmap_atomic(ptr);
diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 273bc3a35425..e59a6d952b57 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -881,7 +881,7 @@ static ssize_t cache_downcall(struct address_space *mapping,
 	char *kaddr;
 	ssize_t ret = -ENOMEM;
 
-	if (count >= PAGE_CACHE_SIZE)
+	if (count >= PAGE_SIZE)
 		goto out_slow;
 
 	page = find_or_create_page(mapping, 0, GFP_KERNEL);
@@ -892,7 +892,7 @@ static ssize_t cache_downcall(struct address_space *mapping,
 	ret = cache_do_downcall(kaddr, buf, count, cd);
 	kunmap(page);
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 	return ret;
 out_slow:
 	return cache_slow_downcall(buf, count, cd);
diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 31789ef3e614..fc48eca21fd2 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -1390,8 +1390,8 @@ rpc_fill_super(struct super_block *sb, void *data, int silent)
 	struct sunrpc_net *sn = net_generic(net, sunrpc_net_id);
 	int err;
 
-	sb->s_blocksize = PAGE_CACHE_SIZE;
-	sb->s_blocksize_bits = PAGE_CACHE_SHIFT;
+	sb->s_blocksize = PAGE_SIZE;
+	sb->s_blocksize_bits = PAGE_SHIFT;
 	sb->s_magic = RPCAUTH_GSSMAGIC;
 	sb->s_op = &s_ops;
 	sb->s_d_op = &simple_dentry_operations;
diff --git a/net/sunrpc/socklib.c b/net/sunrpc/socklib.c
index 2df87f78e518..de70c78025d7 100644
--- a/net/sunrpc/socklib.c
+++ b/net/sunrpc/socklib.c
@@ -96,8 +96,8 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 	if (base || xdr->page_base) {
 		pglen -= base;
 		base += xdr->page_base;
-		ppage += base >> PAGE_CACHE_SHIFT;
-		base &= ~PAGE_CACHE_MASK;
+		ppage += base >> PAGE_SHIFT;
+		base &= ~PAGE_MASK;
 	}
 	do {
 		char *kaddr;
@@ -113,7 +113,7 @@ ssize_t xdr_partial_copy_from_skb(struct xdr_buf *xdr, unsigned int base, struct
 			}
 		}
 
-		len = PAGE_CACHE_SIZE;
+		len = PAGE_SIZE;
 		kaddr = kmap_atomic(*ppage);
 		if (base) {
 			len -= base;
diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
index 4439ac4c1b53..6bdb3865212d 100644
--- a/net/sunrpc/xdr.c
+++ b/net/sunrpc/xdr.c
@@ -164,7 +164,7 @@ EXPORT_SYMBOL_GPL(xdr_inline_pages);
  * Note: the addresses pgto_base and pgfrom_base are both calculated in
  *       the same way:
  *            if a memory area starts at byte 'base' in page 'pages[i]',
- *            then its address is given as (i << PAGE_CACHE_SHIFT) + base
+ *            then its address is given as (i << PAGE_SHIFT) + base
  * Also note: pgfrom_base must be < pgto_base, but the memory areas
  * 	they point to may overlap.
  */
@@ -181,20 +181,20 @@ _shift_data_right_pages(struct page **pages, size_t pgto_base,
 	pgto_base += len;
 	pgfrom_base += len;
 
-	pgto = pages + (pgto_base >> PAGE_CACHE_SHIFT);
-	pgfrom = pages + (pgfrom_base >> PAGE_CACHE_SHIFT);
+	pgto = pages + (pgto_base >> PAGE_SHIFT);
+	pgfrom = pages + (pgfrom_base >> PAGE_SHIFT);
 
-	pgto_base &= ~PAGE_CACHE_MASK;
-	pgfrom_base &= ~PAGE_CACHE_MASK;
+	pgto_base &= ~PAGE_MASK;
+	pgfrom_base &= ~PAGE_MASK;
 
 	do {
 		/* Are any pointers crossing a page boundary? */
 		if (pgto_base == 0) {
-			pgto_base = PAGE_CACHE_SIZE;
+			pgto_base = PAGE_SIZE;
 			pgto--;
 		}
 		if (pgfrom_base == 0) {
-			pgfrom_base = PAGE_CACHE_SIZE;
+			pgfrom_base = PAGE_SIZE;
 			pgfrom--;
 		}
 
@@ -236,11 +236,11 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 	char *vto;
 	size_t copy;
 
-	pgto = pages + (pgbase >> PAGE_CACHE_SHIFT);
-	pgbase &= ~PAGE_CACHE_MASK;
+	pgto = pages + (pgbase >> PAGE_SHIFT);
+	pgbase &= ~PAGE_MASK;
 
 	for (;;) {
-		copy = PAGE_CACHE_SIZE - pgbase;
+		copy = PAGE_SIZE - pgbase;
 		if (copy > len)
 			copy = len;
 
@@ -253,7 +253,7 @@ _copy_to_pages(struct page **pages, size_t pgbase, const char *p, size_t len)
 			break;
 
 		pgbase += copy;
-		if (pgbase == PAGE_CACHE_SIZE) {
+		if (pgbase == PAGE_SIZE) {
 			flush_dcache_page(*pgto);
 			pgbase = 0;
 			pgto++;
@@ -280,11 +280,11 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 	char *vfrom;
 	size_t copy;
 
-	pgfrom = pages + (pgbase >> PAGE_CACHE_SHIFT);
-	pgbase &= ~PAGE_CACHE_MASK;
+	pgfrom = pages + (pgbase >> PAGE_SHIFT);
+	pgbase &= ~PAGE_MASK;
 
 	do {
-		copy = PAGE_CACHE_SIZE - pgbase;
+		copy = PAGE_SIZE - pgbase;
 		if (copy > len)
 			copy = len;
 
@@ -293,7 +293,7 @@ _copy_from_pages(char *p, struct page **pages, size_t pgbase, size_t len)
 		kunmap_atomic(vfrom);
 
 		pgbase += copy;
-		if (pgbase == PAGE_CACHE_SIZE) {
+		if (pgbase == PAGE_SIZE) {
 			pgbase = 0;
 			pgfrom++;
 		}
@@ -1038,8 +1038,8 @@ xdr_buf_subsegment(struct xdr_buf *buf, struct xdr_buf *subbuf,
 	if (base < buf->page_len) {
 		subbuf->page_len = min(buf->page_len - base, len);
 		base += buf->page_base;
-		subbuf->page_base = base & ~PAGE_CACHE_MASK;
-		subbuf->pages = &buf->pages[base >> PAGE_CACHE_SHIFT];
+		subbuf->page_base = base & ~PAGE_MASK;
+		subbuf->pages = &buf->pages[base >> PAGE_SHIFT];
 		len -= subbuf->page_len;
 		base = 0;
 	} else {
@@ -1297,9 +1297,9 @@ xdr_xcode_array2(struct xdr_buf *buf, unsigned int base,
 		todo -= avail_here;
 
 		base += buf->page_base;
-		ppages = buf->pages + (base >> PAGE_CACHE_SHIFT);
-		base &= ~PAGE_CACHE_MASK;
-		avail_page = min_t(unsigned int, PAGE_CACHE_SIZE - base,
+		ppages = buf->pages + (base >> PAGE_SHIFT);
+		base &= ~PAGE_MASK;
+		avail_page = min_t(unsigned int, PAGE_SIZE - base,
 					avail_here);
 		c = kmap(*ppages) + base;
 
@@ -1383,7 +1383,7 @@ xdr_xcode_array2(struct xdr_buf *buf, unsigned int base,
 			}
 
 			avail_page = min(avail_here,
-				 (unsigned int) PAGE_CACHE_SIZE);
+				 (unsigned int) PAGE_SIZE);
 		}
 		base = buf->page_len;  /* align to start of tail */
 	}
@@ -1479,9 +1479,9 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 		if (page_len > len)
 			page_len = len;
 		len -= page_len;
-		page_offset = (offset + buf->page_base) & (PAGE_CACHE_SIZE - 1);
-		i = (offset + buf->page_base) >> PAGE_CACHE_SHIFT;
-		thislen = PAGE_CACHE_SIZE - page_offset;
+		page_offset = (offset + buf->page_base) & (PAGE_SIZE - 1);
+		i = (offset + buf->page_base) >> PAGE_SHIFT;
+		thislen = PAGE_SIZE - page_offset;
 		do {
 			if (thislen > page_len)
 				thislen = page_len;
@@ -1492,7 +1492,7 @@ xdr_process_buf(struct xdr_buf *buf, unsigned int offset, unsigned int len,
 			page_len -= thislen;
 			i++;
 			page_offset = 0;
-			thislen = PAGE_CACHE_SIZE;
+			thislen = PAGE_SIZE;
 		} while (page_len != 0);
 		offset = 0;
 	}
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
