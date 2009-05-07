Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 0C57C6B003D
	for <linux-mm@kvack.org>; Thu,  7 May 2009 18:25:21 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH] PM/Freezer: Disable OOM killer when tasks are frozen (was: Re: [RFC][PATCH 1/5] mm: Introduce __GFP_NO_OOM_KILL)
Date: Fri, 8 May 2009 00:24:24 +0200
References: <200905070040.08561.rjw@sisk.pl> <200905072348.59856.rjw@sisk.pl> <200905072350.07105.rjw@sisk.pl>
In-Reply-To: <200905072350.07105.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200905080024.25039.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: pm list <linux-pm@lists.linux-foundation.org>
Cc: Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Pavel Machek <pavel@ucw.cz>, Nigel Cunningham <nigel@tuxonice.net>, David Rientjes <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 07 May 2009, Rafael J. Wysocki wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> > > Remind me: why can't we just allocate N pages at suspend-time?
> > 
> > We need half of memory free. The reason we can't "just allocate" is
> > probably OOM killer; but my memories are quite weak :-(.
> 
> hm.  You'd think that with our splendid range of __GFP_foo falgs, there
> would be some combo which would suit this requirement but I can't
> immediately spot one.
> 
> We can always add another I guess.  Something like...
> 
> [rjw: fixed white space, added comment in page_alloc.c]
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

An alternative to this one is the appended patch.

The idea here is that after freezing the user space totally, there's no point
in letting the OOM killer run, because that won't result in any memory being
freed anyway until the tasks are thawed.

Thanks,
Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: PM/Freezer: Disable OOM killer when tasks are frozen

The OOM killer is not really going to work while tasks are frozen, so
we can just give up calling it in that case.

This will allow us to safely use memory allocations for decreasing
the number of saveable pages in the hibernation core code instead of
using any artificial memory shriking mechanisms for this purpose.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
---
 include/linux/freezer.h |    2 ++
 kernel/power/process.c  |   16 ++++++++++++++++
 mm/page_alloc.c         |    5 +++++
 3 files changed, 23 insertions(+)

Index: linux-2.6/kernel/power/process.c
===================================================================
--- linux-2.6.orig/kernel/power/process.c
+++ linux-2.6/kernel/power/process.c
@@ -19,6 +19,12 @@
  */
 #define TIMEOUT	(20 * HZ)
 
+/*
+ * Set after freeze_processes() has successfully run and reset at the beginning
+ * of thaw_processes().
+ */
+static bool all_tasks_frozen;
+
 static inline int freezeable(struct task_struct * p)
 {
 	if ((p == current) ||
@@ -120,6 +126,10 @@ int freeze_processes(void)
  Exit:
 	BUG_ON(in_atomic());
 	printk("\n");
+
+	if (!error)
+		all_tasks_frozen = true;
+
 	return error;
 }
 
@@ -145,6 +155,8 @@ static void thaw_tasks(bool nosig_only)
 
 void thaw_processes(void)
 {
+	all_tasks_frozen = false;
+
 	printk("Restarting tasks ... ");
 	thaw_tasks(true);
 	thaw_tasks(false);
@@ -152,3 +164,7 @@ void thaw_processes(void)
 	printk("done.\n");
 }
 
+bool killable_tasks_are_frozen(void)
+{
+	return all_tasks_frozen;
+}
Index: linux-2.6/include/linux/freezer.h
===================================================================
--- linux-2.6.orig/include/linux/freezer.h
+++ linux-2.6/include/linux/freezer.h
@@ -50,6 +50,7 @@ extern int thaw_process(struct task_stru
 extern void refrigerator(void);
 extern int freeze_processes(void);
 extern void thaw_processes(void);
+extern bool killable_tasks_are_frozen(void);
 
 static inline int try_to_freeze(void)
 {
@@ -170,6 +171,7 @@ static inline int thaw_process(struct ta
 static inline void refrigerator(void) {}
 static inline int freeze_processes(void) { BUG(); return 0; }
 static inline void thaw_processes(void) {}
+static inline bool killable_tasks_are_frozen(void) { return false; }
 
 static inline int try_to_freeze(void) { return 0; }
 
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -46,6 +46,7 @@
 #include <linux/page-isolation.h>
 #include <linux/page_cgroup.h>
 #include <linux/debugobjects.h>
+#include <linux/freezer.h>
 
 #include <asm/tlbflush.h>
 #include <asm/div64.h>
@@ -1600,6 +1601,10 @@ nofail_alloc:
 		if (page)
 			goto got_pg;
 	} else if ((gfp_mask & __GFP_FS) && !(gfp_mask & __GFP_NORETRY)) {
+		/* The OOM killer won't work if processes are frozen. */
+		if (killable_tasks_are_frozen())
+			goto nopage;
+
 		if (!try_set_zone_oom(zonelist, gfp_mask)) {
 			schedule_timeout_uninterruptible(1);
 			goto restart;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
