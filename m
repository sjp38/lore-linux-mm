From: Steve Dodd <steved@loth.demon.co.uk>
Date: Fri, 14 Apr 2000 00:17:35 +0100
Subject: [PATCH] 2.3.99x: SMP race in getblk()?
Message-ID: <20000414001735.U831@loth.demon.co.uk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="GpGaEY17fSl8rd50"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-kernel@vger.rutgers.edu, Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

--GpGaEY17fSl8rd50
Content-Type: text/plain; charset=us-ascii

[CC'd to linux-mm at Rik's suggestion]

This is a first attempt at a fix for what I /think/ is a potential race
condition in getblk. There seems to be a small window where multiple
buffer_heads could be added to the hash table for the same block. The patch
compiles, but I've not tried running it yet. Any thoughts?

-- 
The very concept of PNP is a lovely dream that simply does not translate to
reality. The confusion of manually doing stuff is nothing compared to the
confusion of computers trying to do stuff and getting it wrong, which they
gleefully do with great enthusiasm. -- Jinx Tigr in the SDM

--GpGaEY17fSl8rd50
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="buffer.c.diff"

--- buffer.c~	Thu Apr 13 23:08:06 2000
+++ buffer.c	Thu Apr 13 23:38:55 2000
@@ -494,17 +494,6 @@
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
@@ -536,24 +525,56 @@
  * will force it bad). This shouldn't really happen currently, but
  * the code is ready.
  */
-struct buffer_head * get_hash_table(kdev_t dev, int block, int size)
+static struct buffer_head * __get_hash_table(kdev_t dev, int block, int size,
+						struct buffer_head **head)
 {
-	struct buffer_head **head = &hash(dev, block);
 	struct buffer_head *bh;
 
-	read_lock(&hash_table_lock);
 	for(bh = *head; bh; bh = bh->b_next)
 		if (bh->b_blocknr == block	&&
-		    bh->b_size    == size	&&
+		    bh->b_size    == size	&&	/* is this required? */
 		    bh->b_dev     == dev)
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
@@ -840,8 +861,16 @@
 		bh->b_blocknr = block;
 		bh->b_state = 1 << BH_Mapped;
 
-		/* Insert the buffer into the regular lists */
-		insert_into_queues(bh);
+		/* Insert the buffer into the regular lists; check noone
+		   else added it first */
+		
+		if (!insert_into_queues_unique(bh))
+			goto out;
+
+		/* someone added it after we last check the hash table */
+		put_last_free(bh);
+		goto repeat;
+	
 	out:
 		touch_buffer(bh);
 		return bh;

--GpGaEY17fSl8rd50--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
