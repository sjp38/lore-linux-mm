Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C58DF6B0047
	for <linux-mm@kvack.org>; Sat, 16 Jan 2010 19:38:21 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Sun, 17 Jan 2010 01:38:37 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <1263678289.4276.4.camel@maxim-laptop> <201001162317.39940.rjw@sisk.pl>
In-Reply-To: <201001162317.39940.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001170138.37283.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Hi,

I thing the snippet below is a good summary of what this is about.

On Saturday 16 January 2010, Rafael J. Wysocki wrote:
> On Saturday 16 January 2010, Maxim Levitsky wrote:
> > On Sat, 2010-01-16 at 01:57 +0100, Rafael J. Wysocki wrote: 
> > > On Saturday 16 January 2010, Maxim Levitsky wrote:
> > > > On Fri, 2010-01-15 at 23:03 +0100, Rafael J. Wysocki wrote: 
> > > > > On Friday 15 January 2010, Maxim Levitsky wrote:
> > > > > > Hi,
> > > > > 
> > > > > Hi,
> > > > > 
> > > > > > I know that this is very controversial, because here I want to describe
> > > > > > a problem in a proprietary driver that happens now in 2.6.33-rc3
> > > > > > I am taking about nvidia driver.
> > > > > > 
> > > > > > Some time ago I did very long hibernate test and found no errors after
> > > > > > more that 200 cycles.
> > > > > > 
> > > > > > Now I update to 2.6.33 and notice that system will hand when nvidia
> > > > > > driver allocates memory is their .suspend functions. 
> > > > > 
> > > > > They shouldn't do that, there's no guarantee that's going to work at all.
> > > > > 
> > > > > > This could fail in 2.6.32 if I would run many memory hungry
> > > > > > applications, but now this happens with most of memory free.
> > > > > 
> > > > > This sounds a little strange.  What's the requested size of the image?
> > > > Don't know, but system has to be very tight on memory.
> > > 
> > > Can you send full dmesg, please?
> > 
> > I deleted it, but for this case I think that hang was somewhere else.
> > This task was hand on doing forking, which probably happened even before
> > the freezer.
> > 
> > Anyway, the problem is clear. Now __get_free_pages blocks more often,
> > and can block in .suspend even if there is plenty of memory free.

This is suspicious, but I leave it to the MM people for consideration.

> > I now patched nvidia to use GFP_ATOMIC _always_, and problem disappear.
> > It isn't such great solution when memory is tight though....
> > 
> > This is going to hit hard all nvidia users...
> 
> Well, generally speaking, no driver should ever allocate memory using
> GFP_KERNEL in its .suspend() routine, because that's not going to work, as you
> can readily see.  So this is a NVidia bug, hands down.
> 
> Now having said that, we've been considering a change that will turn all
> GFP_KERNEL allocations into GFP_NOIO during suspend/resume, so perhaps I'll
> prepare a patch to do that and let's see what people think.

If I didn't confuse anything (which is likely, because it's a bit late here
now), the patch below should do the trick.  I have only checked that it doesn't
break compilation, so please take it with a grain of salt.

Comments welcome.

Rafael

---
 include/linux/gfp.h      |    5 +++++
 kernel/power/hibernate.c |    6 ++++++
 kernel/power/main.c      |   30 ++++++++++++++++++++++++++++++
 kernel/power/power.h     |    2 ++
 kernel/power/suspend.c   |    2 ++
 5 files changed, 45 insertions(+)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h
+++ linux-2.6/include/linux/gfp.h
@@ -342,4 +342,9 @@ static inline void set_gfp_allowed_mask(
 	gfp_allowed_mask = mask;
 }
 
+static inline gfp_t get_gfp_allowed_mask(void)
+{
+	return gfp_allowed_mask;
+}
+
 #endif /* __LINUX_GFP_H */
