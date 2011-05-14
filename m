Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 7AA4B6B0011
	for <linux-mm@kvack.org>; Sat, 14 May 2011 15:06:52 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p4EJ6nLi028606
	for <linux-mm@kvack.org>; Sat, 14 May 2011 12:06:49 -0700
Received: from pzk9 (pzk9.prod.google.com [10.243.19.137])
	by hpaq5.eem.corp.google.com with ESMTP id p4EJ6fbD031710
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Sat, 14 May 2011 12:06:47 -0700
Received: by pzk9 with SMTP id 9so1587312pzk.19
        for <linux-mm@kvack.org>; Sat, 14 May 2011 12:06:41 -0700 (PDT)
Date: Sat, 14 May 2011 12:06:42 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] tmpfs: fix race between swapoff and writepage
Message-ID: <alpine.LSU.2.00.1105141201190.1906@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Shame on me!  Commit b1dea800ac39 "tmpfs: fix race between umount and
writepage" fixed the advertized race, but introduced another: as even
its comment makes clear, we cannot safely rely on a peek at list_empty()
while holding no lock - until info->swapped is set, shmem_unuse_inode()
may delete any formerly-swapped inode from the shmem_swaplist, which
in this case would leave a swap area impossible to swapoff.

Although I don't relish taking the mutex every time, I don't care much
for the alternatives either; and at least the peek at list_empty() in
shmem_evict_inode() (a hotter path since most inodes would never have
been swapped) remains safe, because we already truncated the whole file.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@kernel.org
---

 mm/shmem.c |   10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

--- 2.6.39-rc7+/mm/shmem.c	2011-05-09 21:09:49.861399310 -0700
+++ linux/mm/shmem.c	2011-05-14 03:48:02.719548428 -0700
@@ -1037,7 +1037,6 @@ static int shmem_writepage(struct page *
 	struct address_space *mapping;
 	unsigned long index;
 	struct inode *inode;
-	bool unlock_mutex = false;
 
 	BUG_ON(!PageLocked(page));
 	mapping = page->mapping;
@@ -1072,15 +1071,14 @@ static int shmem_writepage(struct page *
 	 * we've taken the spinlock, because shmem_unuse_inode() will
 	 * prune a !swapped inode from the swaplist under both locks.
 	 */
-	if (swap.val && list_empty(&info->swaplist)) {
+	if (swap.val) {
 		mutex_lock(&shmem_swaplist_mutex);
-		/* move instead of add in case we're racing */
-		list_move_tail(&info->swaplist, &shmem_swaplist);
-		unlock_mutex = true;
+		if (list_empty(&info->swaplist))
+			list_add_tail(&info->swaplist, &shmem_swaplist);
 	}
 
 	spin_lock(&info->lock);
-	if (unlock_mutex)
+	if (swap.val)
 		mutex_unlock(&shmem_swaplist_mutex);
 
 	if (index >= info->next_index) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
