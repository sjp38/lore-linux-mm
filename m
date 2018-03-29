Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 78A186B000E
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:09 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w59so2540529wrb.8
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:09 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id b12si4522283wrh.368.2018.03.29.04.26.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:07 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 097/109] mm: add ksys_mmap_pgoff() helper; remove in-kernel calls to sys_mmap_pgoff()
Date: Thu, 29 Mar 2018 13:24:14 +0200
Message-Id: <20180329112426.23043-98-linux@dominikbrodowski.net>
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Using this helper allows us to avoid the in-kernel calls to the
sys_mmap_pgoff() syscall. The ksys_ prefix denotes that this function is
meant as a drop-in replacement for the syscall. In particular, it uses the
same calling convention as sys_mmap_pgoff().

This patch is part of a series which removes in-kernel calls to syscalls.
On this basis, the syscall entry path can be streamlined. For details, see
http://lkml.kernel.org/r/20180325162527.GA17492@light.dominikbrodowski.net

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 arch/alpha/kernel/osf_sys.c             |  2 +-
 arch/arm64/kernel/sys.c                 |  2 +-
 arch/ia64/kernel/sys_ia64.c             |  4 ++--
 arch/m68k/kernel/sys_m68k.c             |  2 +-
 arch/microblaze/kernel/sys_microblaze.c |  6 +++---
 arch/mips/kernel/linux32.c              |  4 ++--
 arch/mips/kernel/syscall.c              |  6 ++++--
 arch/parisc/kernel/sys_parisc.c         |  6 +++---
 arch/powerpc/kernel/syscalls.c          |  2 +-
 arch/riscv/kernel/sys_riscv.c           |  4 ++--
 arch/s390/kernel/compat_linux.c         |  6 +++---
 arch/s390/kernel/sys_s390.c             |  2 +-
 arch/sh/kernel/sys_sh.c                 |  4 ++--
 arch/sparc/kernel/sys_sparc_32.c        |  6 +++---
 arch/sparc/kernel/sys_sparc_64.c        |  2 +-
 arch/um/kernel/syscall.c                |  2 +-
 arch/x86/ia32/sys_ia32.c                |  2 +-
 arch/x86/kernel/sys_x86_64.c            |  2 +-
 include/linux/syscalls.h                |  3 +++
 mm/mmap.c                               | 17 ++++++++++++-----
 mm/nommu.c                              | 17 ++++++++++++-----
 21 files changed, 60 insertions(+), 41 deletions(-)

diff --git a/arch/alpha/kernel/osf_sys.c b/arch/alpha/kernel/osf_sys.c
index fa1a392ca9a2..89faa6f4de47 100644
--- a/arch/alpha/kernel/osf_sys.c
+++ b/arch/alpha/kernel/osf_sys.c
@@ -189,7 +189,7 @@ SYSCALL_DEFINE6(osf_mmap, unsigned long, addr, unsigned long, len,
 		goto out;
 	if (off & ~PAGE_MASK)
 		goto out;
-	ret = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	ret = ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
  out:
 	return ret;
 }
diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
index 26fe8ea93ea2..72981bae10eb 100644
--- a/arch/arm64/kernel/sys.c
+++ b/arch/arm64/kernel/sys.c
@@ -34,7 +34,7 @@ asmlinkage long sys_mmap(unsigned long addr, unsigned long len,
 	if (offset_in_page(off) != 0)
 		return -EINVAL;
 
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 }
 
 SYSCALL_DEFINE1(arm64_personality, unsigned int, personality)
