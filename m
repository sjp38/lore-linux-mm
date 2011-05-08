Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 05A976B0022
	for <linux-mm@kvack.org>; Sun,  8 May 2011 15:41:43 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p48Jfe4i011422
	for <linux-mm@kvack.org>; Sun, 8 May 2011 12:41:40 -0700
Received: from pxi7 (pxi7.prod.google.com [10.243.27.7])
	by hpaq1.eem.corp.google.com with ESMTP id p48Jfb1f028429
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sun, 8 May 2011 12:41:39 -0700
Received: by pxi7 with SMTP id 7so3196263pxi.30
        for <linux-mm@kvack.org>; Sun, 08 May 2011 12:41:37 -0700 (PDT)
Date: Sun, 8 May 2011 12:41:48 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/3] tmpfs: fix race between umount and writepage
In-Reply-To: <4DC691D0.6050104@parallels.com>
Message-ID: <alpine.LSU.2.00.1105081238010.15963@sister.anvils>
References: <4DAFD0B1.9090603@parallels.com> <20110421064150.6431.84511.stgit@localhost6> <20110421124424.0a10ed0c.akpm@linux-foundation.org> <4DB0FE8F.9070407@parallels.com> <alpine.LSU.2.00.1105031223120.9845@sister.anvils> <4DC4D9A6.9070103@parallels.com>
 <alpine.LSU.2.00.1105071621330.3668@sister.anvils> <4DC691D0.6050104@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Konstanin Khlebnikov reports that a dangerous race between umount and
shmem_writepage can be reproduced by this script:

for i in {1..300} ; do
	mkdir $i
	while true ; do
		mount -t tmpfs none $i
		dd if=/dev/zero of=$i/test bs=1M count=$(($RANDOM % 100))
		umount $i
	done &
done

on a 6xCPU node with 8Gb RAM: kernel very unstable after this accident. =)

Kernel log:

VFS: Busy inodes after unmount of tmpfs.
               Self-destruct in 5 seconds.  Have a nice day...

WARNING: at lib/list_debug.c:53 __list_del_entry+0x8d/0x98()
list_del corruption. prev->next should be ffff880222fdaac8, but was (null)
Pid: 11222, comm: mount.tmpfs Not tainted 2.6.39-rc2+ #4
Call Trace:
 warn_slowpath_common+0x80/0x98
 warn_slowpath_fmt+0x41/0x43
 __list_del_entry+0x8d/0x98
 evict+0x50/0x113
 iput+0x138/0x141
...
BUG: unable to handle kernel paging request at ffffffffffffffff
IP: shmem_free_blocks+0x18/0x4c
Pid: 10422, comm: dd Tainted: G        W   2.6.39-rc2+ #4
Call Trace:
 shmem_recalc_inode+0x61/0x66
 shmem_writepage+0xba/0x1dc
 pageout+0x13c/0x24c
 shrink_page_list+0x28e/0x4be
 shrink_inactive_list+0x21f/0x382
...

shmem_writepage() calls igrab() on the inode for the page which came from
page reclaim, to add it later into shmem_swaplist for swapoff operation.

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

This igrap-iput pair was added in commit 1b1b32f2c6f6
"tmpfs: fix shmem_swaplist races" based on incorrect assumptions:
igrab() protects the inode from concurrent eviction by deletion, but
it does nothing to protect it from concurrent unmounting, which goes
ahead despite the raised i_count.

So this use of igrab() was wrong all along, but the race made much
worse in 2.6.37 when commit 63997e98a3be "split invalidate_inodes()"
replaced two attempts at invalidate_inodes() by a single evict_inodes().

Konstantin posted a plausible patch, raising sb->s_active too:
I'm unsure whether it was correct or not; but burnt once by igrab(),
I am sure that we don't want to rely more deeply upon externals here.

Fix it by adding the inode to shmem_swaplist earlier, while the page
lock on page in page cache still secures the inode against eviction,
without artifically raising i_count.  It was originally added later
because shmem_unuse_inode() is liable to remove an inode from the
list while it's unswapped; but we can guard against that by taking
spinlock before dropping mutex.

Reported-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Tested-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: stable@kernel.org
---

 mm/shmem.c |   31 ++++++++++++++++++++-----------
 1 file changed, 20 insertions(+), 11 deletions(-)

--- 2.6.39-rc6/mm/shmem.c	2011-04-28 09:52:49.066135001 -0700
+++ tmpfs1/mm/shmem.c	2011-05-07 17:38:00.648660817 -0700
@@ -1039,6 +1039,7 @@ static int shmem_writepage(struct page *
 	struct address_space *mapping;
 	unsigned long index;
 	struct inode *inode;
+	bool unlock_mutex = false;
 
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
@@ -1064,7 +1065,26 @@ static int shmem_writepage(struct page *
 	else
 		swap.val = 0;
 
+	/*
+	 * Add inode to shmem_unuse()'s list of swapped-out inodes,
+	 * if it's not already there.  Do it now because we cannot take
+	 * mutex while holding spinlock, and must do so before the page
+	 * is moved to swap cache, when its pagelock no longer protects
+	 * the inode from eviction.  But don't unlock the mutex until
+	 * we've taken the spinlock, because shmem_unuse_inode() will
+	 * prune a !swapped inode from the swaplist under both locks.
+	 */
+	if (swap.val && list_empty(&info->swaplist)) {
+		mutex_lock(&shmem_swaplist_mutex);
+		/* move instead of add in case we're racing */
+		list_move_tail(&info->swaplist, &shmem_swaplist);
+		unlock_mutex = true;
+	}
+
 	spin_lock(&info->lock);
+	if (unlock_mutex)
+		mutex_unlock(&shmem_swaplist_mutex);
+
 	if (index >= info->next_index) {
 		BUG_ON(!(info->flags & SHMEM_TRUNCATE));
 		goto unlock;
@@ -1084,21 +1104,10 @@ static int shmem_writepage(struct page *
 		delete_from_page_cache(page);
 		shmem_swp_set(info, entry, swap.val);
 		shmem_swp_unmap(entry);
-		if (list_empty(&info->swaplist))
-			inode = igrab(inode);
-		else
-			inode = NULL;
 		spin_unlock(&info->lock);
 		swap_shmem_alloc(swap);
 		BUG_ON(page_mapped(page));
 		swap_writepage(page, wbc);
-		if (inode) {
-			mutex_lock(&shmem_swaplist_mutex);
-			/* move instead of add in case we're racing */
-			list_move_tail(&info->swaplist, &shmem_swaplist);
-			mutex_unlock(&shmem_swaplist_mutex);
-			iput(inode);
-		}
 		return 0;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
