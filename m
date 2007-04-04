Message-ID: <461367F6.10705@yahoo.com.au>
Date: Wed, 04 Apr 2007 18:55:18 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: missing madvise functionality
References: <46128051.9000609@redhat.com>	<p73648dz5oa.fsf@bingen.suse.de>	 <46128CC2.9090809@redhat.com>	<20070403172841.GB23689@one.firstfloor.org>	 <20070403125903.3e8577f4.akpm@linux-foundation.org>	 <4612B645.7030902@redhat.com>	 <20070403202937.GE355@devserv.devel.redhat.com>	 <20070403144948.fe8eede6.akpm@linux-foundation.org>	 <4612DCC6.7000504@cosmosbay.com>  <46130BC8.9050905@yahoo.com.au> <1175675146.6483.26.camel@twins>
In-Reply-To: <1175675146.6483.26.camel@twins>
Content-Type: multipart/mixed;
 boundary="------------050503080802060505000407"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Eric Dumazet <dada1@cosmosbay.com>, Andrew Morton <akpm@linux-foundation.org>, Jakub Jelinek <jakub@redhat.com>, Ulrich Drepper <drepper@redhat.com>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050503080802060505000407
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Peter Zijlstra wrote:
> On Wed, 2007-04-04 at 12:22 +1000, Nick Piggin wrote:
> 
>>Eric Dumazet wrote:
> 
> 
>>>I do think such workloads might benefit from a vma_cache not shared by 
>>>all threads but private to each thread. A sequence could invalidate the 
>>>cache(s).
>>>
>>>ie instead of a mm->mmap_cache, having a mm->sequence, and each thread 
>>>having a current->mmap_cache and current->mm_sequence
>>
>>I have a patchset to do exactly this, btw.
> 
> 
> /me too
> 
> However, I decided against pushing it because when it does happen that a
> task is not involved with a vma lookup for longer than it takes the seq
> count to wrap we have a stale pointer...
> 
> We could go and walk the tasks once in a while to reset the pointer, but
> it all got a tad involved.

Well here is my core patch (against I think 2.6.16 + a set of vma cache
cleanups and abstractions). I didn't think the wrapping aspect was
terribly involved.

-- 
SUSE Labs, Novell Inc.

--------------050503080802060505000407
Content-Type: text/plain;
 name="mm-thread-vma-cache.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-thread-vma-cache.patch"

