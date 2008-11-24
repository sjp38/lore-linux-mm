Subject: [PATCH/RFC] - support inheritance of mlocks across fork/exec
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Mon, 24 Nov 2008 16:21:46 -0500
Message-Id: <1227561707.6937.61.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh@veritas.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

PATCH/RFC - support inheritance of mlocks across fork/exec

Against;  2.6.28-rc5-mmotm-081121

Add support for mlockall(MCL_INHERIT|MCL_RECURSIVE):
	MCL_CURRENT|MCL_INHERIT - inherit memory locks across fork()
	MCL_FUTURE|MCL_INHERIT - inherit "MCL_FUTURE" semantics across
	fork() and exec().
	MCL_RECURSIVE - inherit across future generations.

In support of a "lock prefix command"--e.g., mlock <cmd> <args> ...

Together with patches to keep mlocked pages off the LRU, this will
allow users/admins to lock down applications without modifying them,
if their RLIMIT_MEMLOCK is sufficiently large, keeping their pages
off the LRU and out of consideration for reclaim.

Potentially useful in real-time environments to force prefaulting and 
residency for applications that don't mlock themselves.

Jeff Sharkey at Montana State developed a similar patch for Linux
[link no longer accessible], but apparently he never submitted the patch.

I submitted an earlier version of this patch around a year ago.  I
resurrected it to test the unevictable lru/mlocked pages patches--
e.g., by "mlock -r make -j<N*nr_cpus> all".  This did shake out a few
races and vmstat accounting bugs, but NOT something I'd recommend as
general practice--for kernel builds, that is.


Define MCL_INHERIT, MCL_RECURSIVE in <asm-*/mman.h>.
+ x86 and  ia64 versions included.
+ other arch can/will be created, if this patch deemed merge-worthy.

Similarly, I'll provide kernel man page update if/when needed.

Example "lock prefix command" in Documentation/vm/mlock.c

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 Documentation/vm/mlock.c     |  149 +++++++++++++++++++++++++++++++++++++++++++
 arch/ia64/include/asm/mman.h |    2 
 arch/x86/include/asm/mman.h  |    3 
 fs/binfmt_elf.c              |    9 ++
 include/linux/mm_types.h     |    2 
 kernel/fork.c                |   15 +++-
 mm/mlock.c                   |   14 ++--
 7 files changed, 186 insertions(+), 8 deletions(-)

Index: linux-2.6.28-rc5-mmotm-081121/arch/ia64/include/asm/mman.h
===================================================================
--- linux-2.6.28-rc5-mmotm-081121.orig/arch/ia64/include/asm/mman.h	2008-11-24 14:11:59.000000000 -0500
+++ linux-2.6.28-rc5-mmotm-081121/arch/ia64/include/asm/mman.h	2008-11-24 14:12:15.000000000 -0500
@@ -21,6 +21,8 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_INHERIT	4		/* inherit '_FUTURE across fork/exec */
+#define MCL_RECURSIVE	8		/* inherit '_FUTURE recursively */
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
Index: linux-2.6.28-rc5-mmotm-081121/mm/mlock.c
===================================================================
--- linux-2.6.28-rc5-mmotm-081121.orig/mm/mlock.c	2008-11-24 14:11:59.000000000 -0500
+++ linux-2.6.28-rc5-mmotm-081121/mm/mlock.c	2008-11-24 14:12:15.000000000 -0500
@@ -572,15 +572,18 @@ asmlinkage long sys_munlock(unsigned lon
 static int do_mlockall(int flags)
 {
 	struct vm_area_struct * vma, * prev = NULL;
+	struct mm_struct *mm = current->mm;
 	unsigned int def_flags = 0;
 
 	if (flags & MCL_FUTURE)
-		def_flags = VM_LOCKED;
-	current->mm->def_flags = def_flags;
-	if (flags == MCL_FUTURE)
+		def_flags = VM_LOCKED;;
+	mm->def_flags = def_flags;
+	if (flags & MCL_INHERIT)
+		mm->mcl_inherit = flags & (MCL_INHERIT | MCL_RECURSIVE);
+	if ((flags & ~(MCL_INHERIT | MCL_RECURSIVE)) == MCL_FUTURE)
 		goto out;
 
-	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
+	for (vma = mm->mmap; vma ; vma = prev->vm_next) {
 		unsigned int newflags;
 
 		newflags = vma->vm_flags | VM_LOCKED;
@@ -599,7 +602,8 @@ asmlinkage long sys_mlockall(int flags)
 	unsigned long lock_limit;
 	int ret = -EINVAL;
 
-	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
+	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE |
+				 MCL_INHERIT | MCL_RECURSIVE)))
 		goto out;
 
 	ret = -EPERM;
