Date: Tue, 18 Sep 2007 09:44:37 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch 2/4] oom: move constraints to enum
In-Reply-To: <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.0.9999.0709180246350.21326@chino.kir.corp.google.com>
References: <871b7a4fd566de081120.1187786931@v2.random> <Pine.LNX.4.64.0709121658450.4489@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131126370.27997@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131136560.9590@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709131139340.30279@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131152400.9999@schroedinger.engr.sgi.com> <alpine.DEB.0.9999.0709131732330.21805@chino.kir.corp.google.com> <Pine.LNX.4.64.0709131923410.12159@schroedinger.engr.sgi.com>
 <alpine.DEB.0.9999.0709132010050.30494@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180007420.4624@chino.kir.corp.google.com> <alpine.DEB.0.9999.0709180245170.21326@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, Christoph Lameter <clameter@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

The OOM killer's CONSTRAINT definitions are really more appropriate in an
enum, so define them in include/linux/oom.h.

Cc: Andrea Arcangeli <andrea@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>
Signed-off-by: David Rientjes <rientjes@google.com>
---
 include/linux/oom.h |    9 +++++++++
 mm/oom_kill.c       |   12 +++---------
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -11,6 +11,15 @@
 
 #ifdef __KERNEL__
 
+/*
+ * Types of limitations to the nodes from which allocations may occur
+ */
+enum oom_constraint {
+	CONSTRAINT_NONE,
+	CONSTRAINT_CPUSET,
+	CONSTRAINT_MEMORY_POLICY,
+};
+
 extern void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order);
 extern int register_oom_notifier(struct notifier_block *nb);
 extern int unregister_oom_notifier(struct notifier_block *nb);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -164,16 +164,10 @@ unsigned long badness(struct task_struct *p, unsigned long uptime)
 }
 
 /*
- * Types of limitations to the nodes from which allocations may occur
- */
-#define CONSTRAINT_NONE 1
-#define CONSTRAINT_MEMORY_POLICY 2
-#define CONSTRAINT_CPUSET 3
-
-/*
  * Determine the type of allocation constraint.
  */
-static inline int constrained_alloc(struct zonelist *zonelist, gfp_t gfp_mask)
+static inline enum oom_constraint constrained_alloc(struct zonelist *zonelist,
+						    gfp_t gfp_mask)
 {
 #ifdef CONFIG_NUMA
 	struct zone **z;
@@ -400,7 +394,7 @@ void out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask, int order)
 	struct task_struct *p;
 	unsigned long points = 0;
 	unsigned long freed = 0;
-	int constraint;
+	enum oom_constraint constraint;
 
 	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
 	if (freed > 0)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
