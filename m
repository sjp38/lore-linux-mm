Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 8ED126B005D
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 20:42:19 -0500 (EST)
Received: by mail-pb0-f46.google.com with SMTP id wy7so1596542pbc.19
        for <linux-mm@kvack.org>; Wed, 19 Dec 2012 17:42:18 -0800 (PST)
Date: Wed, 19 Dec 2012 17:42:16 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] sched: numa: ksm: fix oops in task_numa_placment()
Message-ID: <alpine.LNX.2.00.1212191735530.25409@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>, Sasha Levin <sasha.levin@oracle.com>, Petr Holasek <pholasek@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

task_numa_placement() oopsed on NULL p->mm when task_numa_fault()
got called in the handling of break_ksm() for ksmd.  That might be a
peculiar case, which perhaps KSM could takes steps to avoid? but it's
more robust if task_numa_placement() allows for such a possibility.

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 kernel/sched/fair.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

--- 3.7+git/kernel/sched/fair.c	2012-12-16 16:35:08.724441527 -0800
+++ linux/kernel/sched/fair.c	2012-12-18 21:37:24.727964195 -0800
@@ -793,8 +793,11 @@ unsigned int sysctl_numa_balancing_scan_
 
 static void task_numa_placement(struct task_struct *p)
 {
-	int seq = ACCESS_ONCE(p->mm->numa_scan_seq);
+	int seq;
 
+	if (!p->mm)	/* for example, ksmd faulting in a user's mm */
+		return;
+	seq = ACCESS_ONCE(p->mm->numa_scan_seq);
 	if (p->numa_scan_seq == seq)
 		return;
 	p->numa_scan_seq = seq;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
