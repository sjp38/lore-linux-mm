Date: Sat, 16 Jul 2005 20:21:51 -0700 (PDT)
From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [NUMA] Display and modify the memory policy of a process through
 /proc/<pid>/numa_policy
In-Reply-To: <20050716163030.0147b6ba.pj@sgi.com>
Message-ID: <Pine.LNX.4.62.0507162016470.27506@schroedinger.engr.sgi.com>
References: <20050715214700.GJ15783@wotan.suse.de>
 <Pine.LNX.4.62.0507151450570.11656@schroedinger.engr.sgi.com>
 <20050715220753.GK15783@wotan.suse.de> <Pine.LNX.4.62.0507151518580.12160@schroedinger.engr.sgi.com>
 <20050715223756.GL15783@wotan.suse.de> <Pine.LNX.4.62.0507151544310.12371@schroedinger.engr.sgi.com>
 <20050715225635.GM15783@wotan.suse.de> <Pine.LNX.4.62.0507151602390.12530@schroedinger.engr.sgi.com>
 <20050715234402.GN15783@wotan.suse.de> <Pine.LNX.4.62.0507151647300.12832@schroedinger.engr.sgi.com>
 <20050716020141.GO15783@wotan.suse.de> <20050716163030.0147b6ba.pj@sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Jackson <pj@sgi.com>
Cc: Andi Kleen <ak@suse.de>, kenneth.w.chen@intel.com, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 16 Jul 2005, Paul Jackson wrote:

> On the other hand, I hear him saying we can't do it, because the
> locking cannot be safely handled.

Here is one approach to locking using xchg. This is restricted only to the 
policy fields on task_struct and vm_area_struct. One could also 
synchronize by taking the alloc_lock in task_struct. I did not use xchg
during the population of vm_area_struct and task_struct and also not 
during the destruction of these structures.

