Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3385A6B004F
	for <linux-mm@kvack.org>; Wed,  4 Jan 2012 12:23:59 -0500 (EST)
From: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Subject: [PATCH 3.2.0-rc1 3/3] Used Memory Meter pseudo-device module
Date: Wed,  4 Jan 2012 19:21:56 +0200
Message-Id: <ed78895aa673d2e5886e95c3e3eae38cc6661eda.1325696593.git.leonid.moiseichuk@nokia.com>
In-Reply-To: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
In-Reply-To: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
References: <cover.1325696593.git.leonid.moiseichuk@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

The Used Memory Meter (UMM) device tracks level of memory utilization
and notifies subscribed processes when consumption crossed specified
threshold up or down. It could be used on embedded devices to
implementation of performance-cheap memory reacting by using
e.g. libmemnotify or similar user-space component.

Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
---
 drivers/misc/Kconfig  |   12 ++
 drivers/misc/Makefile |    1 +
 drivers/misc/umm.c    |  452 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/linux/umm.h   |   42 +++++
 4 files changed, 507 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/umm.c
 create mode 100644 include/linux/umm.h

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index d593878..5d71960 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -499,6 +499,18 @@ config USB_SWITCH_FSA9480
 	  stereo and mono audio, video, microphone and UART data to use
 	  a common connector port.
 
+config USED_MEMORY_METER
+	tristate "Enables used memory meter pseudo-device"
+	default n
+	select MM_ALLOC_FREE_HOOK
+	help
+	  This option enables pseudo-device /dev/used_memory for tracking
+	  system memory utilization and updating state to subscribed clients
+	  when specified threshold reached.
+
+	  Say Y here if you want to support used memory monitor.
+	  If unsure, say N.
+
 source "drivers/misc/c2port/Kconfig"
 source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index b26495a..eaec343 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -48,3 +48,4 @@ obj-y				+= lis3lv02d/
 obj-y				+= carma/
 obj-$(CONFIG_USB_SWITCH_FSA9480) += fsa9480.o
 obj-$(CONFIG_ALTERA_STAPL)	+=altera-stapl/
