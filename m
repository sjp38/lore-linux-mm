Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 11 of 13] not-wait-memdie
Message-Id: <ecc696d359edebbfe355.1199778642@v2.random>
In-Reply-To: <patchbomb.1199778631@v2.random>
Date: Tue, 08 Jan 2008 08:50:42 +0100
From: Andrea Arcangeli <andrea@cpushare.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User Andrea Arcangeli <andrea@suse.de>
# Date 1199470022 -3600
# Node ID ecc696d359edebbfe35566510f78a4be445c8f67
# Parent  0a13c24681cf4851555c87358fc2ec2465f9ef39
not-wait-memdie

Don't wait tif-memdie tasks forever because they may be stuck in some kernel
lock owned by some task that requires memory to exit the critical section.

Signed-off-by: Andrea Arcangeli <andrea@suse.de>

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -222,12 +222,16 @@ static struct task_struct *select_bad_pr
 		 * being killed. Don't allow any other task access to the
 		 * memory reserve.
 		 *
-		 * Note: this may have a chance of deadlock if it gets
-		 * blocked waiting for another task which itself is waiting
-		 * for memory. Is there a better alternative?
+		 * But if the TIF_MEMDIE task stays around for more than
+		 * MEMDIE_DELAY jiffies, ignore it and fallback killing
+		 * another task.
 		 */
-		if (test_tsk_thread_flag(p, TIF_MEMDIE))
-			return ERR_PTR(-1UL);
+		if (test_tsk_thread_flag(p, TIF_MEMDIE)) {
+			if (time_before(p->memdie_jiffies + MEMDIE_DELAY, jiffies))
+				continue;
+			else
+				return ERR_PTR(-1UL);
+		}
 
 		/*
 		 * This is in the process of releasing memory so wait for it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
