Message-Id: <200112210107.fBL17nL10142@maild.telia.com>
From: Roger Larsson <roger.larsson@norran.net>
Subject: [RFC] Concept: Active/busy "reverse" mapping
Date: Fri, 21 Dec 2001 02:05:26 +0100
References: <Pine.LNX.4.33L.0112200121290.15741-100000@imladris.surriel.com>
In-Reply-To: <Pine.LNX.4.33L.0112200121290.15741-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="------------Boundary-00=_2P5O1V8V82QYVQKS3P33"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--------------Boundary-00=_2P5O1V8V82QYVQKS3P33
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 8bit

The goal of this code is to make sure that used pages are marked as such.

This is accomplished by:

* When a process is descheduled - look in its mm for used pages - update 
corresponding page. (Done at most once per tick)

Pros:
* No need for extra elements in page
* Used page will be updated promptly

Cons:
* Context switch times will increase
* CPU cycle waste.

But:
* On my UP it does not affect performance that much :-)
- Lost at most 1,7 MB/s (-7%)
+ Gained in some cases (read, diff, dbench 4%)
[I thought it would become much worse - with other mm changes
 compensating]

-- 
Roger Larsson
Skelleftea
Sweden

--------------Boundary-00=_2P5O1V8V82QYVQKS3P33
Content-Type: text/x-diff;
  charset="iso-8859-1";
  name="patch-2.4.17rc1-update_page_usage-RL2"
Content-Transfer-Encoding: 8bit
Content-Disposition: attachment; filename="patch-2.4.17rc1-update_page_usage-RL2"

*******************************************
Patch prepared by: roger.larsson@norran.net
Name of file: /home/roger/patches/patch-2.4.17rc1-update_page_usage_R2

--- linux/kernel/sched.c.orig	Thu Dec 13 23:33:30 2001
+++ linux/kernel/sched.c	Wed Dec 19 23:27:46 2001
@@ -557,6 +557,10 @@
 	spin_lock_prefetch(&runqueue_lock);
 
 	if (!current->active_mm) BUG();
+
+	if (current->mm)
+	    update_page_usage(current->mm);
+
 need_resched_back:
 	prev = current;
 	this_cpu = prev->processor;
--- linux/mm/vmscan.c.orig	Thu Dec 13 23:30:55 2001
+++ linux/mm/vmscan.c	Wed Dec 19 23:27:46 2001
@@ -246,28 +246,16 @@
 	return count;
 }
 
-/* Placeholder for swap_out(): may be updated by fork.c:mmput() */
-struct mm_struct *swap_mm = &init_mm;
-
 /*
- * Returns remaining count of pages to be swapped out by followup call.
+ * No checking of mm nor address, and no locking...
  */
-static inline int swap_out_mm(struct mm_struct * mm, int count, int * mmcounter, zone_t * classzone)
+static inline int _swap_out_mm(struct mm_struct * mm, unsigned long address, int count, zone_t * classzone)
 {
-	unsigned long address;
 	struct vm_area_struct* vma;
-
 	/*
 	 * Find the proper vm-area after freezing the vma chain 
 	 * and ptes.
 	 */
-	spin_lock(&mm->page_table_lock);
-	address = mm->swap_address;
-	if (address == TASK_SIZE || swap_mm != mm) {
-		/* We raced: don't count this mm but try again */
-		++*mmcounter;
-		goto out_unlock;
-	}
 	vma = find_vma(mm, address);
 	if (vma) {
 		if (address < vma->vm_start)
@@ -279,14 +267,36 @@
 			if (!vma)
 				break;
 			if (!count)
-				goto out_unlock;
+				return count;
 			address = vma->vm_start;
 		}
 	}
 	/* Indicate that we reached the end of address space */
 	mm->swap_address = TASK_SIZE;
+	mm->update_jiffies = jiffies;
+
+	return count;
+}
+
+/* Placeholder for swap_out(): may be updated by fork.c:mmput() */
+struct mm_struct *swap_mm = &init_mm;
+
+/*
+ * Returns remaining count of pages to be swapped out by followup call.
+ */
+static inline int swap_out_mm(struct mm_struct * mm, int count, int * mmcounter, zone_t * classzone)
+{
+	unsigned long address;
+
+	spin_lock(&mm->page_table_lock);
+	address = mm->swap_address;
+	if (address == TASK_SIZE || swap_mm != mm) {
+		/* We raced: don't count this mm but try again */
+		++*mmcounter;
+	}
+	else
+		count = _swap_out_mm(mm, address, count, classzone);
 
-out_unlock:
 	spin_unlock(&mm->page_table_lock);
 	return count;
 }
