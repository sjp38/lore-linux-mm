Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id E60D96B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 14:15:03 -0400 (EDT)
Received: by iajr24 with SMTP id r24so23849270iaj.14
        for <linux-mm@kvack.org>; Mon, 23 Apr 2012 11:15:02 -0700 (PDT)
Date: Mon, 23 Apr 2012 11:14:50 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] mm: fix s390 BUG by __set_page_dirty_no_writeback on swap
In-Reply-To: <alpine.LSU.2.00.1204231106450.23248@eggly.anvils>
Message-ID: <alpine.LSU.2.00.1204231110090.23248@eggly.anvils>
References: <20120416141423.GD2359@suse.de> <alpine.LSU.2.00.1204161332120.1675@eggly.anvils> <20120417122202.GF2359@suse.de> <alpine.LSU.2.00.1204172023390.1609@eggly.anvils> <20120418152831.GK2359@suse.de> <alpine.LSU.2.00.1204181005500.1811@eggly.anvils>
 <20120423124124.GB3255@suse.de> <alpine.LSU.2.00.1204231106450.23248@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Rik van Riel <riel@redhat.com>, Ken Chen <kenchen@google.com>, linux-mm@kvack.org, linux-s390@vger.kernel.org, linux-kernel@vger.kernel.org

Mel reports a BUG_ON(slot == NULL) in radix_tree_tag_set() on s390 3.0.13:
called from __set_page_dirty_nobuffers() when page_remove_rmap() tries to
transfer dirty flag from s390 storage key to struct page and radix_tree.

That would be because of reclaim's shrink_page_list() calling add_to_swap()
on this page at the same time: first PageSwapCache is set (causing
page_mapping(page) to appear as &swapper_space), then page->private set,
then tree_lock taken, then page inserted into radix_tree - so there's
an interval before taking the lock when the radix_tree slot is empty.

We could fix this by moving __add_to_swap_cache()'s spin_lock_irq up
before the SetPageSwapCache.  But a better fix is simply to do what's
five years overdue: Ken Chen introduced __set_page_dirty_no_writeback()
(if !PageDirty TestSetPageDirty) for tmpfs to skip all the radix_tree
overhead, and swap is just the same - it ignores the radix_tree tag,
and does not participate in dirty page accounting, so should be using
__set_page_dirty_no_writeback() too.

s390 testing now confirms that this does indeed fix the problem.

Reported-by: Mel Gorman <mgorman@suse.de>
Signed-off-by: Hugh Dickins <hughd@google.com>
Acked-by: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ken Chen <kenchen@google.com>
Cc: stable@vger.kernel.org
---

 mm/swap_state.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- 3.4-git/mm/swap_state.c	2012-03-31 17:42:26.949729938 -0700
+++ linux/mm/swap_state.c	2012-04-17 15:34:05.732086663 -0700
@@ -26,7 +26,7 @@
  */
 static const struct address_space_operations swap_aops = {
 	.writepage	= swap_writepage,
-	.set_page_dirty	= __set_page_dirty_nobuffers,
+	.set_page_dirty	= __set_page_dirty_no_writeback,
 	.migratepage	= migrate_page,
 };
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