diff --git a/arch/ia64/kernel/sys_ia64.c b/arch/ia64/kernel/sys_ia64.c
index 085adfcc74a4..9ebe1d633abc 100644
--- a/arch/ia64/kernel/sys_ia64.c
+++ b/arch/ia64/kernel/sys_ia64.c
@@ -139,7 +139,7 @@ int ia64_mmap_check(unsigned long addr, unsigned long len,
 asmlinkage unsigned long
 sys_mmap2 (unsigned long addr, unsigned long len, int prot, int flags, int fd, long pgoff)
 {
-	addr = sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+	addr = ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
 	if (!IS_ERR((void *) addr))
 		force_successful_syscall_return();
 	return addr;
@@ -151,7 +151,7 @@ sys_mmap (unsigned long addr, unsigned long len, int prot, int flags, int fd, lo
 	if (offset_in_page(off) != 0)
 		return -EINVAL;
 
-	addr = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	addr = ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 	if (!IS_ERR((void *) addr))
 		force_successful_syscall_return();
 	return addr;
diff --git a/arch/m68k/kernel/sys_m68k.c b/arch/m68k/kernel/sys_m68k.c
index 27e10af5153a..6363ec83a290 100644
--- a/arch/m68k/kernel/sys_m68k.c
+++ b/arch/m68k/kernel/sys_m68k.c
@@ -46,7 +46,7 @@ asmlinkage long sys_mmap2(unsigned long addr, unsigned long len,
 	 * so we need to shift the argument down by 1; m68k mmap64(3)
 	 * (in libc) expects the last argument of mmap2 in 4Kb units.
 	 */
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
 }
 
 /* Convert virtual (user) address VADDR to physical address PADDR */
diff --git a/arch/microblaze/kernel/sys_microblaze.c b/arch/microblaze/kernel/sys_microblaze.c
index f1e1f666ddde..ed9f34da1a2a 100644
--- a/arch/microblaze/kernel/sys_microblaze.c
+++ b/arch/microblaze/kernel/sys_microblaze.c
@@ -40,7 +40,7 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 	if (pgoff & ~PAGE_MASK)
 		return -EINVAL;
 
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff >> PAGE_SHIFT);
 }
 
 SYSCALL_DEFINE6(mmap2, unsigned long, addr, unsigned long, len,
@@ -50,6 +50,6 @@ SYSCALL_DEFINE6(mmap2, unsigned long, addr, unsigned long, len,
 	if (pgoff & (~PAGE_MASK >> 12))
 		return -EINVAL;
 
-	return sys_mmap_pgoff(addr, len, prot, flags, fd,
-			      pgoff >> (PAGE_SHIFT - 12));
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       pgoff >> (PAGE_SHIFT - 12));
 }
diff --git a/arch/mips/kernel/linux32.c b/arch/mips/kernel/linux32.c
index 1c5785e72db4..0571ab7b68b0 100644
--- a/arch/mips/kernel/linux32.c
+++ b/arch/mips/kernel/linux32.c
@@ -67,8 +67,8 @@ SYSCALL_DEFINE6(32_mmap2, unsigned long, addr, unsigned long, len,
 {
 	if (pgoff & (~PAGE_MASK >> 12))
 		return -EINVAL;
-	return sys_mmap_pgoff(addr, len, prot, flags, fd,
-			      pgoff >> (PAGE_SHIFT-12));
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       pgoff >> (PAGE_SHIFT-12));
 }
 
 #define RLIM_INFINITY32 0x7fffffff
diff --git a/arch/mips/kernel/syscall.c b/arch/mips/kernel/syscall.c
index 58c6f634b550..69c17b549fd3 100644
--- a/arch/mips/kernel/syscall.c
+++ b/arch/mips/kernel/syscall.c
@@ -63,7 +63,8 @@ SYSCALL_DEFINE6(mips_mmap, unsigned long, addr, unsigned long, len,
 {
 	if (offset & ~PAGE_MASK)
 		return -EINVAL;
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, offset >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       offset >> PAGE_SHIFT);
 }
 
 SYSCALL_DEFINE6(mips_mmap2, unsigned long, addr, unsigned long, len,
@@ -73,7 +74,8 @@ SYSCALL_DEFINE6(mips_mmap2, unsigned long, addr, unsigned long, len,
 	if (pgoff & (~PAGE_MASK >> 12))
 		return -EINVAL;
 
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff >> (PAGE_SHIFT-12));
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       pgoff >> (PAGE_SHIFT - 12));
 }
 
 save_static_function(sys_fork);
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index f36ab1f09595..080d566654ea 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -270,8 +270,8 @@ asmlinkage unsigned long sys_mmap2(unsigned long addr, unsigned long len,
 {
 	/* Make sure the shift for mmap2 is constant (12), no matter what PAGE_SIZE
 	   we have. */
-	return sys_mmap_pgoff(addr, len, prot, flags, fd,
-			      pgoff >> (PAGE_SHIFT - 12));
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       pgoff >> (PAGE_SHIFT - 12));
 }
 
 asmlinkage unsigned long sys_mmap(unsigned long addr, unsigned long len,
@@ -279,7 +279,7 @@ asmlinkage unsigned long sys_mmap(unsigned long addr, unsigned long len,
 		unsigned long offset)
 {
 	if (!(offset & ~PAGE_MASK)) {
-		return sys_mmap_pgoff(addr, len, prot, flags, fd,
+		return ksys_mmap_pgoff(addr, len, prot, flags, fd,
 					offset >> PAGE_SHIFT);
 	} else {
 		return -EINVAL;
diff --git a/arch/powerpc/kernel/syscalls.c b/arch/powerpc/kernel/syscalls.c
index ecb981eea74b..1ef3b80b62a6 100644
--- a/arch/powerpc/kernel/syscalls.c
+++ b/arch/powerpc/kernel/syscalls.c
@@ -57,7 +57,7 @@ static inline long do_mmap2(unsigned long addr, size_t len,
 		off >>= shift;
 	}
 
-	ret = sys_mmap_pgoff(addr, len, prot, flags, fd, off);
+	ret = ksys_mmap_pgoff(addr, len, prot, flags, fd, off);
 out:
 	return ret;
 }
diff --git a/arch/riscv/kernel/sys_riscv.c b/arch/riscv/kernel/sys_riscv.c
index 79c78668258e..f7181ed8aafc 100644
--- a/arch/riscv/kernel/sys_riscv.c
+++ b/arch/riscv/kernel/sys_riscv.c
@@ -24,8 +24,8 @@ static long riscv_sys_mmap(unsigned long addr, unsigned long len,
 {
 	if (unlikely(offset & (~PAGE_MASK >> page_shift_offset)))
 		return -EINVAL;
-	return sys_mmap_pgoff(addr, len, prot, flags, fd,
-			      offset >> (PAGE_SHIFT - page_shift_offset));
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       offset >> (PAGE_SHIFT - page_shift_offset));
 }
 
 #ifdef CONFIG_64BIT
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 9bb897e443a6..da5ef7718254 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -442,8 +442,8 @@ COMPAT_SYSCALL_DEFINE1(s390_old_mmap, struct mmap_arg_struct_emu31 __user *, arg
 		return -EFAULT;
 	if (a.offset & ~PAGE_MASK)
 		return -EINVAL;
-	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
-			      a.offset >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
+			       a.offset >> PAGE_SHIFT);
 }
 
 COMPAT_SYSCALL_DEFINE1(s390_mmap2, struct mmap_arg_struct_emu31 __user *, arg)
@@ -452,7 +452,7 @@ COMPAT_SYSCALL_DEFINE1(s390_mmap2, struct mmap_arg_struct_emu31 __user *, arg)
 
 	if (copy_from_user(&a, arg, sizeof(a)))
 		return -EFAULT;
-	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd, a.offset);
+	return ksys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd, a.offset);
 }
 
 COMPAT_SYSCALL_DEFINE3(s390_read, unsigned int, fd, char __user *, buf, compat_size_t, count)
