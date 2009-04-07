Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 1BBFC5F0009
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 03:45:08 -0400 (EDT)
Message-Id: <20090407072133.296409976@intel.com>
References: <20090407071729.233579162@intel.com>
Date: Tue, 07 Apr 2009 15:17:34 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/14] readahead: account mmap_miss for VM_FAULT_RETRY
Content-Disposition: inline; filename=readahead-mmap_miss-retry.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

The VM_FAULT_RETRY case introduced a performance bug that leads to
excessive/unconditional mmap readarounds for wild random mmap reads.

A retried page fault means a mmap readahead miss(mmap_miss++) followed by
a hit(mmap_miss--) on the same page. This sticks mmap_miss, and thus stops
mmap readaround from being turned off for wild random reads. Fix it by an
extra mmap_miss increament in order to counteract the followed mmap hit.

Also make mmap_miss a more robust 'unsigned int', so that if ever mmap_miss
goes out of range, it only create _temporary_ performance impacts.

Cc: Ying Han <yinghan@google.com>
Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 include/linux/fs.h |    2 +-
 mm/filemap.c       |    8 ++++++--
 2 files changed, 7 insertions(+), 3 deletions(-)

--- mm.orig/mm/filemap.c
+++ mm/mm/filemap.c
@@ -1574,8 +1574,10 @@ retry_find:
 							   vmf->pgoff, 1);
 			retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
 						vma, &page, retry_flag);
-			if (retry_ret == VM_FAULT_RETRY)
+			if (retry_ret == VM_FAULT_RETRY) {
+				ra->mmap_miss++; /* counteract the followed retry hit */
 				return retry_ret;
+			}
 			if (!page)
 				goto no_cached_page;
 		}
@@ -1617,8 +1619,10 @@ retry_find:
 retry_find_retry:
 		retry_ret = find_lock_page_retry(mapping, vmf->pgoff,
 				vma, &page, retry_flag);
-		if (retry_ret == VM_FAULT_RETRY)
+		if (retry_ret == VM_FAULT_RETRY) {
+			ra->mmap_miss++; /* counteract the followed retry hit */
 			return retry_ret;
+		}
 		if (!page)
 			goto no_cached_page;
 	}
--- mm.orig/include/linux/fs.h
+++ mm/include/linux/fs.h
@@ -824,7 +824,7 @@ struct file_ra_state {
 					   there are only # of pages ahead */
 
 	unsigned int ra_pages;		/* Maximum readahead window */
-	int mmap_miss;			/* Cache miss stat for mmap accesses */
+	unsigned int mmap_miss;		/* Cache miss stat for mmap accesses */
 	loff_t prev_pos;		/* Cache last read() position */
 };
 

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