Index: linux-2.6/kernel/power/hibernate.c
===================================================================
--- linux-2.6.orig/kernel/power/hibernate.c
+++ linux-2.6/kernel/power/hibernate.c
@@ -334,6 +334,7 @@ int hibernation_snapshot(int platform_mo
 		goto Close;
 
 	suspend_console();
+	pm_force_noio_allocations();
 	error = dpm_suspend_start(PMSG_FREEZE);
 	if (error)
 		goto Recover_platform;
@@ -351,6 +352,7 @@ int hibernation_snapshot(int platform_mo
 
 	dpm_resume_end(in_suspend ?
 		(error ? PMSG_RECOVER : PMSG_THAW) : PMSG_RESTORE);
+	pm_allow_io_allocations();
 	resume_console();
  Close:
 	platform_end(platform_mode);
@@ -448,11 +450,13 @@ int hibernation_restore(int platform_mod
 
 	pm_prepare_console();
 	suspend_console();
+	pm_force_noio_allocations();
 	error = dpm_suspend_start(PMSG_QUIESCE);
 	if (!error) {
 		error = resume_target_kernel(platform_mode);
 		dpm_resume_end(PMSG_RECOVER);
 	}
+	pm_allow_io_allocations();
 	resume_console();
 	pm_restore_console();
 	return error;
@@ -481,6 +485,7 @@ int hibernation_platform_enter(void)
 
 	entering_platform_hibernation = true;
 	suspend_console();
+	pm_force_noio_allocations();
 	error = dpm_suspend_start(PMSG_HIBERNATE);
 	if (error) {
 		if (hibernation_ops->recover)
@@ -518,6 +523,7 @@ int hibernation_platform_enter(void)
  Resume_devices:
 	entering_platform_hibernation = false;
 	dpm_resume_end(PMSG_RESTORE);
+	pm_allow_io_allocations();
 	resume_console();
 
  Close:
Index: linux-2.6/kernel/power/power.h
===================================================================
--- linux-2.6.orig/kernel/power/power.h
+++ linux-2.6/kernel/power/power.h
@@ -187,6 +187,8 @@ static inline void suspend_test_finish(c
 #ifdef CONFIG_PM_SLEEP
 /* kernel/power/main.c */
 extern int pm_notifier_call_chain(unsigned long val);
+extern void pm_force_noio_allocations(void);
+extern void pm_allow_io_allocations(void);
 #endif
 
 #ifdef CONFIG_HIGHMEM
Index: linux-2.6/kernel/power/suspend.c
===================================================================
--- linux-2.6.orig/kernel/power/suspend.c
+++ linux-2.6/kernel/power/suspend.c
@@ -208,6 +208,7 @@ int suspend_devices_and_enter(suspend_st
 			goto Close;
 	}
 	suspend_console();
+	pm_force_noio_allocations();
 	suspend_test_start();
 	error = dpm_suspend_start(PMSG_SUSPEND);
 	if (error) {
@@ -224,6 +225,7 @@ int suspend_devices_and_enter(suspend_st
 	suspend_test_start();
 	dpm_resume_end(PMSG_RESUME);
 	suspend_test_finish("resume devices");
+	pm_allow_io_allocations();
 	resume_console();
  Close:
 	if (suspend_ops->end)
Index: linux-2.6/kernel/power/main.c
===================================================================
--- linux-2.6.orig/kernel/power/main.c
+++ linux-2.6/kernel/power/main.c
@@ -12,6 +12,7 @@
 #include <linux/string.h>
 #include <linux/resume-trace.h>
 #include <linux/workqueue.h>
+#include <linux/gfp.h>
 
 #include "power.h"
 
@@ -22,6 +23,35 @@ EXPORT_SYMBOL(pm_flags);
 
 #ifdef CONFIG_PM_SLEEP
 
+static gfp_t saved_gfp_allowed_mask;
+
+/**
+ * pm_force_noio_allocations - Modify gfp_allowed_mask to disable IO allocations
+ *
+ * Change gfp_allowed_mask by unsetting __GFP_IO and __GFP_FS in it and save the
+ * old value.
+ */
+void pm_force_noio_allocations(void)
+{
+	saved_gfp_allowed_mask = get_gfp_allowed_mask();
+	set_gfp_allowed_mask(saved_gfp_allowed_mask & ~(__GFP_IO | __GFP_FS));
+}
+
+/**
+ * pm_allow_io_allocations - Modify gfp_allowed_mask to allow IO allocations
+ *
+ * If the saved value of gfp_allowed_mask has __GFP_IO set, modify the current
+ * gfp_allowed_mask by setting this bit and anlogously for __GFP_FS.
+ */
+void pm_allow_io_allocations(void)
+{
+	gfp_t gfp_mask;
+
+	gfp_mask = get_gfp_allowed_mask();
+	gfp_mask |= saved_gfp_allowed_mask & (__GFP_IO | __GFP_FS);
+	set_gfp_allowed_mask(gfp_mask);
+}
+
 /* Routines for PM-transition notifications */
 
 static BLOCKING_NOTIFIER_HEAD(pm_chain_head);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
