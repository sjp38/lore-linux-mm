Date: Sun, 11 Nov 2007 09:40:12 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: [patch] mm: unlockless reclaim
Message-ID: <20071111084012.GB19816@wotan.suse.de>
References: <20071110051222.GA16018@wotan.suse.de> <20071110054343.GA17803@wotan.suse.de> <1194695495.20832.27.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1194695495.20832.27.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Combined with the previous and subsequent patches, throughput of pages through
the pagecache on an Opteron system here goes up by anywhere from 50% to 500%,
depending on the number of files and threads involved.
--

unlock_page is fairly expensive. It can be avoided in page reclaim.

Signed-off-by: Nick Piggin <npiggin@suse.de>
---
Index: linux-2.6/mm/vmscan.c
===================================================================
--- linux-2.6.orig/mm/vmscan.c
+++ linux-2.6/mm/vmscan.c
@@ -589,7 +589,14 @@ static unsigned long shrink_page_list(st
 			goto keep_locked;
 
 free_it:
-		unlock_page(page);
+		/*
+		 * At this point, we have no other references and there is
+		 * no way to pick any more up (removed from LRU, removed
+		 * from pagecache). Can use non-atomic bitops now (and
+		 * we obviously don't have to worry about waking up a process
+		 * waiting on the page lock, because there are no references.
+		 */
+		__clear_page_locked(page);
 		nr_reclaimed++;
 		if (!pagevec_add(&freed_pvec, page))
 			__pagevec_release_nonlru(&freed_pvec);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
