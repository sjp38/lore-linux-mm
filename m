From: Steve Dodd <steved@loth.demon.co.uk>
Date: Sun, 4 Jun 2000 19:18:48 +0100
Subject: [PATCH] 2.4.0-test1: fix for SMP race in getblk()
Message-ID: <20000604191848.C22412@loth.demon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="uQr8t48UFsdbeI+V"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-kernel@vger.rutgers.edu
Cc: Tigran Aivazian <tigran@veritas.com>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=us-ascii

This is a repost of a patch which I sent a while back but that never got
merged. Can anyone see any problems with it?


--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="getblk-new2.txt"

I believe the attached patch fixes a potential race in buffer.c:getblk() on
SMP machines. The problem is that another CPU could potentially add the same
buffer between us checking the hash table and adding the new buffer. Most
callers currently take the big kernel lock first, but some don't - block_write,
for example. I also nuked the comment at the top of get_hash_table, because it
really doesn't seem to make sense..

--uQr8t48UFsdbeI+V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="getblk-new2.diff"

Index: kallsyms-kdb.2/fs/buffer.c
--- kallsyms-kdb.2/fs/buffer.c Sat, 03 Jun 2000 16:48:29 +0100 steved (linux/P/22_buffer.c 1.3.1.1.1.6 644)
+++ kallsyms-kdb.2(w)/fs/buffer.c Sat, 03 Jun 2000 18:36:06 +0100 steved (linux/P/22_buffer.c 1.3.1.1.1.6 644)
@@ -28,6 +28,8 @@
 
 /* async buffer flushing, 1999 Andrea Arcangeli <andrea@suse.de> */
 
+/* [6-May-2000, Steve Dodd] fix SMP race in getblk() */
+
 #include <linux/config.h>
 #include <linux/sched.h>
 #include <linux/fs.h>
@@ -495,17 +497,6 @@ static void __remove_from_queues(struct 
 	__remove_from_lru_list(bh, bh->b_list);
 }
 
-static void insert_into_queues(struct buffer_head *bh)
-{
-	struct buffer_head **head = &hash(bh->b_dev, bh->b_blocknr);
-
-	spin_lock(&lru_list_lock);
-	write_lock(&hash_table_lock);
-	__hash_link(bh, head);
-	__insert_into_lru_list(bh, bh->b_list);
-	write_unlock(&hash_table_lock);
-	spin_unlock(&lru_list_lock);
-}
 
 /* This function must only run if there are no other
  * references _anywhere_ to this buffer head.
@@ -530,19 +521,11 @@ static void put_last_free(struct buffer_
 	spin_unlock(&head->lock);
 }
 
-/*
- * Why like this, I hear you say... The reason is race-conditions.
- * As we don't lock buffers (unless we are reading them, that is),
- * something might happen to it while we sleep (ie a read-error
- * will force it bad). This shouldn't really happen currently, but
- * the code is ready.
- */
-struct buffer_head * get_hash_table(kdev_t dev, int block, int size)
+static struct buffer_head * __get_hash_table(kdev_t dev, int block, int size,
+						struct buffer_head **head)
 {
-	struct buffer_head **head = &hash(dev, block);
 	struct buffer_head *bh;
 
-	read_lock(&hash_table_lock);
 	for(bh = *head; bh; bh = bh->b_next)
 		if (bh->b_blocknr == block	&&
 		    bh->b_size    == size	&&
@@ -550,11 +533,44 @@ struct buffer_head * get_hash_table(kdev
 			break;
 	if (bh)
 		atomic_inc(&bh->b_count);
+
+	return bh;
+}
+
+struct buffer_head * get_hash_table(kdev_t dev, int block, int size)
+{
+	struct buffer_head **head = &hash(dev, block);
+	struct buffer_head *bh;
+
+	read_lock(&hash_table_lock);
+	bh = __get_hash_table(dev, block, size, head);
 	read_unlock(&hash_table_lock);
 
 	return bh;
 }
 
+static int insert_into_queues_unique(struct buffer_head *bh)
+{
+	struct buffer_head **head = &hash(bh->b_dev, bh->b_blocknr);
+	struct buffer_head *alias;
+	int err = 0;
+
+	spin_lock(&lru_list_lock);
+	write_lock(&hash_table_lock);
+
+	alias = __get_hash_table(bh->b_dev, bh->b_blocknr, bh->b_size, head);
+	if (!alias) {
+		__hash_link(bh, head);
+		__insert_into_lru_list(bh, bh->b_list);
+	} else
+		err = 1;
+
+	write_unlock(&hash_table_lock);
+	spin_unlock(&lru_list_lock);
+
+	return err;
+}
+
 unsigned int get_hardblocksize(kdev_t dev)
 {
 	/*
@@ -831,9 +847,8 @@ repeat:
 	spin_unlock(&free_list[isize].lock);
 
 	/*
-	 * OK, FINALLY we know that this buffer is the only one of
-	 * its kind, we hold a reference (b_count>0), it is unlocked,
-	 * and it is clean.
+	 * OK, we hold a reference (b_count>0) to the buffer,
+	 * it is unlocked, and it is clean.
 	 */
 	if (bh) {
 		init_buffer(bh, end_buffer_io_sync, NULL);
@@ -841,8 +856,16 @@ repeat:
 		bh->b_blocknr = block;
 		bh->b_state = 1 << BH_Mapped;
 
-		/* Insert the buffer into the regular lists */
-		insert_into_queues(bh);
+		/* Insert the buffer into the regular lists; check nobody
+		   else added it first */
+		
+		if (!insert_into_queues_unique(bh))
+			goto out;
+
+		/* someone added it after we last checked the hash table */
+		put_last_free(bh);
+		goto repeat;
+	
 	out:
 		touch_buffer(bh);
 		return bh;

--uQr8t48UFsdbeI+V--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
