Received: from oscar.casa.dyndns.org ([65.92.166.161])
          by tomts22-srv.bellnexxia.net
          (InterMail vM.5.01.04.05 201-253-122-122-105-20011231) with ESMTP
          id <20020506011741.EKFQ17922.tomts22-srv.bellnexxia.net@oscar.casa.dyndns.org>
          for <linux-mm@kvack.org>; Sun, 5 May 2002 21:17:41 -0400
Received: from oscar (localhost [127.0.0.1])
	by oscar.casa.dyndns.org (Postfix) with ESMTP id B3D741750
	for <linux-mm@kvack.org>; Sun,  5 May 2002 21:17:17 -0400 (EDT)
Content-Type: text/plain;
  charset="us-ascii"
From: Ed Tomlinson <tomlins@cam.org>
Subject: [RFC][PATCH] dcache and rmap
Date: Sun, 5 May 2002 21:17:16 -0400
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Message-Id: <200205052117.16268.tomlins@cam.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, 

I got tired of finding my box with 50-60% percent of memory tied up in dentry/inode 
caches every morning after update-db runs or after doing a find / -name "*" to generate
a list of files for backups.  So I decided to make a stab at fixing this.

The problem is that when there is not much memory pressure the vm is happy to let the
above caches expand and expand...  What I did was factored the shrink calls out of 
do_try_to_free_pages and placed an additional call to shrink in kswapd which can get
called if kswapd does not need to use do_try_to_free_pages.

The issue then becomes when to call the new shrink_caches function?  I changed the
dcache logic to estimate and track the number of new pages alloced to dentries.  Once a
threshold is exceeded, kswapd calls shrink_caches.   Using a threshold of 32 pages works
well here.

Patch is against 19-pre7-ac2. 

Comments?
Ed Tomlinson

# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.422   -> 1.425  
#	         fs/dcache.c	1.18    -> 1.21   
#	         mm/vmscan.c	1.60    -> 1.61   
#	include/linux/dcache.h	1.11    -> 1.12   
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 02/05/04	ed@oscar.et.ca	1.423
# Modify the cache shrinking logic to apply pressure when the dcache
# grows by more than <n> pages (currently 32).  Note the slab growth
# detection code, though not perfect, is okay for this use.
# --------------------------------------------
# 02/05/04	ed@oscar.et.ca	1.424
# Fix comments
# --------------------------------------------
# 02/05/04	ed@oscar.et.ca	1.425
# grammar
# --------------------------------------------
#
diff -Nru a/fs/dcache.c b/fs/dcache.c
--- a/fs/dcache.c	Sat May  4 23:17:36 2002
+++ b/fs/dcache.c	Sat May  4 23:17:36 2002
@@ -305,6 +305,22 @@
 	spin_lock(&dcache_lock);
 }
 
+
+/**
+ * Have we allocated over n pages worth of
+ * dentries entries? 
+ */
+
+#define DENTRIES_PER_PAGE (PAGE_SIZE/(sizeof(struct dentry)+8))
+
+static int dcache_alloc_count = 0;
+
+int try_to_shrink(int pages)
+{ 
+	return dcache_alloc_count > pages; 
+}
+
+
 /**
  * prune_dcache - shrink the dcache
  * @count: number of entries to try and free
@@ -567,7 +583,13 @@
 
 	count = dentry_stat.nr_unused / priority;
 
-	prune_dcache(count);
+	prune_dcache(count); 
+
+	/*
+	 * relieve some pressure...
+	 */
+	dcache_alloc_count /= 2;
+
 	return kmem_cache_shrink_nr(dentry_cache);
 }
 
@@ -585,8 +607,17 @@
  
 struct dentry * d_alloc(struct dentry * parent, const struct qstr *name)
 {
+	static int nr_entry_base = 0;
 	char * str;
 	struct dentry *dentry;
+ 
+	if (dentry_stat.nr_dentry < nr_entry_base) 
+		nr_entry_base = dentry_stat.nr_dentry;
+		  
+	if (dentry_stat.nr_dentry-nr_entry_base > DENTRIES_PER_PAGE) {
+	        dcache_alloc_count++;
+		nr_entry_base = dentry_stat.nr_dentry;
+	}
 
 	dentry = kmem_cache_alloc(dentry_cache, GFP_KERNEL); 
 	if (!dentry)
diff -Nru a/include/linux/dcache.h b/include/linux/dcache.h
--- a/include/linux/dcache.h	Sat May  4 23:17:36 2002
+++ b/include/linux/dcache.h	Sat May  4 23:17:36 2002
@@ -173,6 +173,7 @@
 /* dcache memory management */
 extern int shrink_dcache_memory(int, unsigned int);
 extern void prune_dcache(int);
+extern int try_to_shink(int);
 
 /* icache memory management (defined in linux/fs/inode.c) */
 extern int shrink_icache_memory(int, int);
diff -Nru a/mm/vmscan.c b/mm/vmscan.c
--- a/mm/vmscan.c	Sat May  4 23:17:36 2002
+++ b/mm/vmscan.c	Sat May  4 23:17:36 2002
@@ -562,6 +562,24 @@
 		if (inactive_high(zone) > 0)
 			refill_inactive_zone(zone, priority);
 }
+	
+static int shrink_caches(unsigned int pri, unsigned int gfp_mask)
+{
+	int ret = 0;
+
+        /*
+         * Eat memory from 
+         * dentry, inode and filesystem quota caches.
+         */
+        ret += shrink_dcache_memory(pri, gfp_mask);
+        ret += shrink_icache_memory(1, gfp_mask);
+#ifdef CONFIG_QUOTA
+        ret += shrink_dqcache_memory(pri, gfp_mask);
+#endif
+
+	return ret;
+}
+
 
 /*
  * Worker function for kswapd and try_to_free_pages, we get
@@ -571,6 +589,7 @@
  * This function will also move pages to the inactive list,
  * if needed.
  */
+
 static int do_try_to_free_pages(unsigned int gfp_mask)
 {
 	int ret = 0;
@@ -580,11 +599,7 @@
 	 * dentry, inode and filesystem quota caches.
 	 */
 	ret += page_launder(gfp_mask);
-	ret += shrink_dcache_memory(DEF_PRIORITY, gfp_mask);
-	ret += shrink_icache_memory(1, gfp_mask);
-#ifdef CONFIG_QUOTA
-	ret += shrink_dqcache_memory(DEF_PRIORITY, gfp_mask);
-#endif
+	ret += shrink_caches(DEF_PRIORITY, gfp_mask);
 
 	/*
 	 * Move pages from the active list to the inactive list.
@@ -653,6 +668,9 @@
  * If there are applications that are active memory-allocators
  * (most normal use), this basically shouldn't matter.
  */
+
+#define DCACHE_PAGES (32) 
+
 int kswapd(void *unused)
 {
 	struct task_struct *tsk = current;
@@ -691,6 +709,9 @@
 		 */
 		if (free_high(ALL_ZONES) >= 0 || free_low(ANY_ZONE) > 0)
 			do_try_to_free_pages(GFP_KSWAPD);
+		else 
+			if (try_to_shrink(DCACHE_PAGES))
+				shrink_caches(DEF_PRIORITY, GFP_KSWAPD);
 
 		refill_freelist();

 -----------------------------


 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
