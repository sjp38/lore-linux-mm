Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 606656B0031
	for <linux-mm@kvack.org>; Wed, 15 Jan 2014 20:25:00 -0500 (EST)
Received: by mail-pa0-f48.google.com with SMTP id kx10so379497pab.35
        for <linux-mm@kvack.org>; Wed, 15 Jan 2014 17:25:00 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id r7si3385921pbk.297.2014.01.15.17.24.58
        for <linux-mm@kvack.org>;
        Wed, 15 Jan 2014 17:24:59 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH v5 01/22] Fix XIP fault vs truncate race
Date: Wed, 15 Jan 2014 20:24:19 -0500
Message-Id: <f146fb2f49911a1cc1edd9025613a88d5a23b1db.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
In-Reply-To: <cover.1389779961.git.matthew.r.wilcox@intel.com>
References: <cover.1389779961.git.matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-ext4@vger.kernel.org
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>

Pagecache faults recheck i_size after taking the page lock to ensure that
the fault didn't race against a truncate.  We don't have a page to lock
in the XIP case, so use the i_mmap_mutex instead.  It is locked in the
truncate path in unmap_mapping_range() after updating i_size.  So while
we hold it in the fault path, we are guaranteed that either i_size has
already been updated in the truncate path, or that the truncate will
subsequently call zap_page_range_single() and so remove the mapping we
have just inserted.

There is a window of time in which i_size has been reduced and the
thread has a mapping to a page which will be removed from the file,
but this is harmless as the page will not be allocated to a different
purpose before the thread's access to it is revoked.

Signed-off-by: Matthew Wilcox <matthew.r.wilcox@intel.com>
---
 mm/filemap_xip.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/mm/filemap_xip.c b/mm/filemap_xip.c
index d8d9fe3..c8d23e9 100644
--- a/mm/filemap_xip.c
+++ b/mm/filemap_xip.c
@@ -260,8 +260,17 @@ again:
 		__xip_unmap(mapping, vmf->pgoff);
 
 found:
+		/* We must recheck i_size under i_mmap_mutex */
+		mutex_lock(&mapping->i_mmap_mutex);
+		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
+							PAGE_CACHE_SHIFT;
+		if (unlikely(vmf->pgoff >= size)) {
+			mutex_unlock(&mapping->i_mmap_mutex);
+			return VM_FAULT_SIGBUS;
+		}
 		err = vm_insert_mixed(vma, (unsigned long)vmf->virtual_address,
 							xip_pfn);
+		mutex_unlock(&mapping->i_mmap_mutex);
 		if (err == -ENOMEM)
 			return VM_FAULT_OOM;
 		/*
@@ -285,16 +294,27 @@ found:
 		}
 		if (error != -ENODATA)
 			goto out;
+
+		/* We must recheck i_size under i_mmap_mutex */
+		mutex_lock(&mapping->i_mmap_mutex);
+		size = (i_size_read(inode) + PAGE_CACHE_SIZE - 1) >>
+							PAGE_CACHE_SHIFT;
+		if (unlikely(vmf->pgoff >= size)) {
+			ret = VM_FAULT_SIGBUS;
+			goto unlock;
+		}
 		/* not shared and writable, use xip_sparse_page() */
 		page = xip_sparse_page();
 		if (!page)
-			goto out;
+			goto unlock;
 		err = vm_insert_page(vma, (unsigned long)vmf->virtual_address,
 							page);
 		if (err == -ENOMEM)
-			goto out;
+			goto unlock;
 
 		ret = VM_FAULT_NOPAGE;
+unlock:
+		mutex_unlock(&mapping->i_mmap_mutex);
 out:
 		write_seqcount_end(&xip_sparse_seq);
 		mutex_unlock(&xip_sparse_mutex);
-- 
1.8.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
