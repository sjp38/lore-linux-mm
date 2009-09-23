Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5B0136B005C
	for <linux-mm@kvack.org>; Wed, 23 Sep 2009 20:29:25 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [PATCH v18 74/80] c/r: support for controlling terminal and job control
Date: Wed, 23 Sep 2009 19:51:54 -0400
Message-Id: <1253749920-18673-75-git-send-email-orenl@librato.com>
In-Reply-To: <1253749920-18673-1-git-send-email-orenl@librato.com>
References: <1253749920-18673-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, Pavel Emelyanov <xemul@openvz.org>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

Add checkpoint/restart of controlling terminal: current->signal->tty.
This is only done for session leaders.

If the session leader belongs to the ancestor pid-ns, then checkpoint
skips this tty; On restart, it will not be restored, and whatever tty
is in place from parent pid-ns (at restart) will be inherited.

Chagnelog [v1]:
  - Don't restore tty_old_pgrp it pgid is CKPT_PID_NULL
  - Initialize pgrp to NULL in restore_signal

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
---
 checkpoint/signal.c            |   79 +++++++++++++++++++++++++++++++++++++++-
 drivers/char/tty_io.c          |   33 +++++++++++++----
 include/linux/checkpoint.h     |    1 +
 include/linux/checkpoint_hdr.h |    6 +++
 include/linux/tty.h            |    5 +++
 5 files changed, 115 insertions(+), 9 deletions(-)

diff --git a/checkpoint/signal.c b/checkpoint/signal.c
index 5ff0734..cd3956d 100644
--- a/checkpoint/signal.c
+++ b/checkpoint/signal.c
@@ -316,11 +316,12 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	struct ckpt_hdr_signal *h;
 	struct signal_struct *signal;
 	struct sigpending shared_pending;
+	struct tty_struct *tty = NULL;
 	struct rlimit *rlim;
 	struct timeval tval;
 	cputime_t cputime;
 	unsigned long flags;
-	int i, ret;
+	int i, ret = 0;
 
 	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
 	if (!h)
@@ -398,9 +399,34 @@ static int checkpoint_signal(struct ckpt_ctx *ctx, struct task_struct *t)
 	cputime_to_timeval(signal->it_prof_incr, &tval);
 	h->it_prof_incr = timeval_to_ns(&tval);
 
+	/* tty */
+	if (signal->leader) {
+		h->tty_old_pgrp = ckpt_pid_nr(ctx, signal->tty_old_pgrp);
+		tty = tty_kref_get(signal->tty);
+		if (tty) {
+			/* irq is already disabled */
+			spin_lock(&tty->ctrl_lock);
+			h->tty_pgrp = ckpt_pid_nr(ctx, tty->pgrp);
+			spin_unlock(&tty->ctrl_lock);
+			tty_kref_put(tty);
+		}
+	}
+
 	unlock_task_sighand(t, &flags);
 
-	ret = ckpt_write_obj(ctx, &h->h);
+	/*
+	 * If the session is in an ancestor namespace, skip this tty
+	 * and set tty_objref = 0. It will not be explicitly restored,
+	 * but rather inherited from parent pid-ns at restart time.
+	 */
+	if (tty && ckpt_pid_nr(ctx, tty->session) > 0) {
+		h->tty_objref = checkpoint_obj(ctx, tty, CKPT_OBJ_TTY);
+		if (h->tty_objref < 0)
+			ret = h->tty_objref;
+	}
+
+	if (!ret)
+		ret = ckpt_write_obj(ctx, &h->h);
 	if (!ret)
 		ret = checkpoint_sigpending(ctx, &shared_pending);
 
@@ -471,8 +497,10 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	struct ckpt_hdr_signal *h;
 	struct sigpending new_pending;
 	struct sigpending *pending;
+	struct tty_struct *tty = NULL;
 	struct itimerval itimer;
 	struct rlimit rlim;
+	struct pid *pgrp = NULL;
 	int i, ret;
 
 	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_SIGNAL);
@@ -492,6 +520,40 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	if (ret < 0)
 		goto out;
 
+	/* tty - session */
+	if (h->tty_objref) {
+		tty = ckpt_obj_fetch(ctx, h->tty_objref, CKPT_OBJ_TTY);
+		if (IS_ERR(tty)) {
+			ret = PTR_ERR(tty);
+			goto out;
+		}
+		/* this will fail unless we're the session leader */
+		ret = tiocsctty(tty, 0);
+		if (ret < 0)
+			goto out;
+		/* now restore the foreground group (job control) */
+		if (h->tty_pgrp) {
+			/*
+			 * If tty_pgrp == CKPT_PID_NULL, below will
+			 * fail, so no need for explicit test
+			 */
+			ret = do_tiocspgrp(tty, tty_pair_get_tty(tty),
+					   h->tty_pgrp);
+			if (ret < 0)
+				goto out;
+		}
+	} else {
+		/*
+		 * If tty_objref isn't set, we _keep_ whatever tty we
+		 * already have as a ctty. Why does this make sense ?
+		 * - If our session is "within" the restart context,
+		 * then that session has no controlling terminal.
+		 * - If out session is "outside" the restart context,
+                 * then we're like to keep whatever we inherit from
+                 * the parent pid-ns.
+		 */
+	}
+
 	/*
 	 * Reset real/virt/prof itimer (in case they were set), to
 	 * prevent unwanted signals after flushing current signals
@@ -503,7 +565,20 @@ static int restore_signal(struct ckpt_ctx *ctx)
 	do_setitimer(ITIMER_VIRTUAL, &itimer, NULL);
 	do_setitimer(ITIMER_PROF, &itimer, NULL);
 
+	/* tty - tty_old_pgrp */
+	if (current->signal->leader && h->tty_old_pgrp != CKPT_PID_NULL) {
+		rcu_read_lock();
+		pgrp = get_pid(_ckpt_find_pgrp(ctx, h->tty_old_pgrp));
+		rcu_read_unlock();
+		if (!pgrp)
+			goto out;
+	}
+
 	spin_lock_irq(&current->sighand->siglock);
