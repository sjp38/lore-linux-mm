Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A67396005A4
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 03:04:15 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o057gxgL010858
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 5 Jan 2010 16:42:59 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2DED045DE51
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:42:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C7D445DE4E
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:42:59 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id E79621DB803C
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:42:58 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D2A51DB8043
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 16:42:55 +0900 (JST)
Date: Tue, 5 Jan 2010 16:39:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 6/8] mm: handle_speculative_fault()
Message-Id: <20100105163939.a3f146fb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100104182429.833180340@chello.nl>
	<20100104182813.753545361@chello.nl>
	<20100105092559.1de8b613.kamezawa.hiroyu@jp.fujitsu.com>
	<28c262361001042029w4b95f226lf54a3ed6a4291a3b@mail.gmail.com>
	<20100105134357.4bfb4951.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.LFD.2.00.1001042052210.3630@localhost.localdomain>
	<20100105143046.73938ea2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__5_Jan_2010_16_39_39_+0900_DoWOxI0nVrafESLX"
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, cl@linux-foundation.org, "hugh.dickins" <hugh.dickins@tiscali.co.uk>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Tue__5_Jan_2010_16_39_39_+0900_DoWOxI0nVrafESLX
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Tue, 5 Jan 2010 14:30:46 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> ==
> Above codes are a bit heavy(and buggy). I have some fixes.
> 
Here is my latest one. But I myself think this should be improved more
and don't think this patch is bug-free. I have some concern
s around fork() etc..and still considering how to avoid atomic ops.

I post this just as a reference rather than cut-out from old e-mails.

Here is a comarison before after patch. A test program does following in
multi-thread. (attached)

  while (1) {
	touch memory (with write)
   	pthread_barrier_wait().
   	fork() if I'm the first thread.
     	-> exit() immediately
        wait()
   	pthread_barrier_wait()
  }

And see overheads by perf. This is result on 8core/2socket hosts.
This is highly affected by the number of sockets.

# Samples: 1164449628090
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    43.23%  multi-fault-all  [kernel]                  [k] smp_invalidate_interrupt
    16.27%  multi-fault-all  [kernel]                  [k] flush_tlb_others_ipi
    11.55%  multi-fault-all  [kernel]                  [k] _raw_spin_lock_irqsave    <========(*)
     6.23%  multi-fault-all  [kernel]                  [k] intel_pmu_enable_all
     2.17%  multi-fault-all  [kernel]                  [k] _raw_spin_unlock_irqrestore
     1.59%  multi-fault-all  [kernel]                  [k] page_fault
     1.45%  multi-fault-all  [kernel]                  [k] do_wp_page
     1.35%  multi-fault-all  ./multi-fault-all-fork    [.] worker
     1.26%  multi-fault-all  [kernel]                  [k] handle_mm_fault
     1.19%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     1.03%  multi-fault-all  [kernel]                  [k] invalidate_interrupt7
     1.00%  multi-fault-all  [kernel]                  [k] invalidate_interrupt6
     0.99%  multi-fault-all  [kernel]                  [k] invalidate_interrupt3


# Samples: 181505050964
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    45.08%  multi-fault-all  [kernel]                  [k] smp_invalidate_interrupt
    19.45%  multi-fault-all  [kernel]                  [k] intel_pmu_enable_all
    14.17%  multi-fault-all  [kernel]                  [k] flush_tlb_others_ipi
     1.89%  multi-fault-all  [kernel]                  [k] do_wp_page
     1.58%  multi-fault-all  [kernel]                  [k] page_fault
     1.46%  multi-fault-all  ./multi-fault-all-fork    [.] worker
     1.26%  multi-fault-all  [kernel]                  [k] do_page_fault
     1.14%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
     1.10%  multi-fault-all  [kernel]                  [k] flush_tlb_page
     1.09%  multi-fault-all  [kernel]                  [k] vma_put           <========(**)
     0.99%  multi-fault-all  [kernel]                  [k] invalidate_interrupt0
     0.98%  multi-fault-all  [kernel]                  [k] find_vma_speculative <=====(**)
     0.81%  multi-fault-all  [kernel]                  [k] invalidate_interrupt3
     0.81%  multi-fault-all  [kernel]                  [k] native_apic_mem_write
     0.79%  multi-fault-all  [kernel]                  [k] invalidate_interrupt7
     0.76%  multi-fault-all  [kernel]                  [k] invalidate_interrupt5

