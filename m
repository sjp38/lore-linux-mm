Date: Sat, 1 May 2004 18:41:57 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: [PATCH] small numa api fixups
Message-ID: <20040501164157.GA32321@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org, ak@suse.de
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--- linux-2.6.6-rc3-mm1/fs/exec.c	2004-04-28 13:58:20.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/fs/exec.c	2004-04-28 14:26:41.000000000 +0200
@@ -46,6 +46,7 @@
 #include <linux/security.h>
 #include <linux/syscalls.h>
 #include <linux/rmap.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/mmu_context.h>
--- linux-2.6.6-rc3-mm1/include/linux/mm.h	2004-04-28 13:58:28.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/include/linux/mm.h	2004-04-28 14:08:08.000000000 +0200
@@ -13,7 +13,8 @@
 #include <linux/rbtree.h>
 #include <linux/prio_tree.h>
 #include <linux/fs.h>
-#include <linux/mempolicy.h>
+
+struct mempolicy;
 
 #ifndef CONFIG_DISCONTIGMEM          /* Don't use mapnrs, do it properly */
 extern unsigned long max_mapnr;
--- linux-2.6.6-rc3-mm1/include/linux/sched.h	2004-04-28 13:58:28.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/include/linux/sched.h	2004-04-28 14:07:44.000000000 +0200
@@ -29,7 +29,6 @@
 #include <linux/completion.h>
 #include <linux/pid.h>
 #include <linux/percpu.h>
-#include <linux/mempolicy.h>
 
 struct exec_domain;
 
@@ -388,6 +387,7 @@ int set_current_groups(struct group_info
 
 
 struct audit_context;		/* See audit.c */
+struct mempolicy;
 
 struct task_struct {
 	volatile long state;	/* -1 unrunnable, 0 runnable, >0 stopped */
@@ -517,8 +517,10 @@ struct task_struct {
 	unsigned long ptrace_message;
 	siginfo_t *last_siginfo; /* For ptrace use.  */
 
+#ifdef CONFIG_NUMA
   	struct mempolicy *mempolicy;
   	short il_next;		/* could be shared with used_math */
+#endif
 };
 
 static inline pid_t process_group(struct task_struct *tsk)
--- linux-2.6.6-rc3-mm1/kernel/exit.c	2004-04-28 13:58:28.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/kernel/exit.c	2004-04-28 14:21:31.000000000 +0200
@@ -790,7 +790,9 @@ asmlinkage NORET_TYPE void do_exit(long 
 	__exit_fs(tsk);
 	exit_namespace(tsk);
 	exit_thread();
+#ifdef CONFIG_NUMA
 	mpol_free(tsk->mempolicy);
+#endif
 
 	if (tsk->signal->leader)
 		disassociate_ctty(1);
--- linux-2.6.6-rc3-mm1/kernel/fork.c	2004-04-28 13:58:28.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/kernel/fork.c	2004-04-28 14:20:24.000000000 +0200
@@ -35,6 +35,7 @@
 #include <linux/audit.h>
 #include <linux/rmap.h>
 #include <linux/cpu.h>
+#include <linux/mempolicy.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
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
--- linux-2.6.6-rc3-mm1/mm/mempolicy.c	2004-04-28 13:58:29.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/mm/mempolicy.c	2004-04-28 14:11:51.000000000 +0200
@@ -72,6 +72,7 @@
 #include <linux/interrupt.h>
 #include <linux/init.h>
 #include <linux/compat.h>
+#include <linux/mempolicy.h>
 #include <asm/uaccess.h>
 
 static kmem_cache_t *policy_cache;
--- linux-2.6.6-rc3-mm1/mm/mmap.c	2004-04-28 13:58:29.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/mm/mmap.c	2004-04-28 14:09:02.000000000 +0200
@@ -21,6 +21,7 @@
 #include <linux/profile.h>
 #include <linux/module.h>
 #include <linux/mount.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
--- linux-2.6.6-rc3-mm1/mm/mprotect.c	2004-04-28 13:58:29.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/mm/mprotect.c	2004-04-28 14:26:27.000000000 +0200
@@ -16,6 +16,7 @@
 #include <linux/fs.h>
 #include <linux/highmem.h>
 #include <linux/security.h>
+#include <linux/mempolicy.h>
 
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
--- linux-2.6.6-rc3-mm1/mm/shmem.c	2004-04-28 13:58:29.000000000 +0200
+++ linux-2.6.6-rc3-mm1-hch/mm/shmem.c	2004-04-28 14:08:56.000000000 +0200
@@ -39,6 +39,7 @@
 #include <linux/blkdev.h>
 #include <linux/security.h>
 #include <linux/swapops.h>
+#include <linux/mempolicy.h>
 #include <asm/uaccess.h>
 #include <asm/div64.h>
 #include <asm/pgtable.h>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
