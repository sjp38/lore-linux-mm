Message-Id: <20071114201528.010028000@chello.nl>
References: <20071114200136.009242000@chello.nl>
Date: Wed, 14 Nov 2007 21:01:37 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 1/3] mm: pull mmap_sem into do_mmap{,_pgoff}
Content-Disposition: inline; filename=mmap_locking.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Trond Myklebust <trond.myklebust@fys.uio.no>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh@veritas.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

It appears that some filesystems (NFS) require i_mutex in ->mmap(). This
violates the normal locking order of:

  i_mutex
    mmap_sem

In order to provide a mmap hook that is outside of mmap_sem, pull this lock
into do_mmap{,_pgoff}.

___do_mmap_pgoff() - base function, requires mmap_sem
__do_mmap_anon()   - full do_mmap() for anonymous, requires mmap_sem
do_mmap_pgoff()    - full do_mmap_pgoff()
do_mmap()          - full do_mmap()

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/kernel/osf_sys.c         |    2 -
 arch/arm/kernel/sys_arm.c           |    2 -
 arch/avr32/kernel/sys_avr32.c       |    2 -
 arch/blackfin/kernel/sys_bfin.c     |    2 -
 arch/cris/kernel/sys_cris.c         |    2 -
 arch/frv/kernel/sys_frv.c           |    4 ---
 arch/h8300/kernel/sys_h8300.c       |    4 ---
 arch/ia64/ia32/sys_ia32.c           |   30 ++++++++-----------------
 arch/ia64/kernel/sys_ia64.c         |    2 -
 arch/m32r/kernel/sys_m32r.c         |    2 -
 arch/m68k/kernel/sys_m68k.c         |    4 ---
 arch/m68knommu/kernel/sys_m68k.c    |    2 -
 arch/mips/kernel/irixelf.c          |   12 ----------
 arch/mips/kernel/linux32.c          |    2 -
 arch/mips/kernel/syscall.c          |    2 -
 arch/mips/kernel/sysirix.c          |    5 ----
 arch/parisc/kernel/sys_parisc.c     |    2 -
 arch/powerpc/kernel/syscalls.c      |    2 -
 arch/s390/kernel/compat_linux.c     |    7 ------
 arch/s390/kernel/sys_s390.c         |    2 -
 arch/sh/kernel/sys_sh.c             |    2 -
 arch/sh64/kernel/sys_sh64.c         |    2 -
 arch/sparc/kernel/sys_sparc.c       |    2 -
 arch/sparc/kernel/sys_sunos.c       |    2 -
 arch/sparc64/kernel/binfmt_aout32.c |    6 -----
 arch/sparc64/kernel/sys_sparc.c     |    2 -
 arch/sparc64/kernel/sys_sunos32.c   |    2 -
 arch/sparc64/solaris/misc.c         |    2 -
 arch/um/kernel/syscall.c            |    2 -
 arch/v850/kernel/syscalls.c         |    2 -
 arch/x86/ia32/ia32_aout.c           |    6 -----
 arch/x86/ia32/sys_ia32.c            |   10 --------
 arch/x86/kernel/sys_i386_32.c       |    4 ---
 arch/x86/kernel/sys_x86_64.c        |    2 -
 arch/xtensa/kernel/syscall.c        |    2 -
 drivers/char/drm/drm_bufs.c         |    4 ---
 drivers/char/drm/i810_dma.c         |    2 -
 fs/aio.c                            |    6 ++---
 fs/binfmt_aout.c                    |    6 -----
 fs/binfmt_elf.c                     |    6 -----
 fs/binfmt_elf_fdpic.c               |   11 +--------
 fs/binfmt_flat.c                    |    6 +----
 fs/binfmt_som.c                     |    6 -----
 include/linux/mm.h                  |   22 +++++++++++++-----
 ipc/shm.c                           |    2 -
 mm/mmap.c                           |   42 ++++++++++++++++++++++++++++++++----
 mm/nommu.c                          |   39 ++++++++++++++++++++++++++++++++-
 47 files changed, 112 insertions(+), 180 deletions(-)

