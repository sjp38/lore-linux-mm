Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 04 of 24] serialize oom killer
Message-Id: <871b7a4fd566de081120.1187786931@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:48:51 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1187778125 -7200
# Node ID 871b7a4fd566de0811207628b74abea0a73341f6
# Parent  5566f2af006a171cd47d596c6654f51beca74203
serialize oom killer

It's risky and useless to run two oom killers in parallel, let serialize it to
reduce the probability of spurious oom-killage.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -401,12 +401,15 @@ void out_of_memory(struct zonelist *zone
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
@@ -473,4 +476,6 @@ out:
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
