Content-Type: text/plain;
  charset="iso-8859-1"
From: Ed Tomlinson <tomlins@cam.org>
Subject: [PATCH][RFC] appling pressure to icache and dcache - simplified
Date: Sat, 7 Apr 2001 15:45:28 -0400
MIME-Version: 1.0
Message-Id: <01040507463401.00699@oscar>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi,

Rik asked, "Can it be made simpler?"

So I went back to the basics, inserted a printk in kswapd and watched
the dentry_stat and inodes_stat numbers for a while.   I observed
the following pattern.  The dentry cache grows as does the number of 
unused entries in it.  Unless we shrink this cache objects do not seem
to be reused.  At the same time the inode cache usually kept about 15% 
free.

At this point I starting to shrink the dcache.  The goal being to keep 
the size of the cache as observed in /proc/slabinfo reasonable without 
much overhead.  From experimenting, it turns out that if the shrink
call is made when there is over 50% free space the cache stays small.
Using 66% is not quite as aggressive but achieves its effect with about
half the shrink calls.

With the pressure on the dcache, I looked at the icache numbers.  With  
the dcache shrinking the amount of free space in the icache was much 
higher.  It turns out that using the same logic as above with, 80% as 
the amount of free space, it works well.

Here are the results against 2.4.3-ac3

Thoughs?

-----
--- linux.ac3.orig/mm/vmscan.c	Sat Apr  7 15:20:49 2001
+++ linux/mm/vmscan.c	Sat Apr  7 12:37:27 2001
@@ -997,6 +997,21 @@
 		 */
 		refill_inactive_scan(DEF_PRIORITY, 0);
 
+		/* 
+		 * Here we apply pressure to the dcache and icache.
+		 * The nr_inodes and nr_dentry track the used part of
+		 * the slab caches.  When there is more than X% objs free
+		 * in these lists, as reported by the nr_unused fields,
+		 * there is a very good chance that shrinking will free
+		 * pages from the slab caches.  For the dcache 66% works,
+		 * and 80% seems optimal for the icache.
+		 */
+
+		if ((dentry_stat.nr_unused+(dentry_stat.nr_unused>>1)) > dentry_stat.nr_dentry)
+			shrink_dcache_memory(DEF_PRIORITY, GFP_KSWAPD);
+		if ((inodes_stat.nr_unused+(inodes_stat.nr_unused>>2)) > inodes_stat.nr_inodes)
+			shrink_icache_memory(DEF_PRIORITY, GFP_KSWAPD);
+
 		/* Once a second, recalculate some VM stats. */
 		if (time_after(jiffies, recalc + HZ)) {
 			recalc = jiffies;
-----

Ed Tomlinson <tomlins@cam.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
