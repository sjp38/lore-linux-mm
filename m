Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 6AC446B003D
	for <linux-mm@kvack.org>; Sun, 22 Mar 2009 07:42:05 -0400 (EDT)
Date: Sun, 22 Mar 2009 21:23:56 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [aarcange@redhat.com: [PATCH] fork vs gup(-fast) fix]
In-Reply-To: <20090318105735.BD17.A69D9226@jp.fujitsu.com>
References: <200903170323.45917.nickpiggin@yahoo.com.au> <20090318105735.BD17.A69D9226@jp.fujitsu.com>
Message-Id: <20090322205249.6801.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Nick Piggin <npiggin@novell.com>, Hugh Dickins <hugh@veritas.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

following patch is my v2 approach.
it survive Andrea's three dio test-case.

Linus suggested to change add_to_swap() and shrink_page_list() stuff
for avoid false cow in do_wp_page() when page become to swapcache.

I think it's good idea. but it's a bit radical. so I think it's for development
tree tackle.

Then, I decide to use Nick's early decow in 
get_user_pages() and RO mapped page don't use gup_fast.

yeah, my approach is extream brutal way and big hammer. but I think 
it don't have performance issue in real world.

why?

Practically, we can assume following two thing.

(1) the buffer of passed write(2) syscall argument is RW mapped
    page or COWed RO page.

if anybody write following code, my path cause performance degression.

   buf = mmap()
   memset(buf, 0x11, len);
   mprotect(buf, len, PROT_READ)
   fd = open(O_DIRECT)
   write(fd, buf, len)

but it's very artifactical code. nobody want this.
ok, we can ignore this.

(2) DirectIO user process isn't short lived process.

early decow only decrease short lived process performaqnce. 
because long lived process do decowing anyway before exec(2).

and, All DB application is definitely long lived process.
then early decow don't cause degression.


