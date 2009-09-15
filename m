Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id B9E3D6B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:32:35 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:31:49 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 1/4] mm: m(un)lock avoid ZERO_PAGE
In-Reply-To: <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909152130260.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
 <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm still reluctant to clutter __get_user_pages() with another flag,
just to avoid touching ZERO_PAGE count in mlock(); though we can add
that later if it shows up as an issue in practice.

But when mlocking, we can test page->mapping slightly earlier, to avoid
the potentially bouncy rescheduling of lock_page on ZERO_PAGE - mlock
didn't lock_page in olden ZERO_PAGE days, so we might have regressed.

And when munlocking, it turns out that FOLL_DUMP coincidentally does
what's needed to avoid all updates to ZERO_PAGE, so use that here also.
Plus add comment suggested by KAMEZAWA Hiroyuki.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
---

 mm/mlock.c |   49 ++++++++++++++++++++++++++++++++++++-------------
 1 file changed, 36 insertions(+), 13 deletions(-)

--- mm0/mm/mlock.c	2009-09-14 16:34:37.000000000 +0100
+++ mm1/mm/mlock.c	2009-09-15 17:32:03.000000000 +0100
@@ -198,17 +198,26 @@ static long __mlock_vma_pages_range(stru
 		for (i = 0; i < ret; i++) {
 			struct page *page = pages[i];
 
-			lock_page(page);
-			/*
-			 * Because we lock page here and migration is blocked
-			 * by the elevated reference, we need only check for
-			 * file-cache page truncation.  This page->mapping
-			 * check also neatly skips over the ZERO_PAGE(),
-			 * though if that's common we'd prefer not to lock it.
-			 */
-			if (page->mapping)
-				mlock_vma_page(page);
-			unlock_page(page);
+			if (page->mapping) {
+				/*
+				 * That preliminary check is mainly to avoid
+				 * the pointless overhead of lock_page on the
+				 * ZERO_PAGE: which might bounce very badly if
+				 * there is contention.  However, we're still
+				 * dirtying its cacheline with get/put_page:
+				 * we'll add another __get_user_pages flag to
+				 * avoid it if that case turns out to matter.
+				 */
+				lock_page(page);
+				/*
+				 * Because we lock page here and migration is
+				 * blocked by the elevated reference, we need
+				 * only check for file-cache page truncation.
+				 */
+				if (page->mapping)
+					mlock_vma_page(page);
+				unlock_page(page);
+			}
 			put_page(page);	/* ref from get_user_pages() */
 		}
 
@@ -309,9 +318,23 @@ void munlock_vma_pages_range(struct vm_a
 	vma->vm_flags &= ~VM_LOCKED;
 
 	for (addr = start; addr < end; addr += PAGE_SIZE) {
-		struct page *page = follow_page(vma, addr, FOLL_GET);
-		if (page) {
+		struct page *page;
+		/*
+		 * Although FOLL_DUMP is intended for get_dump_page(),
+		 * it just so happens that its special treatment of the
+		 * ZERO_PAGE (returning an error instead of doing get_page)
+		 * suits munlock very well (and if somehow an abnormal page
+		 * has sneaked into the range, we won't oops here: great).
+		 */
+		page = follow_page(vma, addr, FOLL_GET | FOLL_DUMP);
+		if (page && !IS_ERR(page)) {
 			lock_page(page);
+			/*
+			 * Like in __mlock_vma_pages_range(),
+			 * because we lock page here and migration is
+			 * blocked by the elevated reference, we need
+			 * only check for file-cache page truncation.
+			 */
 			if (page->mapping)
 				munlock_vma_page(page);
 			unlock_page(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
