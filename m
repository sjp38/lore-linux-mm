Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 2482C6B002C
	for <linux-mm@kvack.org>; Mon, 13 Feb 2012 20:07:34 -0500 (EST)
Received: by dadv6 with SMTP id v6so6168678dad.14
        for <linux-mm@kvack.org>; Mon, 13 Feb 2012 17:07:33 -0800 (PST)
Date: Mon, 13 Feb 2012 17:07:31 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] mm, oom: introduce independent oom killer ratelimit
 state
Message-ID: <alpine.DEB.2.00.1202131706320.30721@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org

printk_ratelimit() uses the global ratelimit state for all printks.  The
oom killer should not be subjected to this state just because another
subsystem or driver may be flooding the kernel log.

This patch introduces printk ratelimiting specifically for the oom
killer.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -34,6 +34,7 @@
 #include <linux/ptrace.h>
 #include <linux/freezer.h>
 #include <linux/ftrace.h>
+#include <linux/ratelimit.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/oom.h>
@@ -444,6 +445,8 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 	struct task_struct *t = p;
 	struct mm_struct *mm;
 	unsigned int victim_points = 0;
+	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
+					      DEFAULT_RATELIMIT_BURST);
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -454,7 +457,7 @@ static void oom_kill_process(struct task_struct *p, gfp_t gfp_mask, int order,
 		return;
 	}
 
-	if (printk_ratelimit())
+	if (__ratelimit(&oom_rs))
 		dump_header(p, gfp_mask, order, memcg, nodemask);
 
 	task_lock(p);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
