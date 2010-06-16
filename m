Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8A1736B01B6
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 20:08:08 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5G0841K004251
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 16 Jun 2010 09:08:05 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 745F645DE55
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:08:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 41B8845DE4C
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:08:04 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 23806E38004
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:08:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id BA5161DB8013
	for <linux-mm@kvack.org>; Wed, 16 Jun 2010 09:08:03 +0900 (JST)
Date: Wed, 16 Jun 2010 09:03:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] use find_lock_task_mm in memory cgroups oom v2
Message-Id: <20100616090334.d27e0c4e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinEEYWULLICKqBr4yX7GL01E4cq0jQSfuN8J6Jq@mail.gmail.com>
References: <20100615152450.f82c1f8c.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinEEYWULLICKqBr4yX7GL01E4cq0jQSfuN8J6Jq@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Oleg Nesterov <oleg@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Jun 2010 18:59:25 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> > -/*
> > +/**
> > + * find_lock_task_mm - Checking a process which a task belongs to has valid mm
> > + * and return a locked task which has a valid pointer to mm.
> > + *
> 
> This comment should have been another patch.
> BTW, below comment uses "subthread" word.
> Personally it's easy to understand function's goal to me. :)
> 
> How about following as?
> Checking a process which has any subthread with vaild mm
> ....
> 
Sure. thank you. v2 is here. I removed unnecessary parts.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

When the OOM killer scans task, it check a task is under memcg or
not when it's called via memcg's context.

But, as Oleg pointed out, a thread group leader may have NULL ->mm
and task_in_mem_cgroup() may do wrong decision. We have to use
find_lock_task_mm() in memcg as generic OOM-Killer does.

Changelog:
 - removed unnecessary changes in comments.

Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/oom.h |    2 ++
 mm/memcontrol.c     |   10 +++++++---
 mm/oom_kill.c       |    2 +-
 3 files changed, 10 insertions(+), 4 deletions(-)

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
@@ -87,7 +87,7 @@ static bool has_intersects_mems_allowed(
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
