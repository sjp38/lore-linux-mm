Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id D96C06B0007
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 04:51:51 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id t26-v6so4461361pfh.0
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 01:51:51 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id q64-v6sor3247036pga.290.2018.07.31.01.51.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 31 Jul 2018 01:51:50 -0700 (PDT)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2] pm/reboot: eliminate race between reboot and suspend
Date: Tue, 31 Jul 2018 16:51:32 +0800
Message-Id: <1533027092-15085-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-pm@vger.kernel.org
Cc: Pingfan Liu <kernelfans@gmail.com>, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

At present, "systemctl suspend" and "shutdown" can run in parrallel. A
system can suspend after devices_shutdown(), and resume. Then the shutdown
task goes on to power off. This causes many devices are not really shut
off. Hence replacing reboot_mutex with system_transition_mutex (renamed
from pm_mutex) to achieve the exclusion. The renaming of pm_mutex as
system_transition_mutex can be better to reflect the purpose of the mutex.

Cc: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Cc: Len Brown <len.brown@intel.com>
Cc: Pavel Machek <pavel@ucw.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
---
v1 -> v2:
 rename pm_mutex as system_transition_mutex

 Documentation/power/freezing-of-tasks.txt      | 12 ++++++------
 Documentation/power/suspend-and-cpuhotplug.txt |  6 +++---
 include/linux/suspend.h                        |  2 +-
 kernel/freezer.c                               |  4 +++-
 kernel/power/hibernate.c                       | 15 ++++++++-------
 kernel/power/main.c                            | 12 ++++++------
 kernel/power/suspend.c                         |  4 ++--
 kernel/power/user.c                            |  4 ++--
 kernel/reboot.c                                |  6 +++---
 mm/page_alloc.c                                | 11 ++++++-----
 10 files changed, 40 insertions(+), 36 deletions(-)

diff --git a/Documentation/power/freezing-of-tasks.txt b/Documentation/power/freezing-of-tasks.txt
index af00577..cd28319 100644
--- a/Documentation/power/freezing-of-tasks.txt
+++ b/Documentation/power/freezing-of-tasks.txt
@@ -204,26 +204,26 @@ VI. Are there any precautions to be taken to prevent freezing failures?
 
 Yes, there are.
 
-First of all, grabbing the 'pm_mutex' lock to mutually exclude a piece of code
+First of all, grabbing the 'system_transition_mutex' lock to mutually exclude a piece of code
 from system-wide sleep such as suspend/hibernation is not encouraged.
 If possible, that piece of code must instead hook onto the suspend/hibernation
 notifiers to achieve mutual exclusion. Look at the CPU-Hotplug code
 (kernel/cpu.c) for an example.
 
-However, if that is not feasible, and grabbing 'pm_mutex' is deemed necessary,
-it is strongly discouraged to directly call mutex_[un]lock(&pm_mutex) since
+However, if that is not feasible, and grabbing 'system_transition_mutex' is deemed necessary,
+it is strongly discouraged to directly call mutex_[un]lock(&system_transition_mutex) since
 that could lead to freezing failures, because if the suspend/hibernate code
-successfully acquired the 'pm_mutex' lock, and hence that other entity failed
+successfully acquired the 'system_transition_mutex' lock, and hence that other entity failed
 to acquire the lock, then that task would get blocked in TASK_UNINTERRUPTIBLE
 state. As a consequence, the freezer would not be able to freeze that task,
 leading to freezing failure.
 
 However, the [un]lock_system_sleep() APIs are safe to use in this scenario,
 since they ask the freezer to skip freezing this task, since it is anyway
-"frozen enough" as it is blocked on 'pm_mutex', which will be released
+"frozen enough" as it is blocked on 'system_transition_mutex', which will be released
 only after the entire suspend/hibernation sequence is complete.
 So, to summarize, use [un]lock_system_sleep() instead of directly using
