Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id BA9749000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 18:32:08 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p66MW6gq011365
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 15:32:06 -0700
Received: from pwi5 (pwi5.prod.google.com [10.241.219.5])
	by kpbe20.cbf.corp.google.com with ESMTP id p66MVxLt018645
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 6 Jul 2011 15:32:00 -0700
Received: by pwi5 with SMTP id 5so361432pwi.18
        for <linux-mm@kvack.org>; Wed, 06 Jul 2011 15:31:59 -0700 (PDT)
Date: Wed, 6 Jul 2011 15:31:52 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] oom: make deprecated use of oom_adj more verbose
Message-ID: <alpine.DEB.2.00.1107061531120.8633@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

/proc/pid/oom_adj is deprecated and scheduled for removal in August 2012
according to Documentation/feature-removal-schedule.txt.

This patch makes the warning more verbose by making it appear as a more
serious problem (the presence of a stack trace and being multiline should
attract more attention) so that applications still using the old
interface can get fixed.

Very popular users of the old interface have been converted since the oom
killer rewrite has been introduced.  udevd switched to the
/proc/pid/oom_score_adj interface for v162, kde switched in 4.6.1, and
opensshd switched in 5.7p1.

At the start of 2012, this should be changed into a WARN() to emit all
such incidents and then finally remove the tunable in August 2012 as
scheduled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 fs/proc/base.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/proc/base.c b/fs/proc/base.c
--- a/fs/proc/base.c
+++ b/fs/proc/base.c
@@ -1118,10 +1118,9 @@ static ssize_t oom_adjust_write(struct file *file, const char __user *buf,
 	 * Warn that /proc/pid/oom_adj is deprecated, see
 	 * Documentation/feature-removal-schedule.txt.
 	 */
-	printk_once(KERN_WARNING "%s (%d): /proc/%d/oom_adj is deprecated, "
-			"please use /proc/%d/oom_score_adj instead.\n",
-			current->comm, task_pid_nr(current),
-			task_pid_nr(task), task_pid_nr(task));
+	WARN_ONCE(1, "%s (%d): /proc/%d/oom_adj is deprecated, please use /proc/%d/oom_score_adj instead.\n",
+		  current->comm, task_pid_nr(current), task_pid_nr(task),
+		  task_pid_nr(task));
 	task->signal->oom_adj = oom_adjust;
 	/*
 	 * Scale /proc/pid/oom_score_adj appropriately ensuring that a maximum 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
