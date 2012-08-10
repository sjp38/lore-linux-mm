Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id AA5786B005D
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 17:42:15 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 2/3] HWPOISON: undo memory error handling for dirty pagecache
Date: Fri, 10 Aug 2012 17:41:52 -0400
Message-Id: <1344634913-13681-3-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
References: <1344634913-13681-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi.kleen@intel.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Tony Luck <tony.luck@intel.com>, Rik van Riel <riel@redhat.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, Naoya Horiguchi <nhoriguc@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Current memory error handling on dirty pagecache has a bug that user
processes who use corrupted pages via read() or write() can't be aware
of the memory error and result in discarding dirty data silently.

The following patch is to improve handling/reporting memory errors on
this case, but as a short term solution I suggest that we should undo
the present error handling code and just leave errors for such cases
(which expect the 2nd MCE to panic the system) to ensure data consistency.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: stable@vger.kernel.org
---
 mm/memory-failure.c | 54 +++++++++++------------------------------------------
 1 file changed, 11 insertions(+), 43 deletions(-)

diff --git v3.6-rc1.orig/mm/memory-failure.c v3.6-rc1/mm/memory-failure.c
index 79dfb2f..7e62797 100644
--- v3.6-rc1.orig/mm/memory-failure.c
+++ v3.6-rc1/mm/memory-failure.c
@@ -613,49 +613,17 @@ static int me_pagecache_clean(struct page *p, unsigned long pfn)
  */
 static int me_pagecache_dirty(struct page *p, unsigned long pfn)
 {
-	struct address_space *mapping = page_mapping(p);
-
-	SetPageError(p);
-	/* TBD: print more information about the file. */
-	if (mapping) {
-		/*
-		 * IO error will be reported by write(), fsync(), etc.
-		 * who check the mapping.
-		 * This way the application knows that something went
-		 * wrong with its dirty file data.
-		 *
-		 * There's one open issue:
-		 *
-		 * The EIO will be only reported on the next IO
-		 * operation and then cleared through the IO map.
-		 * Normally Linux has two mechanisms to pass IO error
-		 * first through the AS_EIO flag in the address space
-		 * and then through the PageError flag in the page.
-		 * Since we drop pages on memory failure handling the
-		 * only mechanism open to use is through AS_AIO.
-		 *
-		 * This has the disadvantage that it gets cleared on
-		 * the first operation that returns an error, while
-		 * the PageError bit is more sticky and only cleared
-		 * when the page is reread or dropped.  If an
-		 * application assumes it will always get error on
-		 * fsync, but does other operations on the fd before
-		 * and the page is dropped between then the error
-		 * will not be properly reported.
-		 *
-		 * This can already happen even without hwpoisoned
-		 * pages: first on metadata IO errors (which only
-		 * report through AS_EIO) or when the page is dropped
-		 * at the wrong time.
-		 *
-		 * So right now we assume that the application DTRT on
-		 * the first EIO, but we're not worse than other parts
-		 * of the kernel.
-		 */
-		mapping_set_error(mapping, EIO);
-	}
-
-	return me_pagecache_clean(p, pfn);
+	/*
+	 * The original memory error handling on dirty pagecache has
+	 * a bug that user processes who use corrupted pages via read()
+	 * or write() can't be aware of the memory error and result
+	 * in throwing out dirty data silently.
+	 *
+	 * Until we solve the problem, let's close the path of memory
+	 * error handling for dirty pagecache. We just leave errors
+	 * for the 2nd MCE to trigger panics.
+	 */
+	return IGNORED;
 }
 
 /*
-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
