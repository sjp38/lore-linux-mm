Date: Tue, 18 Oct 2005 11:30:03 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: [PATCH] Allow outside read access to a tasks memory policy
Message-ID: <Pine.LNX.4.62.0510181126280.8305@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: akpm@osdl.org, linux-mm@kvack.org, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Currently access to the memory policy of a task from outside of a task is not
possible since there are no locking conventions. A task must always be
able to access its memory policy without the necessity to take a lock in
order to allow alloc_pages to operate efficiently.

Access to the tasks memory policy from the outside is likely going to be
needed for page migration. In case of an ECC failure or a memory unplug
operation, new memory needs to be allocated for a task following its memory
policy. However, that operation is done from outside of the task itself. 

Read access may be permitted if the changes of the task to its memory policy
are protected by a lock. The accessor from the outside will then take that
lock and is guaranteed that no changes to the memory policy occur while
the access takes place.

No write access is possible since the task itself may need to read the memory
policy at any time and will do so without taking any locks.

For vma based policy changes a task takes the mmap_sem lock. This patch implements
the same mechanism for the task based policies. The task takes a writelock
on mmap_sem. Outside readers must take a readlock on mmap_sem.

Thus:

1. Require that a readlock be taken on mmap_sem when invoking get_vma_policy
   or that get_vma_policy be invoked for the current task.
   (this is the case for curent uses of get_vma_policy)

2. We can then insure that the policy is not modified by taking a write lock
   on mmap_sem in do_set_mempolicy.

A Mmap_sem lock cannot be taken for a kernel thread that has no memory
(task->mm == NULL). This is safe since kernel threads do not change their
memory policy after startup. Kernel threads do not own any memory.

There is actually already a case in the /proc filesystem of a potential
access to the memory policy of a task via get_vma_policy if /proc/<pid>/numa_maps
is displayed.

If there is no policy defined for a vma then a pointer to the tasks policy may
be returned. This patch guarantees that the policy pointed to by
task->mempolicy is not changed by do_set_mempolicy while another process is
using the result of get_vma_policy.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.14-rc4-mm1/mm/mempolicy.c
===================================================================
--- linux-2.6.14-rc4-mm1.orig/mm/mempolicy.c	2005-10-18 10:31:22.000000000 -0700
+++ linux-2.6.14-rc4-mm1/mm/mempolicy.c	2005-10-18 11:12:02.000000000 -0700
@@ -443,16 +443,21 @@ long do_mbind(unsigned long start, unsig
 long do_set_mempolicy(int mode, nodemask_t *nodes)
 {
 	struct mempolicy *new;
+	struct mm_struct *mm = current->mm;
 
 	if (contextualize_policy(mode, nodes))
 		return -EINVAL;
 	new = mpol_new(mode, nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
+	if (mm)
+		down_write(&mm->mmap_sem);
 	mpol_free(current->mempolicy);
 	current->mempolicy = new;
 	if (new && new->policy == MPOL_INTERLEAVE)
 		current->il_next = first_node(new->v.nodes);
+	if (mm)
+		up_write(&mm->mmap_sem);
 	return 0;
 }
 
@@ -827,7 +832,15 @@ asmlinkage long compat_sys_mbind(compat_
 
 #endif
 
-/* Return effective policy for a VMA */
+/*
+ * Return effective policy for a VMA
+ *
+ * Note that the function may return the tasks memory policy if there
+ * is no policy defined for the vma.
+ *
+ * mmap_sem must be held for as long as the pointer returned is in use
+ * or task == current.
+ */
 struct mempolicy *
 get_vma_policy(struct task_struct *task, struct vm_area_struct *vma, unsigned long addr)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
