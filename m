Date: Mon, 06 Aug 2001 17:14:54 -0400
From: Chris Mason <mason@suse.com>
Subject: Re: [PATCH] kill flush_dirty_buffers
Message-ID: <786050000.997132494@tiny>
In-Reply-To: <Pine.LNX.4.33.0108061048240.8972-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Monday, August 06, 2001 11:00:02 AM -0700 Linus Torvalds <torvalds@transmeta.com> wrote:

> 
> On Mon, 6 Aug 2001, Chris Mason wrote:
>> 
>> Patch is lightly tested on ext2 and reiserfs, use at your own risk
>> for now.  Linus, if this is what you were talking about in the
>> vm suckage thread, I'll test/benchmark harder....
> 
> This is what I was talking about, but I'd rather have two separate
> functions. Right now we have a simple "write_unlocked_buffers()" that is
> very straightforward, and I hate having "flags" arguments to functions
> that change their behaviour.

Yes, I had somehow read that you wanted write_unlocked_buffers to look 
more like flush_dirty_buffers...whoops.  Anyway, below is a slightly 
different patch.  The check_flushtime idea is changed, kupdate 
writes a minimum of b_un.ndirty buffers, even if the first buffer it finds
is too young.

Same light testing as before, same warning label ;-)

Daniel, I left the kdev_t parameter to all flavors of write_unlocked_buffers.
It should be possible to experiment with flushes per device.

-chris

--- linux-248p4/fs/buffer.c	Mon Aug  6 16:58:58 2001
+++ linux/fs/buffer.c	Mon Aug  6 17:08:43 2001
@@ -195,18 +195,22 @@
 }
 
 #define NRSYNC (32)
-static void write_unlocked_buffers(kdev_t dev)
-{
-	struct buffer_head *next;
-	struct buffer_head *array[NRSYNC];
-	unsigned int count;
-	int nr;
 
-repeat:
-	spin_lock(&lru_list_lock);
-	next = lru_list[BUF_DIRTY];
-	nr = nr_buffers_type[BUF_DIRTY] * 2;
-	count = 0;
+/* we set start to point to the last buffer we write, that way callers
+** can check the age of that buffer to see if they think they've flushed
+** enough
+**
+** the number of buffers written is returned.  If this is less than
+** NRSYNC, it is because we could not find enough dirty unlocked buffers on
+** the list to write out.
+*/
+static int __write_unlocked_buffers(kdev_t dev, struct buffer_head **start)
+{
+	int count = 0 ;
+	struct buffer_head *array[NRSYNC] ;
+	struct buffer_head *next = *start ;
+	int nr = nr_buffers_type[BUF_DIRTY] * 2;
+
 	while (next && --nr >= 0) {
 		struct buffer_head * bh = next;
 		next = bh->b_next_free;
@@ -219,12 +223,13 @@
 		if (atomic_set_buffer_clean(bh)) {
 			__refile_buffer(bh);
 			array[count++] = bh;
+			*start = bh ;
 			if (count < NRSYNC)
 				continue;
 
 			spin_unlock(&lru_list_lock);
 			write_locked_buffers(array, count);
-			goto repeat;
+			return count ;
 		}
 		unlock_buffer(bh);
 		put_bh(bh);
@@ -233,6 +238,63 @@
 
 	if (count)
 		write_locked_buffers(array, count);
+
+	if (current->need_resched) {
+		run_task_queue(&tq_disk) ;
+		schedule() ;
+	}
+	return count ;
+}
+
+static void write_unlocked_buffers(kdev_t dev)
+{
+	struct buffer_head *next;
+	int count ;
+
+	do {
+		spin_lock(&lru_list_lock);
+		next = lru_list[BUF_DIRTY];
+		count = __write_unlocked_buffers(dev, &next) ;
+	} while (count >= NRSYNC) ;
+}
+
+static int flush_dirty_buffers(kdev_t dev)
+{
+	struct buffer_head *next;
+	int count ;
+	int total = 0 ;
+
+	do {
+		spin_lock(&lru_list_lock);
+		next = lru_list[BUF_DIRTY];
+		count = __write_unlocked_buffers(dev, &next) ;
+		total += count ;
+		if (total >= bdf_prm.b_un.ndirty)
+			break ;
+	} while (count >= NRSYNC) ;
+	return total ;
+}
+
+static int flush_old_buffers(kdev_t dev)
+{
+	struct buffer_head *next;
+	int count ;
+	int total = 0 ;
+
+	do {
+		spin_lock(&lru_list_lock);
+		next = lru_list[BUF_DIRTY];
+		count = __write_unlocked_buffers(dev, &next) ;
+		total += count ;
+
+		/* once we get past the oldest buffers, keep
+		** going until we've written a full ndirty cycle
+		*/
+		if (total >= bdf_prm.b_un.ndirty && next && 
+		    time_before(jiffies, next->b_flushtime))
+				break ;
+	} while (count >= NRSYNC) ;
+	return total ;
 }
 
 static int wait_for_locked_buffers(kdev_t dev, int index, int refile)
@@ -2524,60 +2586,6 @@
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
@@ -2586,7 +2594,7 @@
 		wake_up_interruptible(&bdflush_wait);
 
 	if (block)
-		flush_dirty_buffers(0);
+		flush_dirty_buffers(NODEV);
 }
 
 /* 
@@ -2604,7 +2612,7 @@
 	sync_supers(0);
 	unlock_kernel();
 
-	flush_dirty_buffers(1);
+	flush_old_buffers(NODEV);
 	/* must really sync all the active I/O request to disk here */
 	run_task_queue(&tq_disk);
 	return 0;
@@ -2700,7 +2708,7 @@
 	for (;;) {
 		CHECK_EMERGENCY_SYNC
 
-		flushed = flush_dirty_buffers(0);
+		flushed = flush_dirty_buffers(NODEV);
 
 		/*
 		 * If there are still a lot of dirty buffers around,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