+obj-$(CONFIG_USED_MEMORY_METER)	+= umm.o
diff --git a/drivers/misc/umm.c b/drivers/misc/umm.c
new file mode 100644
index 0000000..a384be20
--- /dev/null
+++ b/drivers/misc/umm.c
@@ -0,0 +1,452 @@
+/*
+ * umm.c - system-wide Used Memory Meter pseudo-device implementation
+ *
+ * Copyright (C) 2011 Nokia Corporation.
+ *      Leonid Moiseichuk
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/kernel.h>
+#include <linux/atomic.h>
+#include <linux/jiffies.h>
+#include <linux/mm.h>
+#include <linux/slab.h>
+#include <linux/poll.h>
+#include <linux/highmem.h>
+#include <linux/swap.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/spinlock.h>
+#include <linux/spinlock_types.h>
+
+#include <linux/umm.h>
+
+
+
+/* subscriber information to be notified when level changed */
+struct observer {
+	/* list data to check from notify_memory_usage and wakeup user-space */
+	struct list_head list;
+	/* related file structure for open/close/read/write and poll */
+	struct file	*file;
+	/* threshold [pages] when we should trigger notification */
+	unsigned long	threshold;
+	/* did we crossed theshold on last validation? */
+	bool		active;
+	/* flag about new notification is required */
+	bool		updated;
+};
+
+
+
+MODULE_AUTHOR("Leonid Moiseichuk (leonid.moiseichuk@nokia.com)");
+MODULE_DESCRIPTION("System used memory meter pseudo-device");
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION("0.0.2");
+
+static int debug __read_mostly;
+module_param(debug, bool, 0);
+MODULE_PARM_DESC(debug, "More info about module parameters and operations");
+
+static int probe __read_mostly;
+module_param(probe, bool, 0);
+MODULE_PARM_DESC(probe, "Probe measurement overhead during loading");
+
+static char device_name[64] __read_mostly = UMM_DEVICE_NAME;
+module_param_string(device_name, device_name, sizeof(device_name), 0);
+MODULE_PARM_DESC(device_name, "Device name in /dev if need different");
+
+static unsigned update_period __read_mostly = UMM_UPDATE_PERIOD;
+module_param(update_period, uint, 0);
+MODULE_PARM_DESC(update_period, "Update interval period [ms]");
+
+static unsigned update_space __read_mostly;
+module_param(update_space, uint, 0);
+MODULE_PARM_DESC(update_space, "Clients granularity space in [kb], 0 - auto");
+
+/* Validated parameters in adequate units */
+static unsigned long update_period_jiffies __read_mostly;
+static unsigned      update_space_pages    __read_mostly;
+static mm_alloc_free_hook_t old_mm_hook    __read_mostly;
+
+/* Timestamp when last time memory usage was measured */
+static atomic_long_t last_time_jiffies __read_mostly =
+					ATOMIC_LONG_INIT(INITIAL_JIFFIES);
+/* Memory values which is used in measurements and notification */
+static unsigned long available_pages      __read_mostly;
+#ifdef CONFIG_SWAP
+static unsigned long available_swap_pages __read_mostly;
+#endif
+static atomic_long_t last_used_pages   __read_mostly = ATOMIC_LONG_INIT(0);
+static atomic_long_t last_nofity_pages __read_mostly = ATOMIC_LONG_INIT(0);
+
+/* Subscribers in poll() call to be validated and notified */
+static atomic_t observer_counter = ATOMIC_INIT(0);
+static DEFINE_SPINLOCK(observer_lock);
+static LIST_HEAD(observer_list);
+static DECLARE_WAIT_QUEUE_HEAD(watcher_queue);
+
+
+
+static inline bool notification_required(unsigned long a, unsigned long b)
+{
+	return (a < b ? b - a : a - b) >= update_space_pages / 2;
+}
+
+static inline bool validate_observer(struct observer *obs, unsigned long used)
+{
+	/* evaluation of current state and compare to old one */
+	const bool active = (obs->threshold && obs->threshold < used);
+	/*
+	 * If we evaluated status just before and did not send update
+	 * yet to user-space we must preserve update flag.
+	 */
+	if (active != obs->active) {
+		obs->active  = active;
+		obs->updated = true;
+	}
+
+	return obs->updated;
+}
+
+static inline unsigned long get_memory_usage(void)
+{
+	/* calculate used pages by substracting free memories */
+	unsigned long used = available_pages;
+
+	/* RAM part: free + slab rec + cached - shared */
+	used -= global_page_state(NR_FREE_PAGES);
+	used -= global_page_state(NR_SLAB_RECLAIMABLE);
+	used -= global_page_state(NR_FILE_PAGES);
+	used += global_page_state(NR_SHMEM);
+
+#ifdef CONFIG_SWAP
+	/* Swap if we have */
+	if (available_swap_pages) {
+		struct sysinfo si;
+		si_swapinfo(&si);
+		used -= si.freeswap;
+	}
+#endif
+
+	return used;
+}
+
+static inline void update_memory_usage(void)
+{
+	atomic_long_set(&last_used_pages, get_memory_usage());
+	atomic_long_set(&last_time_jiffies, jiffies + update_period_jiffies);
+}
+
+/* this code called from allocation hook = must be as fast as possible */
+static inline void notify_memory_usage(void)
+{
+	const unsigned long was = atomic_long_read(&last_nofity_pages);
+	const unsigned long now = atomic_long_read(&last_used_pages);
+
+	if (notification_required(was, now)) {
+		bool updated = false;
+		struct list_head *pos;
+
+		atomic_long_set(&last_nofity_pages, now);
+		spin_lock(&observer_lock);
+		list_for_each(pos, &observer_list) {
+			struct observer *obs = (struct observer *)pos;
+			if (validate_observer(obs, now)) {
+				updated = true;
+				/*
+				 * some watcher changed status
+				 * the rest of checks will be done in umm_poll
+				 */
+				break;
+			}
+		}
+		spin_unlock(&observer_lock);
+		if (updated) {
+			if (debug)
+				pr_info("UMM: wakeup polling tasks\n");
+			wake_up_all(&watcher_queue);
+		}
+	}
+}
+
+/* this method invoked from MM allocation hot path */
+static void mm_alloc_free_hook(int pages)
+{
+	const unsigned long last_measured =
+		(unsigned long)atomic_long_read(&last_time_jiffies);
+
+	if (abs(pages) >= update_space_pages ||
+		time_is_before_jiffies(last_measured)) {
+		update_memory_usage();
+		if (atomic_read(&observer_counter) > 0)
+			notify_memory_usage();
+	}
+
+	if (old_mm_hook)
+		old_mm_hook(pages);
+}
+
+
+
+static int umm_open(struct inode *inode, struct file *file)
+{
+	struct observer *obs;
+
+	obs = kmalloc(sizeof(*obs), GFP_KERNEL);
+	if (obs) {
+		/* object initialization */
+		memset(obs, 0, sizeof(obs));
+		obs->file      = file;
+		file->private_data = obs;
+
+		/* place it into checking list */
+		spin_lock(&observer_lock);
+		list_add(&obs->list, &observer_list);
+		spin_unlock(&observer_lock);
+		atomic_inc(&observer_counter);
+
+		if (debug)
+			pr_info("UMM: 0x%p - observer %u created\n",
+				obs, atomic_read(&observer_counter));
+
+		return 0;
+	}
+
+	return -ENOMEM;
+}
+
+static int umm_release(struct inode *inode, struct file *file)
+{
+	struct observer *obs = (struct observer *)file->private_data;
+
+	if (obs) {
+		if (debug)
+			pr_info("UMM: 0x%p - observer released\n", obs);
+
+		/* remove from checking list */
+		atomic_dec(&observer_counter);
+		spin_lock(&observer_lock);
+		list_del(&obs->list);
+		spin_unlock(&observer_lock);
+
+		/* cleanup the memory */
+		file->private_data = NULL;
+		kfree(obs);
+	}
+
+	return 0;
+}
+
+static ssize_t umm_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	char tmp[128];
+	ssize_t retval;
+
+	retval = snprintf(tmp, sizeof(tmp), "%lu:%lu\n",
+			atomic_long_read(&last_used_pages), available_pages);
+	if (retval > count)
+		retval = count;
+	return copy_to_user(buf, tmp, retval) ? -EINVAL : retval;
+}
+
+static ssize_t umm_write(struct file *file, const char __user *buf,
+					size_t count, loff_t *offset)
+{
+	struct observer *obs = (struct observer *)file->private_data;
+
+	obs->updated = false;
+	if (kstrtoul_from_user(buf, count, 10, &obs->threshold) < 0) {
+		obs->threshold = 0;
+		obs->active = false;
+		return -EINVAL;
+	}
+	obs->active = (obs->threshold &&
+			obs->threshold < atomic_long_read(&last_used_pages));
+	if (debug)
+		pr_info("UMM: 0x%p - threshold set to %lu -> %d\n",
+					obs, obs->threshold, obs->active);
+
+	return (ssize_t)count;
+}
+
+static unsigned int umm_poll(struct file *file, poll_table *wait)
+{
+	struct observer *obs = (struct observer *)file->private_data;
+
+	if (NULL == obs || 0 == obs->threshold)
+		return 0;
+
+	poll_wait(file, &watcher_queue, wait);
+	if (validate_observer(obs, atomic_long_read(&last_used_pages))) {
+		if (debug)
+			pr_info("UMM: 0x%p - threshold %lu updated to %d\n",
+					obs, obs->threshold, obs->active);
+		obs->updated = false;
+		return POLLIN;
+	} else
+		return 0;
+}
+
+
+
+static const struct file_operations umm_fops = {
+	.llseek  = noop_llseek,
+	.open    = umm_open,
+	.release = umm_release,
+	.read    = umm_read,
+	.write   = umm_write,
+	.poll    = umm_poll,
+};
+
+static struct device *umm_device __read_mostly;
+static struct class  *umm_class  __read_mostly;
+static int            umm_major  __read_mostly = -1;
+
+
+static int __init umm_init(void)
+{
+	struct sysinfo si;
+	int error;
+
+	pr_info("UMM: Used Memory Meter loading to support /dev/%s\n",
+							device_name);
+
+	umm_major = register_chrdev(0, device_name, &umm_fops);
+	if (umm_major < 0) {
+		pr_err("UMM: unable to get major number for device %s\n",
+							device_name);
+		error = -EBUSY;
+		goto register_failed;
+	}
+
+	umm_class = class_create(THIS_MODULE, device_name);
+	if (IS_ERR(umm_class)) {
+		error = PTR_ERR(umm_class);
+		pr_err("UMM: unable to create class for device %s - %d\n",
+						device_name, error);
+		goto class_failed;
+	}
+
+	umm_device = device_create(
+			umm_class, NULL,
+			MKDEV(umm_major, 0),
+			NULL, device_name);
+	if (IS_ERR(umm_device)) {
+		error = PTR_ERR(umm_device);
+		pr_err("UMM: unable to create device %s - %d\n",
+						device_name, error);
+		goto device_failed;
+	}
+
+	update_period_jiffies = msecs_to_jiffies(update_period);
+	if (!update_period_jiffies)
+		update_period_jiffies = msecs_to_jiffies(UMM_UPDATE_PERIOD);
+
+	/* query amount of available ram and swap, mem_unit is PAGE_SIZE */
+	si_meminfo(&si);
+#ifdef CONFIG_SWAP
+	si_swapinfo(&si);
+	available_pages = si.totalram + si.totalswap;
+	available_swap_pages = si.totalswap;
+#else
+	available_pages = si.totalram;
+#endif
+	/* if autodetect then set granularity to ~1.4% from available memory */
+	if (update_space)
+		update_space_pages = update_space >> (PAGE_SHIFT - 10);
+	else
+		update_space_pages = available_pages >> 6;
+	if (!update_space_pages)
+		update_space_pages = UMM_UPDATE_SPACE >> (PAGE_SHIFT - 10);
+
+	update_memory_usage();
+	old_mm_hook = set_mm_alloc_free_hook(mm_alloc_free_hook);
+
+	if (debug) {
+		pr_info("UMM: /dev/%s got major %d\n", device_name, umm_major);
+		pr_info("UMM: update period set to %u ms or %lu jiffies\n",
+					update_period, update_period_jiffies);
+		pr_info("UMM: update space set to %u kb or %u pages\n",
+					update_space, update_space_pages);
+		pr_info("UMM: old mm alloc/free hook is 0x%p\n", old_mm_hook);
+		pr_info("UMM: now hook set to 0x%p\n", mm_alloc_free_hook);
+#ifdef CONFIG_SWAP
+		pr_info("UMM: %lu available pages found (only ram)\n",
+							available_pages);
+#else
+		pr_info("UMM: %lu available pages found (%lu ram + %lu swap)\n",
+				available_pages, si.totalram, si.totalswap);
+#endif
+		pr_info("UMM: %lu used pages, utilization %lu percents\n",
+					atomic_long_read(&last_used_pages),
+			(100 * atomic_long_read(&last_used_pages)) /
+							available_pages);
+		pr_info("UMM: overhead per client connection is %lu bytes\n",
+						sizeof(struct observer));
+	}
+
+	if (probe) {
+		unsigned long start;
+		unsigned long stop;
+		unsigned long time;
+		unsigned long counter = 0;
+
+		pr_info("UMM: probing measurements overhead for %u [ms] ...\n",
+							UMM_PROBE_PERIOD);
+		start = jiffies;
+		stop  = jiffies + msecs_to_jiffies(UMM_PROBE_PERIOD);
+		while (time_is_after_jiffies(stop)) {
+			update_memory_usage();
+			counter++;
+		}
+		time = jiffies_to_usecs(jiffies - start);
+		pr_info("UMM: %lu probes done in %lu us, %lu probes/us\n",
+					counter, time, counter / time);
+	}
+
+	return 0;
+
+device_failed:
+	class_destroy(umm_class);
+class_failed:
+	unregister_chrdev(umm_major, device_name);
+register_failed:
+	return error;
+}
+
+static void __exit umm_exit(void)
+{
+	mm_alloc_free_hook_t hook = set_mm_alloc_free_hook(old_mm_hook);
+
+	if (debug)
+		pr_info("UMM: old mm alloc/free hook 0x%p restored\n",
+							old_mm_hook);
+	if (mm_alloc_free_hook != hook)
+		pr_warning("UMM: restored 0x%p, expected 0x%p!\n",
+					hook, mm_alloc_free_hook);
+	if (umm_device)
+		device_del(umm_device);
+	if (umm_class)
+		class_destroy(umm_class);
+	if (umm_major >= 0)
+		unregister_chrdev(umm_major, device_name);
+
+	pr_info("UMM: Used Memory Meter unloaded, /dev/%s gone\n", device_name);
+}
+
+
+module_init(umm_init);
+module_exit(umm_exit);
diff --git a/include/linux/umm.h b/include/linux/umm.h
new file mode 100644
index 0000000..0bfc0b0
--- /dev/null
+++ b/include/linux/umm.h
@@ -0,0 +1,42 @@
+/*
+ * umm.h - system-wide Used Memory Meter definitions
+ *
+ * Copyright (C) 2011 Nokia Corporation.
+ *      Leonid Moiseichuk
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed "as is" WITHOUT ANY WARRANTY of any
+ * kind, whether express or implied; without even the implied warranty
+ * of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ */
+
+#ifndef LINUX_UMM_H
+#define LINUX_UMM_H
+
+/*
+ * Pseudo-device name in /dev to subscribe or read data.
+ */
+#define UMM_DEVICE_NAME	"used_memory"
+
+/*
+ * How often [ms] usage information will be updated.
+ * It happened in alloc/free hook and needs to be tuned for your system.
+ */
+#define UMM_UPDATE_PERIOD	250
+
+/*
+ * Which minimal [kb] allocation change will produce notification for user-space
+ * to avoid too often jittering.
+ */
+#define UMM_UPDATE_SPACE	1024
+
+/*
+ * Probe period [ms] if it requested during module loading to clarify overhead.
+ */
+#define UMM_PROBE_PERIOD	100
+
+#endif
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
