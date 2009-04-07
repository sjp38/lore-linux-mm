From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH 05/14] readahead: account mmap_miss for VM_FAULT_RETRY
Date: Tue, 07 Apr 2009 19:50:44 +0800
Message-ID: <20090407115234.313061952@intel.com>
References: <20090407115039.780820496@intel.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 49DF35F0004
	for <linux-mm@kvack.org>; Tue,  7 Apr 2009 08:00:53 -0400 (EDT)
Content-Disposition: inline; filename=readahead-mmap_miss-retry.patch
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Wu Fengguang <fengguang.wu@intel.com>, David Rientjes <rientjes@google.com>, Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Mike Waychison <mikew@google.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rohit Seth <rohitseth@google.com>, Edwin <edwintorok@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Ying Han <yinghan@google.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-Id: linux-mm.kvack.org

The VM_FAULT_RETRY case introduced a performance bug that leads to
excessive/unconditional mmap readarounds for wild random mmap reads.

A retried page fault means a mmap readahead miss(mmap_miss++) followed by
a hit(mmap_miss--) on the same page. This sticks mmap_miss, and thus stops
mmap readaround from being turned off for wild random reads. Fix it by an
extra mmap_miss increament in order to counteract the followed mmap hit.

Also make mmap_miss a more robust 'unsigned int', so that if ever mmap_miss
goes out of range, it only create _temporary_ performance impacts.

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
