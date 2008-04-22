Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 10 of 12] Convert mm_lock to use semaphores after i_mmap_lock
	and anon_vma_lock
Message-Id: <f8210c45f1c6f8b38d15.1208872286@duo.random>
In-Reply-To: <patchbomb.1208872276@duo.random>
Date: Tue, 22 Apr 2008 15:51:26 +0200
From: Andrea Arcangeli <andrea@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <npiggin@suse.de>, Jack Steiner <steiner@sgi.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, kvm-devel@lists.sourceforge.net, Kanoj Sarcar <kanojsarcar@yahoo.com>, Roland Dreier <rdreier@cisco.com>, Steve Wise <swise@opengridcomputing.com>, linux-kernel@vger.kernel.org, Avi Kivity <avi@qumranet.com>, linux-mm@kvack.org, Robin Holt <holt@sgi.com>, general@lists.openfabrics.org, Hugh Dickins <hugh@veritas.com>, akpm@linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@qumranet.com>
# Date 1208872187 -7200
# Node ID f8210c45f1c6f8b38d15e5dfebbc5f7c1f890c93
# Parent  bdb3d928a0ba91cdce2b61bd40a2f80bddbe4ff2
Convert mm_lock to use semaphores after i_mmap_lock and anon_vma_lock
conversion.

Signed-off-by: Andrea Arcangeli <andrea@qumranet.com>

diff --git a/include/linux/mm.h b/include/linux/mm.h
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1062,10 +1062,10 @@
  * mm_lock and mm_unlock are expensive operations that may take a long time.
  */
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
@@ -2243,8 +2243,8 @@
 static int mm_lock_cmp(const void *a, const void *b)
 {
 	cond_resched();
-	if ((unsigned long)*(spinlock_t **)a <
-	    (unsigned long)*(spinlock_t **)b)
+	if ((unsigned long)*(struct rw_semaphore **)a <
+	    (unsigned long)*(struct rw_semaphore **)b)
 		return -1;
 	else if (a == b)
 		return 0;
@@ -2252,7 +2252,7 @@
 		return 1;
 }
 
-static unsigned long mm_lock_sort(struct mm_struct *mm, spinlock_t **locks,
+static unsigned long mm_lock_sort(struct mm_struct *mm, struct rw_semaphore **sems,
 				  int anon)
 {
 	struct vm_area_struct *vma;
@@ -2261,59 +2261,59 @@
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
@@ -2325,57 +2325,57 @@
  */
 int mm_lock(struct mm_struct *mm, struct mm_lock_data *data)
 {
-	spinlock_t **anon_vma_locks, **i_mmap_locks;
+	struct rw_semaphore **anon_vma_sems, **i_mmap_sems;
 
 	down_write(&mm->mmap_sem);
 	if (mm->map_count) {
-		anon_vma_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
-		if (unlikely(!anon_vma_locks)) {
+		anon_vma_sems = vmalloc(sizeof(struct rw_semaphore *) * mm->map_count);
+		if (unlikely(!anon_vma_sems)) {
 			up_write(&mm->mmap_sem);
 			return -ENOMEM;
 		}
 
-		i_mmap_locks = vmalloc(sizeof(spinlock_t *) * mm->map_count);
-		if (unlikely(!i_mmap_locks)) {
+		i_mmap_sems = vmalloc(sizeof(struct rw_semaphore *) * mm->map_count);
+		if (unlikely(!i_mmap_sems)) {
 			up_write(&mm->mmap_sem);
-			vfree(anon_vma_locks);
+			vfree(anon_vma_sems);
 			return -ENOMEM;
 		}
 
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
 
 /* avoid memory allocations for mm_unlock to prevent deadlock */
 void mm_unlock(struct mm_struct *mm, struct mm_lock_data *data)
 {
 	if (mm->map_count) {
-		if (data->nr_anon_vma_locks)
-			mm_unlock_vfree(data->anon_vma_locks,
-					data->nr_anon_vma_locks);
-		if (data->i_mmap_locks)
-			mm_unlock_vfree(data->i_mmap_locks,
-					data->nr_i_mmap_locks);
+		if (data->nr_anon_vma_sems)
+			mm_unlock_vfree(data->anon_vma_sems,
+					data->nr_anon_vma_sems);
+		if (data->i_mmap_sems)
+			mm_unlock_vfree(data->i_mmap_sems,
+					data->nr_i_mmap_sems);
 	}
 	up_write(&mm->mmap_sem);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
