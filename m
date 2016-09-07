Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id C57746B0038
	for <linux-mm@kvack.org>; Wed,  7 Sep 2016 19:32:55 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id ag5so65302077pad.2
        for <linux-mm@kvack.org>; Wed, 07 Sep 2016 16:32:55 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id m5si42224904pfm.117.2016.09.07.10.50.58
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 07 Sep 2016 10:50:58 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH 2/2] mm: Remove page_file_index
Date: Wed,  7 Sep 2016 10:50:49 -0700
Message-Id: <1473270649-27229-2-git-send-email-ying.huang@intel.com>
In-Reply-To: <1473270649-27229-1-git-send-email-ying.huang@intel.com>
References: <1473270649-27229-1-git-send-email-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: tim.c.chen@intel.com, dave.hansen@intel.com, andi.kleen@intel.com, aaron.lu@intel.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, Trond Myklebust <trond.myklebust@primarydata.com>, Anna Schumaker <anna.schumaker@netapp.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Dan Williams <dan.j.williams@intel.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Eric Dumazet <edumazet@google.com>

From: Huang Ying <ying.huang@intel.com>

After using the offset of the swap entry as the key of the swap cache,
the page_index() becomes exactly same as page_file_index().  So the
page_file_index() is removed and the callers are changed to use
page_index() instead.

Cc: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
---
 fs/nfs/internal.h       |  6 +++---
 fs/nfs/pagelist.c       |  2 +-
 fs/nfs/read.c           |  2 +-
 fs/nfs/write.c          |  4 ++--
 include/linux/mm.h      | 12 ------------
 include/linux/pagemap.h |  2 +-
 6 files changed, 8 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 48d1adf..bed73db 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -682,11 +682,11 @@ unsigned int nfs_page_length(struct page *page)
 	loff_t i_size = i_size_read(page_file_mapping(page)->host);
 
 	if (i_size > 0) {
-		pgoff_t page_index = page_file_index(page);
+		pgoff_t index = page_index(page);
 		pgoff_t end_index = (i_size - 1) >> PAGE_SHIFT;
-		if (page_index < end_index)
+		if (index < end_index)
 			return PAGE_SIZE;
-		if (page_index == end_index)
+		if (index == end_index)
 			return ((i_size - 1) & ~PAGE_MASK) + 1;
 	}
 	return 0;
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 174dd4c..965db47 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -342,7 +342,7 @@ nfs_create_request(struct nfs_open_context *ctx, struct page *page,
 	 * update_nfs_request below if the region is not locked. */
 	req->wb_page    = page;
 	if (page) {
-		req->wb_index = page_file_index(page);
+		req->wb_index = page_index(page);
 		get_page(page);
 	}
 	req->wb_offset  = offset;
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index 572e5b3..defc923 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -295,7 +295,7 @@ int nfs_readpage(struct file *file, struct page *page)
 	int		error;
 
 	dprintk("NFS: nfs_readpage (%p %ld@%lu)\n",
-		page, PAGE_SIZE, page_file_index(page));
+		page, PAGE_SIZE, page_index(page));
 	nfs_inc_stats(inode, NFSIOS_VFSREADPAGE);
 	nfs_add_stats(inode, NFSIOS_READPAGES, 1);
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 3a6724c..5321183 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -151,7 +151,7 @@ static void nfs_grow_file(struct page *page, unsigned int offset, unsigned int c
 	spin_lock(&inode->i_lock);
 	i_size = i_size_read(inode);
 	end_index = (i_size - 1) >> PAGE_SHIFT;
-	if (i_size > 0 && page_file_index(page) < end_index)
+	if (i_size > 0 && page_index(page) < end_index)
 		goto out;
 	end = page_file_offset(page) + ((loff_t)offset+count);
 	if (i_size >= end)
@@ -603,7 +603,7 @@ static int nfs_do_writepage(struct page *page, struct writeback_control *wbc,
 {
 	int ret;
 
-	nfs_pageio_cond_complete(pgio, page_file_index(page));
+	nfs_pageio_cond_complete(pgio, page_index(page));
 	ret = nfs_page_async_flush(pgio, page, wbc->sync_mode == WB_SYNC_NONE,
 				   launder);
 	if (ret == -EAGAIN) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index b5709fa..5817eb9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1061,18 +1061,6 @@ static inline pgoff_t page_index(struct page *page)
 	return page->index;
 }
 
-/*
- * Return the file index of the page. Regular pagecache pages use ->index
- * whereas swapcache pages use swp_offset(->private)
- */
-static inline pgoff_t page_file_index(struct page *page)
-{
-	if (unlikely(PageSwapCache(page)))
-		return __page_file_index(page);
-
-	return page->index;
-}
-
 bool page_mapped(struct page *page);
 struct address_space *page_mapping(struct page *page);
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 08937bd..6799d10 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -410,7 +410,7 @@ static inline loff_t page_offset(struct page *page)
 
 static inline loff_t page_file_offset(struct page *page)
 {
-	return ((loff_t)page_file_index(page)) << PAGE_SHIFT;
+	return ((loff_t)page_index(page)) << PAGE_SHIFT;
 }
 
 extern pgoff_t linear_hugepage_index(struct vm_area_struct *vma,
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
