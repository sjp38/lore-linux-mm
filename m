From: Christoph Lameter <clameter@sgi.com>
Subject: [ofa-general] [patch 06/10] emm: Convert anon_vma lock to rw_sem and
	refcount
Date: Fri, 04 Apr 2008 15:30:54 -0700
Message-ID: <20080404223132.477298248@sgi.com>
References: <20080404223048.374852899@sgi.com>
Return-path: <general-bounces@lists.openfabrics.org>
Content-Disposition: inline; filename=emm_anon_vma_sem
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org
List-Id: linux-mm.kvack.org

Convert the anon_vma spinlock to a rw semaphore. This allows concurrent
traversal of reverse maps for try_to_unmap and page_mkclean. It also
allows the calling of sleeping functions from reverse map traversal.

An additional complication is that rcu is used in some context to guarantee
the presence of the anon_vma while we acquire the lock. We cannot take a
semaphore within an rcu critical section. Add a refcount to the anon_vma
structure which allow us to give an existence guarantee for the anon_vma
structure independent of the spinlock or the list contents.

The refcount can then be taken within the RCU section. If it has been
taken successfully then the refcount guarantees the existence of the
anon_vma. The refcount in anon_vma also allows us to fix a nasty
issue in page migration where we fudged by using rcu for a long code
path to guarantee the existence of the anon_vma.

The refcount in general allows a shortening of RCU critical sections since
we can do a rcu_unlock after taking the refcount. This is particularly
relevant if the anon_vma chains contain hundreds of entries.

Issues:
- Atomic overhead increases in situations where a new reference
  to the anon_vma has to be established or removed. Overhead also increases
  when a speculative reference is used (try_to_unmap,
  page_mkclean, page migration). There is also the more frequent processor
  change due to up_xxx letting waiting tasks run first.
  This results in f.e. the Aim9 brk performance test to got down by 10-15%.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

---
 include/linux/rmap.h |   20 ++++++++++++++++---
 mm/migrate.c         |   26 ++++++++++---------------
 mm/mmap.c            |   28 +++++++++++++-------------
 mm/rmap.c            |   53 +++++++++++++++++++++++++++++----------------------
 4 files changed, 73 insertions(+), 54 deletions(-)

Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h	2008-04-04 15:09:45.403759876 -0700
+++ linux-2.6/include/linux/rmap.h	2008-04-04 15:16:54.318714568 -0700
@@ -25,7 +25,8 @@
  * pointing to this anon_vma once its vma list is empty.
  */
 struct anon_vma {
-	spinlock_t lock;	/* Serialize access to vma list */
+	atomic_t refcount;	/* vmas on the list */
+	struct rw_semaphore sem;/* Serialize access to vma list */
 	struct list_head head;	/* List of private "related" vmas */
 };
 
@@ -43,18 +44,31 @@ static inline void anon_vma_free(struct 
 	kmem_cache_free(anon_vma_cachep, anon_vma);
 }
 
+struct anon_vma *grab_anon_vma(struct page *page);
+
+static inline void get_anon_vma(struct anon_vma *anon_vma)
+{
+	atomic_inc(&anon_vma->refcount);
+}
+
+static inline void put_anon_vma(struct anon_vma *anon_vma)
+{
+	if (atomic_dec_and_test(&anon_vma->refcount))
+		anon_vma_free(anon_vma);
+}
+
 static inline void anon_vma_lock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_lock(&anon_vma->lock);
+		down_write(&anon_vma->sem);
 }
 
 static inline void anon_vma_unlock(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		up_write(&anon_vma->sem);
 }
 
 /*
Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2008-04-04 15:09:45.443760619 -0700
+++ linux-2.6/mm/migrate.c	2008-04-04 15:16:54.318714568 -0700
@@ -235,15 +235,16 @@ static void remove_anon_migration_ptes(s
 		return;
 
 	/*
-	 * We hold the mmap_sem lock. So no need to call page_lock_anon_vma.
+	 * We hold either the mmap_sem lock or a reference on the
+	 * anon_vma. So no need to call page_lock_anon_vma.
 	 */
 	anon_vma = (struct anon_vma *) (mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
+	down_read(&anon_vma->sem);
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
 		remove_migration_pte(vma, old, new);
 
-	spin_unlock(&anon_vma->lock);
+	up_read(&anon_vma->sem);
 }
 
 /*
@@ -623,7 +624,7 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
-	int rcu_locked = 0;
+	struct anon_vma *anon_vma = NULL;
 	int charge = 0;
 
 	if (!newpage)
@@ -647,16 +648,14 @@ static int unmap_and_move(new_page_t get
 	}
 	/*
 	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
-	 * we cannot notice that anon_vma is freed while we migrates a page.
+	 * we cannot notice that anon_vma is freed while we migrate a page.
 	 * This rcu_read_lock() delays freeing anon_vma pointer until the end
 	 * of migration. File cache pages are no problem because of page_lock()
 	 * File Caches may use write_page() or lock_page() in migration, then,
 	 * just care Anon page here.
 	 */
