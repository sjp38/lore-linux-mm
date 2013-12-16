Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f182.google.com (mail-ea0-f182.google.com [209.85.215.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6825E6B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 05:14:29 -0500 (EST)
Received: by mail-ea0-f182.google.com with SMTP id a15so2127449eae.13
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 02:14:28 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v6si12830950eel.91.2013.12.16.02.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 16 Dec 2013 02:14:28 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH 1/3] mm: munlock: fix a bug where THP tail page is encountered
Date: Mon, 16 Dec 2013 11:14:14 +0100
Message-Id: <1387188856-21027-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1387188856-21027-1-git-send-email-vbabka@suse.cz>
References: <52AE07B4.4020203@oracle.com>
 <1387188856-21027-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, joern@logfs.org, Michel Lespinasse <walken@google.com>, Vlastimil Babka <vbabka@suse.cz>, stable@kernel.org

Since commit ff6a6da60 ("mm: accelerate munlock() treatment of THP pages")
munlock skips tail pages of a munlocked THP page. However, when the head page
already has PageMlocked unset, it will not skip the tail pages.

Commit 7225522bb ("mm: munlock: batch non-THP page isolation and
munlock+putback using pagevec") has added a PageTransHuge() check which
contains VM_BUG_ON(PageTail(page)). Sasha Levin found this triggered using
trinity, on the first tail page of a THP page without PageMlocked flag.

This patch fixes the issue by skipping tail pages also in the case when
PageMlocked flag is unset. There is still a possibility of race with THP page
split between clearing PageMlocked and determining how many pages to skip.
The race might result in former tail pages not being skipped, which is however
no longer a bug, as during the skip the PageTail flags are cleared.

However this race also affects correctness of NR_MLOCK accounting, which is to
be fixed in a separate patch.

Cc: stable@kernel.org
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 mm/mlock.c | 24 ++++++++++++++++++------
 1 file changed, 18 insertions(+), 6 deletions(-)

diff --git a/mm/mlock.c b/mm/mlock.c
index d480cd6..3847b13 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -148,21 +148,30 @@ static void __munlock_isolation_failed(struct page *page)
  */
 unsigned int munlock_vma_page(struct page *page)
 {
-	unsigned int page_mask = 0;
+	unsigned int nr_pages;
 
 	BUG_ON(!PageLocked(page));
 
 	if (TestClearPageMlocked(page)) {
-		unsigned int nr_pages = hpage_nr_pages(page);
+		nr_pages = hpage_nr_pages(page);
 		mod_zone_page_state(page_zone(page), NR_MLOCK, -nr_pages);
-		page_mask = nr_pages - 1;
 		if (!isolate_lru_page(page))
 			__munlock_isolated_page(page);
 		else
 			__munlock_isolation_failed(page);
+	} else {
+		nr_pages = hpage_nr_pages(page);
 	}
 
-	return page_mask;
+	/*
+	 * Regardless of the original PageMlocked flag, we determine nr_pages
+	 * after touching the flag. This leaves a possible race with a THP page
+	 * split, such that a whole THP page was munlocked, but nr_pages == 1.
+	 * Returning a smaller mask due to that is OK, the worst that can
+	 * happen is subsequent useless scanning of the former tail pages.
+	 * The NR_MLOCK accounting can however become broken.
+	 */
+	return nr_pages - 1;
 }
 
 /**
@@ -440,7 +449,8 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 
 	while (start < end) {
 		struct page *page = NULL;
-		unsigned int page_mask, page_increm;
+		unsigned int page_mask;
+		unsigned long page_increm;
 		struct pagevec pvec;
 		struct zone *zone;
 		int zoneid;
@@ -490,7 +500,9 @@ void munlock_vma_pages_range(struct vm_area_struct *vma,
 				goto next;
 			}
 		}
-		page_increm = 1 + (~(start >> PAGE_SHIFT) & page_mask);
+		/* It's a bug to munlock in the middle of a THP page */
+		VM_BUG_ON((start >> PAGE_SHIFT) & page_mask);
+		page_increm = 1 + page_mask;
 		start += page_increm * PAGE_SIZE;
 next:
 		cond_resched();
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
