Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0BF1F620002
	for <linux-mm@kvack.org>; Thu, 24 Dec 2009 20:55:02 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBP1sxLf003200
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 25 Dec 2009 10:54:59 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F0F9645DE51
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 10:54:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id D2F7A45DE4C
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 10:54:58 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A8CE4E78004
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 10:54:58 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 26785E08009
	for <linux-mm@kvack.org>; Fri, 25 Dec 2009 10:54:58 +0900 (JST)
Date: Fri, 25 Dec 2009 10:51:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC PATCH] asynchronous page fault.
Message-Id: <20091225105140.263180e8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Fri__25_Dec_2009_10_51_40_+0900_DOy+WjGypE=bUghU"
Sender: owner-linux-mm@kvack.org
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.

--Multipart=_Fri__25_Dec_2009_10_51_40_+0900_DOy+WjGypE=bUghU
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

Speculative page fault v3.

This version is much simpler than old versions and doesn't use mm_accessor
but use RCU. This is based on linux-2.6.33-rc2.

This patch is just my toy but shows...
 - Once RB-tree is RCU-aware and no-lock in readside, we can avoid mmap_sem
   in page fault. 
So, what we need is not mm_accessor, but RCU-aware RB-tree, I think.

But yes, I may miss something critical ;)

After patch, statistics perf show is following. Test progam is attached.
  
# Samples: 1331231315119
#
# Overhead          Command             Shared Object  Symbol
# ........  ...............  ........................  ......
#
    28.41%  multi-fault-all  [kernel]                  [k] clear_page_c
            |
            --- clear_page_c
                __alloc_pages_nodemask
                handle_mm_fault
                do_page_fault
                page_fault
                0x400950
               |
                --100.00%-- (nil)

    21.69%  multi-fault-all  [kernel]                  [k] _raw_spin_lock
            |
            --- _raw_spin_lock
               |
               |--81.85%-- free_pcppages_bulk
               |          free_hot_cold_page
               |          __pagevec_free
               |          release_pages
               |          free_pages_and_swap_cache


I'll be almost offline in the next week. 

Minchan, in this version, I didn't add CONFIG and some others which was
recommended just for my laziness. Sorry.

=
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

Test result on my tiny test program on 8core/2socket machine is here.
This measures how many page fault can occur in 60sec in parallel.