Index: linux-2.6.28-rc5-mmotm-081121/kernel/fork.c
===================================================================
--- linux-2.6.28-rc5-mmotm-081121.orig/kernel/fork.c	2008-11-24 14:11:59.000000000 -0500
+++ linux-2.6.28-rc5-mmotm-081121/kernel/fork.c	2008-11-24 14:12:15.000000000 -0500
@@ -274,7 +274,8 @@ static int dup_mmap(struct mm_struct *mm
 	 */
 	down_write_nested(&mm->mmap_sem, SINGLE_DEPTH_NESTING);
 
-	mm->locked_vm = 0;
+	if (!mm->mcl_inherit)
+		mm->locked_vm = 0;
 	mm->mmap = NULL;
 	mm->mmap_cache = NULL;
 	mm->free_area_cache = oldmm->mmap_base;
@@ -312,7 +313,8 @@ static int dup_mmap(struct mm_struct *mm
 		if (IS_ERR(pol))
 			goto fail_nomem_policy;
 		vma_set_policy(tmp, pol);
-		tmp->vm_flags &= ~VM_LOCKED;
+		if (!mm->mcl_inherit)
+			tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
 		tmp->vm_next = NULL;
 		anon_vma_link(tmp);
@@ -402,6 +404,8 @@ __cacheline_aligned_in_smp DEFINE_SPINLO
 
 static struct mm_struct * mm_init(struct mm_struct * mm, struct task_struct *p)
 {
+	unsigned long def_flags = 0;
+
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
@@ -418,9 +422,14 @@ static struct mm_struct * mm_init(struct
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
 	mm_init_owner(mm, p);
+	if (current->mm && current->mm->mcl_inherit) {
+		def_flags = current->mm->def_flags & VM_LOCKED;
+		if (mm->mcl_inherit & MCL_RECURSIVE)
+			mm->mcl_inherit  = current->mm->mcl_inherit;
+	}
 
 	if (likely(!mm_alloc_pgd(mm))) {
-		mm->def_flags = 0;
+		mm->def_flags = def_flags;
 		mmu_notifier_mm_init(mm);
 		return mm;
 	}
Index: linux-2.6.28-rc5-mmotm-081121/fs/binfmt_elf.c
===================================================================
--- linux-2.6.28-rc5-mmotm-081121.orig/fs/binfmt_elf.c	2008-11-24 14:11:59.000000000 -0500
+++ linux-2.6.28-rc5-mmotm-081121/fs/binfmt_elf.c	2008-11-24 14:12:15.000000000 -0500
@@ -585,6 +585,7 @@ static int load_elf_binary(struct linux_
 	unsigned long reloc_func_desc = 0;
 	int executable_stack = EXSTACK_DEFAULT;
 	unsigned long def_flags = 0;
+	int mcl_inherit = 0;
 	struct {
 		struct elfhdr elf_ex;
 		struct elfhdr interp_elf_ex;
@@ -749,6 +750,13 @@ static int load_elf_binary(struct linux_
 		SET_PERSONALITY(loc->elf_ex);
 	}
 
+	/* Optionally inherit MCL_FUTURE state before destroying old mm */
+	if (current->mm && current->mm->mcl_inherit) {
+		def_flags = current->mm->def_flags & VM_LOCKED;
+		if (current->mm->mcl_inherit & MCL_RECURSIVE)
+			mcl_inherit  = current->mm->mcl_inherit;
+	}
+
 	/* Flush all traces of the currently running executable */
 	retval = flush_old_exec(bprm);
 	if (retval)
@@ -757,6 +765,7 @@ static int load_elf_binary(struct linux_
 	/* OK, This is the point of no return */
 	current->flags &= ~PF_FORKNOEXEC;
 	current->mm->def_flags = def_flags;
+	current->mm->mcl_inherit = mcl_inherit;
 
 	/* Do this immediately, since STACK_TOP as used in setup_arg_pages
 	   may depend on the personality.  */
Index: linux-2.6.28-rc5-mmotm-081121/arch/x86/include/asm/mman.h
===================================================================
--- linux-2.6.28-rc5-mmotm-081121.orig/arch/x86/include/asm/mman.h	2008-11-24 14:11:59.000000000 -0500
+++ linux-2.6.28-rc5-mmotm-081121/arch/x86/include/asm/mman.h	2008-11-24 14:12:15.000000000 -0500
@@ -16,5 +16,8 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_INHERIT	4		/* inherit mlocks across fork */
+					/* inherit '_FUTURE flag across fork/exec */
+#define MCL_RECURSIVE	8		/* inherit mlocks recursively */
 
 #endif /* _ASM_X86_MMAN_H */
Index: linux-2.6.28-rc5-mmotm-081121/include/linux/mm_types.h
===================================================================
--- linux-2.6.28-rc5-mmotm-081121.orig/include/linux/mm_types.h	2008-11-24 14:11:59.000000000 -0500
+++ linux-2.6.28-rc5-mmotm-081121/include/linux/mm_types.h	2008-11-24 14:12:15.000000000 -0500
@@ -235,6 +235,8 @@ struct mm_struct {
 	unsigned int token_priority;
 	unsigned int last_interval;
 
+	int mcl_inherit;		/* inherit current/future locks */
+
 	unsigned long flags; /* Must use atomic bitops to access the bits */
 
 	struct core_state *core_state; /* coredumping support */
Index: linux-2.6.28-rc5-mmotm-081121/Documentation/vm/mlock.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.28-rc5-mmotm-081121/Documentation/vm/mlock.c	2008-11-24 14:12:15.000000000 -0500
@@ -0,0 +1,149 @@
+/*
+ * mlock.c
+ *
+ * Command-line utility for launching a program with the
+ * mlockall() MCL_FUTURE flag set such that all of the task's
+ * pages will be locked into memory.  This depends on the
+ * MCL_INHERIT|MCL_RECURSIVE enhancement to mlockall(2).
+ *
+ * Based on the taskset command from the schedutils package by
+ *
+ * 	Robert Love <rml@tech9.net>
+ *
+ * Compile with:
+ *
+ * 	gcc -o mlock mlock.c
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License, v2, as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+ *
+ * Copyright (C) 2004 Robert Love
+ * Copyright (C) 2008 Hewlett-Packard, Inc.
+ */
+
+#include <sys/types.h>
+#include <sys/mman.h>
+
+#include <ctype.h>
+#include <errno.h>
+#include <getopt.h>
+#include <stdlib.h>
+#include <stdio.h>
+#include <string.h>
+#include <unistd.h>
+
+#define MLOCK_VERSION "0.2"
+
+/*
+ * Version Info
+ *
+ * 0.1	- initial implementation
+ *
+ * 0.2  - add "--recursive" support
+ */
+
+#define OPTIONS "+hr"
+static struct option l_opts[] = {
+	{
+		.name = "help",
+		.has_arg = no_argument,
+		.flag = NULL,
+		.val = 'h'
+	},
+	{
+		.name = "recursive",
+		.has_arg = no_argument,
+		.flag = NULL,
+		.val = 'r'
+	},
+	{
+		.name = NULL,
+	}
+};
+
+/*
+ * For testing before MCL_INHERIT and MCL_RECURSIVE exist in a
+ * user space header.  mlockall() will fail if these flags are
+ * not implemented.
+ *
+ * N.B., won't work on platforms with "interesting" values for
+ *       MCL_FUTURE  -- e.g., powerpc, sparc, alpha
+ *       [maybe OK for alpha, but ...]
+ */
+#ifndef MCL_INHERIT
+#define MCL_INHERIT   (MCL_FUTURE << 1)
+#define MCL_RECURSIVE (MCL_INHERIT << 1)
+#endif
+
+static const char *usage = "\
+\nmlock version " MLOCK_VERSION "\n\n\
+Usage:  %s [-hr] <cmd> [args...]]\n\n\
+Where:\n\
+\t--help/-h      = show this help/usage\n\
+\t--recursive/-r = inherit recursively--i.e., across future\n\
+\t                 generations.\n\n\
+Run <cmd> as if it had called mlockall(2) with the MCL_CURRENT|MCL_FUTURE\n\
+flags set.  That is, all of <cmd>'s pages will be locked into memory.\n\
+If '--recursive/-r' specified, the MCL_RECURSIVE flag will be added, and\n\
+all future descendants of <cmd> will run with inherit this condition,\n\
+unless one of them calls munlockall(2) or mlockall(2) without the\n\
+MCL_INHERIT|MCL_RECURSIVE flags.\n\n\
+";
+
+static void show_usage(const char *cmd)
+{
+	fprintf(stderr, usage, cmd);
+}
+
+int main(int argc, char *argv[])
+{
+
+	int opt;
+	int flags = MCL_FUTURE|MCL_INHERIT;
+
+	while ((opt = getopt_long(argc, argv, OPTIONS, l_opts, NULL)) != -1) {
+		int ret = 1;
+
+		switch (opt) {
+		case 'r':
+			flags |= MCL_RECURSIVE;
+			break;
+		case 'h':
+			ret = 0;
+			/* fall through */
+
+		default:
+			show_usage(argv[0]);
+			return ret;
+		}
+	}
+
+	if ((argc - optind) < 1) {
+		show_usage(argv[0]);
+		return 1;
+	}
+
+	if (mlockall(flags) == -1) {
+		fprintf(stderr, "%s mlockall() failed - %s\n", argv[0],
+			strerror(errno));
+		return 1;
+	}
+
+	argv += optind;
+	execvp(argv[0], argv);
+	perror("execvp");
+	fprintf(stderr, "failed to execute %s\n", argv[0]);
+	return 1;
+
+}
+


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
