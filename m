Message-ID: <3D2BC6DB.B60E010D@zip.com.au>
Date: Tue, 09 Jul 2002 22:32:11 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <3D2A55D0.35C5F523@zip.com.au> <1214790647.1026163711@[10.10.2.3]> <3D2A7466.AD867DA7@zip.com.au> <20020709173246.GG8878@dualathlon.random>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli wrote:
> 
> the patch with the hooks into the page fault handler is basically
> what Martin was suggesting me at ols when I was laughting. the ugliest
> part is the implicit dependency on every copy-user to store the current
> source and destination in esi/dsi.

Ah, but note how I called the patch "linus-copy_user-hack".  That clearly
identifies who is to blame.

But yes.

However it seems that the esi/edi restriction isn't too bad.  If someone
has a smarter copy_*_user implementation then they'll have to use the old
one in certain places, or use those registers, or write fixup code for the
new implementation.

I tested it with the IBM folks' faster copy_*_user patch which
fixes the Intel alignment thing.  Worked OK.

> However your implementation is still not as optimizes as you can
> optimize it, if you take the max-performnace route you should do it all,
> you shouldn't kunmap_atomic/kmap_atomic blindly around the page fault
> handler like you're doing now. you should hold on the atomic kmap for
> the whole page fault until a new kmap_atomic of the same type happens on
> the current cpu under you during the page fault (either from the page
> fault handler itself or another task because the page fault handler
> blocked and scheduled in another task).

Good stuff, thanks.  Did that.  New patch is here.  I stuck with
KM_FILEMAP because KM_USER0 is used in the COW code, and that
is in fact called inside the filemap fault handler.  So basically
the "oh drat" path was being taken all the time.

> ...
> NOTE: you don't need to execute the kunmap_atomic at all in the
> recursive case, just disable the debugging (infact if you take this
> route you can as well drop the kunmap_atomic call enterely from the
> common code, you may want to verify the ppc or sparc guys aren't doing
> something magic in the kunmap first, in such case you may want to skip
> it only during recursion in the i386/mm/fault.c). Don't blame the fact
> we lose some debugging capability, you want max performance at all costs
> remeber?

