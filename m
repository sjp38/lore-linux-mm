Message-ID: <3D2A55D0.35C5F523@zip.com.au>
Date: Mon, 08 Jul 2002 20:17:36 -0700
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: scalable kmap (was Re: vm lock contention reduction)
References: <1048271645.1025997192@[10.10.2.3]> <9820000.1026149363@flay>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <Martin.Bligh@us.ibm.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Linus Torvalds <torvalds@transmeta.com>, Rik van Riel <riel@conectiva.com.br>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" wrote:
> 
> OK, here's the data from Keith that I was promising on kmap. This was just
> for a kernel compile. So copy_strings and file_read_actor seem to be the
> main users (for this workload) by an order of magnitude.
> 
>                 0.00    0.00       1/3762429     remove_arg_zero [618]
>                 0.00    0.00      10/3762429     ext2_set_link [576]
>                 0.00    0.00     350/3762429     block_read_full_page [128]
>                 0.00    0.00     750/3762429     ext2_empty_dir [476]
>                 0.02    0.00   11465/3762429     ext2_delete_entry [217]
>                 0.02    0.00   12983/3762429     ext2_inode_by_name [228]
>                 0.03    0.00   15400/3762429     ext2_add_link [182]
>                 0.03    0.00   16621/3762429     ext2_find_entry [198]
>                 0.06    0.00   33016/3762429     ext2_readdir [79]
>                 0.13    0.00   71900/3762429     generic_file_write [109]
>                 0.17    0.00   95589/3762429     generic_commit_write [255]
>                 2.25    0.00 1229513/3762429     file_read_actor [50]
>                 4.15    0.00 2274831/3762429     copy_strings [36]
> [105]    0.2    6.87    0.00 3762429         kunmap_high [105]


It's a bit weird that copy_strings is the heaviest user of kmap().
I bet it's kmapping the same page over and over.  A little cache
there will help.  I'll fix that up.

So here's the patch.  Seems to work.  Across a `make -j6 bzImage'
the number of calls to kmap_high() went from 490,429 down to 41,174.

And guess what?   Zero change in wallclock time.

With:
        make -j6 bzImage  399.97s user 32.95s system 374% cpu 1:55.51 total
        kmap_high_counter: 41174

Without:
        make -j6 bzImage  400.06s user 32.74s system 377% cpu 1:54.78 total
        kmap_high_counter: 490429

Quad PIII Xeon, 2.5G RAM.

Any theories?


 arch/i386/lib/usercopy.c        |   10 +++++
 arch/i386/mm/fault.c            |   40 ++++++++++++++++++++
 fs/exec.c                       |    6 ++-
 include/asm-i386/kmap_types.h   |    3 +
 include/asm-i386/processor.h    |    2 +
 include/asm-ppc/kmap_types.h    |    1 
 include/asm-sparc/kmap_types.h  |    1 
 include/asm-x86_64/kmap_types.h |    1 
 include/linux/highmem.h         |   78 ++++++++++++++++++++++++++++++++++++++++
 include/linux/sched.h           |    5 ++
 mm/filemap.c                    |   11 +++--
 11 files changed, 151 insertions(+), 7 deletions(-)

--- 2.5.25/arch/i386/mm/fault.c~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/arch/i386/mm/fault.c	Mon Jul  8 20:08:20 2002
@@ -18,6 +18,7 @@
 #include <linux/ptrace.h>
 #include <linux/mman.h>
 #include <linux/mm.h>
+#include <linux/highmem.h>
 #include <linux/smp.h>
 #include <linux/smp_lock.h>
 #include <linux/interrupt.h>
@@ -138,6 +139,39 @@ void bust_spinlocks(int yes)
 	}
 }
 
+#ifdef CONFIG_HIGHMEM
+static inline void highmem_remove_atomic_kmap(struct pt_regs *regs)
+{
+	struct copy_user_state *cus = current->copy_user_state;
+
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
+		offset = *reg & (PAGE_SIZE - 1);
+		*reg = ((long)cus->kaddr) | offset;
+	}
+}
+#else
+static inline void highmem_remove_atomic_kmap(struct pt_regs *regs)
+{}
+static inline void highmem_restore_atomic_kmap(struct pt_regs *regs)
+{}
+#endif
+
 asmlinkage void do_invalid_op(struct pt_regs *, unsigned long);
 extern unsigned long idt;
 
@@ -206,6 +240,8 @@ asmlinkage void do_page_fault(struct pt_
 	}
 #endif
 
+	highmem_remove_atomic_kmap(regs);
+
 	down_read(&mm->mmap_sem);
 
 	vma = find_vma(mm, address);
@@ -267,8 +303,10 @@ good_area:
 			tsk->maj_flt++;
 			break;
 		case VM_FAULT_SIGBUS:
