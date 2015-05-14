Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f173.google.com (mail-qk0-f173.google.com [209.85.220.173])
	by kanga.kvack.org (Postfix) with ESMTP id 6C60A6B0073
	for <linux-mm@kvack.org>; Thu, 14 May 2015 13:31:31 -0400 (EDT)
Received: by qkgw4 with SMTP id w4so13794567qkg.3
        for <linux-mm@kvack.org>; Thu, 14 May 2015 10:31:31 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q78si1305901qgq.84.2015.05.14.10.31.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 May 2015 10:31:28 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 19/23] userfaultfd: activate syscall
Date: Thu, 14 May 2015 19:31:16 +0200
Message-Id: <1431624680-20153-20-git-send-email-aarcange@redhat.com>
In-Reply-To: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
References: <1431624680-20153-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, qemu-devel@nongnu.org, kvm@vger.kernel.org, linux-api@vger.kernel.org
Cc: Pavel Emelyanov <xemul@parallels.com>, Sanidhya Kashyap <sanidhya.gatech@gmail.com>, zhang.zhanghailiang@huawei.com, Linus Torvalds <torvalds@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Andres Lagar-Cavilla <andreslc@google.com>, Dave Hansen <dave.hansen@intel.com>, Paolo Bonzini <pbonzini@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Andy Lutomirski <luto@amacapital.net>, Hugh Dickins <hughd@google.com>, Peter Feiner <pfeiner@google.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, "Huangpeng (Peter)" <peter.huangpeng@huawei.com>

This activates the userfaultfd syscall.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/powerpc/include/asm/systbl.h      | 1 +
 arch/powerpc/include/uapi/asm/unistd.h | 1 +
 arch/x86/syscalls/syscall_32.tbl       | 1 +
 arch/x86/syscalls/syscall_64.tbl       | 1 +
 include/linux/syscalls.h               | 1 +
 kernel/sys_ni.c                        | 1 +
 6 files changed, 6 insertions(+)

diff --git a/arch/powerpc/include/asm/systbl.h b/arch/powerpc/include/asm/systbl.h
index f1863a1..4741b15 100644
--- a/arch/powerpc/include/asm/systbl.h
+++ b/arch/powerpc/include/asm/systbl.h
@@ -368,3 +368,4 @@ SYSCALL_SPU(memfd_create)
 SYSCALL_SPU(bpf)
 COMPAT_SYS(execveat)
 PPC64ONLY(switch_endian)
+SYSCALL_SPU(userfaultfd)
diff --git a/arch/powerpc/include/uapi/asm/unistd.h b/arch/powerpc/include/uapi/asm/unistd.h
index e4aa173..6ad58d4 100644
--- a/arch/powerpc/include/uapi/asm/unistd.h
+++ b/arch/powerpc/include/uapi/asm/unistd.h
@@ -386,5 +386,6 @@
 #define __NR_bpf		361
 #define __NR_execveat		362
 #define __NR_switch_endian	363
+#define __NR_userfaultfd	364
 
 #endif /* _UAPI_ASM_POWERPC_UNISTD_H_ */
diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index ef8187f..dcc18ea 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -365,3 +365,4 @@
 356	i386	memfd_create		sys_memfd_create
 357	i386	bpf			sys_bpf
 358	i386	execveat		sys_execveat			stub32_execveat
+359	i386	userfaultfd		sys_userfaultfd
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 9ef32d5..81c4906 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -329,6 +329,7 @@
 320	common	kexec_file_load		sys_kexec_file_load
 321	common	bpf			sys_bpf
 322	64	execveat		stub_execveat
+323	common	userfaultfd		sys_userfaultfd
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index bb51bec..8ee1d0c 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -810,6 +810,7 @@ asmlinkage long sys_timerfd_gettime(int ufd, struct itimerspec __user *otmr);
 asmlinkage long sys_eventfd(unsigned int count);
 asmlinkage long sys_eventfd2(unsigned int count, int flags);
 asmlinkage long sys_memfd_create(const char __user *uname_ptr, unsigned int flags);
+asmlinkage long sys_userfaultfd(int flags);
 asmlinkage long sys_fallocate(int fd, int mode, loff_t offset, loff_t len);
 asmlinkage long sys_old_readdir(unsigned int, struct old_linux_dirent __user *, unsigned int);
 asmlinkage long sys_pselect6(int, fd_set __user *, fd_set __user *,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 7995ef5..8b3e10ea 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -218,6 +218,7 @@ cond_syscall(compat_sys_timerfd_gettime);
 cond_syscall(sys_eventfd);
 cond_syscall(sys_eventfd2);
 cond_syscall(sys_memfd_create);
+cond_syscall(sys_userfaultfd);
 
 /* performance counters: */
 cond_syscall(sys_perf_event_open);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