-mutex_[un]lock(&pm_mutex). That would prevent freezing failures.
+mutex_[un]lock(&system_transition_mutex). That would prevent freezing failures.
 
 V. Miscellaneous
 /sys/power/pm_freeze_timeout controls how long it will cost at most to freeze
diff --git a/Documentation/power/suspend-and-cpuhotplug.txt b/Documentation/power/suspend-and-cpuhotplug.txt
index 6f55eb9..a8751b8 100644
--- a/Documentation/power/suspend-and-cpuhotplug.txt
+++ b/Documentation/power/suspend-and-cpuhotplug.txt
@@ -32,7 +32,7 @@ More details follow:
                                     sysfs file
                                         |
                                         v
-                               Acquire pm_mutex lock
+                               Acquire system_transition_mutex lock
                                         |
                                         v
                              Send PM_SUSPEND_PREPARE
@@ -96,10 +96,10 @@ execution during resume):
 
 * thaw tasks
 * send PM_POST_SUSPEND notifications
-* Release pm_mutex lock.
+* Release system_transition_mutex lock.
 
 
-It is to be noted here that the pm_mutex lock is acquired at the very
+It is to be noted here that the system_transition_mutex lock is acquired at the very
 beginning, when we are just starting out to suspend, and then released only
 after the entire cycle is complete (i.e., suspend + resume).
 
diff --git a/include/linux/suspend.h b/include/linux/suspend.h
index 440b62f..5a28ac9 100644
--- a/include/linux/suspend.h
+++ b/include/linux/suspend.h
@@ -414,7 +414,7 @@ static inline bool hibernation_available(void) { return false; }
 #define PM_RESTORE_PREPARE	0x0005 /* Going to restore a saved image */
 #define PM_POST_RESTORE		0x0006 /* Restore failed */
 
-extern struct mutex pm_mutex;
+extern struct mutex system_transition_mutex;
 
 #ifdef CONFIG_PM_SLEEP
 void save_processor_state(void);
diff --git a/kernel/freezer.c b/kernel/freezer.c
index 6f56a9e..b162b74 100644
--- a/kernel/freezer.c
+++ b/kernel/freezer.c
@@ -15,7 +15,9 @@
 atomic_t system_freezing_cnt = ATOMIC_INIT(0);
 EXPORT_SYMBOL(system_freezing_cnt);
 
-/* indicate whether PM freezing is in effect, protected by pm_mutex */
+/* indicate whether PM freezing is in effect, protected by
+ * system_transition_mutex
+ */
 bool pm_freezing;
 bool pm_nosig_freezing;
 
diff --git a/kernel/power/hibernate.c b/kernel/power/hibernate.c
index 9c85c78..7a4979e 100644
--- a/kernel/power/hibernate.c
+++ b/kernel/power/hibernate.c
@@ -338,7 +338,7 @@ static int create_image(int platform_mode)
  * hibernation_snapshot - Quiesce devices and create a hibernation image.
  * @platform_mode: If set, use platform driver to prepare for the transition.
  *
