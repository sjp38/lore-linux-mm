Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3F4556B0330
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 12:10:14 -0500 (EST)
Received: by mail-qt0-f200.google.com with SMTP id n6so84019358qtd.4
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 09:10:14 -0800 (PST)
Received: from out03.mta.xmission.com (out03.mta.xmission.com. [166.70.13.233])
        by mx.google.com with ESMTPS id e10si1534822oic.187.2016.11.17.09.10.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 09:10:12 -0800 (PST)
From: ebiederm@xmission.com (Eric W. Biederman)
References: <87twcbq696.fsf@x220.int.ebiederm.org>
	<20161018135031.GB13117@dhcp22.suse.cz> <8737jt903u.fsf@xmission.com>
	<20161018150507.GP14666@pc.thejh.net> <87twc9656s.fsf@xmission.com>
	<20161018191206.GA1210@laptop.thejh.net> <87r37dnz74.fsf@xmission.com>
	<87k2d5nytz.fsf_-_@xmission.com>
	<CALCETrU4SZYUEPrv4JkpUpA+0sZ=EirZRftRDp+a5hce5E7HgA@mail.gmail.com>
	<87y41kjn6l.fsf@xmission.com> <20161019172917.GE1210@laptop.thejh.net>
	<CALCETrWSY1SRse5oqSwZ=goQ+ZALd2XcTP3SZ8ry49C8rNd98Q@mail.gmail.com>
	<87pomwi5p2.fsf@xmission.com>
	<CALCETrUz2oU6OYwQ9K4M-SUg6FeDsd6Q1gf1w-cJRGg2PdmK8g@mail.gmail.com>
	<87pomwghda.fsf@xmission.com>
	<CALCETrXA2EnE8X3HzetLG6zS8YSVjJQJrsSumTfvEcGq=r5vsw@mail.gmail.com>
	<87twb6avk8.fsf_-_@xmission.com>
Date: Thu, 17 Nov 2016 11:05:22 -0600
In-Reply-To: <87twb6avk8.fsf_-_@xmission.com> (Eric W. Biederman's message of
	"Thu, 17 Nov 2016 11:02:47 -0600")
Message-ID: <87oa1eavfx.fsf_-_@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: [REVIEW][PATCH 1/3] ptrace: Capture the ptracer's creds not PT_PTRACE_CAP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Containers <containers@lists.linux-foundation.org>
Cc: Oleg Nesterov <oleg@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linux FS Devel <linux-fsdevel@vger.kernel.org>, Michal Hocko <mhocko@kernel.org>, Jann Horn <jann@thejh.net>, Willy Tarreau <w@1wt.eu>, Kees Cook <keescook@chromium.org>, Andy Lutomirski <luto@amacapital.net>


When the flag PT_PTRACE_CAP was added the PTRACE_TRACEME path was
overlooked.  This can result in incorrect behavior when an application
like strace traces an exec of a setuid executable.

Further PT_PTRACE_CAP does not have enough information for making good
security decisions as it does not report which user namespace the
capability is in.  This has already allowed one mistake through
insufficient granulariy.

I found this issue when I was testing another corner case of exec and
discovered that I could not get strace to set PT_PTRACE_CAP even when
running strace as root with a full set of caps.

This change fixes the above issue with strace allowing stracing as
root a setuid executable without disabling setuid.  More fundamentaly
this change allows what is allowable at all times, by using the correct
information in it's decision.

Cc: stable@vger.kernel.org
Fixes: 4214e42f96d4 ("v2.4.9.11 -> v2.4.9.12")
Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 fs/exec.c                  |  2 +-
 include/linux/capability.h |  1 +
 include/linux/ptrace.h     |  1 -
 include/linux/sched.h      |  1 +
 kernel/capability.c        | 20 ++++++++++++++++++++
 kernel/ptrace.c            | 12 +++++++-----
 6 files changed, 30 insertions(+), 7 deletions(-)

