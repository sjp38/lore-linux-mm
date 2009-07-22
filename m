Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 59E166B00AD
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 06:10:20 -0400 (EDT)
From: Oren Laadan <orenl@librato.com>
Subject: [RFC v17][PATCH 23/60] c/r: export functionality used in next patch for restart-blocks
Date: Wed, 22 Jul 2009 05:59:45 -0400
Message-Id: <1248256822-23416-24-git-send-email-orenl@librato.com>
In-Reply-To: <1248256822-23416-1-git-send-email-orenl@librato.com>
References: <1248256822-23416-1-git-send-email-orenl@librato.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@osdl.org>, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-api@vger.kernel.org, Serge Hallyn <serue@us.ibm.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Pavel Emelyanov <xemul@openvz.org>, Alexey Dobriyan <adobriyan@gmail.com>, Oren Laadan <orenl@librato.com>, Oren Laadan <orenl@cs.columbia.edu>
List-ID: <linux-mm.kvack.org>

To support c/r of restart-blocks (system call that need to be
restarted because they were interrupted but there was no userspace
visible side-effect), export restart-block callbacks for poll()
and futex() syscalls.

More details on c/r of restart-blocks and how it works in the
following patch.

Signed-off-by: Oren Laadan <orenl@cs.columbia.edu>
Acked-by: Serge Hallyn <serue@us.ibm.com>
---
 fs/select.c                  |    2 +-
 include/linux/futex.h        |   11 +++++++++++
 include/linux/poll.h         |    3 +++
 include/linux/posix-timers.h |    6 ++++++
 kernel/compat.c              |    4 ++--
 kernel/futex.c               |   12 +-----------
 kernel/posix-timers.c        |    2 +-
 7 files changed, 25 insertions(+), 15 deletions(-)

diff --git a/fs/select.c b/fs/select.c
index d870237..08d1d35 100644
--- a/fs/select.c
+++ b/fs/select.c
@@ -865,7 +865,7 @@ out_fds:
 	return err;
 }
 
-static long do_restart_poll(struct restart_block *restart_block)
+long do_restart_poll(struct restart_block *restart_block)
 {
 	struct pollfd __user *ufds = restart_block->poll.ufds;
 	int nfds = restart_block->poll.nfds;
diff --git a/include/linux/futex.h b/include/linux/futex.h
index 34956c8..4326f81 100644
--- a/include/linux/futex.h
+++ b/include/linux/futex.h
@@ -136,6 +136,17 @@ extern int
 handle_futex_death(u32 __user *uaddr, struct task_struct *curr, int pi);
 
 /*
+ * In case we must use restart_block to restart a futex_wait,
+ * we encode in the 'flags' shared capability
+ */
+#define FLAGS_SHARED		0x01
+#define FLAGS_CLOCKRT		0x02
+#define FLAGS_HAS_TIMEOUT	0x04
+
+/* for c/r */
+extern long futex_wait_restart(struct restart_block *restart);
+
+/*
  * Futexes are matched on equal values of this key.
  * The key type depends on whether it's a shared or private mapping.
  * Don't rearrange members without looking at hash_futex().
diff --git a/include/linux/poll.h b/include/linux/poll.h
index fa287f2..0841c51 100644
--- a/include/linux/poll.h
+++ b/include/linux/poll.h
@@ -134,6 +134,9 @@ extern int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
 
 extern int poll_select_set_timeout(struct timespec *to, long sec, long nsec);
 
+/* used by checkpoint/restart */
+extern long do_restart_poll(struct restart_block *restart_block);
+
 #endif /* KERNEL */
 
 #endif /* _LINUX_POLL_H */
diff --git a/include/linux/posix-timers.h b/include/linux/posix-timers.h
index 4f71bf4..d0d6a66 100644
--- a/include/linux/posix-timers.h
+++ b/include/linux/posix-timers.h
@@ -101,6 +101,10 @@ int posix_cpu_timer_create(struct k_itimer *timer);
 int posix_cpu_nsleep(const clockid_t which_clock, int flags,
 		     struct timespec *rqtp, struct timespec __user *rmtp);
 long posix_cpu_nsleep_restart(struct restart_block *restart_block);
+#ifdef CONFIG_COMPAT
+long compat_nanosleep_restart(struct restart_block *restart);
+long compat_clock_nanosleep_restart(struct restart_block *restart);
+#endif
 int posix_cpu_timer_set(struct k_itimer *timer, int flags,
 			struct itimerspec *new, struct itimerspec *old);
 int posix_cpu_timer_del(struct k_itimer *timer);
@@ -119,4 +123,6 @@ long clock_nanosleep_restart(struct restart_block *restart_block);
 
 void update_rlimit_cpu(unsigned long rlim_new);
 
+int invalid_clockid(const clockid_t which_clock);
+
 #endif
diff --git a/kernel/compat.c b/kernel/compat.c
index f6c204f..20afdba 100644
--- a/kernel/compat.c
+++ b/kernel/compat.c
@@ -100,7 +100,7 @@ int put_compat_timespec(const struct timespec *ts, struct compat_timespec __user
 			__put_user(ts->tv_nsec, &cts->tv_nsec)) ? -EFAULT : 0;
 }
 
-static long compat_nanosleep_restart(struct restart_block *restart)
+long compat_nanosleep_restart(struct restart_block *restart)
 {
 	struct compat_timespec __user *rmtp;
 	struct timespec rmt;
@@ -647,7 +647,7 @@ long compat_sys_clock_getres(clockid_t which_clock,
 	return err;
 }
 
-static long compat_clock_nanosleep_restart(struct restart_block *restart)
+long compat_clock_nanosleep_restart(struct restart_block *restart)
 {
 	long err;
 	mm_segment_t oldfs;
diff --git a/kernel/futex.c b/kernel/futex.c
index 794c862..dfe246f 100644
--- a/kernel/futex.c
+++ b/kernel/futex.c
@@ -1516,16 +1516,6 @@ handle_fault:
 	goto retry;
 }
 
-/*
- * In case we must use restart_block to restart a futex_wait,
- * we encode in the 'flags' shared capability
- */
-#define FLAGS_SHARED		0x01
-#define FLAGS_CLOCKRT		0x02
-#define FLAGS_HAS_TIMEOUT	0x04
-
-static long futex_wait_restart(struct restart_block *restart);
-
 /**
  * fixup_owner() - Post lock pi_state and corner case management
  * @uaddr:	user address of the futex
@@ -1795,7 +1785,7 @@ out:
 }
 
 
-static long futex_wait_restart(struct restart_block *restart)
+long futex_wait_restart(struct restart_block *restart)
 {
 	u32 __user *uaddr = (u32 __user *)restart->futex.uaddr;
 	int fshared = 0;
diff --git a/kernel/posix-timers.c b/kernel/posix-timers.c
index 052ec4d..589aed2 100644
--- a/kernel/posix-timers.c
+++ b/kernel/posix-timers.c
@@ -205,7 +205,7 @@ static int no_timer_create(struct k_itimer *new_timer)
 /*
  * Return nonzero if we know a priori this clockid_t value is bogus.
  */
-static inline int invalid_clockid(const clockid_t which_clock)
+int invalid_clockid(const clockid_t which_clock)
 {
 	if (which_clock < 0)	/* CPU clock, posix_cpu_* will check it */
 		return 0;
-- 
1.6.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
