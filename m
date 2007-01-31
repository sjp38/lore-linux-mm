Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id l0VMdP1e009709
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 22:39:25 GMT
Received: from wr-out-0506.google.com (wri57.prod.google.com [10.54.9.57])
	by spaceape10.eur.corp.google.com with ESMTP id l0VMcneZ023807
	for <linux-mm@kvack.org>; Wed, 31 Jan 2007 22:39:20 GMT
Received: by wr-out-0506.google.com with SMTP id 57so343124wri
        for <linux-mm@kvack.org>; Wed, 31 Jan 2007 14:39:20 -0800 (PST)
Message-ID: <b040c32a0701311439y2e0ba4e6qcc25bc4d4ab8f7e4@mail.gmail.com>
Date: Wed, 31 Jan 2007 14:39:19 -0800
From: "Ken Chen" <kenchen@google.com>
Subject: [patch] convert ramfs to use __set_page_dirty_no_writeback
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

As pointed out by Hugh, ramfs would also benefit from using the new
set_page_dirty aop method for memory backed file systems.

Signed-off-by: Ken Chen <kenchen@google.com>

---
Hugh, I chickened out on swap_aops() as I'd rather not to muck with code
that I'm not familiar with.


--- ./fs/ramfs/file-mmu.c.orig	2007-01-31 13:27:14.000000000 -0800
+++ ./fs/ramfs/file-mmu.c	2007-01-31 13:27:39.000000000 -0800
@@ -31,7 +31,7 @@
 	.readpage	= simple_readpage,
 	.prepare_write	= simple_prepare_write,
 	.commit_write	= simple_commit_write,
-	.set_page_dirty = __set_page_dirty_nobuffers,
+	.set_page_dirty = __set_page_dirty_no_writeback,
 };

 const struct file_operations ramfs_file_operations = {
--- ./fs/ramfs/file-nommu.c.orig	2007-01-31 13:27:27.000000000 -0800
+++ ./fs/ramfs/file-nommu.c	2007-01-31 13:28:21.000000000 -0800
@@ -32,7 +32,7 @@
 	.readpage		= simple_readpage,
 	.prepare_write		= simple_prepare_write,
 	.commit_write		= simple_commit_write,
-	.set_page_dirty = __set_page_dirty_nobuffers,
+	.set_page_dirty		= __set_page_dirty_no_writeback,
 };

 const struct file_operations ramfs_file_operations = {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