Index: linux-2.6/arch/alpha/kernel/osf_sys.c
===================================================================
--- linux-2.6.orig/arch/alpha/kernel/osf_sys.c
+++ linux-2.6/arch/alpha/kernel/osf_sys.c
@@ -193,9 +193,7 @@ osf_mmap(unsigned long addr, unsigned lo
 			goto out;
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
 	ret = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
  out:
Index: linux-2.6/arch/arm/kernel/sys_arm.c
===================================================================
--- linux-2.6.orig/arch/arm/kernel/sys_arm.c
+++ linux-2.6/arch/arm/kernel/sys_arm.c
@@ -72,9 +72,7 @@ inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/avr32/kernel/sys_avr32.c
===================================================================
--- linux-2.6.orig/arch/avr32/kernel/sys_avr32.c
+++ linux-2.6/arch/avr32/kernel/sys_avr32.c
@@ -41,9 +41,7 @@ asmlinkage long sys_mmap2(unsigned long 
 			return error;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, offset);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/blackfin/kernel/sys_bfin.c
===================================================================
--- linux-2.6.orig/arch/blackfin/kernel/sys_bfin.c
+++ linux-2.6/arch/blackfin/kernel/sys_bfin.c
@@ -78,9 +78,7 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/cris/kernel/sys_cris.c
===================================================================
--- linux-2.6.orig/arch/cris/kernel/sys_cris.c
+++ linux-2.6/arch/cris/kernel/sys_cris.c
@@ -60,9 +60,7 @@ do_mmap2(unsigned long addr, unsigned lo
                         goto out;
         }
 
-        down_write(&current->mm->mmap_sem);
         error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-        up_write(&current->mm->mmap_sem);
 
         if (file)
                 fput(file);
Index: linux-2.6/arch/frv/kernel/sys_frv.c
===================================================================
--- linux-2.6.orig/arch/frv/kernel/sys_frv.c
+++ linux-2.6/arch/frv/kernel/sys_frv.c
@@ -69,9 +69,7 @@ asmlinkage long sys_mmap2(unsigned long 
 
 	pgoff >>= (PAGE_SHIFT - 12);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
@@ -114,9 +112,7 @@ asmlinkage long sys_mmap64(struct mmap_a
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/h8300/kernel/sys_h8300.c
===================================================================
--- linux-2.6.orig/arch/h8300/kernel/sys_h8300.c
+++ linux-2.6/arch/h8300/kernel/sys_h8300.c
@@ -60,9 +60,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
@@ -147,9 +145,7 @@ asmlinkage long sys_mmap64(struct mmap_a
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/ia64/ia32/sys_ia32.c
===================================================================
--- linux-2.6.orig/arch/ia64/ia32/sys_ia32.c
+++ linux-2.6/arch/ia64/ia32/sys_ia32.c
@@ -212,12 +212,8 @@ mmap_subpage (struct file *file, unsigne
 	if (old_prot)
 		copy_from_user(page, (void __user *) PAGE_START(start), PAGE_SIZE);
 
-	down_write(&current->mm->mmap_sem);
-	{
-		ret = do_mmap(NULL, PAGE_START(start), PAGE_SIZE, prot | PROT_WRITE,
-			      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
-	}
-	up_write(&current->mm->mmap_sem);
+	ret = do_mmap(NULL, PAGE_START(start), PAGE_SIZE, prot | PROT_WRITE,
+			flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 
 	if (IS_ERR((void *) ret))
 		goto out;
@@ -821,16 +817,14 @@ emulate_mmap (struct file *file, unsigne
 	DBG("mmap_body: mapping [0x%lx-0x%lx) %s with poff 0x%llx\n", pstart, pend,
 	    is_congruent ? "congruent" : "not congruent", poff);
 
-	down_write(&current->mm->mmap_sem);
-	{
-		if (!(flags & MAP_ANONYMOUS) && is_congruent)
-			ret = do_mmap(file, pstart, pend - pstart, prot, flags | MAP_FIXED, poff);
-		else
-			ret = do_mmap(NULL, pstart, pend - pstart,
-				      prot | ((flags & MAP_ANONYMOUS) ? 0 : PROT_WRITE),
-				      flags | MAP_FIXED | MAP_ANONYMOUS, 0);
+	if (!(flags & MAP_ANONYMOUS) && is_congruent) {
+		ret = do_mmap(file, pstart, pend - pstart, prot,
+			       	flags | MAP_FIXED, poff);
+	} else {
+		ret = do_mmap(NULL, pstart, pend - pstart,
+			prot | ((flags & MAP_ANONYMOUS) ? 0 : PROT_WRITE),
+			flags | MAP_FIXED | MAP_ANONYMOUS, 0);
 	}
-	up_write(&current->mm->mmap_sem);
 
 	if (IS_ERR((void *) ret))
 		return ret;
@@ -904,11 +898,7 @@ ia32_do_mmap (struct file *file, unsigne
 	}
 	mutex_unlock(&ia32_mmap_mutex);
 #else
-	down_write(&current->mm->mmap_sem);
-	{
-		addr = do_mmap(file, addr, len, prot, flags, offset);
-	}
-	up_write(&current->mm->mmap_sem);
+	addr = do_mmap(file, addr, len, prot, flags, offset);
 #endif
 	DBG("ia32_do_mmap: returning 0x%lx\n", addr);
 	return addr;
Index: linux-2.6/arch/ia64/kernel/sys_ia64.c
===================================================================
--- linux-2.6.orig/arch/ia64/kernel/sys_ia64.c
+++ linux-2.6/arch/ia64/kernel/sys_ia64.c
@@ -209,9 +209,7 @@ do_mmap2 (unsigned long addr, unsigned l
 		goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 out:	if (file)
 		fput(file);
Index: linux-2.6/arch/m32r/kernel/sys_m32r.c
===================================================================
--- linux-2.6.orig/arch/m32r/kernel/sys_m32r.c
+++ linux-2.6/arch/m32r/kernel/sys_m32r.c
@@ -110,9 +110,7 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/m68k/kernel/sys_m68k.c
===================================================================
--- linux-2.6.orig/arch/m68k/kernel/sys_m68k.c
+++ linux-2.6/arch/m68k/kernel/sys_m68k.c
@@ -63,9 +63,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
@@ -150,9 +148,7 @@ asmlinkage long sys_mmap64(struct mmap_a
 	}
 	a.flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/m68knommu/kernel/sys_m68k.c
===================================================================
--- linux-2.6.orig/arch/m68knommu/kernel/sys_m68k.c
+++ linux-2.6/arch/m68knommu/kernel/sys_m68k.c
@@ -61,9 +61,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/mips/kernel/irixelf.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/irixelf.c
+++ linux-2.6/arch/mips/kernel/irixelf.c
@@ -342,12 +342,10 @@ static unsigned int load_irix_interp(str
 			         (unsigned long)
 			         (eppnt->p_offset & 0xfffff000));
 
-			down_write(&current->mm->mmap_sem);
 			error = do_mmap(interpreter, vaddr,
 			eppnt->p_filesz + (eppnt->p_vaddr & 0xfff),
 			elf_prot, elf_type,
 			eppnt->p_offset & 0xfffff000);
-			up_write(&current->mm->mmap_sem);
 
 			if (error < 0 && error > -1024) {
 				printk("Aieee IRIX interp mmap error=%d\n",
@@ -514,12 +512,10 @@ static inline void map_executable(struct
 		prot  = (epp->p_flags & PF_R) ? PROT_READ : 0;
 		prot |= (epp->p_flags & PF_W) ? PROT_WRITE : 0;
 		prot |= (epp->p_flags & PF_X) ? PROT_EXEC : 0;
-	        down_write(&current->mm->mmap_sem);
 		(void) do_mmap(fp, (epp->p_vaddr & 0xfffff000),
 			       (epp->p_filesz + (epp->p_vaddr & 0xfff)),
 			       prot, EXEC_MAP_FLAGS,
 			       (epp->p_offset & 0xfffff000));
-	        up_write(&current->mm->mmap_sem);
 
 		/* Fixup location tracking vars. */
 		if ((epp->p_vaddr & 0xfffff000) < *estack)
@@ -798,10 +794,8 @@ static int load_irix_binary(struct linux
 	 * Since we do not have the power to recompile these, we
 	 * emulate the SVr4 behavior.  Sigh.
 	 */
-	down_write(&current->mm->mmap_sem);
-	(void) do_mmap(NULL, 0, 4096, PROT_READ | PROT_EXEC,
+ 	(void) do_mmap(NULL, 0, 4096, PROT_READ | PROT_EXEC,
 		       MAP_FIXED | MAP_PRIVATE, 0);
-	up_write(&current->mm->mmap_sem);
 #endif
 
 	start_thread(regs, elf_entry, bprm->p);
@@ -871,14 +865,12 @@ static int load_irix_library(struct file
 	while (elf_phdata->p_type != PT_LOAD) elf_phdata++;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap(file,
 			elf_phdata->p_vaddr & 0xfffff000,
 			elf_phdata->p_filesz + (elf_phdata->p_vaddr & 0xfff),
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			elf_phdata->p_offset & 0xfffff000);
-	up_write(&current->mm->mmap_sem);
 
 	k = elf_phdata->p_vaddr + elf_phdata->p_filesz;
 	if (k > elf_bss) elf_bss = k;
@@ -959,12 +951,10 @@ unsigned long irix_mapelf(int fd, struct
 		prot |= (flags & PF_W) ? PROT_WRITE : 0;
 		prot |= (flags & PF_X) ? PROT_EXEC : 0;
 
-		down_write(&current->mm->mmap_sem);
 		retval = do_mmap(filp, (vaddr & 0xfffff000),
 				 (filesz + (vaddr & 0xfff)),
 				 prot, (MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE),
 				 (offset & 0xfffff000));
-		up_write(&current->mm->mmap_sem);
 
 		if (retval != (vaddr & 0xfffff000)) {
 			printk("irix_mapelf: do_mmap fails with %d!\n", retval);
Index: linux-2.6/arch/mips/kernel/linux32.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/linux32.c
+++ linux-2.6/arch/mips/kernel/linux32.c
@@ -119,9 +119,7 @@ sys32_mmap2(unsigned long addr, unsigned
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 
Index: linux-2.6/arch/mips/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/syscall.c
+++ linux-2.6/arch/mips/kernel/syscall.c
@@ -136,9 +136,7 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/mips/kernel/sysirix.c
===================================================================
--- linux-2.6.orig/arch/mips/kernel/sysirix.c
+++ linux-2.6/arch/mips/kernel/sysirix.c
@@ -1051,9 +1051,7 @@ asmlinkage unsigned long irix_mmap32(uns
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, offset);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 
@@ -1536,10 +1534,7 @@ asmlinkage int irix_mmap64(struct pt_reg
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
-
 	if (file)
 		fput(file);
 
Index: linux-2.6/arch/parisc/kernel/sys_parisc.c
===================================================================
--- linux-2.6.orig/arch/parisc/kernel/sys_parisc.c
+++ linux-2.6/arch/parisc/kernel/sys_parisc.c
@@ -137,9 +137,7 @@ static unsigned long do_mmap2(unsigned l
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file != NULL)
 		fput(file);
Index: linux-2.6/arch/powerpc/kernel/syscalls.c
===================================================================
--- linux-2.6.orig/arch/powerpc/kernel/syscalls.c
+++ linux-2.6/arch/powerpc/kernel/syscalls.c
@@ -175,9 +175,7 @@ static inline unsigned long do_mmap2(uns
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	ret = do_mmap_pgoff(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/s390/kernel/compat_linux.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/compat_linux.c
+++ linux-2.6/arch/s390/kernel/compat_linux.c
@@ -860,14 +860,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	if (!IS_ERR((void *) error) && error + len >= 0x80000000ULL) {
-		/* Result is out of bounds.  */
-		do_munmap(current->mm, addr, len);
-		error = -ENOMEM;
-	}
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/s390/kernel/sys_s390.c
===================================================================
--- linux-2.6.orig/arch/s390/kernel/sys_s390.c
+++ linux-2.6/arch/s390/kernel/sys_s390.c
@@ -65,9 +65,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sh/kernel/sys_sh.c
===================================================================
--- linux-2.6.orig/arch/sh/kernel/sys_sh.c
+++ linux-2.6/arch/sh/kernel/sys_sh.c
@@ -153,9 +153,7 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sh64/kernel/sys_sh64.c
===================================================================
--- linux-2.6.orig/arch/sh64/kernel/sys_sh64.c
+++ linux-2.6/arch/sh64/kernel/sys_sh64.c
@@ -148,9 +148,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sparc/kernel/sys_sparc.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/sys_sparc.c
+++ linux-2.6/arch/sparc/kernel/sys_sparc.c
@@ -252,9 +252,7 @@ static unsigned long do_mmap2(unsigned l
 	len = PAGE_ALIGN(len);
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sparc/kernel/sys_sunos.c
===================================================================
--- linux-2.6.orig/arch/sparc/kernel/sys_sunos.c
+++ linux-2.6/arch/sparc/kernel/sys_sunos.c
@@ -120,9 +120,7 @@ asmlinkage unsigned long sunos_mmap(unsi
 	}
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 	if (!ret_type)
 		retval = ((retval < PAGE_OFFSET) ? 0 : retval);
 
Index: linux-2.6/arch/sparc64/kernel/binfmt_aout32.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/binfmt_aout32.c
+++ linux-2.6/arch/sparc64/kernel/binfmt_aout32.c
@@ -290,24 +290,20 @@ static int load_aout32_binary(struct lin
 			goto beyond_if;
 		}
 
-	        down_write(&current->mm->mmap_sem);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-	        up_write(&current->mm->mmap_sem);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-	        down_write(&current->mm->mmap_sem);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-	        up_write(&current->mm->mmap_sem);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -379,12 +375,10 @@ static int load_aout32_library(struct fi
 	start_addr =  ex.a_entry & 0xfffff000;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
 	retval = error;
 	if (error != start_addr)
 		goto out;
Index: linux-2.6/arch/sparc64/kernel/sys_sparc.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/sys_sparc.c
+++ linux-2.6/arch/sparc64/kernel/sys_sparc.c
@@ -576,9 +576,7 @@ asmlinkage unsigned long sys_mmap(unsign
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	len = PAGE_ALIGN(len);
 
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/sparc64/kernel/sys_sunos32.c
===================================================================
--- linux-2.6.orig/arch/sparc64/kernel/sys_sunos32.c
+++ linux-2.6/arch/sparc64/kernel/sys_sunos32.c
@@ -99,12 +99,10 @@ asmlinkage u32 sunos_mmap(u32 addr, u32 
 	flags &= ~_MAP_NEW;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file,
 			 (unsigned long) addr, (unsigned long) len,
 			 (unsigned long) prot, (unsigned long) flags,
 			 (unsigned long) off);
-	up_write(&current->mm->mmap_sem);
 	if (!ret_type)
 		retval = ((retval < 0xf0000000) ? 0 : retval);
 out_putf:
Index: linux-2.6/arch/sparc64/solaris/misc.c
===================================================================
--- linux-2.6.orig/arch/sparc64/solaris/misc.c
+++ linux-2.6/arch/sparc64/solaris/misc.c
@@ -95,12 +95,10 @@ static u32 do_solaris_mmap(u32 addr, u32
 	ret_type = flags & _MAP_NEW;
 	flags &= ~_MAP_NEW;
 
-	down_write(&current->mm->mmap_sem);
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	retval = do_mmap(file,
 			 (unsigned long) addr, (unsigned long) len,
 			 (unsigned long) prot, (unsigned long) flags, off);
-	up_write(&current->mm->mmap_sem);
 	if(!ret_type)
 		retval = ((retval < STACK_TOP32) ? 0 : retval);
 	                        
Index: linux-2.6/arch/um/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/um/kernel/syscall.c
+++ linux-2.6/arch/um/kernel/syscall.c
@@ -54,9 +54,7 @@ long sys_mmap2(unsigned long addr, unsig
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/v850/kernel/syscalls.c
===================================================================
--- linux-2.6.orig/arch/v850/kernel/syscalls.c
+++ linux-2.6/arch/v850/kernel/syscalls.c
@@ -164,9 +164,7 @@ do_mmap2 (unsigned long addr, size_t len
 			goto out;
 	}
 	
-	down_write (&current->mm->mmap_sem);
 	ret = do_mmap_pgoff (file, addr, len, prot, flags, pgoff);
-	up_write (&current->mm->mmap_sem);
 	if (file)
 		fput (file);
 out:
Index: linux-2.6/arch/x86/ia32/ia32_aout.c
===================================================================
--- linux-2.6.orig/arch/x86/ia32/ia32_aout.c
+++ linux-2.6/arch/x86/ia32/ia32_aout.c
@@ -374,24 +374,20 @@ static int load_aout_binary(struct linux
 			goto beyond_if;
 		}
 
-		down_write(&current->mm->mmap_sem);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE | MAP_32BIT,
 			fd_offset);
-		up_write(&current->mm->mmap_sem);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-		down_write(&current->mm->mmap_sem);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE | MAP_32BIT,
 				fd_offset + ex.a_text);
-		up_write(&current->mm->mmap_sem);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -488,12 +484,10 @@ static int load_aout_library(struct file
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_32BIT,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
 	retval = error;
 	if (error != start_addr)
 		goto out;
Index: linux-2.6/arch/x86/ia32/sys_ia32.c
===================================================================
--- linux-2.6.orig/arch/x86/ia32/sys_ia32.c
+++ linux-2.6/arch/x86/ia32/sys_ia32.c
@@ -227,7 +227,6 @@ sys32_mmap(struct mmap_arg_struct __user
 	struct mmap_arg_struct a;
 	struct file *file = NULL;
 	unsigned long retval;
-	struct mm_struct *mm ;
 
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
@@ -241,14 +240,10 @@ sys32_mmap(struct mmap_arg_struct __user
 			return -EBADF;
 	}
 	
-	mm = current->mm; 
-	down_write(&mm->mmap_sem); 
 	retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset>>PAGE_SHIFT);
 	if (file)
 		fput(file);
 
-	up_write(&mm->mmap_sem); 
-
 	return retval;
 }
 
@@ -697,7 +692,6 @@ asmlinkage long sys32_mmap2(unsigned lon
 	unsigned long prot, unsigned long flags,
 	unsigned long fd, unsigned long pgoff)
 {
-	struct mm_struct *mm = current->mm;
 	unsigned long error;
 	struct file * file = NULL;
 
@@ -708,12 +702,10 @@ asmlinkage long sys32_mmap2(unsigned lon
 			return -EBADF;
 	}
 
-	down_write(&mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
-
 	if (file)
 		fput(file);
+
 	return error;
 }
 
Index: linux-2.6/arch/x86/kernel/sys_i386_32.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/sys_i386_32.c
+++ linux-2.6/arch/x86/kernel/sys_i386_32.c
@@ -45,7 +45,6 @@ asmlinkage long sys_mmap2(unsigned long 
 {
 	int error = -EBADF;
 	struct file *file = NULL;
-	struct mm_struct *mm = current->mm;
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	if (!(flags & MAP_ANONYMOUS)) {
@@ -54,10 +53,7 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
-
 	if (file)
 		fput(file);
 out:
Index: linux-2.6/arch/x86/kernel/sys_x86_64.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/sys_x86_64.c
+++ linux-2.6/arch/x86/kernel/sys_x86_64.c
@@ -51,9 +51,7 @@ asmlinkage long sys_mmap(unsigned long a
 		if (!file)
 			goto out;
 	}
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, off >> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/arch/xtensa/kernel/syscall.c
===================================================================
--- linux-2.6.orig/arch/xtensa/kernel/syscall.c
+++ linux-2.6/arch/xtensa/kernel/syscall.c
@@ -72,9 +72,7 @@ asmlinkage long xtensa_mmap2(unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6/drivers/char/drm/drm_bufs.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/drm_bufs.c
+++ linux-2.6/drivers/char/drm/drm_bufs.c
@@ -1517,18 +1517,14 @@ int drm_mapbufs(struct drm_device *dev, 
 				retcode = -EINVAL;
 				goto done;
 			}
-			down_write(&current->mm->mmap_sem);
 			virtual = do_mmap(file_priv->filp, 0, map->size,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED,
 					  token);
-			up_write(&current->mm->mmap_sem);
 		} else {
-			down_write(&current->mm->mmap_sem);
 			virtual = do_mmap(file_priv->filp, 0, dma->byte_count,
 					  PROT_READ | PROT_WRITE,
 					  MAP_SHARED, 0);
-			up_write(&current->mm->mmap_sem);
 		}
 		if (virtual > -1024UL) {
 			/* Real error */
Index: linux-2.6/drivers/char/drm/i810_dma.c
===================================================================
--- linux-2.6.orig/drivers/char/drm/i810_dma.c
+++ linux-2.6/drivers/char/drm/i810_dma.c
@@ -131,7 +131,6 @@ static int i810_map_buffer(struct drm_bu
 	if (buf_priv->currently_mapped == I810_BUF_MAPPED)
 		return -EINVAL;
 
-	down_write(&current->mm->mmap_sem);
 	old_fops = file_priv->filp->f_op;
 	file_priv->filp->f_op = &i810_buffer_fops;
 	dev_priv->mmap_buffer = buf;
@@ -146,7 +145,6 @@ static int i810_map_buffer(struct drm_bu
 		retcode = PTR_ERR(buf_priv->virtual);
 		buf_priv->virtual = NULL;
 	}
-	up_write(&current->mm->mmap_sem);
 
 	return retcode;
 }
Index: linux-2.6/fs/aio.c
===================================================================
--- linux-2.6.orig/fs/aio.c
+++ linux-2.6/fs/aio.c
@@ -129,18 +129,18 @@ static int aio_setup_ring(struct kioctx 
 
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
-	down_write(&ctx->mm->mmap_sem);
-	info->mmap_base = do_mmap(NULL, 0, info->mmap_size, 
+	WARN_ON(ctx->mm != current->mm);
+	info->mmap_base = do_mmap(NULL, 0, info->mmap_size,
 				  PROT_READ|PROT_WRITE, MAP_ANONYMOUS|MAP_PRIVATE,
 				  0);
 	if (IS_ERR((void *)info->mmap_base)) {
-		up_write(&ctx->mm->mmap_sem);
 		info->mmap_size = 0;
 		aio_free_ring(ctx);
 		return -EAGAIN;
 	}
 
 	dprintk("mmap address: 0x%08lx\n", info->mmap_base);
+	down_write(&ctx->mm->mmap_sem);
 	info->nr_pages = get_user_pages(current, ctx->mm,
 					info->mmap_base, nr_pages, 
 					1, 0, info->ring_pages, NULL);
Index: linux-2.6/fs/binfmt_aout.c
===================================================================
--- linux-2.6.orig/fs/binfmt_aout.c
+++ linux-2.6/fs/binfmt_aout.c
@@ -403,24 +403,20 @@ static int load_aout_binary(struct linux
 			goto beyond_if;
 		}
 
-		down_write(&current->mm->mmap_sem);
 		error = do_mmap(bprm->file, N_TXTADDR(ex), ex.a_text,
 			PROT_READ | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 			fd_offset);
-		up_write(&current->mm->mmap_sem);
 
 		if (error != N_TXTADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
 		}
 
-		down_write(&current->mm->mmap_sem);
  		error = do_mmap(bprm->file, N_DATADDR(ex), ex.a_data,
 				PROT_READ | PROT_WRITE | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE | MAP_EXECUTABLE,
 				fd_offset + ex.a_text);
-		up_write(&current->mm->mmap_sem);
 		if (error != N_DATADDR(ex)) {
 			send_sig(SIGKILL, current, 0);
 			return error;
@@ -518,12 +514,10 @@ static int load_aout_library(struct file
 		goto out;
 	}
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap(file, start_addr, ex.a_text + ex.a_data,
 			PROT_READ | PROT_WRITE | PROT_EXEC,
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			N_TXTOFF(ex));
-	up_write(&current->mm->mmap_sem);
 	retval = error;
 	if (error != start_addr)
 		goto out;
Index: linux-2.6/fs/binfmt_elf.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf.c
+++ linux-2.6/fs/binfmt_elf.c
@@ -303,7 +303,6 @@ static unsigned long elf_map(struct file
 	unsigned long map_addr;
 	unsigned long pageoffset = ELF_PAGEOFFSET(eppnt->p_vaddr);
 
-	down_write(&current->mm->mmap_sem);
 	/* mmap() will return -EINVAL if given a zero size, but a
 	 * segment with zero filesize is perfectly valid */
 	if (eppnt->p_filesz + pageoffset)
@@ -312,7 +311,6 @@ static unsigned long elf_map(struct file
 				   eppnt->p_offset - pageoffset);
 	else
 		map_addr = ELF_PAGESTART(addr);
-	up_write(&current->mm->mmap_sem);
 	return(map_addr);
 }
 
@@ -1026,10 +1024,8 @@ static int load_elf_binary(struct linux_
 		   and some applications "depend" upon this behavior.
 		   Since we do not have the power to recompile these, we
 		   emulate the SVr4 behavior. Sigh. */
-		down_write(&current->mm->mmap_sem);
 		error = do_mmap(NULL, 0, PAGE_SIZE, PROT_READ | PROT_EXEC,
 				MAP_FIXED | MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
 	}
 
 #ifdef ELF_PLAT_INIT
@@ -1125,7 +1121,6 @@ static int load_elf_library(struct file 
 		eppnt++;
 
 	/* Now use mmap to map the library into memory. */
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap(file,
 			ELF_PAGESTART(eppnt->p_vaddr),
 			(eppnt->p_filesz +
@@ -1134,7 +1129,6 @@ static int load_elf_library(struct file 
 			MAP_FIXED | MAP_PRIVATE | MAP_DENYWRITE,
 			(eppnt->p_offset -
 			 ELF_PAGEOFFSET(eppnt->p_vaddr)));
-	up_write(&current->mm->mmap_sem);
 	if (error != ELF_PAGESTART(eppnt->p_vaddr))
 		goto out_free_ph;
 
Index: linux-2.6/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6.orig/fs/binfmt_elf_fdpic.c
+++ linux-2.6/fs/binfmt_elf_fdpic.c
@@ -370,14 +370,12 @@ static int load_elf_fdpic_binary(struct 
 	if (stack_size < PAGE_SIZE * 2)
 		stack_size = PAGE_SIZE * 2;
 
-	down_write(&current->mm->mmap_sem);
-	current->mm->start_brk = do_mmap(NULL, 0, stack_size,
+ 	current->mm->start_brk = do_mmap(NULL, 0, stack_size,
 					 PROT_READ | PROT_WRITE | PROT_EXEC,
 					 MAP_PRIVATE | MAP_ANONYMOUS | MAP_GROWSDOWN,
 					 0);
 
 	if (IS_ERR_VALUE(current->mm->start_brk)) {
-		up_write(&current->mm->mmap_sem);
 		retval = current->mm->start_brk;
 		current->mm->start_brk = 0;
 		goto error_kill;
@@ -385,6 +383,7 @@ static int load_elf_fdpic_binary(struct 
 
 	/* expand the stack mapping to use up the entire allocation granule */
 	fullsize = ksize((char *) current->mm->start_brk);
+	down_write(&current->mm->mmap_sem);
 	if (!IS_ERR_VALUE(do_mremap(current->mm->start_brk, stack_size,
 				    fullsize, 0, 0)))
 		stack_size = fullsize;
@@ -904,10 +903,8 @@ static int elf_fdpic_map_file_constdisp_
 	if (params->flags & ELF_FDPIC_FLAG_EXECUTABLE)
 		mflags |= MAP_EXECUTABLE;
 
-	down_write(&mm->mmap_sem);
 	maddr = do_mmap(NULL, load_addr, top - base,
 			PROT_READ | PROT_WRITE | PROT_EXEC, mflags, 0);
-	up_write(&mm->mmap_sem);
 	if (IS_ERR_VALUE(maddr))
 		return (int) maddr;
 
@@ -1050,10 +1047,8 @@ static int elf_fdpic_map_file_by_direct_
 
 		/* create the mapping */
 		disp = phdr->p_vaddr & ~PAGE_MASK;
-		down_write(&mm->mmap_sem);
 		maddr = do_mmap(file, maddr, phdr->p_memsz + disp, prot, flags,
 				phdr->p_offset - disp);
-		up_write(&mm->mmap_sem);
 
 		kdebug("mmap[%d] <file> sz=%lx pr=%x fl=%x of=%lx --> %08lx",
 		       loop, phdr->p_memsz + disp, prot, flags,
@@ -1096,10 +1091,8 @@ static int elf_fdpic_map_file_by_direct_
 			unsigned long xmaddr;
 
 			flags |= MAP_FIXED | MAP_ANONYMOUS;
-			down_write(&mm->mmap_sem);
 			xmaddr = do_mmap(NULL, xaddr, excess - excess1,
 					 prot, flags, 0);
-			up_write(&mm->mmap_sem);
 
 			kdebug("mmap[%d] <anon>"
 			       " ad=%lx sz=%lx pr=%x fl=%x of=0 --> %08lx",
Index: linux-2.6/fs/binfmt_flat.c
===================================================================
--- linux-2.6.orig/fs/binfmt_flat.c
+++ linux-2.6/fs/binfmt_flat.c
@@ -531,9 +531,7 @@ static int load_flat_file(struct linux_b
 		 */
 		DBG_FLT("BINFMT_FLAT: ROM mapping of file (we hope)\n");
 
-		down_write(&current->mm->mmap_sem);
 		textpos = do_mmap(bprm->file, 0, text_len, PROT_READ|PROT_EXEC, MAP_PRIVATE, 0);
-		up_write(&current->mm->mmap_sem);
 		if (!textpos  || textpos >= (unsigned long) -4096) {
 			if (!textpos)
 				textpos = (unsigned long) -ENOMEM;
@@ -544,7 +542,7 @@ static int load_flat_file(struct linux_b
 
 		len = data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
 		down_write(&current->mm->mmap_sem);
-		realdatastart = do_mmap(0, 0, len,
+		realdatastart = __do_mmap_anon(0, len,
 			PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE, 0);
 		/* Remap to use all availabe slack region space */
 		if (realdatastart && (realdatastart < (unsigned long)-4096)) {
@@ -596,7 +594,7 @@ static int load_flat_file(struct linux_b
 
 		len = text_len + data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
 		down_write(&current->mm->mmap_sem);
-		textpos = do_mmap(0, 0, len,
+		textpos = __do_mmap_anon(0, len,
 			PROT_READ | PROT_EXEC | PROT_WRITE, MAP_PRIVATE, 0);
 		/* Remap to use all availabe slack region space */
 		if (textpos && (textpos < (unsigned long) -4096)) {
Index: linux-2.6/fs/binfmt_som.c
===================================================================
--- linux-2.6.orig/fs/binfmt_som.c
+++ linux-2.6/fs/binfmt_som.c
@@ -148,10 +148,8 @@ static int map_som_binary(struct file *f
 	code_size = SOM_PAGEALIGN(hpuxhdr->exec_tsize);
 	current->mm->start_code = code_start;
 	current->mm->end_code = code_start + code_size;
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, code_start, code_size, prot,
 			flags, SOM_PAGESTART(hpuxhdr->exec_tfile));
-	up_write(&current->mm->mmap_sem);
 	if (retval < 0 && retval > -1024)
 		goto out;
 
@@ -159,20 +157,16 @@ static int map_som_binary(struct file *f
 	data_size = SOM_PAGEALIGN(hpuxhdr->exec_dsize);
 	current->mm->start_data = data_start;
 	current->mm->end_data = bss_start = data_start + data_size;
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, data_start, data_size,
 			prot | PROT_WRITE, flags,
 			SOM_PAGESTART(hpuxhdr->exec_dfile));
-	up_write(&current->mm->mmap_sem);
 	if (retval < 0 && retval > -1024)
 		goto out;
 
 	som_brk = bss_start + SOM_PAGEALIGN(hpuxhdr->exec_bsize);
 	current->mm->start_brk = current->mm->brk = som_brk;
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(NULL, bss_start, som_brk - bss_start,
 			prot | PROT_WRITE, MAP_FIXED | MAP_PRIVATE, 0);
-	up_write(&current->mm->mmap_sem);
 	if (retval > 0 || retval < -1024)
 		retval = 0;
 out:
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -980,6 +980,10 @@ extern int install_special_mapping(struc
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
+extern unsigned long ___do_mmap_pgoff(
+	struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flag, unsigned long pgoff);
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff);
@@ -988,19 +992,25 @@ extern unsigned long mmap_region(struct 
 	unsigned int vm_flags, unsigned long pgoff,
 	int accountable);
 
-static inline unsigned long do_mmap(struct file *file, unsigned long addr,
+static inline unsigned long __do_mmap_anon(unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
 {
 	unsigned long ret = -EINVAL;
-	if ((offset + PAGE_ALIGN(len)) < offset)
-		goto out;
-	if (!(offset & ~PAGE_MASK))
-		ret = do_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
-out:
+	unsigned long pgoff = offset >> PAGE_SHIFT;
+
+	if ((offset + PAGE_ALIGN(len)) < offset || (offset & ~PAGE_MASK))
+		return ret;
+
+	ret = ___do_mmap_pgoff(NULL, addr, len, prot, flag, pgoff);
+
 	return ret;
 }
 
+extern unsigned long do_mmap(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flag, unsigned long offset);
+
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
 extern unsigned long do_brk(unsigned long, unsigned long);
Index: linux-2.6/ipc/shm.c
===================================================================
--- linux-2.6.orig/ipc/shm.c
+++ linux-2.6/ipc/shm.c
@@ -1012,7 +1012,7 @@ long do_shmat(int shmid, char __user *sh
 			goto invalid;
 	}
 		
-	user_addr = do_mmap (file, addr, size, prot, flags, 0);
+	user_addr = ___do_mmap_pgoff (file, addr, size, prot, flags, 0);
 	*raddr = user_addr;
 	err = 0;
 	if (IS_ERR_VALUE(user_addr))
Index: linux-2.6/mm/mmap.c
===================================================================
--- linux-2.6.orig/mm/mmap.c
+++ linux-2.6/mm/mmap.c
@@ -888,9 +888,9 @@ void vm_stat_account(struct mm_struct *m
  * The caller must hold down_write(current->mm->mmap_sem).
  */
 
-unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
-			unsigned long len, unsigned long prot,
-			unsigned long flags, unsigned long pgoff)
+unsigned long ___do_mmap_pgoff(struct file * file, unsigned long addr,
+		unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long pgoff)
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
@@ -1026,10 +1026,44 @@ unsigned long do_mmap_pgoff(struct file 
 	return mmap_region(file, addr, len, flags, vm_flags, pgoff,
 			   accountable);
 }
+EXPORT_SYMBOL(___do_mmap_pgoff);
+
+unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
+			unsigned long len, unsigned long prot,
+			unsigned long flags, unsigned long pgoff)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long ret;
+
+	down_write(&mm->mmap_sem);
+	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
 EXPORT_SYMBOL(do_mmap_pgoff);
 
+unsigned long do_mmap(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long offset)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long ret = -EINVAL;
+	unsigned long pgoff = offset >> PAGE_SHIFT;
+
+	if ((offset + PAGE_ALIGN(len)) < offset || (offset & ~PAGE_MASK))
+		return ret;
+
+	down_write(&mm->mmap_sem);
+	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
+EXPORT_SYMBOL(do_mmap);
+
 /*
- * Some shared mappigns will want the pages marked read-only
+ * Some shared mappings will want the pages marked read-only
  * to track write events. If so, we'll downgrade vm_page_prot
  * to the private version (using protection_map[] without the
  * VM_SHARED bit).
Index: linux-2.6/mm/nommu.c
===================================================================
--- linux-2.6.orig/mm/nommu.c
+++ linux-2.6/mm/nommu.c
@@ -815,7 +815,7 @@ enomem:
 /*
  * handle mapping creation for uClinux
  */
-unsigned long do_mmap_pgoff(struct file *file,
+unsigned long ___do_mmap_pgoff(struct file *file,
 			    unsigned long addr,
 			    unsigned long len,
 			    unsigned long prot,
@@ -1013,8 +1013,45 @@ unsigned long do_mmap_pgoff(struct file 
 	show_free_areas();
 	return -ENOMEM;
 }
+EXPORT_SYMBOL(___do_mmap_pgoff);
+
+unsigned long do_mmap_pgoff(struct file *file,
+			    unsigned long addr,
+			    unsigned long len,
+			    unsigned long prot,
+			    unsigned long flags,
+			    unsigned long pgoff)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long ret;
+
+	down_write(&mm->mmap_sem);
+	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
 EXPORT_SYMBOL(do_mmap_pgoff);
 
+unsigned long do_mmap(struct file *file, unsigned long addr,
+		unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long offset)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long ret = -EINVAL;
+	unsigned long pgoff = offset >> PAGE_SHIFT;
+
+	if ((offset + PAGE_ALIGN(len)) < offset || (offset & ~PAGE_MASK))
+		return ret;
+
+	down_write(&mm->mmap_sem);
+	ret = ___do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
+	up_write(&mm->mmap_sem);
+
+	return ret;
+}
+EXPORT_SYMBOL(do_mmap);
+
 /*
  * handle mapping disposal for uClinux
  */

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
