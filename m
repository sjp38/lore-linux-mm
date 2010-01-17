Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id CE4E16B0071
	for <linux-mm@kvack.org>; Sun, 17 Jan 2010 08:55:35 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [RFC][PATCH] PM: Force GFP_NOIO during suspend/resume (was: Re: [linux-pm] Memory allocations in .suspend became very unreliable)
Date: Sun, 17 Jan 2010 14:55:55 +0100
References: <1263549544.3112.10.camel@maxim-laptop> <201001162317.39940.rjw@sisk.pl> <201001170138.37283.rjw@sisk.pl>
In-Reply-To: <201001170138.37283.rjw@sisk.pl>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201001171455.55909.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Maxim Levitsky <maximlevitsky@gmail.com>
Cc: linux-pm@lists.linux-foundation.org, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

On Sunday 17 January 2010, Rafael J. Wysocki wrote:
> Hi,
> 
> I thing the snippet below is a good summary of what this is about.
> 
> On Saturday 16 January 2010, Rafael J. Wysocki wrote:
> > On Saturday 16 January 2010, Maxim Levitsky wrote:
> > > On Sat, 2010-01-16 at 01:57 +0100, Rafael J. Wysocki wrote: 
> > > > On Saturday 16 January 2010, Maxim Levitsky wrote:
> > > > > On Fri, 2010-01-15 at 23:03 +0100, Rafael J. Wysocki wrote: 
> > > > > > On Friday 15 January 2010, Maxim Levitsky wrote:
> > > > > > > Hi,
> > > > > > 
> > > > > > Hi,
> > > > > > 
> > > > > > > I know that this is very controversial, because here I want to describe
> > > > > > > a problem in a proprietary driver that happens now in 2.6.33-rc3
> > > > > > > I am taking about nvidia driver.
> > > > > > > 
> > > > > > > Some time ago I did very long hibernate test and found no errors after
> > > > > > > more that 200 cycles.
> > > > > > > 
> > > > > > > Now I update to 2.6.33 and notice that system will hand when nvidia
> > > > > > > driver allocates memory is their .suspend functions. 
> > > > > > 
> > > > > > They shouldn't do that, there's no guarantee that's going to work at all.
> > > > > > 
> > > > > > > This could fail in 2.6.32 if I would run many memory hungry
> > > > > > > applications, but now this happens with most of memory free.
> > > > > > 
> > > > > > This sounds a little strange.  What's the requested size of the image?
> > > > > Don't know, but system has to be very tight on memory.
> > > > 
> > > > Can you send full dmesg, please?
> > > 
> > > I deleted it, but for this case I think that hang was somewhere else.
> > > This task was hand on doing forking, which probably happened even before
> > > the freezer.
> > > 
> > > Anyway, the problem is clear. Now __get_free_pages blocks more often,
> > > and can block in .suspend even if there is plenty of memory free.
> 
> This is suspicious, but I leave it to the MM people for consideration.
> 
> > > I now patched nvidia to use GFP_ATOMIC _always_, and problem disappear.
> > > It isn't such great solution when memory is tight though....
> > > 
> > > This is going to hit hard all nvidia users...
> > 
> > Well, generally speaking, no driver should ever allocate memory using
> > GFP_KERNEL in its .suspend() routine, because that's not going to work, as you
> > can readily see.  So this is a NVidia bug, hands down.
> > 
> > Now having said that, we've been considering a change that will turn all
> > GFP_KERNEL allocations into GFP_NOIO during suspend/resume, so perhaps I'll
> > prepare a patch to do that and let's see what people think.
> 
> If I didn't confuse anything (which is likely, because it's a bit late here
> now), the patch below should do the trick.  I have only checked that it doesn't
> break compilation, so please take it with a grain of salt.

Appended is another version that attempts to remove some possible races.
It's been tested a little too.

Rafael

---
 include/linux/gfp.h      |    5 +----
 kernel/power/hibernate.c |    6 ++++++
 kernel/power/main.c      |    1 +
 kernel/power/power.h     |    3 +++
 kernel/power/suspend.c   |    2 ++
 mm/Makefile              |    1 +
 mm/internal.h            |    3 +++
 mm/page_alloc.c          |   16 +++++++++++++++-
 mm/pm.c                  |   34 ++++++++++++++++++++++++++++++++++
 9 files changed, 66 insertions(+), 5 deletions(-)

