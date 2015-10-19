Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f51.google.com (mail-oi0-f51.google.com [209.85.218.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5368782F67
	for <linux-mm@kvack.org>; Mon, 19 Oct 2015 01:03:18 -0400 (EDT)
Received: by oiao187 with SMTP id o187so34911181oia.3
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:03:18 -0700 (PDT)
Received: from mail-ob0-x232.google.com (mail-ob0-x232.google.com. [2607:f8b0:4003:c01::232])
        by mx.google.com with ESMTPS id ru9si16186963oeb.92.2015.10.18.22.03.17
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 18 Oct 2015 22:03:17 -0700 (PDT)
Received: by obbda8 with SMTP id da8so129999517obb.1
        for <linux-mm@kvack.org>; Sun, 18 Oct 2015 22:03:17 -0700 (PDT)
Date: Sun, 18 Oct 2015 22:03:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 9/12] mm: simplify page migration's anon_vma comment and
 flow
In-Reply-To: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1510182201380.2481@eggly.anvils>
References: <alpine.LSU.2.11.1510182132470.2481@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org

__unmap_and_move() contains a long stale comment on page_get_anon_vma()
and PageSwapCache(), with an odd control flow that's hard to follow.
Mostly this reflects our confusion about the lifetime of an anon_vma,
in the early days of page migration, before we could take a reference
to one.  Nowadays this seems quite straightforward: cut it all down to
essentials.

I cannot see the relevance of swapcache here at all, so don't treat it
any differently: I believe the old comment reflects in part our anon_vma
confusions, and in part the original v2.6.16 page migration technique,
which used actual swap to migrate anon instead of swap-like migration
entries.  Why should a swapcache page not be migrated with the aid of
migration entry ptes like everything else?  So lose that comment now,
and enable migration entries for swapcache in the next patch.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 mm/migrate.c |   36 ++++++++++--------------------------
 1 file changed, 10 insertions(+), 26 deletions(-)

--- migrat.orig/mm/migrate.c	2015-10-18 17:53:24.858337721 -0700
+++ migrat/mm/migrate.c	2015-10-18 17:53:27.120340297 -0700
@@ -819,6 +819,7 @@ static int __unmap_and_move(struct page
 			goto out_unlock;
 		wait_on_page_writeback(page);
 	}
+
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
 	 * we cannot notice that anon_vma is freed while we migrates a page.
@@ -826,34 +827,15 @@ static int __unmap_and_move(struct page
 	 * of migration. File cache pages are no problem because of page_lock()
 	 * File Caches may use write_page() or lock_page() in migration, then,
 	 * just care Anon page here.
+	 *
+	 * Only page_get_anon_vma() understands the subtleties of
+	 * getting a hold on an anon_vma from outside one of its mms.
+	 * But if we cannot get anon_vma, then we won't need it anyway,
+	 * because that implies that the anon page is no longer mapped
+	 * (and cannot be remapped so long as we hold the page lock).
 	 */
-	if (PageAnon(page) && !PageKsm(page)) {
-		/*
-		 * Only page_lock_anon_vma_read() understands the subtleties of
-		 * getting a hold on an anon_vma from outside one of its mms.
-		 */
+	if (PageAnon(page) && !PageKsm(page))
 		anon_vma = page_get_anon_vma(page);
-		if (anon_vma) {
-			/*
-			 * Anon page
-			 */
-		} else if (PageSwapCache(page)) {
-			/*
-			 * We cannot be sure that the anon_vma of an unmapped
-			 * swapcache page is safe to use because we don't
-			 * know in advance if the VMA that this page belonged
-			 * to still exists. If the VMA and others sharing the
-			 * data have been freed, then the anon_vma could
-			 * already be invalid.
-			 *
-			 * To avoid this possibility, swapcache pages get
-			 * migrated but are not remapped when migration
-			 * completes
-			 */
-		} else {
-			goto out_unlock;
-		}
-	}
 
 	/*
 	 * Block others from accessing the new page when we get around to
@@ -898,6 +880,8 @@ static int __unmap_and_move(struct page
 		}
 	} else if (page_mapped(page)) {
 		/* Establish migration ptes */
+		VM_BUG_ON_PAGE(PageAnon(page) && !PageKsm(page) && !anon_vma,
+				page);
 		try_to_unmap(page,
 			TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
 		page_was_mapped = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
