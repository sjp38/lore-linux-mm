Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id BE5E16B004A
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:08:45 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 23 Feb 2012 13:08:09 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 1099438C8054
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:08:05 -0500 (EST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1NI83kd336524
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 13:08:03 -0500
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1NI83c5005156
	for <linux-mm@kvack.org>; Thu, 23 Feb 2012 11:08:03 -0700
Subject: [RFC][PATCH] fix move/migrate_pages() race on task struct
From: Dave Hansen <dave@linux.vnet.ibm.com>
Date: Thu, 23 Feb 2012 10:07:40 -0800
Message-Id: <20120223180740.C4EC4156@kernel>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave@linux.vnet.ibm.com>


sys_move_pages() and sys_migrate_pages() are a pretty nice copy
and paste job of each other.  They both take a pid, find the task
struct, and then grab a ref on the mm.  They both also do an
rcu_read_unlock() after they've taken the mm and then proceed to
access 'task'.  I think this is a bug in both cases.

I haven't been able to get it to trigger without adding some
healthy spinning in migrate_pages():

	for (x = 0; x < 1ULL<<28; x++)
		barrier();

Granted, that's a horribly silly thing to do, but I think it's
"valid" in that it does not sleep; it just just widens the race
window.  After adding the loop, if I just run a kernel compile
and then a bunch of copies of "migratepages `pidof -s gcc` 0 0"
it'll oops pretty fast dereferencing cred:

SYSCALL_DEFINE4(migrate_pages, pid_t, pid, unsigned long, maxnode,
...
        rcu_read_lock();
        tcred = __task_cred(task);
--->    if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
            cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
            !capable(CAP_SYS_NICE)) {
                rcu_read_unlock();
                err = -EPERM;
                goto out;
        }
        rcu_read_unlock();

I think I got lucky that my task_struct was bogus in the oops
below.  It's probably quite feasible that a task_struct could get
freed back in to the slab, reallocated as another task_struct,
and then we do these cred checks against a valid, but basically
random task.

This patch takes the pid-to-task code along with the credential
and security checks in sys_move_pages() and sys_migrate_pages()
and consolidates them.  It now takes a task reference in
the new function and requires the caller to drop it.  I
believe this resolves the race.

Sample oops below:

BUG: unable to handle kernel paging request at ffff880072ab8ce0
IP: [<ffffffff810c3b1c>] sys_migrate_pages+0xc0/0x180
PGD 1606063 PUD 1fdfd067 PMD 1ff93067 PTE 8000000072ab8160
Oops: 0000 [#17] PREEMPT SMP DEBUG_PAGEALLOC
CPU 14 
Modules linked in:

Pid: 12880, comm: migratepages Tainted: G      D      3.2.0-rc2-qemubigsmp-00110-gb6955fa-dirty #505 Bochs Bochs
RIP: 0010:[<ffffffff810c3b1c>]  [<ffffffff810c3b1c>] sys_migrate_pages+0xc0/0x180
RSP: 0018:ffff88005f54df28  EFLAGS: 00010202
RAX: ffff8800724d59d0 RBX: 00000000ffffffea RCX: 0000000000000000
RDX: 0000000000000014 RSI: 0000000000000000 RDI: ffff880072ab8e60
RBP: ffff88005f54df78 R08: 1fffffffffffffff R09: 00000000000031ed
R10: 0000000000603130 R11: 0000000000000246 R12: ffff880072ab89d0
R13: ffff880060c0bca0 R14: ffff8800724d59d0 R15: 0000000000603130
FS:  00007fb05c7ad720(0000) GS:ffff88007fdc0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffff880072ab8ce0 CR3: 000000006e47f000 CR4: 00000000000006a0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process migratepages (pid: 12880, threadinfo ffff88005f54c000, task ffff8800724d59d0)
Stack:
 000031ed00400b60 ffff880072a08818 0000000000000001 0000000000000001
 00007fff66bbae50 00000000000031ed 0000000000603110 00007fff66bbae40
 0000000000000000 0000000000000000 00000000006030d0 ffffffff813ebe3b
Call Trace:
 [<ffffffff813ebe3b>] system_call_fastpath+0x16/0x1b
Code: 83 f6 ff 49 89 c5 e8 90 c3 fa ff 31 c0 48 ff c0 48 3d 00 00 00 10 75 f5 4d 85 ed bb ea ff ff ff 0f 84 b3 00 00 00 e8 f5 bc fa ff 
 8b 84 24 10 03 00 00 48 8b 4d b8 8b 70 0c 8b 51 14 39 f2 74 
RIP  [<ffffffff810c3b1c>] sys_migrate_pages+0xc0/0x180
 RSP <ffff88005f54df28>
CR2: ffff880072ab8ce0
---[ end trace 942060673021a7ae ]---

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>
---

 linux-2.6.git-dave/include/linux/migrate.h |    1 
 linux-2.6.git-dave/mm/mempolicy.c          |   44 +++-------------
 linux-2.6.git-dave/mm/migrate.c            |   76 +++++++++++++++++------------
 3 files changed, 57 insertions(+), 64 deletions(-)

diff -puN include/linux/migrate.h~movememory-helper include/linux/migrate.h
--- linux-2.6.git/include/linux/migrate.h~movememory-helper	2012-02-16 09:59:17.270207242 -0800
+++ linux-2.6.git-dave/include/linux/migrate.h	2012-02-16 09:59:17.286207438 -0800
@@ -31,6 +31,7 @@ extern int migrate_vmas(struct mm_struct
 extern void migrate_page_copy(struct page *newpage, struct page *page);
 extern int migrate_huge_page_move_mapping(struct address_space *mapping,
 				  struct page *newpage, struct page *page);
+struct task_struct *can_migrate_get_task(pid_t pid);
 #else
 #define PAGE_MIGRATION 0
 
diff -puN mm/mempolicy.c~movememory-helper mm/mempolicy.c
--- linux-2.6.git/mm/mempolicy.c~movememory-helper	2012-02-16 09:59:17.274207291 -0800
+++ linux-2.6.git-dave/mm/mempolicy.c	2012-02-16 09:59:17.286207438 -0800
@@ -1314,59 +1314,33 @@ SYSCALL_DEFINE4(migrate_pages, pid_t, pi
 	if (err)
 		goto out;
 
-	/* Find the mm_struct */
-	rcu_read_lock();
-	task = pid ? find_task_by_vpid(pid) : current;
-	if (!task) {
-		rcu_read_unlock();
-		err = -ESRCH;
-		goto out;
-	}
+	task = can_migrate_get_task(pid);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
 	mm = get_task_mm(task);
-	rcu_read_unlock();
-
 	err = -EINVAL;
 	if (!mm)
-		goto out;
-
-	/*
-	 * Check if this process has the right to modify the specified
-	 * process. The right exists if the process has administrative
-	 * capabilities, superuser privileges or the same
-	 * userid as the target process.
-	 */
-	rcu_read_lock();
-	tcred = __task_cred(task);
-	if (cred->euid != tcred->suid && cred->euid != tcred->uid &&
-	    cred->uid  != tcred->suid && cred->uid  != tcred->uid &&
-	    !capable(CAP_SYS_NICE)) {
-		rcu_read_unlock();
-		err = -EPERM;
-		goto out;
-	}
-	rcu_read_unlock();
+		goto out_put_task;
 
 	task_nodes = cpuset_mems_allowed(task);
 	/* Is the user allowed to access the target nodes? */
 	if (!nodes_subset(*new, task_nodes) && !capable(CAP_SYS_NICE)) {
 		err = -EPERM;
-		goto out;
+		goto out_put_task;
 	}
 
 	if (!nodes_subset(*new, node_states[N_HIGH_MEMORY])) {
 		err = -EINVAL;
-		goto out;
+		goto out_put_task;
 	}
 
-	err = security_task_movememory(task);
-	if (err)
-		goto out;
-
 	err = do_migrate_pages(mm, old, new,
 		capable(CAP_SYS_NICE) ? MPOL_MF_MOVE_ALL : MPOL_MF_MOVE);
-out:
+out_put_task:
 	if (mm)
 		mmput(mm);
+	put_task_struct(task);
+out:
 	NODEMASK_SCRATCH_FREE(scratch);
 
 	return err;
diff -puN mm/migrate.c~movememory-helper mm/migrate.c
--- linux-2.6.git/mm/migrate.c~movememory-helper	2012-02-16 09:59:17.278207340 -0800
+++ linux-2.6.git-dave/mm/migrate.c	2012-02-16 09:59:17.286207438 -0800
@@ -1339,38 +1339,22 @@ static int do_pages_stat(struct mm_struc
 }
 
 /*
- * Move a list of pages in the address space of the currently executing
- * process.
+ * If successful, takes a task_struct reference that
+ * the caller is responsible for releasing.
  */
-SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
-		const void __user * __user *, pages,
-		const int __user *, nodes,
-		int __user *, status, int, flags)
+struct task_struct *can_migrate_get_task(pid_t pid)
 {
-	const struct cred *cred = current_cred(), *tcred;
 	struct task_struct *task;
-	struct mm_struct *mm;
-	int err;
-
-	/* Check flags */
-	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
-		return -EINVAL;
-
-	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
-		return -EPERM;
+	const struct cred *cred = current_cred(), *tcred;
+	int err = 0;
 
-	/* Find the mm_struct */
 	rcu_read_lock();
 	task = pid ? find_task_by_vpid(pid) : current;
 	if (!task) {
 		rcu_read_unlock();
-		return -ESRCH;
+		return ERR_PTR(-ESRCH);
 	}
-	mm = get_task_mm(task);
-	rcu_read_unlock();
-
-	if (!mm)
-		return -EINVAL;
+	get_task_struct(task);
 
 	/*
 	 * Check if this process has the right to modify the specified
@@ -1378,20 +1362,53 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, 
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
 		goto out;
 	}
-	rcu_read_unlock();
 
  	err = security_task_movememory(task);
- 	if (err)
-		goto out;
+
+out:
+	rcu_read_unlock();
+ 	if (err) {
+		put_task_struct(task);
+		return ERR_PTR(err);
+	}
+	return task;
+}
+
+/*
+ * Move a list of pages in the address space of the currently executing
+ * process.
+ */
+SYSCALL_DEFINE6(move_pages, pid_t, pid, unsigned long, nr_pages,
+		const void __user * __user *, pages,
+		const int __user *, nodes,
+		int __user *, status, int, flags)
+{
+	struct task_struct *task;
+	struct mm_struct *mm;
+	int err;
+
+	/* Check flags */
+	if (flags & ~(MPOL_MF_MOVE|MPOL_MF_MOVE_ALL))
+		return -EINVAL;
+
+	if ((flags & MPOL_MF_MOVE_ALL) && !capable(CAP_SYS_NICE))
+		return -EPERM;
+
+	task = can_migrate_get_task(pid);
+	if (IS_ERR(task))
+		return PTR_ERR(task);
+	mm = get_task_mm(task);
+	if (!mm) {
+		err = -EINVAL;
+		goto out_put_task;
+	}
 
 	if (nodes) {
 		err = do_pages_move(mm, task, nr_pages, pages, nodes, status,
@@ -1400,8 +1417,9 @@ SYSCALL_DEFINE6(move_pages, pid_t, pid, 
 		err = do_pages_stat(mm, nr_pages, pages, status);
 	}
 
-out:
 	mmput(mm);
+out_put_task:
+	put_task_struct(task);
 	return err;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
