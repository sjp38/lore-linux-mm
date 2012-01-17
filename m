Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id AF1426B00B0
	for <linux-mm@kvack.org>; Tue, 17 Jan 2012 08:23:19 -0500 (EST)
From: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
Subject: [PATCH v2 2/2] Memory notification pseudo-device module
Date: Tue, 17 Jan 2012 15:22:11 +0200
Message-Id: <5b429d6c4d0a3ad06ec01193eab7edc98a03e0de.1326803859.git.leonid.moiseichuk@nokia.com>
In-Reply-To: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
In-Reply-To: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
References: <cover.1326803859.git.leonid.moiseichuk@nokia.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: cesarb@cesarb.net, kamezawa.hiroyu@jp.fujitsu.com, emunson@mgebm.net, penberg@kernel.org, aarcange@redhat.com, riel@redhat.com, mel@csn.ul.ie, rientjes@google.com, dima@android.com, gregkh@suse.de, rebecca@android.com, san@google.com, akpm@linux-foundation.org, vesa.jaaskelainen@nokia.com

The memory notification (memnotify) device tracks level of memory utilization,
active page set and notifies subscribed processes when consumption crossed
specified threshold(s) up or down. It could be used on embedded devices to
implementation of performance-cheap memory reacting by using
e.g. libmemnotify or similar user-space component.

The minimal (250 ms) and maximal (15s) periods of reaction and granularity
(~1.4% of memory size) could be tuned using module options.

Signed-off-by: Leonid Moiseichuk <leonid.moiseichuk@nokia.com>
---
 drivers/misc/Kconfig     |   11 +
 drivers/misc/Makefile    |    1 +
 drivers/misc/memnotify.c |  582 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 594 insertions(+), 0 deletions(-)
 create mode 100644 drivers/misc/memnotify.c

diff --git a/drivers/misc/Kconfig b/drivers/misc/Kconfig
index 5664696..eefda14 100644
--- a/drivers/misc/Kconfig
+++ b/drivers/misc/Kconfig
@@ -500,6 +500,17 @@ config USB_SWITCH_FSA9480
 	  stereo and mono audio, video, microphone and UART data to use
 	  a common connector port.
 
+config MEMNOTIFY
+	tristate "Enables memory notification pseudo-device"
+	default n
+	help
+	  This option enables pseudo-device /dev/memnotify for tracking
+	  system memory utilization and updating state to subscribed clients
+	  when specified threshold reached.
+
+	  Say Y here if you want to support memory monitoring.
+	  If unsure, say N.
+
 source "drivers/misc/c2port/Kconfig"
 source "drivers/misc/eeprom/Kconfig"
 source "drivers/misc/cb710/Kconfig"
diff --git a/drivers/misc/Makefile b/drivers/misc/Makefile
index b26495a..86f6199 100644
--- a/drivers/misc/Makefile
+++ b/drivers/misc/Makefile
@@ -48,3 +48,4 @@ obj-y				+= lis3lv02d/
 obj-y				+= carma/
 obj-$(CONFIG_USB_SWITCH_FSA9480) += fsa9480.o
 obj-$(CONFIG_ALTERA_STAPL)	+=altera-stapl/
