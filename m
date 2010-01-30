Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id F3B526B0047
	for <linux-mm@kvack.org>; Sat, 30 Jan 2010 13:46:35 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Sat, 30 Jan 2010 19:47:10 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001170138.37283.rjw@sisk.pl> <1264866419.27933.0.camel@maxim-laptop>
In-Reply-To: <1264866419.27933.0.camel@maxim-laptop>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <201001301947.10453.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Maxim Levitsky <maximlevitsky@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Saturday 30 January 2010, Maxim Levitsky wrote:
> On Sun, 2010-01-17 at 01:38 +0100, Rafael J. Wysocki wrote: 
> > Hi,
> > 
> > I thing the snippet below is a good summary of what this is about.
> 
> Any progress on that?

Well, I'm waiting for you to report back:
http://patchwork.kernel.org/patch/74740/

The patch is appended once again for convenience.

Rafael

---
From: Rafael J. Wysocki <rjw@sisk.pl>
Subject: MM / PM: Force GFP_NOIO during suspend/hibernation and resume

There are quite a few GFP_KERNEL memory allocations made during
suspend/hibernation and resume that may cause the system to hang,
because the I/O operations they depend on cannot be completed due to
the underlying devices being suspended.

Avoid this problem by clearing the __GFP_IO and __GFP_FS bits in
gfp_allowed_mask before suspend/hibernation and restoring the
original values of these bits in gfp_allowed_mask durig the
subsequent resume.

Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>
Reported-by: Maxim Levitsky <maximlevitsky@gmail.com>
---
 kernel/power/hibernate.c |    6 ++++++
 kernel/power/power.h     |    3 +++
 kernel/power/suspend.c   |    2 ++
 mm/Makefile              |    1 +
 mm/pm.c                  |   28 ++++++++++++++++++++++++++++
 5 files changed, 40 insertions(+)

Index: linux-2.6/kernel/power/hibernate.c
===================================================================
--- linux-2.6.orig/kernel/power/hibernate.c
+++ linux-2.6/kernel/power/hibernate.c
@@ -334,6 +334,7 @@ int hibernation_snapshot(int platform_mo
 		goto Close;
 
 	suspend_console();
+	mm_force_noio_allocations();
 	error = dpm_suspend_start(PMSG_FREEZE);
 	if (error)
 		goto Recover_platform;
@@ -351,6 +352,7 @@ int hibernation_snapshot(int platform_mo
 
 	dpm_resume_end(in_suspend ?
 		(error ? PMSG_RECOVER : PMSG_THAW) : PMSG_RESTORE);
+	mm_allow_io_allocations();
 	resume_console();
  Close:
 	platform_end(platform_mode);
@@ -448,11 +450,13 @@ int hibernation_restore(int platform_mod
 
 	pm_prepare_console();
 	suspend_console();
+	mm_force_noio_allocations();
 	error = dpm_suspend_start(PMSG_QUIESCE);
 	if (!error) {
 		error = resume_target_kernel(platform_mode);
 		dpm_resume_end(PMSG_RECOVER);
 	}
+	mm_allow_io_allocations();
 	resume_console();
 	pm_restore_console();
 	return error;
@@ -481,6 +485,7 @@ int hibernation_platform_enter(void)
 
 	entering_platform_hibernation = true;
 	suspend_console();
+	mm_force_noio_allocations();
 	error = dpm_suspend_start(PMSG_HIBERNATE);
 	if (error) {
 		if (hibernation_ops->recover)
@@ -518,6 +523,7 @@ int hibernation_platform_enter(void)
  Resume_devices:
 	entering_platform_hibernation = false;
 	dpm_resume_end(PMSG_RESTORE);
+	mm_allow_io_allocations();
 	resume_console();
 
  Close:
Index: linux-2.6/kernel/power/power.h
===================================================================
--- linux-2.6.orig/kernel/power/power.h
+++ linux-2.6/kernel/power/power.h
@@ -187,6 +187,9 @@ static inline void suspend_test_finish(c
 #ifdef CONFIG_PM_SLEEP
 /* kernel/power/main.c */
 extern int pm_notifier_call_chain(unsigned long val);
+/* mm/pm.c */
+extern void mm_force_noio_allocations(void);
+extern void mm_allow_io_allocations(void);
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
+	mm_force_noio_allocations();
 	suspend_test_start();
 	error = dpm_suspend_start(PMSG_SUSPEND);
 	if (error) {
@@ -224,6 +225,7 @@ int suspend_devices_and_enter(suspend_st
 	suspend_test_start();
 	dpm_resume_end(PMSG_RESUME);
 	suspend_test_finish("resume devices");
+	mm_allow_io_allocations();
 	resume_console();
  Close:
 	if (suspend_ops->end)
Index: linux-2.6/mm/Makefile
===================================================================
--- linux-2.6.orig/mm/Makefile
+++ linux-2.6/mm/Makefile
@@ -40,3 +40,4 @@ obj-$(CONFIG_MEMORY_FAILURE) += memory-f
 obj-$(CONFIG_HWPOISON_INJECT) += hwpoison-inject.o
 obj-$(CONFIG_DEBUG_KMEMLEAK) += kmemleak.o
 obj-$(CONFIG_DEBUG_KMEMLEAK_TEST) += kmemleak-test.o
+obj-$(CONFIG_PM_SLEEP) += pm.o
Index: linux-2.6/mm/pm.c
===================================================================
--- /dev/null
+++ linux-2.6/mm/pm.c
@@ -0,0 +1,28 @@
+#include <linux/gfp.h>
+
+static gfp_t saved_gfp_allowed_mask;
+
+#define GFP_IOFS (__GFP_IO | __GFP_FS)
+
+/**
+ * mm_force_noio_allocations - Modify gfp_allowed_mask to disable IO allocations
+ *
+ * Change gfp_allowed_mask by unsetting __GFP_IO and __GFP_FS in it and save the
+ * old value.
+ */
+void mm_force_noio_allocations(void)
+{
+	saved_gfp_allowed_mask = gfp_allowed_mask;
+	gfp_allowed_mask &= ~GFP_IOFS;
+}
+
+/**
+ * mm_allow_io_allocations - Modify gfp_allowed_mask to allow IO allocations
+ *
+ * If the saved value of gfp_allowed_mask has __GFP_IO set, modify the current
+ * gfp_allowed_mask by setting this bit and anlogously for __GFP_FS.
+ */
+void mm_allow_io_allocations(void)
+{
+	gfp_allowed_mask |= saved_gfp_allowed_mask & GFP_IOFS;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
