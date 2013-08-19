Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 843F86B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 08:24:12 -0400 (EDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v2 2/7] mm: munlock: remove unnecessary call to lru_add_drain()
Date: Mon, 19 Aug 2013 14:23:37 +0200
Message-Id: <1376915022-12741-3-git-send-email-vbabka@suse.cz>
In-Reply-To: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
References: <1376915022-12741-1-git-send-email-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: =?UTF-8?q?J=C3=B6rn=20Engel?= <joern@logfs.org>, Michel Lespinasse <walken@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>

In munlock_vma_range(), lru_add_drain() is currently called in a loop before
each munlock_vma_page() call.
This is suboptimal for performance when munlocking many pages. The benefits
of per-cpu pagevec for batching the LRU putback are removed since the pagevec
only holds at most one page from the previous loop's iteration.

The lru_add_drain() call also does not serve any purposes for correctness - it
does not even drain pagavecs of all cpu's. The munlock code already expects
and handles situations where a page cannot be isolated from the LRU (e.g.
because it is on some per-cpu pagevec).

The history of the (not commented) call also suggest that it appears there as
an oversight rather than intentionally. Before commit ff6a6da6 ("mm: accelerate
munlock() treatment of THP pages") the call happened only once upon entering the
function. The commit has moved the call into the while loope. So while the
other changes in the commit improved munlock performance for THP pages, it
introduced the abovementioned suboptimal per-cpu pagevec usage.

Further in history, before commit 408e82b7 ("mm: munlock use follow_page"),
munlock_vma_pages_range() was just a wrapper around __mlock_vma_pages_range
which performed both mlock and munlock depending on a flag. However, before
ba470de4 ("mmap: handle mlocked pages during map, remap, unmap") the function
handled only mlock, not munlock. The lru_add_drain call thus comes from the
implementation in commit b291f000 ("mlock: mlocked pages are unevictable" and
was intended only for mlocking, not munlocking. The original intention of
draining the LRU pagevec at mlock time was to ensure the pages were on the LRU
before the lock operation so that they could be placed on the unevictable list
immediately. There is very little motivation to do the same in the munlock path
this, particularly for every single page.

This patch therefore removes the call completely. After removing the call, a
10% speedup was measured for munlock() of a 56GB large memory area with THP
disabled.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Reviewed-by: JA?rn Engel <joern@logfs.org>
---
 mm/mlock.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index 79b7cf7..b85f1e8 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -247,7 +247,6 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 					&page_mask);
 		if (page && !IS_ERR(page)) {
 			lock_page(page);
-			lru_add_drain();
 			/*
 			 * Any THP page found by follow_page_mask() may have
 			 * gotten split before reaching munlock_vma_page(),
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