+obj-$(CONFIG_MEMNOTIFY)		+= memnotify.o
diff --git a/drivers/misc/memnotify.c b/drivers/misc/memnotify.c
new file mode 100644
index 0000000..898f3df
--- /dev/null
+++ b/drivers/misc/memnotify.c
@@ -0,0 +1,582 @@
+/*
+ * memnotify.c - system-wide memory meter and notifier pseudo-device
+ *
+ * Copyright (C) 2012 Nokia Corporation.
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
+/* #define DEBUG */
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/device.h>
+#include <linux/kernel.h>
+#include <linux/atomic.h>
+#include <linux/jiffies.h>
+#include <linux/miscdevice.h>
+#include <linux/mm.h>
+#include <linux/mmzone.h>
+#include <linux/slab.h>
+#include <linux/poll.h>
+#include <linux/highmem.h>
+#include <linux/swap.h>
+#include <linux/list.h>
+#include <linux/wait.h>
+#include <linux/spinlock.h>
+#include <linux/spinlock_types.h>
+#include <linux/timer.h>
+
+
+/*
+ * How often [ms] information will be updated.
+ */
+#define MN_UPDATE_PERIOD	250
+
+/*
+ * Maximal delay [ms] if no changes detected.
+ */
+#define MN_MAX_UPDATE_PERIOD	(15 * 1000)
+
+/*
+ * Which minimal [kb] allocation change will produce notification for user-space
+ * to avoid too often jittering.
+ */
+#define MN_UPDATE_SPACE	1024
+
+/*
+ * Which memory types we should have, report and track
+ *
+ * Note:
+ * If you need to report more values, add them here and
+ * modify get_memory_status function to fill more fields
+ *
+ * Warning:
+ * The length of list is limited by used flags mask (unsigned = 32)
+ */
+static const char * const memtypes[] = {
+	"total",
+	"used",
+	"active"
+};
+#define MN_TYPES_SIZE		(ARRAY_SIZE(memtypes))
+#define MN_LINE_BUFFER_SIZE	(MN_TYPES_SIZE * 64)
+
+/* Memory values indexed by memtypes */
+struct memvalue {
+	unsigned long	v[MN_TYPES_SIZE];
+};
+
+
+/* subscriber information to be notified when level changed */
+struct observer {
+	/* list data to check from notify_memory_usage and wakeup user-space */
+	struct list_head	list;
+
+	/* related file structure for open/close/read/write and poll */
+	struct file		*file;
+	/* thresholds [pages] when we should trigger notification */
+	struct memvalue		threshold;
+	/* bitmask: did we crossed theshold on last validation? */
+	unsigned		active;
+	/* flag about new notification is required */
+	bool			updated;
+};
+
+
+
+MODULE_AUTHOR("Leonid Moiseichuk (leonid.moiseichuk@nokia.com)");
+MODULE_DESCRIPTION("System memory meter/notification pseudo-device");
+MODULE_LICENSE("GPL v2");
+MODULE_VERSION("0.2.0");
+
+static unsigned update_period __read_mostly = MN_UPDATE_PERIOD;
+module_param(update_period, uint, 0);
+MODULE_PARM_DESC(update_period, "Base update interval [ms]");
+
+static unsigned max_update_period __read_mostly = MN_MAX_UPDATE_PERIOD;
+module_param(max_update_period, uint, 0);
+MODULE_PARM_DESC(max_update_period, "Maximal update interval [ms]");
+
+static unsigned update_space __read_mostly;
+module_param(update_space, uint, 0);
+MODULE_PARM_DESC(update_space, "Clients granularity space in [kb], 0 - auto");
+
+/* The device pointer, mostly for dev_XXX */
+static struct device *dev __read_mostly;
+
+/* Validated parameters in adequate units */
+static unsigned long update_period_jiffies     __read_mostly;
+static unsigned long max_update_period_jiffies __read_mostly;
+static unsigned      update_space_pages        __read_mostly;
+
+/* Memory values which is used in measurements and notification */
+static unsigned long available_pages      __read_mostly;
+#ifdef CONFIG_SWAP
+static unsigned long available_swap_pages __read_mostly;
+#endif
+
+/* Amount of memory measured and notified last time */
+/* That is safe to have these values as a normal data by design */
+static struct memvalue	last_measured	__read_mostly;
+static struct memvalue	last_notified	__read_mostly;
+
+/* Timer which is used to requesting vm statistics */
+static struct timer_list timer;
+static unsigned long update_timer_jiffies __read_mostly;
+
+/* Subscribers in poll() call to be validated and notified */
+static atomic_t observer_counter = ATOMIC_INIT(0);
+static DEFINE_SPINLOCK(observer_lock);
+static LIST_HEAD(observer_list);
+static DECLARE_WAIT_QUEUE_HEAD(watcher_queue);
+
+
+
+/* Validates two memvalues to be equal or not */
+static inline bool memvalue_about_equal(
+	const struct memvalue *a, const struct memvalue *b)
+{
+	unsigned m = 1;
+	unsigned i = 0;
+
+	while (i < MN_TYPES_SIZE) {
+		const unsigned long av = a->v[i];
+		const unsigned long bv = b->v[i];
+		/* if field set to zero = not tracked */
+		if (av && bv &&
+			(av < bv ? bv - av : av - bv) >= update_space_pages)
+			return false;
+		m <<= 1;
+		i++;
+	}
+
+	return true;
+}
+
+/* Produces bitmask of active memory thresholds */
+static inline unsigned memvalue_active(
+	const struct memvalue *t, const struct memvalue *c)
+{
+	unsigned a = 0;
+	unsigned m = 1;
+	unsigned i = 0;
+
+	while (i < MN_TYPES_SIZE) {
+		const unsigned long tv = t->v[i];
+		const unsigned long cv = c->v[i];
+		/* if field set to zero = not tracked */
+		if (tv && cv && cv >= tv)
+			a |= m;
+		m <<= 1;
+		i++;
+	}
+
+	return a;
+}
+
+
+static inline bool validate_observer(
+	struct observer *obs, const struct memvalue *now)
+{
+	/* evaluation of current state and compare to old one */
+	const unsigned active = memvalue_active(&obs->threshold, now);
+
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
+/* Please update this function if contents memtypes is changed */
+static inline void get_memory_status(struct memvalue *value)
+{
+	/* field #0 -- total available pages */
+	value->v[0] = available_pages;
+
+	/* field #1 -- used memory by substracting free memories */
+	value->v[1] = available_pages;
+
+	/* RAM part: free + slab rec + cached - shared - mlocked */
+	value->v[1] -= global_page_state(NR_FREE_PAGES);
+	value->v[1] -= global_page_state(NR_SLAB_RECLAIMABLE);
+	value->v[1] -= global_page_state(NR_FILE_PAGES);
+	value->v[1] += global_page_state(NR_SHMEM);
+	value->v[1] += global_page_state(NR_MLOCK);
+#ifdef CONFIG_SWAP
+	/* Swap if we have */
+	if (available_swap_pages) {
+		struct sysinfo si;
+		si_swapinfo(&si);
+		value->v[1] -= si.freeswap;
+	}
+#endif
+
+	/* field #2 -- active pages */
+	value->v[2]  = global_page_state(LRU_ACTIVE_FILE);
+	value->v[2] += global_page_state(LRU_ACTIVE_ANON);
+}
+
+/* this method invoked from timer to re-check statistics */
+static void timer_function(unsigned long data)
+{
+	/* data is not used */
+	data = data;
+
+	/* query current memory statistics */
+	get_memory_status(&last_measured);
+
+	/* do we have value changed? */
+	if (!memvalue_about_equal(&last_measured, &last_notified)) {
+		last_notified = last_measured;
+		update_timer_jiffies = update_period_jiffies;
+		if (atomic_read(&observer_counter) > 0) {
+			bool updated = false;
+			struct list_head *pos;
+
+			spin_lock(&observer_lock);
+			list_for_each(pos, &observer_list) {
+				struct observer *obs = (struct observer *)pos;
+				if (validate_observer(obs, &last_measured)) {
+					updated = true;
+					/*
+					 * some watcher changed status
+					 * the rest will be done in mn_poll
+					 */
+					break;
+				}
+			}
+			spin_unlock(&observer_lock);
+
+			if (updated) {
+				/*
+				 * Wakeup of tasks should happened rare, only
+				 * when at least one theshold changed. So has
+				 * sense to show this information in logs.
+				 */
+				dev_info(dev, "wakeup polling tasks\n");
+				wake_up_all(&watcher_queue);
+			}
+		}
+	} else {
+		update_timer_jiffies <<= 1;
+		if (update_timer_jiffies > max_update_period_jiffies)
+			update_timer_jiffies = max_update_period_jiffies;
+	}
+
+	dev_dbg(dev, "tick for %lu jiffies\n", update_timer_jiffies);
+	mod_timer(&timer, jiffies + update_timer_jiffies);
+}
+
+static int vm_shrink(struct shrinker *sh, struct shrink_control *sc)
+{
+	/* unused values */
+	sh = sh;
+	sc = sc;
+
+	/* we are in reclaim mode - recheck memory situation later */
+	if (update_timer_jiffies != update_period_jiffies) {
+		/* adjust timer only in case it has sense */
+		update_timer_jiffies = update_period_jiffies;
+		mod_timer(&timer, jiffies + update_timer_jiffies);
+		dev_dbg(dev, "memory pressure - timer adjusted\n");
+	}
+
+	return 0;
+}
+
+static struct shrinker vm_shrinker = {
+	.shrink = vm_shrink,
+	.seeks = DEFAULT_SEEKS
+};
+
+
+static inline void subscribe_vm_stats(void)
+{
+	/* the initial delay always started from specified value */
+	update_timer_jiffies = update_period_jiffies;
+
+	/* update memory statistics */
+	get_memory_status(&last_measured);
+	last_notified = last_measured;
+
+	/* create timer and register shrinker */
+	init_timer_deferrable(&timer);
+	timer.data = 0;
+	timer.function = timer_function;
+	timer.expires = jiffies + update_timer_jiffies;
+	add_timer(&timer);
+	register_shrinker(&vm_shrinker);
+}
+
+static inline void unsubscribe_vm_stats(void)
+{
+	unregister_shrinker(&vm_shrinker);
+	del_timer_sync(&timer);
+}
+
+static int mn_open(struct inode *inode, struct file *file)
+{
+	struct observer *obs;
+
+	obs = kmalloc(sizeof(*obs), GFP_KERNEL);
+	if (obs) {
+		get_device(dev);
+
+		/* object initialization */
+		memset(obs, 0, sizeof(*obs));
+		obs->file      = file;
+		file->private_data = obs;
+
+		/* place it into checking list */
+		spin_lock(&observer_lock);
+		list_add(&obs->list, &observer_list);
+		spin_unlock(&observer_lock);
+
+		/* subscribe to vm stat updates */
+		if (1 == atomic_add_return(1, &observer_counter))
+			subscribe_vm_stats();
+
+		dev_dbg(dev, "0x%p - observer %u created\n",
+				obs, atomic_read(&observer_counter));
+
+		return 0;
+	}
+
+	return -ENOMEM;
+}
+
+static int mn_release(struct inode *inode, struct file *file)
+{
+	struct observer *obs = (struct observer *)file->private_data;
+
+	if (obs) {
+		dev_dbg(dev, "0x%p - observer released\n", obs);
+
+		/* unsubscribe from vm stat updates */
+		if (0 == atomic_sub_return(1, &observer_counter))
+			unsubscribe_vm_stats();
+
+		/* remove from checking list */
+		spin_lock(&observer_lock);
+		list_del(&obs->list);
+		spin_unlock(&observer_lock);
+
+		/* cleanup the memory */
+		file->private_data = NULL;
+		kfree(obs);
+
+		put_device(dev);
+	}
+
+	return 0;
+}
+
+static ssize_t mn_read(struct file *file, char __user *buf,
+				size_t count, loff_t *ppos)
+{
+	char tmp[MN_LINE_BUFFER_SIZE];
+	ssize_t pos = 0;
+	const struct memvalue mv = last_measured;
+	int idx;
+
+	for (idx = 0; idx < MN_TYPES_SIZE && pos < sizeof(tmp) - 2; idx++) {
+		ssize_t retval;
+
+		if (pos > 0)
+			tmp[pos++] = ' ';
+		retval = snprintf(&tmp[pos], sizeof(tmp) - pos,
+				"%s %lu",
+				memtypes[idx], mv.v[idx]);
+		if (retval > 0)
+			pos += retval;
+		else
+			return -EINVAL;
+	}
+
+	if (pos < sizeof(tmp))
+		tmp[pos++] = '\n';
+
+	if (pos > count)
+		pos = count;
+
+	return copy_to_user(buf, tmp, pos) ? -EINVAL : pos;
+}
+
+static ssize_t mn_write(struct file *file, const char __user *buf,
+					size_t count, loff_t *offset)
+{
+	struct observer *obs = (struct observer *)file->private_data;
+	char tmp[MN_LINE_BUFFER_SIZE];
+	ssize_t retval = min(count, sizeof(tmp) - 1);
+	int index;
+
+	if (copy_from_user(tmp, buf, retval))
+		return -EINVAL;
+
+	tmp[retval]  = 0;
+	obs->updated = false;
+	obs->active  = 0;
+	for (index = 0; index < MN_TYPES_SIZE; index++) {
+		const char *ptr = strstr(tmp, memtypes[index]);
+		if (ptr) {
+			char nmb[64];
+			int  i;
+
+			ptr += strlen(memtypes[index]) + 1;
+			while (*ptr && *ptr < '0')
+				ptr++;
+			for (i = 0; i < sizeof(nmb) - 1; i++, ptr++) {
+				const char c = *ptr;
+				if (c < '0' || c > '9')
+					break;
+				nmb[i] = c;
+			}
+			nmb[i] = 0;
+
+			if (kstrtoul(nmb, 10, &obs->threshold.v[index]) < 0) {
+				dev_dbg(dev,
+					"0x%p - cannot parse '%s' as '%s'\n",
+						obs, memtypes[index], nmb);
+				obs->threshold.v[index] = 0;
+				return -EINVAL;
+			}
+		} else
+			obs->threshold.v[index] = 0;
+	}
+	obs->active = memvalue_active(&obs->threshold, &last_measured);
+	dev_dbg(dev, "0x%p - threshold set to 0x%x\n", obs, obs->active);
+
+	return (ssize_t)count;
+}
+
+static unsigned int mn_poll(struct file *file, poll_table *wait)
+{
+	struct observer *obs = (struct observer *)file->private_data;
+
+	if (NULL == obs)
+		return 0;
+
+	poll_wait(file, &watcher_queue, wait);
+	if (validate_observer(obs, &last_measured)) {
+		dev_info(dev, "0x%p - threshold updated to 0x%x\n",
+					obs, obs->active);
+		obs->updated = false;
+		return POLLIN;
+	} else
+		return 0;
+}
+
+
+
+static const struct file_operations mn_fops = {
+	.owner   = THIS_MODULE,
+	.llseek  = noop_llseek,
+	.open    = mn_open,
+	.release = mn_release,
+	.read    = mn_read,
+	.write   = mn_write,
+	.poll    = mn_poll,
+};
+
+static struct miscdevice mn_device = {
+	.minor = MISC_DYNAMIC_MINOR,
+	.name  = "memnotify",
+	.fops  = &mn_fops,
+};
+
+
+static int __init mn_init(void)
+{
+	struct sysinfo si;
+	int error;
+#ifdef DEBUG
+	int i;
+#endif
+
+	error = misc_register(&mn_device);
+	if (error) {
+		pr_err("unable to register device %d\n", error);
+		return error;
+	}
+	dev = mn_device.this_device;
+
+	update_period_jiffies = msecs_to_jiffies(update_period);
+	if (!update_period_jiffies)
+		update_period_jiffies = msecs_to_jiffies(MN_UPDATE_PERIOD);
+
+	max_update_period_jiffies = msecs_to_jiffies(max_update_period);
+	if (max_update_period_jiffies < update_period_jiffies)
+		max_update_period_jiffies = update_period_jiffies;
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
+	/* update_space_pages extra divided by 2 due to it is an offset      */
+	if (update_space)
+		update_space_pages = update_space >> (PAGE_SHIFT - 10 + 1);
+	else
+		update_space_pages = available_pages >> 7;
+	if (!update_space_pages)
+		update_space_pages = MN_UPDATE_SPACE >> (PAGE_SHIFT - 10 + 1);
+
+	dev_dbg(dev, "update period set to %u ms or %lu jiffies\n",
+				update_period, update_period_jiffies);
+	dev_dbg(dev, "update period limit set to %u ms or %lu jiffies\n",
+				max_update_period, max_update_period_jiffies);
+	dev_dbg(dev, "update space set to %u kb or -+%u pages\n",
+				update_space, update_space_pages);
+
+#ifdef CONFIG_SWAP
+	dev_dbg(dev, "%lu available pages found (%lu ram + %lu swap)\n",
+				available_pages, si.totalram, si.totalswap);
+#else
+	dev_dbg(dev, "%lu available pages found (only ram)\n",
+						available_pages);
+#endif
+
+#ifdef DEBUG
+	get_memory_status(&last_measured);
+	for (i = 0; i < MN_TYPES_SIZE; i++) {
+		dev_dbg(dev, "%lu %s pages, utilization %lu percents\n",
+						last_measured.v[i],
+							memtypes[i],
+			(100 * last_measured.v[i]) / available_pages);
+	}
+#endif
+
+	dev_dbg(dev, "overhead per client connection is %u bytes\n",
+				(unsigned)sizeof(struct observer));
+
+	return 0;
+}
+
+static void __exit mn_exit(void)
+{
+	dev = NULL;
+	misc_deregister(&mn_device);
+}
+
+
+module_init(mn_init);
+module_exit(mn_exit);
-- 
1.7.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