+			highmem_restore_atomic_kmap(regs);
 			goto do_sigbus;
 		case VM_FAULT_OOM:
+			highmem_restore_atomic_kmap(regs);
 			goto out_of_memory;
 		default:
 			BUG();
@@ -283,6 +321,7 @@ good_area:
 			tsk->thread.screen_bitmap |= 1 << bit;
 	}
 	up_read(&mm->mmap_sem);
+	highmem_restore_atomic_kmap(regs);
 	return;
 
 /*
@@ -291,6 +330,7 @@ good_area:
  */
 bad_area:
 	up_read(&mm->mmap_sem);
+	highmem_restore_atomic_kmap(regs);
 
 	/* User mode accesses just cause a SIGSEGV */
 	if (error_code & 4) {
--- 2.5.25/include/asm-i386/kmap_types.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/asm-i386/kmap_types.h	Mon Jul  8 19:58:03 2002
@@ -19,7 +19,8 @@ D(5)	KM_BIO_SRC_IRQ,
 D(6)	KM_BIO_DST_IRQ,
 D(7)	KM_PTE0,
 D(8)	KM_PTE1,
-D(9)	KM_TYPE_NR
+D(9)	KM_FILEMAP,
+D(10)	KM_TYPE_NR
 };
 
 #undef D
--- 2.5.25/include/asm-ppc/kmap_types.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/asm-ppc/kmap_types.h	Mon Jul  8 19:58:03 2002
@@ -15,6 +15,7 @@ enum km_type {
 	KM_BIO_DST_IRQ,
 	KM_PTE0,
 	KM_PTE1,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/asm-sparc/kmap_types.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/asm-sparc/kmap_types.h	Mon Jul  8 19:58:03 2002
@@ -9,6 +9,7 @@ enum km_type {
 	KM_USER1,
 	KM_BIO_SRC_IRQ,
 	KM_BIO_DST_IRQ,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/asm-x86_64/kmap_types.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/asm-x86_64/kmap_types.h	Mon Jul  8 19:58:03 2002
@@ -9,6 +9,7 @@ enum km_type {
 	KM_USER1,
 	KM_BIO_SRC_IRQ,
 	KM_BIO_DST_IRQ,
+	KM_FILEMAP,
 	KM_TYPE_NR
 };
 
--- 2.5.25/include/linux/highmem.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/linux/highmem.h	Mon Jul  8 20:13:05 2002
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
@@ -72,4 +74,80 @@ static inline void copy_user_highpage(st
 	kunmap_atomic(vto, KM_USER1);
 }
 
+#if defined(CONFIG_HIGHMEM) && defined(ARCH_HAS_KMAP_FIXUP)
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
--- 2.5.25/include/linux/sched.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/linux/sched.h	Mon Jul  8 20:14:08 2002
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
--- 2.5.25/mm/filemap.c~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/mm/filemap.c	Mon Jul  8 19:58:03 2002
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
--- 2.5.25/include/asm-i386/processor.h~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/include/asm-i386/processor.h	Mon Jul  8 19:58:03 2002
@@ -485,4 +485,6 @@ extern inline void prefetchw(const void 
 
 #endif
 
+#define ARCH_HAS_KMAP_FIXUP
+
 #endif /* __ASM_I386_PROCESSOR_H */
--- 2.5.25/arch/i386/lib/usercopy.c~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/arch/i386/lib/usercopy.c	Mon Jul  8 19:58:03 2002
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
--- 2.5.25/fs/exec.c~linus-copy_user-hack	Mon Jul  8 19:58:03 2002
+++ 2.5.25-akpm/fs/exec.c	Mon Jul  8 19:58:03 2002
@@ -203,6 +203,7 @@ int copy_strings(int argc,char ** argv, 
 			int i, new, err;
 			struct page *page;
 			int offset, bytes_to_copy;
+			struct copy_user_state copy_user_state;
 
 			offset = pos % PAGE_SIZE;
 			i = pos/PAGE_SIZE;
@@ -215,7 +216,8 @@ int copy_strings(int argc,char ** argv, 
 					return -ENOMEM;
 				new = 1;
 			}
-			kaddr = kmap(page);
+			kaddr = kmap_copy_user(&copy_user_state, page,
+						KM_FILEMAP, 0);
 
 			if (new && offset)
 				memset(kaddr, 0, offset);
@@ -226,7 +228,7 @@ int copy_strings(int argc,char ** argv, 
 					memset(kaddr+offset+len, 0, PAGE_SIZE-offset-len);
 			}
 			err = copy_from_user(kaddr + offset, str, bytes_to_copy);
-			kunmap(page);
+			kunmap_copy_user(&copy_user_state);
 
 			if (err)
 				return -EFAULT; 

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
