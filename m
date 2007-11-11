Subject: Re: dio_get_page() lockdep complaints
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <1194630300.7459.65.camel@heimdal.trondhjem.org>
References: <20070419073828.GB20928@kernel.dk>
	 <1194627742.6289.175.camel@twins>  <4734992C.7000408@oracle.com>
	 <1194630300.7459.65.camel@heimdal.trondhjem.org>
Content-Type: text/plain
Date: Sun, 11 Nov 2007 20:49:06 +0100
Message-Id: <1194810546.6098.6.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Zach Brown <zach.brown@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-aio@kvack.org, Chris Mason <chris.mason@oracle.com>, linux-mm <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Linus Torvalds <torvalds@linux-foundation.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-09 at 12:45 -0500, Trond Myklebust wrote:
> On Fri, 2007-11-09 at 09:30 -0800, Zach Brown wrote:
> > So, reiserfs and NFS are nesting i_mutex inside the mmap_sem.
> > 
> > >>        [<b038c6e5>] mutex_lock+0x1c/0x1f
> > >>        [<b01b17e9>] reiserfs_file_release+0x54/0x447
> > >>        [<b016afe7>] __fput+0x53/0x101
> > >>        [<b016b0ee>] fput+0x19/0x1c
> > >>        [<b015bcd5>] remove_vma+0x3b/0x4d
> > >>        [<b015c659>] do_munmap+0x17f/0x1cf
> > 
> > >        [<ffffffff802686a1>] _mutex_lock+0x28/0x34
> > >        [<ffffffff883e71d0>] nfs_revalidate_mapping+0x6d/0xac [nfs]
> > >        [<ffffffff883e4b51>] nfs_file_mmap+0x5c/0x74 [nfs]
> > >        [<ffffffff8020df7e>] do_mmap_pgoff+0x51a/0x817
> > >        [<ffffffff80225d19>] sys_mmap+0x90/0x119
> > 
> > I think i_mutex is fundamentally nested outside of the mmap_sem because
> > of faulting in the buffered write path.  I think these warnings could be
> > reproduced with a careful test app which tries buffered writes from an
> > address which will fault.
> > 
> > DIO just tripped it up because it *always* performs get_user_pages() on
> > the memory.
> > 
> > So reiser and NFS need to be fixed.  No?
> 
> Actually, it is rather mmap() needs to be fixed. It is cold calling the
> filesystem while holding all sorts of nasty locks. It needs to be
> migrated to the same sort of syscall layout as read() and write().
> 
> You _first_ call the filesystem so that it can make whatever
> preparations it needs outside the lock. The filesystem then calls the
> VM, which can then call the filesystem back if needed.

Right, which gets us into all kinds of trouble because some sites need
mmap_sem to resolve some races, notably s390 31-bit and shm.

Quick proto-type that moves mmap_sem into do_mmap{,_pgoff} and provides
_locked functions for those few icky sites.

The !_locked functions also call f_op->mmap_prepare() before taking the
mmap_sem. Which makes for some ugly asymetry :-/

Anyway, I'm not comming up with anything nicer atm, hopefully a nice
idea will present itself soon.

(compile tested only - mostly for illustrational purposes)

