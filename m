Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 616716B0038
	for <linux-mm@kvack.org>; Mon, 17 Oct 2016 12:41:58 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h24so147964218pfh.0
        for <linux-mm@kvack.org>; Mon, 17 Oct 2016 09:41:58 -0700 (PDT)
Received: from out02.mta.xmission.com (out02.mta.xmission.com. [166.70.13.232])
        by mx.google.com with ESMTPS id 74si31509520pfs.231.2016.10.17.09.41.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 17 Oct 2016 09:41:57 -0700 (PDT)
From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 17 Oct 2016 11:39:49 -0500
Message-ID: <87twcbq696.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [REVIEW][PATCH] mm: Add a user_ns owner to mm_struct and fix ptrace_may_access
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Containers <containers@lists.linux-foundation.org>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Serge E. Hallyn" <serge@hallyn.com>, Oleg Nesterov <oleg@redhat.com>, Andy Lutomirski <luto@amacapital.net>, linux-kernel@vger.kernel.org


During exec dumpable is cleared if the file that is being executed is
not readable by the user executing the file.  A bug in
ptrace_may_access allows reading the file if the executable happens to
enter into a subordinate user namespace (aka clone(CLONE_NEWUSER),
unshare(CLONE_NEWUSER), or setns(fd, CLONE_NEWUSER).

This problem is fixed with only necessary userspace breakage by adding
a user namespace owner to mm_struct, captured at the time of exec,
so it is clear in which user namespace CAP_SYS_PTRACE must be present
in to be able to safely give read permission to the executable.

The function ptrace_may_access is modified to verify that the ptracer
has CAP_SYS_ADMIN in task->mm->user_ns instead of task->cred->user_ns.
This ensures that if the task changes it's cred into a subordinate
user namespace it does not become ptraceable.

Cc: stable@vger.kernel.org
Fixes: 8409cca70561 ("userns: allow ptrace from non-init user namespaces")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---

It turns out that dumpable needs to be fixed to be user namespace
aware to fix this issue.  When this patch is ready I plan to place it in
my userns tree and send it to Linus, hopefully for -rc2.

 include/linux/mm_types.h |  1 +
 kernel/fork.c            |  9 ++++++---
 kernel/ptrace.c          | 17 ++++++-----------
 mm/init-mm.c             |  2 ++
 4 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 4a8acedf4b7d..08d947fc4c59 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -473,6 +473,7 @@ struct mm_struct {
 	 */
 	struct task_struct __rcu *owner;
 #endif
+	struct user_namespace *user_ns;
 
 	/* store ref to file /proc/<pid>/exe symlink points to */
 	struct file __rcu *exe_file;
diff --git a/kernel/fork.c b/kernel/fork.c
index 623259fc794d..fd85c68c2791 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -742,7 +742,8 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 #endif
 }
 
-static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
+static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
+	struct user_namespace *user_ns)
 {
 	mm->mmap = NULL;
 	mm->mm_rb = RB_ROOT;
@@ -782,6 +783,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p)
 	if (init_new_context(p, mm))
 		goto fail_nocontext;
 
+	mm->user_ns = get_user_ns(user_ns);
 	return mm;
 
 fail_nocontext:
@@ -827,7 +829,7 @@ struct mm_struct *mm_alloc(void)
 		return NULL;
 
 	memset(mm, 0, sizeof(*mm));
-	return mm_init(mm, current);
+	return mm_init(mm, current, current_user_ns());
 }
 
 /*
@@ -842,6 +844,7 @@ void __mmdrop(struct mm_struct *mm)
 	destroy_context(mm);
 	mmu_notifier_mm_destroy(mm);
 	check_mm(mm);
+	put_user_ns(mm->user_ns);
 	free_mm(mm);
 }
 EXPORT_SYMBOL_GPL(__mmdrop);
@@ -1123,7 +1126,7 @@ static struct mm_struct *dup_mm(struct task_struct *tsk)
 
 	memcpy(mm, oldmm, sizeof(*mm));
 
-	if (!mm_init(mm, tsk))
+	if (!mm_init(mm, tsk, mm->user_ns))
 		goto fail_nomem;
 
 	err = dup_mmap(mm, oldmm);
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 2a99027312a6..f2d1b9afb3f8 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -220,7 +220,7 @@ static int ptrace_has_cap(struct user_namespace *ns, unsigned int mode)
 static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 {
 	const struct cred *cred = current_cred(), *tcred;
-	int dumpable = 0;
+	struct mm_struct *mm;
 	kuid_t caller_uid;
 	kgid_t caller_gid;
 
@@ -271,16 +271,11 @@ static int __ptrace_may_access(struct task_struct *task, unsigned int mode)
 	return -EPERM;
 ok:
 	rcu_read_unlock();
-	smp_rmb();
-	if (task->mm)
-		dumpable = get_dumpable(task->mm);
-	rcu_read_lock();
-	if (dumpable != SUID_DUMP_USER &&
-	    !ptrace_has_cap(__task_cred(task)->user_ns, mode)) {
-		rcu_read_unlock();
-		return -EPERM;
-	}
-	rcu_read_unlock();
+	mm = task->mm;
+	if (!mm ||
+	    ((get_dumpable(mm) != SUID_DUMP_USER) &&
+	     !ptrace_has_cap(mm->user_ns, mode)))
+	    return -EPERM;
 
 	return security_ptrace_access_check(task, mode);
 }
diff --git a/mm/init-mm.c b/mm/init-mm.c
index a56a851908d2..975e49f00f34 100644
--- a/mm/init-mm.c
+++ b/mm/init-mm.c
@@ -6,6 +6,7 @@
 #include <linux/cpumask.h>
 
 #include <linux/atomic.h>
+#include <linux/user_namespace.h>
 #include <asm/pgtable.h>
 #include <asm/mmu.h>
 
@@ -21,5 +22,6 @@ struct mm_struct init_mm = {
 	.mmap_sem	= __RWSEM_INITIALIZER(init_mm.mmap_sem),
 	.page_table_lock =  __SPIN_LOCK_UNLOCKED(init_mm.page_table_lock),
 	.mmlist		= LIST_HEAD_INIT(init_mm.mmlist),
+	.user_ns	= &init_user_ns,
 	INIT_MM_CONTEXT(init_mm)
 };
-- 
2.8.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