There may be additional races that need to be dealt with depending on 
when the task struct and vm_area_struct become visible through the /proc 
filesystem. However, these races are then general races affecting the use 
of other fields in the 
/proc filesystem.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.13-rc3/mm/mempolicy.c
===================================================================
--- linux-2.6.13-rc3.orig/mm/mempolicy.c	2005-07-16 20:07:04.000000000 -0700
+++ linux-2.6.13-rc3/mm/mempolicy.c	2005-07-16 20:07:06.000000000 -0700
@@ -349,7 +349,7 @@ check_range(struct mm_struct *mm, unsign
 static int policy_vma(struct vm_area_struct *vma, struct mempolicy *new)
 {
 	int err = 0;
-	struct mempolicy *old = vma->vm_policy;
+	struct mempolicy *old;
 
 	PDprintk("vma %lx-%lx/%lx vm_ops %p vm_file %p set_policy %p\n",
 		 vma->vm_start, vma->vm_end, vma->vm_pgoff,
@@ -360,7 +360,7 @@ static int policy_vma(struct vm_area_str
 		err = vma->vm_ops->set_policy(vma, new);
 	if (!err) {
 		mpol_get(new);
-		vma->vm_policy = new;
+		old = xchg(&vma->vm_policy, new);
 		mpol_free(old);
 	}
 	return err;
@@ -451,8 +451,7 @@ asmlinkage long sys_set_mempolicy(int mo
 	new = mpol_new(mode, nodes);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
-	mpol_free(current->mempolicy);
-	current->mempolicy = new;
+	mpol_free(xchg(&current->mempolicy, new));
 	if (new && new->policy == MPOL_INTERLEAVE)
 		current->il_next = find_first_bit(new->v.nodes, MAX_NUMNODES);
 	return 0;
Index: linux-2.6.13-rc3/kernel/exit.c
===================================================================
--- linux-2.6.13-rc3.orig/kernel/exit.c	2005-07-12 21:46:46.000000000 -0700
+++ linux-2.6.13-rc3/kernel/exit.c	2005-07-16 20:07:06.000000000 -0700
@@ -851,8 +851,7 @@ fastcall NORET_TYPE void do_exit(long co
 	tsk->exit_code = code;
 	exit_notify(tsk);
 #ifdef CONFIG_NUMA
-	mpol_free(tsk->mempolicy);
-	tsk->mempolicy = NULL;
+	mpol_free(xchg(&tsk->mempolicy, NULL));
 #endif
 
 	BUG_ON(!(current->flags & PF_DEAD));
Index: linux-2.6.13-rc3/include/linux/mm.h
===================================================================
--- linux-2.6.13-rc3.orig/include/linux/mm.h	2005-07-12 21:46:46.000000000 -0700
+++ linux-2.6.13-rc3/include/linux/mm.h	2005-07-16 20:07:06.000000000 -0700
@@ -107,7 +107,9 @@ struct vm_area_struct {
 	atomic_t vm_usage;		/* refcount (VMAs shared if !MMU) */
 #endif
 #ifdef CONFIG_NUMA
-	struct mempolicy *vm_policy;	/* NUMA policy for the VMA */
+	struct mempolicy *vm_policy;	/* NUMA policy for the VMA, may be updated only
+					 * with xchg or cmpxchg
+					 */
 #endif
 };
 
Index: linux-2.6.13-rc3/include/linux/sched.h
===================================================================
--- linux-2.6.13-rc3.orig/include/linux/sched.h	2005-07-16 19:54:14.000000000 -0700
+++ linux-2.6.13-rc3/include/linux/sched.h	2005-07-16 20:07:06.000000000 -0700
@@ -761,7 +761,10 @@ struct task_struct {
 	clock_t acct_stimexpd;	/* clock_t-converted stime since last update */
 #endif
 #ifdef CONFIG_NUMA
-  	struct mempolicy *mempolicy;
+  	struct mempolicy *mempolicy;	/* Only update via xchg or cmpxchg because mempolicy
+					 * may be changed from outside of the process
+					 * context
+					 */
 	short il_next;
 #endif
 #ifdef CONFIG_CPUSETS
Index: linux-2.6.13-rc3/fs/proc/task_mmu.c
===================================================================
--- linux-2.6.13-rc3.orig/fs/proc/task_mmu.c	2005-07-16 20:07:04.000000000 -0700
+++ linux-2.6.13-rc3/fs/proc/task_mmu.c	2005-07-16 20:08:49.000000000 -0700
@@ -357,7 +357,7 @@ static ssize_t numa_policy_write(struct 
 {
 	struct task_struct *task = proc_task(file->f_dentry->d_inode);
 	char buffer[MAX_MEMPOL_STRING_SIZE], *end;
-	struct mempolicy *pol, *old_policy;
+	struct mempolicy *pol;
 
 	if (!capable(CAP_SYS_RESOURCE))
 		return -EPERM;
@@ -373,17 +373,10 @@ static ssize_t numa_policy_write(struct 
 	if (*end == '\n')
 		end++;
 
-	old_policy = task->mempolicy;
+	if (pol->policy == MPOL_DEFAULT)
+		pol = NULL;
 
-
-	if (!mpol_equal(pol, old_policy)) {
-		if (pol->policy == MPOL_DEFAULT)
-			pol = NULL;
-
-		task->mempolicy = pol;
-		mpol_free(old_policy);
-	} else
-		mpol_free(pol);
+	mpol_free(xchg(&task->mempolicy, pol));
 
 	return end - buffer;
 }
@@ -402,7 +395,7 @@ static ssize_t numa_vma_policy_write(str
 	unsigned long addr;
 	char buffer[MAX_MEMPOL_STRING_SIZE];
 	char *p, *end;
-	struct mempolicy *pol, *old_policy;
+	struct mempolicy *pol;
 
 	if (!capable(CAP_SYS_RESOURCE))
 		return -EPERM;
@@ -426,16 +419,10 @@ static ssize_t numa_vma_policy_write(str
 	if (*end == '\n')
 		end++;
 
-	old_policy = vma->vm_policy;
+	if (pol->policy == MPOL_DEFAULT)
+		pol = NULL;
 
-	if (!mpol_equal(pol, old_policy)) {
-		if (pol->policy == MPOL_DEFAULT)
-			pol = NULL;
-
-		vma->vm_policy = pol;
-		mpol_free(old_policy);
-	} else
-		mpol_free(pol);
+	mpol_free(xchg(&vma->vm_policy, pol));
 
 	return end - buffer;
 }
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
