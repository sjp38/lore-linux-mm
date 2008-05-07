Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 08 of 11] anon-vma-rwsem
Message-Id: <6b384bb988786aa78ef0.1210170958@duo.random>
In-Reply-To: <patchbomb.1210170950@duo.random>
Date: Wed, 07 May 2008 16:35:58 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1210115136 -7200
# Node ID 6b384bb988786aa78ef07440180e4b2948c4c6a2
# Parent  58f716ad4d067afb6bdd1b5f7042e19d854aae0d
anon-vma-rwsem

Convert the anon_vma spinlock to a rw semaphore. This allows concurrent
traversal of reverse maps for try_to_unmap() and page_mkclean(). It also
allows the calling of sleeping functions from reverse map traversal as
needed for the notifier callbacks. It includes possible concurrency.

Rcu is used in some context to guarantee the presence of the anon_vma
(try_to_unmap) while we acquire the anon_vma lock. We cannot take a
semaphore within an rcu critical section. Add a refcount to the anon_vma
structure which allow us to give an existence guarantee for the anon_vma
structure independent of the spinlock or the list contents.

The refcount can then be taken within the RCU section. If it has been
taken successfully then the refcount guarantees the existence of the
anon_vma. The refcount in anon_vma also allows us to fix a nasty
issue in page migration where we fudged by using rcu for a long code
path to guarantee the existence of the anon_vma. I think this is a bug
because the anon_vma may become empty and get scheduled to be freed
but then we increase the refcount again when the migration entries are
removed.

The refcount in general allows a shortening of RCU critical sections since
we can do a rcu_unlock after taking the refcount. This is particularly
relevant if the anon_vma chains contain hundreds of entries.

However:
- Atomic overhead increases in situations where a new reference
  to the anon_vma has to be established or removed. Overhead also increases
  when a speculative reference is used (try_to_unmap,
  page_mkclean, page migration).
- There is the potential for more frequent processor change due to up_xxx
  letting waiting tasks run first. This results in f.e. the Aim9 brk
  performance test to got down by 10-15%.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
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
diff --git a/mm/migrate.c b/mm/migrate.c
--- a/mm/migrate.c
+++ b/mm/migrate.c
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
@@ -630,7 +631,7 @@ static int unmap_and_move(new_page_t get
 	int rc = 0;
 	int *result = NULL;
 	struct page *newpage = get_new_page(page, private, &result);
-	int rcu_locked = 0;
+	struct anon_vma *anon_vma = NULL;
 	int charge = 0;
 
 	if (!newpage)
@@ -654,16 +655,14 @@ static int unmap_and_move(new_page_t get
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
@@ -681,10 +680,7 @@ static int unmap_and_move(new_page_t get
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
@@ -705,8 +701,8 @@ static int unmap_and_move(new_page_t get
 	} else if (charge)
  		mem_cgroup_end_migration(newpage);
 rcu_unlock:
-	if (rcu_locked)
-		rcu_read_unlock();
+	if (anon_vma)
+		put_anon_vma(anon_vma);
 
 unlock:
 
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -570,7 +570,7 @@ again:			remove_next = 1 + (end > next->
 	if (vma->anon_vma)
 		anon_vma = vma->anon_vma;
 	if (anon_vma) {
-		spin_lock(&anon_vma->lock);
+		down_write(&anon_vma->sem);
 		/*
 		 * Easily overlooked: when mprotect shifts the boundary,
 		 * make sure the expanding vma has anon_vma set if the
@@ -624,7 +624,7 @@ again:			remove_next = 1 + (end > next->
 	}
 
 	if (anon_vma)
-		spin_unlock(&anon_vma->lock);
+		up_write(&anon_vma->sem);
 	if (mapping)
 		up_write(&mapping->i_mmap_sem);
 
diff --git a/mm/rmap.c b/mm/rmap.c
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -69,7 +69,7 @@ int anon_vma_prepare(struct vm_area_stru
 		if (anon_vma) {
 			allocated = NULL;
 			locked = anon_vma;
-			spin_lock(&locked->lock);
+			down_write(&locked->sem);
 		} else {
 			anon_vma = anon_vma_alloc();
 			if (unlikely(!anon_vma))
@@ -81,6 +81,7 @@ int anon_vma_prepare(struct vm_area_stru
 		/* page_table_lock to protect against threads */
 		spin_lock(&mm->page_table_lock);
 		if (likely(!vma->anon_vma)) {
+			get_anon_vma(anon_vma);
 			vma->anon_vma = anon_vma;
 			list_add_tail(&vma->anon_vma_node, &anon_vma->head);
 			allocated = NULL;
@@ -88,7 +89,7 @@ int anon_vma_prepare(struct vm_area_stru
 		spin_unlock(&mm->page_table_lock);
 
 		if (locked)
-			spin_unlock(&locked->lock);
+			up_write(&locked->sem);
 		if (unlikely(allocated))
 			anon_vma_free(allocated);
 	}
@@ -99,14 +100,17 @@ void __anon_vma_merge(struct vm_area_str
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
@@ -114,36 +118,32 @@ void anon_vma_link(struct vm_area_struct
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
 
@@ -157,9 +157,9 @@ void __init anon_vma_init(void)
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
@@ -170,17 +170,26 @@ static struct anon_vma *page_lock_anon_v
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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