Index: linux-2.6/include/linux/gfp.h
===================================================================
--- linux-2.6.orig/include/linux/gfp.h
+++ linux-2.6/include/linux/gfp.h
@@ -337,9 +337,6 @@ void drain_local_pages(void *dummy);
 
 extern gfp_t gfp_allowed_mask;
 
-static inline void set_gfp_allowed_mask(gfp_t mask)
-{
-	gfp_allowed_mask = mask;
-}
+extern void set_gfp_allowed_mask(gfp_t mask);
 
 #endif /* __LINUX_GFP_H */
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
 
Index: linux-2.6/mm/page_alloc.c
===================================================================
--- linux-2.6.orig/mm/page_alloc.c
+++ linux-2.6/mm/page_alloc.c
@@ -76,6 +76,17 @@ unsigned long totalreserve_pages __read_
 int percpu_pagelist_fraction;
 gfp_t gfp_allowed_mask __read_mostly = GFP_BOOT_MASK;
 
+DECLARE_RWSEM(gfp_allowed_mask_sem);
+
+void set_gfp_allowed_mask(gfp_t mask)
+{
+	/* Wait for all slowpath allocations using the old mask to complete */
+	down_write(&gfp_allowed_mask_sem);
+	gfp_allowed_mask = mask;
+	up_write(&gfp_allowed_mask_sem);
+}
+
+
 #ifdef CONFIG_HUGETLB_PAGE_SIZE_VARIABLE
 int pageblock_order __read_mostly;
 #endif
@@ -1963,10 +1974,13 @@ __alloc_pages_nodemask(gfp_t gfp_mask, u
 	page = get_page_from_freelist(gfp_mask|__GFP_HARDWALL, nodemask, order,
 			zonelist, high_zoneidx, ALLOC_WMARK_LOW|ALLOC_CPUSET,
 			preferred_zone, migratetype);
-	if (unlikely(!page))
+	if (unlikely(!page)) {
+		down_read(&gfp_allowed_mask_sem);
 		page = __alloc_pages_slowpath(gfp_mask, order,
 				zonelist, high_zoneidx, nodemask,
 				preferred_zone, migratetype);
+		up_read(&gfp_allowed_mask_sem);
+	}
 
 	trace_mm_page_alloc(page, order, gfp_mask, migratetype);
 	return page;
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
@@ -0,0 +1,34 @@
+#include "internal.h"
+
+static gfp_t saved_gfp_allowed_mask;
+
+/**
+ * mm_force_noio_allocations - Modify gfp_allowed_mask to disable IO allocations
+ *
+ * Change gfp_allowed_mask by unsetting __GFP_IO and __GFP_FS in it and save the
+ * old value.
+ */
+void mm_force_noio_allocations(void)
+{
+	/* Wait for all slowpath allocations using the old mask to complete */
+	down_write(&gfp_allowed_mask_sem);
+	saved_gfp_allowed_mask = gfp_allowed_mask;
+	gfp_allowed_mask &= ~(__GFP_IO | __GFP_FS);
+	up_write(&gfp_allowed_mask_sem);
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
+	gfp_t gfp_mask = saved_gfp_allowed_mask & (__GFP_IO | __GFP_FS);
+
+	/* Wait for all slowpath allocations using the old mask to complete */
+	down_write(&gfp_allowed_mask_sem);
+	gfp_allowed_mask |= gfp_mask;
+	up_write(&gfp_allowed_mask_sem);
+}
Index: linux-2.6/mm/internal.h
===================================================================
--- linux-2.6.orig/mm/internal.h
+++ linux-2.6/mm/internal.h
@@ -12,6 +12,7 @@
 #define __MM_INTERNAL_H
 
 #include <linux/mm.h>
+#include <linux/rwsem.h>
 
 void free_pgtables(struct mmu_gather *tlb, struct vm_area_struct *start_vma,
 		unsigned long floor, unsigned long ceiling);
@@ -259,3 +260,5 @@ extern u64 hwpoison_filter_flags_mask;
 extern u64 hwpoison_filter_flags_value;
 extern u64 hwpoison_filter_memcg;
 extern u32 hwpoison_filter_enable;
+
+extern struct rw_semaphore gfp_allowed_mask_sem;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