(*) is removed overhead of mmap_sem and (**) is added overhead of atomic ops.
And yes, 1% seems still not ideally small. And it's unknown how this false-sharing
of atomic ops can affect to very big SMP.....maybe very big.

BTW, I'm not sure why intel_pmu_enable_all() is very big...because of fork() ?

My patch is below, just as a reference of my work in the last year, not
very clean yet. I need more time for improvements (and does not adhere to
this implementation.)

When you test this, please turn off SPINLOCK_DEBUG to enable split-page-table-lock.

Regards,
-Kame
==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Asynchronous page fault.

This patch is for avoidng mmap_sem in usual page fault. At running highly
multi-threaded programs, mm->mmap_sem can use much CPU because of false
sharing when it causes page fault in parallel. (Run after fork() is a typical
case, I think.)
This patch uses a speculative vma lookup to reduce that cost.

Considering vma lookup, rb-tree lookup, the only operation we do is checking
node->rb_left,rb_right. And there are no complicated operation.
At page fault, there are no demands for accessing sorted-vma-list or access
prev or next in many case. Except for stack-expansion, we always need a vma
which contains page-fault address. Then, we can access vma's RB-tree in
speculative way.
Even if RB-tree rotation occurs while we walk tree for look-up, we just
miss vma without oops. In other words, we can _try_ to find vma in lockless
manner. If failed, retry is ok.... we take lock and access vma.

For lockess walking, this uses RCU and adds find_vma_speculative(). And
per-vma wait-queue and reference count. This refcnt+wait_queue guarantees that
there are no thread which access the vma when we call subsystem's unmap
functions.

Changelog:
 - removed rcu_xxx macros.
 - fixed reference count handling bug at vma_put().
 - removed atomic_add_unless() etc. But use Big number for handling race.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/mm/fault.c      |   14 ++++++
 include/linux/mm.h       |   14 ++++++
 include/linux/mm_types.h |    5 ++
 mm/mmap.c                |   98 +++++++++++++++++++++++++++++++++++++++++++++--
 4 files changed, 127 insertions(+), 4 deletions(-)

Index: linux-2.6.33-rc2/include/linux/mm_types.h
===================================================================
--- linux-2.6.33-rc2.orig/include/linux/mm_types.h
+++ linux-2.6.33-rc2/include/linux/mm_types.h
@@ -11,6 +11,7 @@
 #include <linux/rwsem.h>
 #include <linux/completion.h>
 #include <linux/cpumask.h>
+#include <linux/rcupdate.h>
 #include <linux/page-debug-flags.h>
 #include <asm/page.h>
 #include <asm/mmu.h>
@@ -180,6 +181,10 @@ struct vm_area_struct {
 	void * vm_private_data;		/* was vm_pte (shared mem) */
 	unsigned long vm_truncate_count;/* truncate_count or restart_addr */
 
+	atomic_t refcnt;
+	wait_queue_head_t wait_queue;
+	struct rcu_head	rcuhead;
+
 #ifndef CONFIG_MMU
 	struct vm_region *vm_region;	/* NOMMU mapping region */
 #endif
Index: linux-2.6.33-rc2/mm/mmap.c
===================================================================
--- linux-2.6.33-rc2.orig/mm/mmap.c
+++ linux-2.6.33-rc2/mm/mmap.c
@@ -187,6 +187,26 @@ error:
 	return -ENOMEM;
 }
 
+static void __free_vma_rcu_cb(struct rcu_head *head)
+{
+	struct vm_area_struct *vma;
+	vma = container_of(head, struct vm_area_struct, rcuhead);
+	kmem_cache_free(vm_area_cachep, vma);
+}
+/* Call this if vma was linked to rb-tree */
+static void free_vma_rcu(struct vm_area_struct *vma)
+{
+	call_rcu(&vma->rcuhead, __free_vma_rcu_cb);
+}
+#define VMA_FREE_MAGIC	(10000000)
+/* called when vma is unlinked and wait for all racy access.*/
+static void invalidate_vma_before_free(struct vm_area_struct *vma)
+{
+	atomic_sub(VMA_FREE_MAGIC, &vma->refcnt);
+	wait_event(vma->wait_queue,
+		(atomic_read(&vma->refcnt) == -VMA_FREE_MAGIC));
+}
+
 /*
  * Requires inode->i_mapping->i_mmap_lock
  */
@@ -238,7 +258,7 @@ static struct vm_area_struct *remove_vma
 			removed_exe_file_vma(vma->vm_mm);
 	}
 	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma_rcu(vma);
 	return next;
 }
 
