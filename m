Subject: [RFC] another crazy idea to get rid of mmap_sem in faults
From: Peter Zijlstra <peterz@infradead.org>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Fri, 28 Nov 2008 16:42:39 +0100
Message-Id: <1227886959.4454.4421.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, hugh <hugh@veritas.com>
Cc: Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hi,

While pondering the page_fault retry stuff, I came up with the following
idea.

Pagefault concurrency with mmap() is undefined at best (any sane
application will start using memory after its been mmap'ed and stop
using it before it unmaps it).

The only thing we need to ensure is that we don't insert a PTE in the
wrong map in case some app does stupid.

If we do not freeze the vm map like we normally do but use a lockless
vma lookup we're left with the unmap race (you're unlikely to find the
vma before insertion anyway).

I think we can close that race by marking a vma 'dead' before we do the
pte unmap, this means that once we have the pte lock in the fault
handler we can validate the vma (it cannot go away after all, because
the unmap will block on it).

Therefore, we can do the fault optimistically with any sane vma we get
until the point we want to insert the PTE, at which point we have to
take the PTL and validate the vma is still good.

[ Of course getting the PTL after the unmap might instantiate the upper
  page tables for naught and we ought to clean them up again if we
  raced, can this be done race free? ]

I'm sure there are many fun details to work out, even if the above idea
is found solid, amongst them is extending srcu to provide call_srcu(),
and implement an RCU friendly tree structure.

[ hmm, while writing this it occurred to me this might mean we have to
  srcu free the page table pages :/ ]

The below patch is very rough and doesn't compile nor attempts to be
correct, it's only purpose is to illustrate the idea more clearly.

NOT-Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 63e9f7c..ba0eeeb 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -591,6 +591,7 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
 	unsigned long address;
 	int write, si_code;
 	int fault;
+	int idx;
 	unsigned long *stackend;
 
 #ifdef CONFIG_X86_64
@@ -600,7 +601,6 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
 
 	tsk = current;
 	mm = tsk->mm;
-	prefetchw(&mm->mmap_sem);
 
 	/* get the address */
 	address = read_cr2();
@@ -683,32 +683,35 @@ void __kprobes do_page_fault(struct pt_regs *regs, unsigned long error_code)
 		goto bad_area_nosemaphore;
 
 again:
+	idx = srcu_read_lock(&mm_srcu);
+
+retry:
 	/*
-	 * When running in the kernel we expect faults to occur only to
-	 * addresses in user space.  All other faults represent errors in the
-	 * kernel and should generate an OOPS.  Unfortunately, in the case of an
-	 * erroneous fault occurring in a code path which already holds mmap_sem
-	 * we will deadlock attempting to validate the fault against the
-	 * address space.  Luckily the kernel only validly references user
-	 * space from well defined areas of code, which are listed in the
-	 * exceptions table.
+	 * this should be lockless, except RB trees suck!
+	 *
+	 * we want:
+	 * srcu_read_lock(); // guard vmas
+	 * rcu_read_lock();  // guard the lookup structure
+	 * vma = find_vma(mm, address);
+	 * rcu_read_unlock();
 	 *
-	 * As the vast majority of faults will be valid we will only perform
-	 * the source reference check when there is a possibility of a deadlock.
-	 * Attempt to lock the address space, if we cannot we then validate the
-	 * source.  If this is invalid we can skip the address space check,
-	 * thus avoiding the deadlock.
+	 * do the fault
+	 *
+	 * srcu_read_unlock(); // release vma
 	 */
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		if ((error_code & PF_USER) == 0 &&
-		    !search_exception_tables(regs->ip))
-			goto bad_area_nosemaphore;
-		down_read(&mm->mmap_sem);
-	}
-
+	down_read(&mm->mmap_sem);
 	vma = find_vma(mm, address);
+	up_read(&mm->mmap_sem);
+
 	if (!vma)
 		goto bad_area;
+	if (vma_is_dead(vma)) {
+		/*
+		 * We lost a race against an concurrent modification. Retry the
+		 * lookup which should now obtain a NULL or valid vma.
+		 */
+		goto retry;
+	}
 	if (vma->vm_start <= address)
 		goto good_area;
 	if (!(vma->vm_flags & VM_GROWSDOWN))
@@ -723,6 +726,9 @@ again:
 		if (address + 65536 + 32 * sizeof(unsigned long) < regs->sp)
 			goto bad_area;
 	}
+	/*
+	 * XXX this might still need mmap_sem...
+	 */
 	if (expand_stack(vma, address))
 		goto bad_area;
 /*
@@ -775,7 +781,7 @@ good_area:
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
 #endif
-	up_read(&mm->mmap_sem);
+	srcu_read_unlock(&mm_srcu, idx);
 	return;
 
 /*
@@ -783,7 +789,7 @@ good_area:
  * Fix it, but check if it's kernel or user first..
  */
 bad_area:
