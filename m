Date: Wed, 27 Jun 2007 07:44:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 1/4] oom: extract deadlock helper function
Message-ID: <alpine.DEB.0.99.0706261947490.24949@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

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
@@ -28,6 +28,8 @@
 int sysctl_panic_on_oom;
 /* #define DEBUG */
 
+#define OOM_DEADLOCK_TIMEOUT	(10*HZ)
+
 unsigned long VM_is_OOM;
 static unsigned long last_tif_memdie_jiffies;
 
@@ -365,6 +367,22 @@ int unregister_oom_notifier(struct notifier_block *nb)
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
@@ -421,12 +439,9 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
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
