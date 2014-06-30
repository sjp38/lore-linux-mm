Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f178.google.com (mail-pd0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 4144A6B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:09:42 -0400 (EDT)
Received: by mail-pd0-f178.google.com with SMTP id r10so8867764pdi.37
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:09:41 -0700 (PDT)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id ra6si24529277pab.44.2014.06.30.14.09.40
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 14:09:41 -0700 (PDT)
Received: by mail-pd0-f179.google.com with SMTP id w10so8832057pde.24
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:09:40 -0700 (PDT)
Date: Mon, 30 Jun 2014 14:08:11 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/2] shmem: fix init_page_accessed use to stop !PageLRU bug
Message-ID: <alpine.LSU.2.11.1406301405230.1096@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Under shmem swapping load, I sometimes hit the VM_BUG_ON_PAGE(!PageLRU)
in isolate_lru_pages() at mm/vmscan.c:1281!

Commit 2457aec63745 ("mm: non-atomically mark page accessed during page
cache allocation where possible") looks like interrupted work-in-progress.

mm/filemap.c's call to init_page_accessed() is fine, but not mm/shmem.c's
- shmem_write_begin() is clearly wrong to use it after shmem_getpage(),
when the page is always visible in radix_tree, and often already on LRU.

Revert change to shmem_write_begin(), and use init_page_accessed() or
mark_page_accessed() appropriately for SGP_WRITE in shmem_getpage_gfp().

SGP_WRITE also covers shmem_symlink(), which did not mark_page_accessed()
before; but since many other filesystems use [__]page_symlink(), which did
and does mark the page accessed, consider this as rectifying an oversight.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/shmem.c |   15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

--- 3.16-rc3/mm/shmem.c	2014-06-29 15:22:10.592003936 -0700
+++ linux/mm/shmem.c	2014-06-30 12:15:52.204093217 -0700
@@ -1029,6 +1029,9 @@ repeat:
 		goto failed;
 	}
 
+	if (page && sgp == SGP_WRITE)
+		mark_page_accessed(page);
+
 	/* fallocated page? */
 	if (page && !PageUptodate(page)) {
 		if (sgp != SGP_READ)
@@ -1110,6 +1113,9 @@ repeat:
 		shmem_recalc_inode(inode);
 		spin_unlock(&info->lock);
 
+		if (sgp == SGP_WRITE)
+			mark_page_accessed(page);
+
 		delete_from_swap_cache(page);
 		set_page_dirty(page);
 		swap_free(swap);
@@ -1136,6 +1142,9 @@ repeat:
 
 		__SetPageSwapBacked(page);
 		__set_page_locked(page);
+		if (sgp == SGP_WRITE)
+			init_page_accessed(page);
+
 		error = mem_cgroup_charge_file(page, current->mm,
 						gfp & GFP_RECLAIM_MASK);
 		if (error)
@@ -1412,13 +1421,9 @@ shmem_write_begin(struct file *file, str
 			loff_t pos, unsigned len, unsigned flags,
 			struct page **pagep, void **fsdata)
 {
-	int ret;
 	struct inode *inode = mapping->host;
 	pgoff_t index = pos >> PAGE_CACHE_SHIFT;
-	ret = shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
-	if (ret == 0 && *pagep)
-		init_page_accessed(*pagep);
-	return ret;
+	return shmem_getpage(inode, index, pagep, SGP_WRITE, NULL);
 }
 
 static int

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
