Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 16EE56B0036
	for <linux-mm@kvack.org>; Thu, 29 Aug 2013 17:08:10 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: [PATCH 2/3] PM / hibernate: Create memory bitmaps after freezing user space
Date: Thu, 29 Aug 2013 23:17:48 +0200
Message-ID: <10303295.iNF2gTh50Q@vostro.rjw.lan>
In-Reply-To: <9589253.Co8jZpnWdd@vostro.rjw.lan>
References: <9589253.Co8jZpnWdd@vostro.rjw.lan>
MIME-Version: 1.0
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="utf-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: ACPI Devel Maling List <linux-acpi@vger.kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org

From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

The hibernation core uses special memory bitmaps during image
creation and restoration and traditionally those bitmaps are
allocated before freezing tasks, because in the past GFP_KERNEL
allocations might not work after all tasks had been frozen.

However, this is an anachronism, because hibernation_snapshot()
now calls hibernate_preallocate_memory() which allocates memory
for the image upfront anyway, so the memory bitmaps may be
allocated after freezing user space safely.

For this reason, move all of the create_basic_memory_bitmaps()
calls after freeze_processes() and all of the corresponding
free_basic_memory_bitmaps() calls before thaw_processes().

This will allow us to hold device_hotplug_lock around hibernation
without the need to worry about freezing issues with user space
processes attempting to acquire it via sysfs attributes after the
creation of memory bitmaps and before the freezing of tasks.

Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
---
 kernel/power/hibernate.c |   41 +++++++++++++++++++----------------------
 kernel/power/user.c      |   22 ++++++++++++----------
 2 files changed, 31 insertions(+), 32 deletions(-)

Index: linux-pm/kernel/power/hibernate.c
===================================================================
--- linux-pm.orig/kernel/power/hibernate.c
+++ linux-pm/kernel/power/hibernate.c
@@ -644,22 +644,22 @@ int hibernate(void)
 	if (error)
 		goto Exit;
 
-	/* Allocate memory management structures */
-	error = create_basic_memory_bitmaps();
-	if (error)
-		goto Exit;
-
 	printk(KERN_INFO "PM: Syncing filesystems ... ");
 	sys_sync();
 	printk("done.\n");
 
 	error = freeze_processes();
 	if (error)
-		goto Free_bitmaps;
+		goto Exit;
+
+	/* Allocate memory management structures */
+	error = create_basic_memory_bitmaps();
+	if (error)
+		goto Thaw;
 
 	error = hibernation_snapshot(hibernation_mode == HIBERNATION_PLATFORM);
 	if (error || freezer_test_done)
-		goto Thaw;
+		goto Free_bitmaps;
 
 	if (in_suspend) {
 		unsigned int flags = 0;
@@ -682,14 +682,13 @@ int hibernate(void)
 		pr_debug("PM: Image restored successfully.\n");
 	}
 
+ Free_bitmaps:
+	free_basic_memory_bitmaps();
  Thaw:
 	thaw_processes();
 
 	/* Don't bother checking whether freezer_test_done is true */
 	freezer_test_done = false;
-
- Free_bitmaps:
-	free_basic_memory_bitmaps();
  Exit:
 	pm_notifier_call_chain(PM_POST_HIBERNATION);
 	pm_restore_console();
@@ -806,21 +805,19 @@ static int software_resume(void)
 	pm_prepare_console();
 	error = pm_notifier_call_chain(PM_RESTORE_PREPARE);
 	if (error)
-		goto close_finish;
-
-	error = create_basic_memory_bitmaps();
-	if (error)
-		goto close_finish;
+		goto Close_Finish;
 
 	pr_debug("PM: Preparing processes for restore.\n");
 	error = freeze_processes();
-	if (error) {
-		swsusp_close(FMODE_READ);
-		goto Done;
-	}
+	if (error)
+		goto Close_Finish;
 
 	pr_debug("PM: Loading hibernation image.\n");
 
+	error = create_basic_memory_bitmaps();
+	if (error)
+		goto Thaw;
+
 	error = swsusp_read(&flags);
 	swsusp_close(FMODE_READ);
 	if (!error)
@@ -828,9 +825,9 @@ static int software_resume(void)
 
 	printk(KERN_ERR "PM: Failed to load hibernation image, recovering.\n");
 	swsusp_free();
-	thaw_processes();
- Done:
 	free_basic_memory_bitmaps();
+ Thaw:
+	thaw_processes();
  Finish:
 	pm_notifier_call_chain(PM_POST_RESTORE);
 	pm_restore_console();
@@ -840,7 +837,7 @@ static int software_resume(void)
 	mutex_unlock(&pm_mutex);
 	pr_debug("PM: Hibernation image not present or could not be loaded.\n");
 	return error;
-close_finish:
+ Close_Finish:
 	swsusp_close(FMODE_READ);
 	goto Finish;
 }
Index: linux-pm/kernel/power/user.c
===================================================================
--- linux-pm.orig/kernel/power/user.c
+++ linux-pm/kernel/power/user.c
@@ -60,11 +60,6 @@ static int snapshot_open(struct inode *i
 		error = -ENOSYS;
 		goto Unlock;
 	}
-	if(create_basic_memory_bitmaps()) {
-		atomic_inc(&snapshot_device_available);
-		error = -ENOMEM;
-		goto Unlock;
-	}
 	nonseekable_open(inode, filp);
 	data = &snapshot_state;
 	filp->private_data = data;
@@ -90,10 +85,9 @@ static int snapshot_open(struct inode *i
 		if (error)
 			pm_notifier_call_chain(PM_POST_RESTORE);
 	}
-	if (error) {
-		free_basic_memory_bitmaps();
+	if (error)
 		atomic_inc(&snapshot_device_available);
-	}
+
 	data->frozen = 0;
 	data->ready = 0;
 	data->platform_support = 0;
@@ -111,11 +105,11 @@ static int snapshot_release(struct inode
 	lock_system_sleep();
 
 	swsusp_free();
-	free_basic_memory_bitmaps();
 	data = filp->private_data;
 	free_all_swap_pages(data->swap);
 	if (data->frozen) {
 		pm_restore_gfp_mask();
+		free_basic_memory_bitmaps();
 		thaw_processes();
 	}
 	pm_notifier_call_chain(data->mode == O_RDONLY ?
@@ -220,14 +214,22 @@ static long snapshot_ioctl(struct file *
 		printk("done.\n");
 
 		error = freeze_processes();
-		if (!error)
+		if (error)
+			break;
+
+		error = create_basic_memory_bitmaps();
+		if (error)
+			thaw_processes();
+		else
 			data->frozen = 1;
+
 		break;
 
 	case SNAPSHOT_UNFREEZE:
 		if (!data->frozen || data->ready)
 			break;
 		pm_restore_gfp_mask();
+		free_basic_memory_bitmaps();
 		thaw_processes();
 		data->frozen = 0;
 		break;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
