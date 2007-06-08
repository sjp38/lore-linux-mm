Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 0442C12207
	for <linux-mm@kvack.org>; Fri,  8 Jun 2007 22:06:44 +0200 (CEST)
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 04 of 16] serialize oom killer
Message-Id: <baa866fedc79cb333b90.1181332982@v2.random>
In-Reply-To: <patchbomb.1181332978@v2.random>
Date: Fri, 08 Jun 2007 22:03:02 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1181332960 -7200
# Node ID baa866fedc79cb333b90004da2730715c145f1d5
# Parent  532a5f712848ee75d827bfe233b9364a709e1fc1
serialize oom killer

It's risky and useless to run two oom killers in parallel, let serialize it to
reduce the probability of spurious oom-killage.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -400,12 +400,15 @@ void out_of_memory(struct zonelist *zone
 	unsigned long points = 0;
 	unsigned long freed = 0;
 	int constraint;
+	static DECLARE_MUTEX(OOM_lock);
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)
 		/* Got some memory back in the last second. */
 		return;
 
+	if (down_trylock(&OOM_lock))
+		return;
 	if (printk_ratelimit()) {
 		printk(KERN_WARNING "%s invoked oom-killer: "
 			"gfp_mask=0x%x, order=%d, oomkilladj=%d\n",
@@ -472,4 +475,6 @@ out:
 	 */
 	if (!test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
-}
+
+	up(&OOM_lock);
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
