Date: Sat, 20 Aug 2005 00:35:21 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Use deltas to replace atomic inc 
In-Reply-To: <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508200033420.20471@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
 <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
 <20050818212939.7dca44c3.akpm@osdl.org> <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andrew Morton <akpm@osdl.org>, hugh@veritas.com, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This patch applies on top of the counter delta patches and the page fault
scalability patchset in 2.6.13-rc6-mm1.

It switches the code paths that could potentially not use the page table lock
to use inc_mm_delta instead of inc_mm_counter (which requires the ptl or atomic
operations). We can then remove the definitions for making the mm_struct counters
atomic.

As a consequence page_add_anon_rmap does no longer require the page_table_lock.
It will always increase the delta rss of the currently executing process instead
of increasing the rss of the mm belonging to the vma. Most of the time this is okay
except in the case when the unuse_mm uses this function. In that case
the deferred counters need to be charged to the mm_structs as they are processed
similarly to what was done for get_user_pages().

The use of deltas could be taken further and other places could be switched.
Obviously this would be possible with places like unuse_pte() that now use mixed
mm_counter and mm_delta operations.

In the case of CONFIG_ATOMIC_TABLE_OPS not having been defined for an 
arch then we will still be using the deltas. This will help somewhat in 
avoiding bouncing cachelines however the page_table_lock will still be 
taken which is the major scalability bottleneck. Maybe we need to fall 
back to no deltas?

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc6-mm1/include/linux/sched.h
===================================================================
--- linux-2.6.13-rc6-mm1.orig/include/linux/sched.h	2005-08-19 23:42:27.000000000 -0700
+++ linux-2.6.13-rc6-mm1/include/linux/sched.h	2005-08-20 00:22:23.000000000 -0700
@@ -227,35 +227,8 @@ arch_get_unmapped_area_topdown(struct fi
 extern void arch_unmap_area(struct mm_struct *, unsigned long);
 extern void arch_unmap_area_topdown(struct mm_struct *, unsigned long);
 
-#ifdef CONFIG_ATOMIC_TABLE_OPS
 /*
- * No spinlock is held during atomic page table operations. The
- * counters are not protected anymore and must also be
- * incremented atomically.
-*/
-#ifdef ATOMIC64_INIT
-#define set_mm_counter(mm, member, value) atomic64_set(&(mm)->_##member, value)
-#define get_mm_counter(mm, member) ((unsigned long)atomic64_read(&(mm)->_##member))
-#define add_mm_counter(mm, member, value) atomic64_add(value, &(mm)->_##member)
-#define inc_mm_counter(mm, member) atomic64_inc(&(mm)->_##member)
-#define dec_mm_counter(mm, member) atomic64_dec(&(mm)->_##member)
-typedef atomic64_t mm_counter_t;
-#else
-/*
- * This may limit process memory to 2^31 * PAGE_SIZE which may be around 8TB
- * if using 4KB page size
- */
-#define set_mm_counter(mm, member, value) atomic_set(&(mm)->_##member, value)
-#define get_mm_counter(mm, member) ((unsigned long)atomic_read(&(mm)->_##member))
-#define add_mm_counter(mm, member, value) atomic_add(value, &(mm)->_##member)
-#define inc_mm_counter(mm, member) atomic_inc(&(mm)->_##member)
-#define dec_mm_counter(mm, member) atomic_dec(&(mm)->_##member)
-typedef atomic_t mm_counter_t;
-#endif
-#else
-/*
- * No atomic page table operations. Counters are protected by
- * the page table lock
+ * Operations for mm_struct counters protected by the page table lock
  */
 #define set_mm_counter(mm, member, value) (mm)->_##member = (value)
 #define get_mm_counter(mm, member) ((mm)->_##member)
@@ -263,7 +236,6 @@ typedef atomic_t mm_counter_t;
 #define inc_mm_counter(mm, member) (mm)->_##member++
 #define dec_mm_counter(mm, member) (mm)->_##member--
 typedef unsigned long mm_counter_t;
-#endif
 
 /*
  * mm_counter operations through the deltas in task_struct
Index: linux-2.6.13-rc6-mm1/mm/memory.c
===================================================================
--- linux-2.6.13-rc6-mm1.orig/mm/memory.c	2005-08-19 23:42:27.000000000 -0700
+++ linux-2.6.13-rc6-mm1/mm/memory.c	2005-08-20 00:22:23.000000000 -0700
@@ -1842,7 +1842,7 @@ do_anonymous_page(struct mm_struct *mm, 
 	 */
 	page_add_anon_rmap(page, vma, addr);
 	lru_cache_add_active(page);
-	inc_mm_counter(mm, rss);
+	inc_mm_delta(rss);
 	update_mmu_cache(vma, addr, entry);
 	lazy_mmu_prot_update(entry);
 
@@ -2192,7 +2192,7 @@ int __handle_mm_fault(struct mm_struct *
 			pte_free(new);
 		else {
 			inc_page_state(nr_page_table_pages);
-			inc_mm_counter(mm, nr_ptes);
+			inc_mm_delta(nr_ptes);
 		}
 	}
 
Index: linux-2.6.13-rc6-mm1/mm/rmap.c
===================================================================
--- linux-2.6.13-rc6-mm1.orig/mm/rmap.c	2005-08-19 11:45:27.000000000 -0700
+++ linux-2.6.13-rc6-mm1/mm/rmap.c	2005-08-20 00:22:23.000000000 -0700
@@ -437,15 +437,13 @@ int page_referenced(struct page *page, i
  * @page:	the page to add the mapping to
  * @vma:	the vm area in which the mapping is added
  * @address:	the user virtual address mapped
- *
- * The caller needs to hold the mm->page_table_lock.
  */
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
 	BUG_ON(PageReserved(page));
 
-	inc_mm_counter(vma->vm_mm, anon_rss);
+	inc_mm_delta(anon_rss);
 
 	if (atomic_inc_and_test(&page->_mapcount)) {
 		struct anon_vma *anon_vma = vma->anon_vma;
Index: linux-2.6.13-rc6-mm1/mm/swapfile.c
===================================================================
--- linux-2.6.13-rc6-mm1.orig/mm/swapfile.c	2005-08-19 11:47:49.000000000 -0700
+++ linux-2.6.13-rc6-mm1/mm/swapfile.c	2005-08-20 00:22:23.000000000 -0700
@@ -508,6 +508,16 @@ static int unuse_mm(struct mm_struct *mm
 {
 	struct vm_area_struct *vma;
 
+	/*
+	 * Ensure that existing deltas are charged to the current mm since
+	 * we will charge the next batch manually to the target mm
+	 */
+	if (current->mm && mm_counter_updates_pending(current)) {
+		spin_lock(&current->mm->page_table_lock);
+		mm_counter_catchup(current, current->mm);
+		spin_unlock(&current->mm->page_table_lock);
+	}
+
 	if (!down_read_trylock(&mm->mmap_sem)) {
 		/*
 		 * Activate page so shrink_cache is unlikely to unmap its
@@ -523,6 +533,13 @@ static int unuse_mm(struct mm_struct *mm
 		if (vma->anon_vma && unuse_vma(vma, entry, page))
 			break;
 	}
+
+	/*
+	 * Make sure all the deferred counters get charged
+	 * to the right mm_struct.
+	 */
+	mm_counter_catchup(current, mm);
+
 	spin_unlock(&mm->page_table_lock);
 	up_read(&mm->mmap_sem);
 	/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
