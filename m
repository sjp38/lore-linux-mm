Subject: Re: [PATCH 01 of 16] remove nr_scan_inactive/active
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <468439E8.4040606@redhat.com>
References: <8e38f7656968417dfee0.1181332979@v2.random>
	 <466C36AE.3000101@redhat.com>	<20070610181700.GC7443@v2.random>
	 <46814829.8090808@redhat.com>
	 <20070626105541.cd82c940.akpm@linux-foundation.org>
	 <468439E8.4040606@redhat.com>
Content-Type: text/plain
Date: Fri, 29 Jun 2007 09:38:29 -0400
Message-Id: <1183124309.5037.31.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Nick Dokos <nicholas.dokos@hp.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2007-06-28 at 18:44 -0400, Rik van Riel wrote:
> Andrew Morton wrote:
> 
> > Where's the system time being spent?
> 
> OK, it turns out that there is quite a bit of variability
> in where the system spends its time.  I did a number of
> reaim runs and averaged the time the system spent in the
> top functions.
> 
> This is with the Fedora rawhide kernel config, which has
> quite a few debugging options enabled.
> 
> _raw_spin_lock		32.0%
> page_check_address	12.7%
> __delay			10.8%
> mwait_idle		10.4%
> anon_vma_unlink		5.7%
> __anon_vma_link		5.3%
> lockdep_reset_lock	3.5%
> __kmalloc_node_track_caller 2.8%
> security_port_sid	1.8%
> kfree			1.6%
> anon_vma_link		1.2%
> page_referenced_one	1.1%
> 
> In short, the system is waiting on the anon_vma lock.
> 
> I wonder if Lee Schemmerhorn's patch to turn that
> spinlock into an rwlock would help this workload,
> or if we simply should scan fewer pages in the
> pageout code.
> 

Rik:

Here's a fairly recent version of the patch if you want to try it on
your workload.  We've seen mixed results on somewhat larger systems,
with and without your split LRU patch.  I've started writing up those
results.  I'll try to get back to finishing up the writeup after OLS and
vacation.

Regards,
Lee

-----------
Patch against 2.6.22-rc4-mm2

Make the anon_vma list lock a read/write lock.  Heaviest use of this
lock is in the page_referenced()/try_to_unmap() calls from vmscan
[shrink_page_list()].  These functions can use a read lock to allow
some parallelism for different cpus trying to reclaim pages mapped
via the same set of vmas.

This change should not change the footprint of the anon_vma in the
non-debug case.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 include/linux/rmap.h |    9 ++++++---
 mm/migrate.c         |    4 ++--
 mm/mmap.c            |    4 ++--
 mm/rmap.c            |   20 ++++++++++----------
 4 files changed, 20 insertions(+), 17 deletions(-)

Index: Linux/include/linux/rmap.h
===================================================================
--- Linux.orig/include/linux/rmap.h	2007-06-11 14:39:56.000000000 -0400
+++ Linux/include/linux/rmap.h	2007-06-20 09:49:24.000000000 -0400
@@ -24,7 +24,7 @@
  * pointing to this anon_vma once its vma list is empty.
  */
 struct anon_vma {
-	spinlock_t lock;	/* Serialize access to vma list */
+	rwlock_t rwlock;	/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
 };
 
@@ -42,18 +42,21 @@ static inline void anon_vma_free(struct 
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
--- Linux.orig/mm/rmap.c	2007-06-11 14:40:06.000000000 -0400
+++ Linux/mm/rmap.c	2007-06-20 09:50:27.000000000 -0400
@@ -25,7 +25,7 @@
  *   mm->mmap_sem
  *     page->flags PG_locked (lock_page)
  *       mapping->i_mmap_lock
- *         anon_vma->lock
+ *         anon_vma->rwlock
  *           mm->page_table_lock or pte_lock
  *             zone->lru_lock (in mark_page_accessed, isolate_lru_page)
  *             swap_lock (in swap_duplicate, swap_info_get)
@@ -85,7 +85,7 @@ int anon_vma_prepare(struct vm_area_stru
 		if (anon_vma) {
 			allocated = NULL;
 			locked = anon_vma;
-			spin_lock(&locked->lock);
+			write_lock(&locked->rwlock);
 		} else {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
@@ -104,7 +104,7 @@ int anon_vma_prepare(struct vm_area_stru
 		spin_unlock(&mm->page_table_lock);
 
 		if (locked)
-			spin_unlock(&locked->lock);
+			write_unlock(&locked->rwlock);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
@@ -132,10 +132,10 @@ void anon_vma_link(struct vm_area_struct
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->rwlock);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
 		validate_anon_vma(vma);
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->rwlock);
 	}
 }
 
@@ -147,13 +147,13 @@ void anon_vma_unlink(struct vm_area_stru
 	if (!anon_vma)
 		return;
 
-	spin_lock(&anon_vma->lock);
+	write_lock(&anon_vma->rwlock);
 	validate_anon_vma(vma);
 	list_del(&vma->anon_vma_node);
 
 	/* We must garbage collect the anon_vma if it's empty */
 	empty = list_empty(&anon_vma->head);
-	spin_unlock(&anon_vma->lock);
+	write_unlock(&anon_vma->rwlock);
 
 	if (empty)
 		anon_vma_free(anon_vma);
@@ -164,7 +164,7 @@ static void anon_vma_ctor(void *data, st
 {
 	struct anon_vma *anon_vma = data;
 
-	spin_lock_init(&anon_vma->lock);
+ 	rwlock_init(&anon_vma->rwlock);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -191,7 +191,7 @@ static struct anon_vma *page_lock_anon_v
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	read_lock(&anon_vma->rwlock);
 	return anon_vma;
 out:
 	rcu_read_unlock();
@@ -200,7 +200,7 @@ out:
 
 static void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->lock);
+	read_unlock(&anon_vma->rwlock);
 	rcu_read_unlock();
 }
 
Index: Linux/mm/mmap.c
===================================================================
--- Linux.orig/mm/mmap.c	2007-06-20 09:39:03.000000000 -0400
+++ Linux/mm/mmap.c	2007-06-20 09:49:24.000000000 -0400
@@ -571,7 +571,7 @@ again:			remove_next = 1 + (end > next->
 	if (vma->anon_vma)
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		write_lock(&anon_vma->rwlock);
 		/*
 		 * Easily overlooked: when mprotect shifts the boundary,
 		 * make sure the expanding vma has anon_vma set if the
@@ -625,7 +625,7 @@ again:			remove_next = 1 + (end > next->
 	}
 
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		write_unlock(&anon_vma->rwlock);
 	if (mapping)
 		spin_unlock(&mapping->i_mmap_lock);
 
Index: Linux/mm/migrate.c
===================================================================
--- Linux.orig/mm/migrate.c	2007-06-20 09:39:04.000000000 -0400
+++ Linux/mm/migrate.c	2007-06-20 09:49:24.000000000 -0400
@@ -228,12 +228,12 @@ static void remove_anon_migration_ptes(s
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
