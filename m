Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D7A928D003B
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:41:18 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p3K1D5hs015437
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:13:05 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p3K1fHDp229544
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 21:41:17 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p3K1fGYv007281
	for <linux-mm@kvack.org>; Tue, 19 Apr 2011 22:41:17 -0300
Subject: Re: [PATCH 1/2] break out page allocation warning code
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1104181321480.31186@chino.kir.corp.google.com>
	 <1303161774.9887.346.camel@nimitz>
	 <20110419094422.9375.A69D9226@jp.fujitsu.com>
	 <alpine.DEB.2.00.1104191419470.510@chino.kir.corp.google.com>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 19 Apr 2011 18:41:13 -0700
Message-ID: <1303263673.5076.612.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Nazarewicz <mina86@mina86.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue, 2011-04-19 at 14:21 -0700, David Rientjes wrote:
> On Tue, 19 Apr 2011, KOSAKI Motohiro wrote:
> > The rule is,
> > 
> > 1) writing comm
> > 	need task_lock
> > 2) read _another_ thread's comm
> > 	need task_lock
> > 3) read own comm
> > 	no need task_lock
> 
> That was true a while ago, but you now need to protect every thread's 
> ->comm with get_task_comm() or ensuring task_lock() is held to protect 
> against /proc/pid/comm which can change other thread's ->comm.  That was 
> different before when prctl(PR_SET_NAME) would only operate on current, so 
> no lock was needed when reading current->comm.

Everybody still goes through set_task_comm() to _set_ it, though.  That
means that the worst case scenario that we get is output truncated
(possibly to nothing).  We already have at least one existing user in
mm/ (kmemleak) that thinks this is OK.  I'd tend to err in the direction
of taking a truncated or empty task name to possibly locking up the
system.

There are also plenty of instances of current->comm going in to the
kernel these days.  I count 18 added since 2.6.37.

As for a long-term fix, locks probably aren't the answer.  Would
something like this completely untested patch work?  It would have the
added bonus that it keeps tsk->comm users working for the moment.  We
could eventually add an rcu_read_lock()-annotated access function.

---

 linux-2.6.git-dave/fs/exec.c                 |   22 +++++++++++++++-------
 linux-2.6.git-dave/include/linux/init_task.h |    3 ++-
 linux-2.6.git-dave/include/linux/sched.h     |    3 ++-
 3 files changed, 19 insertions(+), 9 deletions(-)

diff -puN mm/page_alloc.c~tsk_comm mm/page_alloc.c
diff -puN include/linux/sched.h~tsk_comm include/linux/sched.h
--- linux-2.6.git/include/linux/sched.h~tsk_comm	2011-04-19 18:23:58.435013635 -0700
+++ linux-2.6.git-dave/include/linux/sched.h	2011-04-19 18:24:44.651034028 -0700
@@ -1334,10 +1334,11 @@ struct task_struct {
 					 * credentials (COW) */
 	struct cred *replacement_session_keyring; /* for KEYCTL_SESSION_TO_PARENT */
 
-	char comm[TASK_COMM_LEN]; /* executable name excluding path
+	char comm_buf[TASK_COMM_LEN]; /* executable name excluding path
 				     - access with [gs]et_task_comm (which lock
 				       it with task_lock())
 				     - initialized normally by setup_new_exec */
+	char __rcu *comm;
 /* file system info */
 	int link_count, total_link_count;
 #ifdef CONFIG_SYSVIPC
diff -puN include/linux/init_task.h~tsk_comm include/linux/init_task.h
--- linux-2.6.git/include/linux/init_task.h~tsk_comm	2011-04-19 18:24:48.703035798 -0700
+++ linux-2.6.git-dave/include/linux/init_task.h	2011-04-19 18:25:22.147050279 -0700
@@ -161,7 +161,8 @@ extern struct cred init_cred;
 	.group_leader	= &tsk,						\
 	RCU_INIT_POINTER(.real_cred, &init_cred),			\
 	RCU_INIT_POINTER(.cred, &init_cred),				\
-	.comm		= "swapper",					\
+	.comm_buf	= "swapper",					\
+	.comm		= &tsk.comm_buf, 				\
 	.thread		= INIT_THREAD,					\
 	.fs		= &init_fs,					\
 	.files		= &init_files,					\
diff -puN fs/exec.c~tsk_comm fs/exec.c
--- linux-2.6.git/fs/exec.c~tsk_comm	2011-04-19 18:25:32.283054625 -0700
+++ linux-2.6.git-dave/fs/exec.c	2011-04-19 18:37:47.991485880 -0700
@@ -1007,17 +1007,25 @@ char *get_task_comm(char *buf, struct ta
 
 void set_task_comm(struct task_struct *tsk, char *buf)
 {
+	char tmp_comm[TASK_COMM_LEN];
+
 	task_lock(tsk);
 
+	memcpy(tmp_comm, tsk->comm_buf, TASK_COMM_LEN);
+	tsk->comm = tmp;
 	/*
-	 * Threads may access current->comm without holding
-	 * the task lock, so write the string carefully.
-	 * Readers without a lock may see incomplete new
-	 * names but are safe from non-terminating string reads.
+	 * Make sure no one is still looking at tsk->comm_buf
 	 */
-	memset(tsk->comm, 0, TASK_COMM_LEN);
-	wmb();
-	strlcpy(tsk->comm, buf, sizeof(tsk->comm));
+	synchronize_rcu();
+
+	strlcpy(tsk->comm_buf, buf, sizeof(tsk->comm));
+	tsk->comm = tsk->com_buff;
+	/*
+	 * Make sure no one is still looking at the
+	 * stack-allocated buffer
+	 */
+	synchronize_rcu();
+
 	task_unlock(tsk);
 	perf_event_comm(tsk);
 }


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
