Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 72BFA6B0012
	for <linux-mm@kvack.org>; Mon, 30 May 2011 05:37:51 -0400 (EDT)
From: Jan Kara <jack@suse.cz>
Subject: [PATCH] mm: Fix assertion mapping->nrpages == 0 in end_writeback()
Date: Mon, 30 May 2011 11:37:38 +0200
Message-Id: <1306748258-4732-1-git-send-email-jack@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Al Viro <viro@ZenIV.linux.org.uk>, mszeredi@suse.cz, Jan Kara <jack@suse.cz>, Jay <jinshan.xiong@whamcloud.com>, stable@kernel.org

Under heavy memory and filesystem load, users observe the assertion
mapping->nrpages == 0 in end_writeback() trigger. This can be caused
by page reclaim reclaiming the last page from a mapping in the following
race:
	CPU0				CPU1
  ...
  shrink_page_list()
    __remove_mapping()
      __delete_from_page_cache()
        radix_tree_delete()
					evict_inode()
					  truncate_inode_pages()
					    truncate_inode_pages_range()
					      pagevec_lookup() - finds nothing
					  end_writeback()
					    mapping->nrpages != 0 -> BUG
        page->mapping = NULL
        mapping->nrpages--

Fix the problem by cycling the mapping->tree_lock at the end of
truncate_inode_pages_range() to synchronize with page reclaim.

Analyzed by Jay <jinshan.xiong@whamcloud.com>, lost in LKML, and dug
out by Miklos Szeredi <mszeredi@suse.de>.

CC: Jay <jinshan.xiong@whamcloud.com>
CC: stable@kernel.org
Acked-by: Miklos Szeredi <mszeredi@suse.de>
Signed-off-by: Jan Kara <jack@suse.cz>
---
 mm/truncate.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

 Andrew, would you merge this patch please? Thanks.

diff --git a/mm/truncate.c b/mm/truncate.c
index a956675..ec3d292 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -291,6 +291,13 @@ void truncate_inode_pages_range(struct address_space *mapping,
 		pagevec_release(&pvec);
 		mem_cgroup_uncharge_end();
 	}
+	/*
+	 * Cycle the tree_lock to make sure all __delete_from_page_cache()
+	 * calls run from page reclaim have finished as well (this handles the
+	 * case when page reclaim took the last page from our range).
+	 */
+	spin_lock_irq(&mapping->tree_lock);
+	spin_unlock_irq(&mapping->tree_lock);
 }
 EXPORT_SYMBOL(truncate_inode_pages_range);
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