[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all-split 8

 Performance counter stats for './multi-fault-all-split 8' (5 runs):

       17481387  page-faults                ( +-   0.409% )
      509914595  cache-misses               ( +-   0.239% )

   60.002277793  seconds time elapsed   ( +-   0.000% )


[root@bluextal memory]# /root/bin/perf stat -e page-faults,cache-misses --repeat 5 ./multi-fault-all-split 8


 Performance counter stats for './multi-fault-all-split 8' (5 runs):

       35949073  page-faults                ( +-   0.364% )
      473091100  cache-misses               ( +-   0.304% )

   60.005444117  seconds time elapsed   ( +-   0.004% )



Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 arch/x86/mm/fault.c      |   14 +++++++-
 include/linux/mm.h       |   14 ++++++++
 include/linux/mm_types.h |    5 +++
 lib/rbtree.c             |   34 ++++++++++----------
 mm/mmap.c                |   77 +++++++++++++++++++++++++++++++++++++++++++++--
 5 files changed, 123 insertions(+), 21 deletions(-)

Index: linux-2.6.33-rc2/lib/rbtree.c
===================================================================
--- linux-2.6.33-rc2.orig/lib/rbtree.c
+++ linux-2.6.33-rc2/lib/rbtree.c
@@ -30,19 +30,19 @@ static void __rb_rotate_left(struct rb_n
 
 	if ((node->rb_right = right->rb_left))
 		rb_set_parent(right->rb_left, node);
-	right->rb_left = node;
+	rcu_assign_pointer(right->rb_left, node);
 
 	rb_set_parent(right, parent);
 
 	if (parent)
 	{
 		if (node == parent->rb_left)
-			parent->rb_left = right;
+			rcu_assign_pointer(parent->rb_left, right);
 		else
-			parent->rb_right = right;
+			rcu_assign_pointer(parent->rb_right, right);
 	}
 	else
-		root->rb_node = right;
+		rcu_assign_pointer(root->rb_node, right);
 	rb_set_parent(node, right);
 }
 
@@ -53,19 +53,19 @@ static void __rb_rotate_right(struct rb_
 
 	if ((node->rb_left = left->rb_right))
 		rb_set_parent(left->rb_right, node);
-	left->rb_right = node;
+	rcu_assign_pointer(left->rb_right, node);
 
 	rb_set_parent(left, parent);
 
 	if (parent)
 	{
 		if (node == parent->rb_right)
-			parent->rb_right = left;
+			rcu_assign_pointer(parent->rb_right, left);
 		else
-			parent->rb_left = left;
+			rcu_assign_pointer(parent->rb_left, left);
 	}
 	else
-		root->rb_node = left;
+		rcu_assign_pointer(root->rb_node, left);
 	rb_set_parent(node, left);
 }
 
@@ -234,11 +234,11 @@ void rb_erase(struct rb_node *node, stru
 
 		if (rb_parent(old)) {
 			if (rb_parent(old)->rb_left == old)
-				rb_parent(old)->rb_left = node;
+				rcu_assign_pointer(rb_parent(old)->rb_left, node);
 			else
-				rb_parent(old)->rb_right = node;
+				rcu_assign_pointer(rb_parent(old)->rb_right, node);
 		} else
-			root->rb_node = node;
+			rcu_assign_pointer(root->rb_node, node);
 
 		child = node->rb_right;
 		parent = rb_parent(node);
@@ -249,14 +249,14 @@ void rb_erase(struct rb_node *node, stru
 		} else {
 			if (child)
 				rb_set_parent(child, parent);
-			parent->rb_left = child;
+			rcu_assign_pointer(parent->rb_left, child);
 
-			node->rb_right = old->rb_right;
+			rcu_assign_pointer(node->rb_right, old->rb_right);
 			rb_set_parent(old->rb_right, node);
 		}
 
 		node->rb_parent_color = old->rb_parent_color;
-		node->rb_left = old->rb_left;
+		rcu_assign_pointer(node->rb_left, old->rb_left);
 		rb_set_parent(old->rb_left, node);
 
 		goto color;
@@ -270,12 +270,12 @@ void rb_erase(struct rb_node *node, stru
 	if (parent)
 	{
 		if (parent->rb_left == node)
-			parent->rb_left = child;
+			rcu_assign_pointer(parent->rb_left, child);
 		else
-			parent->rb_right = child;
+			rcu_assign_pointer(parent->rb_right, child);
 	}
 	else
-		root->rb_node = child;
+		rcu_assign_pointer(root->rb_node, child);
 
  color:
 	if (color == RB_BLACK)
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
@@ -187,6 +187,24 @@ error:
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
+/* called when vma is unlinked and wait for all racy access.*/
+static void invalidate_vma_before_free(struct vm_area_struct *vma)
+{
+	atomic_dec(&vma->refcnt);
+	wait_event(vma->wait_queue, !atomic_read(&vma->refcnt));
+}
+
 /*
  * Requires inode->i_mapping->i_mmap_lock
  */
@@ -238,7 +256,7 @@ static struct vm_area_struct *remove_vma
 			removed_exe_file_vma(vma->vm_mm);
 	}
 	mpol_put(vma_policy(vma));
-	kmem_cache_free(vm_area_cachep, vma);
+	free_vma_rcu(vma);
 	return next;
 }
 
@@ -404,6 +422,8 @@ __vma_link_list(struct mm_struct *mm, st
 void __vma_link_rb(struct mm_struct *mm, struct vm_area_struct *vma,
 		struct rb_node **rb_link, struct rb_node *rb_parent)
 {
+	atomic_set(&vma->refcnt, 1);
+	init_waitqueue_head(&vma->wait_queue);
 	rb_link_node(&vma->vm_rb, rb_parent, rb_link);
 	rb_insert_color(&vma->vm_rb, &mm->mm_rb);
 }
@@ -614,6 +634,7 @@ again:			remove_next = 1 + (end > next->
 		 * us to remove next before dropping the locks.
 		 */
 		__vma_unlink(mm, next, vma);
+		invalidate_vma_before_free(next);
 		if (file)
 			__remove_shared_vm_struct(next, file, mapping);
 		if (next->anon_vma)
@@ -640,7 +661,7 @@ again:			remove_next = 1 + (end > next->
 		}
 		mm->map_count--;
 		mpol_put(vma_policy(next));
-		kmem_cache_free(vm_area_cachep, next);
+		free_vma_rcu(next);
 		/*
 		 * In mprotect's case 6 (see comments on vma_merge),
 		 * we must remove another next too. It would clutter
@@ -1544,6 +1565,55 @@ out:
 }
 
 /*
+ * Returns vma which contains given address. This scans rb-tree in speculative
+ * way and increment a reference count if found. Even if vma exists in rb-tree,
+ * this function may return NULL in racy case. So, this function cannot be used
+ * for checking whether given address is valid or not.
+ */
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
+	rb_node = rcu_dereference(mm->mm_rb.rb_node);
+	vma = NULL;
+	while (rb_node) {
+		vma_tmp = rb_entry(rb_node, struct vm_area_struct, vm_rb);
+
+		if (vma_tmp->vm_end > addr) {
+			vma = vma_tmp;
+			if (vma_tmp->vm_start <= addr)
+				break;
+			rb_node = rcu_dereference(rb_node->rb_left);
+		} else
+			rb_node = rcu_dereference(rb_node->rb_right);
+	}
+	if (vma) {
+		if ((vma->vm_start <= addr) && (addr < vma->vm_end)) {
+			if (!atomic_inc_not_zero(&vma->refcnt))
+				vma = NULL;
+		} else
+			vma = NULL;
+	}
+	rcu_read_unlock();
+	return vma;
+}
+
+void vma_put(struct vm_area_struct *vma)
+{
+	if ((atomic_dec_return(&vma->refcnt) == 1) &&
+	    waitqueue_active(&vma->wait_queue))
+		wake_up(&vma->wait_queue);
+	return;
+}
+
+/*
  * Verify that the stack growth is acceptable and
  * update accounting. This is shared with both the
  * grow-up and grow-down cases.
@@ -1808,6 +1878,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 	insertion_point = (prev ? &prev->vm_next : &mm->mmap);
 	do {
 		rb_erase(&vma->vm_rb, &mm->mm_rb);
+		invalidate_vma_before_free(vma);
 		mm->map_count--;
 		tail_vma = vma;
 		vma = vma->vm_next;
@@ -1819,7 +1890,7 @@ detach_vmas_to_be_unmapped(struct mm_str
 	else
 		addr = vma ?  vma->vm_start : mm->mmap_base;
 	mm->unmap_area(mm, addr);
-	mm->mmap_cache = NULL;		/* Kill the cache. */
+	mm->mmap_cache = NULL;	/* Kill the cache. */
 }
 
 /*
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

--Multipart=_Fri__25_Dec_2009_10_51_40_+0900_DOy+WjGypE=bUghU
Content-Type: text/x-csrc;
 name="multi-fault-all-split.c"
Content-Disposition: attachment;
 filename="multi-fault-all-split.c"
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

		madvise(start, FAULT_LENGTH, MADV_DONTNEED);
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

	for (i = 0; i < num; i++) {
		mmap_area[i] = mmap(NULL, MMAP_LENGTH * num,
				PROT_WRITE|PROT_READ,
				MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
		/* memory hole */
		mmap(NULL, PAGE_SIZE, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, 0, 0);
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

--Multipart=_Fri__25_Dec_2009_10_51_40_+0900_DOy+WjGypE=bUghU--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
