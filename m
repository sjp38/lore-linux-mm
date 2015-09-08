Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3D1FC6B0257
	for <linux-mm@kvack.org>; Tue,  8 Sep 2015 09:59:08 -0400 (EDT)
Received: by qgt47 with SMTP id 47so82660985qgt.2
        for <linux-mm@kvack.org>; Tue, 08 Sep 2015 06:59:08 -0700 (PDT)
Received: from prod-mail-xrelay05.akamai.com ([23.79.238.179])
        by mx.google.com with ESMTP id f94si3843868qkf.43.2015.09.08.06.59.04
        for <linux-mm@kvack.org>;
        Tue, 08 Sep 2015 06:59:04 -0700 (PDT)
From: Eric B Munson <emunson@akamai.com>
Subject: [PATCH v9 2/6] mm: mlock: Add new mlock system call
Date: Tue,  8 Sep 2015 09:58:58 -0400
Message-Id: <1441720742-7803-3-git-send-email-emunson@akamai.com>
In-Reply-To: <1441720742-7803-1-git-send-email-emunson@akamai.com>
References: <1441720742-7803-1-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric B Munson <emunson@akamai.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Heiko Carstens <heiko.carstens@de.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Catalin Marinas <catalin.marinas@arm.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Guenter Roeck <linux@roeck-us.net>, linux-alpha@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, adi-buildroot-devel@lists.sourceforge.net, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, linux-m68k@lists.linux-m68k.org, linux-am33-list@redhat.com, linux-parisc@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org, linux-xtensa@linux-xtensa.org, linux-api@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org

With the refactored mlock code, introduce a new system call for mlock.
The new call will allow the user to specify what lock states are being
added.  mlock2 is trivial at the moment, but a follow on patch will add
a new mlock state making it useful.

Signed-off-by: Eric B Munson <emunson@akamai.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Michal Hocko <mhocko@suse.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Guenter Roeck <linux@roeck-us.net>
Cc: linux-alpha@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: linux-arm-kernel@lists.infradead.org
Cc: adi-buildroot-devel@lists.sourceforge.net
Cc: linux-cris-kernel@axis.com
Cc: linux-ia64@vger.kernel.org
Cc: linux-m68k@lists.linux-m68k.org
Cc: linux-am33-list@redhat.com
Cc: linux-parisc@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Cc: sparclinux@vger.kernel.org
Cc: linux-xtensa@linux-xtensa.org
Cc: linux-api@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm@kvack.org
---
Changes from V8:
* Update x86[_64] syscall numbers to follow the new userfaultfd syscalls

 arch/x86/entry/syscalls/syscall_32.tbl | 1 +
 arch/x86/entry/syscalls/syscall_64.tbl | 1 +
 include/linux/syscalls.h               | 2 ++
 include/uapi/asm-generic/unistd.h      | 4 +++-
 kernel/sys_ni.c                        | 1 +
 mm/mlock.c                             | 8 ++++++++
 6 files changed, 16 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 477bfa6..41e72a5 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -381,3 +381,4 @@
 372	i386	recvmsg			sys_recvmsg			compat_sys_recvmsg
 373	i386	shutdown		sys_shutdown
 374	i386	userfaultfd		sys_userfaultfd
+375	i386	mlock2			sys_mlock2
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 81c4906..2366900 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -330,6 +330,7 @@
 321	common	bpf			sys_bpf
 322	64	execveat		stub_execveat
 323	common	userfaultfd		sys_userfaultfd
+324	common	mlock2			sys_mlock2
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0800131..890632c 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -885,4 +885,6 @@ asmlinkage long sys_execveat(int dfd, const char __user *filename,
 			const char __user *const __user *argv,
 			const char __user *const __user *envp, int flags);
 
+asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
+
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index e016bd9..14a6013 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -709,9 +709,11 @@ __SYSCALL(__NR_memfd_create, sys_memfd_create)
 __SYSCALL(__NR_bpf, sys_bpf)
 #define __NR_execveat 281
 __SC_COMP(__NR_execveat, sys_execveat, compat_sys_execveat)
+#define __NR_mlock2 282
+__SYSCALL(__NR_mlock2, sys_mlock2)
 
 #undef __NR_syscalls
-#define __NR_syscalls 282
+#define __NR_syscalls 283
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 03c3875..8de5b26 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -194,6 +194,7 @@ cond_syscall(sys_mlock);
 cond_syscall(sys_munlock);
 cond_syscall(sys_mlockall);
 cond_syscall(sys_munlockall);
+cond_syscall(sys_mlock2);
 cond_syscall(sys_mincore);
 cond_syscall(sys_madvise);
 cond_syscall(sys_mremap);
diff --git a/mm/mlock.c b/mm/mlock.c
index c32ad8f..a23a533 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -644,6 +644,14 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 	return do_mlock(start, len, VM_LOCKED);
 }
 
+SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
+{
+	if (flags)
+		return -EINVAL;
+
+	return do_mlock(start, len, VM_LOCKED);
+}
+
 SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
