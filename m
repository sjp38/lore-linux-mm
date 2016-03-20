Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 1769482F60
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:48:29 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id n5so237556531pfn.2
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:48:29 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id wb2si13830644pab.213.2016.03.20.11.41.49
        for <linux-mm@kvack.org>;
        Sun, 20 Mar 2016 11:41:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 41/71] hostfs: get rid of PAGE_CACHE_* and page_cache_{get,release} macros
Date: Sun, 20 Mar 2016 21:40:48 +0300
Message-Id: <1458499278-1516-42-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1458499278-1516-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Matthew Wilcox <willy@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jeff Dike <jdike@addtoit.com>, Richard Weinberger <richard@nod.at>

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
Cc: Jeff Dike <jdike@addtoit.com>
Cc: Richard Weinberger <richard@nod.at>
---
 fs/hostfs/hostfs_kern.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/fs/hostfs/hostfs_kern.c b/fs/hostfs/hostfs_kern.c
index d1abbee281d1..7016653f3e41 100644
--- a/fs/hostfs/hostfs_kern.c
+++ b/fs/hostfs/hostfs_kern.c
@@ -410,12 +410,12 @@ static int hostfs_writepage(struct page *page, struct writeback_control *wbc)
 	struct inode *inode = mapping->host;
 	char *buffer;
 	loff_t base = page_offset(page);
-	int count = PAGE_CACHE_SIZE;
-	int end_index = inode->i_size >> PAGE_CACHE_SHIFT;
+	int count = PAGE_SIZE;
+	int end_index = inode->i_size >> PAGE_SHIFT;
 	int err;
 
 	if (page->index >= end_index)
-		count = inode->i_size & (PAGE_CACHE_SIZE-1);
+		count = inode->i_size & (PAGE_SIZE-1);
 
 	buffer = kmap(page);
 
@@ -447,7 +447,7 @@ static int hostfs_readpage(struct file *file, struct page *page)
 
 	buffer = kmap(page);
 	bytes_read = read_file(FILE_HOSTFS_I(file)->fd, &start, buffer,
-			PAGE_CACHE_SIZE);
+			PAGE_SIZE);
 	if (bytes_read < 0) {
 		ClearPageUptodate(page);
 		SetPageError(page);
@@ -455,7 +455,7 @@ static int hostfs_readpage(struct file *file, struct page *page)
 		goto out;
 	}
 
-	memset(buffer + bytes_read, 0, PAGE_CACHE_SIZE - bytes_read);
+	memset(buffer + bytes_read, 0, PAGE_SIZE - bytes_read);
 
 	ClearPageError(page);
 	SetPageUptodate(page);
@@ -471,7 +471,7 @@ static int hostfs_write_begin(struct file *file, struct address_space *mapping,
 			      loff_t pos, unsigned len, unsigned flags,
 			      struct page **pagep, void **fsdata)
 {
-	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
+	pgoff_t index = pos >> PAGE_SHIFT;
 
 	*pagep = grab_cache_page_write_begin(mapping, index, flags);
 	if (!*pagep)
@@ -485,14 +485,14 @@ static int hostfs_write_end(struct file *file, struct address_space *mapping,
 {
 	struct inode *inode = mapping->host;
 	void *buffer;
-	unsigned from = pos & (PAGE_CACHE_SIZE - 1);
+	unsigned from = pos & (PAGE_SIZE - 1);
 	int err;
 
 	buffer = kmap(page);
 	err = write_file(FILE_HOSTFS_I(file)->fd, &pos, buffer + from, copied);
 	kunmap(page);
 
-	if (!PageUptodate(page) && err == PAGE_CACHE_SIZE)
+	if (!PageUptodate(page) && err == PAGE_SIZE)
 		SetPageUptodate(page);
 
 	/*
@@ -502,7 +502,7 @@ static int hostfs_write_end(struct file *file, struct address_space *mapping,
 	if (err > 0 && (pos > inode->i_size))
 		inode->i_size = pos;
 	unlock_page(page);
-	page_cache_release(page);
+	put_page(page);
 
 	return err;
 }
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
