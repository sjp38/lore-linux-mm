Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E06638D003B
	for <linux-mm@kvack.org>; Thu, 21 Apr 2011 15:45:14 -0400 (EDT)
Date: Thu, 21 Apr 2011 12:44:24 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] tmpfs: fix race between umount and writepage
Message-Id: <20110421124424.0a10ed0c.akpm@linux-foundation.org>
In-Reply-To: <20110421064150.6431.84511.stgit@localhost6>
References: <4DAFD0B1.9090603@parallels.com>
	<20110421064150.6431.84511.stgit@localhost6>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Apr 2011 10:41:50 +0400
Konstantin Khlebnikov <khlebnikov@openvz.org> wrote:

> shmem_writepage() call igrab() on the inode for the page which is came from
> reclaimer to add it later into shmem_swaplist for swap-unuse operation.
> 
> This igrab() can race with super-block deactivating process:
> 
> shrink_inactive_list()		deactivate_super()
> pageout()			tmpfs_fs_type->kill_sb()
> shmem_writepage()		kill_litter_super()
> 				generic_shutdown_super()
> 				 evict_inodes()
>  igrab()
> 				  atomic_read(&inode->i_count)
> 				   skip-inode
>  iput()
> 				 if (!list_empty(&sb->s_inodes))
> 					printk("VFS: Busy inodes after...
> 
> This igrap-iput pair was added in commit 1b1b32f2c6f6bb3253
> based on incorrect assumptions:
> 
> : Ah, I'd never suspected it, but shmem_writepage's swaplist manipulation
> : is unsafe: though still hold page lock, which would hold off inode
> : deletion if the page were i pagecache, it doesn't hold off once it's in
> : swapcache (free_swap_and_cache doesn't wait on locked pages).  Hmm: we
> : could put the the inode on swaplist earlier, but then shmem_unuse_inode
> : could never prune unswapped inodes.
> 
> Attached locked page actually protect inode from deletion because
> truncate_inode_pages_range() will sleep on this, so igrab not required.
> This patch actually revert last hunk from that commit.
> 

hm, is that last paragraph true?  Let's look at the resulting code.


: 	if (swap.val && add_to_swap_cache(page, swap, GFP_ATOMIC) == 0) {
: 		delete_from_page_cache(page);

Here, the page is removed from inode->i_mapping.  So
truncate_inode_pages() won't see that page and will not block on its
lock.

: 		shmem_swp_set(info, entry, swap.val);
: 		shmem_swp_unmap(entry);
: 		spin_unlock(&info->lock);
: 		if (list_empty(&info->swaplist)) {
: 			mutex_lock(&shmem_swaplist_mutex);
: 			/* move instead of add in case we're racing */
: 			list_move_tail(&info->swaplist, &shmem_swaplist);
: 			mutex_unlock(&shmem_swaplist_mutex);
: 		}

Here, the code plays with `info', which points at storage which is
embedded within the inode's filesystem-private part.

But because the inode now has no attached locked page, a concurrent
umount can free the inode while this code is using it.

: 		swap_shmem_alloc(swap);
: 		BUG_ON(page_mapped(page));
: 		swap_writepage(page, wbc);
: 		return 0;
: 	}

However, I assume that you reran your testcase with the v2 patch and
that things ran OK.  How come?  Either my analysis is wrong or the
testcase doesn't trigger races in this code path?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
