Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f171.google.com (mail-ig0-f171.google.com [209.85.213.171])
	by kanga.kvack.org (Postfix) with ESMTP id 16BF1280268
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 19:45:17 -0400 (EDT)
Received: by iggp10 with SMTP id p10so109878934igg.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:45:16 -0700 (PDT)
Received: from mail-ig0-x230.google.com (mail-ig0-x230.google.com. [2607:f8b0:4001:c05::230])
        by mx.google.com with ESMTPS id m67si2076713iod.128.2015.07.14.16.45.16
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Jul 2015 16:45:16 -0700 (PDT)
Received: by igbij6 with SMTP id ij6so58792730igb.1
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 16:45:16 -0700 (PDT)
Date: Tue, 14 Jul 2015 16:45:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch -mm 2/2] mm, oom: remove unnecessary variable
In-Reply-To: <alpine.DEB.2.10.1507141644320.16182@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1507141644530.16182@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1507141644320.16182@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Michal Hocko <mhocko@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

The "killed" variable in out_of_memory() can be removed since the call to
oom_kill_process() where we should block to allow the process time to
exit is obvious.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c | 21 ++++++++-------------
 1 file changed, 8 insertions(+), 13 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -645,7 +645,6 @@ bool out_of_memory(struct oom_control *oc)
 	unsigned long freed = 0;
 	unsigned int uninitialized_var(points);
 	enum oom_constraint constraint = CONSTRAINT_NONE;
-	int killed = 0;
 
 	if (oom_killer_disabled)
 		return false;
@@ -653,7 +652,7 @@ bool out_of_memory(struct oom_control *oc)
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
 		/* Got some memory back in the last second. */
-		goto out;
+		return true;
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
@@ -666,7 +665,7 @@ bool out_of_memory(struct oom_control *oc)
 	if (current->mm &&
 	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
 		mark_oom_victim(current);
-		goto out;
+		return true;
 	}
 
 	/*
@@ -684,7 +683,7 @@ bool out_of_memory(struct oom_control *oc)
 		get_task_struct(current);
 		oom_kill_process(oc, current, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
-		goto out;
+		return true;
 	}
 
 	p = select_bad_process(oc, &points, totalpages);
@@ -696,16 +695,12 @@ bool out_of_memory(struct oom_control *oc)
 	if (p && p != (void *)-1UL) {
 		oom_kill_process(oc, p, points, totalpages, NULL,
 				 "Out of memory");
-		killed = 1;
-	}
-out:
-	/*
-	 * Give the killed threads a good chance of exiting before trying to
-	 * allocate memory again.
-	 */
-	if (killed)
+		/*
+		 * Give the killed process a good chance to exit before trying
+		 * to allocate memory again.
+		 */
 		schedule_timeout_killable(1);
-
+	}
 	return true;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