+	/* tty - tty_old_pgrp */
+	put_pid(current->signal->tty_old_pgrp);
+	current->signal->tty_old_pgrp = pgrp;
+	/* pending signals */
 	pending = &current->signal->shared_pending;
 	flush_sigqueue(pending);
 	pending->signal = new_pending.signal;
diff --git a/drivers/char/tty_io.c b/drivers/char/tty_io.c
index 72f4432..1b220c1 100644
--- a/drivers/char/tty_io.c
+++ b/drivers/char/tty_io.c
@@ -2130,7 +2130,7 @@ static int fionbio(struct file *file, int __user *p)
  *		Takes ->siglock() when updating signal->tty
  */
 
-static int tiocsctty(struct tty_struct *tty, int arg)
+int tiocsctty(struct tty_struct *tty, int arg)
 {
 	int ret = 0;
 	if (current->signal->leader && (task_session(current) == tty->session))
@@ -2219,10 +2219,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
 }
 
 /**
- *	tiocspgrp		-	attempt to set process group
+ *	do_tiocspgrp		-	attempt to set process group
  *	@tty: tty passed by user
  *	@real_tty: tty side device matching tty passed by user
- *	@p: pid pointer
+ *	@pid: pgrp_nr
  *
  *	Set the process group of the tty to the session passed. Only
  *	permitted where the tty session is our session.
@@ -2230,10 +2230,10 @@ static int tiocgpgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
  *	Locking: RCU, ctrl lock
  */
 
-static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
+int do_tiocspgrp(struct tty_struct *tty,
+		 struct tty_struct *real_tty, pid_t pgrp_nr)
 {
 	struct pid *pgrp;
-	pid_t pgrp_nr;
 	int retval = tty_check_change(real_tty);
 	unsigned long flags;
 
@@ -2245,8 +2245,6 @@ static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t
 	    (current->signal->tty != real_tty) ||
 	    (real_tty->session != task_session(current)))
 		return -ENOTTY;
-	if (get_user(pgrp_nr, p))
-		return -EFAULT;
 	if (pgrp_nr < 0)
 		return -EINVAL;
 	rcu_read_lock();
@@ -2268,6 +2266,27 @@ out_unlock:
 }
 
 /**
+ *	tiocspgrp		-	attempt to set process group
+ *	@tty: tty passed by user
+ *	@real_tty: tty side device matching tty passed by user
+ *	@p: pid pointer
+ *
+ *	Set the process group of the tty to the session passed. Only
+ *	permitted where the tty session is our session.
+ *
+ *	Locking: RCU, ctrl lock
+ */
+
+static int tiocspgrp(struct tty_struct *tty, struct tty_struct *real_tty, pid_t __user *p)
+{
+	pid_t pgrp_nr;
+
+	if (get_user(pgrp_nr, p))
+		return -EFAULT;
+	return do_tiocspgrp(tty, real_tty, pgrp_nr);
+}
+
+/**
  *	tiocgsid		-	get session id
  *	@tty: tty passed by user
  *	@real_tty: tty side of the tty pased by the user if a pty else the tty
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 8e1cce7..e00dd70 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -84,6 +84,7 @@ extern char *ckpt_fill_fname(struct path *path, struct path *root,
 
 /* pids */
 extern pid_t ckpt_pid_nr(struct ckpt_ctx *ctx, struct pid *pid);
+extern struct pid *_ckpt_find_pgrp(struct ckpt_ctx *ctx, pid_t pgid);
 
 /* socket functions */
 extern int ckpt_sock_getnames(struct ckpt_ctx *ctx,
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 842177f..9ae35a0 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -578,13 +578,19 @@ struct ckpt_rlimit {
 
 struct ckpt_hdr_signal {
 	struct ckpt_hdr h;
+	/* rlimit */
 	struct ckpt_rlimit rlim[CKPT_RLIM_NLIMITS];
+	/* itimer */
 	__u64 it_real_value;
 	__u64 it_real_incr;
 	__u64 it_virt_value;
 	__u64 it_virt_incr;
 	__u64 it_prof_value;
 	__u64 it_prof_incr;
+	/* tty */
+	__s32 tty_objref;
+	__s32 tty_pgrp;
+	__s32 tty_old_pgrp;
 } __attribute__((aligned(8)));
 
 struct ckpt_hdr_signal_task {
diff --git a/include/linux/tty.h b/include/linux/tty.h
index 295447b..9447251 100644
--- a/include/linux/tty.h
+++ b/include/linux/tty.h
@@ -471,6 +471,11 @@ extern void tty_ldisc_enable(struct tty_struct *tty);
 /* This one is for ptmx_close() */
 extern int tty_release(struct inode *inode, struct file *filp);
 
+/* These are for checkpoint/restart */
+extern int tiocsctty(struct tty_struct *tty, int arg);
+extern int do_tiocspgrp(struct tty_struct *tty,
+			struct tty_struct *real_tty, pid_t pgrp_nr);
+
 #ifdef CONFIG_CHECKPOINT
 struct ckpt_ctx;
 struct ckpt_hdr_file;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
