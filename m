Subject: PATCH: Making the VM pressure consistent for dcache and icache
From: "Juan J. Quintela" <quintela@fi.udc.es>
Date: 22 May 2000 17:17:55 +0200
Message-ID: <yttn1li7gws.fsf@serpe.mitica>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, Linus Torvalds <torvalds@transmeta.com>, alviro@redhat.com
List-ID: <linux-mm.kvack.org>

Hi
        I have made a patch to make the pressure for freeing pages
consistent with the rest of the kernel for the dcache and the
icache.  In the rest of the kernel we do:

         count = number allocated / (priority + 1)

This also removes the need for the if's.  It is some reason to have the
code this way, or it is better to make the same pressure to all the
subsystems?

Comment?

Later, Juan.

PD.  I have sent the patch also to Al Viro because I don't know if the
     patches about the dcache, icache are sent through Al Viro or
     directly to Linus.

diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/fs/dcache.c testing/fs/dcache.c
--- base/fs/dcache.c	Sun May 21 17:38:00 2000
+++ testing/fs/dcache.c	Mon May 22 16:59:23 2000
@@ -494,10 +494,8 @@
  */
 int shrink_dcache_memory(int priority, unsigned int gfp_mask)
 {
-	int count = 0;
+	int count = dentry_stat.nr_unused / (priority + 1);
 	lock_kernel();
-	if (priority)
-		count = dentry_stat.nr_unused / priority;
 	prune_dcache(count);
 	unlock_kernel();
 	/* FIXME: kmem_cache_shrink here should tell us
diff -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude base/fs/inode.c testing/fs/inode.c
--- base/fs/inode.c	Sun May 21 17:38:00 2000
+++ testing/fs/inode.c	Mon May 22 16:59:23 2000
@@ -411,11 +411,10 @@
 	(((inode)->i_state | (inode)->i_data.nrpages) == 0)
 #define INODE(entry)	(list_entry(entry, struct inode, i_list))
 
-void prune_icache(int goal)
+void prune_icache(int count)
 {
 	LIST_HEAD(list);
 	struct list_head *entry, *freeable = &list;
-	int count = 0;
 	struct inode * inode;
 
 	spin_lock(&inode_lock);
@@ -440,11 +439,10 @@
 		INIT_LIST_HEAD(&inode->i_hash);
 		list_add(tmp, freeable);
 		inode->i_state |= I_FREEING;
-		count++;
-		if (!--goal)
+		inodes_stat.nr_unused--;
+		if (!--count)
 			break;
 	}
-	inodes_stat.nr_unused -= count;
 	spin_unlock(&inode_lock);
 
 	dispose_list(freeable);
@@ -452,10 +450,7 @@
 
 int shrink_icache_memory(int priority, int gfp_mask)
 {
-	int count = 0;
-		
-	if (priority)
-		count = inodes_stat.nr_unused / priority;
+	int count = inodes_stat.nr_unused / (priority + 1);
 	prune_icache(count);
 	/* FIXME: kmem_cache_shrink here should tell us
 	   the number of pages freed, and it should









-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
