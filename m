Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: Re: inode/dentry pressure
Date: Wed, 16 May 2001 23:26:49 -0400
References: <Pine.GSO.4.21.0105161932260.26191-100000@weyl.math.psu.edu>
In-Reply-To: <Pine.GSO.4.21.0105161932260.26191-100000@weyl.math.psu.edu>
MIME-Version: 1.0
Message-Id: <01051623264900.02257@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexander Viro <viro@math.psu.edu>, Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wednesday 16 May 2001 19:34, Alexander Viro wrote:
> On Wed, 16 May 2001, Rik van Riel wrote:
> > If we cannot find an easy to implement Real Solution(tm) we
> > should probably go for the 10% limit in 2.4 and implement the
> > real solution in 2.5; if anybody has a 2.4-attainable idea
> > I'd like to hear about it ;)
>
> Rip the crap from icache hard, fast and often. _Any_ inode with
> no dentry is fair game as soon as it's clean. Keep in mind
> that icache is a secondary cache - we are talking about the
> stuff dcache didn't want to keep.

I have been running with this patch for the last few weeks.  It 
adds a call to kswapd that prunes dead dentries quickly.  Think it
qualifies as something that does "Rip the crap from icache hard, 
fast and often". 

Comments?

Ed Tomlinson

--- 2.4.4-pre7/include/linux/dcache.h	Thu Apr 26 12:57:47 2001
+++ linux/include/linux/dcache.h	Fri Apr 27 18:17:20 2001
@@ -176,6 +176,7 @@

 /* icache memory management (defined in linux/fs/inode.c) */
 extern void shrink_icache_memory(int, int);
+extern void shrink_unused_icache_memory(int);
 extern void prune_icache(int);

 /* only used at mount-time */
--- 2.4.4-pre7/mm/vmscan.c	Fri Apr 27 11:36:04 2001
+++ linux/mm/vmscan.c	Fri Apr 27 18:33:07 2001
@@ -953,6 +953,11 @@
 		 */
 		refill_inactive_scan(DEF_PRIORITY, 0);

+		/*
+		 * Free unused inodes.
+		 */
+		shrink_unused_icache_memory(GFP_KSWAPD);
+
 		/* Once a second, recalculate some VM stats. */
 		if (time_after(jiffies, recalc + HZ)) {
 			recalc = jiffies;
--- 2.4.4-pre7/fs/inode.c	Thu Apr 26 12:49:33 2001
+++ linux/fs/inode.c	Fri Apr 27 18:54:25 2001
@@ -540,16 +540,16 @@
 	 !inode_has_buffers(inode))
 #define INODE(entry)	(list_entry(entry, struct inode, i_list))

-void prune_icache(int goal)
+/*
+ * Called with inode lock held, returns with it released.
+ */
+int prune_unused_icachei_unlock(int goal)
 {
 	LIST_HEAD(list);
 	struct list_head *entry, *freeable = &list;
-	int count = 0, synced = 0;
+	int count = 0;
 	struct inode * inode;

-	spin_lock(&inode_lock);
-
-free_unused:
 	entry = inode_unused.prev;
 	while (entry != &inode_unused)
 	{
@@ -577,19 +577,27 @@

 	dispose_list(freeable);

+	return count;
+}
+
+/*
+ * A goal of zero frees everything
+ */
+void prune_icache(int goal)
+{
+	spin_lock(&inode_lock);
+	goal -= prune_unused_icachei_unlock(goal);
+
 	/*
 	 * If we freed enough clean inodes, avoid writing
-	 * dirty ones. Also giveup if we already tried to
-	 * sync dirty inodes.
+	 * dirty ones.
 	 */
-	if (!goal || synced)
+	if (!goal)
 		return;

-	synced = 1;
-
 	spin_lock(&inode_lock);
 	try_to_sync_unused_inodes();
-	goto free_unused;
+ 	prune_unused_icache_unlock(goal);
 }

 void shrink_icache_memory(int priority, int gfp_mask)
@@ -611,6 +619,20 @@

 	prune_icache(count);
 	kmem_cache_shrink(inode_cachep);
+}
+
+void shrink_unused_icache_memory(int gfp_mask)
+{
+	/*
+	 * Nasty deadlock avoidance..
+	 */
+	if (!(gfp_mask & __GFP_IO))
+		return;
+
+	if (spin_trylock(&inode_lock)) {
+		prune_unused_icache_unlock(0);
+		kmem_cache_shrink(inode_cachep);
+	}
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