diff --git a/arch/s390/kernel/sys_s390.c b/arch/s390/kernel/sys_s390.c
index 0090037ab148..31cefe0c28c0 100644
--- a/arch/s390/kernel/sys_s390.c
+++ b/arch/s390/kernel/sys_s390.c
@@ -53,7 +53,7 @@ SYSCALL_DEFINE1(mmap2, struct s390_mmap_arg_struct __user *, arg)
 
 	if (copy_from_user(&a, arg, sizeof(a)))
 		goto out;
-	error = sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd, a.offset);
+	error = ksys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd, a.offset);
 out:
 	return error;
 }
diff --git a/arch/sh/kernel/sys_sh.c b/arch/sh/kernel/sys_sh.c
index 724911c59e7d..f8afc014e084 100644
--- a/arch/sh/kernel/sys_sh.c
+++ b/arch/sh/kernel/sys_sh.c
@@ -35,7 +35,7 @@ asmlinkage int old_mmap(unsigned long addr, unsigned long len,
 {
 	if (off & ~PAGE_MASK)
 		return -EINVAL;
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, off>>PAGE_SHIFT);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, off>>PAGE_SHIFT);
 }
 
 asmlinkage long sys_mmap2(unsigned long addr, unsigned long len,
@@ -51,7 +51,7 @@ asmlinkage long sys_mmap2(unsigned long addr, unsigned long len,
 
 	pgoff >>= PAGE_SHIFT - 12;
 
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
 }
 
 /* sys_cacheflush -- flush (part of) the processor cache.  */
diff --git a/arch/sparc/kernel/sys_sparc_32.c b/arch/sparc/kernel/sys_sparc_32.c
index 990703b7cf4d..d980da4ffd7b 100644
--- a/arch/sparc/kernel/sys_sparc_32.c
+++ b/arch/sparc/kernel/sys_sparc_32.c
@@ -104,8 +104,8 @@ asmlinkage long sys_mmap2(unsigned long addr, unsigned long len,
 {
 	/* Make sure the shift for mmap2 is constant (12), no matter what PAGE_SIZE
 	   we have. */
-	return sys_mmap_pgoff(addr, len, prot, flags, fd,
-			      pgoff >> (PAGE_SHIFT - 12));
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd,
+			       pgoff >> (PAGE_SHIFT - 12));
 }
 
 asmlinkage long sys_mmap(unsigned long addr, unsigned long len,
@@ -113,7 +113,7 @@ asmlinkage long sys_mmap(unsigned long addr, unsigned long len,
 	unsigned long off)
 {
 	/* no alignment check? */
-	return sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 }
 
 long sparc_remap_file_pages(unsigned long start, unsigned long size,
diff --git a/arch/sparc/kernel/sys_sparc_64.c b/arch/sparc/kernel/sys_sparc_64.c
index 55416db482ad..ebb84dc8a5a7 100644
--- a/arch/sparc/kernel/sys_sparc_64.c
+++ b/arch/sparc/kernel/sys_sparc_64.c
@@ -458,7 +458,7 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 		goto out;
 	if (off & ~PAGE_MASK)
 		goto out;
-	retval = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	retval = ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 out:
 	return retval;
 }
diff --git a/arch/um/kernel/syscall.c b/arch/um/kernel/syscall.c
index 6258676bed85..35f7047bdebc 100644
--- a/arch/um/kernel/syscall.c
+++ b/arch/um/kernel/syscall.c
@@ -22,7 +22,7 @@ long old_mmap(unsigned long addr, unsigned long len,
 	if (offset & ~PAGE_MASK)
 		goto out;
 
-	err = sys_mmap_pgoff(addr, len, prot, flags, fd, offset >> PAGE_SHIFT);
+	err = ksys_mmap_pgoff(addr, len, prot, flags, fd, offset >> PAGE_SHIFT);
  out:
 	return err;
 }
diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index 401bd8ec9cf0..bff71b9ae3f5 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -166,7 +166,7 @@ COMPAT_SYSCALL_DEFINE1(x86_mmap, struct mmap_arg_struct32 __user *, arg)
 	if (a.offset & ~PAGE_MASK)
 		return -EINVAL;
 
-	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
+	return ksys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
 			       a.offset>>PAGE_SHIFT);
 }
 