Well, the non-recursive case is the common case.  And yes, maybe.  Could
use `ifdef CONFIG_HIGHMEM_DEBUG' and then open-code the preempt_enable()
in there I guess...

Here's the diff.  The kmap() and kmap_atomic() rate is way down
now.  Still no benefit from it all through.  Martin.  Help.


 arch/i386/kernel/i386_ksyms.c   |    5 ++
 arch/i386/lib/usercopy.c        |   10 +++++
 arch/i386/mm/fault.c            |   71 +++++++++++++++++++++++++++++++++++
 fs/exec.c                       |   60 +++++++++++++++++++++---------
 include/asm-i386/highmem.h      |    5 ++
 include/asm-i386/kmap_types.h   |    3 +
 include/asm-i386/processor.h    |    2 +
 include/asm-ppc/kmap_types.h    |    1 
 include/asm-sparc/kmap_types.h  |    1 
 include/asm-x86_64/kmap_types.h |    1 
 include/linux/highmem.h         |   80 ++++++++++++++++++++++++++++++++++++++++
 include/linux/sched.h           |    5 ++
 mm/filemap.c                    |   11 +++--
 13 files changed, 232 insertions(+), 23 deletions(-)

--- 2.5.25/arch/i386/kernel/i386_ksyms.c~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/arch/i386/kernel/i386_ksyms.c	Tue Jul  9 21:12:35 2002
@@ -14,6 +14,7 @@
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/tty.h>
+#include <linux/highmem.h>
 
 #include <asm/semaphore.h>
 #include <asm/processor.h>
@@ -76,6 +77,10 @@ EXPORT_SYMBOL(get_cmos_time);
 EXPORT_SYMBOL(apm_info);
 EXPORT_SYMBOL(gdt);
 
+#ifdef CONFIG_HIGHMEM
+EXPORT_SYMBOL(kmap_atomic_seq);
+#endif
+
 #ifdef CONFIG_DEBUG_IOVIRT
 EXPORT_SYMBOL(__io_virt_debug);
 #endif
--- 2.5.25/arch/i386/lib/usercopy.c~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/arch/i386/lib/usercopy.c	Tue Jul  9 21:12:35 2002
@@ -11,6 +11,16 @@
 
 #ifdef CONFIG_X86_USE_3DNOW_AND_WORKS
 
+/*
+ * We cannot use the mmx functions here with the kmap_atomic fixup
+ * code.
+ *
+ * But CONFIG_X86_USE_3DNOW_AND_WORKS never gets defined anywhere.
+ * Maybe kill this code?
+ */
+
+#error this will not work
+
 unsigned long
 __generic_copy_to_user(void *to, const void *from, unsigned long n)
 {
--- 2.5.25/arch/i386/mm/fault.c~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/arch/i386/mm/fault.c	Tue Jul  9 21:34:38 2002
@@ -18,6 +18,7 @@
 #include <linux/ptrace.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/interrupt.h>
@@ -138,6 +139,70 @@ void bust_spinlocks(int yes)
 	}
 }
 
+#ifdef CONFIG_HIGHMEM
+
+/*
+ * per-cpu, per-atomic-kmap sequence numbers.  Incremented in kmap_atomic.
+ * If these change, we know that an atomic kmap slot has been reused.
+ */
+int kmap_atomic_seq[KM_TYPE_NR] __per_cpu_data = {0};
+
+/*
+ * Note the CPU ID and the currently-held atomic kmap's sequence number
+ */
+static inline void note_atomic_kmap(struct pt_regs *regs)
+{
+	struct copy_user_state *cus = current->copy_user_state;
+
+	if (cus) {
+		cus->cpu = smp_processor_id();
+		cus->seq = this_cpu(kmap_atomic_seq[cus->type]);
+	}
+}
+
+/*
+ * After processing the fault, look to see whether we have switched CPUs
+ * or whether the fault handler has used the same kmap slot (it must have
+ * scheduled to another task).  If so, drop the kmap and get a new one.
+ * And then fix up the machine register which copy_*_user() is using so
+ * that it gets the correct address relative to the the new kmap.
+ */
+static void
+__check_atomic_kmap(struct copy_user_state *cus, struct pt_regs *regs)
+{
+	const int cpu = smp_processor_id();
+
+	if (cus->seq != per_cpu(kmap_atomic_seq[cus->type], cpu) ||
+				cus->cpu != cpu) {
+		long *reg;
+		unsigned offset;
+
+		kunmap_atomic(cus->kaddr, cus->type);
+		cus->kaddr = kmap_atomic(cus->page, cus->type);
+		if (cus->src)
+			reg = &regs->esi;
+		else
+			reg = &regs->edi;
+		offset = *reg & (PAGE_SIZE - 1);
+		*reg = ((long)cus->kaddr) | offset;
+	}
+}
+
+static inline void check_atomic_kmap(struct pt_regs *regs)
+{
+	struct copy_user_state *cus = current->copy_user_state;
+
+	if (cus)
+		__check_atomic_kmap(cus, regs);
+}
+	
+#else
+static inline void note_atomic_kmap(struct pt_regs *regs)
+{}
+static inline void check_atomic_kmap(struct pt_regs *regs)
+{}
+#endif
+
 asmlinkage void do_invalid_op(struct pt_regs *, unsigned long);
 extern unsigned long idt;
 
@@ -206,6 +271,8 @@ asmlinkage void do_page_fault(struct pt_
 	}
 #endif
 
+	note_atomic_kmap(regs);
+
 	down_read(&mm->mmap_sem);
 
 	vma = find_vma(mm, address);
@@ -267,8 +334,10 @@ good_area:
 			tsk->maj_flt++;
 			break;
 		case VM_FAULT_SIGBUS:
+			check_atomic_kmap(regs);
 			goto do_sigbus;
 		case VM_FAULT_OOM:
+			check_atomic_kmap(regs);
 			goto out_of_memory;
 		default:
 			BUG();
@@ -283,6 +352,7 @@ good_area:
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
 	up_read(&mm->mmap_sem);
+	check_atomic_kmap(regs);
 	return;
 
 /*
@@ -291,6 +361,7 @@ good_area:
  */
 bad_area:
 	up_read(&mm->mmap_sem);
+	check_atomic_kmap(regs);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if (error_code & 4) {
--- 2.5.25/fs/exec.c~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/fs/exec.c	Tue Jul  9 21:53:51 2002
@@ -184,25 +184,39 @@ static int count(char ** argv, int max)
  */
 int copy_strings(int argc,char ** argv, struct linux_binprm *bprm) 
 {
+	struct page *kmapped_page = NULL;
+	char *kaddr = NULL;
+	int ret;
+
 	while (argc-- > 0) {
 		char *str;
 		int len;
 		unsigned long pos;
 
-		if (get_user(str, argv+argc) || !(len = strnlen_user(str, bprm->p)))
-			return -EFAULT;
-		if (bprm->p < len) 
-			return -E2BIG; 
+		if (get_user(str, argv+argc) ||
+				!(len = strnlen_user(str, bprm->p))) {
+			ret = -EFAULT;
+			goto out;
+		}
+
+		if (bprm->p < len)  {
+			ret = -E2BIG;
+			goto out;
+		}
 
 		bprm->p -= len;
 		/* XXX: add architecture specific overflow check here. */ 
-
 		pos = bprm->p;
+
+		/*
+		 * The only sleeping function which we are allowed to call in
+		 * this loop is copy_from_user().  Otherwise, copy_user_state
+		 * could get trashed.
+		 */
 		while (len > 0) {
-			char *kaddr;
 			int i, new, err;
-			struct page *page;
 			int offset, bytes_to_copy;
+			struct page *page;
 
 			offset = pos % PAGE_SIZE;
 			i = pos/PAGE_SIZE;
@@ -211,32 +225,44 @@ int copy_strings(int argc,char ** argv, 
 			if (!page) {
 				page = alloc_page(GFP_HIGHUSER);
 				bprm->page[i] = page;
-				if (!page)
-					return -ENOMEM;
+				if (!page) {
+					ret = -ENOMEM;
+					goto out;
+				}
 				new = 1;
 			}
-			kaddr = kmap(page);
 
+			if (page != kmapped_page) {
+				if (kmapped_page)
+					kunmap(kmapped_page);
+				kmapped_page = page;
+				kaddr = kmap(kmapped_page);
+			}
 			if (new && offset)
 				memset(kaddr, 0, offset);
 			bytes_to_copy = PAGE_SIZE - offset;
 			if (bytes_to_copy > len) {
 				bytes_to_copy = len;
 				if (new)
-					memset(kaddr+offset+len, 0, PAGE_SIZE-offset-len);
+					memset(kaddr+offset+len, 0,
+						PAGE_SIZE-offset-len);
+			}
+			err = copy_from_user(kaddr+offset, str, bytes_to_copy);
+			if (err) {
+				ret = -EFAULT;
+				goto out;
 			}
-			err = copy_from_user(kaddr + offset, str, bytes_to_copy);
-			kunmap(page);
-
-			if (err)
-				return -EFAULT; 
 
 			pos += bytes_to_copy;
 			str += bytes_to_copy;
 			len -= bytes_to_copy;
 		}
 	}
-	return 0;
+	ret = 0;
+out:
+	if (kmapped_page)
+		kunmap(kmapped_page);
+	return ret;
 }
 
 /*
--- 2.5.25/include/asm-i386/highmem.h~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/include/asm-i386/highmem.h	Tue Jul  9 21:12:35 2002
@@ -22,6 +22,7 @@
 
 #include <linux/config.h>
 #include <linux/interrupt.h>
+#include <linux/percpu.h>
 #include <asm/kmap_types.h>
 #include <asm/tlbflush.h>
 
@@ -76,6 +77,8 @@ static inline void kunmap(struct page *p
  * be used in IRQ contexts, so in some (very limited) cases we need
  * it.
  */
+extern int kmap_atomic_seq[KM_TYPE_NR] __per_cpu_data;
+
 static inline void *kmap_atomic(struct page *page, enum km_type type)
 {
 	enum fixed_addresses idx;
@@ -93,7 +96,7 @@ static inline void *kmap_atomic(struct p
 #endif
 	set_pte(kmap_pte-idx, mk_pte(page, kmap_prot));
 	__flush_tlb_one(vaddr);
-
+	this_cpu(kmap_atomic_seq[type])++;
 	return (void*) vaddr;
 }
 
--- 2.5.25/include/asm-i386/processor.h~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/include/asm-i386/processor.h	Tue Jul  9 21:12:35 2002
@@ -485,4 +485,6 @@ extern inline void prefetchw(const void 
 
 #endif
 
+#define ARCH_HAS_KMAP_FIXUP
+
 #endif /* __ASM_I386_PROCESSOR_H */
--- 2.5.25/include/linux/highmem.h~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/include/linux/highmem.h	Tue Jul  9 21:54:59 2002
@@ -3,6 +3,7 @@
 
 #include <linux/config.h>
 #include <linux/fs.h>
+#include <asm/processor.h>
 #include <asm/cacheflush.h>
 
 #ifdef CONFIG_HIGHMEM
@@ -10,6 +11,7 @@
 extern struct page *highmem_start_page;
 
 #include <asm/highmem.h>
+#include <asm/kmap_types.h>
 
 /* declarations for linux/mm/highmem.c */
 unsigned int nr_free_highpages(void);
@@ -72,4 +74,82 @@ static inline void copy_user_highpage(st
 	kunmap_atomic(vto, KM_USER1);
 }
 
+#if defined(CONFIG_HIGHMEM) && defined(ARCH_HAS_KMAP_FIXUP)
+/*
+ * Used when performing a copy_*_user while holding an atomic kmap
+ */
+struct copy_user_state {
+	struct page *page;	/* The page which is kmap_atomiced */
+	void *kaddr;		/* Its mapping */
+	enum km_type type;	/* Its offset */
+	int src;		/* 1: fixup ESI.  0: Fixup EDI */
+	int cpu;		/* CPU which the kmap was taken on */
+	int seq;		/* The kmap's sequence number */
+};
+
+/*
+ * `src' is true if the kmap_atomic virtual address is the source of the copy.
+ */
+static inline void *
+kmap_copy_user(struct copy_user_state *cus, struct page *page,
+			enum km_type type, int src)
+{
+	cus->page = page;
+	cus->kaddr = kmap_atomic(page, type);
+	if (PageHighMem(page)) {
+		cus->type = type;
+		cus->src = src;
+		BUG_ON(current->copy_user_state != NULL);
+		current->copy_user_state = cus;
+	}
+	return cus->kaddr;
+}
+
+static inline void kunmap_copy_user(struct copy_user_state *cus)
+{
+	if (PageHighMem(cus->page)) {
+		BUG_ON(current->copy_user_state != cus);
+		kunmap_atomic(cus->kaddr, cus->type);
+		current->copy_user_state = NULL;
+		cus->page = NULL;	/* debug */
+	}
+}
+
+/*
+ * After a copy_*_user, the kernel virtual address may be different.  So
+ * use kmap_copy_user_addr() to get the new value.
+ */
+static inline void *kmap_copy_user_addr(struct copy_user_state *cus)
+{
+	return cus->kaddr;
+}
+
+#else
+
+struct copy_user_state {
+	struct page *page;
+};
+
+/*
+ * This must be a macro because `type' may be undefined
+ */
+
+#define kmap_copy_user(cus, page, type, src)	\
+	({					\
+		(cus)->page = (page);		\
+		kmap(page);			\
+	})
+
+static inline void kunmap_copy_user(struct copy_user_state *cus)
+{
+	kunmap(cus->page);
+}
+
+static inline void *kmap_copy_user_addr(struct copy_user_state *cus)
+{
+	return page_address(cus->page);
+}
+
+#endif
+
 #endif /* _LINUX_HIGHMEM_H */
