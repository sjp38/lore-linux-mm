Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 09 of 11] mm_lock-rwsem
Message-Id: <94eaa1515369e8ef183e.1210170959@duo.random>
In-Reply-To: <patchbomb.1210170950@duo.random>
Date: Wed, 07 May 2008 16:35:59 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, Robin Holt <holt@sgi.com>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, Rusty Russell <rusty@rustcorp.com.au>, Anthony Liguori <aliguori@us.ibm.com>, Chris Wright <chrisw@redhat.com>, Marcelo Tosatti <marcelo@kvack.org>, Eric Dumazet <dada1@cosmosbay.com>, "Paul E. McKenney" <paulmck@us.ibm.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1210115508 -7200
# Node ID 94eaa1515369e8ef183e2457f6f25a7f36473d70
# Parent  6b384bb988786aa78ef07440180e4b2948c4c6a2
mm_lock-rwsem

Convert mm_lock to use semaphores after i_mmap_lock and anon_vma_lock
conversion.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1084,10 +1084,10 @@ extern int install_special_mapping(struc
 				   unsigned long flags, struct page **pages);
 
 struct mm_lock_data {
-	spinlock_t **i_mmap_locks;
-	spinlock_t **anon_vma_locks;
-	size_t nr_i_mmap_locks;
-	size_t nr_anon_vma_locks;
+	struct rw_semaphore **i_mmap_sems;
+	struct rw_semaphore **anon_vma_sems;
+	size_t nr_i_mmap_sems;
+	size_t nr_anon_vma_sems;
 };
 extern int mm_lock(struct mm_struct *mm, struct mm_lock_data *data);
 extern void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data);
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -2255,8 +2255,8 @@ int install_special_mapping(struct mm_st
 
 static int mm_lock_cmp(const void *a, const void *b)
 {
-	unsigned long _a = (unsigned long)*(spinlock_t **)a;
-	unsigned long _b = (unsigned long)*(spinlock_t **)b;
+	unsigned long _a = (unsigned long)*(struct rw_semaphore **)a;
+	unsigned long _b = (unsigned long)*(struct rw_semaphore **)b;
 
 	cond_resched();
 	if (_a < _b)
@@ -2266,7 +2266,7 @@ static int mm_lock_cmp(const void *a, co
 	return 0;
 }
 
-static unsigned long mm_lock_sort(struct mm_struct *mm, spinlock_t **locks,
+static unsigned long mm_lock_sort(struct mm_struct *mm, struct rw_semaphore **sems,
 				  int anon)
 {
 	struct vm_area_struct *vma;
@@ -2275,59 +2275,59 @@ static unsigned long mm_lock_sort(struct
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		if (anon) {
 			if (vma->anon_vma)
-				locks[i++] = &vma->anon_vma->lock;
+				sems[i++] = &vma->anon_vma->sem;
 		} else {
 			if (vma->vm_file && vma->vm_file->f_mapping)
-				locks[i++] = &vma->vm_file->f_mapping->i_mmap_lock;
+				sems[i++] = &vma->vm_file->f_mapping->i_mmap_sem;
 		}
 	}
 
 	if (!i)
 		goto out;
 
-	sort(locks, i, sizeof(spinlock_t *), mm_lock_cmp, NULL);
+	sort(sems, i, sizeof(struct rw_semaphore *), mm_lock_cmp, NULL);
 
 out:
 	return i;
 }
 
 static inline unsigned long mm_lock_sort_anon_vma(struct mm_struct *mm,
-						  spinlock_t **locks)
+						  struct rw_semaphore **sems)
 {
-	return mm_lock_sort(mm, locks, 1);
+	return mm_lock_sort(mm, sems, 1);
 }
 
 static inline unsigned long mm_lock_sort_i_mmap(struct mm_struct *mm,
-						spinlock_t **locks)
+						struct rw_semaphore **sems)
 {
-	return mm_lock_sort(mm, locks, 0);
+	return mm_lock_sort(mm, sems, 0);
 }
 
-static void mm_lock_unlock(spinlock_t **locks, size_t nr, int lock)
+static void mm_lock_unlock(struct rw_semaphore **sems, size_t nr, int lock)
 {
-	spinlock_t *last = NULL;
+	struct rw_semaphore *last = NULL;
 	size_t i;
 
 	for (i = 0; i < nr; i++)
 		/*  Multiple vmas may use the same lock. */
-		if (locks[i] != last) {
-			BUG_ON((unsigned long) last > (unsigned long) locks[i]);
-			last = locks[i];
+		if (sems[i] != last) {
+			BUG_ON((unsigned long) last > (unsigned long) sems[i]);
+			last = sems[i];
 			if (lock)
-				spin_lock(last);
+				down_write(last);
 			else
-				spin_unlock(last);
+				up_write(last);
 		}
 }
 
-static inline void __mm_lock(spinlock_t **locks, size_t nr)
+static inline void __mm_lock(struct rw_semaphore **sems, size_t nr)
 {
-	mm_lock_unlock(locks, nr, 1);
+	mm_lock_unlock(sems, nr, 1);
 }
 
-static inline void __mm_unlock(spinlock_t **locks, size_t nr)
+static inline void __mm_unlock(struct rw_semaphore **sems, size_t nr)
 {
-	mm_lock_unlock(locks, nr, 0);
+	mm_lock_unlock(sems, nr, 0);
 }
 
 /*
@@ -2358,10 +2358,10 @@ static inline void __mm_unlock(spinlock_
  * of vmas is defined in /proc/sys/vm/max_map_count.
  *
  * mm_lock() can fail if memory allocation fails. The worst case
- * vmalloc allocation required is 2*max_map_count*sizeof(spinlock_t *),
- * so around 1Mbyte, but in practice it'll be much less because
- * normally there won't be max_map_count vmas allocated in the task
- * that runs mm_lock().
+ * vmalloc allocation required is 2*max_map_count*sizeof(struct
+ * rw_semaphore *), so around 1Mbyte, but in practice it'll be much
+ * less because normally there won't be max_map_count vmas allocated
+ * in the task that runs mm_lock().
  *
  * The vmalloc memory allocated by mm_lock is stored in the
  * mm_lock_data structure that must be allocated by the caller and it
@@ -2375,16 +2375,16 @@ static inline void __mm_unlock(spinlock_
  */
 int mm_lock(struct mm_struct *mm, struct mm_lock_data *data)
 {
-	spinlock_t **anon_vma_locks, **i_mmap_locks;
+	struct rw_semaphore **anon_vma_sems, **i_mmap_sems;
 
 	if (mm->map_count) {
-		anon_vma_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
-		if (unlikely(!anon_vma_locks))
+		anon_vma_sems = vmalloc(sizeof(struct rw_semaphore *) * mm->map_count);
+		if (unlikely(!anon_vma_sems))
 			return -ENOMEM;
 
-		i_mmap_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
-		if (unlikely(!i_mmap_locks)) {
-			vfree(anon_vma_locks);
+		i_mmap_sems = vmalloc(sizeof(struct rw_semaphore *) * mm->map_count);
+		if (unlikely(!i_mmap_sems)) {
+			vfree(anon_vma_sems);
 			return -ENOMEM;
 		}
 
@@ -2392,31 +2392,31 @@ int mm_lock(struct mm_struct *mm, struct
 		 * When mm_lock_sort_anon_vma/i_mmap returns zero it
 		 * means there's no lock to take and so we can free
 		 * the array here without waiting mm_unlock. mm_unlock
-		 * will do nothing if nr_i_mmap/anon_vma_locks is
+		 * will do nothing if nr_i_mmap/anon_vma_sems is
 		 * zero.
 		 */
-		data->nr_anon_vma_locks = mm_lock_sort_anon_vma(mm, anon_vma_locks);
-		data->nr_i_mmap_locks = mm_lock_sort_i_mmap(mm, i_mmap_locks);
+		data->nr_anon_vma_sems = mm_lock_sort_anon_vma(mm, anon_vma_sems);
+		data->nr_i_mmap_sems = mm_lock_sort_i_mmap(mm, i_mmap_sems);
 
-		if (data->nr_anon_vma_locks) {
-			__mm_lock(anon_vma_locks, data->nr_anon_vma_locks);
-			data->anon_vma_locks = anon_vma_locks;
+		if (data->nr_anon_vma_sems) {
+			__mm_lock(anon_vma_sems, data->nr_anon_vma_sems);
+			data->anon_vma_sems = anon_vma_sems;
 		} else
-			vfree(anon_vma_locks);
+			vfree(anon_vma_sems);
 
-		if (data->nr_i_mmap_locks) {
-			__mm_lock(i_mmap_locks, data->nr_i_mmap_locks);
-			data->i_mmap_locks = i_mmap_locks;
+		if (data->nr_i_mmap_sems) {
+			__mm_lock(i_mmap_sems, data->nr_i_mmap_sems);
+			data->i_mmap_sems = i_mmap_sems;
 		} else
-			vfree(i_mmap_locks);
+			vfree(i_mmap_sems);
 	}
 	return 0;
 }
 
-static void mm_unlock_vfree(spinlock_t **locks, size_t nr)
+static void mm_unlock_vfree(struct rw_semaphore **sems, size_t nr)
 {
-	__mm_unlock(locks, nr);
-	vfree(locks);
+	__mm_unlock(sems, nr);
+	vfree(sems);
 }
 
 /*
@@ -2435,11 +2435,11 @@ void mm_unlock(struct mm_struct *mm, str
 void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
 {
 	if (mm->map_count) {
-		if (data->nr_anon_vma_locks)
-			mm_unlock_vfree(data->anon_vma_locks,
-					data->nr_anon_vma_locks);
-		if (data->nr_i_mmap_locks)
-			mm_unlock_vfree(data->i_mmap_locks,
-					data->nr_i_mmap_locks);
+		if (data->nr_anon_vma_sems)
+			mm_unlock_vfree(data->anon_vma_sems,
+					data->nr_anon_vma_sems);
+		if (data->nr_i_mmap_sems)
+			mm_unlock_vfree(data->i_mmap_sems,
+					data->nr_i_mmap_sems);
 	}
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
