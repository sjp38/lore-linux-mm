Message-Id: <200405222208.i4MM84r13291@mail.osdl.org>
Subject: [patch 26/57] small numa api fixups
From: akpm@osdl.org
Date: Sat, 22 May 2004 15:07:32 -0700
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@osdl.org
Cc: linux-mm@kvack.org, akpm@osdl.org, hch@lst.de
List-ID: <linux-mm.kvack.org>

From: Christoph Hellwig <hch@lst.de>

- don't include mempolicy.h in sched.h and mm.h when a forward delcaration
  is enough.  Andi argued against that in the past, but I'd really hate to add
  another header to two of the includes used in basically every driver when we
  can include it in the six files actually needing it instead (that number is
  for my ppc32 system, maybe other arches need more include in their
  directories)

- make numa api fields in tast_struct conditional on CONFIG_NUMA, this gives
  us a few ugly ifdefs but avoids wasting memory on non-NUMA systems.


---

 25-akpm/arch/ia64/ia32/binfmt_elf32.c  |    1 +
 25-akpm/arch/ia64/kernel/perfmon.c     |    1 +
 25-akpm/arch/ia64/mm/init.c            |    1 +
 25-akpm/arch/x86_64/ia32/ia32_binfmt.c |    1 +
 25-akpm/fs/exec.c                      |    1 +
 25-akpm/include/linux/mm.h             |    3 ++-
 25-akpm/include/linux/sched.h          |    4 +++-
 25-akpm/kernel/exit.c                  |    3 +++
 25-akpm/kernel/fork.c                  |    5 +++++
 25-akpm/mm/mempolicy.c                 |    1 +
 25-akpm/mm/mmap.c                      |    1 +
 25-akpm/mm/mprotect.c                  |    1 +
 25-akpm/mm/shmem.c                     |    1 +
 13 files changed, 22 insertions(+), 2 deletions(-)

diff -puN fs/exec.c~small-numa-api-fixups fs/exec.c
--- 25/fs/exec.c~small-numa-api-fixups	2004-05-22 14:56:25.697184960 -0700
+++ 25-akpm/fs/exec.c	2004-05-22 14:59:39.509720976 -0700
@@ -46,6 +46,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/rmap.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
diff -puN include/linux/mm.h~small-numa-api-fixups include/linux/mm.h
--- 25/include/linux/mm.h~small-numa-api-fixups	2004-05-22 14:56:25.698184808 -0700
+++ 25-akpm/include/linux/mm.h	2004-05-22 14:59:39.777680240 -0700
@@ -12,7 +12,8 @@
 #include <linux/mmzone.h>
 #include <linux/rbtree.h>
 #include <linux/fs.h>
-#include <linux/mempolicy.h>
+
+struct mempolicy;
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
diff -puN include/linux/sched.h~small-numa-api-fixups include/linux/sched.h
--- 25/include/linux/sched.h~small-numa-api-fixups	2004-05-22 14:56:25.700184504 -0700
+++ 25-akpm/include/linux/sched.h	2004-05-22 14:59:35.804284288 -0700
@@ -29,7 +29,6 @@
 #include <linux/completion.h>
 #include <linux/pid.h>
 #include <linux/percpu.h>
-#include <linux/mempolicy.h>
 
 struct exec_domain;
 
