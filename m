Message-ID: <3D2A2B5C.946185AD@zip.com.au>
Date: Mon, 08 Jul 2002 17:16:28 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <9820000.1026149363@flay> <Pine.LNX.4.44.0207081503530.4650-100000@home.transmeta.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Andrea Arcangeli <andrea@suse.de>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> 
> ...
>         do_page_fault(..)
>         {
>                 ....
> 
>         +       if (current->preempt_count)
>         +               kunmap_atomic(ptregs->page_reg);
> 
>                 switch (handle_mm_fault(mm, vma, address, write)) {
>                 ....
>                 }
> 
>         +       if (current->preempt_count)
>         +               ptregs->addr_reg = (ptregs->addr_reg & ~PAGE_MASK) | kmap_atomic(ptregs->page_reg);
> 
>                 ...
> 
> which basically allows us to hold "atomic" kmap's over a page fault (and
> _only_ over a page fault, it wouldn't help for anything but the user copy
> case).

That'll work.

We need to use a bit more than preempt_count, because that
doesn't get incremented when CONFIG_PREEMPT=n, and we need
to know stuff like the kmap type and the page and the virtual
address within the fault handler.

I'll work on the below patch.  I'll need to audit the various
copy_*_user implementations to make sure that esi and edi are
really always the right registers to use.  Sigh.  I've been
trying to avoid understanding the x86 instruction set.

 arch/i386/mm/fault.c            |   39 +++++++++++++++++++++++++++++++++
 include/asm-i386/kmap_types.h   |    3 +-
 include/asm-ppc/kmap_types.h    |    1 
 include/asm-sparc/kmap_types.h  |    1 
 include/asm-x86_64/kmap_types.h |    1 
 include/linux/highmem.h         |   46 ++++++++++++++++++++++++++++++++++++++++
 include/linux/sched.h           |    7 ++++++
 mm/filemap.c                    |    8 +++++-
 8 files changed, 103 insertions, 3 deletions

--- 2.5.25/arch/i386/mm/fault.c~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/arch/i386/mm/fault.c	Mon Jul  8 17:13:16 2002
@@ -18,6 +18,7 @@
 #include <linux/ptrace.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/interrupt.h>
@@ -138,6 +139,40 @@ void bust_spinlocks(int yes)
 	}
 }
 
+#ifdef CONFIG_HIGHMEM
+static inline void highmem_remove_atomic_kmap(void)
+{
+	struct copy_user_state *cus = current->copy_user_state;
+
+	printk("%s\n", __FUNCTION__);
+	if (cus)
+		kunmap_atomic(cus->kaddr, cus->type);
+}
+
+static inline void highmem_restore_atomic_kmap(struct pt_regs *regs)
+{
+	struct copy_user_state *cus = current->copy_user_state;
+
+	if (cus) {
+		long *reg;
+		unsigned offset;
+
+		cus->kaddr = kmap_atomic(cus->page, cus->type);
+		if (cus->src)
+			reg = &regs->esi;
+		else
+			reg = &regs->edi;
+		offset = *reg & PAGE_SIZE;
+		*reg = ((long)cus->kaddr & ~(PAGE_SIZE - 1)) | offset;
+	}
+}
+#else
+static inline void highmem_remove_atomic_kmap(void)
+{}
+static inline void highmem_restore_atomic_kmap(struct pt_regs *regs)
+{}
+#endif
+
 asmlinkage void do_invalid_op(struct pt_regs *, unsigned long);
 extern unsigned long idt;
 
@@ -206,6 +241,8 @@ asmlinkage void do_page_fault(struct pt_
 	}
 #endif
 
+	highmem_remove_atomic_kmap();
+
 	down_read(&mm->mmap_sem);
 
 	vma = find_vma(mm, address);
@@ -283,6 +320,7 @@ good_area:
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
 	up_read(&mm->mmap_sem);
+	highmem_restore_atomic_kmap(regs);
 	return;
 
 /*
@@ -291,6 +329,7 @@ good_area:
  */
 bad_area:
 	up_read(&mm->mmap_sem);
+	highmem_restore_atomic_kmap(regs);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if (error_code & 4) {
--- 2.5.25/include/asm-i386/kmap_types.h~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/include/asm-i386/kmap_types.h	Mon Jul  8 17:13:16 2002
@@ -19,7 +19,8 @@ D(5)	KM_BIO_SRC_IRQ,
 D(6)	KM_BIO_DST_IRQ,
 D(7)	KM_PTE0,
 D(8)	KM_PTE1,
-D(9)	KM_TYPE_NR
+D(9)	KM_FILEMAP,
+D(10)	KM_TYPE_NR
 };
 
 #undef D
