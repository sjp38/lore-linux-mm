Received: from willy by www.linux.org.uk with local (Exim 3.13 #1)
	id 14ZfmH-0001AV-00
	for linux-mm@kvack.org; Sun, 04 Mar 2001 21:10:53 +0000
Date: Sun, 4 Mar 2001 21:10:53 +0000
From: Matthew Wilcox <matthew@wil.cx>
Subject: Shared mmaps
Message-ID: <20010304211053.F1865@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Sparc & IA64 use a flag in the task_struct to indicate that they're trying
to allocate an mmap which is shared.  That's really ugly, let's just pass
the flags in to the get_mapped_area function instead.  I had to invent a
new flag for this because mremap's flags are different to mmap's (bah!)

Comments?

----- Forwarded message from Matthew Wilcox <willy@ldl.fc.hp.com> -----

Index: arch/ia64/kernel/sys_ia64.c
===================================================================
RCS file: /home/cvs/parisc/linux/arch/ia64/kernel/sys_ia64.c,v
retrieving revision 1.5
diff -u -p -r1.5 sys_ia64.c
--- sys_ia64.c	2001/01/24 23:58:50	1.5
+++ sys_ia64.c	2001/03/04 20:09:48
@@ -22,7 +22,7 @@
 #define COLOR_ALIGN(addr)	(((addr) + SHMLBA - 1) & ~(SHMLBA - 1))
 
 unsigned long
-get_unmapped_area (unsigned long addr, unsigned long len)
+get_unmapped_area (unsigned long addr, unsigned long len, unsigned long flags)
 {
 	struct vm_area_struct * vmm;
 
@@ -31,7 +31,7 @@ get_unmapped_area (unsigned long addr, u
 	if (!addr)
 		addr = TASK_UNMAPPED_BASE;
 
-	if (current->thread.flags & IA64_THREAD_MAP_SHARED)
+	if (flags & _MAP_ALIGN)
 		addr = COLOR_ALIGN(addr);
 	else
 		addr = PAGE_ALIGN(addr);
@@ -45,6 +45,8 @@ get_unmapped_area (unsigned long addr, u
 		if (!vmm || addr + len <= vmm->vm_start)
 			return addr;
 		addr = vmm->vm_end;
+		if (flags & _MAP_ALIGN)
+			addr = COLOR_ALIGN(addr);
 	}
 }
 
@@ -198,13 +200,11 @@ do_mmap2 (unsigned long addr, unsigned l
 	}
 
 	if (flags & MAP_SHARED)
-		current->thread.flags |= IA64_THREAD_MAP_SHARED;
+		flags |= _MAP_ALIGN;
 
 	down(&current->mm->mmap_sem);
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up(&current->mm->mmap_sem);
-
-	current->thread.flags &= ~IA64_THREAD_MAP_SHARED;
 
 	if (file)
 		fput(file);
Index: arch/parisc/kernel/sys_parisc.c
===================================================================
RCS file: /home/cvs/parisc/linux/arch/parisc/kernel/sys_parisc.c,v
retrieving revision 1.8
diff -u -p -r1.8 sys_parisc.c
--- sys_parisc.c	2001/03/04 04:48:53	1.8
+++ sys_parisc.c	2001/03/04 20:09:48
@@ -1,7 +1,7 @@
 /*
  * linux/arch/parisc/kernel/sys_parisc.c
  *
- * this implements the missing syscalls.
+ * this implements syscalls which are handled per-arch.
  */
 
 #include <asm/uaccess.h>
@@ -10,8 +10,37 @@
 #include <linux/linkage.h>
 #include <linux/mm.h>
 #include <linux/mman.h>
+#include <linux/shm.h>
 #include <linux/smp_lock.h>
 
+#define COLOUR_ALIGN(addr)      (((addr)+SHMLBA-1)&~(SHMLBA-1))
+
+unsigned long get_unmapped_area(unsigned long addr, unsigned long len, unsigned long flags)
+{
+	struct vm_area_struct * vmm;
+
+	if (len > TASK_SIZE)
+		return 0;
+	if (!addr)
+		addr = TASK_UNMAPPED_BASE;
+
+	if (flags & _MAP_ALIGN)
+		addr = COLOUR_ALIGN(addr);
+	else
+		addr = PAGE_ALIGN(addr);
+
+	for (vmm = find_vma(current->mm, addr); ; vmm = vmm->vm_next) {
+		/* At this point:  (!vmm || addr < vmm->vm_end). */
+		if (TASK_SIZE - len < addr)
+			return 0;
+		if (!vmm || addr + len <= vmm->vm_start)
+			return addr;
+		addr = vmm->vm_end;
+		if (flags & _MAP_ALIGN)
+			addr = COLOUR_ALIGN(addr);
+	}
+}
+
 int sys_pipe(int *fildes)
 {
 	int fd[2];
@@ -46,6 +75,9 @@ int sys_mmap(unsigned long addr, unsigne
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
+	if (flags & MAP_SHARED)
+		flags |= _MAP_ALIGN;
+
 	down(&current->mm->mmap_sem);
 	error = do_mmap(file, addr, len, prot, flags, offset);
 	up(&current->mm->mmap_sem);
@@ -56,10 +88,8 @@ out:
 	return error;
 }
 
-long sys_shmat_wrapper(int shmid, void *shmaddr, int shmflag)
+long sys_shmat_wrapper(int shmid, char *shmaddr, int shmflag)
 {
-	extern int sys_shmat(int shmid, char *shmaddr, int shmflg,
-			     unsigned long * raddr);
 	unsigned long raddr;
 	int r;
 
Index: arch/sparc/kernel/sys_sparc.c
===================================================================
RCS file: /home/cvs/parisc/linux/arch/sparc/kernel/sys_sparc.c,v
retrieving revision 1.5
diff -u -p -r1.5 sys_sparc.c
--- sys_sparc.c	2001/01/25 00:00:10	1.5
+++ sys_sparc.c	2001/03/04 20:09:48
@@ -36,7 +36,7 @@ asmlinkage unsigned long sys_getpagesize
 
 #define COLOUR_ALIGN(addr)      (((addr)+SHMLBA-1)&~(SHMLBA-1))
 
-unsigned long get_unmapped_area(unsigned long addr, unsigned long len)
+unsigned long get_unmapped_area(unsigned long addr, unsigned long len, unsigned long flags)
 {
 	struct vm_area_struct * vmm;
 
@@ -48,7 +48,7 @@ unsigned long get_unmapped_area(unsigned
 	if (!addr)
 		addr = TASK_UNMAPPED_BASE;
 
-	if (current->thread.flags & SPARC_FLAG_MMAPSHARED)
+	if (flags & _MAP_ALIGN)
 		addr = COLOUR_ALIGN(addr);
 	else
 		addr = PAGE_ALIGN(addr);
@@ -64,7 +64,7 @@ unsigned long get_unmapped_area(unsigned
 		if (!vmm || addr + len <= vmm->vm_start)
 			return addr;
 		addr = vmm->vm_end;
-		if (current->thread.flags & SPARC_FLAG_MMAPSHARED)
+		if (flags & _MAP_ALIGN)
 			addr = COLOUR_ALIGN(addr);
 	}
 }
@@ -234,14 +234,12 @@ static unsigned long do_mmap2(unsigned l
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
 	if (flags & MAP_SHARED)
-		current->thread.flags |= SPARC_FLAG_MMAPSHARED;
+		flags |= _MAP_ALIGN;
 
 	down(&current->mm->mmap_sem);
 	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	up(&current->mm->mmap_sem);
 
-	current->thread.flags &= ~(SPARC_FLAG_MMAPSHARED);
-
 out_putf:
 	if (file)
 		fput(file);
@@ -287,7 +285,7 @@ asmlinkage unsigned long sparc_mremap(un
 	down(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, addr);
 	if (vma && (vma->vm_flags & VM_SHARED))
-		current->thread.flags |= SPARC_FLAG_MMAPSHARED;
+		flags |= _MAP_ALIGN;
 	if (flags & MREMAP_FIXED) {
 		if (ARCH_SUN4C_SUN4 &&
 		    new_addr < 0xe0000000 &&
@@ -301,14 +299,13 @@ asmlinkage unsigned long sparc_mremap(un
 		ret = -ENOMEM;
 		if (!(flags & MREMAP_MAYMOVE))
 			goto out_sem;
-		new_addr = get_unmapped_area (addr, new_len);
+		new_addr = get_unmapped_area (addr, new_len, flags);
 		if (!new_addr)
 			goto out_sem;
 		flags |= MREMAP_FIXED;
 	}
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
 out_sem:
-	current->thread.flags &= ~(SPARC_FLAG_MMAPSHARED);
 	up(&current->mm->mmap_sem);
 out:
 	return ret;       
Index: arch/sparc64/kernel/sys_sparc.c
===================================================================
RCS file: /home/cvs/parisc/linux/arch/sparc64/kernel/sys_sparc.c,v
retrieving revision 1.7
diff -u -p -r1.7 sys_sparc.c
--- sys_sparc.c	2001/01/25 00:00:16	1.7
+++ sys_sparc.c	2001/03/04 20:09:48
@@ -42,7 +42,7 @@ asmlinkage unsigned long sys_getpagesize
 
 #define COLOUR_ALIGN(addr)	(((addr)+SHMLBA-1)&~(SHMLBA-1))
 
-unsigned long get_unmapped_area(unsigned long addr, unsigned long len)
+unsigned long get_unmapped_area(unsigned long addr, unsigned long len, unsigned long flags)
 {
 	struct vm_area_struct * vmm;
 	unsigned long task_size = TASK_SIZE;
@@ -54,7 +54,7 @@ unsigned long get_unmapped_area(unsigned
 	if (!addr)
 		addr = TASK_UNMAPPED_BASE;
 
-	if (current->thread.flags & SPARC_FLAG_MMAPSHARED)
+	if (flags & _MAP_ALIGN)
 		addr = COLOUR_ALIGN(addr);
 	else
 		addr = PAGE_ALIGN(addr);
@@ -72,7 +72,7 @@ unsigned long get_unmapped_area(unsigned
 		if (!vmm || addr + len <= vmm->vm_start)
 			return addr;
 		addr = vmm->vm_end;
-		if (current->thread.flags & SPARC_FLAG_MMAPSHARED)
+		if (flags & _MAP_ALIGN)
 			addr = COLOUR_ALIGN(addr);
 	}
 }
@@ -241,14 +241,12 @@ asmlinkage unsigned long sys_mmap(unsign
 	}
 
 	if (flags & MAP_SHARED)
-		current->thread.flags |= SPARC_FLAG_MMAPSHARED;
+		flags |= _MAP_ALIGN;
 
 	down(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
 	up(&current->mm->mmap_sem);
 
-	current->thread.flags &= ~(SPARC_FLAG_MMAPSHARED);
-
 out_putf:
 	if (file)
 		fput(file);
@@ -288,7 +286,7 @@ asmlinkage unsigned long sys64_mremap(un
 	down(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, addr);
 	if (vma && (vma->vm_flags & VM_SHARED))
-		current->thread.flags |= SPARC_FLAG_MMAPSHARED;
+		flags |= _MAP_ALIGN;
 	if (flags & MREMAP_FIXED) {
 		if (new_addr < PAGE_OFFSET &&
 		    new_addr + new_len > -PAGE_OFFSET)
@@ -297,14 +295,13 @@ asmlinkage unsigned long sys64_mremap(un
 		ret = -ENOMEM;
 		if (!(flags & MREMAP_MAYMOVE))
 			goto out_sem;
-		new_addr = get_unmapped_area(addr, new_len);
+		new_addr = get_unmapped_area(addr, new_len, flags);
 		if (!new_addr)
 			goto out_sem;
 		flags |= MREMAP_FIXED;
 	}
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
 out_sem:
-	current->thread.flags &= ~(SPARC_FLAG_MMAPSHARED);
 	up(&current->mm->mmap_sem);
 out:
 	return ret;       
Index: arch/sparc64/kernel/sys_sparc32.c
===================================================================
RCS file: /home/cvs/parisc/linux/arch/sparc64/kernel/sys_sparc32.c,v
retrieving revision 1.9
diff -u -p -r1.9 sys_sparc32.c
--- sys_sparc32.c	2001/02/02 03:35:43	1.9
+++ sys_sparc32.c	2001/03/04 20:09:48
@@ -4139,7 +4139,7 @@ asmlinkage unsigned long sys32_mremap(un
 	down(&current->mm->mmap_sem);
 	vma = find_vma(current->mm, addr);
 	if (vma && (vma->vm_flags & VM_SHARED))
-		current->thread.flags |= SPARC_FLAG_MMAPSHARED;
+		flags |= _MAP_ALIGN;
 	if (flags & MREMAP_FIXED) {
 		if (new_addr > 0xf0000000UL - new_len)
 			goto out_sem;
@@ -4147,14 +4147,13 @@ asmlinkage unsigned long sys32_mremap(un
 		ret = -ENOMEM;
 		if (!(flags & MREMAP_MAYMOVE))
 			goto out_sem;
-		new_addr = get_unmapped_area(addr, new_len);
+		new_addr = get_unmapped_area(addr, new_len, flags);
 		if (!new_addr)
 			goto out_sem;
 		flags |= MREMAP_FIXED;
 	}
 	ret = do_mremap(addr, old_len, new_len, flags, new_addr);
 out_sem:
-	current->thread.flags &= ~(SPARC_FLAG_MMAPSHARED);
 	up(&current->mm->mmap_sem);
 out:
 	return ret;       
Index: include/asm-parisc/processor.h
===================================================================
RCS file: /home/cvs/parisc/linux/include/asm-parisc/processor.h,v
retrieving revision 1.41
diff -u -p -r1.41 processor.h
--- processor.h	2001/03/02 08:28:56	1.41
+++ processor.h	2001/03/04 20:09:48
@@ -324,4 +324,7 @@ extern inline unsigned long get_wchan(st
 #define init_task (init_task_union.task) 
 #define init_stack (init_task_union.stack)
 
+/* We provide our own get_unmapped_area to cope with dcache aliasing */
+#define HAVE_ARCH_UNMAPPED_AREA
+
 #endif /* __ASM_PARISC_PROCESSOR_H */
Index: include/asm-sparc/processor.h
===================================================================
RCS file: /home/cvs/parisc/linux/include/asm-sparc/processor.h,v
retrieving revision 1.3
diff -u -p -r1.3 processor.h
--- processor.h	2001/01/25 00:03:14	1.3
+++ processor.h	2001/03/04 20:09:48
@@ -90,7 +90,6 @@ struct thread_struct {
 
 #define SPARC_FLAG_KTHREAD      0x1    /* task is a kernel thread */
 #define SPARC_FLAG_UNALIGNED    0x2    /* is allowed to do unaligned accesses */
-#define SPARC_FLAG_MMAPSHARED	0x4    /* task wants a shared mmap */
 
 #define INIT_MMAP { &init_mm, (0), (0), \
 		    NULL, __pgprot(0x0) , VM_READ | VM_WRITE | VM_EXEC, 1, NULL, NULL }
Index: include/asm-sparc64/processor.h
===================================================================
RCS file: /home/cvs/parisc/linux/include/asm-sparc64/processor.h,v
retrieving revision 1.5
diff -u -p -r1.5 processor.h
--- processor.h	2001/01/25 00:03:15	1.5
+++ processor.h	2001/03/04 20:09:48
@@ -80,7 +80,6 @@ struct thread_struct {
 #define SPARC_FLAG_32BIT        0x04    /* task is older 32-bit binary		*/
 #define SPARC_FLAG_NEWCHILD     0x08    /* task is just-spawned child process	*/
 #define SPARC_FLAG_PERFCTR	0x10    /* task has performance counters active	*/
-#define SPARC_FLAG_MMAPSHARED	0x20    /* task wants a shared mmap             */
 
 #define FAULT_CODE_WRITE	0x01	/* Write access, implies D-TLB		*/
 #define FAULT_CODE_DTLB		0x02	/* Miss happened in D-TLB		*/
Index: include/linux/mm.h
===================================================================
RCS file: /home/cvs/parisc/linux/include/linux/mm.h,v
retrieving revision 1.16
diff -u -p -r1.16 mm.h
--- mm.h	2001/02/08 22:39:19	1.16
+++ mm.h	2001/03/04 20:09:48
@@ -423,7 +423,7 @@ extern void insert_vm_struct(struct mm_s
 extern void __insert_vm_struct(struct mm_struct *, struct vm_area_struct *);
 extern void build_mmap_avl(struct mm_struct *);
 extern void exit_mmap(struct mm_struct *);
-extern unsigned long get_unmapped_area(unsigned long, unsigned long);
+extern unsigned long get_unmapped_area(unsigned long, unsigned long, unsigned long);
 
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
Index: include/linux/mman.h
===================================================================
RCS file: /home/cvs/parisc/linux/include/linux/mman.h,v
retrieving revision 1.2
diff -u -p -r1.2 mman.h
--- mman.h	2000/02/08 20:34:36	1.2
+++ mman.h	2001/03/04 20:09:48
@@ -5,5 +5,6 @@
 
 #define MREMAP_MAYMOVE	1
 #define MREMAP_FIXED	2
+#define _MAP_ALIGN	0x80000000		/* Align as required */
 
 #endif /* _LINUX_MMAN_H */
Index: mm/mmap.c
===================================================================
RCS file: /home/cvs/parisc/linux/mm/mmap.c,v
retrieving revision 1.19
diff -u -p -r1.19 mmap.c
--- mmap.c	2001/02/02 03:37:18	1.19
+++ mmap.c	2001/03/04 20:09:48
@@ -254,7 +254,7 @@ unsigned long do_mmap_pgoff(struct file 
 		if (addr & ~PAGE_MASK)
 			return -EINVAL;
 	} else {
-		addr = get_unmapped_area(addr, len);
+		addr = get_unmapped_area(addr, len, flags);
 		if (!addr)
 			return -ENOMEM;
 	}
@@ -376,7 +376,7 @@ free_vma:
  * Return value 0 means ENOMEM.
  */
 #ifndef HAVE_ARCH_UNMAPPED_AREA
-unsigned long get_unmapped_area(unsigned long addr, unsigned long len)
+unsigned long get_unmapped_area(unsigned long addr, unsigned long len, unsigned long flags)
 {
 	struct vm_area_struct * vmm;
 
Index: mm/mremap.c
===================================================================
RCS file: /home/cvs/parisc/linux/mm/mremap.c,v
retrieving revision 1.7
diff -u -p -r1.7 mremap.c
--- mremap.c	2001/01/25 00:03:36	1.7
+++ mremap.c	2001/03/04 20:09:48
@@ -276,7 +276,7 @@ unsigned long do_mremap(unsigned long ad
 	ret = -ENOMEM;
 	if (flags & MREMAP_MAYMOVE) {
 		if (!(flags & MREMAP_FIXED)) {
-			new_addr = get_unmapped_area(0, new_len);
+			new_addr = get_unmapped_area(0, new_len, flags);
 			if (!new_addr)
 				goto out;
 		}


_______________________________________________
parisc-linux-cvs mailing list
parisc-linux-cvs@lists.parisc-linux.org
http://lists.parisc-linux.org/cgi-bin/mailman/listinfo/parisc-linux-cvs

----- End forwarded message -----

-- 
Revolutions do not require corporate support.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