- * This routine must be called with pm_mutex held.
+ * This routine must be called with system_transition_mutex held.
  */
 int hibernation_snapshot(int platform_mode)
 {
@@ -500,8 +500,9 @@ static int resume_target_kernel(bool platform_mode)
  * hibernation_restore - Quiesce devices and restore from a hibernation image.
  * @platform_mode: If set, use platform driver to prepare for the transition.
  *
- * This routine must be called with pm_mutex held.  If it is successful, control
- * reappears in the restored target kernel in hibernation_snapshot().
+ * This routine must be called with system_transition_mutex held.  If it is
+ * successful, control reappears in the restored target kernel in
+ * hibernation_snapshot().
  */
 int hibernation_restore(int platform_mode)
 {
@@ -805,13 +806,13 @@ static int software_resume(void)
 	 * name_to_dev_t() below takes a sysfs buffer mutex when sysfs
 	 * is configured into the kernel. Since the regular hibernate
 	 * trigger path is via sysfs which takes a buffer mutex before
-	 * calling hibernate functions (which take pm_mutex) this can
-	 * cause lockdep to complain about a possible ABBA deadlock
+	 * calling hibernate functions (which take system_transition_mutex)
+	 * this can cause lockdep to complain about a possible ABBA deadlock
 	 * which cannot happen since we're in the boot code here and
 	 * sysfs can't be invoked yet. Therefore, we use a subclass
 	 * here to avoid lockdep complaining.
 	 */
-	mutex_lock_nested(&pm_mutex, SINGLE_DEPTH_NESTING);
+	mutex_lock_nested(&system_transition_mutex, SINGLE_DEPTH_NESTING);
 
 	if (swsusp_resume_device)
 		goto Check_image;
@@ -899,7 +900,7 @@ static int software_resume(void)
 	atomic_inc(&snapshot_device_available);
 	/* For success case, the suspend path will release the lock */
  Unlock:
-	mutex_unlock(&pm_mutex);
+	mutex_unlock(&system_transition_mutex);
 	pm_pr_dbg("Hibernation image not present or could not be loaded.\n");
 	return error;
  Close_Finish:
diff --git a/kernel/power/main.c b/kernel/power/main.c
index d9706da..35b5082 100644
--- a/kernel/power/main.c
+++ b/kernel/power/main.c
@@ -15,17 +15,16 @@
 #include <linux/workqueue.h>
 #include <linux/debugfs.h>
 #include <linux/seq_file.h>
+#include <linux/suspend.h>
 
 #include "power.h"
 
-DEFINE_MUTEX(pm_mutex);
-
 #ifdef CONFIG_PM_SLEEP
 
 void lock_system_sleep(void)
 {
 	current->flags |= PF_FREEZER_SKIP;
-	mutex_lock(&pm_mutex);
+	mutex_lock(&system_transition_mutex);
 }
 EXPORT_SYMBOL_GPL(lock_system_sleep);
 
@@ -37,8 +36,9 @@ void unlock_system_sleep(void)
 	 *
 	 * Reason:
 	 * Fundamentally, we just don't need it, because freezing condition
-	 * doesn't come into effect until we release the pm_mutex lock,
-	 * since the freezer always works with pm_mutex held.
+	 * doesn't come into effect until we release the
+	 * system_transition_mutex lock, since the freezer always works with
+	 * system_transition_mutex held.
 	 *
 	 * More importantly, in the case of hibernation,
 	 * unlock_system_sleep() gets called in snapshot_read() and
@@ -47,7 +47,7 @@ void unlock_system_sleep(void)
 	 * enter the refrigerator, thus causing hibernation to lockup.
 	 */
 	current->flags &= ~PF_FREEZER_SKIP;
-	mutex_unlock(&pm_mutex);
+	mutex_unlock(&system_transition_mutex);
 }
 EXPORT_SYMBOL_GPL(unlock_system_sleep);
 
diff --git a/kernel/power/suspend.c b/kernel/power/suspend.c
index 8733156..9e13afe 100644
--- a/kernel/power/suspend.c
+++ b/kernel/power/suspend.c
@@ -556,7 +556,7 @@ static int enter_state(suspend_state_t state)
 	} else if (!valid_state(state)) {
 		return -EINVAL;
 	}
-	if (!mutex_trylock(&pm_mutex))
+	if (!mutex_trylock(&system_transition_mutex))
 		return -EBUSY;
 
 	if (state == PM_SUSPEND_TO_IDLE)
@@ -590,7 +590,7 @@ static int enter_state(suspend_state_t state)
 	pm_pr_dbg("Finishing wakeup.\n");
 	suspend_finish();
  Unlock:
-	mutex_unlock(&pm_mutex);
+	mutex_unlock(&system_transition_mutex);
 	return error;
 }
 
