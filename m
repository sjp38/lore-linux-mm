Date: Mon, 06 Aug 2001 13:09:49 -0400
From: Chris Mason <mason@suse.com>
Subject: [PATCH] kill flush_dirty_buffers
Message-ID: <663080000.997117789@tiny>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: torvalds@transmeta.com
List-ID: <linux-mm.kvack.org>

Hi guys,

I've been mucking with buffer.c recently, so I took a few minutes
to replace flush_dirty_buffers with write_unlocked_buffers().  

Patch is lightly tested on ext2 and reiserfs, use at your own risk
for now.  Linus, if this is what you were talking about in the
vm suckage thread, I'll test/benchmark harder....

-chris

diff -Nru a/fs/buffer.c b/fs/buffer.c
--- a/fs/buffer.c	Mon Aug  6 13:02:46 2001
+++ b/fs/buffer.c	Mon Aug  6 13:02:46 2001
@@ -195,24 +195,35 @@
 }
 
 #define NRSYNC (32)
-static void write_unlocked_buffers(kdev_t dev)
+static int write_unlocked_buffers(kdev_t dev, int max, int check_flushtime)
 {
 	struct buffer_head *next;
 	struct buffer_head *array[NRSYNC];
 	unsigned int count;
 	int nr;
+	int total_flushed = 0 ;
 
 repeat:
 	spin_lock(&lru_list_lock);
 	next = lru_list[BUF_DIRTY];
 	nr = nr_buffers_type[BUF_DIRTY] * 2;
 	count = 0;
-	while (next && --nr >= 0) {
+	while ((!max || total_flushed < max) && next && --nr >= 0) {
 		struct buffer_head * bh = next;
 		next = bh->b_next_free;
 
 		if (dev && bh->b_dev != dev)
 			continue;
+
+		if (check_flushtime) {
+			/* The dirty lru list is chronologically ordered so
+			   if the current bh is not yet timed out,
+			   then also all the following bhs
+			   will be too young. */
+			if (time_before(jiffies, bh->b_flushtime))
+				break ;
+		}
+		
 		if (test_and_set_bit(BH_Lock, &bh->b_state))
 			continue;
 		get_bh(bh);
@@ -224,6 +235,7 @@
 
 			spin_unlock(&lru_list_lock);
 			write_locked_buffers(array, count);
+			total_flushed += count ;
 			goto repeat;
 		}
 		unlock_buffer(bh);
@@ -231,8 +243,11 @@
 	}
 	spin_unlock(&lru_list_lock);
 
-	if (count)
+	if (count) {
 		write_locked_buffers(array, count);
+		total_flushed += count ;
+	}
+	return total_flushed ;
 }
 
 static int wait_for_locked_buffers(kdev_t dev, int index, int refile)
@@ -286,10 +301,10 @@
 	 * 2) write out all dirty, unlocked buffers;
 	 * 2) wait for completion by waiting for all buffers to unlock.
 	 */
-	write_unlocked_buffers(dev);
+	write_unlocked_buffers(dev, 0, 0);
 	if (wait) {
 		err = wait_for_locked_buffers(dev, BUF_DIRTY, 0);
-		write_unlocked_buffers(dev);
+		write_unlocked_buffers(dev, 0, 0);
 		err |= wait_for_locked_buffers(dev, BUF_LOCKED, 1);
 	}
 	return err;
@@ -2524,60 +2539,6 @@
  * a limited number of buffers to the disks and then go back to sleep again.
  */
 
-/* This is the _only_ function that deals with flushing async writes
-   to disk.
-   NOTENOTENOTENOTE: we _only_ need to browse the DIRTY lru list
-   as all dirty buffers lives _only_ in the DIRTY lru list.
-   As we never browse the LOCKED and CLEAN lru lists they are infact
-   completly useless. */
-static int flush_dirty_buffers(int check_flushtime)
-{
-	struct buffer_head * bh, *next;
-	int flushed = 0, i;
-
- restart:
-	spin_lock(&lru_list_lock);
-	bh = lru_list[BUF_DIRTY];
-	if (!bh)
-		goto out_unlock;
-	for (i = nr_buffers_type[BUF_DIRTY]; i-- > 0; bh = next) {
-		next = bh->b_next_free;
-
-		if (!buffer_dirty(bh)) {
-			__refile_buffer(bh);
-			continue;
-		}
-		if (buffer_locked(bh))
-			continue;
-
-		if (check_flushtime) {
-			/* The dirty lru list is chronologically ordered so
-			   if the current bh is not yet timed out,
-			   then also all the following bhs
-			   will be too young. */
-			if (time_before(jiffies, bh->b_flushtime))
-				goto out_unlock;
-		} else {
-			if (++flushed > bdf_prm.b_un.ndirty)
-				goto out_unlock;
-		}
-
-		/* OK, now we are committed to write it out. */
-		get_bh(bh);
-		spin_unlock(&lru_list_lock);
-		ll_rw_block(WRITE, 1, &bh);
-		put_bh(bh);
-
-		if (current->need_resched)
-			schedule();
-		goto restart;
-	}
- out_unlock:
-	spin_unlock(&lru_list_lock);
-
-	return flushed;
-}
-
 DECLARE_WAIT_QUEUE_HEAD(bdflush_wait);
 
 void wakeup_bdflush(int block)
@@ -2586,7 +2547,7 @@
 		wake_up_interruptible(&bdflush_wait);
 
 	if (block)
-		flush_dirty_buffers(0);
+		write_unlocked_buffers(NODEV, bdf_prm.b_un.ndirty, 0) ;
 }
 
 /* 
@@ -2604,7 +2565,7 @@
 	sync_supers(0);
 	unlock_kernel();
 
-	flush_dirty_buffers(1);
+	write_unlocked_buffers(NODEV, 0, 1) ;
 	/* must really sync all the active I/O request to disk here */
 	run_task_queue(&tq_disk);
 	return 0;
@@ -2700,7 +2661,7 @@
 	for (;;) {
 		CHECK_EMERGENCY_SYNC
 
-		flushed = flush_dirty_buffers(0);
+		flushed = write_unlocked_buffers(NODEV, bdf_prm.b_un.ndirty, 0);
 
 		/*
 		 * If there are still a lot of dirty buffers around,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
