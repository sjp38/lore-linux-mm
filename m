Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id CAA09933
	for <linux-mm@kvack.org>; Sun, 2 Feb 2003 02:56:02 -0800 (PST)
Date: Sun, 2 Feb 2003 02:56:09 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: hugepage patches
Message-Id: <20030202025609.7e20a22c.akpm@digeo.com>
In-Reply-To: <20030131151501.7273a9bf.akpm@digeo.com>
References: <20030131151501.7273a9bf.akpm@digeo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: davem@redhat.com, rohit.seth@intel.com, davidm@napali.hpl.hp.com, anton@samba.org, wli@holomorphy.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

8/4

hugetlbfs cleanups

- Remove quota code.

- Remove extraneous copy-n-paste code from truncate: that's only for
  physically-backed filesystems.

- Whitespace changes.


 hugetlbfs/inode.c |   91 ++++++++----------------------------------------------
 1 files changed, 15 insertions(+), 76 deletions(-)

diff -puN fs/hugetlbfs/inode.c~hugetlbfs-cleanup fs/hugetlbfs/inode.c
--- 25/fs/hugetlbfs/inode.c~hugetlbfs-cleanup	2003-02-02 01:17:07.000000000 -0800
+++ 25-akpm/fs/hugetlbfs/inode.c	2003-02-02 01:17:07.000000000 -0800
@@ -120,12 +120,16 @@ static int hugetlbfs_readpage(struct fil
 	return -EINVAL;
 }
 
-static int hugetlbfs_prepare_write(struct file *file, struct page *page, unsigned offset, unsigned to)
+static int
+hugetlbfs_prepare_write(struct file *file, struct page *page,
+			unsigned offset, unsigned to)
 {
 	return -EINVAL;
 }
 
-static int hugetlbfs_commit_write(struct file *file, struct page *page, unsigned offset, unsigned to)
+static int
+hugetlbfs_commit_write(struct file *file, struct page *page,
+			unsigned offset, unsigned to)
 {
 	return -EINVAL;
 }
@@ -140,28 +144,8 @@ void huge_pagevec_release(struct pagevec
 	pagevec_reinit(pvec);
 }
 
-void truncate_partial_hugepage(struct page *page, unsigned partial)
-{
-	int i;
-	const unsigned piece = partial & (PAGE_SIZE - 1);
-	const unsigned tailstart = PAGE_SIZE - piece;
-	const unsigned whole_pages = partial / PAGE_SIZE;
-	const unsigned last_page_offset = HPAGE_SIZE/PAGE_SIZE - whole_pages;
-
-	for (i = HPAGE_SIZE/PAGE_SIZE - 1; i >= last_page_offset; ++i)
-		memclear_highpage_flush(&page[i], 0, PAGE_SIZE);
-
-	if (!piece)
-		return;
-
-	memclear_highpage_flush(&page[last_page_offset - 1], tailstart, piece);
-}
-
-void truncate_huge_page(struct address_space *mapping, struct page *page)
+void truncate_huge_page(struct page *page)
 {
-	if (page->mapping != mapping)
-		return;
-
 	clear_page_dirty(page);
 	ClearPageUptodate(page);
 	remove_from_page_cache(page);
@@ -170,52 +154,13 @@ void truncate_huge_page(struct address_s
 
 void truncate_hugepages(struct address_space *mapping, loff_t lstart)
 {
-	const pgoff_t start = (lstart + HPAGE_SIZE - 1) >> HPAGE_SHIFT;
-	const unsigned partial = lstart & (HPAGE_SIZE - 1);
+	const pgoff_t start = lstart >> HPAGE_SHIFT;
 	struct pagevec pvec;
 	pgoff_t next;
 	int i;
 
 	pagevec_init(&pvec, 0);
 	next = start;
-
-	while (pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
-		for (i = 0; i < pagevec_count(&pvec); ++i) {
-			struct page *page = pvec.pages[i];
-			pgoff_t page_index = page->index;
-
-			if (page_index > next)
-				next = page_index;
-
-			++next;
-
-			if (TestSetPageLocked(page))
-				continue;
-
-			if (PageWriteback(page)) {
-				unlock_page(page);
-				continue;
-			}
-
-			truncate_huge_page(mapping, page);
-			unlock_page(page);
-		}
-		huge_pagevec_release(&pvec);
-		cond_resched();
-	}
-
-	if (partial) {
-		struct page *page = find_lock_page(mapping, start - 1);
-		if (page) {
-			wait_on_page_writeback(page);
-			truncate_partial_hugepage(page, partial);
-			unlock_page(page);
-			huge_page_release(page);
-		}
-	}
-
-	next = start;
-
 	while (1) {
 		if (!pagevec_lookup(&pvec, mapping, next, PAGEVEC_SIZE)) {
 			if (next == start)
@@ -228,11 +173,10 @@ void truncate_hugepages(struct address_s
 			struct page *page = pvec.pages[i];
 
 			lock_page(page);
-			wait_on_page_writeback(page);
 			if (page->index > next)
 				next = page->index;
 			++next;
-			truncate_huge_page(mapping, page);
+			truncate_huge_page(page);
 			unlock_page(page);
 		}
 		huge_pagevec_release(&pvec);
@@ -363,13 +307,6 @@ static int hugetlbfs_setattr(struct dent
 	error = security_inode_setattr(dentry, attr);
 	if (error)
 		goto out;
-
-	if ((ia_valid & ATTR_UID && attr->ia_uid != inode->i_uid) ||
-	    (ia_valid & ATTR_GID && attr->ia_gid != inode->i_gid))
-		error = DQUOT_TRANSFER(inode, attr) ? -EDQUOT : 0;
-	if (error)
-		goto out;
-
 	if (ia_valid & ATTR_SIZE) {
 		error = -EINVAL;
 		if (!(attr->ia_size & ~HPAGE_MASK))
@@ -401,7 +338,7 @@ hugetlbfs_get_inode(struct super_block *
 		inode->i_blocks = 0;
 		inode->i_rdev = NODEV;
 		inode->i_mapping->a_ops = &hugetlbfs_aops;
-		inode->i_mapping->backing_dev_info = &hugetlbfs_backing_dev_info;
+		inode->i_mapping->backing_dev_info =&hugetlbfs_backing_dev_info;
 		inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
 		switch (mode & S_IFMT) {
 		default:
@@ -444,7 +381,7 @@ hugetlbfs_mknod(struct inode *dir, struc
 	return error;
 }
 
-static int hugetlbfs_mkdir(struct inode * dir, struct dentry * dentry, int mode)
+static int hugetlbfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 {
 	int retval = hugetlbfs_mknod(dir, dentry, mode | S_IFDIR, 0);
 	if (!retval)
@@ -457,7 +394,8 @@ static int hugetlbfs_create(struct inode
 	return hugetlbfs_mknod(dir, dentry, mode | S_IFREG, 0);
 }
 
-static int hugetlbfs_symlink(struct inode * dir, struct dentry *dentry, const char * symname)
+static int
+hugetlbfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
 	struct inode *inode;
 	int error = -ENOSPC;
@@ -518,7 +456,8 @@ static struct super_operations hugetlbfs
 	.drop_inode	= hugetlbfs_drop_inode,
 };
 
-static int hugetlbfs_fill_super(struct super_block * sb, void * data, int silent)
+static int
+hugetlbfs_fill_super(struct super_block * sb, void * data, int silent)
 {
 	struct inode * inode;
 	struct dentry * root;

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
