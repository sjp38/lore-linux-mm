Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id F08BB6B0005
	for <linux-mm@kvack.org>; Thu, 29 Mar 2018 07:26:03 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w59so2540379wrb.8
        for <linux-mm@kvack.org>; Thu, 29 Mar 2018 04:26:03 -0700 (PDT)
Received: from isilmar-4.linta.de (isilmar-4.linta.de. [136.243.71.142])
        by mx.google.com with ESMTPS id 140si1263352wmi.146.2018.03.29.04.26.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Mar 2018 04:26:02 -0700 (PDT)
From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: [PATCH 098/109] mm: add ksys_readahead() helper; remove in-kernel calls to sys_readahead()
Date: Thu, 29 Mar 2018 13:24:15 +0200
Message-Id: <20180329112426.23043-99-linux@dominikbrodowski.net>
In-Reply-To: <20180329112426.23043-1-linux@dominikbrodowski.net>
References: <20180329112426.23043-1-linux@dominikbrodowski.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: viro@ZenIV.linux.org.uk, torvalds@linux-foundation.org, arnd@arndb.de, linux-arch@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

Using this helper allows us to avoid the in-kernel calls to the
sys_readahead() syscall. The ksys_ prefix denotes that this function is
meant as a drop-in replacement for the syscall. In particular, it uses the
same calling convention as sys_readahead().

This patch is part of a series which removes in-kernel calls to syscalls.
On this basis, the syscall entry path can be streamlined. For details, see
http://lkml.kernel.org/r/20180325162527.GA17492@light.dominikbrodowski.net

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Dominik Brodowski <linux@dominikbrodowski.net>
---
 arch/mips/kernel/linux32.c      | 2 +-
 arch/parisc/kernel/sys_parisc.c | 2 +-
 arch/powerpc/kernel/sys_ppc32.c | 2 +-
 arch/s390/kernel/compat_linux.c | 2 +-
 arch/sparc/kernel/sys_sparc32.c | 2 +-
 arch/x86/ia32/sys_ia32.c        | 2 +-
 include/linux/syscalls.h        | 1 +
 mm/readahead.c                  | 7 ++++++-
 8 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/arch/mips/kernel/linux32.c b/arch/mips/kernel/linux32.c
