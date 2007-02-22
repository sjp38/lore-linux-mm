Subject: [RFC] [PATCH 2.6.20-mm2] Optionally inherit mlockall() semantics
	across fork()/exec()
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Content-Type: text/plain
Date: Thu, 22 Feb 2007 16:03:57 -0500
Message-Id: <1172178237.5341.38.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Add support for mlockall(MCL_INHERIT):
	MCL_CURRENT|MCL_INHERIT - inherit memory locks across fork()
	MCL_FUTURE|MCL_INHERIT - inherit "MCL_FUTURE" semantics across
	fork() and exec().

In support of a "lock prefix command"--e.g., mlock <cmd> <args> ...
Together with Christoph Lameter's patch to keep mlocked pages off
the LRU, this will allow users/admins to lock down applications
without modifying them, keeping their pages off the LRU and out of
consideration for reclaim.

Define MCL_INHERIT in <asm/mman.h>.

Add an int to mm_struct to remember inheritance of future locks.
TODO:  use a bit flag in some other member?  For now, slot it in
where we might have some padding on 64-bit systems.

sys_mlockall():	Allow MCL_INHERIT in flags.

do_mlockall():  Set mcl_inherit non-zero in mm_struct if
		MCL_INHERIT set; otherwise, zero mcl_inherit
		[munlockall()].
		Note:   mlockall() w/o MCL_INHERIT will also
		turn off future lock inheritance.

dup_mm():	Inherit vm locks and mcl_inherit itself
		over fork() if mcl_inherit set in parent's
		mm_struct.

mm_init():	Inherit the MCL_INHERIT and MCL_FUTURE
		state.  This will propagate across exec()
		via exec_mmap().

load_elf_binary(): Propagate VM_LOCKED in def_flags if mcl_inherit
		set in current->mm.  [Why does the elf loader
		muck with def_flags?  Other binary loaders
		don't.  Shouldn't this be in more generic code?]

Note:  A similar feature was implemented in at least one real time
enhanced Unix back in the 90's [Concurrent Computer's MaxOS]. 
Jeff Sharkey at Montana State developed a similar patch for Linux
[see: http://www.cs.montana.edu/~jsharkey/cs518/jsharkey-final.ppt],
but apparently he never submitted it.

Example "lock prefix command" at:
	http://free.linux.hp.com/~lts/Tools/mlock-latest.tar.gz

TODO:  man page enhancement, if patch accepted.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

 fs/binfmt_elf.c       |    4 ++++
 include/asm/mman.h    |    1 +
 include/linux/sched.h |    1 +
 kernel/fork.c         |   11 +++++++++--
 mm/mlock.c            |    5 +++--
 5 files changed, 18 insertions(+), 4 deletions(-)

Index: Linux/include/asm/mman.h
===================================================================
--- Linux.orig/include/asm/mman.h	2007-02-21 18:13:30.000000000 -0500
+++ Linux/include/asm/mman.h	2007-02-21 18:13:52.000000000 -0500
@@ -21,6 +21,7 @@
 
 #define MCL_CURRENT	1		/* lock all current mappings */
 #define MCL_FUTURE	2		/* lock all future mappings */
+#define MCL_INHERIT	4		/* inherit '_FUTURE across fork/exec */
 
 #ifdef __KERNEL__
 #ifndef __ASSEMBLY__
Index: Linux/include/linux/sched.h
===================================================================
--- Linux.orig/include/linux/sched.h	2007-02-21 18:13:30.000000000 -0500
+++ Linux/include/linux/sched.h	2007-02-21 18:13:52.000000000 -0500
@@ -325,6 +325,7 @@ struct mm_struct {
 	atomic_t mm_users;			/* How many users with user space? */
 	atomic_t mm_count;			/* How many references to "struct mm_struct" (users count as 1) */
 	int map_count;				/* number of VMAs */
+	int mcl_inherit;			/* inherit future locks */
 	struct rw_semaphore mmap_sem;
 	spinlock_t page_table_lock;		/* Protects page tables and some counters */
 
Index: Linux/mm/mlock.c
===================================================================
--- Linux.orig/mm/mlock.c	2007-02-21 18:13:30.000000000 -0500
+++ Linux/mm/mlock.c	2007-02-22 14:58:44.000000000 -0500
@@ -184,7 +184,8 @@ static int do_mlockall(int flags)
 	if (flags & MCL_FUTURE)
 		def_flags = VM_LOCKED;
 	current->mm->def_flags = def_flags;
-	if (flags == MCL_FUTURE)
+	current->mm->mcl_inherit = !!(flags & MCL_INHERIT);
+	if ((flags & ~MCL_INHERIT) == MCL_FUTURE)
 		goto out;
 
 	for (vma = current->mm->mmap; vma ; vma = prev->vm_next) {
@@ -206,7 +207,7 @@ asmlinkage long sys_mlockall(int flags)
 	unsigned long lock_limit;
 	int ret = -EINVAL;
 
-	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE)))
+	if (!flags || (flags & ~(MCL_CURRENT | MCL_FUTURE | MCL_INHERIT)))
 		goto out;
 
 	ret = -EPERM;
Index: Linux/kernel/fork.c
===================================================================
--- Linux.orig/kernel/fork.c	2007-02-21 18:13:30.000000000 -0500
+++ Linux/kernel/fork.c	2007-02-22 14:40:03.000000000 -0500
@@ -249,7 +249,8 @@ static inline int dup_mmap(struct mm_str
 		if (IS_ERR(pol))
 			goto fail_nomem_policy;
 		vma_set_policy(tmp, pol);
-		tmp->vm_flags &= ~VM_LOCKED;
+		if (!mm->mcl_inherit)
+			tmp->vm_flags &= ~VM_LOCKED;
 		tmp->vm_mm = mm;
 		tmp->vm_next = NULL;
 		anon_vma_link(tmp);
@@ -330,6 +331,8 @@ static inline void mm_free_pgd(struct mm
 
 static struct mm_struct * mm_init(struct mm_struct * mm)
 {
+	unsigned long def_flags = 0;
+
 	atomic_set(&mm->mm_users, 1);
 	atomic_set(&mm->mm_count, 1);
 	init_rwsem(&mm->mmap_sem);
@@ -343,9 +346,13 @@ static struct mm_struct * mm_init(struct
 	mm->ioctx_list = NULL;
 	mm->free_area_cache = TASK_UNMAPPED_BASE;
 	mm->cached_hole_size = ~0UL;
+	if (current->mm && current->mm->mcl_inherit) {
+		mm->mcl_inherit  = current->mm->mcl_inherit;
+		def_flags = current->mm->def_flags & VM_LOCKED;
+	}
 
 	if (likely(!mm_alloc_pgd(mm))) {
-		mm->def_flags = 0;
+		mm->def_flags = def_flags;
 		return mm;
 	}
 	free_mm(mm);
Index: Linux/fs/binfmt_elf.c
===================================================================
--- Linux.orig/fs/binfmt_elf.c	2007-02-22 12:54:54.000000000 -0500
+++ Linux/fs/binfmt_elf.c	2007-02-22 14:45:51.000000000 -0500
@@ -766,6 +766,10 @@ static int load_elf_binary(struct linux_
 		}
 	}
 
+	/* Optionally inherit MCL_FUTURE state before destroying old mm */
+	if (current->mm && current->mm->mcl_inherit)
+		def_flags = current->mm->def_flags & VM_LOCKED;
+
 	/* Flush all traces of the currently running executable */
 	retval = flush_old_exec(bprm);
 	if (retval)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
