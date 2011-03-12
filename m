Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E38908D003A
	for <linux-mm@kvack.org>; Sat, 12 Mar 2011 08:52:52 -0500 (EST)
Date: Sat, 12 Mar 2011 14:44:11 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/3] oom: oom_kill_task: mark every thread as TIF_MEMDIE
Message-ID: <20110312134411.GB27275@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110312134341.GA27275@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>

oom_kill_task() kills the whole thread group, but only one task gets
TIF_MEMDIE. This can't be right, every test_thread_flag(TIF_MEMDIE)
check is per-thread.

I think it should be replaced by MMF_, but as a first step let's change
oom_kill_task() to mark every sub-thread as TIF_MEMDIE. And change the
"Kill all processes sharing p->mm" code the same way.

This also fixes another problem. sysctl_oom_kill_allocating_task case
does oom_kill_process(current). If current is not the main thread, then
select_bad_process() won't see the TIF_MEMDIE task.

Note:

	- oom_kill_task()->for_each_process() is wrong. It can't detect
	  all processes sharing p->mm. The fix is simple

	- This patch doesn't change other callers of set_*(TIF_MEMDIE).
	  This needs a separate discussion, but oom_kill_process() is
	  simply wrong.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 mm/oom_kill.c |   18 ++++++++++++++----
 1 file changed, 14 insertions(+), 4 deletions(-)

--- 38/mm/oom_kill.c~oom_kill_spread_memdie	2011-03-12 14:19:36.000000000 +0100
+++ 38/mm/oom_kill.c	2011-03-12 14:20:42.000000000 +0100
@@ -401,6 +401,18 @@ static void dump_header(struct task_stru
 		dump_tasks(mem, nodemask);
 }
 
+static void do_oom_kill(struct task_struct *p)
+{
+	struct task_struct *t;
+
+	t = p;
+	do {
+		set_tsk_thread_flag(t, TIF_MEMDIE);
+	} while_each_thread(p, t);
+
+	force_sig(SIGKILL, p);
+}
+
 #define K(x) ((x) << (PAGE_SHIFT-10))
 static int oom_kill_task(struct task_struct *p, struct mem_cgroup *mem)
 {
@@ -436,12 +448,10 @@ static int oom_kill_task(struct task_str
 			pr_err("Kill process %d (%s) sharing same memory\n",
 				task_pid_nr(q), q->comm);
 			task_unlock(q);
-			force_sig(SIGKILL, q);
+			do_oom_kill(q);
 		}
 
-	set_tsk_thread_flag(p, TIF_MEMDIE);
-	force_sig(SIGKILL, p);
-
+	do_oom_kill(p);
 	/*
 	 * We give our sacrificial lamb high priority and access to
 	 * all the memory it needs. That way it should be able to

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
