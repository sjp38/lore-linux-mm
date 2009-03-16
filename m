Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 0DF016B0047
	for <linux-mm@kvack.org>; Mon, 16 Mar 2009 20:00:38 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2H00ZAj010416
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 17 Mar 2009 09:00:35 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 32E7D45DE56
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 09:00:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0155145DE52
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 09:00:35 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C8E71E08010
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 09:00:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 491921DB8018
	for <linux-mm@kvack.org>; Tue, 17 Mar 2009 09:00:34 +0900 (JST)
Date: Tue, 17 Mar 2009 08:59:11 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
Message-Id: <20090317085911.4eb2135d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <200903170350.13665.nickpiggin@yahoo.com.au>
References: <1237007189.25062.91.camel@pasglop>
	<200903170323.45917.nickpiggin@yahoo.com.au>
	<alpine.LFD.2.00.0903160927240.3675@localhost.localdomain>
	<200903170350.13665.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Andrea Arcangeli <aarcange@redhat.com>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Mar 2009 03:50:12 +1100
Nick Piggin <nickpiggin@yahoo.com.au> wrote:

> On Tuesday 17 March 2009 03:32:11 Linus Torvalds wrote:
> > On Tue, 17 Mar 2009, Nick Piggin wrote:
> > > > Yes, my patch isn't realy solusion.
> > > > Andrea already pointed out that it's not O_DIRECT issue, it's gup vs
> > > > fork issue. *and* my patch is crazy slow :)
> > >
> > > Well, it's an interesting question. I'd say it probably is more than
> > > just O_DIRECT. vmsplice too, for example (which I think is much harder
> > > to fix this way because the pages are retired by the other end of
> > > the pipe, so I don't think you can hold a lock across it).
> >
> > Well, only the "fork()" has the race problem.
> >
> > So having a fork-specific lock (but not naming it by directio) actually
> > does make sense. The fork is much less performance-critical than most
> > random mmap_sem users - and doesn't have the same scalability issues
> > either (ie people probably _do_ want to do mmap/munmap/brk concurrently
> > with gup lookup, but there's much less worry about concurrent fork()
> > performance).
> >
> > It doesn't necessarily make the general problem go away, but it makes the
> > _particular_ race between get_user_pages() and fork() go away. Then you
> > can do per-page flags or whatever and not have to worry about concurrent
> > lookups.
> 
> Hmm, I see what you mean there; it can be used to solve Andrea's race
> instead of using set_bit/memory barriers. But I think then you would
> still need to put this lock in fork and get_user_pages[_fast], *and*
> still do most of the other stuff required in Andrea's patch.
> 
> So I'm not sure if that was KAMEZAWA-san's patch.
> 
Just FYI.

This was the last patch I sent to redhat (againat RHEL5) but ignored ;)
plz ignore the dirty part which comes from limitation that I can't
modify mm_struct.

===
This patch provides a kind of rwlock for DIO.

This patch adds below:
	struct mm_private {
		struct mm_struct
		new our data
	}

  Before issuing dio, dio submitter should call dio_lock()/dio_unlock().
  Before startinc COW, the kennel should call mm_cow_start()/mm_cow_end().

  dio_lock() registers a range of address which is under DIO.
  mm_cow_start() checks range of address is under DIO or not, then
  - If under DIO, retry fault. (for releaseing rwsem.)
  - If not under DIO, mark "we're under COW". This will make DIO submitters
    wait.

  For avoiding too many page faults, "conflict" counter is added and
  if conflict==1, DIO submitter will wait for a while.

  If no one isseus DIO yet at copy-on-write, no checkes.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
--
 fs/direct-io.c             |   43 ++++++++++++++-
 include/linux/direct-io.h  |   38 +++++++++++++
 include/linux/mm_private.h |   24 ++++++++
 kernel/fork.c              |   23 ++++++--
 mm/Makefile                |    2 
 mm/diolock.c               |  129 +++++++++++++++++++++++++++++++++++++++++++++
 mm/hugetlb.c               |   11 +++
 mm/memory.c                |   15 +++++
 8 files changed, 278 insertions(+), 7 deletions(-)

