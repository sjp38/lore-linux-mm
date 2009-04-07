From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 04/14] mm: reduce duplicate page fault code
Date: Tue, 07 Apr 2009 19:50:43 +0800
Message-ID: <20090407115234.200152360@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7F0C35F0007
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:53 -0400 (EDT)
Content-Disposition: inline; filename=filemap-fault-cleanup.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ying Han <yinghan@google.com>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

Restore the simplicity of the filemap_fault():no_cached_page block.
The VM_FAULT_RETRY case is not all that different.

No readahead/readaround will be performed after no_cached_page,
because no_cached_page either means MADV_RANDOM or some error condition.

Cc: Ying Han <yinghan@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/filemap.c |   22 +++-------------------
 1 file changed, 3 insertions(+), 19 deletions(-)

--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -1565,7 +1565,6 @@ int filemap_fault(struct vm_area_struct 
 retry_find:
 	page = find_lock_page(mapping, vmf->pgoff);
 
-retry_find_nopage:
 	/*
 	 * For sequential accesses, we use the generic readahead logic.
 	 */
@@ -1615,6 +1614,7 @@ retry_find_nopage:
 				start = vmf->pgoff - ra_pages / 2;
 			do_page_cache_readahead(mapping, file, start, ra_pages);
 		}
+retry_find_retry:
 		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
 				vma, &page, retry_flag);
 		if (retry_ret == VM_FAULT_RETRY)
@@ -1626,7 +1626,6 @@ retry_find_nopage:
 	if (!did_readaround)
 		ra->mmap_miss--;
 
-retry_page_update:
 	/*
 	 * We have a locked page in the page cache, now we need to check
 	 * that it's up-to-date. If not, it is going to be due to an error.
@@ -1662,23 +1661,8 @@ no_cached_page:
 	 * In the unlikely event that someone removed it in the
 	 * meantime, we'll just come back here and read it again.
 	 */
-	if (error >= 0) {
-		/*
-		 * If caller cannot tolerate a retry in the ->fault path
-		 * go back to check the page again.
-		 */
-		if (!retry_flag)
-			goto retry_find;
-
-		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
-					vma, &page, retry_flag);
-		if (retry_ret == VM_FAULT_RETRY)
-			return retry_ret;
-		if (!page)
-			goto retry_find_nopage;
-		else
-			goto retry_page_update;
-	}
+	if (error >= 0)
+		goto retry_find_retry;
 
 	/*
 	 * An error return from page_cache_read can result if the

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
