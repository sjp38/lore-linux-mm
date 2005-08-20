Date: Sat, 20 Aug 2005 00:33:39 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] mm_struct counter deltas in task_struct
In-Reply-To: <Pine.LNX.4.58.0508182141250.3412@g5.osdl.org>
Message-ID: <Pine.LNX.4.62.0508200031290.20471@schroedinger.engr.sgi.com>
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

Introduce counter deltas in the task_struct. Instead of updating
the counters in the mm_struct via inc_mm_counter() etc one may now use
inc_mm_delta(). Inc_mm_delta will increment a delta in the task_struct.
The delta is later folded into the mm_struct counter during schedule().
The advantage is that the operations on the deltas do not need any locks.

The delta counters may be used for a variety of purposes outside of the
page fault scalability patchset. (f.e. It may be possible to switch the 
existing tlb "freed" handling to use this method).

The method to fold the counters in schedule() may require some scrutiny. We only
take the page_table_lock if its available otherwise counter updates are deferred
until the next schedule(). If the page_table_lock is busy for extended time periods
then lots of deltas may accumulate. The reported RSS visible through /proc may lag
a bit as a result. One may want to add other points where the mm counters will
be updated.

The main problem in the past with using current to store mm_struct counter
information were primarily concerns with get_user_pages(). The approach here
solves the issues in the following way:

get_user_pages() first shifts any deltas into the current->mm. Then it does
the handle_mm_fault() thing which may accumulate new deltas in current.
These are stuffed into the target mm after the page_table_lock has been
acquired.

This patch only introduces the counter deltas and is independent of the
page fault scalabilty patches. It does not make the page fault
scalability patchset use the deltas.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc6-mm1/include/linux/sched.h
===================================================================
--- linux-2.6.13-rc6-mm1.orig/include/linux/sched.h	2005-08-19 11:47:48.000000000 -0700
+++ linux-2.6.13-rc6-mm1/include/linux/sched.h	2005-08-19 23:36:22.000000000 -0700
@@ -265,6 +265,16 @@ typedef atomic_t mm_counter_t;
 typedef unsigned long mm_counter_t;
 #endif
 