Index: kame-odirect-linux/include/linux/direct-io.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ kame-odirect-linux/include/linux/direct-io.h	2009-01-30 10:12:58.000000000 +0900
@@ -0,0 +1,38 @@
+#ifndef __LINUX_DIRECT_IO_H
+#define __LINUX_DIRECT_IO_H
+
+struct dio_lock_head
+{
+	spinlock_t		lock;		/* A lock for all below */
+	struct list_head	dios;		/* DIOs running now */
+	int			need_dio_check; /* This process used DIO */
+	int			cows;		/* COWs running now */
+	int			conflicts;	/* conflicts between COW and DIOs*/
+	wait_queue_head_t	waitq;		/* A waitq for all stopped DIOs.*/
+};
+
+struct dio_lock_ent
+{
+	struct list_head 	list;		/* Linked list from head->dios */
+	struct mm_struct	*mm;		/* the mm struct this is assgined for */
+	unsigned long		start;		/* start address for a DIO */
+	unsigned long		end;		/* end address for a DIO */
+};
+
+/* called at fork/exit */
+int dio_lock_init(struct dio_lock_head *head);
+void dio_lock_free(struct dio_lock_head *head);
+
+/*
+ * Called by DIO submitter.
+ */
+int dio_lock(struct mm_struct *mm, unsigned long start, unsigned long end,
+		struct dio_lock_ent *lock);
+void dio_unlock(struct dio_lock_ent *lock);
+/*
+ * Called by waiters.
+ */
+int mm_cow_start(struct mm_struct *mm, unsigned long start, unsigned long size);
+void mm_cow_end(struct mm_struct *mm);
+
+#endif
Index: kame-odirect-linux/mm/diolock.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ kame-odirect-linux/mm/diolock.c	2009-01-30 10:43:11.000000000 +0900
@@ -0,0 +1,129 @@
+#include <linux/mm.h>
+#include <linux/wait.h>
+#include <linux/hash.h>
+#include <linux/mm_private.h>
+
+
+int dio_lock_init(struct dio_lock_head *head)
+{
+	spin_lock_init(&head->lock);
+	head->need_dio_check = 0;
+	head->cows = 0;
+	head->conflicts = 0;
+	INIT_LIST_HEAD(&head->dios);
+	init_waitqueue_head(&head->waitq);
+	return 0;
+}
+
+void dio_lock_free(struct dio_lock_head *head)
+{
+	BUG_ON(!list_empty(&head->dios));
+	return;
+}
+
+
+int dio_lock(struct mm_struct *mm, unsigned long start, unsigned long end,
+	     struct dio_lock_ent *lock)
+{
+	unsigned long flags;
+	struct dio_lock_head *head;
+	DEFINE_WAIT(wait);
+retry:
+	if (signal_pending(current))
+		return -EINTR;
+	head  = &get_mm_private(mm)->diolock;
+
+	if (!head->need_dio_check) {
+		down_write(&mm->mmap_sem);
+		head->need_dio_check = 1;
+		up_write(&mm->mmap_sem);
+	}
+
+	prepare_to_wait(&head->waitq, &wait, TASK_INTERRUPTIBLE);
+	spin_lock_irqsave(&head->lock, flags);
+	if (head->cows || head->conflicts) { /* Allow COWs go ahead rather than new I/O */
+		spin_unlock_irqrestore(&head->lock, flags);
+		if (head->cows)
+			schedule();
+		else {
+			schedule_timeout(10); /* Allow 10tick for COW rertry */
+			head->conflicts = 0;
+		}
+		finish_wait(&head->waitq, &wait);
+		goto retry;
+	}
+	lock->mm = mm;
+	lock->start = PAGE_ALIGN(start);
+	lock->end = PAGE_ALIGN(end) + PAGE_SIZE;
+	list_add(&lock->list, &head->dios);
+	atomic_inc(&mm->mm_users);
+	spin_unlock_irqrestore(&head->lock, flags);
+	finish_wait(&head->waitq, &wait);
+	return 0;
+}
+
+void dio_unlock(struct dio_lock_ent *lock)
+{
+	struct dio_lock_head *head;
+	struct mm_struct *mm;
+	unsigned long flags;
+
+	mm = lock->mm;
+	head = &get_mm_private(mm)->diolock;
+	spin_lock_irqsave(&head->lock, flags);
+	list_del(&lock->list);
+	if (waitqueue_active(&head->waitq))
+		wake_up_all(&head->waitq);
+	spin_unlock_irqrestore(&head->lock, flags);
+	mmput(mm);
+}
+
+int mm_cow_start(struct mm_struct *mm,
+		unsigned long start, unsigned long end)
+{
+	struct dio_lock_head *head;
+	struct dio_lock_ent *lock;
+
+	head = &get_mm_private(mm)->diolock;
+	if (!head->need_dio_check)
+		return 0;
+
+	spin_lock_irq(&head->lock);
+	head->cows++;
+	if (list_empty(&head->dios)) {
+		spin_unlock_irq(&head->lock);
+		return 0;
+	}
+	/* SLOW PATH */	
+	list_for_each_entry(lock, &head->dios, list) {
+		if ((start < lock->end) && (end > lock->start)) {
+			head->cows--;
+			head->conflicts++;
+			spin_unlock_irq(&head->lock);
+			 /* This page fault will be retried but new dio requests will be
+			    delayed until cow ends.*/
+			return 1;
+		}
+	}
+	spin_unlock_irq(&head->lock);
+	return 0;
+}
+
+void mm_cow_end(struct mm_struct *mm)
+{
+	struct dio_lock_head *head;
+
+	head = &get_mm_private(mm)->diolock;
+	if (!head->need_dio_check)
+		return;
+
+	spin_lock_irq(&head->lock);
+	head->cows--;
+	if (!head->cows) {
+		head->conflicts = 0;
+		if (waitqueue_active(&head->waitq))
+			wake_up_all(&head->waitq);
+	}
+	spin_unlock_irq(&head->lock);
+	
+}
Index: kame-odirect-linux/fs/direct-io.c
===================================================================
--- kame-odirect-linux.orig/fs/direct-io.c	2009-01-29 14:01:44.000000000 +0900
+++ kame-odirect-linux/fs/direct-io.c	2009-01-30 10:53:45.000000000 +0900
@@ -34,6 +34,8 @@
 #include <linux/buffer_head.h>
 #include <linux/rwsem.h>
 #include <linux/uio.h>