diff --git a/kernel/power/user.c b/kernel/power/user.c
index abd2255..2d8b60a 100644
--- a/kernel/power/user.c
+++ b/kernel/power/user.c
@@ -216,7 +216,7 @@ static long snapshot_ioctl(struct file *filp, unsigned int cmd,
 	if (!capable(CAP_SYS_ADMIN))
 		return -EPERM;
 
-	if (!mutex_trylock(&pm_mutex))
+	if (!mutex_trylock(&system_transition_mutex))
 		return -EBUSY;
 
 	lock_device_hotplug();
@@ -394,7 +394,7 @@ static long snapshot_ioctl(struct file *filp, unsigned int cmd,
 	}
 
 	unlock_device_hotplug();
-	mutex_unlock(&pm_mutex);
+	mutex_unlock(&system_transition_mutex);
 
 	return error;
 }
diff --git a/kernel/reboot.c b/kernel/reboot.c
index e4ced88..8fb44de 100644
--- a/kernel/reboot.c
+++ b/kernel/reboot.c
@@ -294,7 +294,7 @@ void kernel_power_off(void)
 }
 EXPORT_SYMBOL_GPL(kernel_power_off);
 
-static DEFINE_MUTEX(reboot_mutex);
+DEFINE_MUTEX(system_transition_mutex);
 
 /*
  * Reboot system call: for obvious reasons only root may call it,
@@ -338,7 +338,7 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
 	if ((cmd == LINUX_REBOOT_CMD_POWER_OFF) && !pm_power_off)
 		cmd = LINUX_REBOOT_CMD_HALT;
 
-	mutex_lock(&reboot_mutex);
+	mutex_lock(&system_transition_mutex);
 	switch (cmd) {
 	case LINUX_REBOOT_CMD_RESTART:
 		kernel_restart(NULL);
@@ -389,7 +389,7 @@ SYSCALL_DEFINE4(reboot, int, magic1, int, magic2, unsigned int, cmd,
 		ret = -EINVAL;
 		break;
 	}
-	mutex_unlock(&reboot_mutex);
+	mutex_unlock(&system_transition_mutex);
 	return ret;
 }
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a790ef4..3674e42 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -155,16 +155,17 @@ static inline void set_pcppage_migratetype(struct page *page, int migratetype)
  * The following functions are used by the suspend/hibernate code to temporarily
  * change gfp_allowed_mask in order to avoid using I/O during memory allocations
  * while devices are suspended.  To avoid races with the suspend/hibernate code,
- * they should always be called with pm_mutex held (gfp_allowed_mask also should
- * only be modified with pm_mutex held, unless the suspend/hibernate code is
- * guaranteed not to run in parallel with that modification).
+ * they should always be called with system_transition_mutex held
+ * (gfp_allowed_mask also should only be modified with system_transition_mutex
+ * held, unless the suspend/hibernate code is guaranteed not to run in parallel
+ * with that modification).
  */
 
 static gfp_t saved_gfp_mask;
 
 void pm_restore_gfp_mask(void)
 {
-	WARN_ON(!mutex_is_locked(&pm_mutex));
+	WARN_ON(!mutex_is_locked(&system_transition_mutex));
 	if (saved_gfp_mask) {
 		gfp_allowed_mask = saved_gfp_mask;
 		saved_gfp_mask = 0;
@@ -173,7 +174,7 @@ void pm_restore_gfp_mask(void)
 
 void pm_restrict_gfp_mask(void)
 {
-	WARN_ON(!mutex_is_locked(&pm_mutex));
+	WARN_ON(!mutex_is_locked(&system_transition_mutex));
 	WARN_ON(saved_gfp_mask);
 	saved_gfp_mask = gfp_allowed_mask;
 	gfp_allowed_mask &= ~(__GFP_IO | __GFP_FS);
-- 
2.7.4
