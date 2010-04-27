Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 77A946B01F4
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 19:01:14 -0400 (EDT)
Received: from hpaq7.eem.corp.google.com (hpaq7.eem.corp.google.com [10.3.21.7])
	by smtp-out.google.com with ESMTP id o3RN1Bl7032099
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 16:01:11 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by hpaq7.eem.corp.google.com with ESMTP id o3RN18p0024067
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 16:01:09 -0700
Received: by pzk3 with SMTP id 3so6423802pzk.26
        for <linux-mm@kvack.org>; Tue, 27 Apr 2010 16:01:08 -0700 (PDT)
Date: Tue, 27 Apr 2010 16:01:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] oom: avoid divide by zero
Message-ID: <alpine.DEB.2.00.1004271600220.19364@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's evidently possible for a memory controller to have a limit of 0
bytes, so it's possible for the oom killer to have a divide by zero error
in such circumstances.

When this is the case, each candidate task's rss and swap is divided by
one so they are essentially ranked according to whichever task attached
to the cgroup has the most resident RAM and swap.

Reported-by: Greg Thelen <gthelen@google.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -189,6 +189,14 @@ unsigned int oom_badness(struct task_struct *p, unsigned long totalpages)
 	p = find_lock_task_mm(p);
 	if (!p)
 		return 0;
+
+	/*
+	 * The memory controller can have a limit of 0 bytes, so avoid a divide
+	 * by zero if necessary.
+	 */
+	if (!totalpages)
+		totalpages = 1;
+
 	/*
 	 * The baseline for the badness score is the proportion of RAM that each
 	 * task's rss and swap space use.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
