Date: Sun, 18 Jun 2000 14:02:34 -0400 (EDT)
From: Ben LaHaise <bcrl@redhat.com>
Subject: [PATCH] move mmap_sem & lock kernel into do_mmap
Message-ID: <Pine.LNX.4.21.0006181359160.14917-100000@devserv.devel.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a patch that moves the down(&mm->mmap_dem) into do_mmap, as well as
fixing a few bugs in the various architecture's mmap syscalls.  <sigh>
Please yell at me if I've mangled it, but it seems to work here, and
deletes more lines than it adds. =)

		-ben

diff -ur 2.4.0-test1-ac19/arch/alpha/kernel/osf_sys.c test/arch/alpha/kernel/osf_sys.c
--- 2.4.0-test1-ac19/arch/alpha/kernel/osf_sys.c	Sat Jun 17 19:05:38 2000
+++ test/arch/alpha/kernel/osf_sys.c	Sat Jun 17 20:40:37 2000
@@ -230,7 +230,6 @@
 	struct file *file = NULL;
 	unsigned long ret = -EBADF;
 
-	lock_kernel();
 #if 0
 	if (flags & (_MAP_HASSEMAPHORE | _MAP_INHERIT | _MAP_UNALIGNED))
 		printk("%s: unimplemented OSF mmap flags %04lx\n", 
@@ -242,13 +241,10 @@
 			goto out;
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down(&current->mm->mmap_sem);
 	ret = do_mmap(file, addr, len, prot, flags, off);
-	up(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return ret;
 }
 
diff -ur 2.4.0-test1-ac19/arch/arm/kernel/sys_arm.c test/arch/arm/kernel/sys_arm.c
--- 2.4.0-test1-ac19/arch/arm/kernel/sys_arm.c	Fri May 12 14:21:20 2000
+++ test/arch/arm/kernel/sys_arm.c	Sat Jun 17 21:13:33 2000
@@ -65,13 +65,7 @@
 			goto out;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
diff -ur 2.4.0-test1-ac19/arch/i386/kernel/sys_i386.c test/arch/i386/kernel/sys_i386.c
--- 2.4.0-test1-ac19/arch/i386/kernel/sys_i386.c	Thu Jan 27 09:32:14 2000
+++ test/arch/i386/kernel/sys_i386.c	Sat Jun 17 21:26:02 2000
@@ -57,13 +57,7 @@
 			goto out;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
diff -ur 2.4.0-test1-ac19/arch/ia64/ia32/sys_ia32.c test/arch/ia64/ia32/sys_ia32.c
--- 2.4.0-test1-ac19/arch/ia64/ia32/sys_ia32.c	Sat Jun 17 19:05:38 2000
+++ test/arch/ia64/ia32/sys_ia32.c	Sat Jun 17 21:18:48 2000
@@ -103,15 +103,9 @@
 	 *  `execve' frees all current memory we only have to do an
 	 *  `munmap' if the `execve' failes.
 	 */
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	av = do_mmap_pgoff(0, NULL, len,
 		PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0);
 
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
-
 	if (IS_ERR(av))
 		return(av);
 	ae = av + na + 1;
@@ -221,6 +215,7 @@
 	front = NULL;
 	back = NULL;
 	if ((baddr = (addr & PAGE_MASK)) != addr && get_user(c, (char *)baddr) == 0) {
+		/* FIXME */
 		front = kmalloc(addr - baddr, GFP_KERNEL);
 		memcpy(front, (void *)baddr, addr - baddr);
 	}
@@ -228,12 +223,11 @@
 	if (addr)
 #endif
 	if (((addr + len) & ~PAGE_MASK) && get_user(c, (char *)(addr + len)) == 0) {
+		/* FIXME */
 		back = kmalloc(PAGE_SIZE - ((addr + len) & ~PAGE_MASK), GFP_KERNEL);
 		memcpy(back, addr + len, PAGE_SIZE - ((addr + len) & ~PAGE_MASK));
 	}
-	down(&current->mm->mmap_sem);
 	r = do_mmap(0, baddr, len + (addr - baddr), prot, flags | MAP_ANONYMOUS, 0);
-	up(&current->mm->mmap_sem);
 	if (r < 0)
 		return(r);
 #ifndef	DDD
@@ -293,7 +287,6 @@
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
 
-	lock_kernel();
 	if (!(a.flags & MAP_ANONYMOUS)) {
 		error = -EBADF;
 		file = fget(a.fd);
@@ -307,18 +300,13 @@
 #else	// DDD
 	if (1) {
 #endif	// DDD
-		unlock_kernel();
 		error = do_mmap_fake(file, a.addr, a.len, a.prot, a.flags, a.offset);
-		lock_kernel();
 	} else {
-		down(&current->mm->mmap_sem);
 		error = do_mmap(file, a.addr, a.len, a.prot, a.flags, a.offset);
-		up(&current->mm->mmap_sem);
 	}
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return error;
 }
 
diff -ur 2.4.0-test1-ac19/arch/ia64/kernel/sys_ia64.c test/arch/ia64/kernel/sys_ia64.c
--- 2.4.0-test1-ac19/arch/ia64/kernel/sys_ia64.c	Sun Feb 13 13:30:38 2000
+++ test/arch/ia64/kernel/sys_ia64.c	Sat Jun 17 21:20:51 2000
@@ -120,14 +120,8 @@
 			return -EBADF;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
-
 	if (file)
 		fput(file);
 	return addr;
@@ -155,6 +149,9 @@
 	  int fd, long off, long arg6, long arg7, long stack)
 {
 	struct pt_regs *regs = (struct pt_regs *) &stack;
+
+	if (off & PAGE_MASK)
+		return -EINVAL;
 
 	addr = do_mmap2(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 	if (!IS_ERR(addr))
diff -ur 2.4.0-test1-ac19/arch/m68k/kernel/sys_m68k.c test/arch/m68k/kernel/sys_m68k.c
--- 2.4.0-test1-ac19/arch/m68k/kernel/sys_m68k.c	Sat Jun 17 19:05:38 2000
+++ test/arch/m68k/kernel/sys_m68k.c	Sat Jun 17 21:06:34 2000
@@ -60,14 +60,8 @@
 			goto out;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
-
 	if (file)
 		fput(file);
 out:
@@ -143,7 +137,6 @@
 	if ((a.offset >> PAGE_SHIFT) != pgoff)
 		return -EINVAL;
 
-	lock_kernel();
 	if (!(a.flags & MAP_ANONYMOUS)) {
 		error = -EBADF;
 		file = fget(a.fd);
@@ -152,13 +145,10 @@
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return error;
 }
 #endif
diff -ur 2.4.0-test1-ac19/arch/mips/kernel/irixelf.c test/arch/mips/kernel/irixelf.c
--- 2.4.0-test1-ac19/arch/mips/kernel/irixelf.c	Sat Jun 17 19:05:38 2000
+++ test/arch/mips/kernel/irixelf.c	Sat Jun 17 20:54:56 2000
@@ -315,12 +315,10 @@
 		   (unsigned long) elf_prot, (unsigned long) elf_type,
 		   (unsigned long) (eppnt->p_offset & 0xfffff000));
 #endif
-	    down(&current->mm->mmap_sem);
 	    error = do_mmap(interpreter, vaddr,
 			    eppnt->p_filesz + (eppnt->p_vaddr & 0xfff),
 			    elf_prot, elf_type,
 			    eppnt->p_offset & 0xfffff000);
-	    up(&current->mm->mmap_sem);
 
 	    if(error < 0 && error > -1024) {
 		    printk("Aieee IRIX interp mmap error=%d\n", error);
@@ -500,12 +498,11 @@
 		prot  = (epp->p_flags & PF_R) ? PROT_READ : 0;
 		prot |= (epp->p_flags & PF_W) ? PROT_WRITE : 0;
 		prot |= (epp->p_flags & PF_X) ? PROT_EXEC : 0;
-	        down(&current->mm->mmap_sem);
+		/* FIXME: I like mysterious failures */
 		(void) do_mmap(fp, (epp->p_vaddr & 0xfffff000),
 			       (epp->p_filesz + (epp->p_vaddr & 0xfff)),
 			       prot, EXEC_MAP_FLAGS,
 			       (epp->p_offset & 0xfffff000));
-	        up(&current->mm->mmap_sem);
 
 		/* Fixup location tracking vars. */
 		if((epp->p_vaddr & 0xfffff000) < *estack)
@@ -764,10 +761,8 @@
 	 * Since we do not have the power to recompile these, we
 	 * emulate the SVr4 behavior.  Sigh.
 	 */
-	down(&current->mm->mmap_sem);
 	(void) do_mmap(NULL, 0, 4096, PROT_READ | PROT_EXEC,
 		       MAP_FIXED | MAP_PRIVATE, 0);
-	up(&current->mm->mmap_sem);
 #endif
 
 	start_thread(regs, elf_entry, bprm->p);
@@ -839,14 +834,12 @@
 	while(elf_phdata->p_type != PT_LOAD) elf_phdata++;
 	
 	/* Now use mmap to map the library into memory. */
-	down(&current->mm->mmap_sem);
 	error = do_mmap(file,
 			elf_phdata->p_vaddr & 0xfffff000,
 			elf_phdata->p_filesz + (elf_phdata->p_vaddr & 0xfff),
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			elf_phdata->p_offset & 0xfffff000);
-	up(&current->mm->mmap_sem);
 
 	k = elf_phdata->p_vaddr + elf_phdata->p_filesz;
 	if (k > elf_bss) elf_bss = k;
@@ -918,12 +911,10 @@
 		prot  = (hp->p_flags & PF_R) ? PROT_READ : 0;
 		prot |= (hp->p_flags & PF_W) ? PROT_WRITE : 0;
 		prot |= (hp->p_flags & PF_X) ? PROT_EXEC : 0;
-		down(&current->mm->mmap_sem);
 		retval = do_mmap(filp, (hp->p_vaddr & 0xfffff000),
 				 (hp->p_filesz + (hp->p_vaddr & 0xfff)),
 				 prot, (MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE),
 				 (hp->p_offset & 0xfffff000));
-		up(&current->mm->mmap_sem);
 
 		if(retval != (hp->p_vaddr & 0xfffff000)) {
 			printk("irix_mapelf: do_mmap fails with %d!\n", retval);
diff -ur 2.4.0-test1-ac19/arch/mips/kernel/syscall.c test/arch/mips/kernel/syscall.c
--- 2.4.0-test1-ac19/arch/mips/kernel/syscall.c	Sat May 13 11:29:14 2000
+++ test/arch/mips/kernel/syscall.c	Sat Jun 17 20:56:26 2000
@@ -70,14 +70,8 @@
 			goto out;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
-
 	if (file)
 		fput(file);
 out:
@@ -87,7 +81,10 @@
 asmlinkage unsigned long old_mmap(unsigned long addr, size_t len, int prot,
                                   int flags, int fd, off_t offset)
 {
-	return do_mmap2(addr, len, prot, flags, fd, offset >> PAGE_SHIFT);
+	unsigned long ret = -EINVAL;
+	if (!(offset & PAGE_MASK))
+		ret = do_mmap2(addr, len, prot, flags, fd, offset >> PAGE_SHIFT);
+	return ret;
 }
 
 asmlinkage long
diff -ur 2.4.0-test1-ac19/arch/mips/kernel/sysirix.c test/arch/mips/kernel/sysirix.c
--- 2.4.0-test1-ac19/arch/mips/kernel/sysirix.c	Sat Jun 17 19:05:38 2000
+++ test/arch/mips/kernel/sysirix.c	Sat Jun 17 21:02:06 2000
@@ -1076,7 +1076,6 @@
 	struct file *file = NULL;
 	unsigned long retval;
 
-	lock_kernel();
 	if (!(flags & MAP_ANONYMOUS)) {
 		if (!(file = fget(fd))) {
 			retval = -EBADF;
@@ -1099,15 +1098,11 @@
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, offset);
-	up(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 
 out:
-	unlock_kernel();
-
 	return retval;
 }
 
@@ -1646,6 +1641,7 @@
 	addr = regs->regs[base + 4];
 	len = regs->regs[base + 5];
 	prot = regs->regs[base + 6];
+	/* FIXME: why is verify_area being used?  Is this just mouldy code? */
 	if (!base) {
 		flags = regs->regs[base + 7];
 		error = verify_area(VERIFY_READ, sp, (4 * sizeof(unsigned long)));
@@ -1672,7 +1668,7 @@
 	pgoff = (off1 << (32 - PAGE_SHIFT)) | (off2 >> PAGE_SHIFT);
 
 	if (!(flags & MAP_ANONYMOUS)) {
-		if (!(file = fcheck(fd))) {
+		if (!(file = fget(fd))) {
 			error = -EBADF;
 			goto out;
 		}
@@ -1693,9 +1689,7 @@
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
diff -ur 2.4.0-test1-ac19/arch/mips64/kernel/linux32.c test/arch/mips64/kernel/linux32.c
--- 2.4.0-test1-ac19/arch/mips64/kernel/linux32.c	Sat May 13 11:30:17 2000
+++ test/arch/mips64/kernel/linux32.c	Sat Jun 17 21:21:56 2000
@@ -488,14 +488,8 @@
 	 *  `execve' frees all current memory we only have to do an
 	 *  `munmap' if the `execve' failes.
 	 */
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	av = (char **) do_mmap_pgoff(0, 0, len, PROT_READ | PROT_WRITE,
 				     MAP_PRIVATE | MAP_ANONYMOUS, 0);
-
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
 
 	if (IS_ERR(av))
 		return((long) av);
diff -ur 2.4.0-test1-ac19/arch/mips64/kernel/syscall.c test/arch/mips64/kernel/syscall.c
--- 2.4.0-test1-ac19/arch/mips64/kernel/syscall.c	Sat Jun 17 19:05:38 2000
+++ test/arch/mips64/kernel/syscall.c	Sat Jun 17 21:22:39 2000
@@ -56,7 +56,6 @@
 	struct file * file = NULL;
 	unsigned long error = -EFAULT;
 
-	lock_kernel();
 	if (!(flags & MAP_ANONYMOUS)) {
 		error = -EBADF;
 		file = fget(fd);
@@ -65,14 +64,10 @@
 	}
         flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down(&current->mm->mmap_sem);
         error = do_mmap(file, addr, len, prot, flags, offset);
-	up(&current->mm->mmap_sem);
         if (file)
                 fput(file);
 out:
-	unlock_kernel();
-
 	return error;
 }
 
diff -ur 2.4.0-test1-ac19/arch/ppc/kernel/syscalls.c test/arch/ppc/kernel/syscalls.c
--- 2.4.0-test1-ac19/arch/ppc/kernel/syscalls.c	Sun Feb 13 13:47:01 2000
+++ test/arch/ppc/kernel/syscalls.c	Sat Jun 17 21:04:00 2000
@@ -201,20 +201,16 @@
 	struct file * file = NULL;
 	int ret = -EBADF;
 
-	lock_kernel();
 	if (!(flags & MAP_ANONYMOUS)) {
 		if (!(file = fget(fd)))
 			goto out;
 	}
 	
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down(&current->mm->mmap_sem);
 	ret = do_mmap(file, addr, len, prot, flags, offset);
-	up(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return ret;
 }
 
diff -ur 2.4.0-test1-ac19/arch/s390/kernel/sys_s390.c test/arch/s390/kernel/sys_s390.c
--- 2.4.0-test1-ac19/arch/s390/kernel/sys_s390.c	Fri May 12 14:41:45 2000
+++ test/arch/s390/kernel/sys_s390.c	Sat Jun 17 21:24:16 2000
@@ -63,13 +63,7 @@
 			goto out;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
diff -ur 2.4.0-test1-ac19/arch/sh/kernel/sys_sh.c test/arch/sh/kernel/sys_sh.c
--- 2.4.0-test1-ac19/arch/sh/kernel/sys_sh.c	Sun Mar  5 12:33:55 2000
+++ test/arch/sh/kernel/sys_sh.c	Sat Jun 17 21:14:42 2000
@@ -59,12 +59,7 @@
 			goto out;
 	}
 
-	down(&current->mm->mmap_sem);
-	lock_kernel();
-
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	unlock_kernel();
-	up(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
diff -ur 2.4.0-test1-ac19/arch/sparc/kernel/sys_sparc.c test/arch/sparc/kernel/sys_sparc.c
--- 2.4.0-test1-ac19/arch/sparc/kernel/sys_sparc.c	Sat Jun 17 19:05:39 2000
+++ test/arch/sparc/kernel/sys_sparc.c	Sat Jun 17 20:50:56 2000
@@ -215,7 +215,6 @@
 			goto out;
 	}
 
-	lock_kernel();
 	retval = -EINVAL;
 	len = PAGE_ALIGN(len);
 	if (ARCH_SUN4C_SUN4 &&
@@ -229,12 +228,9 @@
 		goto out_putf;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down(&current->mm->mmap_sem);
 	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up(&current->mm->mmap_sem);
 
 out_putf:
-	unlock_kernel();
 	if (file)
 		fput(file);
 out:
@@ -254,7 +250,10 @@
 	unsigned long prot, unsigned long flags, unsigned long fd,
 	unsigned long off)
 {
-	return do_mmap2(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	unsigned long ret = -EINVAL;
+	if (!(off & PAGE_MASK))
+		ret = do_mmap2(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	return ret;
 }
 
 extern unsigned long do_mremap(unsigned long addr,
diff -ur 2.4.0-test1-ac19/arch/sparc/kernel/sys_sunos.c test/arch/sparc/kernel/sys_sunos.c
--- 2.4.0-test1-ac19/arch/sparc/kernel/sys_sunos.c	Sat Jun 17 19:05:39 2000
+++ test/arch/sparc/kernel/sys_sunos.c	Sat Jun 17 20:52:51 2000
@@ -68,7 +68,6 @@
 	struct file * file = NULL;
 	unsigned long retval, ret_type;
 
-	lock_kernel();
 	if(flags & MAP_NORESERVE) {
 		static int cnt;
 		if (cnt++ < 10)
@@ -117,9 +116,7 @@
 	}
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up(&current->mm->mmap_sem);
 	if(!ret_type)
 		retval = ((retval < PAGE_OFFSET) ? 0 : retval);
 
@@ -127,7 +124,6 @@
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return retval;
 }
 
diff -ur 2.4.0-test1-ac19/arch/sparc64/kernel/binfmt_aout32.c test/arch/sparc64/kernel/binfmt_aout32.c
--- 2.4.0-test1-ac19/arch/sparc64/kernel/binfmt_aout32.c	Sat Jun 17 19:05:39 2000
+++ test/arch/sparc64/kernel/binfmt_aout32.c	Sat Jun 17 21:08:56 2000
@@ -277,24 +277,20 @@
 			goto beyond_if;
 		}
 
-	        down(&current->mm->mmap_sem);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-	        up(&current->mm->mmap_sem);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-	        down(&current->mm->mmap_sem);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-	        up(&current->mm->mmap_sem);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -368,12 +364,10 @@
 	start_addr =  ex.a_entry & 0xfffff000;
 
 	/* Now use mmap to map the library into memory. */
-	down(&current->mm->mmap_sem);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up(&current->mm->mmap_sem);
 	retval = error;
 	if (error != start_addr)
 		goto out;
diff -ur 2.4.0-test1-ac19/arch/sparc64/kernel/sys_sparc.c test/arch/sparc64/kernel/sys_sparc.c
--- 2.4.0-test1-ac19/arch/sparc64/kernel/sys_sparc.c	Sat Jun 17 19:05:39 2000
+++ test/arch/sparc64/kernel/sys_sparc.c	Sat Jun 17 21:08:15 2000
@@ -227,8 +227,6 @@
 	len = PAGE_ALIGN(len);
 	retval = -EINVAL;
 
-	lock_kernel();
-
 	if (current->thread.flags & SPARC_FLAG_32BIT) {
 		if (len > 0xf0000000UL ||
 		    ((flags & MAP_FIXED) && addr > 0xf0000000UL - len))
@@ -240,12 +238,9 @@
 			goto out_putf;
 	}
 
-	down(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up(&current->mm->mmap_sem);
 
 out_putf:
-	unlock_kernel();
 	if (file)
 		fput(file);
 out:
diff -ur 2.4.0-test1-ac19/arch/sparc64/kernel/sys_sunos32.c test/arch/sparc64/kernel/sys_sunos32.c
--- 2.4.0-test1-ac19/arch/sparc64/kernel/sys_sunos32.c	Sat Jun 17 19:05:39 2000
+++ test/arch/sparc64/kernel/sys_sunos32.c	Sat Jun 17 21:09:54 2000
@@ -68,7 +68,6 @@
 	struct file *file = NULL;
 	unsigned long retval, ret_type;
 
-	lock_kernel();
 	if(flags & MAP_NORESERVE) {
 		static int cnt;
 		if (cnt++ < 10)
@@ -101,19 +100,16 @@
 	flags &= ~_MAP_NEW;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down(&current->mm->mmap_sem);
 	retval = do_mmap(file,
 			 (unsigned long) addr, (unsigned long) len,
 			 (unsigned long) prot, (unsigned long) flags,
 			 (unsigned long) off);
-	up(&current->mm->mmap_sem);
 	if(!ret_type)
 		retval = ((retval < 0xf0000000) ? 0 : retval);
 out_putf:
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return (u32) retval;
 }
 
diff -ur 2.4.0-test1-ac19/arch/sparc64/solaris/misc.c test/arch/sparc64/solaris/misc.c
--- 2.4.0-test1-ac19/arch/sparc64/solaris/misc.c	Mon May 22 12:50:54 2000
+++ test/arch/sparc64/solaris/misc.c	Sat Jun 17 21:12:28 2000
@@ -54,9 +54,10 @@
 	struct file *file = NULL;
 	unsigned long retval, ret_type;
 
-	lock_kernel();
 	/* Do we need it here? */
+	lock_kernel();	/* Is this needed? */
 	set_personality(PER_SVR4);
+	unlock_kernel();
 	if (flags & MAP_NORESERVE) {
 		static int cnt = 0;
 		
@@ -94,12 +95,10 @@
 	ret_type = flags & _MAP_NEW;
 	flags &= ~_MAP_NEW;
 
-	down(&current->mm->mmap_sem);
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	retval = do_mmap(file,
 			 (unsigned long) addr, (unsigned long) len,
 			 (unsigned long) prot, (unsigned long) flags, off);
-	up(&current->mm->mmap_sem);
 	if(!ret_type)
 		retval = ((retval < 0xf0000000) ? 0 : retval);
 	                        
@@ -107,7 +106,6 @@
 	if (file)
 		fput(file);
 out:
-	unlock_kernel();
 	return (u32) retval;
 }
 
diff -ur 2.4.0-test1-ac19/drivers/char/drm/bufs.c test/drivers/char/drm/bufs.c
--- 2.4.0-test1-ac19/drivers/char/drm/bufs.c	Sat Jun 17 20:29:11 2000
+++ test/drivers/char/drm/bufs.c	Sat Jun 17 20:29:30 2000
@@ -480,10 +480,8 @@
 			   -EFAULT);
 
 	if (request.count >= dma->buf_count) {
-		down(&current->mm->mmap_sem);
 		virtual = do_mmap(filp, 0, dma->byte_count,
 				  PROT_READ|PROT_WRITE, MAP_SHARED, 0);
-		up(&current->mm->mmap_sem);
 		if (virtual > -1024UL) {
 				/* Real error */
 			retcode = (signed long)virtual;
diff -ur 2.4.0-test1-ac19/drivers/sgi/char/graphics.c test/drivers/sgi/char/graphics.c
--- 2.4.0-test1-ac19/drivers/sgi/char/graphics.c	Sat Jun 17 19:06:00 2000
+++ test/drivers/sgi/char/graphics.c	Sat Jun 17 20:35:28 2000
@@ -150,11 +150,9 @@
 		 * sgi_graphics_mmap
 		 */
 		disable_gconsole ();
-		down(&current->mm->mmap_sem);
 		r = do_mmap (file, (unsigned long)vaddr,
 			     cards[board].g_regs_size, PROT_READ|PROT_WRITE,
 			     MAP_FIXED|MAP_PRIVATE, 0);
-		up(&current->mm->mmap_sem);
 		if (r)
 			return r;
 	}
diff -ur 2.4.0-test1-ac19/drivers/sgi/char/shmiq.c test/drivers/sgi/char/shmiq.c
--- 2.4.0-test1-ac19/drivers/sgi/char/shmiq.c	Sat Jun 17 19:06:00 2000
+++ test/drivers/sgi/char/shmiq.c	Sat Jun 17 20:37:33 2000
@@ -278,10 +278,7 @@
 			return -EINVAL;
 		}
 		s = req.arg * sizeof (struct shmqevent) + sizeof (struct sharedMemoryInputQueue);
-		down(&current->mm->mmap_sem);
-		do_munmap (current->mm, vaddr, s);
 		do_mmap (filp, vaddr, s, PROT_READ | PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 0);
-		up(&current->mm->mmap_sem);
 		shmiqs [minor].events = req.arg;
 		shmiqs [minor].mapped = 1;
 		return 0;
diff -ur 2.4.0-test1-ac19/fs/binfmt_aout.c test/fs/binfmt_aout.c
--- 2.4.0-test1-ac19/fs/binfmt_aout.c	Sat Jun 17 19:06:04 2000
+++ test/fs/binfmt_aout.c	Sat Jun 17 20:22:49 2000
@@ -365,24 +365,20 @@
 			goto beyond_if;
 		}
 
-		down(&current->mm->mmap_sem);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-		up(&current->mm->mmap_sem);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-		down(&current->mm->mmap_sem);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-		up(&current->mm->mmap_sem);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -464,12 +460,10 @@
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down(&current->mm->mmap_sem);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up(&current->mm->mmap_sem);
 	retval = error;
 	if (error != start_addr)
 		goto out;
diff -ur 2.4.0-test1-ac19/fs/binfmt_elf.c test/fs/binfmt_elf.c
--- 2.4.0-test1-ac19/fs/binfmt_elf.c	Sat Jun 17 19:06:04 2000
+++ test/fs/binfmt_elf.c	Sat Jun 17 20:22:11 2000
@@ -261,14 +261,12 @@
 	    if (interp_elf_ex->e_type == ET_EXEC || load_addr_set)
 	    	elf_type |= MAP_FIXED;
 
-	    down(&current->mm->mmap_sem);
 	    map_addr = do_mmap(interpreter,
 			    load_addr + ELF_PAGESTART(vaddr),
 			    eppnt->p_filesz + ELF_PAGEOFFSET(eppnt->p_vaddr),
 			    elf_prot,
 			    elf_type,
 			    eppnt->p_offset - ELF_PAGEOFFSET(eppnt->p_vaddr));
-	    up(&current->mm->mmap_sem);
 	    if (map_addr > -1024UL) /* Real error */
 		goto out_close;
 
@@ -614,13 +612,11 @@
 			elf_flags |= MAP_FIXED;
 		}
 
-		down(&current->mm->mmap_sem);
 		error = do_mmap(bprm->file, ELF_PAGESTART(load_bias + vaddr),
 		                (elf_ppnt->p_filesz +
 		                ELF_PAGEOFFSET(elf_ppnt->p_vaddr)),
 		                elf_prot, elf_flags, (elf_ppnt->p_offset -
 		                ELF_PAGEOFFSET(elf_ppnt->p_vaddr)));
-		up(&current->mm->mmap_sem);
 
 		if (!load_addr_set) {
 			load_addr_set = 1;
@@ -729,10 +725,8 @@
 		   Since we do not have the power to recompile these, we
 		   emulate the SVr4 behavior.  Sigh.  */
 		/* N.B. Shouldn't the size here be PAGE_SIZE?? */
-		down(&current->mm->mmap_sem);
 		error = do_mmap(NULL, 0, 4096, PROT_READ | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE, 0);
-		up(&current->mm->mmap_sem);
 	}
 
 #ifdef ELF_PLAT_INIT
@@ -813,7 +807,6 @@
 	while (elf_phdata->p_type != PT_LOAD) elf_phdata++;
 
 	/* Now use mmap to map the library into memory. */
-	down(&current->mm->mmap_sem);
 	error = do_mmap(file,
 			ELF_PAGESTART(elf_phdata->p_vaddr),
 			(elf_phdata->p_filesz +
@@ -822,7 +815,6 @@
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			(elf_phdata->p_offset -
 			 ELF_PAGEOFFSET(elf_phdata->p_vaddr)));
-	up(&current->mm->mmap_sem);
 	if (error != ELF_PAGESTART(elf_phdata->p_vaddr))
 		goto out_free_ph;
 
diff -ur 2.4.0-test1-ac19/ipc/shm.c test/ipc/shm.c
--- 2.4.0-test1-ac19/ipc/shm.c	Sat Jun 17 19:06:11 2000
+++ test/ipc/shm.c	Sat Jun 17 22:16:46 2000
@@ -1196,7 +1196,7 @@
 /*
  * Fix shmaddr, allocate descriptor, map shm, add attach descriptor to lists.
  */
-asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr)
+asmlinkage long sys_shmat (int shmid, char *shmaddr, int shmflg, ulong *raddr_p)
 {
 	struct shmid_kernel *shp;
 	unsigned long addr;
@@ -1208,6 +1208,7 @@
 	int acc_mode;
 	struct dentry *dentry;
 	char   name[SHM_FMT_LEN+1];
+	ulong raddr;
 
 	if (!shm_sb || (shmid % SEQ_MULTIPLIER) == zero_id)
 		return -EINVAL;
@@ -1261,15 +1262,13 @@
 	err = PTR_ERR(file);
 	if (IS_ERR (file))
 		goto bad_file1;
-	down(&current->mm->mmap_sem);
-	*raddr = do_mmap (file, addr, file->f_dentry->d_inode->i_size,
+	raddr = do_mmap (file, addr, file->f_dentry->d_inode->i_size,
 			  prot, flags, 0);
-	up(&current->mm->mmap_sem);
 	unlock_kernel();
-	if (IS_ERR(*raddr))
-		err = PTR_ERR(*raddr);
+	if (IS_ERR(raddr))
+		err = PTR_ERR(raddr);
 	else
-		err = 0;
+		err = put_user(raddr, raddr_p);
 	fput (file);
 	return err;
 
diff -ur 2.4.0-test1-ac19/mm/mmap.c test/mm/mmap.c
--- 2.4.0-test1-ac19/mm/mmap.c	Sat Jun 17 19:06:12 2000
+++ test/mm/mmap.c	Sat Jun 17 22:15:06 2000
@@ -164,7 +164,7 @@
 unsigned long do_mmap_pgoff(struct file * file, unsigned long addr, unsigned long len,
 	unsigned long prot, unsigned long flags, unsigned long pgoff)
 {
-	struct mm_struct * mm = current->mm;
+	struct mm_struct *mm = current->mm;
 	struct vm_area_struct * vma;
 	int correct_wcount = 0;
 	int error;
@@ -182,16 +182,25 @@
 	if ((pgoff + (len >> PAGE_SHIFT)) < pgoff)
 		return -EINVAL;
 
+	/* From here on in, wear protection. */
+	down(&mm->mmap_sem);
+	lock_kernel();
+
 	/* Too many mappings? */
+	error = -ENOMEM;
 	if (mm->map_count > MAX_MAP_COUNT)
-		return -ENOMEM;
+		goto out_up;
 
 	/* mlock MCL_FUTURE? */
 	if (mm->def_flags & VM_LOCKED) {
 		unsigned long locked = mm->locked_vm << PAGE_SHIFT;
 		locked += len;
+		/* FIXME: should RLIMIT_MEMLOCK should be per-mm?  And
+		 * is -EAGAIN the best error?
+		 */
+		error = -EAGAIN;
 		if (locked > current->rlim[RLIMIT_MEMLOCK].rlim_cur)
-			return -EAGAIN;
+			goto out_up;
 	}
 
 	/* Do simple checking here so the lower-level routines won't have
@@ -199,27 +208,31 @@
 	 * of the memory object, so we don't do any here.
 	 */
 	if (file != NULL) {
+		error = -EACCES;
 		switch (flags & MAP_TYPE) {
 		case MAP_SHARED:
 			if ((prot & PROT_WRITE) && !(file->f_mode & FMODE_WRITE))
-				return -EACCES;
+				goto out_up;
 
 			/* Make sure we don't allow writing to an append-only file.. */
 			if (IS_APPEND(file->f_dentry->d_inode) && (file->f_mode & FMODE_WRITE))
-				return -EACCES;
+				goto out_up;
 
 			/* make sure there are no mandatory locks on the file. */
-			if (locks_verify_locked(file->f_dentry->d_inode))
-				return -EAGAIN;
+			if (locks_verify_locked(file->f_dentry->d_inode)) {
+				error = -EAGAIN;
+				goto out_up;
+			}
 
 			/* fall through */
 		case MAP_PRIVATE:
 			if (!(file->f_mode & FMODE_READ))
-				return -EACCES;
+				goto out_up;
 			break;
 
 		default:
-			return -EINVAL;
+			error = -EINVAL;
+			goto out_up;
 		}
 	}
 
@@ -227,12 +240,14 @@
 	 * that it represents a valid section of the address space.
 	 */
 	if (flags & MAP_FIXED) {
+		error = -EINVAL;
 		if (addr & ~PAGE_MASK)
-			return -EINVAL;
+			goto out_up;
 	} else {
 		addr = get_unmapped_area(addr, len);
+		error = -ENOMEM;
 		if (!addr)
-			return -ENOMEM;
+			goto out_up;
 	}
 
 	/* Determine the object being mapped and call the appropriate
@@ -240,8 +255,9 @@
 	 * not unmapped, but the maps are removed from the list.
 	 */
 	vma = kmem_cache_alloc(vm_area_cachep, SLAB_KERNEL);
+	error = -ENOMEM;
 	if (!vma)
-		return -ENOMEM;
+		goto out_up;
 
 	vma->vm_mm = mm;
 	vma->vm_start = addr;
@@ -330,6 +346,8 @@
 		mm->locked_vm += len >> PAGE_SHIFT;
 		make_pages_present(addr, addr + len);
 	}
+	unlock_kernel();
+	up(&mm->mmap_sem);
 	return addr;
 
 unmap_and_free_vma:
@@ -343,6 +361,9 @@
 	flush_tlb_range(mm, vma->vm_start, vma->vm_end);
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
+out_up:
+	unlock_kernel();
+	up(&mm->mmap_sem);
 	return error;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