--- 2.5.25/include/asm-ppc/kmap_types.h~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/include/asm-ppc/kmap_types.h	Mon Jul  8 17:13:16 2002
@@ -15,6 +15,7 @@ enum km_type {
 	KM_BIO_DST_IRQ,
 	KM_PTE0,
 	KM_PTE1,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/asm-sparc/kmap_types.h~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/include/asm-sparc/kmap_types.h	Mon Jul  8 17:13:16 2002
@@ -9,6 +9,7 @@ enum km_type {
 	KM_USER1,
 	KM_BIO_SRC_IRQ,
 	KM_BIO_DST_IRQ,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/asm-x86_64/kmap_types.h~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/include/asm-x86_64/kmap_types.h	Mon Jul  8 17:13:16 2002
@@ -9,6 +9,7 @@ enum km_type {
 	KM_USER1,
 	KM_BIO_SRC_IRQ,
 	KM_BIO_DST_IRQ,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/linux/highmem.h~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/include/linux/highmem.h	Mon Jul  8 17:13:16 2002
@@ -10,12 +10,44 @@
 extern struct page *highmem_start_page;
 
 #include <asm/highmem.h>
+#include <asm/kmap_types.h>
 
 /* declarations for linux/mm/highmem.c */
 unsigned int nr_free_highpages(void);
 
 extern void check_highmem_ptes(void);
 
+/*
+ * Used when performing a copy_*_user while holding an atomic kmap
+ */
+struct copy_user_state {
+	struct page *page;		/* The page which is kmap_atomiced */
+	void *kaddr;			/* Its mapping */
+	enum km_type type;		/* Its offset */
+	int src;			/* 1: fixup ESI.  0: Fixup EDI */
+};
+
+/*
+ * `src' is true if the kmap_atomic virtual address is the source of the copy.
+ */
+static inline void
+pre_kmap_copy_user(struct copy_user_state *state, struct page *page,
+			void *kaddr, enum km_type type, int src)
+{
+	state->page = page;
+	state->kaddr = kaddr;
+	state->type = type;
+	state->src = src;
+	BUG_ON(current->copy_user_state != NULL);
+	current->copy_user_state = state;
+}
+
+static inline void post_kmap_copy_user(void)
+{
+	BUG_ON(current->copy_user_state == NULL);
+	current->copy_user_state = NULL;
+}
+	
 #else /* CONFIG_HIGHMEM */
 
 static inline unsigned int nr_free_highpages(void) { return 0; }
@@ -26,6 +58,20 @@ static inline void *kmap(struct page *pa
 
 #define kmap_atomic(page,idx)		kmap(page)
 #define kunmap_atomic(page,idx)		kunmap(page)
+
+struct copy_user_state {
+	int is_gcc_still_buggy;		/* ? */
+};
+
+static inline void
+pre_kmap_copy_user(struct copy_user_state *state, struct page *page,
+			void *kaddr, enum km_type type, int src)
+{
+}
+
+static inline void post_kmap_copy_user(void)
+{
+}
 
 #endif /* CONFIG_HIGHMEM */
 
--- 2.5.25/include/linux/sched.h~linus-copy_user-hack	Mon Jul  8 17:13:16 2002
+++ 2.5.25-akpm/include/linux/sched.h	Mon Jul  8 17:13:16 2002
@@ -248,6 +248,10 @@ extern struct user_struct root_user;
 
 typedef struct prio_array prio_array_t;
 
+#ifdef CONFIG_HIGHMEM
+struct copy_user_state;
+#endif
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	struct thread_info *thread_info;
@@ -365,6 +369,9 @@ struct task_struct {
 /* journalling filesystem info */
 	void *journal_info;
 	struct dentry *proc_dentry;
+#ifdef CONFIG_HIGHMEM
+	struct copy_user_state *copy_user_state;
+#endif
 };
 
 extern void __put_task_struct(struct task_struct *tsk);
--- 2.5.25/mm/filemap.c~linus-copy_user-hack	Mon Jul  8 17:13:22 2002
+++ 2.5.25-akpm/mm/filemap.c	Mon Jul  8 17:13:30 2002
@@ -15,6 +15,7 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/iobuf.h>
@@ -1186,14 +1187,17 @@ static ssize_t generic_file_direct_IO(in
 int file_read_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size)
 {
 	char *kaddr;
+	struct copy_user_state copy_user_state;
 	unsigned long left, count = desc->count;
 
 	if (size > count)
 		size = count;
 
-	kaddr = kmap(page);
+	kaddr = kmap_atomic(page, KM_FILEMAP);
+	pre_kmap_copy_user(&copy_user_state, page, kaddr, KM_FILEMAP, 1);
 	left = __copy_to_user(desc->buf, kaddr + offset, size);
-	kunmap(page);
+	post_kmap_copy_user();
+	kunmap_atomic(kaddr, KM_FILEMAP);
 	
 	if (left) {
 		size -= left;

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