-	up_read(&mm->mmap_sem);
+	srcu_read_unlock(&mm_srcu, idx);
 
 bad_area_nosemaphore:
 	/* User mode accesses just cause a SIGSEGV */
@@ -883,7 +889,7 @@ no_context:
  * us unable to handle the page fault gracefully.
  */
 out_of_memory:
-	up_read(&mm->mmap_sem);
+	srcu_read_unlock(&mm_srcu, idx);
 	if (is_global_init(tsk)) {
 		yield();
 		/*
@@ -899,7 +905,7 @@ out_of_memory:
 	goto no_context;
 
 do_sigbus:
-	up_read(&mm->mmap_sem);
+	srcu_read_unlock(&mm_srcu, idx);
 
 	/* Kernel mode? Handle exceptions or die */
 	if (!(error_code & PF_USER))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index ffee2f7..c9f1727 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -13,6 +13,7 @@
 #include <linux/prio_tree.h>
 #include <linux/debug_locks.h>
 #include <linux/mm_types.h>
+#include <linux/srcu.h>
 
 struct mempolicy;
 struct anon_vma;
@@ -145,6 +146,7 @@ extern pgprot_t protection_map[16];
 #define FAULT_FLAG_WRITE	0x01	/* Fault was a write access */
 #define FAULT_FLAG_NONLINEAR	0x02	/* Fault was via a nonlinear mapping */
 
+extern struct srcu_struct mm_srcu;
 
 /*
  * vm_fault is filled by the the pagefault handler and passed to the vma's
@@ -1132,6 +1134,25 @@ extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
 extern unsigned long do_brk(unsigned long, unsigned long);
 
+static inline int vma_is_dead(struct vm_area_struct *vma)
+{
+	return atomic_read(&vma->vm_usage) == 0;
+}
+
+static inline void vma_get(struct vm_area_struct *vma)
+{
+	BUG_ON(vma_is_dead(vma));
+	atomic_inc(&vma->vm_usage);
+}
+
+extern void __vma_put(struct vm_area_struct *vma);
+
+static inline void vma_put(struct vm_area_struct *vma)
+{
+	if (!atomic_dec_return(&vma->vm_usage))
+		__vma_put(vma);
+}
+
 /* filemap.c */
 extern unsigned long page_unuse(struct page *);
 extern void truncate_inode_pages(struct address_space *, loff_t);
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 0a48058..d5b46a8 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -159,12 +159,11 @@ struct vm_area_struct {
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
-#ifndef CONFIG_MMU
 	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
-#endif
 #ifdef CONFIG_NUMA
 	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
 #endif
+	struct rcu_head rcu_head;
 };
 
 struct core_thread {
diff --git a/kernel/fork.c b/kernel/fork.c
index afb376d..b4daad6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -136,6 +136,8 @@ struct kmem_cache *vm_area_cachep;
 /* SLAB cache for mm_struct structures (tsk->mm) */
 static struct kmem_cache *mm_cachep;
 
+struct srcu_struct mm_srcu;
+
 void free_task(struct task_struct *tsk)
 {
 	prop_local_destroy_single(&tsk->dirties);
@@ -1477,6 +1479,8 @@ void __init proc_caches_init(void)
 	mm_cachep = kmem_cache_create("mm_struct",
 			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC|SLAB_NOTRACK, NULL);
+
+	init_srcu_struct(&mm_srcu);
 }
 
 /*
diff --git a/mm/memory.c b/mm/memory.c
index fc031d6..dc2475a 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1829,6 +1829,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 * sleep if it needs to.
 			 */
 			page_cache_get(old_page);
+			vma_get(vma);
 			pte_unmap_unlock(page_table, ptl);
 
 			if (vma->vm_ops->page_mkwrite(vma, old_page) < 0)
@@ -1842,6 +1843,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			 */
 			page_table = pte_offset_map_lock(mm, pmd, address,
 							 &ptl);
+			vma_put(vma);
 			page_cache_release(old_page);
 			if (!pte_same(*page_table, orig_pte))
 				goto unlock;
@@ -1869,6 +1871,7 @@ reuse:
 	 */
 	page_cache_get(old_page);
 gotten:
+	vma_get(vma);
 	pte_unmap_unlock(page_table, ptl);
 
 	if (unlikely(anon_vma_prepare(vma)))
@@ -1896,6 +1899,7 @@ gotten:
 	 * Re-check the pte - we dropped the lock
 	 */
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	vma_put(vma);
 	if (likely(pte_same(*page_table, orig_pte))) {
 		if (old_page) {
 			if (!PageAnon(old_page)) {
@@ -2410,6 +2414,17 @@ static int do_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (vma_is_dead(vma)) {
+		/*
+		 * by holding the ptl we pin whatever vma that is covering its
+		 * memory region, if at this point the vma we got is dead,
+		 * we've lost the race and need to bail.
+		 *
+		 * XXX should we re-do the lookup and check for merged vmas?
+		 */
+		pte_unmap_unlock(pte, ptl);
+		return VM_FAULT_SIGBUS;
+	}
 	if (!pte_none(*page_table))
 		goto release;
 	inc_mm_counter(mm, anon_rss);
@@ -2543,6 +2558,17 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
+	if (vma_is_dead(vma)) {
+		/*
+		 * by holding the ptl we pin whatever vma that is covering its
+		 * memory region, if at this point the vma we got is dead,
+		 * we've lost the race and need to bail.
+		 *
+		 * XXX should we re-do the lookup and check for merged vmas?
+		 */
+		pte_unmap_unlock(pte, ptl);
+		return VM_FAULT_SIGBUS;
+	}
 
 	/*
 	 * This silly early PAGE_DIRTY setting removes a race
@@ -2690,6 +2716,17 @@ static inline int handle_pte_fault(struct mm_struct *mm,
 
 	ptl = pte_lockptr(mm, pmd);
 	spin_lock(ptl);
+	if (vma_is_dead(vma)) {
+		/*
+		 * by holding the ptl we pin whatever vma that is covering its
+		 * memory region, if at this point the vma we got is dead,
+		 * we've lost the race and need to bail.
+		 *
+		 * XXX should we re-do the lookup and check for merged vmas?
+		 */
+		pte_unmap_unlock(pte, ptl);
+		return VM_FAULT_SIGBUS;
+	}
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
diff --git a/mm/mmap.c b/mm/mmap.c
index d4855a6..2b2d454 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -43,6 +43,48 @@
 #define arch_rebalance_pgtables(addr, len)		(addr)
 #endif
 
+void __vma_put(struct vm_area_struct *vma)
+{
+	/*
+	 * we should never free a vma through here!
+	 */
+	BUG();
+}
+
+void vma_free_rcu(struct rcu_head *rcu)
+{
+	struct vm_area_struct *vma = 
+		container_of(rcu, struct vm_area_struct, rcu_head);
+
+	kmem_cache_free(vm_area_cachep, vma);
+}
+
+void vma_free(struct vm_area_struct *vma)
+{
+	VM_BUG_ON(!vma_is_dead(vma));
+	/*
+	 * Yeah, I know, this doesn't exist...
+	 */
+	call_srcu(&mm_srcu, &vma->rcu_head, vma_free_rcu);
+}
+
+/*
+ * mark the vma unused before we zap the PTEs, that way, holding the PTE lock
+ * will block the unmap and guarantee vma validity.
+ */
+void vma_remove(struct vm_area_struct *vma)
+{
+	/*
+	 * XXX might need to be a blocking wait ?
+	 *     complicates vma_adjust
+	 *
+	 *     better to get rid of vma_get/put do_wp_page() might be able
+	 *     to compare PTEs and bail, it'll just re-take the fault.
+	 */
+	while (atomic_cmpxchg(&vma->vm_usage, 1, 0))
+		cpu_relax();
+}
+
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
 		unsigned long start, unsigned long end);
@@ -241,7 +283,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 			removed_exe_file_vma(vma->vm_mm);
 	}
 	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	vma_free(vma);
 	return next;
 }
 
@@ -407,6 +449,7 @@ __vma_link_list(struct mm_struct *mm, struct vm_area_struct *vma,
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
+	atomic_set(&vma->vm_usage, 1);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
 }
@@ -492,6 +535,7 @@ __vma_unlink(struct mm_struct *mm, struct vm_area_struct *vma,
 {
 	prev->vm_next = vma->vm_next;
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
+	vma_remove(vma);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
 }
@@ -644,7 +688,7 @@ again:			remove_next = 1 + (end > next->vm_end);
 		}
 		mm->map_count--;
 		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		vma_free(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -1210,7 +1254,7 @@ munmap_back:
 	if (file && vma_merge(mm, prev, addr, vma->vm_end,
 			vma->vm_flags, NULL, file, pgoff, vma_policy(vma))) {
 		mpol_put(vma_policy(vma));
-		kmem_cache_free(vm_area_cachep, vma);
+		vma_free(vma);
 		fput(file);
 		if (vm_flags & VM_EXECUTABLE)
 			removed_exe_file_vma(mm);
@@ -1247,7 +1291,7 @@ unmap_and_free_vma:
 	unmap_region(mm, vma, prev, vma->vm_start, vma->vm_end);
 	charged = 0;
 free_vma:
-	kmem_cache_free(vm_area_cachep, vma);
+	vma_free(vma);
 unacct_error:
 	if (charged)
 		vm_unacct_memory(charged);
@@ -1801,6 +1845,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
 		rb_erase(&vma->vm_rb, &mm->mm_rb);
+		vma_remove(vma);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