--- 2.5.25/include/linux/sched.h~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/include/linux/sched.h	Tue Jul  9 21:12:35 2002
@@ -248,6 +248,8 @@ extern struct user_struct root_user;
 
 typedef struct prio_array prio_array_t;
 
+struct copy_user_state;
+
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
 	struct thread_info *thread_info;
@@ -365,6 +367,9 @@ struct task_struct {
 /* journalling filesystem info */
 	void *journal_info;
 	struct dentry *proc_dentry;
+#ifdef CONFIG_HIGHMEM
+	struct copy_user_state *copy_user_state;
+#endif
 };
 
 extern void __put_task_struct(struct task_struct *tsk);
--- 2.5.25/mm/filemap.c~linus-copy_user-hack	Tue Jul  9 21:12:35 2002
+++ 2.5.25-akpm/mm/filemap.c	Tue Jul  9 21:53:51 2002
@@ -15,6 +15,7 @@
 #include <linux/fs.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/highmem.h>
 #include <linux/pagemap.h>
 #include <linux/file.h>
 #include <linux/iobuf.h>
@@ -1183,18 +1184,20 @@ static ssize_t generic_file_direct_IO(in
 	return retval;
 }
 
-int file_read_actor(read_descriptor_t * desc, struct page *page, unsigned long offset, unsigned long size)
+int file_read_actor(read_descriptor_t *desc, struct page *page,
+			unsigned long offset, unsigned long size)
 {
 	char *kaddr;
+	struct copy_user_state copy_user_state;
 	unsigned long left, count = desc->count;
 
 	if (size > count)
 		size = count;
 
-	kaddr = kmap(page);
+	kaddr = kmap_copy_user(&copy_user_state, page, KM_FILEMAP, 1);
 	left = __copy_to_user(desc->buf, kaddr + offset, size);
-	kunmap(page);
-	
+	kunmap_copy_user(&copy_user_state);
+
 	if (left) {
 		size -= left;
 		desc->error = -EFAULT;
--- 2.5.25/include/asm-i386/kmap_types.h~linus-copy_user-hack	Tue Jul  9 21:13:02 2002
+++ 2.5.25-akpm/include/asm-i386/kmap_types.h	Tue Jul  9 21:13:43 2002
@@ -19,7 +19,8 @@ D(5)	KM_BIO_SRC_IRQ,
 D(6)	KM_BIO_DST_IRQ,
 D(7)	KM_PTE0,
 D(8)	KM_PTE1,
-D(9)	KM_TYPE_NR
+D(9)	KM_FILEMAP,
+D(10)	KM_TYPE_NR
 };
 
 #undef D
--- 2.5.25/include/asm-ppc/kmap_types.h~linus-copy_user-hack	Tue Jul  9 21:13:06 2002
+++ 2.5.25-akpm/include/asm-ppc/kmap_types.h	Tue Jul  9 21:13:49 2002
@@ -15,6 +15,7 @@ enum km_type {
 	KM_BIO_DST_IRQ,
 	KM_PTE0,
 	KM_PTE1,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/asm-sparc/kmap_types.h~linus-copy_user-hack	Tue Jul  9 21:13:09 2002
+++ 2.5.25-akpm/include/asm-sparc/kmap_types.h	Tue Jul  9 21:13:55 2002
@@ -9,6 +9,7 @@ enum km_type {
 	KM_USER1,
 	KM_BIO_SRC_IRQ,
 	KM_BIO_DST_IRQ,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/asm-x86_64/kmap_types.h~linus-copy_user-hack	Tue Jul  9 21:13:12 2002
+++ 2.5.25-akpm/include/asm-x86_64/kmap_types.h	Tue Jul  9 21:14:01 2002
@@ -9,6 +9,7 @@ enum km_type {
 	KM_USER1,
 	KM_BIO_SRC_IRQ,
 	KM_BIO_DST_IRQ,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
