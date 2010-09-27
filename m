Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 466616B0047
	for <linux-mm@kvack.org>; Sun, 26 Sep 2010 22:50:07 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8R2o4hJ030813
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 27 Sep 2010 11:50:04 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A4E445DE4E
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:50:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 02D5845DE4F
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:50:04 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id D62761DB8054
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:50:03 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6CCE11DB8052
	for <linux-mm@kvack.org>; Mon, 27 Sep 2010 11:50:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 4/4] oom: don't ignore rss in nascent mm
In-Reply-To: <20100916174433.GA4842@redhat.com>
References: <20100916145710.3BBA.A69D9226@jp.fujitsu.com> <20100916174433.GA4842@redhat.com>
Message-Id: <20100927115139.6B3C.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 27 Sep 2010 11:50:02 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Oleg Nesterov <oleg@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, oss-security@lists.openwall.com, Solar Designer <solar@openwall.com>, Kees Cook <kees.cook@canonical.com>, Al Viro <viro@zeniv.linux.org.uk>, Neil Horman <nhorman@tuxdriver.com>, linux-fsdevel@vger.kernel.org, pageexec@freemail.hu, Brad Spengler <spender@grsecurity.net>, Eugene Teo <eugene@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

> On 09/16, KOSAKI Motohiro wrote:
> >
> > ChangeLog
> >  o since v1
> >    - Always use thread group leader's ->in_exec_mm.
>=20
> Confused ;)
>=20
> > +static unsigned long oom_rss_swap_usage(struct task_struct *p)
> > +{
> > +	struct task_struct *t =3D p;
> > +	struct task_struct *leader =3D p->group_leader;
> > +	unsigned long points =3D 0;
> > +
> > +	do {
> > +		task_lock(t);
> > +		if (t->mm) {
> > +			points +=3D get_mm_rss(t->mm);
> > +			points +=3D get_mm_counter(t->mm, MM_SWAPENTS);
> > +			task_unlock(t);
> > +			break;
> > +		}
> > +		task_unlock(t);
> > +	} while_each_thread(p, t);
> > +
> > +	/*
> > +	 * If the process is in execve() processing, we have to concern
> > +	 * about both old and new mm.
> > +	 */
> > +	task_lock(leader);
> > +	if (leader->in_exec_mm) {
> > +		points +=3D get_mm_rss(leader->in_exec_mm);
> > +		points +=3D get_mm_counter(leader->in_exec_mm, MM_SWAPENTS);
> > +	}
> > +	task_unlock(leader);
> > +
> > +	return points;
> > +}
>=20
> This patch relies on fact that we can't race with de_thread() (and btw
> the change in de_thread() looks bogus). Then why ->in_exec_mm lives in
> task_struct ?
>=20
> To me, this looks a bit strange. I think we should either do not use
> ->group_leader to hold ->in_exec_mm like your previous patch did, or
> move ->in_exec_mm into signal_struct. The previous 3/4 ensures that
> only one thread can set ->in_exec_mm.

hm. okey. I'll do.


>=20
> And I don't think oom_rss_swap_usage() should replace find_lock_task_mm()
> in oom_badness(), I mean something like this:
>=20
> 	static unsigned long oom_rss_swap_usage(struct mm_struct *mm)
> 	{
> 		return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS);
> 	}
>=20
> 	unsigned int oom_badness(struct task_struct *p, ...)
> 	{
> 		int points =3D 0;
>=20
> 		if (unlikely(p->signal->in_exec_mm)) {
> 			task_lock(p->group_leader);
> 			if (p->signal->in_exec_mm)
> 				points =3D oom_rss_swap_usage(p->signal->in_exec_mm);
> 			task_unlock(p->group_leader);
> 		}
>=20
> 		p =3D find_lock_task_mm(p);
> 		if (!p)
> 			return points;
>=20
> 		...
> 	}
>=20
> but this is the matter of taste.
>=20
> What do you think?

Personally I don't think this is big matter. but I always take reviewer's
opinion if I have no reason to oppose. Will fix.



---------------------------------------------------------------------------
=46rom 882ba08dd61de3ebd429470ac11ac979e50d1615 Mon Sep 17 00:00:00 2001
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sun, 12 Sep 2010 13:26:11 +0900
Subject: [PATCH] oom: don't ignore rss in nascent mm

ChangeLog
 o since v2
   - Move ->in_exec_mm from task_struct to signal_struct
   - clean up oom_rss_swap_usage()
 o since v1
   - Always use thread group leader's ->in_exec_mm.
     It slightly makes efficient oom when a process has many thread.
   - Add the link of Brad's explanation to the description.

Brad Spengler published a local memory-allocation DoS that
evades the OOM-killer (though not the virtual memory RLIMIT):
http://www.grsecurity.net/~spender/64bit_dos.c

Because execve() makes new mm struct and setup stack and
copy argv. It mean the task have two mm while execve() temporary.
Unfortunately this nascent mm is not pointed any tasks, then
OOM-killer can't detect this memory usage. therefore OOM-killer
may kill incorrect task.

Thus, this patch added task->in_exec_mm member and track
nascent mm usage.

Cc: pageexec@freemail.hu
Cc: Roland McGrath <roland@redhat.com>
Cc: Solar Designer <solar@openwall.com>
Cc: Eugene Teo <eteo@redhat.com>
Reported-by: Brad Spengler <spender@grsecurity.net>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 fs/compat.c             |    4 +++-
 fs/exec.c               |   16 +++++++++++++++-
 include/linux/binfmts.h |    1 +
 include/linux/sched.h   |    1 +
 mm/oom_kill.c           |   26 +++++++++++++++++++-------
 5 files changed, 39 insertions(+), 9 deletions(-)

