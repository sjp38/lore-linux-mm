Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF7FA6B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:55:35 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id y7so5860295pgb.16
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 22:55:35 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id i2si8997411plk.126.2017.10.18.22.55.33
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 22:55:33 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 3/3] lockdep: Add a kernel parameter, crossrelease_fullstack
Date: Thu, 19 Oct 2017 14:55:31 +0900
Message-Id: <1508392531-11284-4-git-send-email-byungchul.park@lge.com>
In-Reply-To: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
References: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

Make whether to allow recording full stack, in cross-release feature,
switchable at boot time via a kernel parameter, 'crossrelease_fullstack'.
In case of a splat with no stack trace, one could just reboot and set
the kernel parameter to get the full data without having to recompile
the kernel.

Change CONFIG_CROSSRELEASE_STACK_TRACE default from N to Y, and
introduce the new kernel parameter.

Suggested-by: Thomas Gleixner <tglx@linutronix.de>
Signed-off-by: Byungchul Park <byungchul.park@lge.com>
---
 Documentation/admin-guide/kernel-parameters.txt |  3 +++
 kernel/locking/lockdep.c                        | 18 ++++++++++++++++--
 lib/Kconfig.debug                               |  5 +++--
 3 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
index ead7f40..4107b01 100644
--- a/Documentation/admin-guide/kernel-parameters.txt
+++ b/Documentation/admin-guide/kernel-parameters.txt
@@ -709,6 +709,9 @@
 			It will be ignored when crashkernel=X,high is not used
 			or memory reserved is below 4G.
 
+	crossrelease_fullstack
+			[KNL] Allow to record full stack trace in cross-release
+
 	cryptomgr.notests
                         [KNL] Disable crypto self-tests
 
diff --git a/kernel/locking/lockdep.c b/kernel/locking/lockdep.c
index 5c2ddf2..feba887 100644
--- a/kernel/locking/lockdep.c
+++ b/kernel/locking/lockdep.c
@@ -76,6 +76,15 @@
 #define lock_stat 0
 #endif
 
+static int crossrelease_fullstack;
+static int __init allow_crossrelease_fullstack(char *str)
+{
+	crossrelease_fullstack = 1;
+	return 0;
+}
+
+early_param("crossrelease_fullstack", allow_crossrelease_fullstack);
+
 /*
  * lockdep_lock: protects the lockdep graph, the hashes and the
  *               class/list/hash allocators.
@@ -4864,8 +4873,13 @@ static void add_xhlock(struct held_lock *hlock)
 	xhlock->trace.max_entries = MAX_XHLOCK_TRACE_ENTRIES;
 	xhlock->trace.entries = xhlock->trace_entries;
 #ifdef CONFIG_CROSSRELEASE_STACK_TRACE
-	xhlock->trace.skip = 3;
-	save_stack_trace(&xhlock->trace);
+	if (crossrelease_fullstack) {
+		xhlock->trace.skip = 3;
+		save_stack_trace(&xhlock->trace);
+	} else {
+		xhlock->trace.nr_entries = 1;
+		xhlock->trace.entries[0] = hlock->acquire_ip;
+	}
 #else
 	xhlock->trace.nr_entries = 1;
 	xhlock->trace.entries[0] = hlock->acquire_ip;
diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index fe8fceb..132536d 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1228,7 +1228,7 @@ config LOCKDEP_COMPLETIONS
 config CROSSRELEASE_STACK_TRACE
 	bool "Record more than one entity of stack trace in crossrelease"
 	depends on LOCKDEP_CROSSRELEASE
-	default n
+	default y
 	help
 	 The lockdep "cross-release" feature needs to record stack traces
 	 (of calling functions) for all acquisitions, for eventual later
@@ -1238,7 +1238,8 @@ config CROSSRELEASE_STACK_TRACE
 	 full analysis. This option turns on the saving of the full stack
 	 trace entries.
 
-	 If unsure, say N.
+	 To make the feature actually on, set "crossrelease_fullstack"
+	 kernel parameter, too.
 
 config DEBUG_LOCKDEP
 	bool "Lock dependency engine debugging"
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
