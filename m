Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1C25C6B00AE
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 05:41:55 -0500 (EST)
Received: from spaceape23.eur.corp.google.com (spaceape23.eur.corp.google.com [172.28.16.75])
	by smtp-out.google.com with ESMTP id o2AAfqUi022623
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 02:41:53 -0800
Received: from pzk14 (pzk14.prod.google.com [10.243.19.142])
	by spaceape23.eur.corp.google.com with ESMTP id o2AAfodm025841
	for <linux-mm@kvack.org>; Wed, 10 Mar 2010 02:41:51 -0800
Received: by pzk14 with SMTP id 14so2414278pzk.26
        for <linux-mm@kvack.org>; Wed, 10 Mar 2010 02:41:50 -0800 (PST)
Date: Wed, 10 Mar 2010 02:41:48 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: [patch 10/10 -mm v3] oom: default to killing current for pagefault
 ooms
In-Reply-To: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.00.1003100240350.30013@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1003100236510.30013@chino.kir.corp.google.com>
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
