Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 42AAF6B025F
	for <linux-mm@kvack.org>; Mon, 25 Jul 2016 23:47:21 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id r71so495641585ioi.3
        for <linux-mm@kvack.org>; Mon, 25 Jul 2016 20:47:21 -0700 (PDT)
Received: from cliff.cs.toronto.edu (cliff.cs.toronto.edu. [128.100.3.120])
        by mx.google.com with ESMTPS id j1si22939974ioo.191.2016.07.25.20.47.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Jul 2016 20:47:20 -0700 (PDT)
Message-Id: <447c01092adfc8a8c61f6ee0723024220ef52dda.1469489884.git.gamvrosi@gmail.com>
In-Reply-To: <cover.1469489884.git.gamvrosi@gmail.com>
References: <cover.1469489884.git.gamvrosi@gmail.com>
From: George Amvrosiadis <gamvrosi@gmail.com>
Subject: [PATCH 2/3] mm/duet: syscall wiring
Date: Mon, 25 Jul 2016 23:47:20 -0400 (EDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
Cc: George Amvrosiadis <gamvrosi@gmail.com>

Usual syscall wiring for the four Duet syscalls.

Signed-off-by: George Amvrosiadis <gamvrosi@gmail.com>
---
 arch/x86/entry/syscalls/syscall_32.tbl |  4 ++++
 arch/x86/entry/syscalls/syscall_64.tbl |  4 ++++
 include/linux/syscalls.h               |  8 ++++++++
 include/uapi/asm-generic/unistd.h      | 12 +++++++++++-
 kernel/sys_ni.c                        |  6 ++++++
 5 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
index 4cddd17..f34ff94 100644
--- a/arch/x86/entry/syscalls/syscall_32.tbl
+++ b/arch/x86/entry/syscalls/syscall_32.tbl
@@ -386,3 +386,7 @@
 377	i386	copy_file_range		sys_copy_file_range
 378	i386	preadv2			sys_preadv2			compat_sys_preadv2
 379	i386	pwritev2		sys_pwritev2			compat_sys_pwritev2
+380	i386	duet_status		sys_duet_status
+381	i386	duet_init		sys_duet_init
+382	i386	duet_bmap		sys_duet_bmap
+383	i386	duet_get_path		sys_duet_get_path
diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
index 555263e..d04efaa 100644
--- a/arch/x86/entry/syscalls/syscall_64.tbl
+++ b/arch/x86/entry/syscalls/syscall_64.tbl
@@ -335,6 +335,10 @@
 326	common	copy_file_range		sys_copy_file_range
 327	64	preadv2			sys_preadv2
 328	64	pwritev2		sys_pwritev2
+329	common	duet_status		sys_duet_status
+330	common	duet_init		sys_duet_init
+331	common	duet_bmap		sys_duet_bmap
+332	common	duet_get_path		sys_duet_get_path
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index d022390..da1049e 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -65,6 +65,8 @@ struct old_linux_dirent;
 struct perf_event_attr;
 struct file_handle;
 struct sigaltstack;
+struct duet_status_args;
+struct duet_uuid_arg;
 union bpf_attr;
 
 #include <linux/types.h>
@@ -898,4 +900,10 @@ asmlinkage long sys_copy_file_range(int fd_in, loff_t __user *off_in,
 
 asmlinkage long sys_mlock2(unsigned long start, size_t len, int flags);
 
+asmlinkage long sys_duet_status(u16 flags, struct duet_status_args __user *arg);
+asmlinkage long sys_duet_init(const char __user *taskname, u32 regmask,
+			      const char __user *pathname);
+asmlinkage long sys_duet_bmap(u16 flags, struct duet_uuid_arg __user *arg);
+asmlinkage long sys_duet_get_path(struct duet_uuid_arg __user *uarg,
+				  char __user *pathbuf, int pathbufsize);
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index a26415b..7c287c0 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -725,8 +725,18 @@ __SC_COMP(__NR_preadv2, sys_preadv2, compat_sys_preadv2)
 #define __NR_pwritev2 287
 __SC_COMP(__NR_pwritev2, sys_pwritev2, compat_sys_pwritev2)
 
+/* mm/duet/syscall.c */
+#define __NR_duet_status 288
+__SYSCALL(__NR_duet_status, sys_duet_status)
+#define __NR_duet_init 289
+__SYSCALL(__NR_duet_init, sys_duet_init)
+#define __NR_duet_bmap 290
+__SYSCALL(__NR_duet_bmap, sys_duet_bmap)
+#define __NR_duet_get_path 291
+__SYSCALL(__NR_duet_get_path, sys_duet_get_path)
+
 #undef __NR_syscalls
-#define __NR_syscalls 288
+#define __NR_syscalls 292
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 2c5e3a8..3d4c53a 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -176,6 +176,12 @@ cond_syscall(sys_capget);
 cond_syscall(sys_capset);
 cond_syscall(sys_copy_file_range);
 
+/* Duet syscall entries */
+cond_syscall(sys_duet_status);
+cond_syscall(sys_duet_init);
+cond_syscall(sys_duet_bmap);
+cond_syscall(sys_duet_get_path);
+
 /* arch-specific weak syscall entries */
 cond_syscall(sys_pciconfig_read);
 cond_syscall(sys_pciconfig_write);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
