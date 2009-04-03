Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DBB086B0047
	for <linux-mm@kvack.org>; Fri,  3 Apr 2009 04:35:41 -0400 (EDT)
Date: Fri, 3 Apr 2009 16:35:59 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: [PATCH v2] vfs: fix find_lock_page_retry() return value parsing
Message-ID: <20090403083559.GB6084@localhost>
References: <604427e00812051140s67b2a89dm35806c3ee3b6ed7a@mail.gmail.com> <20090331150046.16539218.akpm@linux-foundation.org> <20090403082230.GA6084@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090403082230.GA6084@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mingo@elte.hu, mikew@google.com, rientjes@google.com, rohitseth@google.com, hugh@veritas.com, a.p.zijlstra@chello.nl, hpa@zytor.com, edwintorok@gmail.com, lee.schermerhorn@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

find_lock_page_retry() won't touch the *ppage value when returning
VM_FAULT_RETRY. This is fine except for the case

        if (VM_RandomReadHint())
                goto no_cached_page;

where the 'page' could be undefined after calling find_lock_page_retry().

Fix it by checking the VM_FAULT_RETRY case first. Also do this for the
other two find_lock_page_retry() invocations for the sake of consistency.

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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
