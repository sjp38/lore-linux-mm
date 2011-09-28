Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B1BFF9000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 21:45:45 -0400 (EDT)
Received: by iaen33 with SMTP id n33so10323778iae.14
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 18:45:43 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH] vmscan: add barrier to prevent evictable page in unevictable list
Date: Wed, 28 Sep 2011 10:45:30 +0900
Message-Id: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

When racing between putback_lru_page and shmem_unlock happens,
progrom execution order is as follows, but clear_bit in processor #1
could be reordered right before spin_unlock of processor #1.
Then, the page would be stranded on the unevictable list.

spin_lock
SetPageLRU
spin_unlock
                                clear_bit(AS_UNEVICTABLE)
                                spin_lock
                                if PageLRU()
                                        if !test_bit(AS_UNEVICTABLE)
                                        	move evictable list
smp_mb
if !test_bit(AS_UNEVICTABLE)
        move evictable list
                                spin_unlock

But, pagevec_lookup in scan_mapping_unevictable_pages has rcu_read_[un]lock so
it could protect reordering before reaching test_bit(AS_UNEVICTABLE) on processor #1
so this problem never happens. But it's a unexpected side effect and we should
solve this problem properly.

This patch adds a barrier after mapping_clear_unevictable.

side-note: I didn't meet this problem but just found during review.

Cc: Johannes Weiner <jweiner@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>
Cc: Rik van Riel <riel@redhat.com>
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 mm/shmem.c  |    1 +
 mm/vmscan.c |   11 ++++++-----
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/mm/shmem.c b/mm/shmem.c
index 2d35772..22cb349 100644
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1068,6 +1068,7 @@ int shmem_lock(struct file *file, int lock, struct user_struct *user)
 		user_shm_unlock(inode->i_size, user);
 		info->flags &= ~VM_LOCKED;
 		mapping_clear_unevictable(file->f_mapping);
+		smp_mb__after_clear_bit();
 		scan_mapping_unevictable_pages(file->f_mapping);
 	}
 	retval = 0;
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 23256e8..4480f67 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -634,13 +634,14 @@ redo:
 		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
 		/*
-		 * When racing with an mlock clearing (page is
-		 * unlocked), make sure that if the other thread does
-		 * not observe our setting of PG_lru and fails
-		 * isolation, we see PG_mlocked cleared below and move
+		 * When racing with an mlock or AS_UNEVICTABLE clearing
+		 * (page is unlocked) make sure that if the other thread
+		 * does not observe our setting of PG_lru and fails
+		 * isolation/check_move_unevictable_page,
+		 * we see PG_mlocked/AS_UNEVICTABLE cleared below and move
 		 * the page back to the evictable list.
 		 *
-		 * The other side is TestClearPageMlocked().
+		 * The other side is TestClearPageMlocked() or shmem_lock().
 		 */
 		smp_mb();
 	}
-- 
1.7.4.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
