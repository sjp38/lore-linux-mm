Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id B87ED6B007E
	for <linux-mm@kvack.org>; Tue, 28 Feb 2012 14:30:22 -0500 (EST)
Date: Tue, 28 Feb 2012 13:30:19 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH] fix move/migrate_pages() race on task struct
In-Reply-To: <alpine.DEB.2.00.1202271636230.6435@router.home>
Message-ID: <alpine.DEB.2.00.1202281329190.25590@router.home>
References: <20120223180740.C4EC4156@kernel> <alpine.DEB.2.00.1202231240590.9878@router.home> <4F468F09.5050200@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231334290.10914@router.home> <4F469BC7.50705@linux.vnet.ibm.com> <alpine.DEB.2.00.1202231536240.13554@router.home>
 <m1ehtkapn9.fsf@fess.ebiederm.org> <alpine.DEB.2.00.1202240859340.2621@router.home> <4F47BF56.6010602@linux.vnet.ibm.com> <alpine.DEB.2.00.1202241053220.3726@router.home> <alpine.DEB.2.00.1202241105280.3726@router.home> <4F47C800.4090903@linux.vnet.ibm.com>
 <alpine.DEB.2.00.1202241131400.3726@router.home> <87sjhzun47.fsf@xmission.com> <alpine.DEB.2.00.1202271238450.32410@router.home> <87d390janv.fsf@xmission.com> <alpine.DEB.2.00.1202271636230.6435@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org

Here is a cleaned up version of the patch. No longer rely on the
task_struct pointer to be NULL for release of the refcount.




Subject: migration: Fix rcu and task refcounting

Migration functions perform the rcu_read_unlock too early. As a result the
task pointed to may change from under us.

The following patch extend the period of the rcu_read_lock until after the
permissions checks are done. We also take a refcount so that the task
reference is stable when calling security check functions and performing
cpuset node validation (which takes a mutex).

The refcount is dropped before actual page migration occurs so there is no
change to the refcounts held during page migration.

Also move the determination of the mm of the task struct to immediately
before the do_migrate*() calls so that it is clear that we switch from
handling the task during permission checks to the mm for the actual
migration. Since the determination is only done once and we then no longer
use the task_struct we can be sure that we operate on a specific address
space that will not change from under us.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 mm/mempolicy.c |   32 +++++++++++++++++++-------------
 mm/migrate.c   |   36 +++++++++++++++++++-----------------
 2 files changed, 38 insertions(+), 30 deletions(-)

Index: linux-2.6/mm/mempolicy.c
===================================================================
--- linux-2.6.orig/mm/mempolicy.c	2012-02-28 03:56:41.236184783 -0600
+++ linux-2.6/mm/mempolicy.c	2012-02-28 07:22:35.245552282 -0600
@@ -1322,12 +1322,9 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 		err = -ESRCH;
 		goto out;
 	}
-	mm = get_task_mm(task);
-	rcu_read_unlock();
+	get_task_struct(task);

 	err = -EINVAL;
-	if (!mm)
-		goto out;

 	/*
 	 * Check if this process has the right to modify the specified
@@ -1335,14 +1332,13 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 	 * capabilities, superuser privileges or the same
 	 * userid as the target process.
 	 */
-	rcu_read_lock();
 	tcred = __task_cred(task);
 	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
 	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
 	    !capable(CAP_SYS_NICE)) {
 		rcu_read_unlock();
 		err = -EPERM;
-		goto out;
+		goto out_put;
 	}
 	rcu_read_unlock();

@@ -1350,26 +1346,36 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 	/* Is the user allowed to access the target nodes? */
 	if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
-		goto out;
+		goto out_put;
 	}

 	if (!nodes_subset(*new, node_states[N_HIGH_MEMORY])) {
 		err = -EINVAL;
-		goto out;
+		goto out_put;
 	}

 	err = security_task_movememory(task);
 	if (err)
-		goto out;
+		goto out_put;

-	err = do_migrate_pages(mm, old, new,
-		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
-out:
+	mm = get_task_mm(task);
+	put_task_struct(task);
 	if (mm)
-		mmput(mm);
+		err = do_migrate_pages(mm, old, new,
+			capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
+	else
+		err = -EINVAL;
+
+	mmput(mm);
+out:
 	NODEMASK_SCRATCH_FREE(scratch);

 	return err;
+
+out_put:
+	put_task_struct(task);
+	goto out;
+
 }


Index: linux-2.6/mm/migrate.c
===================================================================
--- linux-2.6.orig/mm/migrate.c	2012-02-28 06:15:38.239956766 -0600
+++ linux-2.6/mm/migrate.c	2012-02-28 07:18:08.237559577 -0600
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
@@ -1366,11 +1364,7 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
 		rcu_read_unlock();
 		return -ESRCH;
 	}
-	mm = get_task_mm(task);
-	rcu_read_unlock();
-
-	if (!mm)
-		return -EINVAL;
+	get_task_struct(task);

 	/*
 	 * Check if this process has the right to modify the specified
@@ -1378,7 +1372,6 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
 	 * capabilities, superuser privileges or the same
 	 * userid as the target process.
 	 */
-	rcu_read_lock();
 	tcred = __task_cred(task);
 	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
 	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
@@ -1393,16 +1386,25 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid,
  	if (err)
 		goto out;

-	if (nodes) {
-		err = do_pages_move(mm, task, nr_pages, pages, nodes, status,
-				    flags);
-	} else {
-		err = do_pages_stat(mm, nr_pages, pages, status);
-	}
+	task_nodes = cpuset_mems_allowed(task);
+	mm = get_task_mm(task);
+	put_task_struct(task);
+
+	if (mm) {
+		if (nodes)
+			err = do_pages_move(mm, task_nodes, nr_pages, pages, nodes,
+				status, flags);
+		else
+			err = do_pages_stat(mm, nr_pages, pages, status);
+	} else
+		err = -EINVAL;

-out:
 	mmput(mm);
 	return err;
+
+out:
+	put_task_struct(task);
+	return err;
 }

 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