index 0571ab7b68b0..318f1c05c5b3 100644
--- a/arch/mips/kernel/linux32.c
+++ b/arch/mips/kernel/linux32.c
@@ -131,7 +131,7 @@ SYSCALL_DEFINE1(32_personality, unsigned long, personality)
 asmlinkage ssize_t sys32_readahead(int fd, u32 pad0, u64 a2, u64 a3,
 				   size_t count)
 {
-	return sys_readahead(fd, merge_64(a2, a3), count);
+	return ksys_readahead(fd, merge_64(a2, a3), count);
 }
 
 asmlinkage long sys32_sync_file_range(int fd, int __pad,
diff --git a/arch/parisc/kernel/sys_parisc.c b/arch/parisc/kernel/sys_parisc.c
index 080d566654ea..8c99ebbe2bac 100644
--- a/arch/parisc/kernel/sys_parisc.c
+++ b/arch/parisc/kernel/sys_parisc.c
@@ -345,7 +345,7 @@ asmlinkage ssize_t parisc_pwrite64(unsigned int fd, const char __user *buf,
 asmlinkage ssize_t parisc_readahead(int fd, unsigned int high, unsigned int low,
 		                    size_t count)
 {
-	return sys_readahead(fd, (loff_t)high << 32 | low, count);
+	return ksys_readahead(fd, (loff_t)high << 32 | low, count);
 }
 
 asmlinkage long parisc_fadvise64_64(int fd,
diff --git a/arch/powerpc/kernel/sys_ppc32.c b/arch/powerpc/kernel/sys_ppc32.c
index 0b95fa13307f..c11c73373691 100644
--- a/arch/powerpc/kernel/sys_ppc32.c
+++ b/arch/powerpc/kernel/sys_ppc32.c
@@ -88,7 +88,7 @@ compat_ssize_t compat_sys_pwrite64(unsigned int fd, const char __user *ubuf, com
 
 compat_ssize_t compat_sys_readahead(int fd, u32 r4, u32 offhi, u32 offlo, u32 count)
 {
-	return sys_readahead(fd, ((loff_t)offhi << 32) | offlo, count);
+	return ksys_readahead(fd, ((loff_t)offhi << 32) | offlo, count);
 }
 
 asmlinkage int compat_sys_truncate64(const char __user * path, u32 reg4,
diff --git a/arch/s390/kernel/compat_linux.c b/arch/s390/kernel/compat_linux.c
index da5ef7718254..8ac38d51ed7d 100644
--- a/arch/s390/kernel/compat_linux.c
+++ b/arch/s390/kernel/compat_linux.c
@@ -328,7 +328,7 @@ COMPAT_SYSCALL_DEFINE5(s390_pwrite64, unsigned int, fd, const char __user *, ubu
 
 COMPAT_SYSCALL_DEFINE4(s390_readahead, int, fd, u32, high, u32, low, s32, count)
 {
-	return sys_readahead(fd, (unsigned long)high << 32 | low, count);
+	return ksys_readahead(fd, (unsigned long)high << 32 | low, count);
 }
 
 struct stat64_emu31 {
diff --git a/arch/sparc/kernel/sys_sparc32.c b/arch/sparc/kernel/sys_sparc32.c
index 4da66aed50b4..f166e5bbf506 100644
--- a/arch/sparc/kernel/sys_sparc32.c
+++ b/arch/sparc/kernel/sys_sparc32.c
@@ -217,7 +217,7 @@ asmlinkage long compat_sys_readahead(int fd,
 				     unsigned long offlo,
 				     compat_size_t count)
 {
-	return sys_readahead(fd, (offhi << 32) | offlo, count);
+	return ksys_readahead(fd, (offhi << 32) | offlo, count);
 }
 
 long compat_sys_fadvise64(int fd,
diff --git a/arch/x86/ia32/sys_ia32.c b/arch/x86/ia32/sys_ia32.c
index bff71b9ae3f5..bd8a7020b9a7 100644
--- a/arch/x86/ia32/sys_ia32.c
+++ b/arch/x86/ia32/sys_ia32.c
@@ -203,7 +203,7 @@ COMPAT_SYSCALL_DEFINE6(x86_fadvise64_64, int, fd, __u32, offset_low,
 COMPAT_SYSCALL_DEFINE4(x86_readahead, int, fd, unsigned int, off_lo,
 		       unsigned int, off_hi, size_t, count)
 {
-	return sys_readahead(fd, ((u64)off_hi << 32) | off_lo, count);
+	return ksys_readahead(fd, ((u64)off_hi << 32) | off_lo, count);
 }
 
 COMPAT_SYSCALL_DEFINE6(x86_sync_file_range, int, fd, unsigned int, off_low,
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index ec866c959e7d..815fbdd9cca1 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -982,6 +982,7 @@ static inline int ksys_fadvise64_64(int fd, loff_t offset, loff_t len,
 unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
 			      unsigned long prot, unsigned long flags,
 			      unsigned long fd, unsigned long pgoff);
+ssize_t ksys_readahead(int fd, loff_t offset, size_t count);
 
 /*
  * The following kernel syscall equivalents are just wrappers to fs-internal
diff --git a/mm/readahead.c b/mm/readahead.c
index c4ca70239233..4d57b4644f98 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -573,7 +573,7 @@ do_readahead(struct address_space *mapping, struct file *filp,
 	return force_page_cache_readahead(mapping, filp, index, nr);
 }
 
-SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
+ssize_t ksys_readahead(int fd, loff_t offset, size_t count)
 {
 	ssize_t ret;
 	struct fd f;
@@ -592,3 +592,8 @@ SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
 	}
 	return ret;
 }
+
+SYSCALL_DEFINE3(readahead, int, fd, loff_t, offset, size_t, count)
+{
+	return ksys_readahead(fd, offset, count);
+}
-- 
2.16.3
