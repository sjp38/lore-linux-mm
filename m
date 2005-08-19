Date: Thu, 18 Aug 2005 18:22:21 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] use mm_counter macros for nr_pte since its also under ptl
In-Reply-To: <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0508181818100.2740@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, piggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Aug 2005, Hugh Dickins wrote:

> they went into -mm.  Proof: if that's what you're testing, you very
> soon hit the BUG_ON(mm->nr_ptes...) at the end of exit_mmap.  And
> once you've worked your way through the architectural maze, you
> realize that nr_ptes used to be protected by page_table_lock but
> is currently unprotected when CONFIG_ATOMIC_TABLE_OPS.  (I fixed
> that here by adding back page_table_lock around it, but Christoph
> will probably prefer to go atomic with it; for people just testing
> the scalability, it's okay to remove that BUG_ON for the moment.)

Ah thanks.

Actually this is a bug already present in Linus' tree (but still my 
fault). nr_pte's needs to be managed through the mm counter macros like
other counters protected by the page table fault. 

This is a patch against Linus' current tree and independent of the page 
fault scalability patches.

---

Make nr_pte a mm_counter.

nr_pte is also protected by the page_table_lock like rss and anon_rss. This patch
changes all accesses to nr_pte to use the macros provided for that purpose.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc6/include/linux/sched.h
===================================================================
--- linux-2.6.13-rc6.orig/include/linux/sched.h	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/include/linux/sched.h	2005-08-18 18:10:28.000000000 -0700
@@ -238,9 +238,10 @@ struct mm_struct {
 	unsigned long start_brk, brk, start_stack;
 	unsigned long arg_start, arg_end, env_start, env_end;
 	unsigned long total_vm, locked_vm, shared_vm;
-	unsigned long exec_vm, stack_vm, reserved_vm, def_flags, nr_ptes;
+	unsigned long exec_vm, stack_vm, reserved_vm, def_flags;
 
 	/* Special counters protected by the page_table_lock */
+	mm_counter_t _nr_ptes;
 	mm_counter_t _rss;
 	mm_counter_t _anon_rss;
 
Index: linux-2.6.13-rc6/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.13-rc6.orig/fs/proc/task_mmu.c	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/fs/proc/task_mmu.c	2005-08-18 18:10:28.000000000 -0700
@@ -27,7 +27,7 @@ char *task_mem(struct mm_struct *mm, cha
 		get_mm_counter(mm, rss) << (PAGE_SHIFT-10),
 		data << (PAGE_SHIFT-10),
 		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
-		(PTRS_PER_PTE*sizeof(pte_t)*mm->nr_ptes) >> 10);
+		(PTRS_PER_PTE*sizeof(pte_t)*get_mm_counter(mm, nr_ptes)) >> 10);
 	return buffer;
 }
 
Index: linux-2.6.13-rc6/kernel/fork.c
===================================================================
--- linux-2.6.13-rc6.orig/kernel/fork.c	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/kernel/fork.c	2005-08-18 18:10:28.000000000 -0700
@@ -320,7 +320,7 @@ static struct mm_struct * mm_init(struct
 	init_rwsem(&mm->mmap_sem);
 	INIT_LIST_HEAD(&mm->mmlist);
 	mm->core_waiters = 0;
-	mm->nr_ptes = 0;
+	set_mm_counter(mm, nr_ptes, 0);
 	spin_lock_init(&mm->page_table_lock);
 	rwlock_init(&mm->ioctx_list_lock);
 	mm->ioctx_list = NULL;
Index: linux-2.6.13-rc6/mm/memory.c
===================================================================
--- linux-2.6.13-rc6.orig/mm/memory.c	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/mm/memory.c	2005-08-18 18:10:28.000000000 -0700
@@ -116,7 +116,7 @@ static void free_pte_range(struct mmu_ga
 	pmd_clear(pmd);
 	pte_free_tlb(tlb, page);
 	dec_page_state(nr_page_table_pages);
-	tlb->mm->nr_ptes--;
+	dec_mm_counter(tlb->mm, nr_ptes);
 }
 
 static inline void free_pmd_range(struct mmu_gather *tlb, pud_t *pud,
@@ -299,7 +299,7 @@ pte_t fastcall *pte_alloc_map(struct mm_
 			pte_free(new);
 			goto out;
 		}
-		mm->nr_ptes++;
+		inc_mm_counter(mm, nr_ptes);
 		inc_page_state(nr_page_table_pages);
 		pmd_populate(mm, pmd, new);
 	}
Index: linux-2.6.13-rc6/mm/mmap.c
===================================================================
--- linux-2.6.13-rc6.orig/mm/mmap.c	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/mm/mmap.c	2005-08-18 18:10:28.000000000 -0700
@@ -1969,7 +1969,7 @@ void exit_mmap(struct mm_struct *mm)
 		vma = next;
 	}
 
-	BUG_ON(mm->nr_ptes > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
+	BUG_ON(get_mm_counter(mm, nr_ptes) > (FIRST_USER_ADDRESS+PMD_SIZE-1)>>PMD_SHIFT);
 }
 
 /* Insert vm structure into process list sorted by address
Index: linux-2.6.13-rc6/arch/um/kernel/skas/mmu.c
===================================================================
--- linux-2.6.13-rc6.orig/arch/um/kernel/skas/mmu.c	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/arch/um/kernel/skas/mmu.c	2005-08-18 18:10:28.000000000 -0700
@@ -115,7 +115,7 @@ int init_new_context_skas(struct task_st
 		if(ret)
 			goto out_free;
 
-		mm->nr_ptes--;
+		dec_mm_counter(mm, nr_ptes);
 
 		if((cur_mm != NULL) && (cur_mm != &init_mm))
 			mm_id->u.pid = copy_context_skas0(stack,
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
