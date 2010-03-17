Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id E0F156B01FE
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 12:13:54 -0400 (EDT)
From: Oren Laadan <orenl@cs.columbia.edu>
Subject: [C/R v20][PATCH 28/96] c/r: restart-blocks
Date: Wed, 17 Mar 2010 12:08:16 -0400
Message-Id: <1268842164-5590-29-git-send-email-orenl@cs.columbia.edu>
In-Reply-To: <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
References: <1268842164-5590-1-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-2-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-3-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-4-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-5-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-6-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-7-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-8-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-9-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-10-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-11-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-12-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-13-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-14-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-15-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-16-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-17-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-18-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-19-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-20-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-21-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-22-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-23-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-24-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-25-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-26-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-27-git-send-email-orenl@cs.columbia.edu>
 <1268842164-5590-28-git-send-email-orenl@cs.columbia.edu>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Ingo Molnar <mingo@elte.hu>, containers@lists.linux-foundation.org, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

(Paraphrasing what's said this message:
http://lists.openwall.net/linux-kernel/2007/12/05/64)

Restart blocks are callbacks used cause a system call to be restarted
with the arguments specified in the system call restart block. It is
useful for system call that are not idempotent, i.e. the argument(s)
might be a relative timeout, where some adjustments are required when
restarting the system call. It relies on the system call itself to set
up its restart point and the argument save area.  They are rare: an
actual signal would turn that it an EINTR. The only case that should
ever trigger this is some kernel action that interrupts the system
call, but does not actually result in any user-visible state changes -
like freeze and thaw.

So restart blocks are about time remaining for the system call to
sleep/wait. Generally in c/r, there are two possible time models that
we can follow: absolute, relative. Here, I chose to save the relative
timeout, measured from the beginning of the checkpoint. The time when
the checkpoint (and restart) begin is also saved. This information is
sufficient to restart in either model (absolute or negative).

Which model to use should eventually be a per application choice (and
possible configurable via cradvise() or some sort). For now, we adopt
the relative model, namely, at restart the timeout is set relative to
the beginning of the restart.

To checkpoint, we check if a task has a valid restart block, and if so
we save the *remaining* time that is has to wait/sleep, and the type
of the restart block.

To restart, we fill in the data required at the proper place in the
thread information. If the system call return an error (which is
possibly an -ERESTARTSYS eg), we not only use that error as our own
return value, but also arrange for the task to execute the signal
handler (by faking a signal). The handler, in turn, already has the
code to handle these restart request gracefully.


Changelog[v19-rc1]:
  - [Matt Helsley] Add cpp definitions for enums
Changelog[v1]:
  - [Nathan Lynch] fix compilation errors with CONFIG_COMPAT=y

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge E. Hallyn <serue@us.ibm.com>
Tested-by: Serge E. Hallyn <serue@us.ibm.com>
---
 checkpoint/checkpoint.c          |    1 +
 checkpoint/process.c             |  226 ++++++++++++++++++++++++++++++++++++++
 checkpoint/restart.c             |    5 +-
 checkpoint/sys.c                 |    1 +
 include/linux/checkpoint.h       |    4 +
 include/linux/checkpoint_hdr.h   |   34 ++++++
 include/linux/checkpoint_types.h |    3 +
 7 files changed, 272 insertions(+), 2 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 695ab00..e25b9b7 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -22,6 +22,7 @@
 #include <linux/mount.h>
 #include <linux/utsname.h>
 #include <linux/magic.h>
+#include <linux/hrtimer.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
diff --git a/checkpoint/process.c b/checkpoint/process.c
index f6fb9d1..9f2059c 100644
--- a/checkpoint/process.c
+++ b/checkpoint/process.c
@@ -12,6 +12,9 @@
 #define CKPT_DFLAG  CKPT_DSYS
 
 #include <linux/sched.h>
+#include <linux/posix-timers.h>
+#include <linux/futex.h>
+#include <linux/poll.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -47,6 +50,116 @@ static int checkpoint_task_struct(struct ckpt_ctx *ctx, struct task_struct *t)
 	return ckpt_write_string(ctx, t->comm, TASK_COMM_LEN);
 }
 