+/*
+ * mm_counter operations through the deltas in task_struct
+ * that do not require holding the page_table_lock.
+ */
+#define inc_mm_delta(member) current->delta_##member++
+#define dec_mm_delta(member) current->delta_##member--
+
+#define mm_counter_updates_pending(__p) \
+	((__p)->delta_nr_ptes | (__p)->delta_rss | (__p)->delta_anon_rss)
+
 struct mm_struct {
 	struct vm_area_struct * mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
@@ -700,6 +710,15 @@ struct task_struct {
 
 	struct mm_struct *mm, *active_mm;
 
+	/*
+	 * Deltas for corresponding counters in mm_struct which require
+	 * the page_table_lock. The deltas may be updated and are later
+	 * folded into the corresponding mm_struct counters.
+	 */
+	long delta_rss;
+	long delta_anon_rss;
+	long delta_nr_ptes;
+
 /* task state */
 	struct linux_binfmt *binfmt;
 	long exit_state;
@@ -1417,6 +1436,9 @@ static inline void thaw_processes(void) 
 static inline int try_to_freeze(void) { return 0; }
 
 #endif /* CONFIG_PM */
+
+extern void mm_counter_catchup(struct task_struct *t, struct mm_struct *mm);
+
 #endif /* __KERNEL__ */
 
 #endif
Index: linux-2.6.13-rc6-mm1/kernel/fork.c
===================================================================
--- linux-2.6.13-rc6-mm1.orig/kernel/fork.c	2005-08-19 11:47:24.000000000 -0700
+++ linux-2.6.13-rc6-mm1/kernel/fork.c	2005-08-19 23:34:42.000000000 -0700
@@ -173,6 +173,9 @@ static struct task_struct *dup_task_stru
 	*ti = *orig->thread_info;
 	*tsk = *orig;
 	tsk->thread_info = ti;
+	tsk->delta_rss = 0;
+	tsk->delta_anon_rss = 0;
+	tsk->delta_nr_ptes = 0;
 	ti->task = tsk;
 
 	/* One for us, one for whoever does the "release_task()" (usually parent) */
@@ -427,6 +430,13 @@ void mm_release(struct task_struct *tsk,
 {
 	struct completion *vfork_done = tsk->vfork_done;
 
+	/* If we are still carrying deltas then apply them */
+	if (mm && mm_counter_updates_pending(tsk)) {
+		spin_lock(&mm->page_table_lock);
+		mm_counter_catchup(tsk, mm);
+		spin_unlock(&mm->page_table_lock);
+	}
+
 	/* Get rid of any cached register state */
 	deactivate_mm(tsk, mm);
 
Index: linux-2.6.13-rc6-mm1/mm/memory.c
===================================================================
--- linux-2.6.13-rc6-mm1.orig/mm/memory.c	2005-08-19 11:45:27.000000000 -0700
+++ linux-2.6.13-rc6-mm1/mm/memory.c	2005-08-19 23:34:42.000000000 -0700
@@ -886,6 +886,21 @@ untouched_anonymous_page(struct mm_struc
 	return 0;
 }
 
+/*
+ * Update the mm_struct counters protected by
+ * the page_table_lock using the deltas in the task_struct.
+ * Must hold the page_table_lock.
+ */
+void mm_counter_catchup(struct task_struct *t, struct mm_struct *mm)
+{
+	add_mm_counter(mm, rss, t->delta_rss);
+	add_mm_counter(mm, anon_rss, t->delta_anon_rss);
+	add_mm_counter(mm, nr_ptes, t->delta_nr_ptes);
+	t->delta_rss = 0;
+	t->delta_anon_rss = 0;
+	t->delta_nr_ptes = 0;
+}
+
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 		unsigned long start, int len, int write, int force,
 		struct page **pages, struct vm_area_struct **vmas)
@@ -893,7 +908,18 @@ int get_user_pages(struct task_struct *t
 	int i;
 	unsigned int flags;
 
-	/* 
+	if (mm != current->mm && mm_counter_updates_pending(current)) {
+		/*
+		 * Access to a foreign mm requires us first to bring
+		 * the counters in our mm up to date with counter deltas
+		 * so that we do not carry any deltas.
+		 */
+		spin_lock(&current->mm->page_table_lock);
+		mm_counter_catchup(current, current->mm);
+		spin_unlock(&current->mm->page_table_lock);
+	}
+
+	/*
 	 * Require read or write permissions.
 	 * If 'force' is set, we only require the "MAY" flags.
 	 */
@@ -1011,6 +1037,15 @@ int get_user_pages(struct task_struct *t
 			start += PAGE_SIZE;
 			len--;
 		} while (len && start < vma->vm_end);
+
+		if (mm != current->mm && mm_counter_updates_pending(current))
+			/*
+			 * Foreign mm. Update any counters delta in the
+			 * foreign mm otherwise they will be later added
+			 * to the mm_struct of this process.
+			 */
+			mm_counter_catchup(current, mm);
+
 		spin_unlock(&mm->page_table_lock);
 	} while (len);
 	return i;
Index: linux-2.6.13-rc6-mm1/kernel/sched.c
===================================================================
--- linux-2.6.13-rc6-mm1.orig/kernel/sched.c	2005-08-19 11:47:49.000000000 -0700
+++ linux-2.6.13-rc6-mm1/kernel/sched.c	2005-08-19 23:34:42.000000000 -0700
@@ -2917,6 +2917,15 @@ asmlinkage void __sched schedule(void)
 	}
 	profile_hit(SCHED_PROFILING, __builtin_return_address(0));
 
+	/* If we have the opportunity then update the mm_counters */
+	if (unlikely(current->mm
+		&& mm_counter_updates_pending(current)
+		&& spin_trylock(&current->mm->page_table_lock))) {
+
+		mm_counter_catchup(current, current->mm);
+		spin_unlock(&current->mm->page_table_lock);
+	}
+
 need_resched:
 	preempt_disable();
 	prev = current;
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