+#include <linux/direct-io.h>
+
 #include <asm/atomic.h>
 
 /*
@@ -130,8 +132,43 @@
 	int is_async;			/* is IO async ? */
 	int io_error;			/* IO error in completion path */
 	ssize_t result;                 /* IO result */
+
+	/* For sanity of Direct-IO and Copy-On-Write */
+	struct dio_lock_ent		*locks;
+	int				nr_segs;
 };
 
+int dio_protect_all(struct dio *dio, const struct iovec *iov, int nsegs)
+{
+	struct dio_lock_ent *lock;
+	unsigned long start, end;
+	int seg;
+
+	lock = kzalloc(sizeof(*lock) * nsegs, GFP_KERNEL);
+	if (!lock)
+		return -ENOMEM;
+	dio->locks = lock;
+	dio->nr_segs = nsegs;
+	for (seg = 0; seg < nsegs; seg++) {
+		start = (unsigned long)iov[seg].iov_base;
+		end = (unsigned long)iov[seg].iov_base + iov[seg].iov_len;
+		dio_lock(current->mm, start, end, lock+seg);
+	}
+	return 0;
+}
+
+void dio_release_all_protection(struct dio *dio)
+{
+	int seg;
+
+	if (!dio->locks)
+		return;
+
+	for (seg = 0; seg < dio->nr_segs; seg++)
+		dio_unlock(dio->locks + seg);
+	kfree(dio->locks);
+}
+
 /*
  * How many pages are in the queue?
  */
@@ -284,6 +321,7 @@
 	if (remaining == 0) {
 		int ret = dio_complete(dio, dio->iocb->ki_pos, 0);
 		aio_complete(dio->iocb, ret, 0);
+		dio_release_all_protection(dio);
 		kfree(dio);
 	}
 
@@ -965,6 +1003,7 @@
 
 	dio->iocb = iocb;
 	dio->i_size = i_size_read(inode);
+	dio->locks = NULL;
 
 	spin_lock_init(&dio->bio_lock);
 	dio->refcount = 1;
@@ -1088,6 +1127,7 @@
 
 	if (ret2 == 0) {
 		ret = dio_complete(dio, offset, ret);
+		dio_release_all_protection(dio);
 		kfree(dio);
 	} else
 		BUG_ON(ret != -EIOCBQUEUED);
@@ -1166,7 +1206,8 @@
 	retval = -ENOMEM;
 	if (!dio)
 		goto out;
