Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA01743
	for <linux-mm@kvack.org>; Wed, 6 Nov 2002 14:40:08 -0800 (PST)
Message-ID: <3DC99A47.6016C6E9@digeo.com>
Date: Wed, 06 Nov 2002 14:40:07 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [patch] Buffers pinning inodes in icache forever
References: <200211062159.gA6LxmK23126@sisko.scot.redhat.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> ...
> Doing the refile really isn't hard, either.  We expect IO completion
> to be happening in approximately list order on the BUF_LOCKED list, so
> simply doing a refile on any unlocked buffers at the head of that list
> is going to keep it under control in O(1) time per buffer.
> 
> With the patch below we've not seen this particular pathology recur.
> Comments?

See IRC for discussion ;)  Seems good.

2.5 will have the same problem, and doesn't have the global
buffer list.  So doing it per-inode should work.  Untested patch
follows.  (This approach would work in 2.4 as well?)



--- 25/fs/buffer.c~remove-inode-buffers	Wed Nov  6 14:17:36 2002
+++ 25-akpm/fs/buffer.c	Wed Nov  6 14:24:58 2002
@@ -870,6 +870,28 @@ void invalidate_inode_buffers(struct ino
 }
 
 /*
+ * Remove any clean buffers from the inode's buffer list.  This is called
+ * when we're trying to free the inode itself.  Those buffers can pin it.
+ */
+void remove_inode_buffers(struct inode *inode)
+{
+	if (inode_has_buffers(inode)) {
+		struct address_space *mapping = inode->i_mapping;
+		struct list_head *list = &mapping->private_list;
+		struct address_space *buffer_mapping = mapping->assoc_mapping;
+
+		spin_lock_irq(&buffer_mapping->i_private_lock);
+		while (!list_empty(list)) {
+			struct buffer_head *bh = BH_ENTRY(list->next);
+			if (buffer_dirty(bh))
+				break;
+			__remove_assoc_queue(bh);
+		}
+		spin_unlock_irq(&buffer_mapping->i_private_lock);
+	}
+}
+
+/*
  * Create the appropriate buffers when given a page for data area and
  * the size of each buffer.. Use the bh->b_this_page linked list to
  * follow the buffers created.  Return NULL if unable to create more
--- 25/include/linux/buffer_head.h~remove-inode-buffers	Wed Nov  6 14:17:36 2002
+++ 25-akpm/include/linux/buffer_head.h	Wed Nov  6 14:17:36 2002
@@ -141,6 +141,7 @@ void buffer_insert_list(spinlock_t *lock
 void mark_buffer_dirty_inode(struct buffer_head *bh, struct inode *inode);
 int inode_has_buffers(struct inode *);
 void invalidate_inode_buffers(struct inode *);
+void remove_inode_buffers(struct inode *inode);
 int fsync_buffers_list(spinlock_t *lock, struct list_head *);
 int sync_mapping_buffers(struct address_space *mapping);
 void unmap_underlying_metadata(struct block_device *bdev, sector_t block);
--- 25/fs/inode.c~remove-inode-buffers	Wed Nov  6 14:17:36 2002
+++ 25-akpm/fs/inode.c	Wed Nov  6 14:17:36 2002
@@ -371,6 +371,8 @@ static int can_unuse(struct inode *inode
 		return 0;
 	if (atomic_read(&inode->i_count))
 		return 0;
+	if (inode->i_data.nrpages)
+		return 0;
 	return 1;
 }
 
@@ -399,13 +401,14 @@ static void prune_icache(int nr_to_scan)
 
 		inode = list_entry(inode_unused.prev, struct inode, i_list);
 
-		if (!can_unuse(inode)) {
+		if (inode->i_state || atomic_read(&inode->i_count)) {
 			list_move(&inode->i_list, &inode_unused);
 			continue;
 		}
-		if (inode->i_data.nrpages) {
+		if (inode_has_buffers(inode) || inode->i_data.nrpages) {
 			__iget(inode);
 			spin_unlock(&inode_lock);
+			remove_inode_buffers(inode);
 			invalidate_inode_pages(&inode->i_data);
 			iput(inode);
 			spin_lock(&inode_lock);
@@ -415,8 +418,6 @@ static void prune_icache(int nr_to_scan)
 				continue;	/* wrong inode or list_empty */
 			if (!can_unuse(inode))
 				continue;
-			if (inode->i_data.nrpages)
-				continue;
 		}
 		list_del_init(&inode->i_hash);
 		list_move(&inode->i_list, &freeable);

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
