Subject: Re: [patch] updated scheduler-tunables for 2.5.64-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <1047095088.727.5.camel@phantasy.awol.org>
References: <20030307185116.0c53e442.akpm@digeo.com>
	 <1047095088.727.5.camel@phantasy.awol.org>
Content-Type: text/plain
Message-Id: <1047095405.727.11.camel@phantasy.awol.org>
Mime-Version: 1.0
Date: 07 Mar 2003 22:50:06 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2003-03-07 at 22:44, Robert Love wrote:

> Attached patch is a complete replacement for the old patch.  It defaults
> the tunable parameters to the new values in 2.5-bk.  I also added a
> tuning knob for the NUMA node threshold stuff.

I am in an accommodating mood... while the first patch was most likely
easiest for Andrew to use (swap out the old for the new), an incremental
diff is probably easier for the users to just apply on top of
2.5.64-mm2.

So here is an incremental diff, which has the following changes over
what is in 2.5-mm now:

	- update the tunable parameters to have the new defaults
	  Linus applied to 2.5-bk.  These defaults are similar to
	  the values in the sched-rml-updates.patch Andrew had
	  in here for awhile, and I like them.

	- add tuning for the node_threshold parameter for NUMA
	  folks

I encourage users to apply this, since we are getting close to sniffing
out the last of the interactivity woes and these updated parameters are
a large part of the solution.

Enjoy,

	Robert Love


 include/linux/sysctl.h |    1 +
 kernel/sched.c         |   11 ++++++-----
 kernel/sysctl.c        |    4 ++++
 3 files changed, 11 insertions(+), 5 deletions(-)


diff -urN linux-2.5.64-mm2/include/linux/sysctl.h linux/include/linux/sysctl.h
--- linux-2.5.64-mm2/include/linux/sysctl.h	2003-03-07 22:08:04.000000000 -0500
+++ linux/include/linux/sysctl.h	2003-03-07 22:08:19.000000000 -0500
@@ -169,6 +169,7 @@
 	SCHED_INTERACTIVE_DELTA=7,	/* delta used to scale interactivity */
 	SCHED_MAX_SLEEP_AVG=8,		/* maximum sleep avg attainable */
 	SCHED_STARVATION_LIMIT=9,	/* no re-active if expired is starved */
+	SCHED_NODE_THRESHOLD=10,	/* NUMA node rebalance threshold */
 };
 
 /* CTL_NET names: */
diff -urN linux-2.5.64-mm2/kernel/sched.c linux/kernel/sched.c
--- linux-2.5.64-mm2/kernel/sched.c	2003-03-07 22:08:04.000000000 -0500
+++ linux/kernel/sched.c	2003-03-07 22:10:00.000000000 -0500
@@ -62,14 +62,15 @@
  */
 
 int min_timeslice = (10 * HZ) / 1000;
-int max_timeslice = (300 * HZ) / 1000;
-int child_penalty = 95;
+int max_timeslice = (200 * HZ) / 1000;
+int child_penalty = 50;
 int parent_penalty = 100;
 int exit_weight = 3;
 int prio_bonus_ratio = 25;
 int interactive_delta = 2;
-int max_sleep_avg = 2 * HZ;
-int starvation_limit = 2 * HZ;
+int max_sleep_avg = 10 * HZ;
+int starvation_limit = 10 * HZ;
+int node_threshold = 125;
 
 #define MIN_TIMESLICE		(min_timeslice)
 #define MAX_TIMESLICE		(max_timeslice)
@@ -80,7 +81,7 @@
 #define INTERACTIVE_DELTA	(interactive_delta)
 #define MAX_SLEEP_AVG		(max_sleep_avg)
 #define STARVATION_LIMIT	(starvation_limit)
-#define NODE_THRESHOLD		125
+#define NODE_THRESHOLD		(node_threshold)
 
 /*
  * If a task is 'interactive' then we reinsert it in the active
diff -urN linux-2.5.64-mm2/kernel/sysctl.c linux/kernel/sysctl.c
--- linux-2.5.64-mm2/kernel/sysctl.c	2003-03-07 22:08:04.000000000 -0500
+++ linux/kernel/sysctl.c	2003-03-07 22:09:19.000000000 -0500
@@ -64,6 +64,7 @@
 extern int interactive_delta;
 extern int max_sleep_avg;
 extern int starvation_limit;
+extern int node_threshold;
 
 /* this is needed for the proc_dointvec_minmax for [fs_]overflow UID and GID */
 static int maxolduid = 65535;
@@ -399,6 +400,9 @@
 	{SCHED_STARVATION_LIMIT, "starvation_limit", &starvation_limit,
 	 sizeof(int), 0644, NULL, &proc_dointvec_minmax,
 	 &sysctl_intvec, NULL, &zero, NULL},
+	{SCHED_NODE_THRESHOLD, "node_threshold", &node_threshold,
+	 sizeof(int), 0644, NULL, &proc_dointvec_minmax,
+	 &sysctl_intvec, NULL, &one, NULL},
 	{0}
 };
 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
