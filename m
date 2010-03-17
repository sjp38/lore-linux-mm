Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id DF60660036A
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 04:55:58 -0400 (EDT)
Received: from kpbe14.cbf.corp.google.com (kpbe14.cbf.corp.google.com [172.25.105.78])
	by smtp-out.google.com with ESMTP id o2H8tuFs014053
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:56 -0700
Received: from pzk3 (pzk3.prod.google.com [10.243.19.131])
	by kpbe14.cbf.corp.google.com with ESMTP id o2H8tl2Z026835
	for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:55 -0700
Received: by pzk3 with SMTP id 3so520961pzk.24
        for <linux-mm@kvack.org>; Wed, 17 Mar 2010 01:55:55 -0700 (PDT)
Date: Wed, 17 Mar 2010 01:55:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 10/11 -mm v4] oom: default to killing current for pagefault
 ooms
In-Reply-To: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1003170154460.31796@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003170151540.31796@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Nick Piggin <npiggin@suse.de>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The pagefault oom handler does not know the context (gfp_mask, order,
etc) in which memory was not found when a VM_FAULT_OOM is generated.  The
only information known is that current is trying to allocate in that
context, so killing it is a legitimate response (and is the default for
architectures that do not even use the pagefault oom handler such as ia64
and powerpc).

When a VM_FAULT_OOM occurs, the pagefault oom handler will now attempt to
kill current by default.  If it is unkillable, the oom killer is called
to find a memory-hogging task to kill instead that will lead to future
memory freeing.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -711,15 +711,23 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 }
 
 /*
- * The pagefault handler calls here because it is out of memory, so kill a
- * memory-hogging task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel
- * oom killing is already in progress so do nothing.  If a task is found with
- * TIF_MEMDIE set, it has been killed so do nothing and allow it to exit.
+ * The pagefault handler calls here because it is out of memory, so kill current
+ * by default.  If it's unkillable, then fallback to killing a memory-hogging
+ * task.  If a populated zone has ZONE_OOM_LOCKED set, a parallel oom killing is
+ * already in progress so do nothing.  If a task is found with TIF_MEMDIE set,
+ * it has been killed so do nothing and allow it to exit.
  */
 void pagefault_out_of_memory(void)
 {
+	unsigned long totalpages;
+	int err;
+
 	if (try_set_system_oom()) {
-		out_of_memory(NULL, 0, 0, NULL);
+		constrained_alloc(NULL, 0, NULL, &totalpages);
+		err = oom_kill_process(current, 0, 0, 0, totalpages, NULL,
+					"Out of memory (pagefault)");
+		if (err)
+			out_of_memory(NULL, 0, 0, NULL);
 		clear_system_oom();
 	}
 	if (!test_thread_flag(TIF_MEMDIE))

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
