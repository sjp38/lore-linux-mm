Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 460638D003B
	for <linux-mm@kvack.org>; Tue,  5 Apr 2011 06:35:00 -0400 (EDT)
Subject: [PATCH] tmpfs: fix race between umount and writepage
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Tue, 5 Apr 2011 14:34:52 +0400
Message-ID: <20110405103452.18737.28363.stgit@localhost6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

shmem_writepage() call igrab() on the inode for the page which is came from
reclaimer to add it later into shmem_swaplist for swap-unuse operation.

This igrab() can race with super-block deactivating process:

shrink_inactive_list()		deactivate_super()
pageout()			tmpfs_fs_type->kill_sb()
shmem_writepage()		kill_litter_super()
				generic_shutdown_super()
				 evict_inodes()
 igrab()
				  atomic_read(&inode->i_count)
				   skip-inode
 iput()
				 if (!list_empty(&sb->s_inodes))
					printk("VFS: Busy inodes after...

To avoid this race after this patch shmem_writepage() also try grab sb->s_active.

If sb->s_active == 0 adding to the shmem_swaplist not required, because
super-block deactivation in progress and swap-entries will be released soon.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 58da7c1..1f49c03 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1038,11 +1038,13 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 	struct address_space *mapping;
 	unsigned long index;
 	struct inode *inode;
+	struct super_block *sb;
 
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
 	index = page->index;
 	inode = mapping->host;
+	sb = inode->i_sb;
 	info = SHMEM_I(inode);
 	if (info->flags & VM_LOCKED)
 		goto redirty;
@@ -1083,7 +1085,10 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		delete_from_page_cache(page);
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
-		if (list_empty(&info->swaplist))
+		if (!list_empty(&info->swaplist) ||
+				!atomic_inc_not_zero(&sb->s_active))
+			sb = NULL;
+		if (sb)
 			inode = igrab(inode);
 		else
 			inode = NULL;
@@ -1098,6 +1103,8 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 			mutex_unlock(&shmem_swaplist_mutex);
 			iput(inode);
 		}
+		if (sb)
+			deactivate_super(sb);
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
