Date: Thu, 18 Aug 2005 20:53:56 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [RFC] Concept for delayed counter updates in mm_struct
In-Reply-To: <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
Message-ID: <Pine.LNX.4.62.0508182052120.10236@schroedinger.engr.sgi.com>
References: <20050817151723.48c948c7.akpm@osdl.org> <20050817174359.0efc7a6a.akpm@osdl.org>
 <Pine.LNX.4.61.0508182116110.11409@goblin.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, torvalds@osdl.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I think there may be an easier way of avoiding atomic increments
if the page_table_lock is not used than methods that I had proposed last 
year (building lists of task_structs).

If we keep deltas in the task_struct then we can at some later point add 
those to an mm_struct (via calling mm_counter_catchup(mm).

The main problem in the past with using current for rss information were 
primarily concerns with get_user_pages(). I hope that the approach here 
solves the issues neatly. get_user_pages() first shifts any deltas into 
the current->mm. Then it does the handle_mm_fault() thing which may 
accumulate new deltas in current. These are stuffed into the target mm 
after the page_table_lock has been acquired.

What is missing in this patch are points were mm_counter_catchup can be called.
These points must be code where the page table lock is held. One way of providing
these would be to call mm_counter_catchup when a task is in the scheduler.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc6/kernel/fork.c
===================================================================
--- linux-2.6.13-rc6.orig/kernel/fork.c	2005-08-18 18:10:28.000000000 -0700
+++ linux-2.6.13-rc6/kernel/fork.c	2005-08-18 20:34:14.000000000 -0700
@@ -173,6 +173,9 @@ static struct task_struct *dup_task_stru
 	*tsk = *orig;
 	tsk->thread_info = ti;
 	ti->task = tsk;
+	tsk->delta_rss = 0;
+	tsk->delta_anon_rss = 0;
+	tsk->delta_nr_ptes = 0;
 
 	/* One for us, one for whoever does the "release_task()" (usually parent) */
 	atomic_set(&tsk->usage,2);
Index: linux-2.6.13-rc6/include/linux/sched.h
===================================================================
--- linux-2.6.13-rc6.orig/include/linux/sched.h	2005-08-18 18:10:28.000000000 -0700
+++ linux-2.6.13-rc6/include/linux/sched.h	2005-08-18 20:15:50.000000000 -0700
@@ -604,6 +604,15 @@ struct task_struct {
 	unsigned long flags;	/* per process flags, defined below */
 	unsigned long ptrace;
 
+	/*
+	 * The counters in the mm_struct require the page table lock
+	 * These deltas here accumulate changes that are later folded
+	 * into the corresponding mm_struct counters
+	 */
+	long delta_rss;
+	long delta_anon_rss;
+	long delta_nr_ptes;
+
 	int lock_depth;		/* BKL lock depth */
 
 #if defined(CONFIG_SMP) && defined(__ARCH_WANT_UNLOCKED_CTXSW)
@@ -1347,6 +1356,23 @@ static inline void thaw_processes(void) 
 static inline int try_to_freeze(void) { return 0; }
 
 #endif /* CONFIG_PM */
+
+/*
+ * Update mm_struct counters with deltas from task_struct.
+ * Must be called with the page_table_lock held.
+ */
+inline static void mm_counter_catchup(struct mm_struct *mm)
+{
+	if (unlikely(current->delta_rss | current->delta_anon_rss | current->delta_nr_ptes)) {
+		add_mm_counter(mm, rss, current->delta_rss);
+		add_mm_counter(mm, anon_rss, current->delta_anon_rss);
+		add_mm_counter(mm, nr_ptes, current->delta_nr_ptes);
+		current->delta_rss = 0;
+		current->delta_anon_rss = 0;
+		current->delta_nr_ptes = 0;
+	}
+}
+
 #endif /* __KERNEL__ */
 
 #endif
Index: linux-2.6.13-rc6/mm/memory.c
===================================================================
--- linux-2.6.13-rc6.orig/mm/memory.c	2005-08-18 18:10:28.000000000 -0700
+++ linux-2.6.13-rc6/mm/memory.c	2005-08-18 20:33:37.000000000 -0700
@@ -299,7 +299,7 @@ pte_t fastcall *pte_alloc_map(struct mm_
 			pte_free(new);
 			goto out;
 		}
-		inc_mm_counter(mm, nr_ptes);
+		current->delta_nr_ptes++;
 		inc_page_state(nr_page_table_pages);
 		pmd_populate(mm, pmd, new);
 	}
@@ -892,6 +892,13 @@ int get_user_pages(struct task_struct *t
 	flags &= force ? (VM_MAYREAD | VM_MAYWRITE) : (VM_READ | VM_WRITE);
 	i = 0;
 
+	if (mm != current->mm) {
+		/* Insure that there are no deltas for current->mm */
+		spin_lock(&current->mm->page_table_lock);
+		mm_counter_catchup(current->mm);
+		spin_unlock(&current->mm->page_table_lock);
+	}
+
 	do {
 		struct vm_area_struct *	vma;
 
@@ -989,6 +996,12 @@ int get_user_pages(struct task_struct *t
 					BUG();
 				}
 				spin_lock(&mm->page_table_lock);
+				/*
+				 * Update any counters in the mm handled so that
+				 * they are not reflected in the mm of the running
+				 * process
+				 */
+				mm_counter_catchup(mm);
 			}
 			if (pages) {
 				pages[i] = page;
@@ -1778,7 +1791,7 @@ do_anonymous_page(struct mm_struct *mm, 
 			spin_unlock(&mm->page_table_lock);
 			goto out;
 		}
-		inc_mm_counter(mm, rss);
+		current->delta_rss++;
 		entry = maybe_mkwrite(pte_mkdirty(mk_pte(page,
 							 vma->vm_page_prot)),
 				      vma);
Index: linux-2.6.13-rc6/mm/rmap.c
===================================================================
--- linux-2.6.13-rc6.orig/mm/rmap.c	2005-08-07 11:18:56.000000000 -0700
+++ linux-2.6.13-rc6/mm/rmap.c	2005-08-18 20:15:08.000000000 -0700
@@ -448,7 +448,7 @@ void page_add_anon_rmap(struct page *pag
 	BUG_ON(PageReserved(page));
 	BUG_ON(!anon_vma);
 
-	inc_mm_counter(vma->vm_mm, anon_rss);
+	current->delta_anon_rss++;
 
 	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
 	index = (address - vma->vm_start) >> PAGE_SHIFT;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
