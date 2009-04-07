Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 7AAA35F0007
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:45:07 -0400 (EDT)
Message-Id: <20090407072132.812786358@intel.com>
References: <20090407071729.233579162@intel.com>
Date: Tue, 07 Apr 2009 15:17:30 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 01/14] mm: fix find_lock_page_retry() return value parsing
Content-Disposition: inline; filename=filemap-fault-fix.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

find_lock_page_retry() won't touch the *ppage value when returning
VM_FAULT_RETRY. So in the case of filemap_fault():no_cached_page,
the 'page' could be undefined after calling find_lock_page_retry().

Fix it by checking the VM_FAULT_RETRY case first.

Cc: Ying Han <yinghan@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |   14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -759,7 +759,7 @@ EXPORT_SYMBOL(find_lock_page);
  * @retry: 1 indicate caller tolerate a retry.
  *
  * If retry flag is on, and page is already locked by someone else, return
- * a hint of retry.
+ * a hint of retry and leave *ppage untouched.
  *
  * Return *ppage==NULL if page is not in pagecache. Otherwise return *ppage
  * points to the page in the pagecache with ret=VM_FAULT_RETRY indicate a
@@ -1575,10 +1575,10 @@ retry_find_nopage:
 							   vmf->pgoff, 1);
 			retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
 						vma, &page, retry_flag);
-			if (!page)
-				goto no_cached_page;
 			if (retry_ret == VM_FAULT_RETRY)
 				return retry_ret;
+			if (!page)
+				goto no_cached_page;
 		}
 		if (PageReadahead(page)) {
 			page_cache_async_readahead(mapping, ra, file, page,
@@ -1617,10 +1617,10 @@ retry_find_nopage:
 		}
 		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
 				vma, &page, retry_flag);
-		if (!page)
-			goto no_cached_page;
 		if (retry_ret == VM_FAULT_RETRY)
 			return retry_ret;
+		if (!page)
+			goto no_cached_page;
 	}
 
 	if (!did_readaround)
@@ -1672,10 +1672,10 @@ no_cached_page:
 
 		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
 					vma, &page, retry_flag);
+		if (retry_ret == VM_FAULT_RETRY)
+			return retry_ret;
 		if (!page)
 			goto retry_find_nopage;
-		else if (retry_ret == VM_FAULT_RETRY)
-			return retry_ret;
 		else
 			goto retry_page_update;
 	}

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
