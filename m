Subject: Re: pre8: where has the anti-hog code gone?
References: <m12qjP0-000OVtC@amadeus.home.nl>
From: "Juan J. Quintela" <quintela@fi.udc.es>
In-Reply-To: arjan@fenrus.demon.nl's message of "Sat, 13 May 2000 23:24:50 +0200 (CEST)"
Date: 13 May 2000 23:59:42 +0200
Message-ID: <yttn1lu2jsh.fsf@vexeta.dc.fi.udc.es>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@fenrus.demon.nl>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>>>>> "arjan" == Arjan van de Ven <arjan@fenrus.demon.nl> writes:

Hi

arjan> I have been looking at it right now, and I think there are a few issues:

arjan> 1) shrink_[id]node_memory always return 0, even if they free memory
arjan> 2) shrink_inode_memory is broken for priority == 0

arjan> 2) is easily fixable, but even with that fixed, my traces show that, for the
arjan> mmap002 test, shrink_mmap fails just before the OOM.

After discussing with Arjan that changes. And later discussing with riel
about that we _need_ to swap_out more pages that we scan, because some
of the pages can be reclaimed, I made the following patch.  Now things
go better, not well, but better.

Now mmap002 finish sometimes, (where some is a low number).

The important part of the patch is the change in SWAP_COUNT, only
changing that number, I get better behaviour (thanks riel for
suggesting that).

The other patch is to make shrink_[di]cache to behave like the rest of
the shrink* functions and do the *maximum* effort when priority = 0,
not when priority = 1.  This last change improves things only a bit.

Comments?

Later, Juan.

diff -u -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-1/fs/dcache.c testing/fs/dcache.c
--- pre9-1/fs/dcache.c	Fri May 12 01:11:40 2000
+++ testing/fs/dcache.c	Sat May 13 21:58:41 2000
@@ -497,10 +497,8 @@
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
diff -u -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-1/fs/inode.c testing/fs/inode.c
--- pre9-1/fs/inode.c	Fri May 12 01:11:40 2000
+++ testing/fs/inode.c	Sat May 13 22:35:51 2000
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
diff -u -urN --exclude-from=/home/lfcia/quintela/work/kernel/exclude pre9-1/mm/vmscan.c testing/mm/vmscan.c
--- pre9-1/mm/vmscan.c	Sat May 13 19:30:06 2000
+++ testing/mm/vmscan.c	Sat May 13 23:17:22 2000
@@ -430,7 +430,7 @@
  * latency.
  */
 #define FREE_COUNT	8
-#define SWAP_COUNT	8
+#define SWAP_COUNT	16
 static int do_try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;





-- 
In theory, practice and theory are the same, but in practice they 
are different -- Larry McVoy
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
