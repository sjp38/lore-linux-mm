Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx123.postini.com [74.125.245.123])
	by kanga.kvack.org (Postfix) with SMTP id 0D52A6B004A
	for <linux-mm@kvack.org>; Fri, 24 Feb 2012 10:20:56 -0500 (EST)
Date: Fri, 24 Feb 2012 09:20:54 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <m1ehtkapn9.fsf@fess.ebiederm.org>
Message-ID: <alpine.DEB.2.00.1202240859340.2621@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home>
 <m1ehtkapn9.fsf@fess.ebiederm.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 23 Feb 2012, Eric W. Biederman wrote:

> > The bug in migrate_pages() is that we do a rcu_unlock and a rcu_lock. If
> > we drop those then we should be safe if the use of a task pointer within a
> > rcu section is safe without taking a refcount.
>
> Yes the user of a task_struct pointer found via a userspace pid is valid
> for the life of an rcu critical section, and the bug is indeed that we
> drop the rcu_lock and somehow expect the task to remain valid.
>
> The guarantee comes from release_task.  In release_task we call
> __exit_signal which calls __unhash_process, and then we call
> delayed_put_task to guarantee that the task lives until the end of the
> rcu interval.

Ah. Ok. Great.

> In migrate_pages we have a lot of task accesses outside of the rcu
> critical section, and without a reference count on task.

Yes but that is only of interesting for setup and verification of
permissions. What matters during migration is that the mm_struct does not
go away and we take a refcount on that one.

> I tell you the truth trying to figure out what that code needs to be
> correct if task != current makes my head hurt.

Hmm...

> I think we need to grab a reference on task_struct, to stop the task
> from going away, and in addition we need to hold task_lock.  To keep
> task->mm from changing (see exec_mmap).  But we can't do that and sleep
> so I think the entire function needs to be rewritten, and the need for
> task deep in the migrate_pages path needs to be removed as even with the
> reference count held we can race with someone calling exec.

We dont need the task during migration. We only need the mm. The task
is safe until rcu_read_unlock therefore maybe the following should fix
migrate pages:


Subject: migration: Do not do rcu_read_unlock until the last time we need the task_struct pointer

Migration functions perform the rcu_read_unlock too early. As a result the
task pointed to may change. Bugs were introduced when adding security checks
because rcu_unlock/lock sequences were inserted. Plus the security checks
and do_move_pages used the task_struct pointer after rcu_unlock.

Fix those issues by removing the unlock/lock sequences and moving the
rcu_read_unlock after the last use of the task struct pointer.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 mm/mempolicy.c |   22 +++++++++++-----------
 mm/migrate.c   |   28 +++++++++++++++-------------
 2 files changed, 26 insertions(+), 24 deletions(-)

Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2012-01-13 04:04:36.229807226 -0600
+++ linux-2.6/mm/mempolicy.c	2012-02-24 03:11:44.913710625 -0600
@@ -1318,16 +1318,14 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 	rcu_read_lock();
 	task = pid ? find_task_by_vpid(pid) : current;
 	if (!task) {
-		rcu_read_unlock();
 		err = -ESRCH;
-		goto out;
+		goto unlock_out;
 	}
 	mm = get_task_mm(task);
-	rcu_read_unlock();

 	err = -EINVAL;
 	if (!mm)
-		goto out;
+		goto unlock_out;

 	/*
 	 * Check if this process has the right to modify the specified
@@ -1335,33 +1333,31 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 	 * capabilities, superuser privileges or the same
 	 * userid as the target process.
 	 */
-	rcu_read_lock();
 	tcred = __task_cred(task);
 	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
 	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
 	    !capable(CAP_SYS_NICE)) {
-		rcu_read_unlock();
 		err = -EPERM;
-		goto out;
+		goto unlock_out;
 	}
-	rcu_read_unlock();

 	task_nodes = cpuset_mems_allowed(task);
 	/* Is the user allowed to access the target nodes? */
 	if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
-		goto out;
+		goto unlock_out;
 	}

 	if (!nodes_subset(*new, node_states[N_HIGH_MEMORY])) {
 		err = -EINVAL;
-		goto out;
+		goto unlock_out;
 	}

 	err = security_task_movememory(task);
 	if (err)
-		goto out;
+		goto unlock_out;

+	rcu_read_unlock();
 	err = do_migrate_pages(mm, old, new,
 		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
 out:
@@ -1370,6 +1366,10 @@ out:
 	NODEMASK_SCRATCH_FREE(scratch);

 	return err;
+
+unlock_out:
+	rcu_read_unlock();
+	goto out;
 }


Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2012-02-06 04:25:35.857094372 -0600
+++ linux-2.6/mm/migrate.c	2012-02-24 03:18:55.569698851 -0600
@@ -1176,20 +1176,17 @@ set_status:
  * Migrate an array of page address onto an array of nodes and fill
  * the corresponding array of status.
  */
-static int do_pages_move(struct mm_struct *mm, struct task_struct *task,
+static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			 unsigned long nr_pages,
 			 const void __user * __user *pages,
 			 const int __user *nodes,
 			 int __user *status, int flags)
 {
 	struct page_to_node *pm;
-	nodemask_t task_nodes;
 	unsigned long chunk_nr_pages;
 	unsigned long chunk_start;
 	int err;

-	task_nodes = cpuset_mems_allowed(task);
-
 	err = -ENOMEM;
 	pm = (struct page_to_node *)__get_free_page(GFP_KERNEL);
 	if (!pm)
@@ -1351,6 +1348,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
 	struct task_struct *task;
 	struct mm_struct *mm;
 	int err;
+	nodemask_t task_nodes;

 	/* Check flags */
 	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
@@ -1367,10 +1365,11 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
 		return -ESRCH;
 	}
 	mm = get_task_mm(task);
-	rcu_read_unlock();

-	if (!mm)
+	if (!mm) {
+		rcu_read_unlock();
 		return -EINVAL;
+	}

 	/*
 	 * Check if this process has the right to modify the specified
@@ -1378,24 +1377,23 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
 	 * capabilities, superuser privileges or the same
 	 * userid as the target process.
 	 */
-	rcu_read_lock();
 	tcred = __task_cred(task);
 	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
 	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
 	    !capable(CAP_SYS_NICE)) {
-		rcu_read_unlock();
 		err = -EPERM;
-		goto out;
+		goto unlock_out;
 	}
-	rcu_read_unlock();

  	err = security_task_movememory(task);
  	if (err)
-		goto out;
+		goto unlock_out;

+	task_nodes = cpuset_mems_allowed(task);
+	rcu_read_unlock();
 	if (nodes) {
-		err = do_pages_move(mm, task, nr_pages, pages, nodes, status,
-				    flags);
+		err = do_pages_move(mm, task_nodes, nr_pages, pages, nodes,
+				status, flags);
 	} else {
 		err = do_pages_stat(mm, nr_pages, pages, status);
 	}
@@ -1403,6 +1401,10 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
 out:
 	mmput(mm);
 	return err;
+
+unlock_out:
+	rcu_read_unlock();
+	goto out;
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
