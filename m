Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 267746B005A
	for <linux-mm@kvack.org>; Tue, 18 Sep 2012 23:52:21 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so549010qcs.14
        for <linux-mm@kvack.org>; Tue, 18 Sep 2012 20:52:20 -0700 (PDT)
Date: Tue, 18 Sep 2012 20:51:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/4] mm: fix invalidate_complete_page2 lock ordering
Message-ID: <alpine.LSU.2.00.1209182045370.11632@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, Ying Han <yinghan@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

In fuzzing with trinity, lockdep protested "possible irq lock inversion
dependency detected" when isolate_lru_page() reenabled interrupts while
still holding the supposedly irq-safe tree_lock:

invalidate_inode_pages2
  invalidate_complete_page2
    spin_lock_irq(&mapping->tree_lock)
    clear_page_mlock
      isolate_lru_page
        spin_unlock_irq(&zone->lru_lock)

isolate_lru_page() is correct to enable interrupts unconditionally:
invalidate_complete_page2() is incorrect to call clear_page_mlock()
while holding tree_lock, which is supposed to nest inside lru_lock.

Both truncate_complete_page() and invalidate_complete_page() call
clear_page_mlock() before taking tree_lock to remove page from
radix_tree.  I guess invalidate_complete_page2() preferred to test
PageDirty (again) under tree_lock before committing to the munlock;
but since the page has already been unmapped, its state is already
somewhat inconsistent, and no worse if clear_page_mlock() moved up.

Reported-by: Sasha Levin <levinsasha928@gmail.com>
Deciphered-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Michel Lespinasse <walken@google.com>
Cc: Ying Han <yinghan@google.com>
Cc: stable@vger.kernel.org
---
 mm/truncate.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 3.6-rc6.orig/mm/truncate.c	2012-09-18 15:38:08.000000000 -0700
+++ 3.6-rc6/mm/truncate.c	2012-09-18 15:42:17.066731792 -0700
@@ -394,11 +394,12 @@ invalidate_complete_page2(struct address
 	if (page_has_private(page) && !try_to_release_page(page, GFP_KERNEL))
 		return 0;
 
+	clear_page_mlock(page);
+
 	spin_lock_irq(&mapping->tree_lock);
 	if (PageDirty(page))
 		goto failed;
 
-	clear_page_mlock(page);
 	BUG_ON(page_has_private(page));
 	__delete_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