Not-signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
---
 arch/alpha/kernel/osf_sys.c         |    2 -
 arch/arm/kernel/sys_arm.c           |    2 -
 arch/avr32/kernel/sys_avr32.c       |    2 -
 arch/blackfin/kernel/sys_bfin.c     |    2 -
 arch/cris/kernel/sys_cris.c         |    2 -
 arch/frv/kernel/sys_frv.c           |    4 --
 arch/h8300/kernel/sys_h8300.c       |    4 --
 arch/ia64/ia32/sys_ia32.c           |   30 +++++-----------
 arch/ia64/kernel/sys_ia64.c         |    2 -
 arch/m32r/kernel/sys_m32r.c         |    2 -
 arch/m68k/kernel/sys_m68k.c         |    4 --
 arch/m68knommu/kernel/sys_m68k.c    |    2 -
 arch/mips/kernel/irixelf.c          |   10 -----
 arch/mips/kernel/linux32.c          |    2 -
 arch/mips/kernel/syscall.c          |    2 -
 arch/mips/kernel/sysirix.c          |    5 --
 arch/parisc/kernel/sys_parisc.c     |    2 -
 arch/powerpc/kernel/syscalls.c      |    2 -
 arch/s390/kernel/compat_linux.c     |    5 +-
 arch/s390/kernel/sys_s390.c         |    2 -
 arch/sh/kernel/sys_sh.c             |    2 -
 arch/sh64/kernel/sys_sh64.c         |    2 -
 arch/sparc/kernel/sys_sparc.c       |    2 -
 arch/sparc/kernel/sys_sunos.c       |    2 -
 arch/sparc64/kernel/binfmt_aout32.c |    6 ---
 arch/sparc64/kernel/sys_sparc.c     |    2 -
 arch/sparc64/kernel/sys_sunos32.c   |    2 -
 arch/sparc64/solaris/misc.c         |    2 -
 arch/um/kernel/syscall.c            |    2 -
 arch/v850/kernel/syscalls.c         |    2 -
 arch/x86/ia32/ia32_aout.c           |    6 ---
 arch/x86/ia32/sys_ia32.c            |    5 --
 arch/x86/kernel/sys_i386_32.c       |    2 -
 arch/x86/kernel/sys_x86_64.c        |    2 -
 arch/xtensa/kernel/syscall.c        |    2 -
 drivers/char/drm/drm_bufs.c         |    4 --
 drivers/char/drm/i810_dma.c         |    2 -
 fs/aio.c                            |    4 +-
 fs/binfmt_aout.c                    |    6 ---
 fs/binfmt_elf.c                     |    6 ---
 fs/binfmt_elf_fdpic.c               |    9 ----
 fs/binfmt_flat.c                    |    6 +--
 fs/binfmt_som.c                     |    6 ---
 fs/nfs/file.c                       |   25 +++++++++----
 include/linux/fs.h                  |    1 
 include/linux/mm.h                  |   13 ++++++-
 ipc/shm.c                           |    2 -
 mm/mmap.c                           |   65 +++++++++++++++++++++++++++++++++---
 48 files changed, 109 insertions(+), 169 deletions(-)

Index: linux-2.6-2/arch/alpha/kernel/osf_sys.c
===================================================================
--- linux-2.6-2.orig/arch/alpha/kernel/osf_sys.c
+++ linux-2.6-2/arch/alpha/kernel/osf_sys.c
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
Index: linux-2.6-2/arch/arm/kernel/sys_arm.c
===================================================================
--- linux-2.6-2.orig/arch/arm/kernel/sys_arm.c
+++ linux-2.6-2/arch/arm/kernel/sys_arm.c
@@ -72,9 +72,7 @@ inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/avr32/kernel/sys_avr32.c
===================================================================
--- linux-2.6-2.orig/arch/avr32/kernel/sys_avr32.c
+++ linux-2.6-2/arch/avr32/kernel/sys_avr32.c
@@ -41,9 +41,7 @@ asmlinkage long sys_mmap2(unsigned long 
 			return error;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, offset);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/blackfin/kernel/sys_bfin.c
===================================================================
--- linux-2.6-2.orig/arch/blackfin/kernel/sys_bfin.c
+++ linux-2.6-2/arch/blackfin/kernel/sys_bfin.c
@@ -78,9 +78,7 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/cris/kernel/sys_cris.c
===================================================================
--- linux-2.6-2.orig/arch/cris/kernel/sys_cris.c
+++ linux-2.6-2/arch/cris/kernel/sys_cris.c
@@ -60,9 +60,7 @@ do_mmap2(unsigned long addr, unsigned lo
                         goto out;
         }
 
-        down_write(&current->mm->mmap_sem);
         error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-        up_write(&current->mm->mmap_sem);
 
         if (file)
                 fput(file);