diff --git a/fs/compat.c b/fs/compat.c
index 718c706..b631120 100644
--- a/fs/compat.c
+++ b/fs/compat.c
@@ -1567,8 +1567,10 @@ int compat_do_execve(char * filename,
 	return retval;
=20
 out:
-	if (bprm->mm)
+	if (bprm->mm) {
+		set_exec_mm(NULL);
 		mmput(bprm->mm);
+	}
=20
 out_file:
 	if (bprm->file) {
diff --git a/fs/exec.c b/fs/exec.c
index 160eb46..15ab7b3 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -347,6 +347,8 @@ int bprm_mm_init(struct linux_binprm *bprm)
 	if (err)
 		goto err;
=20
+	set_exec_mm(mm);
+
 	return 0;
=20
 err:
@@ -745,6 +747,7 @@ static int exec_mmap(struct mm_struct *mm)
 	tsk->mm =3D mm;
 	tsk->active_mm =3D mm;
 	activate_mm(active_mm, mm);
+	tsk->signal->in_exec_mm =3D NULL;
 	task_unlock(tsk);
 	arch_pick_mmap_layout(mm);
 	if (old_mm) {
@@ -1314,6 +1317,15 @@ int search_binary_handler(struct linux_binprm *bprm,=
struct pt_regs *regs)
=20
 EXPORT_SYMBOL(search_binary_handler);
=20
+void set_exec_mm(struct mm_struct *mm)
+{
+	struct task_struct *leader =3D current->group_leader;
+
+	task_lock(leader);
+	leader->signal->in_exec_mm =3D mm;
+	task_unlock(leader);
+}
+
 /*
  * sys_execve() executes a new program.
  */
@@ -1402,8 +1414,10 @@ int do_execve(const char * filename,
 	return retval;
=20
 out:
-	if (bprm->mm)
+	if (bprm->mm) {
+		set_exec_mm(NULL);
 		mmput (bprm->mm);
+	}
=20
 out_file:
 	if (bprm->file) {
diff --git a/include/linux/binfmts.h b/include/linux/binfmts.h
index a065612..2fde1ba 100644
--- a/include/linux/binfmts.h
+++ b/include/linux/binfmts.h
@@ -133,6 +133,7 @@ extern void install_exec_creds(struct linux_binprm *bpr=
m);
 extern void do_coredump(long signr, int exit_code, struct pt_regs *regs);
 extern void set_binfmt(struct linux_binfmt *new);
 extern void free_bprm(struct linux_binprm *);
+extern void set_exec_mm(struct mm_struct *mm);
=20
 #endif /* __KERNEL__ */
 #endif /* _LINUX_BINFMTS_H */
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 960a867..10a771d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -627,6 +627,7 @@ struct signal_struct {
 	struct mutex cred_guard_mutex;	/* guard against foreign influences on
 					 * credential calculations
 					 * (notably. ptrace) */
+	struct mm_struct *in_exec_mm;	/* temporary nascent mm in execve */
 };
=20
 /* Context switch must be unlocked if interrupts are to be enabled */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c1beda0..18c12d1 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -120,6 +120,15 @@ struct task_struct *find_lock_task_mm(struct task_stru=
ct *p)
 	return NULL;
 }
=20
+/*
+ * The baseline for the badness score is the proportion of RAM that each
+ * task's rss and swap space use.
+ */
+static unsigned long oom_rss_swap_usage(struct mm_struct *mm)
+{
+	return get_mm_rss(mm) + get_mm_counter(mm, MM_SWAPENTS);
+}
+
 /* return true if the task is not adequate as candidate victim task. */
 static bool oom_unkillable_task(struct task_struct *p, struct mem_cgroup *=
mem,
 			   const nodemask_t *nodemask)
@@ -151,7 +160,7 @@ static bool oom_unkillable_task(struct task_struct *p, =
struct mem_cgroup *mem,
 unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *mem,
 			  const nodemask_t *nodemask)
 {
-	unsigned long points;
+	unsigned long points =3D 0;
 	unsigned long points_orig;
 	int oom_adj =3D p->signal->oom_adj;
 	long oom_score_adj =3D p->signal->oom_score_adj;
@@ -169,15 +178,18 @@ unsigned long oom_badness(struct task_struct *p, stru=
ct mem_cgroup *mem,
 	if (p->flags & PF_OOM_ORIGIN)
 		return ULONG_MAX;
=20
+	/* The task is now processing execve(). then it has second mm */
+	if (unlikely(p->signal->in_exec_mm)) {
+		task_lock(p->group_leader);
+		if (p->signal->in_exec_mm)
+			points =3D oom_rss_swap_usage(p->signal->in_exec_mm);
+		task_unlock(p->group_leader);
+	}
+
 	p =3D find_lock_task_mm(p);
 	if (!p)
 		return 0;
-
-	/*
-	 * The baseline for the badness score is the proportion of RAM that each
-	 * task's rss and swap space use.
-	 */
-	points =3D (get_mm_rss(p->mm) + get_mm_counter(p->mm, MM_SWAPENTS));
+	points +=3D oom_rss_swap_usage(p->mm);
 	task_unlock(p);
=20
 	/*
--=20
1.6.5.2






--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