diff --git a/arch/x86/kernel/sys_x86_64.c b/arch/x86/kernel/sys_x86_64.c
index 676774b9bb8d..a3f15ed545b5 100644
--- a/arch/x86/kernel/sys_x86_64.c
+++ b/arch/x86/kernel/sys_x86_64.c
@@ -97,7 +97,7 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 	if (off & ~PAGE_MASK)
 		goto out;
 
-	error = sys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
+	error = ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 out:
 	return error;
 }
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 466d408deefd..ec866c959e7d 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -979,6 +979,9 @@ static inline int ksys_fadvise64_64(int fd, loff_t offset, loff_t len,
 	return -EINVAL;
 }
 #endif
+unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
+			      unsigned long prot, unsigned long flags,
+			      unsigned long fd, unsigned long pgoff);
 
 /*
  * The following kernel syscall equivalents are just wrappers to fs-internal
diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021ad22..aa0dc8231c0d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1488,9 +1488,9 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 	return addr;
 }
 
-SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
-		unsigned long, prot, unsigned long, flags,
-		unsigned long, fd, unsigned long, pgoff)
+unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
+			      unsigned long prot, unsigned long flags,
+			      unsigned long fd, unsigned long pgoff)
 {
 	struct file *file = NULL;
 	unsigned long retval;
@@ -1537,6 +1537,13 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 	return retval;
 }
 
+SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
+		unsigned long, prot, unsigned long, flags,
+		unsigned long, fd, unsigned long, pgoff)
+{
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+}
+
 #ifdef __ARCH_WANT_SYS_OLD_MMAP
 struct mmap_arg_struct {
 	unsigned long addr;
@@ -1556,8 +1563,8 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
 	if (offset_in_page(a.offset))
 		return -EINVAL;
 
-	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
-			      a.offset >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
+			       a.offset >> PAGE_SHIFT);
 }
 #endif /* __ARCH_WANT_SYS_OLD_MMAP */
 
diff --git a/mm/nommu.c b/mm/nommu.c
index ebb6e618dade..cad329629530 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1423,9 +1423,9 @@ unsigned long do_mmap(struct file *file,
 	return -ENOMEM;
 }
 
-SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
-		unsigned long, prot, unsigned long, flags,
-		unsigned long, fd, unsigned long, pgoff)
+unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
+			      unsigned long prot, unsigned long flags,
+			      unsigned long fd, unsigned long pgoff)
 {
 	struct file *file = NULL;
 	unsigned long retval = -EBADF;
@@ -1447,6 +1447,13 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 	return retval;
 }
 
+SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
+		unsigned long, prot, unsigned long, flags,
+		unsigned long, fd, unsigned long, pgoff)
+{
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+}
+
 #ifdef __ARCH_WANT_SYS_OLD_MMAP
 struct mmap_arg_struct {
 	unsigned long addr;
@@ -1466,8 +1473,8 @@ SYSCALL_DEFINE1(old_mmap, struct mmap_arg_struct __user *, arg)
 	if (offset_in_page(a.offset))
 		return -EINVAL;
 
-	return sys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
-			      a.offset >> PAGE_SHIFT);
+	return ksys_mmap_pgoff(a.addr, a.len, a.prot, a.flags, a.fd,
+			       a.offset >> PAGE_SHIFT);
 }
 #endif /* __ARCH_WANT_SYS_OLD_MMAP */
 
-- 
2.16.3