Index: linux-2.6-2/arch/frv/kernel/sys_frv.c
===================================================================
--- linux-2.6-2.orig/arch/frv/kernel/sys_frv.c
+++ linux-2.6-2/arch/frv/kernel/sys_frv.c
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
Index: linux-2.6-2/arch/h8300/kernel/sys_h8300.c
===================================================================
--- linux-2.6-2.orig/arch/h8300/kernel/sys_h8300.c
+++ linux-2.6-2/arch/h8300/kernel/sys_h8300.c
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
Index: linux-2.6-2/arch/ia64/ia32/sys_ia32.c
===================================================================
--- linux-2.6-2.orig/arch/ia64/ia32/sys_ia32.c
+++ linux-2.6-2/arch/ia64/ia32/sys_ia32.c
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
Index: linux-2.6-2/arch/ia64/kernel/sys_ia64.c
===================================================================
--- linux-2.6-2.orig/arch/ia64/kernel/sys_ia64.c
+++ linux-2.6-2/arch/ia64/kernel/sys_ia64.c
@@ -209,9 +209,7 @@ do_mmap2 (unsigned long addr, unsigned l
 		goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	addr = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 out:	if (file)
 		fput(file);
Index: linux-2.6-2/arch/m32r/kernel/sys_m32r.c
===================================================================
--- linux-2.6-2.orig/arch/m32r/kernel/sys_m32r.c
+++ linux-2.6-2/arch/m32r/kernel/sys_m32r.c
@@ -110,9 +110,7 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/m68k/kernel/sys_m68k.c
===================================================================
--- linux-2.6-2.orig/arch/m68k/kernel/sys_m68k.c
+++ linux-2.6-2/arch/m68k/kernel/sys_m68k.c
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
Index: linux-2.6-2/arch/m68knommu/kernel/sys_m68k.c
===================================================================
--- linux-2.6-2.orig/arch/m68knommu/kernel/sys_m68k.c
+++ linux-2.6-2/arch/m68knommu/kernel/sys_m68k.c
@@ -61,9 +61,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/mips/kernel/irixelf.c
===================================================================
--- linux-2.6-2.orig/arch/mips/kernel/irixelf.c
+++ linux-2.6-2/arch/mips/kernel/irixelf.c
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
 	(void) do_mmap(NULL, 0, 4096, PROT_READ | PROT_EXEC,
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
Index: linux-2.6-2/arch/mips/kernel/linux32.c
===================================================================
--- linux-2.6-2.orig/arch/mips/kernel/linux32.c
+++ linux-2.6-2/arch/mips/kernel/linux32.c
@@ -119,9 +119,7 @@ sys32_mmap2(unsigned long addr, unsigned
 	}
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 
Index: linux-2.6-2/arch/mips/kernel/syscall.c
===================================================================
--- linux-2.6-2.orig/arch/mips/kernel/syscall.c
+++ linux-2.6-2/arch/mips/kernel/syscall.c
@@ -136,9 +136,7 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/mips/kernel/sysirix.c
===================================================================
--- linux-2.6-2.orig/arch/mips/kernel/sysirix.c
+++ linux-2.6-2/arch/mips/kernel/sysirix.c
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
 
Index: linux-2.6-2/arch/parisc/kernel/sys_parisc.c
===================================================================
--- linux-2.6-2.orig/arch/parisc/kernel/sys_parisc.c
+++ linux-2.6-2/arch/parisc/kernel/sys_parisc.c
@@ -137,9 +137,7 @@ static unsigned long do_mmap2(unsigned l
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file != NULL)
 		fput(file);
Index: linux-2.6-2/arch/powerpc/kernel/syscalls.c
===================================================================
--- linux-2.6-2.orig/arch/powerpc/kernel/syscalls.c
+++ linux-2.6-2/arch/powerpc/kernel/syscalls.c
@@ -175,9 +175,7 @@ static inline unsigned long do_mmap2(uns
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	ret = do_mmap_pgoff(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 	if (file)
 		fput(file);
 out:
Index: linux-2.6-2/arch/s390/kernel/compat_linux.c
===================================================================
--- linux-2.6-2.orig/arch/s390/kernel/compat_linux.c
+++ linux-2.6-2/arch/s390/kernel/compat_linux.c
@@ -860,14 +860,15 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
 	if (!IS_ERR((void *) error) && error + len >= 0x80000000ULL) {
 		/* Result is out of bounds.  */
+		/* XXX fix race - APZ */
+		down_write(&current->mm->mmap_sem);
 		do_munmap(current->mm, addr, len);
+		up_write(&current->mm->mmap_sem);
 		error = -ENOMEM;
 	}
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/s390/kernel/sys_s390.c
===================================================================
--- linux-2.6-2.orig/arch/s390/kernel/sys_s390.c
+++ linux-2.6-2/arch/s390/kernel/sys_s390.c
@@ -65,9 +65,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/sh/kernel/sys_sh.c
===================================================================
--- linux-2.6-2.orig/arch/sh/kernel/sys_sh.c
+++ linux-2.6-2/arch/sh/kernel/sys_sh.c
@@ -153,9 +153,7 @@ do_mmap2(unsigned long addr, unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/sh64/kernel/sys_sh64.c
===================================================================
--- linux-2.6-2.orig/arch/sh64/kernel/sys_sh64.c
+++ linux-2.6-2/arch/sh64/kernel/sys_sh64.c
@@ -148,9 +148,7 @@ static inline long do_mmap2(
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/sparc/kernel/sys_sparc.c
===================================================================
--- linux-2.6-2.orig/arch/sparc/kernel/sys_sparc.c
+++ linux-2.6-2/arch/sparc/kernel/sys_sparc.c
@@ -252,9 +252,7 @@ static unsigned long do_mmap2(unsigned l
 	len = PAGE_ALIGN(len);
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/sparc/kernel/sys_sunos.c
===================================================================
--- linux-2.6-2.orig/arch/sparc/kernel/sys_sunos.c
+++ linux-2.6-2/arch/sparc/kernel/sys_sunos.c
@@ -120,9 +120,7 @@ asmlinkage unsigned long sunos_mmap(unsi
 	}
 
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 	if (!ret_type)
 		retval = ((retval < PAGE_OFFSET) ? 0 : retval);
 
Index: linux-2.6-2/arch/sparc64/kernel/binfmt_aout32.c
===================================================================
--- linux-2.6-2.orig/arch/sparc64/kernel/binfmt_aout32.c
+++ linux-2.6-2/arch/sparc64/kernel/binfmt_aout32.c
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
Index: linux-2.6-2/arch/sparc64/kernel/sys_sparc.c
===================================================================
--- linux-2.6-2.orig/arch/sparc64/kernel/sys_sparc.c
+++ linux-2.6-2/arch/sparc64/kernel/sys_sparc.c
@@ -576,9 +576,7 @@ asmlinkage unsigned long sys_mmap(unsign
 	flags &= ~(MAP_EXECUTABLE | MAP_DENYWRITE);
 	len = PAGE_ALIGN(len);
 
-	down_write(&current->mm->mmap_sem);
 	retval = do_mmap(file, addr, len, prot, flags, off);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/sparc64/kernel/sys_sunos32.c
===================================================================
--- linux-2.6-2.orig/arch/sparc64/kernel/sys_sunos32.c
+++ linux-2.6-2/arch/sparc64/kernel/sys_sunos32.c
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
Index: linux-2.6-2/arch/sparc64/solaris/misc.c
===================================================================
--- linux-2.6-2.orig/arch/sparc64/solaris/misc.c
+++ linux-2.6-2/arch/sparc64/solaris/misc.c
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
 	                        
Index: linux-2.6-2/arch/um/kernel/syscall.c
===================================================================
--- linux-2.6-2.orig/arch/um/kernel/syscall.c
+++ linux-2.6-2/arch/um/kernel/syscall.c
@@ -54,9 +54,7 @@ long sys_mmap2(unsigned long addr, unsig
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/v850/kernel/syscalls.c
===================================================================
--- linux-2.6-2.orig/arch/v850/kernel/syscalls.c
+++ linux-2.6-2/arch/v850/kernel/syscalls.c
@@ -164,9 +164,7 @@ do_mmap2 (unsigned long addr, size_t len
 			goto out;
 	}
 	
-	down_write (&current->mm->mmap_sem);
 	ret = do_mmap_pgoff (file, addr, len, prot, flags, pgoff);
-	up_write (&current->mm->mmap_sem);
 	if (file)
 		fput (file);
 out:
Index: linux-2.6-2/arch/x86/ia32/ia32_aout.c
===================================================================
--- linux-2.6-2.orig/arch/x86/ia32/ia32_aout.c
+++ linux-2.6-2/arch/x86/ia32/ia32_aout.c
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
Index: linux-2.6-2/arch/x86/ia32/sys_ia32.c
===================================================================
--- linux-2.6-2.orig/arch/x86/ia32/sys_ia32.c
+++ linux-2.6-2/arch/x86/ia32/sys_ia32.c
@@ -242,13 +242,10 @@ sys32_mmap(struct mmap_arg_struct __user
 	}
 	
 	mm = current->mm; 
-	down_write(&mm->mmap_sem); 
 	retval = do_mmap_pgoff(file, a.addr, a.len, a.prot, a.flags, a.offset>>PAGE_SHIFT);
 	if (file)
 		fput(file);
 
-	up_write(&mm->mmap_sem); 
-
 	return retval;
 }
 
@@ -708,9 +705,7 @@ asmlinkage long sys32_mmap2(unsigned lon
 			return -EBADF;
 	}
 
-	down_write(&mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/x86/kernel/sys_i386_32.c
===================================================================
--- linux-2.6-2.orig/arch/x86/kernel/sys_i386_32.c
+++ linux-2.6-2/arch/x86/kernel/sys_i386_32.c
@@ -54,9 +54,7 @@ asmlinkage long sys_mmap2(unsigned long 
 			goto out;
 	}
 
-	down_write(&mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/x86/kernel/sys_x86_64.c
===================================================================
--- linux-2.6-2.orig/arch/x86/kernel/sys_x86_64.c
+++ linux-2.6-2/arch/x86/kernel/sys_x86_64.c
@@ -51,9 +51,7 @@ asmlinkage long sys_mmap(unsigned long a
 		if (!file)
 			goto out;
 	}
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, off >> PAGE_SHIFT);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/arch/xtensa/kernel/syscall.c
===================================================================
--- linux-2.6-2.orig/arch/xtensa/kernel/syscall.c
+++ linux-2.6-2/arch/xtensa/kernel/syscall.c
@@ -72,9 +72,7 @@ asmlinkage long xtensa_mmap2(unsigned lo
 			goto out;
 	}
 
-	down_write(&current->mm->mmap_sem);
 	error = do_mmap_pgoff(file, addr, len, prot, flags, pgoff);
-	up_write(&current->mm->mmap_sem);
 
 	if (file)
 		fput(file);
Index: linux-2.6-2/drivers/char/drm/drm_bufs.c
===================================================================
--- linux-2.6-2.orig/drivers/char/drm/drm_bufs.c
+++ linux-2.6-2/drivers/char/drm/drm_bufs.c
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
Index: linux-2.6-2/drivers/char/drm/i810_dma.c
===================================================================
--- linux-2.6-2.orig/drivers/char/drm/i810_dma.c
+++ linux-2.6-2/drivers/char/drm/i810_dma.c
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
Index: linux-2.6-2/fs/aio.c
===================================================================
--- linux-2.6-2.orig/fs/aio.c
+++ linux-2.6-2/fs/aio.c
@@ -129,18 +129,18 @@ static int aio_setup_ring(struct kioctx 
 
 	info->mmap_size = nr_pages * PAGE_SIZE;
 	dprintk("attempting mmap of %lu bytes\n", info->mmap_size);
-	down_write(&ctx->mm->mmap_sem);
+	WARN_ON(ctx->mm != current->mm);
 	info->mmap_base = do_mmap(NULL, 0, info->mmap_size, 
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
Index: linux-2.6-2/fs/binfmt_aout.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_aout.c
+++ linux-2.6-2/fs/binfmt_aout.c
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
Index: linux-2.6-2/fs/binfmt_elf.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_elf.c
+++ linux-2.6-2/fs/binfmt_elf.c
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
 
Index: linux-2.6-2/fs/binfmt_elf_fdpic.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_elf_fdpic.c
+++ linux-2.6-2/fs/binfmt_elf_fdpic.c
@@ -370,14 +370,12 @@ static int load_elf_fdpic_binary(struct 
 	if (stack_size < PAGE_SIZE * 2)
 		stack_size = PAGE_SIZE * 2;
 
-	down_write(&current->mm->mmap_sem);
 	current->mm->start_brk = do_mmap(NULL, 0, stack_size,
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
Index: linux-2.6-2/fs/binfmt_flat.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_flat.c
+++ linux-2.6-2/fs/binfmt_flat.c
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
+		realdatastart = do_mmap_locked(0, 0, len,
 			PROT_READ|PROT_WRITE|PROT_EXEC, MAP_PRIVATE, 0);
 		/* Remap to use all availabe slack region space */
 		if (realdatastart && (realdatastart < (unsigned long)-4096)) {
@@ -596,7 +594,7 @@ static int load_flat_file(struct linux_b
 
 		len = text_len + data_len + extra + MAX_SHARED_LIBS * sizeof(unsigned long);
 		down_write(&current->mm->mmap_sem);
-		textpos = do_mmap(0, 0, len,
+		textpos = do_mmap_locked(0, 0, len,
 			PROT_READ | PROT_EXEC | PROT_WRITE, MAP_PRIVATE, 0);
 		/* Remap to use all availabe slack region space */
 		if (textpos && (textpos < (unsigned long) -4096)) {
Index: linux-2.6-2/fs/binfmt_som.c
===================================================================
--- linux-2.6-2.orig/fs/binfmt_som.c
+++ linux-2.6-2/fs/binfmt_som.c
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
Index: linux-2.6-2/fs/nfs/file.c
===================================================================
--- linux-2.6-2.orig/fs/nfs/file.c
+++ linux-2.6-2/fs/nfs/file.c
@@ -41,6 +41,9 @@
 static int nfs_file_open(struct inode *, struct file *);
 static int nfs_file_release(struct inode *, struct file *);
 static loff_t nfs_file_llseek(struct file *file, loff_t offset, int origin);
+static int
+nfs_file_mmap_prepare(struct file * file, unsigned long addr, unsigned long len,
+		unsigned long prot, unsigned long flags, unsigned long pgoff);
 static int  nfs_file_mmap(struct file *, struct vm_area_struct *);
 static ssize_t nfs_file_splice_read(struct file *filp, loff_t *ppos,
 					struct pipe_inode_info *pipe,
@@ -64,6 +67,7 @@ const struct file_operations nfs_file_op
 	.write		= do_sync_write,
 	.aio_read	= nfs_file_read,
 	.aio_write	= nfs_file_write,
+	.mmap_prepare	= nfs_file_mmap_prepare,
 	.mmap		= nfs_file_mmap,
 	.open		= nfs_file_open,
 	.flush		= nfs_file_flush,
@@ -270,7 +274,8 @@ nfs_file_splice_read(struct file *filp, 
 }
 
 static int
-nfs_file_mmap(struct file * file, struct vm_area_struct * vma)
+nfs_file_mmap_prepare(struct file * file, unsigned long addr, unsigned long len,
+		unsigned long prot, unsigned long flags, unsigned long pgoff)
 {
 	struct dentry *dentry = file->f_path.dentry;
 	struct inode *inode = dentry->d_inode;
@@ -279,13 +284,17 @@ nfs_file_mmap(struct file * file, struct
 	dfprintk(VFS, "nfs: mmap(%s/%s)\n",
 		dentry->d_parent->d_name.name, dentry->d_name.name);
 
-	status = nfs_revalidate_mapping(inode, file->f_mapping);
-	if (!status) {
-		vma->vm_ops = &nfs_file_vm_ops;
-		vma->vm_flags |= VM_CAN_NONLINEAR;
-		file_accessed(file);
-	}
-	return status;
+	return nfs_revalidate_mapping(inode, file->f_mapping);
+}
+
+static int
+nfs_file_mmap(struct file *file, struct vm_area_struct *vma)
+{
+	vma->vm_ops = &nfs_file_vm_ops;
+	vma->vm_flags |= VM_CAN_NONLINEAR;
+	file_accessed(file);
+
+	return 0;
 }
 
 /*
Index: linux-2.6-2/include/linux/fs.h
===================================================================
--- linux-2.6-2.orig/include/linux/fs.h
+++ linux-2.6-2/include/linux/fs.h
@@ -1172,6 +1172,7 @@ struct file_operations {
 	int (*ioctl) (struct inode *, struct file *, unsigned int, unsigned long);
 	long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
 	long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
+	int (*mmap_prepare) (struct file *, unsigned long addr, unsigned long len, unsigned long prot, unsigned long flags, unsigned long pgoff);
 	int (*mmap) (struct file *, struct vm_area_struct *);
 	int (*open) (struct inode *, struct file *);
 	int (*flush) (struct file *, fl_owner_t id);
Index: linux-2.6-2/include/linux/mm.h
===================================================================
--- linux-2.6-2.orig/include/linux/mm.h
+++ linux-2.6-2/include/linux/mm.h
@@ -980,6 +980,10 @@ extern int install_special_mapping(struc
 
 extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
 
+extern unsigned long do_mmap_pgoff_locked(
+	struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flag, unsigned long pgoff);
 extern unsigned long do_mmap_pgoff(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long pgoff);
@@ -988,7 +992,7 @@ extern unsigned long mmap_region(struct 
 	unsigned int vm_flags, unsigned long pgoff,
 	int accountable);
 
-static inline unsigned long do_mmap(struct file *file, unsigned long addr,
+static inline unsigned long do_mmap_locked(struct file *file, unsigned long addr,
 	unsigned long len, unsigned long prot,
 	unsigned long flag, unsigned long offset)
 {
@@ -996,11 +1000,16 @@ static inline unsigned long do_mmap(stru
 	if ((offset + PAGE_ALIGN(len)) < offset)
 		goto out;
 	if (!(offset & ~PAGE_MASK))
-		ret = do_mmap_pgoff(file, addr, len, prot, flag, offset >> PAGE_SHIFT);
+		ret = do_mmap_pgoff_locked(file, addr, len, prot,
+				flag, offset >> PAGE_SHIFT);
 out:
 	return ret;
 }
 
+extern unsigned long do_mmap(struct file *file, unsigned long addr,
+	unsigned long len, unsigned long prot,
+	unsigned long flag, unsigned long offset);
+
 extern int do_munmap(struct mm_struct *, unsigned long, size_t);
 
 extern unsigned long do_brk(unsigned long, unsigned long);
Index: linux-2.6-2/ipc/shm.c
===================================================================
--- linux-2.6-2.orig/ipc/shm.c
+++ linux-2.6-2/ipc/shm.c
@@ -1012,7 +1012,7 @@ long do_shmat(int shmid, char __user *sh
 			goto invalid;
 	}
 		
-	user_addr = do_mmap (file, addr, size, prot, flags, 0);
+	user_addr = do_mmap_locked (file, addr, size, prot, flags, 0);
 	*raddr = user_addr;
 	err = 0;
 	if (IS_ERR_VALUE(user_addr))
Index: linux-2.6-2/mm/mmap.c
===================================================================
--- linux-2.6-2.orig/mm/mmap.c
+++ linux-2.6-2/mm/mmap.c
@@ -888,9 +888,10 @@ void vm_stat_account(struct mm_struct *m
  * The caller must hold down_write(current->mm->mmap_sem).
  */
 
-unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
-			unsigned long len, unsigned long prot,
-			unsigned long flags, unsigned long pgoff)
+static unsigned long __do_mmap_pgoff_locked(
+		struct file * file, unsigned long addr,
+		unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long pgoff)
 {
 	struct mm_struct * mm = current->mm;
 	struct inode *inode;
@@ -1026,10 +1027,66 @@ unsigned long do_mmap_pgoff(struct file 
 	return mmap_region(file, addr, len, flags, vm_flags, pgoff,
 			   accountable);
 }
+
+unsigned long do_mmap_pgoff_locked(struct file * file, unsigned long addr,
+		unsigned long len, unsigned long prot,
+		unsigned long flags, unsigned long pgoff)
+{
+	WARN_ON(file && file->f_op->mmap_prepare);
+	return __do_mmap_pgoff_locked(file, addr, len, prot, flags, pgoff);
+}
+EXPORT_SYMBOL(do_mmap_pgoff_locked);
+
+unsigned long do_mmap_pgoff(struct file * file, unsigned long addr,
+			unsigned long len, unsigned long prot,
+			unsigned long flags, unsigned long pgoff)
+{
+	struct mm_struct *mm = current->mm;
+	unsigned long ret;
+
+	if (file && file->f_op->mmap_prepare) {
+		ret = file->f_op->mmap_prepare(file, addr,
+				len, prot, flags, pgoff);
+		if (ret)
+			return ret;
+	}
+
+	down_write(&mm->mmap_sem);
+	ret = __do_mmap_pgoff_locked(file, addr, len, prot, flags, pgoff);
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
+	if (file && file->f_op->mmap_prepare) {
+		ret = file->f_op->mmap_prepare(file, addr,
+				len, prot, flags, pgoff);
+		if (ret)
+			return ret;
+	}
+
+	down_write(&mm->mmap_sem);
+	ret = __do_mmap_pgoff_locked(file, addr, len, prot, flags, pgoff);
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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
