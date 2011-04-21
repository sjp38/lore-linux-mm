Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 20C548D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 02:41:55 -0400 (EDT)
Subject: [PATCH v2] tmpfs: fix race between umount and writepage
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Thu, 21 Apr 2011 10:41:50 +0400
Message-ID: <20110421064150.6431.84511.stgit@localhost6>
In-Reply-To: <4DAFD0B1.9090603@parallels.com>
References: <4DAFD0B1.9090603@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
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

This igrap-iput pair was added in commit 1b1b32f2c6f6bb3253
based on incorrect assumptions:

: Ah, I'd never suspected it, but shmem_writepage's swaplist manipulation
: is unsafe: though still hold page lock, which would hold off inode
: deletion if the page were i pagecache, it doesn't hold off once it's in
: swapcache (free_swap_and_cache doesn't wait on locked pages).  Hmm: we
: could put the the inode on swaplist earlier, but then shmem_unuse_inode
: could never prune unswapped inodes.

Attached locked page actually protect inode from deletion because
truncate_inode_pages_range() will sleep on this, so igrab not required.
This patch actually revert last hunk from that commit.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 mm/shmem.c |   13 ++++---------
 1 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 8fa27e4..ea55704 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1084,21 +1084,16 @@ static int shmem_writepage(struct page *page, struct writeback_control *wbc)
 		delete_from_page_cache(page);
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
-		if (list_empty(&info->swaplist))
-			inode = igrab(inode);
-		else
-			inode = NULL;
 		spin_unlock(&info->lock);
-		swap_shmem_alloc(swap);
-		BUG_ON(page_mapped(page));
-		swap_writepage(page, wbc);
-		if (inode) {
+		if (list_empty(&info->swaplist)) {
 			mutex_lock(&shmem_swaplist_mutex);
 			/* move instead of add in case we're racing */
 			list_move_tail(&info->swaplist, &shmem_swaplist);
 			mutex_unlock(&shmem_swaplist_mutex);
-			iput(inode);
 		}
+		swap_shmem_alloc(swap);
+		BUG_ON(page_mapped(page));
+		swap_writepage(page, wbc);
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