diff --git a/fs/exec.c b/fs/exec.c
index 6fcfb3f7b137..fdec760bfac3 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1401,7 +1401,7 @@ static void check_unsafe_exec(struct linux_binprm *bprm)
 	unsigned n_fs;
 
 	if (p->ptrace) {
-		if (p->ptrace & PT_PTRACE_CAP)
+		if (ptracer_capable(p, current_user_ns()))
 			bprm->unsafe |= LSM_UNSAFE_PTRACE_CAP;
 		else
 			bprm->unsafe |= LSM_UNSAFE_PTRACE;
diff --git a/include/linux/capability.h b/include/linux/capability.h
index dbc21c719ce6..d6088e2a7668 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -242,6 +242,7 @@ static inline bool ns_capable_noaudit(struct user_namespace *ns, int cap)
 #endif /* CONFIG_MULTIUSER */
 extern bool capable_wrt_inode_uidgid(const struct inode *inode, int cap);
 extern bool file_ns_capable(const struct file *file, struct user_namespace *ns, int cap);
+extern bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns);
 
 /* audit system wants to get cap info from files as well */
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
diff --git a/include/linux/ptrace.h b/include/linux/ptrace.h
index 504c98a278d4..e13bfdf7f314 100644
--- a/include/linux/ptrace.h
+++ b/include/linux/ptrace.h
@@ -19,7 +19,6 @@
 #define PT_SEIZED	0x00010000	/* SEIZE used, enable new behavior */
 #define PT_PTRACED	0x00000001
 #define PT_DTRACE	0x00000002	/* delayed trace (used on m68k, i386) */
-#define PT_PTRACE_CAP	0x00000004	/* ptracer can follow suid-exec */
 
 #define PT_OPT_FLAG_SHIFT	3
 /* PT_TRACE_* event enable flags */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 348f51b0ec92..8fe58255d219 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1656,6 +1656,7 @@ struct task_struct {
 	struct list_head cpu_timers[3];
 
 /* process credentials */
+	const struct cred __rcu *ptracer_cred; /* Tracer's dredentials at attach */
 	const struct cred __rcu *real_cred; /* objective and real subjective task
 					 * credentials (COW) */
 	const struct cred __rcu *cred;	/* effective (overridable) subjective task
diff --git a/kernel/capability.c b/kernel/capability.c
index 00411c82dac5..dfa0e4528b0b 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -473,3 +473,23 @@ bool capable_wrt_inode_uidgid(const struct inode *inode, int cap)
 		kgid_has_mapping(ns, inode->i_gid);
 }
 EXPORT_SYMBOL(capable_wrt_inode_uidgid);
+
+/**
+ * ptracer_capable - Determine if the ptracer holds CAP_SYS_PTRACE in the namespace
+ * @tsk: The task that may be ptraced
+ * @ns: The user namespace to search for CAP_SYS_PTRACE in
+ *
+ * Return true if the task that is ptracing the current task had CAP_SYS_PTRACE
+ * in the specified user namespace.
+ */
+bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns)
+{
+	int ret = 0;  /* An absent tracer adds no restrictions */
+	const struct cred *cred;
+	rcu_read_lock();
+	cred = rcu_dereference(tsk->ptracer_cred);
+	if (cred)
+		ret = security_capable_noaudit(cred, ns, CAP_SYS_PTRACE);
+	rcu_read_unlock();
+	return (ret == 0);
+}
diff --git a/kernel/ptrace.c b/kernel/ptrace.c
index 44a25a1e6e83..982505497680 100644
--- a/kernel/ptrace.c
+++ b/kernel/ptrace.c
@@ -39,6 +39,9 @@ void __ptrace_link(struct task_struct *child, struct task_struct *new_parent)
 	BUG_ON(!list_empty(&child->ptrace_entry));
 	list_add(&child->ptrace_entry, &new_parent->ptraced);
 	child->parent = new_parent;
+	rcu_read_lock();
+	child->ptracer_cred = get_cred(__task_cred(new_parent));
+	rcu_read_unlock();
 }
 
 /**
@@ -71,12 +74,16 @@ void __ptrace_link(struct task_struct *child, struct task_struct *new_parent)
  */
 void __ptrace_unlink(struct task_struct *child)
 {
+	const struct cred *old_cred;
 	BUG_ON(!child->ptrace);
 
 	clear_tsk_thread_flag(child, TIF_SYSCALL_TRACE);
 
 	child->parent = child->real_parent;
 	list_del_init(&child->ptrace_entry);
+	old_cred = child->ptracer_cred;
+	child->ptracer_cred = NULL;
+	put_cred(old_cred);
 
 	spin_lock(&child->sighand->siglock);
 	child->ptrace = 0;
@@ -326,11 +333,6 @@ static int ptrace_attach(struct task_struct *task, long request,
 
 	task_lock(task);
 	retval = __ptrace_may_access(task, PTRACE_MODE_ATTACH_REALCREDS);
-	if (!retval) {
-		struct mm_struct *mm = task->mm;
-		if (mm && ns_capable(mm->user_ns, CAP_SYS_PTRACE))
-			flags |= PT_PTRACE_CAP;
-	}
 	task_unlock(task);
 	if (retval)
 		goto unlock_creds;
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