-	if (PageAnon(page)) {
-		rcu_read_lock();
-		rcu_locked = 1;
-	}
+	if (PageAnon(page))
+		anon_vma = grab_anon_vma(page);
 
 	/*
 	 * Corner case handling:
@@ -674,10 +673,7 @@ static int unmap_and_move(new_page_t get
 		if (!PageAnon(page) && PagePrivate(page)) {
 			/*
 			 * Go direct to try_to_free_buffers() here because
-			 * a) that's what try_to_release_page() would do anyway
-			 * b) we may be under rcu_read_lock() here, so we can't
-			 *    use GFP_KERNEL which is what try_to_release_page()
-			 *    needs to be effective.
+			 * that's what try_to_release_page() would do anyway
 			 */
 			try_to_free_buffers(page);
 		}
@@ -698,8 +694,8 @@ static int unmap_and_move(new_page_t get
 	} else if (charge)
  		mem_cgroup_end_migration(newpage);
 rcu_unlock:
-	if (rcu_locked)
-		rcu_read_unlock();
+	if (anon_vma)
+		put_anon_vma(anon_vma);
 
 unlock:
 
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2008-04-04 15:09:45.451760720 -0700
+++ linux-2.6/mm/rmap.c	2008-04-04 15:16:54.318714568 -0700
@@ -68,7 +68,7 @@ int anon_vma_prepare(struct vm_area_stru
 		if (anon_vma) {
 			allocated = NULL;
 			locked = anon_vma;
-			spin_lock(&locked->lock);
+			down_write(&locked->sem);
 		} else {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
@@ -80,6 +80,7 @@ int anon_vma_prepare(struct vm_area_stru
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
+			get_anon_vma(anon_vma);
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
 			allocated = NULL;
@@ -87,7 +88,7 @@ int anon_vma_prepare(struct vm_area_stru
 		spin_unlock(&mm->page_table_lock);
 
 		if (locked)
-			spin_unlock(&locked->lock);
+			up_write(&locked->sem);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
@@ -98,14 +99,17 @@ void __anon_vma_merge(struct vm_area_str
 {
 	BUG_ON(vma->anon_vma != next->anon_vma);
 	list_del(&next->anon_vma_node);
+	put_anon_vma(vma->anon_vma);
 }
 
 void __anon_vma_link(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
 
-	if (anon_vma)
+	if (anon_vma) {
+		get_anon_vma(anon_vma);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
+	}
 }
 
 void anon_vma_link(struct vm_area_struct *vma)
@@ -113,36 +117,32 @@ void anon_vma_link(struct vm_area_struct
 	struct anon_vma *anon_vma = vma->anon_vma;
 
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		get_anon_vma(anon_vma);
+		down_write(&anon_vma->sem);
 		list_add_tail(&vma->anon_vma_node, &anon_vma->head);
-		spin_unlock(&anon_vma->lock);
+		up_write(&anon_vma->sem);
 	}
 }
 
 void anon_vma_unlink(struct vm_area_struct *vma)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
-	int empty;
 
 	if (!anon_vma)
 		return;
 
-	spin_lock(&anon_vma->lock);
+	down_write(&anon_vma->sem);
 	list_del(&vma->anon_vma_node);
-
-	/* We must garbage collect the anon_vma if it's empty */
-	empty = list_empty(&anon_vma->head);
-	spin_unlock(&anon_vma->lock);
-
-	if (empty)
-		anon_vma_free(anon_vma);
+	up_write(&anon_vma->sem);
+	put_anon_vma(anon_vma);
 }
 
 static void anon_vma_ctor(struct kmem_cache *cachep, void *data)
 {
 	struct anon_vma *anon_vma = data;
 
-	spin_lock_init(&anon_vma->lock);
+	init_rwsem(&anon_vma->sem);
+	atomic_set(&anon_vma->refcount, 0);
 	INIT_LIST_HEAD(&anon_vma->head);
 }
 
@@ -156,9 +156,9 @@ void __init anon_vma_init(void)
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
-static struct anon_vma *page_lock_anon_vma(struct page *page)
+struct anon_vma *grab_anon_vma(struct page *page)
 {
-	struct anon_vma *anon_vma;
+	struct anon_vma *anon_vma = NULL;
 	unsigned long anon_mapping;
 
 	rcu_read_lock();
@@ -169,17 +169,26 @@ static struct anon_vma *page_lock_anon_v
 		goto out;
 
 	anon_vma = (struct anon_vma *) (anon_mapping - PAGE_MAPPING_ANON);
-	spin_lock(&anon_vma->lock);
-	return anon_vma;
+	if (!atomic_inc_not_zero(&anon_vma->refcount))
+		anon_vma = NULL;
 out:
 	rcu_read_unlock();
-	return NULL;
+	return anon_vma;
+}
+
+static struct anon_vma *page_lock_anon_vma(struct page *page)
+{
+	struct anon_vma *anon_vma = grab_anon_vma(page);
+
+	if (anon_vma)
+		down_read(&anon_vma->sem);
+	return anon_vma;
 }
 
 static void page_unlock_anon_vma(struct anon_vma *anon_vma)
 {
-	spin_unlock(&anon_vma->lock);
-	rcu_read_unlock();
+	up_read(&anon_vma->sem);
+	put_anon_vma(anon_vma);
 }
 
 /*
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c	2008-04-04 15:16:52.106678775 -0700
+++ linux-2.6/mm/mmap.c	2008-04-04 15:17:09.930966883 -0700
@@ -564,7 +564,7 @@ again:			remove_next = 1 + (end > next->
 	if (vma->anon_vma)
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		down_write(&anon_vma->sem);
 		/*
 		 * Easily overlooked: when mprotect shifts the boundary,
 		 * make sure the expanding vma has anon_vma set if the
@@ -618,7 +618,7 @@ again:			remove_next = 1 + (end > next->
 	}
 
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		up_write(&anon_vma->sem);
 	if (mapping)
 		up_write(&mapping->i_mmap_sem);
 
@@ -2238,7 +2238,7 @@ static void mm_lock_unlock(struct mm_str
 {
 	struct vm_area_struct *vma;
 	struct rw_semaphore *i_mmap_sem_last;
-	spinlock_t *anon_vma_lock_last;
+	struct rw_semaphore *anon_vma_sem_last;
 
 	i_mmap_sem_last = NULL;
 	for (;;) {
@@ -2262,23 +2262,23 @@ static void mm_lock_unlock(struct mm_str
 			up_write(i_mmap_sem);
 	}
 
-	anon_vma_lock_last = NULL;
+	anon_vma_sem_last = NULL;
 	for (;;) {
-		spinlock_t *anon_vma_lock = (spinlock_t *) -1UL;
+		struct rw_semaphore *anon_vma_sem = (struct rw_semaphore *) -1UL;
 		for (vma = mm->mmap; vma; vma = vma->vm_next)
 			if (vma->anon_vma &&
-			    (unsigned long) anon_vma_lock >
-			    (unsigned long) &vma->anon_vma->lock &&
-			    (unsigned long) &vma->anon_vma->lock >
-			    (unsigned long) anon_vma_lock_last)
-				anon_vma_lock = &vma->anon_vma->lock;
-		if (anon_vma_lock == (spinlock_t *) -1UL)
+			    (unsigned long) anon_vma_sem >
+			    (unsigned long) &vma->anon_vma->sem &&
+			    (unsigned long) &vma->anon_vma->sem >
+			    (unsigned long) anon_vma_sem_last)
+				anon_vma_sem = &vma->anon_vma->sem;
+		if (anon_vma_sem == (struct rw_semaphore *) -1UL)
 			break;
-		anon_vma_lock_last = anon_vma_lock;
+		anon_vma_sem_last = anon_vma_sem;
 		if (lock)
-			spin_lock(anon_vma_lock);
+			down_write(anon_vma_sem);
 		else
-			spin_unlock(anon_vma_lock);
+			up_write(anon_vma_sem);
 	}
 }
 

-- 
