Message-ID: <410787BF.8070402@yahoo.com.au>
Date: Wed, 28 Jul 2004 21:02:23 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: [PATCH 1/2] make shrinker_sem an rwsem
Content-Type: multipart/mixed;
 boundary="------------080902050801010709080109"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------080902050801010709080109
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Making shrinker_sem an rwsem allows tasks in shrink_slab to be preempted
or cond_resched'ed without slab reclaim grinding to a halt.


--------------080902050801010709080109
Content-Type: text/x-patch;
 name="vm-shrink-slab-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-shrink-slab-fix.patch"



Use an rwsem to protect the shrinker list instead of a regular semaphore.
Modifications to the list are now done under the write lock, shrink_slab
takes the read lock, and access to shrinker->nr becomes racy (which is no
different to how we scan zones). The shrinker->shrinker function also becomes
concurrent.

Previously, having the slab scanner get preempted or scheduling while holding
the semaphore would cause other tasks to skip putting pressure on the slab.

Also, make shrink_icache_memory return -1 if it can't do anything in order to
hold pressure on this cache and prevent useless looping in shrink_slab.

Signed-off-by: Nick Piggin <nickpiggin@yahoo.com.au>


---

 linux-2.6-npiggin/fs/inode.c  |    5 +++--
 linux-2.6-npiggin/mm/vmscan.c |   39 +++++++++++++++++++++++----------------
 2 files changed, 26 insertions(+), 18 deletions(-)

diff -puN mm/vmscan.c~vm-shrink-slab-fix mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-shrink-slab-fix	2004-07-28 20:52:20.000000000 +1000
+++ linux-2.6-npiggin/mm/vmscan.c	2004-07-28 21:02:05.000000000 +1000
@@ -32,6 +32,7 @@
 #include <linux/topology.h>
 #include <linux/cpu.h>
 #include <linux/notifier.h>
+#include <linux/rwsem.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -122,7 +123,7 @@ int vm_swappiness = 60;
 static long total_memory;
 
 static LIST_HEAD(shrinker_list);
-static DECLARE_MUTEX(shrinker_sem);
+static DECLARE_RWSEM(shrinker_rwsem);
 
 /*
  * Add a shrinker callback to be called from the vm
@@ -136,9 +137,9 @@ struct shrinker *set_shrinker(int seeks,
 	        shrinker->shrinker = theshrinker;
 	        shrinker->seeks = seeks;
 	        shrinker->nr = 0;
-	        down(&shrinker_sem);
+	        down_write(&shrinker_rwsem);
 	        list_add(&shrinker->list, &shrinker_list);
-	        up(&shrinker_sem);
+	        up_write(&shrinker_rwsem);
 	}
 	return shrinker;
 }
@@ -149,13 +150,13 @@ EXPORT_SYMBOL(set_shrinker);
  */
 void remove_shrinker(struct shrinker *shrinker)
 {
-	down(&shrinker_sem);
+	down_write(&shrinker_rwsem);
 	list_del(&shrinker->list);
-	up(&shrinker_sem);
+	up_write(&shrinker_rwsem);
 	kfree(shrinker);
 }
 EXPORT_SYMBOL(remove_shrinker);
- 
+
 #define SHRINK_BATCH 128
 /*
  * Call the shrink functions to age shrinkable caches
@@ -175,12 +176,16 @@ static int shrink_slab(unsigned long sca
 	struct shrinker *shrinker;
 	long pages;
 
-	if (down_trylock(&shrinker_sem))
+	if (scanned == 0)
+		return;
+
+	if (!down_read_trylock(&shrinker_rwsem))
 		return 0;
 
 	pages = nr_used_zone_pages();
 	list_for_each_entry(shrinker, &shrinker_list, list) {
 		unsigned long long delta;
+		unsigned long total_scan;
 
 		delta = (4 * scanned) / shrinker->seeks;
 		delta *= (*shrinker->shrinker)(0, gfp_mask);
@@ -189,23 +194,25 @@ static int shrink_slab(unsigned long sca
 		if (shrinker->nr < 0)
 			shrinker->nr = LONG_MAX;	/* It wrapped! */
 
-		if (shrinker->nr <= SHRINK_BATCH)
-			continue;
-		while (shrinker->nr) {
-			long this_scan = shrinker->nr;
+		total_scan = shrinker->nr;
+		shrinker->nr = 0;
+
+		while (total_scan >= SHRINK_BATCH) {
+			long this_scan = SHRINK_BATCH;
 			int shrink_ret;
 
-			if (this_scan > 128)
-				this_scan = 128;
 			shrink_ret = (*shrinker->shrinker)(this_scan, gfp_mask);
-			mod_page_state(slabs_scanned, this_scan);
-			shrinker->nr -= this_scan;
 			if (shrink_ret == -1)
 				break;
+			mod_page_state(slabs_scanned, this_scan);
+			total_scan -= this_scan;
+
 			cond_resched();
 		}
+
+		shrinker->nr += total_scan;
 	}
-	up(&shrinker_sem);
+	up_read(&shrinker_rwsem);
 	return 0;
 }
 
diff -puN fs/inode.c~vm-shrink-slab-fix fs/inode.c
--- linux-2.6/fs/inode.c~vm-shrink-slab-fix	2004-07-28 20:52:20.000000000 +1000
+++ linux-2.6-npiggin/fs/inode.c	2004-07-28 20:52:20.000000000 +1000
@@ -485,8 +485,9 @@ static int shrink_icache_memory(int nr, 
 		 * and we don't want to recurse into the FS that called us
 		 * in clear_inode() and friends..
 	 	 */
-		if (gfp_mask & __GFP_FS)
-			prune_icache(nr);
+		if (!(gfp_mask & __GFP_FS))
+			return -1;
+		prune_icache(nr);
 	}
 	return (inodes_stat.nr_unused / 100) * sysctl_vfs_cache_pressure;
 }

_

--------------080902050801010709080109--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
