Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id D331A8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 15:14:15 -0400 (EDT)
Date: Mon, 14 Mar 2011 20:05:30 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 3/3 for 2.6.38] oom: oom_kill_process: fix the child_points
	logic
Message-ID: <20110314190530.GD21845@redhat.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110314190419.GA21845@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

oom_kill_process() starts with victim_points == 0. This means that
(most likely) any child has more points and can be killed erroneously.

Also, "children has a different mm" doesn't match the reality, we
should check child->mm != t->mm. This check is not exactly correct
if t->mm == NULL but this doesn't really matter, oom_kill_task()
will kill them anyway.

Note: "Kill all processes sharing p->mm" in oom_kill_task() is wrong
too.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 mm/oom_kill.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

--- 38/mm/oom_kill.c~3_fix_kill_chld	2011-03-14 18:52:39.000000000 +0100
+++ 38/mm/oom_kill.c	2011-03-14 19:36:01.000000000 +0100
@@ -459,10 +459,10 @@ static int oom_kill_process(struct task_
 			    struct mem_cgroup *mem, nodemask_t *nodemask,
 			    const char *message)
 {
-	struct task_struct *victim = p;
+	struct task_struct *victim;
 	struct task_struct *child;
-	struct task_struct *t = p;
-	unsigned int victim_points = 0;
+	struct task_struct *t;
+	unsigned int victim_points;
 
 	if (printk_ratelimit())
 		dump_header(p, gfp_mask, order, mem, nodemask);
@@ -488,10 +488,15 @@ static int oom_kill_process(struct task_
 	 * parent.  This attempts to lose the minimal amount of work done while
 	 * still freeing memory.
 	 */
+	victim_points = oom_badness(p, mem, nodemask, totalpages);
+	victim = p;
+	t = p;
 	do {
 		list_for_each_entry(child, &t->children, sibling) {
 			unsigned int child_points;
 
+			if (child->mm == t->mm)
+				continue;
 			/*
 			 * oom_badness() returns 0 if the thread is unkillable
 			 */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