@@ -381,6 +380,7 @@ int set_current_groups(struct group_info
 
 
 struct audit_context;		/* See audit.c */
+struct mempolicy;
 
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
@@ -510,8 +510,10 @@ struct task_struct {
 	unsigned long ptrace_message;
 	siginfo_t *last_siginfo; /* For ptrace use.  */
 
+#ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
   	short il_next;		/* could be shared with used_math */
+#endif
 };
 
 static inline pid_t process_group(struct task_struct *tsk)
diff -puN kernel/exit.c~small-numa-api-fixups kernel/exit.c
--- 25/kernel/exit.c~small-numa-api-fixups	2004-05-22 14:56:25.701184352 -0700
+++ 25-akpm/kernel/exit.c	2004-05-22 14:56:25.720181464 -0700
@@ -22,6 +22,7 @@
 #include <linux/profile.h>
 #include <linux/mount.h>
 #include <linux/proc_fs.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -791,7 +792,9 @@ asmlinkage NORET_TYPE void do_exit(long 
 	__exit_fs(tsk);
 	exit_namespace(tsk);
 	exit_thread();
+#ifdef CONFIG_NUMA
 	mpol_free(tsk->mempolicy);
+#endif
 
 	if (tsk->signal->leader)
 		disassociate_ctty(1);
diff -puN kernel/fork.c~small-numa-api-fixups kernel/fork.c
--- 25/kernel/fork.c~small-numa-api-fixups	2004-05-22 14:56:25.703184048 -0700
+++ 25-akpm/kernel/fork.c	2004-05-22 14:59:39.622703800 -0700
@@ -21,6 +21,7 @@
 #include <linux/completion.h>
 #include <linux/namespace.h>
 #include <linux/personality.h>
+#include <linux/mempolicy.h>
 #include <linux/sem.h>
 #include <linux/file.h>
 #include <linux/binfmts.h>
@@ -972,12 +973,14 @@ struct task_struct *copy_process(unsigne
 	p->security = NULL;
 	p->io_context = NULL;
 	p->audit_context = NULL;
+#ifdef CONFIG_NUMA
  	p->mempolicy = mpol_copy(p->mempolicy);
  	if (IS_ERR(p->mempolicy)) {
  		retval = PTR_ERR(p->mempolicy);
  		p->mempolicy = NULL;
  		goto bad_fork_cleanup;
  	}
+#endif
 
 	retval = -ENOMEM;
 	if ((retval = security_task_alloc(p)))
@@ -1128,7 +1131,9 @@ bad_fork_cleanup_audit:
 bad_fork_cleanup_security:
 	security_task_free(p);
 bad_fork_cleanup_policy:
+#ifdef CONFIG_NUMA
 	mpol_free(p->mempolicy);
+#endif
 bad_fork_cleanup:
 	if (p->pid > 0)
 		free_pidmap(p->pid);
diff -puN mm/mempolicy.c~small-numa-api-fixups mm/mempolicy.c
--- 25/mm/mempolicy.c~small-numa-api-fixups	2004-05-22 14:56:25.704183896 -0700
+++ 25-akpm/mm/mempolicy.c	2004-05-22 14:59:39.908660328 -0700
@@ -72,6 +72,7 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/compat.h>
+#include <linux/mempolicy.h>
 #include <asm/uaccess.h>
 
 static kmem_cache_t *policy_cache;
diff -puN mm/mmap.c~small-numa-api-fixups mm/mmap.c
--- 25/mm/mmap.c~small-numa-api-fixups	2004-05-22 14:56:25.705183744 -0700
+++ 25-akpm/mm/mmap.c	2004-05-22 14:59:39.780679784 -0700
@@ -21,6 +21,7 @@
 #include <linux/profile.h>
 #include <linux/module.h>
 #include <linux/mount.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
diff -puN mm/mprotect.c~small-numa-api-fixups mm/mprotect.c
--- 25/mm/mprotect.c~small-numa-api-fixups	2004-05-22 14:56:25.707183440 -0700
+++ 25-akpm/mm/mprotect.c	2004-05-22 14:59:36.405192936 -0700
@@ -16,6 +16,7 @@
 #include <linux/fs.h>
 #include <linux/highmem.h>
 #include <linux/security.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgalloc.h>
diff -puN mm/shmem.c~small-numa-api-fixups mm/shmem.c
--- 25/mm/shmem.c~small-numa-api-fixups	2004-05-22 14:56:25.708183288 -0700
+++ 25-akpm/mm/shmem.c	2004-05-22 14:56:25.725180704 -0700
@@ -39,6 +39,7 @@
 #include <linux/blkdev.h>
 #include <linux/security.h>
 #include <linux/swapops.h>
+#include <linux/mempolicy.h>
 #include <asm/uaccess.h>
 #include <asm/div64.h>
 #include <asm/pgtable.h>
diff -puN arch/ia64/ia32/binfmt_elf32.c~small-numa-api-fixups arch/ia64/ia32/binfmt_elf32.c
--- 25/arch/ia64/ia32/binfmt_elf32.c~small-numa-api-fixups	2004-05-22 14:56:25.709183136 -0700
+++ 25-akpm/arch/ia64/ia32/binfmt_elf32.c	2004-05-22 14:59:37.399041848 -0700
@@ -14,6 +14,7 @@
 #include <linux/types.h>
 #include <linux/mm.h>
 #include <linux/security.h>
+#include <linux/mempolicy.h>
 
 #include <asm/param.h>
 #include <asm/signal.h>
diff -puN arch/ia64/kernel/perfmon.c~small-numa-api-fixups arch/ia64/kernel/perfmon.c
--- 25/arch/ia64/kernel/perfmon.c~small-numa-api-fixups	2004-05-22 14:56:25.711182832 -0700
+++ 25-akpm/arch/ia64/kernel/perfmon.c	2004-05-22 14:59:37.404041088 -0700
@@ -38,6 +38,7 @@
 #include <linux/pagemap.h>
 #include <linux/mount.h>
 #include <linux/version.h>
+#include <linux/mempolicy.h>
 
 #include <asm/bitops.h>
 #include <asm/errno.h>
diff -puN arch/ia64/mm/init.c~small-numa-api-fixups arch/ia64/mm/init.c
--- 25/arch/ia64/mm/init.c~small-numa-api-fixups	2004-05-22 14:56:25.713182528 -0700
+++ 25-akpm/arch/ia64/mm/init.c	2004-05-22 14:59:37.405040936 -0700
@@ -19,6 +19,7 @@
 #include <linux/slab.h>
 #include <linux/swap.h>
 #include <linux/proc_fs.h>
+#include <linux/mempolicy.h>
 
 #include <asm/a.out.h>
 #include <asm/bitops.h>
diff -puN arch/x86_64/ia32/ia32_binfmt.c~small-numa-api-fixups arch/x86_64/ia32/ia32_binfmt.c
--- 25/arch/x86_64/ia32/ia32_binfmt.c~small-numa-api-fixups	2004-05-22 14:56:25.714182376 -0700
+++ 25-akpm/arch/x86_64/ia32/ia32_binfmt.c	2004-05-22 14:59:38.740837864 -0700
@@ -15,6 +15,7 @@
 #include <linux/binfmts.h>
 #include <linux/mm.h>
 #include <linux/security.h>
+#include <linux/mempolicy.h>
 
 #include <asm/segment.h> 
 #include <asm/ptrace.h>

_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
