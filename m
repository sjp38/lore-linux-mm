Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 637BC6B01F0
	for <linux-mm@kvack.org>; Tue, 30 Mar 2010 12:41:21 -0400 (EDT)
Date: Tue, 30 Mar 2010 18:39:09 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH] oom: fix the unsafe proc_oom_score()->badness() call
Message-ID: <20100330163909.GA16884@redhat.com>
References: <1269447905-5939-1-git-send-email-anfei.zhou@gmail.com> <20100326150805.f5853d1c.akpm@linux-foundation.org> <20100326223356.GA20833@redhat.com> <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329112111.GA16971@redhat.com> <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1003291302170.14859@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

proc_oom_score(task) have a reference to task_struct, but that is all.
If this task was already released before we take tasklist_lock

	- we can't use task->group_leader, it points to nowhere

	- it is not safe to call badness() even if this task is
	  ->group_leader, has_intersects_mems_allowed() assumes
	  it is safe to iterate over ->thread_group list.

Add the pid_alive() check to ensure __unhash_process() was not called.

Note: I think we shouldn't use ->group_leader, badness() should return
the same result for any sub-thread. However this is not true currently,
and I think that ->mm check and list_for_each_entry(p->children) in
badness are not right.

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---

 fs/proc/base.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

--- 34-rc1/fs/proc/base.c~OOM_SCORE	2010-03-22 16:36:28.000000000 +0100
+++ 34-rc1/fs/proc/base.c	2010-03-30 18:23:50.000000000 +0200
@@ -430,12 +430,13 @@ static const struct file_operations proc
 unsigned long badness(struct task_struct *p, unsigned long uptime);
 static int proc_oom_score(struct task_struct *task, char *buffer)
 {
-	unsigned long points;
+	unsigned long points = 0;
 	struct timespec uptime;
 
 	do_posix_clock_monotonic_gettime(&uptime);
 	read_lock(&tasklist_lock);
-	points = badness(task->group_leader, uptime.tv_sec);
+	if (pid_alive(task))
+		points = badness(task->group_leader, uptime.tv_sec);
 	read_unlock(&tasklist_lock);
 	return sprintf(buffer, "%lu\n", points);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