@@ -333,6 +343,29 @@
 	return 0;
 }
 
+
+void update_page_usage(struct mm_struct *mm)
+{
+    unsigned long address;
+
+    atomic_inc(&mm->mm_users); /* needed? */
+
+    /* statistics... 
+     *  - no more then once a jiffie
+     *  - no need to do an expensive spin...
+     */
+    if (mm->update_jiffies != jiffies &&
+	spin_trylock(&mm->page_table_lock)) {
+	    address = mm->swap_address;
+	    if (address == TASK_SIZE)
+		    address = 0;
+	    (void)_swap_out_mm(mm, address, 1, NULL);
+
+	    spin_unlock(&mm->page_table_lock);
+    }
+
+    mmput(mm); /* atomic_dec */
+}
 
 static int FASTCALL(shrink_cache(int nr_pages, zone_t * classzone, unsigned int gfp_mask, int priority));
 static int shrink_cache(int nr_pages, zone_t * classzone, unsigned int gfp_mask, int priority)
--- linux/include/linux/mm.h.orig	Fri Dec  7 18:47:03 2001
+++ linux/include/linux/mm.h	Wed Dec 19 23:31:05 2001
@@ -423,6 +423,9 @@
 extern void ptrace_disable(struct task_struct *);
 extern int ptrace_check_attach(struct task_struct *task, int kill);
 
+int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
+		int len, int write, int force, struct page **pages, struct vm_area_struct **vmas);
+
 /*
  * On a two-level page table, this ends up being trivial. Thus the
  * inlining and the symmetry break with pte_alloc() that does all
@@ -558,11 +561,13 @@
 	 * before relocating the vma range ourself.
 	 */
 	address &= PAGE_MASK;
+ 	spin_lock(&vma->vm_mm->page_table_lock);
 	grow = (vma->vm_start - address) >> PAGE_SHIFT;
 	if (vma->vm_end - address > current->rlim[RLIMIT_STACK].rlim_cur ||
-	    ((vma->vm_mm->total_vm + grow) << PAGE_SHIFT) > current->rlim[RLIMIT_AS].rlim_cur)
+	    ((vma->vm_mm->total_vm + grow) << PAGE_SHIFT) > current->rlim[RLIMIT_AS].rlim_cur) {
+		spin_unlock(&vma->vm_mm->page_table_lock);
 		return -ENOMEM;
-	spin_lock(&vma->vm_mm->page_table_lock);
+	}
 	vma->vm_start = address;
 	vma->vm_pgoff -= grow;
 	vma->vm_mm->total_vm += grow;
--- linux/include/linux/mmzone.h.orig	Thu Dec 13 23:42:46 2001
+++ linux/include/linux/mmzone.h	Wed Dec 19 23:27:46 2001
@@ -113,8 +113,9 @@
 extern int numnodes;
 extern pg_data_t *pgdat_list;
 
-#define memclass(pgzone, classzone)	(((pgzone)->zone_pgdat == (classzone)->zone_pgdat) \
-			&& ((pgzone) <= (classzone)))
+/* with this change classzone might be zero! */
+#define memclass(pgzone, classzone)	(((pgzone) <= (classzone)) && \
+                                         ((pgzone)->zone_pgdat == (classzone)->zone_pgdat))
 
 /*
  * The following two are not meant for general usage. They are here as
--- linux/Makefile.orig	Thu Dec 13 23:33:22 2001
+++ linux/Makefile	Wed Dec 19 23:28:28 2001
@@ -1,7 +1,7 @@
 VERSION = 2
 PATCHLEVEL = 4
 SUBLEVEL = 17
-EXTRAVERSION = -rc1
+EXTRAVERSION = -rc1-update_page_usage
 
 KERNELRELEASE=$(VERSION).$(PATCHLEVEL).$(SUBLEVEL)$(EXTRAVERSION)
 

--------------Boundary-00=_2P5O1V8V82QYVQKS3P33--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
