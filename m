Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 658516B01B4
	for <linux-mm@kvack.org>; Mon,  5 Jul 2010 20:50:17 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o660oD0w028460
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 6 Jul 2010 09:50:14 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id A7B1E45DE51
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:50:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 73F2045DE50
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:50:13 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 519491DB8053
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:50:13 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id F014B1DB804E
	for <linux-mm@kvack.org>; Tue,  6 Jul 2010 09:50:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 1/2] security: add const to security_task_setscheduler()
In-Reply-To: <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
References: <20100702144941.8fa101c3.akpm@linux-foundation.org> <20100706091607.CCCC.A69D9226@jp.fujitsu.com>
Message-Id: <20100706094913.CCD6.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  6 Jul 2010 09:50:12 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: James Morris <jmorris@namei.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Minchan Kim <minchan.kim@gmail.com>, David Rientjes <rientjes@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

All security modules shouldn't change sched_param parameter of
security_task_setscheduler(). This is not only meaningless, but
also make harmful result if caller pass static variable.

This patch add const to it.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/security.h   |    9 +++++----
 security/commoncap.c       |    2 +-
 security/security.c        |    4 ++--
 security/selinux/hooks.c   |    3 ++-
 security/smack/smack_lsm.c |    2 +-
 5 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/include/linux/security.h b/include/linux/security.h
index 5bcb395..07e94e5 100644
--- a/include/linux/security.h
+++ b/include/linux/security.h
@@ -74,7 +74,8 @@ extern int cap_file_mmap(struct file *file, unsigned long reqprot,
 extern int cap_task_fix_setuid(struct cred *new, const struct cred *old, int flags);
 extern int cap_task_prctl(int option, unsigned long arg2, unsigned long arg3,
 			  unsigned long arg4, unsigned long arg5);
-extern int cap_task_setscheduler(struct task_struct *p, int policy, struct sched_param *lp);
+extern int cap_task_setscheduler(struct task_struct *p, int policy,
+				 const struct sched_param *lp);
 extern int cap_task_setioprio(struct task_struct *p, int ioprio);
 extern int cap_task_setnice(struct task_struct *p, int nice);
 extern int cap_syslog(int type, bool from_file);
@@ -1501,7 +1502,7 @@ struct security_operations {
 	int (*task_getioprio) (struct task_struct *p);
 	int (*task_setrlimit) (unsigned int resource, struct rlimit *new_rlim);
 	int (*task_setscheduler) (struct task_struct *p, int policy,
-				  struct sched_param *lp);
+				  const struct sched_param *lp);
 	int (*task_getscheduler) (struct task_struct *p);
 	int (*task_movememory) (struct task_struct *p);
 	int (*task_kill) (struct task_struct *p,
@@ -1750,8 +1751,8 @@ int security_task_setnice(struct task_struct *p, int nice);
 int security_task_setioprio(struct task_struct *p, int ioprio);
 int security_task_getioprio(struct task_struct *p);
 int security_task_setrlimit(unsigned int resource, struct rlimit *new_rlim);
-int security_task_setscheduler(struct task_struct *p,
-				int policy, struct sched_param *lp);
+int security_task_setscheduler(struct task_struct *p, int policy,
+			       const struct sched_param *lp);
 int security_task_getscheduler(struct task_struct *p);
 int security_task_movememory(struct task_struct *p);
 int security_task_kill(struct task_struct *p, struct siginfo *info,
diff --git a/security/commoncap.c b/security/commoncap.c
index 4e01599..b74d460 100644
--- a/security/commoncap.c
+++ b/security/commoncap.c
@@ -726,7 +726,7 @@ static int cap_safe_nice(struct task_struct *p)
  * specified task, returning 0 if permission is granted, -ve if denied.
  */
 int cap_task_setscheduler(struct task_struct *p, int policy,
-			   struct sched_param *lp)
+			  const struct sched_param *lp)
 {
 	return cap_safe_nice(p);
 }
diff --git a/security/security.c b/security/security.c
index 7461b1b..6151322 100644
--- a/security/security.c
+++ b/security/security.c
@@ -785,8 +785,8 @@ int security_task_setrlimit(unsigned int resource, struct rlimit *new_rlim)
 	return security_ops->task_setrlimit(resource, new_rlim);
 }
 
-int security_task_setscheduler(struct task_struct *p,
-				int policy, struct sched_param *lp)
+int security_task_setscheduler(struct task_struct *p, int policy,
+			       const struct sched_param *lp)
 {
 	return security_ops->task_setscheduler(p, policy, lp);
 }
diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
index 5c9f25b..dd136bd 100644
--- a/security/selinux/hooks.c
+++ b/security/selinux/hooks.c
@@ -3385,7 +3385,8 @@ static int selinux_task_setrlimit(unsigned int resource, struct rlimit *new_rlim
 	return 0;
 }
 
-static int selinux_task_setscheduler(struct task_struct *p, int policy, struct sched_param *lp)
+static int selinux_task_setscheduler(struct task_struct *p, int policy,
+				     const struct sched_param *lp)
 {
 	int rc;
 
diff --git a/security/smack/smack_lsm.c b/security/smack/smack_lsm.c
index 07abc9c..c3336f1 100644
--- a/security/smack/smack_lsm.c
+++ b/security/smack/smack_lsm.c
@@ -1280,7 +1280,7 @@ static int smack_task_getioprio(struct task_struct *p)
  * Return 0 if read access is permitted
  */
 static int smack_task_setscheduler(struct task_struct *p, int policy,
-				   struct sched_param *lp)
+				   const struct sched_param *lp)
 {
 	int rc;
 
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
