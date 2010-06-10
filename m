Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 3E0236B01AF
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 21:02:03 -0400 (EDT)
Date: Thu, 10 Jun 2010 03:00:23 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/1] signals: introduce send_sigkill() helper
Message-ID: <20100610010023.GB4727@redhat.com>
References: <20100608204621.767A.A69D9226@jp.fujitsu.com> <20100608210000.7692.A69D9226@jp.fujitsu.com> <20100608184144.GA5914@redhat.com> <20100610005937.GA4727@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100610005937.GA4727@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Roland McGrath <roland@redhat.com>
Cc: "Luis Claudio R. Goncalves" <lclaudio@uudg.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Nick Piggin <npiggin@suse.de>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

Cleanup, no functional changes.

There are a lot of buggy SIGKILL users in kernel. For example, almost
every force_sig(SIGKILL) is wrong. force_sig() is not safe, it assumes
that the task has the valid ->sighand, and in general it should be used
only for synchronous signals. send_sig(SIGKILL, p, 1) or
send_xxx(SEND_SIG_FORCED/SEND_SIG_PRIV) is not right too but this is not
immediately obvious.

The only way to correctly send SIGKILL is send_sig_info(SEND_SIG_NOINFO)
but we do not want to use this directly, because we can optimize this
case later. For example, zap_pid_ns_processes() allocates sigqueue for
each process in namespace, this is unneeded.

Introduce the trivial send_sigkill() helper on top of send_sig_info()
and change zap_pid_ns_processes() as an example.

Note: we need more cleanups here, this is only the first change.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 include/linux/sched.h  |    9 +++++++++
 kernel/pid_namespace.c |    8 +-------
 2 files changed, 10 insertions(+), 7 deletions(-)

--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -2053,6 +2053,15 @@ static inline int kill_cad_pid(int sig, 
 #define SEND_SIG_PRIV	((struct siginfo *) 1)
 #define SEND_SIG_FORCED	((struct siginfo *) 2)
 
+static inline int send_sigkill(struct task_struct * p)
+{
+	/*
+	 * Kills any user-space task, even SIGNAL_UNKILLABLE.
+	 * We use SEND_SIG_NOINFO to make si_fromuser() true.
+	 */
+	return send_sig_info(SIGKILL, SEND_SIG_NOINFO, p);
+}
+
 /*
  * True if we are on the alternate signal stack.
  */
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -160,15 +160,9 @@ void zap_pid_ns_processes(struct pid_nam
 	nr = next_pidmap(pid_ns, 1);
 	while (nr > 0) {
 		rcu_read_lock();
-
-		/*
-		 * Any nested-container's init processes won't ignore the
-		 * SEND_SIG_NOINFO signal, see send_signal()->si_fromuser().
-		 */
 		task = pid_task(find_vpid(nr), PIDTYPE_PID);
 		if (task)
-			send_sig_info(SIGKILL, SEND_SIG_NOINFO, task);
-
+			send_sigkill(task);
 		rcu_read_unlock();
 
 		nr = next_pidmap(pid_ns, nr);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
