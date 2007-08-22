Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Subject: [PATCH 20 of 24] extract deadlock helper function
Message-Id: <2c9417ab4c1ff81a77bc.1187786947@v2.random>
In-Reply-To: <patchbomb.1187786927@v2.random>
Date: Wed, 22 Aug 2007 14:49:07 +0200
From: Andrea Arcangeli <andrea@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

# HG changeset patch
# User David Rientjes <rientjes@google.com>
# Date 1187778125 -7200
# Node ID 2c9417ab4c1ff81a77bca4767207338e43b5cd69
# Parent  be2fc447cec06990a2a31658b166f0c909777260
extract deadlock helper function

Extracts the jiffies comparison operation, the assignment of the
last_tif_memdie actual, and diagnostic message to its own function.

Cc: Andrea Arcangeli <andrea@suse.de>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 mm/oom_kill.c |   27 +++++++++++++++++++++------
 1 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -29,6 +29,8 @@ int sysctl_panic_on_oom;
 int sysctl_panic_on_oom;
 /* #define DEBUG */
 
+#define OOM_DEADLOCK_TIMEOUT	(10*HZ)
+
 unsigned long VM_is_OOM __cacheline_aligned_in_smp;
 static unsigned long last_tif_memdie_jiffies;
 
@@ -366,6 +368,22 @@ int unregister_oom_notifier(struct notif
 }
 EXPORT_SYMBOL_GPL(unregister_oom_notifier);
 
+/*
+ * Returns 1 if the OOM killer is deadlocked, meaning more than
+ * OOM_DEADLOCK_TIMEOUT time has elapsed since the last task was set to
+ * TIF_MEMDIE.  If it is deadlocked, the actual is updated to jiffies to check
+ * for future timeouts.  Otherwise, return 0.
+ */
+static int oom_is_deadlocked(unsigned long *last_tif_memdie)
+{
+	if (unlikely(time_before(jiffies, *last_tif_memdie +
+					  OOM_DEADLOCK_TIMEOUT)))
+		return 0;
+	*last_tif_memdie = jiffies;
+	printk("detected probable OOM deadlock, so killing another task\n");
+	return 1;
+}
+
 /**
  * out_of_memory - kill the "best" process when we run out of memory
  *
@@ -422,12 +440,9 @@ void out_of_memory(struct zonelist *zone
 		 * so it's equivalent to write_lock_irq(tasklist_lock) as
 		 * far as VM_is_OOM is concerned.
 		 */
-		if (unlikely(test_bit(0, &VM_is_OOM))) {
-			if (time_before(jiffies, last_tif_memdie_jiffies + 10*HZ))
-				goto out;
-			printk("detected probable OOM deadlock, so killing another task\n");
-			last_tif_memdie_jiffies = jiffies;
-		}
+		if (unlikely(test_bit(0, &VM_is_OOM)) &&
+		    !oom_is_deadlocked(&last_tif_memdie_jiffies))
+			goto out;
 
 		if (sysctl_panic_on_oom) {
 			read_unlock(&tasklist_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