+/* dump the task_struct of a given task */
+int checkpoint_restart_block(struct ckpt_ctx *ctx, struct task_struct *t)
+{
+	struct ckpt_hdr_restart_block *h;
+	struct restart_block *restart_block;
+	long (*fn)(struct restart_block *);
+	s64 base, expire = 0;
+	int ret;
+
+	h = ckpt_hdr_get_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
+	if (!h)
+		return -ENOMEM;
+
+	base = ktime_to_ns(ctx->ktime_begin);
+	restart_block = &task_thread_info(t)->restart_block;
+	fn = restart_block->fn;
+
+	/* FIX: enumerate clockid_t so we're immune to changes */
+
+	if (fn == do_no_restart_syscall) {
+
+		h->function_type = CKPT_RESTART_BLOCK_NONE;
+		ckpt_debug("restart_block: non\n");
+
+	} else if (fn == hrtimer_nanosleep_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long) restart_block->nanosleep.rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: hrtimer expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == posix_cpu_nsleep_restart) {
+		struct timespec ts;
+
+		h->function_type = CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP;
+		h->arg_0 = restart_block->arg0;
+		h->arg_1 = restart_block->arg1;
+		ts.tv_sec = restart_block->arg2;
+		ts.tv_nsec = restart_block->arg3;
+		expire = timespec_to_ns(&ts);
+		ckpt_debug("restart_block: posix_cpu expire %lld now %lld\n",
+			 expire, base);
+
+#ifdef CONFIG_COMPAT
+	} else if (fn == compat_nanosleep_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
+		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: compat expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == compat_clock_nanosleep_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP;
+		h->arg_0 = restart_block->nanosleep.index;
+		h->arg_1 = (unsigned long)restart_block->nanosleep.rmtp;
+		h->arg_2 = (unsigned long)restart_block->nanosleep.compat_rmtp;
+		expire = restart_block->nanosleep.expires;
+		ckpt_debug("restart_block: compat_clock expire %lld now %lld\n",
+			 expire, base);
+
+#endif
+	} else if (fn == futex_wait_restart) {
+
+		h->function_type = CKPT_RESTART_BLOCK_FUTEX;
+		h->arg_0 = (unsigned long) restart_block->futex.uaddr;
+		h->arg_1 = restart_block->futex.val;
+		h->arg_2 = restart_block->futex.flags;
+		h->arg_3 = restart_block->futex.bitset;
+		expire = restart_block->futex.time;
+		ckpt_debug("restart_block: futex expire %lld now %lld\n",
+			 expire, base);
+
+	} else if (fn == do_restart_poll) {
+		struct timespec ts;
+
+		h->function_type = CKPT_RESTART_BLOCK_POLL;
+		h->arg_0 = (unsigned long) restart_block->poll.ufds;
+		h->arg_1 = restart_block->poll.nfds;
+		h->arg_2 = restart_block->poll.has_timeout;
+		ts.tv_sec = restart_block->poll.tv_sec;
+		ts.tv_nsec = restart_block->poll.tv_nsec;
+		expire = timespec_to_ns(&ts);
+		ckpt_debug("restart_block: poll expire %lld now %lld\n",
+			 expire, base);
+
+	} else {
+
+		BUG();
+
+	}
+
+	/* common to all restart blocks: */
+	h->arg_4 = (base < expire ? expire - base : 0);
+
+	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
+
+	ret = ckpt_write_obj(ctx, &h->h);
+	ckpt_hdr_put(ctx, h);
+
+	ckpt_debug("restart_block ret %d\n", ret);
+	return ret;
+}
+
 /* dump the entire state of a given task */
 int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 {
@@ -62,6 +175,10 @@ int checkpoint_task(struct ckpt_ctx *ctx, struct task_struct *t)
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = checkpoint_restart_block(ctx, t);
+	ckpt_debug("restart-blocks %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = checkpoint_cpu(ctx, t);
 	ckpt_debug("cpu %d\n", ret);
  out:
@@ -98,6 +215,111 @@ static int restore_task_struct(struct ckpt_ctx *ctx)
 	return ret;
 }
 
+int restore_restart_block(struct ckpt_ctx *ctx)
+{
+	struct ckpt_hdr_restart_block *h;
+	struct restart_block restart_block;
+	struct timespec ts;
+	clockid_t clockid;
+	s64 expire;
+	int ret = 0;
+
+	h = ckpt_read_obj_type(ctx, sizeof(*h), CKPT_HDR_RESTART_BLOCK);
+	if (IS_ERR(h))
+		return PTR_ERR(h);
+
+	expire = ktime_to_ns(ctx->ktime_begin) + h->arg_4;
+	restart_block.fn = NULL;
+
+	ckpt_debug("restart_block: expire %lld begin %lld\n",
+		 expire, ktime_to_ns(ctx->ktime_begin));
+	ckpt_debug("restart_block: args %#llx %#llx %#llx %#llx %#llx\n",
+		 h->arg_0, h->arg_1, h->arg_2, h->arg_3, h->arg_4);
+
+	switch (h->function_type) {
+	case CKPT_RESTART_BLOCK_NONE:
+		restart_block.fn = do_no_restart_syscall;
+		break;
+	case CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = hrtimer_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.expires = expire;
+		break;
+	case CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = posix_cpu_nsleep_restart;
+		restart_block.arg0 = clockid;
+		restart_block.arg1 = h->arg_1;
+		ts = ns_to_timespec(expire);
+		restart_block.arg2 = ts.tv_sec;
+		restart_block.arg3 = ts.tv_nsec;
+		break;
+#ifdef CONFIG_COMPAT
+	case CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) h->arg_2;
+		restart_block.nanosleep.expires = expire;
+		break;
+	case CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP:
+		clockid = h->arg_0;
+		if (clockid < 0 || invalid_clockid(clockid))
+			break;
+		restart_block.fn = compat_clock_nanosleep_restart;
+		restart_block.nanosleep.index = clockid;
+		restart_block.nanosleep.rmtp =
+			(struct timespec __user *) (unsigned long) h->arg_1;
+		restart_block.nanosleep.compat_rmtp =
+			(struct compat_timespec __user *)
+				(unsigned long) h->arg_2;
+		restart_block.nanosleep.expires = expire;
+		break;
+#endif
+	case CKPT_RESTART_BLOCK_FUTEX:
+		restart_block.fn = futex_wait_restart;
+		restart_block.futex.uaddr = (u32 *) (unsigned long) h->arg_0;
+		restart_block.futex.val = h->arg_1;
+		restart_block.futex.flags = h->arg_2;
+		restart_block.futex.bitset = h->arg_3;
+		restart_block.futex.time = expire;
+		break;
+	case CKPT_RESTART_BLOCK_POLL:
+		restart_block.fn = do_restart_poll;
+		restart_block.poll.ufds =
+			(struct pollfd __user *) (unsigned long) h->arg_0;
+		restart_block.poll.nfds = h->arg_1;
+		restart_block.poll.has_timeout = h->arg_2;
+		ts = ns_to_timespec(expire);
+		restart_block.poll.tv_sec = ts.tv_sec;
+		restart_block.poll.tv_nsec = ts.tv_nsec;
+		break;
+	default:
+		break;
+	}
+
+	if (restart_block.fn)
+		task_thread_info(current)->restart_block = restart_block;
+	else
+		ret = -EINVAL;
+
+	ckpt_hdr_put(ctx, h);
+	return ret;
+}
+
 /* read the entire state of the current task */
 int restore_task(struct ckpt_ctx *ctx)
 {
@@ -111,6 +333,10 @@ int restore_task(struct ckpt_ctx *ctx)
 	ckpt_debug("thread %d\n", ret);
 	if (ret < 0)
 		goto out;
+	ret = restore_restart_block(ctx);
+	ckpt_debug("restart-blocks %d\n", ret);
+	if (ret < 0)
+		goto out;
 	ret = restore_cpu(ctx);
 	ckpt_debug("cpu %d\n", ret);
  out:
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 11d9738..360c41e 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -16,6 +16,8 @@
 #include <linux/file.h>
 #include <linux/magic.h>
 #include <linux/utsname.h>
+#include <asm/syscall.h>
+#include <linux/elf.h>
 #include <linux/checkpoint.h>
 #include <linux/checkpoint_hdr.h>
 
@@ -523,6 +525,5 @@ long do_restart(struct ckpt_ctx *ctx, pid_t pid)
 	if (ret < 0)
 		return ret;
 
-	/* on success, adjust the return value if needed [TODO] */
-	return restore_retval(ctx);
+	return restore_retval();
 }
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index 308cd27..d858096 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -198,6 +198,7 @@ static struct ckpt_ctx *ckpt_ctx_alloc(int fd, unsigned long uflags,
 
 	ctx->uflags = uflags;
 	ctx->kflags = kflags;
+	ctx->ktime_begin = ktime_get();
 
 	mutex_init(&ctx->msg_mutex);
 
diff --git a/include/linux/checkpoint.h b/include/linux/checkpoint.h
index 3095431..8cb6130 100644
--- a/include/linux/checkpoint.h
+++ b/include/linux/checkpoint.h
@@ -77,6 +77,10 @@ extern int restore_read_header_arch(struct ckpt_ctx *ctx);
 extern int restore_thread(struct ckpt_ctx *ctx);
 extern int restore_cpu(struct ckpt_ctx *ctx);
 
+extern int checkpoint_restart_block(struct ckpt_ctx *ctx,
+				    struct task_struct *t);
+extern int restore_restart_block(struct ckpt_ctx *ctx);
+
 static inline int ckpt_validate_errno(int errno)
 {
 	return (errno >= 0) && (errno < MAX_ERRNO);
diff --git a/include/linux/checkpoint_hdr.h b/include/linux/checkpoint_hdr.h
index 4627564..24e880f 100644
--- a/include/linux/checkpoint_hdr.h
+++ b/include/linux/checkpoint_hdr.h
@@ -67,6 +67,8 @@ enum {
 
 	CKPT_HDR_TASK = 101,
 #define CKPT_HDR_TASK CKPT_HDR_TASK
+	CKPT_HDR_RESTART_BLOCK,
+#define CKPT_HDR_RESTART_BLOCK CKPT_HDR_RESTART_BLOCK
 	CKPT_HDR_THREAD,
 #define CKPT_HDR_THREAD CKPT_HDR_THREAD
 	CKPT_HDR_CPU,
@@ -147,4 +149,36 @@ struct ckpt_hdr_task {
 	__u64 clear_child_tid;
 } __attribute__((aligned(8)));
 
+/* restart blocks */
+struct ckpt_hdr_restart_block {
+	struct ckpt_hdr h;
+	__u64 function_type;
+	__u64 arg_0;
+	__u64 arg_1;
+	__u64 arg_2;
+	__u64 arg_3;
+	__u64 arg_4;
+} __attribute__((aligned(8)));
+
+enum restart_block_type {
+	CKPT_RESTART_BLOCK_NONE = 1,
+#define CKPT_RESTART_BLOCK_NONE CKPT_RESTART_BLOCK_NONE
+	CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP \
+		CKPT_RESTART_BLOCK_HRTIMER_NANOSLEEP
+	CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP \
+		CKPT_RESTART_BLOCK_POSIX_CPU_NANOSLEEP
+	CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP \
+		CKPT_RESTART_BLOCK_COMPAT_NANOSLEEP
+	CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP,
+#define CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP \
+		CKPT_RESTART_BLOCK_COMPAT_CLOCK_NANOSLEEP
+	CKPT_RESTART_BLOCK_POLL,
+#define CKPT_RESTART_BLOCK_POLL CKPT_RESTART_BLOCK_POLL
+	CKPT_RESTART_BLOCK_FUTEX,
+#define CKPT_RESTART_BLOCK_FUTEX CKPT_RESTART_BLOCK_FUTEX
+};
+
 #endif /* _CHECKPOINT_CKPT_HDR_H_ */
diff --git a/include/linux/checkpoint_types.h b/include/linux/checkpoint_types.h
index dc35b21..6420a3b 100644
--- a/include/linux/checkpoint_types.h
+++ b/include/linux/checkpoint_types.h
@@ -15,10 +15,13 @@
 #include <linux/sched.h>
 #include <linux/nsproxy.h>
 #include <linux/fs.h>
+#include <linux/ktime.h>
 
 struct ckpt_ctx {
 	int crid;		/* unique checkpoint id */
 
+	ktime_t ktime_begin;	/* checkpoint start time */
+
 	pid_t root_pid;				/* [container] root pid */
 	struct task_struct *root_task;		/* [container] root task */
 	struct nsproxy *root_nsproxy;		/* [container] root nsproxy */
-- 
1.6.3.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
