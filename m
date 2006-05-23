Date: Tue, 23 May 2006 10:44:10 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060523174410.10156.43268.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
References: <20060523174344.10156.66845.sendpatchset@schroedinger.engr.sgi.com>
Subject: [5/5] move_pages: 32bit support (i386,x86_64 and ia64)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-ia64@vger.kernel.org, Peter Zijlstra <a.p.zijlstra@chello.nl>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <nickpiggin@yahoo.com.au>, linux-mm@kvack.org, Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

sys_move_pages() support for 32bit (i386 plus ia64 and x86_64 compat layers)

Add support for move_pages() on i386 and also add the
compat functions necessary to run 32 bit binaries on x86_64 and ia64.

Add compat_sys_move_pages to both the x86_64 and the ia64 32bit binary
layer. Note that both are not up to date so I added the missing pieces.
Not sure if this is done the right way.

This probably needs some fixups:

1. What about sys_vmsplice on x86_64?

2. There is a whole range of syscalls missing for ia64 that I basically
   interpolated from elsewhere.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc4-mm3/arch/i386/kernel/syscall_table.S
===================================================================
--- linux-2.6.17-rc4-mm3.orig/arch/i386/kernel/syscall_table.S	2006-05-11 16:31:53.000000000 -0700
+++ linux-2.6.17-rc4-mm3/arch/i386/kernel/syscall_table.S	2006-05-23 10:15:43.789358191 -0700
@@ -315,3 +315,5 @@ ENTRY(sys_call_table)
 	.long sys_splice
 	.long sys_sync_file_range
 	.long sys_tee			/* 315 */
+	.long sys_ni_syscall		/* vmsplice */
+	.long sys_move_pages
Index: linux-2.6.17-rc4-mm3/arch/x86_64/ia32/ia32entry.S
===================================================================
--- linux-2.6.17-rc4-mm3.orig/arch/x86_64/ia32/ia32entry.S	2006-05-22 18:03:26.298716900 -0700
+++ linux-2.6.17-rc4-mm3/arch/x86_64/ia32/ia32entry.S	2006-05-23 10:15:43.791311196 -0700
@@ -699,4 +699,5 @@ ia32_sys_call_table:
 	.quad sys_sync_file_range
 	.quad sys_tee
 	.quad compat_sys_vmsplice
+	.quad compat_sys_move_pages
 ia32_syscall_end:		
Index: linux-2.6.17-rc4-mm3/include/asm-i386/unistd.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/asm-i386/unistd.h	2006-05-22 18:03:30.090473603 -0700
+++ linux-2.6.17-rc4-mm3/include/asm-i386/unistd.h	2006-05-23 10:15:43.792287698 -0700
@@ -322,10 +322,11 @@
 #define __NR_sync_file_range	314
 #define __NR_tee		315
 #define __NR_vmsplice		316
+#define __NR_move_pages		317
 
 #ifdef __KERNEL__
 
