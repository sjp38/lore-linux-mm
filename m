Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 0A0FF6B006C
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 08:35:37 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: avoid VM_BUG_ON page_count(page) false positives in __collapse_huge_page_copy
Date: Fri, 28 Sep 2012 14:35:31 +0200
Message-Id: <1348835731-27474-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>

Speculative cache pagecache lookups can elevate the refcount from
under us, so avoid the false positive. If the refcount is < 2 we'll be
notified by a VM_BUG_ON in put_page_testzero as there are two
put_page(src_page) in a row before returning from this function.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/huge_memory.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 1598708..ad56497 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -1814,7 +1814,6 @@ static void __collapse_huge_page_copy(pte_t *pte, struct page *page,
 			src_page = pte_page(pteval);
 			copy_user_highpage(page, src_page, address, vma);
 			VM_BUG_ON(page_mapcount(src_page) != 1);
-			VM_BUG_ON(page_count(src_page) != 2);
 			release_pte_page(src_page);
 			/*
 			 * ptl mostly unnecessary, but preempt has to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