Index: linux-2.6/include/linux/sched.h
===================================================================
--- linux-2.6.orig/include/linux/sched.h
+++ linux-2.6/include/linux/sched.h
@@ -296,6 +296,8 @@ struct mm_struct {
 	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
 	struct vm_area_struct *vma_cache;	/* find_vma cache */
+ 	unsigned long vma_sequence;
+
 	unsigned long (*get_unmapped_area) (struct file *filp,
 				unsigned long addr, unsigned long len,
 				unsigned long pgoff, unsigned long flags);
@@ -693,6 +695,8 @@ enum sleep_type {
 	SLEEP_INTERRUPTED,
 };
 
+#define VMA_CACHE_SIZE	4
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	struct thread_info *thread_info;
@@ -734,6 +738,8 @@ struct task_struct {
 	struct list_head ptrace_list;
 
 	struct mm_struct *mm, *active_mm;
+	struct vm_area_struct *vma_cache[VMA_CACHE_SIZE];
+	unsigned long vma_cache_sequence;
 
 /* task state */
 	struct linux_binfmt *binfmt;
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -32,6 +32,40 @@
 
 static void vma_cache_touch(struct mm_struct *mm, struct vm_area_struct *vma)
 {
+	struct task_struct *curr = current;
+	if (mm == curr->mm) {
+		int i;
+		if (curr->vma_cache_sequence != mm->vma_sequence) {
+			curr->vma_cache_sequence = mm->vma_sequence;
+			curr->vma_cache[0] = vma;
+			for (i = 1; i < VMA_CACHE_SIZE; i++)
+				curr->vma_cache[i] = NULL;
+		} else {
+			int update_mm;
+
+			if (curr->vma_cache[0] == vma)
+				return;
+
+			for (i = 1; i < VMA_CACHE_SIZE; i++) {
+				if (curr->vma_cache[i] == vma)
+					break;
+			}
+			update_mm = 0;
+			if (i == VMA_CACHE_SIZE) {
+				update_mm = 1;
+				i = VMA_CACHE_SIZE-1;
+			}
+			while (i != 0) {
+				curr->vma_cache[i] = curr->vma_cache[i-1];
+				i--;
+			}
+			curr->vma_cache[0] = vma;
+
+			if (!update_mm)
+				return;
+		}
+	}
+
 	if (mm->vma_cache != vma) /* prevent cacheline bouncing */
 		mm->vma_cache = vma;
 }
@@ -39,27 +73,56 @@ static void vma_cache_touch(struct mm_st
 static void vma_cache_replace(struct mm_struct *mm, struct vm_area_struct *vma,
 						struct vm_area_struct *repl)
 {
+	mm->vma_sequence++;
+	if (unlikely(mm->vma_sequence == 0)) {
+		struct task_struct *curr = current, *t;
+		t = curr;
+		rcu_read_lock();
+		do {
+			t->vma_cache_sequence = -1;
+			t = next_thread(t);
+		} while (t != curr);
+		rcu_read_unlock();
+	}
+
 	if (mm->vma_cache == vma)
 		mm->vma_cache = repl;
 }
 
 static void vma_cache_invalidate(struct mm_struct *mm, struct vm_area_struct *vma)
 {
- 	if (mm->vma_cache == vma)
-		mm->vma_cache = NULL;
+	vma_cache_replace(mm, vma, NULL);
 }
 
 static struct vm_area_struct *vma_cache_find(struct mm_struct *mm,
 						unsigned long addr)
 {
-	struct vm_area_struct *vma = mm->vma_cache;
+	struct task_struct *curr;
+	struct vm_area_struct *vma;
 
 	preempt_disable();
 	__inc_page_state(vma_cache_query);
-	if (vma && vma->vm_end > addr && vma->vm_start <= addr)
+
+	curr = current;
+	if (mm == curr->mm && mm->vma_sequence == curr->vma_cache_sequence) {
+		int i;
+		for (i = 0; i < VMA_CACHE_SIZE; i++) {
+			vma = curr->vma_cache[i];
+			if (vma && vma->vm_end > addr && vma->vm_start <= addr){
+				__inc_page_state(vma_cache_hit);
+				goto out;
+			}
+		}
+	}
+
+	vma = mm->vma_cache;
+	if (vma && vma->vm_end > addr && vma->vm_start <= addr) {
 		__inc_page_state(vma_cache_hit);
-	else
-		vma = NULL;
+		goto out;
+	}
+
+	vma = NULL;
+out:
 	preempt_enable();
 
 	return vma;
@@ -1439,9 +1502,9 @@ struct vm_area_struct * find_vma(struct 
 				} else
 					rb_node = rb_node->rb_right;
 			}
-			if (vma)
-				vma_cache_touch(mm, vma);
 		}
+		if (vma)
+			vma_cache_touch(mm, vma);
 	}
 	return vma;
 }
@@ -1487,6 +1550,9 @@ find_vma_prev(struct mm_struct *mm, unsi
 	}
 
 out:
+	if (vma)
+		vma_cache_touch(mm, vma);
+
 	*pprev = prev;
 	return prev ? prev->vm_next : vma;
 }
Index: linux-2.6/kernel/fork.c
===================================================================
--- linux-2.6.orig/kernel/fork.c
+++ linux-2.6/kernel/fork.c
@@ -198,6 +198,7 @@ static inline int dup_mmap(struct mm_str
 	mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->vma_cache = NULL;
+	mm->vma_sequence = 0;
 	mm->free_area_cache = oldmm->mmap_base;
 	mm->cached_hole_size = ~0UL;
 	mm->map_count = 0;

--------------050503080802060505000407--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