TODO
  - implement down_write_killable().
    (but it isn't important thing because this is rare case issue.)
  - implement non x86 portion.


Am I missing any thing?


Note: this is still RFC. not intent submission.

--
 arch/x86/mm/gup.c         |   22 ++++++++++++++--------
 fs/direct-io.c            |   11 +++++++++++
 include/linux/init_task.h |    1 +
 include/linux/mm.h        |    9 +++++++++
 include/linux/mm_types.h  |    6 ++++++
 kernel/fork.c             |    3 +++
 mm/internal.h             |   10 ----------
 mm/memory.c               |   17 ++++++++++++++++-
 mm/util.c                 |    8 ++++++--
 9 files changed, 66 insertions(+), 21 deletions(-)

diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index be54176..02e479b 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -74,8 +74,10 @@ static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
 	pte_t *ptep;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
+
+	/* Maybe the read only pte is cow mapped page. (or not maybe)
+	   So, falling back to get_user_pages() is better */
+	mask |= _PAGE_RW;
 
 	ptep = pte_offset_map(&pmd, addr);
 	do {
@@ -114,8 +116,7 @@ static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 	int refs;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
+	mask |= _PAGE_RW;
 	if ((pte_flags(pte) & mask) != mask)
 		return 0;
 	/* hugepages are never "special" */
@@ -171,8 +172,7 @@ static noinline int gup_huge_pud(pud_t pud, unsigned long addr,
 	int refs;
 
 	mask = _PAGE_PRESENT|_PAGE_USER;
-	if (write)
-		mask |= _PAGE_RW;
+	mask |= _PAGE_RW;
 	if ((pte_flags(pte) & mask) != mask)
 		return 0;
 	/* hugepages are never "special" */
@@ -272,6 +272,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 
 	{
 		int ret;
+		int gup_flags;
 
 slow:
 		local_irq_enable();
@@ -280,9 +281,14 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
+		gup_flags = GUP_FLAGS_PINNING_PAGE;
+		if (write)
+			gup_flags |= GUP_FLAGS_WRITE;
+
 		down_read(&mm->mmap_sem);
-		ret = get_user_pages(current, mm, start,
-			(end - start) >> PAGE_SHIFT, write, 0, pages, NULL);
+		ret = __get_user_pages(current, mm, start,
+				       (end - start) >> PAGE_SHIFT, gup_flags,
+				       pages, NULL);
 		up_read(&mm->mmap_sem);
 
 		/* Have to be a bit careful with return values */
diff --git a/fs/direct-io.c b/fs/direct-io.c
index b6d4390..4f46720 100644
--- a/fs/direct-io.c
+++ b/fs/direct-io.c
@@ -131,6 +131,9 @@ struct dio {
 	int is_async;			/* is IO async ? */
 	int io_error;			/* IO error in completion path */
 	ssize_t result;                 /* IO result */
+
+	/* fork exclusive stuff */
+	struct mm_struct *mm;
 };
 
 /*
@@ -243,6 +246,9 @@ static int dio_complete(struct dio *dio, loff_t offset, int ret)
 	if (dio->lock_type == DIO_LOCKING)
 		/* lockdep: non-owner release */
 		up_read_non_owner(&dio->inode->i_alloc_sem);
+	up_read_non_owner(&dio->mm->mm_pinned_sem);
+	mmdrop(dio->mm);
+	dio->mm = NULL;
 
 	if (ret == 0)
 		ret = dio->page_errors;
@@ -942,6 +948,7 @@ direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode,
 	ssize_t ret = 0;
 	ssize_t ret2;
 	size_t bytes;
+	struct mm_struct *mm;
 
 	dio->inode = inode;
 	dio->rw = rw;
@@ -960,6 +967,10 @@ direct_io_worker(int rw, struct kiocb *iocb, struct inode *inode,
 	spin_lock_init(&dio->bio_lock);
 	dio->refcount = 1;
 
+	mm = dio->mm = current->mm;
+	atomic_inc(&mm->mm_count);
+	down_read_non_owner(&mm->mm_pinned_sem);
+
 	/*
 	 * In case of non-aligned buffers, we may need 2 more
 	 * pages since we need to zero out first and last block.
diff --git a/include/linux/init_task.h b/include/linux/init_task.h
index e752d97..3bc134a 100644
--- a/include/linux/init_task.h
+++ b/include/linux/init_task.h
@@ -37,6 +37,7 @@ extern struct fs_struct init_fs;
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(name.page_table_lock),	\
 	.mmlist		= LIST_HEAD_INIT(name.mmlist),		\
 	.cpu_vm_mask	= CPU_MASK_ALL,				\
+	.mm_pinned_sem	= __RWSEM_INITIALIZER(name.mm_pinned_sem), \
 }
 
 #define INIT_SIGNALS(sig) {						\
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 065cdf8..dcc6ccc 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -823,6 +823,15 @@ static inline int handle_mm_fault(struct mm_struct *mm,
 extern int make_pages_present(unsigned long addr, unsigned long end);
 extern int access_process_vm(struct task_struct *tsk, unsigned long addr, void *buf, int len, int write);
 
+#define GUP_FLAGS_WRITE				0x01
+#define GUP_FLAGS_FORCE				0x02
+#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS	0x04
+#define GUP_FLAGS_IGNORE_SIGKILL		0x08
+#define GUP_FLAGS_PINNING_PAGE			0x10
+
+int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		     unsigned long start, int len, int flags,
+		     struct page **pages, struct vm_area_struct **vmas);
 int get_user_pages(struct task_struct *tsk, struct mm_struct *mm, unsigned long start,
 		int len, int write, int force, struct page **pages, struct vm_area_struct **vmas);
 
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index d84feb7..27089d9 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -274,6 +274,12 @@ struct mm_struct {
 #ifdef CONFIG_MMU_NOTIFIER
 	struct mmu_notifier_mm *mmu_notifier_mm;
 #endif
+
+	/*
+	 * if there are on-flight directio or similar pinning action,
+	 * COW cause memory corruption. the sem protect it by preventing fork.
+	 */
+	struct rw_semaphore mm_pinned_sem;
 };
 
 /* Future-safe accessor for struct mm_struct's cpu_vm_mask. */
diff --git a/kernel/fork.c b/kernel/fork.c
index 4854c2c..ded7caf 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -266,6 +266,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 	unsigned long charge;
 	struct mempolicy *pol;
 
+	down_write(&oldmm->mm_pinned_sem);
 	down_write(&oldmm->mmap_sem);
 	flush_cache_dup_mm(oldmm);
 	/*
@@ -368,6 +369,7 @@ out:
 	up_write(&mm->mmap_sem);
 	flush_tlb_mm(oldmm);
 	up_write(&oldmm->mmap_sem);
+	up_write(&oldmm->mm_pinned_sem);
 	return retval;
 fail_nomem_policy:
 	kmem_cache_free(vm_area_cachep, tmp);
@@ -431,6 +433,7 @@ static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_owner(mm, p);
+	init_rwsem(&mm->mm_pinned_sem);
 
 	if (likely(!mm_alloc_pgd(mm))) {
 		mm->def_flags = 0;
diff --git a/mm/internal.h b/mm/internal.h
index 478223b..04f25d2 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -272,14 +272,4 @@ static inline void mminit_validate_memmodel_limits(unsigned long *start_pfn,
 {
 }
 #endif /* CONFIG_SPARSEMEM */
-
-#define GUP_FLAGS_WRITE                  0x1
-#define GUP_FLAGS_FORCE                  0x2
-#define GUP_FLAGS_IGNORE_VMA_PERMISSIONS 0x4
-#define GUP_FLAGS_IGNORE_SIGKILL         0x8
-
-int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		     unsigned long start, int len, int flags,
-		     struct page **pages, struct vm_area_struct **vmas);
-
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index baa999e..b00e3e9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1211,6 +1211,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 	int force = !!(flags & GUP_FLAGS_FORCE);
 	int ignore = !!(flags & GUP_FLAGS_IGNORE_VMA_PERMISSIONS);
 	int ignore_sigkill = !!(flags & GUP_FLAGS_IGNORE_SIGKILL);
+	int decow = 0;
 
 	if (len <= 0)
 		return 0;
@@ -1279,6 +1280,20 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 			continue;
 		}
 
+		/*
+		 * Except in special cases where the caller will not read to or
+		 * write from these pages, we must break COW for any pages
+		 * returned from get_user_pages, so that our caller does not
+		 * subsequently end up with the pages of a parent or child
+		 * process after a COW takes place.
+		 */
+		if (flags & GUP_FLAGS_PINNING_PAGE) {
+			if (!pages)
+				return -EINVAL;
+			if (is_cow_mapping(vma->vm_flags))
+				decow = 1;
+		}
+
 		foll_flags = FOLL_TOUCH;
 		if (pages)
 			foll_flags |= FOLL_GET;
@@ -1299,7 +1314,7 @@ int __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
 					fatal_signal_pending(current)))
 				return i ? i : -ERESTARTSYS;
 
-			if (write)
+			if (write || decow)
 				foll_flags |= FOLL_WRITE;
 
 			cond_resched();
diff --git a/mm/util.c b/mm/util.c
index 37eaccd..a80d5d3 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -197,10 +197,14 @@ int __attribute__((weak)) get_user_pages_fast(unsigned long start,
 {
 	struct mm_struct *mm = current->mm;
 	int ret;
+	int gup_flags = GUP_FLAGS_PINNING_PAGE;
+
+	if (write)
+		gup_flags |= GUP_FLAGS_WRITE;
 
 	down_read(&mm->mmap_sem);
-	ret = get_user_pages(current, mm, start, nr_pages,
-					write, 0, pages, NULL);
+	ret = __get_user_pages(current, mm, start, nr_pages,
+			       gup_flags, pages, NULL);
 	up_read(&mm->mmap_sem);
 
 	return ret;



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