-#define NR_syscalls 317
+#define NR_syscalls 318
 
 /*
  * user-visible error numbers are in the range -1 - -128: see
Index: linux-2.6.17-rc4-mm3/kernel/compat.c
===================================================================
--- linux-2.6.17-rc4-mm3.orig/kernel/compat.c	2006-05-11 16:31:53.000000000 -0700
+++ linux-2.6.17-rc4-mm3/kernel/compat.c	2006-05-23 10:15:43.793264200 -0700
@@ -21,6 +21,7 @@
 #include <linux/unistd.h>
 #include <linux/security.h>
 #include <linux/timex.h>
+#include <linux/migrate.h>
 
 #include <asm/uaccess.h>
 
@@ -934,3 +935,25 @@ asmlinkage long compat_sys_adjtimex(stru
 
 	return ret;
 }
+
+#ifdef CONFIG_NUMA
+asmlinkage long compat_sys_move_pages(pid_t pid, unsigned long nr_pages,
+		void __user *pages32,
+		const int __user *nodes,
+		int __user *status,
+		int flags)
+{
+	const void __user * __user *pages;
+	int i;
+
+	pages = compat_alloc_user_space(nr_pages * sizeof(void *));
+	for (i = 0; i < nr_pages; i++) {
+		compat_uptr_t p;
+
+		if (get_user(p, (compat_uptr_t *)(pages32 + i)) ||
+			put_user(compat_ptr(p), pages + i))
+			return -EFAULT;
+	}
+	return sys_move_pages(pid, nr_pages, pages, nodes, status, flags);
+}
+#endif
Index: linux-2.6.17-rc4-mm3/include/linux/syscalls.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/linux/syscalls.h	2006-05-23 10:03:36.022956244 -0700
+++ linux-2.6.17-rc4-mm3/include/linux/syscalls.h	2006-05-23 10:15:43.794240702 -0700
@@ -520,6 +520,11 @@ asmlinkage long sys_move_pages(pid_t pid
 				const int __user *nodes,
 				int __user *status,
 				int flags);
+asmlinkage long compat_sys_move_pages(pid_t pid, unsigned long nr_page,
+				void __user *pages,
+				const int __user *nodes,
+				int __user *status,
+				int flags);
 asmlinkage long sys_mbind(unsigned long start, unsigned long len,
 				unsigned long mode,
 				unsigned long __user *nmask,
Index: linux-2.6.17-rc4-mm3/arch/ia64/ia32/ia32_entry.S
===================================================================
--- linux-2.6.17-rc4-mm3.orig/arch/ia64/ia32/ia32_entry.S	2006-05-11 16:31:53.000000000 -0700
+++ linux-2.6.17-rc4-mm3/arch/ia64/ia32/ia32_entry.S	2006-05-23 10:15:43.796193706 -0700
@@ -495,6 +495,39 @@ ia32_syscall_table:
   	data8 compat_sys_mq_getsetattr
 	data8 sys_ni_syscall		/* reserved for kexec */
 	data8 compat_sys_waitid
+	data8 sys_ni_syscall		/* 285: sys_altroot */
+	data8 sys_add_key
+	data8 sys_request_key
+	data8 sys_keyctl
+	data8 sys_ioprio_set
+	data8 sys_ioprio_get		/* 290 */
+	data8 sys_inotify_init
+	data8 sys_inotify_add_watch
+	data8 sys_inotify_rm_watch
+	data8 sys_migrate_pages
+	data8 compat_sys_openat		/* 295 */
+	data8 sys_mkdirat
+	data8 sys_mknodat
+	data8 sys_fchownat
+	data8 compat_sys_futimesat
+	data8 sys_ni_syscall		/* broken: sys_fstatat 300 */
+	data8 sys_unlinkat
+	data8 sys_renameat
+	data8 sys_linkat
+	data8 sys_symlinkat
+	data8 sys_readlinkat		/* 305 */
+	data8 sys_fchmodat
+	data8 sys_faccessat
+	data8 sys_ni_syscall		/* pselect6 */
+	data8 sys_ni_syscall		/* ppoll */
+	data8 sys_unshare               /* 310 */
+	data8 compat_sys_set_robust_list
+	data8 compat_sys_get_robust_list
+	data8 sys_splice
+	data8 sys_sync_file_range
+	data8 sys_tee			/* 315 */
+	data8 compat_sys_vmsplice
+	data8 compat_sys_move_pages
 
 	// guard against failures to increase IA32_NR_syscalls
 	.org ia32_syscall_table + 8*IA32_NR_syscalls
Index: linux-2.6.17-rc4-mm3/include/asm-ia64/ia32.h
===================================================================
--- linux-2.6.17-rc4-mm3.orig/include/asm-ia64/ia32.h	2006-05-22 18:03:30.107074135 -0700
+++ linux-2.6.17-rc4-mm3/include/asm-ia64/ia32.h	2006-05-23 10:15:43.796193706 -0700
@@ -5,7 +5,7 @@
 #include <asm/ptrace.h>
 #include <asm/signal.h>
 
-#define IA32_NR_syscalls		285	/* length of syscall table */
+#define IA32_NR_syscalls		318	/* length of syscall table */
 #define IA32_PAGE_SHIFT			12	/* 4KB pages */
 
 #ifndef __ASSEMBLY__

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
