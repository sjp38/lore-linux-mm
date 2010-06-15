Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 19FAE6B01C4
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 02:29:30 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5F6TS51013155
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 15 Jun 2010 15:29:28 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id C578E45DE4E
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:29:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 9AE5E45DE50
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:29:27 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D78B1DB8054
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:29:27 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0683B1DB804F
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 15:29:27 +0900 (JST)
Date: Tue, 15 Jun 2010 15:24:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] use find_lock_task_mm in memory cgroups oom
Message-Id: <20100615152450.f82c1f8c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>


based on  oom-introduce-find_lock_task_mm-to-fix-mm-false-positives.patch
tested on mm-of-the-moment snapshot 2010-06-11-16-40.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When the OOM killer scans task, it check a task is under memcg or
not when it's called via memcg's context.

But, as Oleg pointed out, a thread group leader may have NULL ->mm
and task_in_mem_cgroup() may do wrong decision. We have to use
find_lock_task_mm() in memcg as generic OOM-Killer does.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/oom.h |    2 ++
 mm/memcontrol.c     |   10 +++++++---
 mm/oom_kill.c       |    8 ++++++--
 3 files changed, 15 insertions(+), 5 deletions(-)

Index: mmotm-2.6.35-0611/include/linux/oom.h
===================================================================
--- mmotm-2.6.35-0611.orig/include/linux/oom.h
+++ mmotm-2.6.35-0611/include/linux/oom.h
@@ -45,6 +45,8 @@ static inline void oom_killer_enable(voi
 	oom_killer_disabled = false;
 }
 
+extern struct task_struct *find_lock_task_mm(struct task_struct *p);
+
 /* sysctls */
 extern int sysctl_oom_dump_tasks;
 extern int sysctl_oom_kill_allocating_task;
Index: mmotm-2.6.35-0611/mm/memcontrol.c
===================================================================
--- mmotm-2.6.35-0611.orig/mm/memcontrol.c
+++ mmotm-2.6.35-0611/mm/memcontrol.c
@@ -47,6 +47,7 @@
 #include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 #include <linux/cpu.h>
+#include <linux/oom.h>
 #include "internal.h"
 
 #include <asm/uaccess.h>
@@ -838,10 +839,13 @@ int task_in_mem_cgroup(struct task_struc
 {
 	int ret;
 	struct mem_cgroup *curr = NULL;
+	struct task_struct *p;
 
-	task_lock(task);
-	curr = try_get_mem_cgroup_from_mm(task->mm);
-	task_unlock(task);
+	p = find_lock_task_mm(task);
+	if (!p)
+		return 0;
+	curr = try_get_mem_cgroup_from_mm(p->mm);
+	task_unlock(p);
 	if (!curr)
 		return 0;
 	/*
Index: mmotm-2.6.35-0611/mm/oom_kill.c
===================================================================
--- mmotm-2.6.35-0611.orig/mm/oom_kill.c
+++ mmotm-2.6.35-0611/mm/oom_kill.c
@@ -81,13 +81,17 @@ static bool has_intersects_mems_allowed(
 }
 #endif /* CONFIG_NUMA */
 
-/*
+/**
+ * find_lock_task_mm - Checking a process which a task belongs to has valid mm
+ * and return a locked task which has a valid pointer to mm.
+ *
+ * @p: the task of a process to be checked.
  * The process p may have detached its own ->mm while exiting or through
  * use_mm(), but one or more of its subthreads may still have a valid
  * pointer.  Return p, or any of its subthreads with a valid ->mm, with
  * task_lock() held.
  */
-static struct task_struct *find_lock_task_mm(struct task_struct *p)
+struct task_struct *find_lock_task_mm(struct task_struct *p)
 {
 	struct task_struct *t = p;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