-
+	if (dio_protect_all(dio, iov, nr_segs))
+		goto out;
 	/*
 	 * For block device access DIO_NO_LOCKING is used,
 	 *	neither readers nor writers do any locking at all
Index: kame-odirect-linux/kernel/fork.c
===================================================================
--- kame-odirect-linux.orig/kernel/fork.c	2009-01-29 14:01:44.000000000 +0900
+++ kame-odirect-linux/kernel/fork.c	2009-01-30 09:54:05.000000000 +0900
@@ -46,6 +46,7 @@
 #include <linux/delayacct.h>
 #include <linux/taskstats_kern.h>
 #include <linux/hash.h>
+#include <linux/mm_private.h>
 #ifndef __GENKSYMS__
 #include <linux/ptrace.h>
 #include <linux/tty.h>
@@ -77,8 +78,8 @@
 struct hlist_head mm_flags_hash[MM_FLAGS_HASH_SIZE] =
 	{ [ 0 ... MM_FLAGS_HASH_SIZE - 1 ] = HLIST_HEAD_INIT };
 DEFINE_SPINLOCK(mm_flags_lock);
-#define MM_HASH_SHIFT ((sizeof(struct mm_struct) >= 1024) ? 10	\
-		       : (sizeof(struct mm_struct) >= 512) ? 9	\
+#define MM_HASH_SHIFT ((sizeof(struct mm_private) >= 1024) ? 10	\
+		       : (sizeof(struct mm_private) >= 512) ? 9	\
 		       : 8)
 #define mm_flags_hash_fn(mm) \
 	hash_long((unsigned long)(mm) >> MM_HASH_SHIFT, MM_FLAGS_HASH_BITS)
@@ -299,6 +300,17 @@
 	spin_unlock(&mm_flags_lock);
 }
 
+static void init_mm_private(struct mm_private *mmp)
+{
+	dio_lock_init(&mmp->diolock);
+}
+
+static void free_mm_private(struct mm_private *mmp)
+{
+	dio_lock_free(&mmp->diolock);
+}
+
+
 #ifdef CONFIG_MMU
 static inline int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 {
@@ -430,7 +442,7 @@
  __cacheline_aligned_in_smp DEFINE_SPINLOCK(mmlist_lock);
 
 #define allocate_mm()	(kmem_cache_alloc(mm_cachep, SLAB_KERNEL))
-#define free_mm(mm)	(kmem_cache_free(mm_cachep, (mm)))
+#define free_mm(mm)	(kmem_cache_free(mm_cachep, get_mm_private((mm))))
 
 #include <linux/init_task.h>
 
@@ -451,6 +463,7 @@
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	init_mm_private(get_mm_private(mm));
 
 	mm_flags = get_mm_flags(current->mm);
 	if (mm_flags != MMF_DUMP_FILTER_DEFAULT) {
@@ -466,6 +479,7 @@
 	if (mm_flags != MMF_DUMP_FILTER_DEFAULT)
 		free_mm_flags(mm);
 fail_nomem:
+	free_mm_private(get_mm_private(mm));
 	free_mm(mm);
 	return NULL;
 }
@@ -494,6 +508,7 @@
 {
 	BUG_ON(mm == &init_mm);
 	free_mm_flags(mm);
+	free_mm_private(get_mm_private(mm));
 	mm_free_pgd(mm);
 	destroy_context(mm);
 	free_mm(mm);
@@ -1550,7 +1565,7 @@
 			sizeof(struct vm_area_struct), 0,
 			SLAB_PANIC, NULL, NULL);
 	mm_cachep = kmem_cache_create("mm_struct",
-			sizeof(struct mm_struct), ARCH_MIN_MMSTRUCT_ALIGN,
+			sizeof(struct mm_private), ARCH_MIN_MMSTRUCT_ALIGN,
 			SLAB_HWCACHE_ALIGN|SLAB_PANIC, NULL, NULL);
 }
 
Index: kame-odirect-linux/mm/Makefile
===================================================================
--- kame-odirect-linux.orig/mm/Makefile	2009-01-29 14:01:44.000000000 +0900
+++ kame-odirect-linux/mm/Makefile	2009-01-29 14:01:59.000000000 +0900
@@ -5,7 +5,7 @@
 mmu-y			:= nommu.o
 mmu-$(CONFIG_MMU)	:= fremap.o highmem.o madvise.o memory.o mincore.o \
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
-			   vmalloc.o
+			   vmalloc.o diolock.o
 
 obj-y			:= bootmem.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   page_alloc.o page-writeback.o pdflush.o \
Index: kame-odirect-linux/mm/memory.c
===================================================================
--- kame-odirect-linux.orig/mm/memory.c	2009-01-29 14:01:44.000000000 +0900
+++ kame-odirect-linux/mm/memory.c	2009-01-29 16:18:19.000000000 +0900
@@ -50,6 +50,7 @@
 #include <linux/delayacct.h>
 #include <linux/init.h>
 #include <linux/writeback.h>
+#include <linux/direct-io.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -1665,6 +1666,7 @@
 	int reuse = 0, ret = VM_FAULT_MINOR;
 	struct page *dirty_page = NULL;
 	int dirty_pte = 0;
+	int dio_stop = 0;
 
 	old_page = vm_normal_page(vma, address, orig_pte);
 	if (!old_page)
@@ -1738,6 +1740,7 @@
 gotten:
 	pte_unmap_unlock(page_table, ptl);
 
+
 	if (unlikely(anon_vma_prepare(vma)))
 		goto oom;
 	if (old_page == ZERO_PAGE(address)) {
@@ -1748,6 +1751,11 @@
 		new_page = alloc_page_vma(GFP_HIGHUSER, vma, address);
 		if (!new_page)
 			goto oom;
+		if (mm_cow_start(mm, address, address+PAGE_SIZE)) {
+			page_cache_release(new_page);
+			goto out_retry;
+		}
+		dio_stop = 1;
 		cow_user_page(new_page, old_page, address);
 	}
 
@@ -1789,6 +1797,9 @@
 		page_cache_release(new_page);
 	if (old_page)
 		page_cache_release(old_page);
+	/* Allow DIO progress */
+	if (dio_stop)
+		mm_cow_end(mm);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
 	if (dirty_page) {
@@ -1797,6 +1808,10 @@
 		put_page(dirty_page);
 	}
 	return ret;