@@ -404,8 +424,12 @@ __vma_link_list(struct mm_struct *mm, st
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
+	atomic_set(&vma->refcnt, 0);
+	init_waitqueue_head(&vma->wait_queue);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
+	/* For speculative vma lookup */
+	smp_wmb();
 }
 
 static void __vma_link_file(struct vm_area_struct *vma)
@@ -490,6 +514,7 @@ __vma_unlink(struct mm_struct *mm, struc
 	rb_erase(&vma->vm_rb, &mm->mm_rb);
 	if (mm->mmap_cache == vma)
 		mm->mmap_cache = prev;
+	smp_wmb();
 }
 
 /*
@@ -614,6 +639,7 @@ again:			remove_next = 1 + (end > next->
 		 * us to remove next before dropping the locks.
 		 */
 		__vma_unlink(mm, next, vma);
+		invalidate_vma_before_free(next);
 		if (file)
 			__remove_shared_vm_struct(next, file, mapping);
 		if (next->anon_vma)
@@ -640,7 +666,7 @@ again:			remove_next = 1 + (end > next->
 		}
 		mm->map_count--;
 		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma_rcu(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -1544,6 +1570,71 @@ out:
 }
 
 /*
+ * Returns vma which contains given address. This scans rb-tree in speculative
+ * way and increment a reference count if found. Even if vma exists in rb-tree,
+ * this function may return NULL in racy case. So, this function cannot be used
+ * for checking whether given address is valid or not.
+ */
+
+struct vm_area_struct *
+find_vma_speculative(struct mm_struct *mm, unsigned long addr)
+{
+	struct vm_area_struct *vma = NULL;
+	struct vm_area_struct *vma_tmp;
+	struct rb_node *rb_node;
+
+	if (unlikely(!mm))
+		return NULL;;
+
+	rcu_read_lock();
+	/*
+ 	 * Barreir against modification of rb-tree
+ 	 * rb-tree update is not an atomic ops and no barreir is used while
+ 	 * modification. Then, modification to rb-tree can be reordered. This
+ 	 * memory barrier is against vma_(un)link_rb() for avoiding to read
+ 	 * too old data to catch all changes we get rcu_read_lock.
+ 	 *
+ 	 * We may see broken RB-tree and can't find existing vma. But it's ok.
+ 	 * We allowed to return NULL even if valid one exists. The caller will
+ 	 * use find_vma() with read-semaphore.
+ 	 */
+
+  	smp_read_barrier_depends();
+	rb_node = mm->mm_rb.rb_node;
+	vma = NULL;
+	while (rb_node) {
+		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
+
+		if (vma_tmp->vm_end > addr) {
+			vma = vma_tmp;
+			if (vma_tmp->vm_start <= addr)
+				break;
+			rb_node = rb_node->rb_left;
+		} else
+			rb_node = rb_node->rb_right;
+	}
+	if (vma) {
+		if ((vma->vm_start <= addr) && (addr < vma->vm_end)) {
+			if (atomic_inc_return(&vma->refcnt) < 0) {
+				vma_put(vma);
+				vma = NULL;
+			}
+		} else
+			vma = NULL;
+	}
+	rcu_read_unlock();
+	return vma;
+}
+
+void vma_put(struct vm_area_struct *vma)
+{
+	if ((atomic_dec_return(&vma->refcnt) == -VMA_FREE_MAGIC) &&
+	    waitqueue_active(&vma->wait_queue))
+		wake_up(&vma->wait_queue);
+	return;
+}
+
+/*
  * Verify that the stack growth is acceptable and
  * update accounting. This is shared with both the
  * grow-up and grow-down cases.
@@ -1808,6 +1899,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
 		rb_erase(&vma->vm_rb, &mm->mm_rb);
+		invalidate_vma_before_free(vma);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;
Index: linux-2.6.33-rc2/include/linux/mm.h
===================================================================
--- linux-2.6.33-rc2.orig/include/linux/mm.h
+++ linux-2.6.33-rc2/include/linux/mm.h
@@ -1235,6 +1235,20 @@ static inline struct vm_area_struct * fi
 	return vma;
 }
 
+/*
+ * Look up vma for given address in speculative way. This allows lockless lookup
+ * of vmas but in racy case, vma may no be found. You have to call find_vma()
+ * under read lock of mm->mmap_sem even if this function returns NULL.
+ * And, returned vma's reference count is incremented to show vma is accessed
+ * asynchronously, the caller has to call vma_put().
+ *
+ * Unlike find_vma(), this returns a vma which contains specified address.
+ * This doesn't return the nearest vma.
+ */
+extern struct vm_area_struct *find_vma_speculative(struct mm_struct *mm,
+	unsigned long addr);
+void vma_put(struct vm_area_struct *vma);
+
 static inline unsigned long vma_pages(struct vm_area_struct *vma)
 {
 	return (vma->vm_end - vma->vm_start) >> PAGE_SHIFT;
Index: linux-2.6.33-rc2/arch/x86/mm/fault.c
===================================================================
--- linux-2.6.33-rc2.orig/arch/x86/mm/fault.c
+++ linux-2.6.33-rc2/arch/x86/mm/fault.c
@@ -952,6 +952,7 @@ do_page_fault(struct pt_regs *regs, unsi
 	struct mm_struct *mm;
 	int write;
 	int fault;
+	int speculative = 0;
 
 	tsk = current;
 	mm = tsk->mm;
@@ -1040,6 +1041,14 @@ do_page_fault(struct pt_regs *regs, unsi
 		return;
 	}
 
+	if ((error_code & PF_USER)) {
+		vma = find_vma_speculative(mm, address);
+		if (vma) {
+			speculative = 1;
+			goto good_area;
+		}
+	}
+
 	/*
 	 * When running in the kernel we expect faults to occur only to
 	 * addresses in user space.  All other faults represent errors in
@@ -1136,5 +1145,8 @@ good_area:
 
 	check_v8086_mode(regs, address, tsk);
 
-	up_read(&mm->mmap_sem);
+	if (speculative)
+		vma_put(vma);
+	else
+		up_read(&mm->mmap_sem);
 }







--Multipart=_Tue__5_Jan_2010_16_39_39_+0900_DoWOxI0nVrafESLX
Content-Type: text/x-csrc;
 name="multi-fault-all-fork.c"
Content-Disposition: attachment;
 filename="multi-fault-all-fork.c"
Content-Transfer-Encoding: 7bit

/*
 * multi-fault.c :: causes 60secs of parallel page fault in multi-thread.
 * % gcc -O2 -o multi-fault multi-fault.c -lpthread
 * % multi-fault # of cpus.
 */

#define _GNU_SOURCE
#include <stdio.h>
#include <pthread.h>
#include <sched.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <signal.h>

#define NR_THREADS	8
pthread_t threads[NR_THREADS];
/*
 * For avoiding contention in page table lock, FAULT area is
 * sparse. If FAULT_LENGTH is too large for your cpus, decrease it.
 */
#define MMAP_LENGTH	(8 * 1024 * 1024)
#define FAULT_LENGTH	(2 * 1024 * 1024)
void *mmap_area[NR_THREADS];
#define PAGE_SIZE	4096

pthread_barrier_t barrier;
int name[NR_THREADS];

void segv_handler(int sig)
{
	sleep(100);
}
void *worker(void *data)
{
	cpu_set_t set;
	int cpu;
	int status;

	cpu = *(int *)data;

	CPU_ZERO(&set);
	CPU_SET(cpu, &set);
	sched_setaffinity(0, sizeof(set), &set);

	while (1) {
		char *c;
		char *start = mmap_area[cpu];
		char *end = mmap_area[cpu] + FAULT_LENGTH;
		pthread_barrier_wait(&barrier);
		//printf("fault into %p-%p\n",start, end);

		for (c = start; c < end; c += PAGE_SIZE)
			*c = 0;
		pthread_barrier_wait(&barrier);

		if ((cpu == 0) && !fork())
			exit(0);
		wait(&status);
		pthread_barrier_wait(&barrier);
	}
	return NULL;
}

int main(int argc, char *argv[])
{
	int i, ret;
	unsigned int num;

	if (argc < 2)
		return 0;

	num = atoi(argv[1]);	
	pthread_barrier_init(&barrier, NULL, num);

	mmap_area[0] = mmap(NULL, MMAP_LENGTH * num, PROT_WRITE|PROT_READ,
				MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	for (i = 1; i < num; i++) {
		mmap_area[i] = mmap_area[i - 1]+ MMAP_LENGTH;
	}

	for (i = 0; i < num; ++i) {
		name[i] = i;
		ret = pthread_create(&threads[i], NULL, worker, &name[i]);
		if (ret < 0) {
			perror("pthread create");
			return 0;
		}
	}
	sleep(60);
	return 0;
}

--Multipart=_Tue__5_Jan_2010_16_39_39_+0900_DoWOxI0nVrafESLX--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
