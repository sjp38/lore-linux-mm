Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 1690F6B0289
	for <linux-mm@kvack.org>; Tue,  4 May 2010 19:51:25 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o44NpLKg022070
	for <linux-mm@kvack.org>; Tue, 4 May 2010 16:51:22 -0700
Received: from pvc30 (pvc30.prod.google.com [10.241.209.158])
	by wpaz37.hot.corp.google.com with ESMTP id o44NpJva019102
	for <linux-mm@kvack.org>; Tue, 4 May 2010 16:51:20 -0700
Received: by pvc30 with SMTP id 30so568064pvc.13
        for <linux-mm@kvack.org>; Tue, 04 May 2010 16:51:19 -0700 (PDT)
Date: Tue, 4 May 2010 16:51:14 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
Message-ID: <alpine.DEB.2.00.1005041650040.13683@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It's pointless to try to kill current if select_bad_process() did not
find an eligible task to kill in mem_cgroup_out_of_memory() since it's
guaranteed that current is a member of the memcg that is oom and it is,
by definition, unkillable.

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -512,12 +512,9 @@ void mem_cgroup_out_of_memory(struct mem_cgroup *mem, gfp_t gfp_mask)
 	read_lock(&tasklist_lock);
 retry:
 	p = select_bad_process(&points, limit, mem, CONSTRAINT_NONE, NULL);
-	if (PTR_ERR(p) == -1UL)
+	if (!p || PTR_ERR(p) == -1UL)
 		goto out;
 
-	if (!p)
-		p = current;
-
 	if (oom_kill_process(p, gfp_mask, 0, points, limit, mem,
 				"Memory cgroup out of memory"))
 		goto retry;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
