Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 856A86B0062
	for <linux-mm@kvack.org>; Wed, 11 Jan 2012 22:24:31 -0500 (EST)
Received: by mail-gx0-f169.google.com with SMTP id p4so957693ggn.14
        for <linux-mm@kvack.org>; Wed, 11 Jan 2012 19:24:31 -0800 (PST)
Date: Wed, 11 Jan 2012 19:24:28 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 3/3] mm, oom: do not emit oom killer warning if chosen thread
 is already exiting
In-Reply-To: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1201111924050.3982@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1201111922500.3982@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org

If a thread is chosen for oom kill and is already PF_EXITING, then the
oom killer simply sets TIF_MEMDIE and returns.  This allows the thread to
have access to memory reserves so that it may quickly exit.  This logic
is preceeded with a comment saying there's no need to alarm the sysadmin.
This patch adds truth to that statement.

There's no need to emit any warning about the oom condition if the thread
is already exiting since it will not be killed.  In this condition, just
silently return the oom killer since its only giving access to memory
reserves and is otherwise a no-op.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -445,9 +445,6 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct mm_struct *mm;
 	unsigned int victim_points = 0;
 
-	if (printk_ratelimit())
-		dump_header(p, gfp_mask, order, mem, nodemask);
-
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
@@ -457,6 +454,9 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		return;
 	}
 
+	if (printk_ratelimit())
+		dump_header(p, gfp_mask, order, mem, nodemask);
+
 	task_lock(p);
 	pr_err("%s: Kill process %d (%s) score %d or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