+out_retry:
+	if (old_page)
+		page_cache_release(old_page);
+	return ret;
 oom:
 	if (old_page)
 		page_cache_release(old_page);
Index: kame-odirect-linux/mm/hugetlb.c
===================================================================
--- kame-odirect-linux.orig/mm/hugetlb.c	2009-01-29 14:01:44.000000000 +0900
+++ kame-odirect-linux/mm/hugetlb.c	2009-01-29 16:29:51.000000000 +0900
@@ -14,6 +14,7 @@
 #include <linux/mempolicy.h>
 #include <linux/cpuset.h>
 #include <linux/mutex.h>
+#include <linux/direct-io.h>
 
 #include <asm/page.h>
 #include <asm/pgtable.h>
@@ -470,7 +471,13 @@
 		page_cache_release(old_page);
 		return VM_FAULT_OOM;
 	}
-
+	if (mm_cow_start(mm, address & HPAGE_MASK, HPAGE_SIZE)) {
+		/* we have to retry. */
+		page_cache_release(old_page);
+		page_cache_release(new_page);
+		return VM_FAULT_MINOR;
+	}
+	
 	spin_unlock(&mm->page_table_lock);
 	copy_huge_page(new_page, old_page, address);
 	spin_lock(&mm->page_table_lock);
@@ -486,6 +493,8 @@
 	}
 	page_cache_release(new_page);
 	page_cache_release(old_page);
+	mm_cow_end(mm);
+
 	return VM_FAULT_MINOR;
 }
 
Index: kame-odirect-linux/include/linux/mm_private.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ kame-odirect-linux/include/linux/mm_private.h	2009-01-30 09:52:26.000000000 +0900
@@ -0,0 +1,24 @@
+#ifndef __LINUX_MM_PRIVATE_H
+#define __LINUX_MM_PRIVATE_H
+
+#include <linux/sched.h>
+#include <linux/direct-io.h>
+
+/*
+ * Because we have to keep KABI, we cannot modify mm_struct itself. This
+ * mm_private is per-process object and not covered by KABI.
+ * Just for a fields of future bugfix.
+ * Note: Now, this is not copied at fork().
+ */
+struct mm_private {
+	struct mm_struct	mm;
+	/* For fixing direct-io/COW races. */
+	struct dio_lock_head	diolock;
+};
+
+static inline struct mm_private *get_mm_private(struct mm_struct *mm)
+{
+	return container_of(mm, struct mm_private, mm);
+}
+
+#endif





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
