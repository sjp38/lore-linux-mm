Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 726EC6B0007
	for <linux-mm@kvack.org>; Thu, 15 Mar 2018 15:06:21 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p13so2923762wmc.6
        for <linux-mm@kvack.org>; Thu, 15 Mar 2018 12:06:21 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id l8si2890882wmd.7.2018.03.15.12.06.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Mar 2018 12:06:19 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH v2 20/36] mm: add ksys_fadvise64_64() helper; remove in-kernel call to sys_fadvise64_64()
Date: Thu, 15 Mar 2018 20:05:13 +0100
Message-Id: <20180315190529.20943-21-linux@dominikbrodowski.net>
In-Reply-To: <20180315190529.20943-1-linux@dominikbrodowski.net>
References: <20180315190529.20943-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, viro@zeniv.linux.org.uk
Cc: luto@kernel.org, mingo@kernel.org, akpm@linux-foundation.org, arnd@arndb.de, linux-mm@kvack.org

Using the ksys_fadvise64_64() helper allows us to avoid the in-kernel
calls to the sys_fadvise64_64() syscall.

Some compat stubs called sys_fadvise64(), which then just passed
through the arguments to sys_fadvise64_64(). Get rid of this
indirection, and call ksys_fadvise64_64() directly.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 arch/arm/kernel/sys_arm.c       |  2 +-
 arch/mips/kernel/linux32.c      |  2 +-
 arch/parisc/kernel/sys_parisc.c |  2 +-
 arch/powerpc/kernel/sys_ppc32.c |  4 ++--
 arch/powerpc/kernel/syscalls.c  |  4 ++--
 arch/s390/kernel/compat_linux.c |  5 +++--
 arch/sh/kernel/sys_sh32.c       |  8 ++++----
 arch/sparc/kernel/sys_sparc32.c | 10 +++++-----
 arch/x86/ia32/sys_ia32.c        | 12 ++++++------
 arch/xtensa/kernel/syscall.c    |  2 +-
 include/linux/syscalls.h        |  9 +++++++++
 mm/fadvise.c                    | 10 ++++++++--
 12 files changed, 43 insertions(+), 27 deletions(-)

diff --git a/arch/arm/kernel/sys_arm.c b/arch/arm/kernel/sys_arm.c
index 3151f5623d0e..bdf7514204ab 100644
--- a/arch/arm/kernel/sys_arm.c
+++ b/arch/arm/kernel/sys_arm.c
@@ -35,5 +35,5 @@
 asmlinkage long sys_arm_fadvise64_64(int fd, int advice,
 				     loff_t offset, loff_t len)
 {
-	return sys_fadvise64_64(fd, offset, len, advice);
+	return ksys_fadvise64_64(fd, offset, len, advice);
 }
