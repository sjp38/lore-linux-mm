From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Date: Fri, 14 Sep 2007 16:54:05 -0400
Message-Id: <20070914205405.6536.37532.sendpatchset@localhost>
In-Reply-To: <20070914205359.6536.98017.sendpatchset@localhost>
References: <20070914205359.6536.98017.sendpatchset@localhost>
Subject: [PATCH/RFC 1/14] Reclaim Scalability:  Convert anon_vma lock to read/write lock
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

[PATCH/RFC] 01/14 Reclaim Scalability:  Convert anon_vma list lock a read/write lock

Against 2.6.23-rc4-mm1

Make the anon_vma list lock a read/write lock.  Heaviest use of this
lock is in the page_referenced()/try_to_unmap() calls from vmscan
[shrink_page_list()].  These functions can use a read lock to allow
some parallelism for different cpus trying to reclaim pages mapped
via the same set of vmas.

This change should not change the footprint of the anon_vma in the
non-debug case.

Note:  I have seen systems livelock with all cpus in reclaim, down
in page_referenced_anon() or try_to_unmap_anon() spinning on the
anon_vma lock.  I have only seen this with the AIM7 benchmark with
workloads of 10s of thousands of tasks.  All of these tasks are
children of a single ancestor, so they all share the same anon_vma
for each vm area in their respective mm's.  I'm told that Apache
can fork thousands of children to handle incoming connections, and
I've seen similar livelocks--albeit on the i_mmap_lock [next patch]
running 1000s of Oracle users on a large ia64 platform.

With this patch [along with Rik van Riel's split LRU patch] we were
able to see the AIM7 workload start swapping, instead of hanging,
for the first time.  Same workload DID hang with just Rik's patch,
so this patch is apparently useful.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/rmap.h |    9 ++++++---
 mm/migrate.c         |    4 ++--
 mm/mmap.c            |    4 ++--
 mm/rmap.c            |   20 ++++++++++----------
 4 files changed, 20 insertions(+), 17 deletions(-)

Index: Linux/include/linux/rmap.h
===================================================================
--- Linux.orig/include/linux/rmap.h	2007-09-10 10:09:47.000000000 -0400
+++ Linux/include/linux/rmap.h	2007-09-10 11:43:11.000000000 -0400
@@ -25,7 +25,7 @@
  * pointing to this anon_vma once its vma list is empty.
  */
 struct anon_vma {
-	spinlock_t lock;	/* Serialize access to vma list */
+	rwlock_t rwlock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
 };
 
@@ -43,18 +43,21 @@ static inline void anon_vma_free(struct 
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
+/*
+ * This needs to be a write lock for __vma_link()
+ */
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->rwlock);
 }
 
 static inline void anon_vma_unlock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->rwlock);
 }
 
 /*
Index: Linux/mm/rmap.c
===================================================================
--- Linux.orig/mm/rmap.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/rmap.c	2007-09-10 11:43:11.000000000 -0400
@@ -25,7 +25,7 @@
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
  *       mapping->i_mmap_lock
- *         anon_vma->lock
+ *         anon_vma->rwlock
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
@@ -68,7 +68,7 @@ int anon_vma_prepare(struct vm_area_stru
 		if (anon_vma) {
 			allocated = NULL;
 			locked = anon_vma;
-			spin_lock(&locked->lock);
+			write_lock(&locked->rwlock);
 		} else {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
@@ -87,7 +87,7 @@ int anon_vma_prepare(struct vm_area_stru
 		spin_unlock(&mm->page_table_lock);
 
 		if (locked)
-			spin_unlock(&locked->lock);
+			write_unlock(&locked->rwlock);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
@@ -113,9 +113,9 @@ void anon_vma_link(struct vm_area_struct
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->rwlock);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->rwlock);
 	}
 }
 
@@ -127,12 +127,12 @@ void anon_vma_unlink(struct vm_area_stru
 	if (!anon_vma)
 		return;
 
-	spin_lock(&anon_vma->lock);
+	write_lock(&anon_vma->rwlock);
 	list_del(&vma->anon_vma_node);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
-	spin_unlock(&anon_vma->lock);
+	write_unlock(&anon_vma->rwlock);
 
 	if (empty)
 		anon_vma_free(anon_vma);
@@ -143,7 +143,7 @@ static void anon_vma_ctor(void *data, st
 {
 	struct anon_vma *anon_vma = data;
 
-	spin_lock_init(&anon_vma->lock);
+ 	rwlock_init(&anon_vma->rwlock);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -170,7 +170,7 @@ static struct anon_vma *page_lock_anon_v
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	read_lock(&anon_vma->rwlock);
 	return anon_vma;
 out:
 	rcu_read_unlock();
@@ -179,7 +179,7 @@ out:
 
 static void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->lock);
+	read_unlock(&anon_vma->rwlock);
 	rcu_read_unlock();
 }
 
Index: Linux/mm/mmap.c
===================================================================
--- Linux.orig/mm/mmap.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/mmap.c	2007-09-10 11:43:11.000000000 -0400
@@ -570,7 +570,7 @@ again:			remove_next = 1 + (end > next->
 	if (vma->anon_vma)
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->rwlock);
 		/*
 		 * Easily overlooked: when mprotect shifts the boundary,
 		 * make sure the expanding vma has anon_vma set if the
@@ -624,7 +624,7 @@ again:			remove_next = 1 + (end > next->
 	}
 
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->rwlock);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-09-10 10:09:47.000000000 -0400
+++ Linux/mm/migrate.c	2007-09-10 11:43:11.000000000 -0400
@@ -234,12 +234,12 @@ static void remove_anon_migration_ptes(s
 	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
 	 */
 	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	read_lock(&anon_vma->rwlock);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
 		remove_migration_pte(vma, old, new);
 
-	spin_unlock(&anon_vma->lock);
+	read_unlock(&anon_vma->rwlock);
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