diff --git a/arch/mips/kernel/linux32.c b/arch/mips/kernel/linux32.c
index b332f6fc1e72..b8a3cf5d5950 100644
--- a/arch/mips/kernel/linux32.c
+++ b/arch/mips/kernel/linux32.c
@@ -149,7 +149,7 @@ asmlinkage long sys32_fadvise64_64(int fd, int __pad,
 	unsigned long a4, unsigned long a5,
 	int flags)
 {
-	return sys_fadvise64_64(fd,
+	return ksys_fadvise64_64(fd,
 			merge_64(a2, a3), merge_64(a4, a5),
 			flags);
 }
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index 378a754ca186..da1c27ea8e1a 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -352,7 +352,7 @@ asmlinkage long parisc_fadvise64_64(int fd,
 			unsigned int high_off, unsigned int low_off,
 			unsigned int high_len, unsigned int low_len, int advice)
 {
-	return sys_fadvise64_64(fd, (loff_t)high_off << 32 | low_off,
+	return ksys_fadvise64_64(fd, (loff_t)high_off << 32 | low_off,
 			(loff_t)high_len << 32 | low_len, advice);
 }
 
diff --git a/arch/powerpc/kernel/sys_ppc32.c b/arch/powerpc/kernel/sys_ppc32.c
index 15f216d022e2..93df264ab76c 100644
--- a/arch/powerpc/kernel/sys_ppc32.c
+++ b/arch/powerpc/kernel/sys_ppc32.c
@@ -113,8 +113,8 @@ asmlinkage int compat_sys_ftruncate64(unsigned int fd, u32 reg4, unsigned long h
 long ppc32_fadvise64(int fd, u32 unused, u32 offset_high, u32 offset_low,
 		     size_t len, int advice)
 {
-	return sys_fadvise64(fd, (u64)offset_high << 32 | offset_low, len,
-			     advice);
+	return ksys_fadvise64_64(fd, (u64)offset_high << 32 | offset_low, len,
+				 advice);
 }
 
 asmlinkage long compat_sys_sync_file_range2(int fd, unsigned int flags,
diff --git a/arch/powerpc/kernel/syscalls.c b/arch/powerpc/kernel/syscalls.c
index a877bf8269fe..ecb981eea74b 100644
--- a/arch/powerpc/kernel/syscalls.c
+++ b/arch/powerpc/kernel/syscalls.c
@@ -119,8 +119,8 @@ long ppc64_personality(unsigned long personality)
 long ppc_fadvise64_64(int fd, int advice, u32 offset_high, u32 offset_low,
 		      u32 len_high, u32 len_low)
 {
-	return sys_fadvise64(fd, (u64)offset_high << 32 | offset_low,
-			     (u64)len_high << 32 | len_low, advice);
+	return ksys_fadvise64_64(fd, (u64)offset_high << 32 | offset_low,
+				 (u64)len_high << 32 | len_low, advice);
 }
 
 long sys_switch_endian(void)
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index 5a9cfde5fc28..357a66934a98 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -483,7 +483,8 @@ COMPAT_SYSCALL_DEFINE5(s390_fadvise64, int, fd, u32, high, u32, low, compat_size
 		advise = POSIX_FADV_DONTNEED;
 	else if (advise == 5)
 		advise = POSIX_FADV_NOREUSE;
-	return sys_fadvise64(fd, (unsigned long)high << 32 | low, len, advise);
+	return ksys_fadvise64_64(fd, (unsigned long)high << 32 | low, len,
+				 advise);
 }
 
 struct fadvise64_64_args {
@@ -503,7 +504,7 @@ COMPAT_SYSCALL_DEFINE1(s390_fadvise64_64, struct fadvise64_64_args __user *, arg
 		a.advice = POSIX_FADV_DONTNEED;
 	else if (a.advice == 5)
 		a.advice = POSIX_FADV_NOREUSE;
-	return sys_fadvise64_64(a.fd, a.offset, a.len, a.advice);
+	return ksys_fadvise64_64(a.fd, a.offset, a.len, a.advice);
 }
 
 COMPAT_SYSCALL_DEFINE6(s390_sync_file_range, int, fd, u32, offhigh, u32, offlow,
diff --git a/arch/sh/kernel/sys_sh32.c b/arch/sh/kernel/sys_sh32.c
index f8dc8bfd4606..4d55318e0899 100644
--- a/arch/sh/kernel/sys_sh32.c
+++ b/arch/sh/kernel/sys_sh32.c
@@ -52,10 +52,10 @@ asmlinkage int sys_fadvise64_64_wrapper(int fd, u32 offset0, u32 offset1,
 				u32 len0, u32 len1, int advice)
 {
 #ifdef  __LITTLE_ENDIAN__
-	return sys_fadvise64_64(fd, (u64)offset1 << 32 | offset0,
-				(u64)len1 << 32 | len0,	advice);
+	return ksys_fadvise64_64(fd, (u64)offset1 << 32 | offset0,
+				 (u64)len1 << 32 | len0, advice);
 #else
-	return sys_fadvise64_64(fd, (u64)offset0 << 32 | offset1,
-				(u64)len0 << 32 | len1,	advice);
+	return ksys_fadvise64_64(fd, (u64)offset0 << 32 | offset1,
+				 (u64)len0 << 32 | len1, advice);
 #endif
 }
diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
index 6d964bdefbaa..08261bc15d30 100644
--- a/arch/sparc/kernel/sys_sparc32.c
+++ b/arch/sparc/kernel/sys_sparc32.c
@@ -225,7 +225,7 @@ long compat_sys_fadvise64(int fd,
 			  unsigned long offlo,
 			  compat_size_t len, int advice)
 {
-	return sys_fadvise64_64(fd, (offhi << 32) | offlo, len, advice);
+	return ksys_fadvise64_64(fd, (offhi << 32) | offlo, len, advice);
 }
 
 long compat_sys_fadvise64_64(int fd,
@@ -233,10 +233,10 @@ long compat_sys_fadvise64_64(int fd,
 			     unsigned long lenhi, unsigned long lenlo,
 			     int advice)
 {
-	return sys_fadvise64_64(fd,
-				(offhi << 32) | offlo,
-				(lenhi << 32) | lenlo,
-				advice);
+	return ksys_fadvise64_64(fd,
+				 (offhi << 32) | offlo,
+				 (lenhi << 32) | lenlo,
+				 advice);
 }
 
 long sys32_sync_file_range(unsigned int fd, unsigned long off_high, unsigned long off_low, unsigned long nb_high, unsigned long nb_low, unsigned int flags)
diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index 6512498bbef6..2afd718e7422 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -198,10 +198,10 @@ COMPAT_SYSCALL_DEFINE6(x86_fadvise64_64, int, fd, __u32, offset_low,
 		       __u32, offset_high, __u32, len_low, __u32, len_high,
 		       int, advice)
 {
-	return sys_fadvise64_64(fd,
-			       (((u64)offset_high)<<32) | offset_low,
-			       (((u64)len_high)<<32) | len_low,
-				advice);
+	return ksys_fadvise64_64(fd,
+				 (((u64)offset_high)<<32) | offset_low,
+				 (((u64)len_high)<<32) | len_low,
+				 advice);
 }
 
 COMPAT_SYSCALL_DEFINE4(x86_readahead, int, fd, unsigned int, off_lo,
@@ -222,8 +222,8 @@ COMPAT_SYSCALL_DEFINE6(x86_sync_file_range, int, fd, unsigned int, off_low,
 COMPAT_SYSCALL_DEFINE5(x86_fadvise64, int, fd, unsigned int, offset_lo,
 		       unsigned int, offset_hi, size_t, len, int, advice)
 {
-	return sys_fadvise64_64(fd, ((u64)offset_hi << 32) | offset_lo,
-				len, advice);
+	return ksys_fadvise64_64(fd, ((u64)offset_hi << 32) | offset_lo,
+				 len, advice);
 }
 
 COMPAT_SYSCALL_DEFINE6(x86_fallocate, int, fd, int, mode,
diff --git a/arch/xtensa/kernel/syscall.c b/arch/xtensa/kernel/syscall.c
index 74afbf02d07e..8201748da05b 100644
--- a/arch/xtensa/kernel/syscall.c
+++ b/arch/xtensa/kernel/syscall.c
@@ -55,7 +55,7 @@ asmlinkage long xtensa_shmat(int shmid, char __user *shmaddr, int shmflg)
 asmlinkage long xtensa_fadvise64_64(int fd, int advice,
 		unsigned long long offset, unsigned long long len)
 {
-	return sys_fadvise64_64(fd, offset, len, advice);
+	return ksys_fadvise64_64(fd, offset, len, advice);
 }
 
 #ifdef CONFIG_MMU
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 2c0fabc7d19d..863ca7d6face 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -955,5 +955,14 @@ int ksys_dup(unsigned int fildes);
 int ksys_chroot(const char __user *filename);
 ssize_t ksys_write(unsigned int fd, const char __user *buf, size_t count);
 int ksys_unshare(unsigned long unshare_flags);
+#ifdef CONFIG_ADVISE_SYSCALLS
+int ksys_fadvise64_64(int fd, loff_t offset, loff_t len, int advice);
+#else
+static inline int ksys_fadvise64_64(int fd, loff_t offset, loff_t len,
+				    int advice)
+{
+	return -EINVAL;
+}
+#endif
 
 #endif
diff --git a/mm/fadvise.c b/mm/fadvise.c
index 767887f5f3bf..afa41491d324 100644
--- a/mm/fadvise.c
+++ b/mm/fadvise.c
@@ -26,7 +26,8 @@
  * POSIX_FADV_WILLNEED could set PG_Referenced, and POSIX_FADV_NOREUSE could
  * deactivate the pages and clear PG_Referenced.
  */
-SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
+
+int ksys_fadvise64_64(int fd, loff_t offset, loff_t len, int advice)
 {
 	struct fd f = fdget(fd);
 	struct inode *inode;
@@ -185,11 +186,16 @@ SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
 	return ret;
 }
 
+SYSCALL_DEFINE4(fadvise64_64, int, fd, loff_t, offset, loff_t, len, int, advice)
+{
+	return ksys_fadvise64_64(fd, offset, len, advice);
+}
+
 #ifdef __ARCH_WANT_SYS_FADVISE64
 
 SYSCALL_DEFINE4(fadvise64, int, fd, loff_t, offset, size_t, len, int, advice)
 {
-	return sys_fadvise64_64(fd, offset, len, advice);
+	return ksys_fadvise64_64(fd, offset, len, advice);
 }
 
 #endif
-- 
2.16.2
