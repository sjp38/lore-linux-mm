Received: by py-out-1112.google.com with SMTP id f47so4290535pye.20
        for <linux-mm@kvack.org>; Sat, 09 Feb 2008 07:23:37 -0800 (PST)
Message-ID: <2f11576a0802090723k42c5b383p76cee418c8d921b6@mail.gmail.com>
Date: Sun, 10 Feb 2008 00:23:36 +0900
From: "KOSAKI Motohiro" <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/8][for -mm] mem_notify v6: introduce /dev/mem_notify new device (the core of this patch series)
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@lxorguk.ukuu.org.uk>, linux-fsdevel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, Al Boldi <a1426z@gawab.com>, Jon Masters <jonathan@jonmasters.org>, Zan Lynx <zlynx@acm.org>
List-ID: <linux-mm.kvack.org>

the core of this patch series.
add /dev/mem_notify device for notification low memory to user process.

<usage examle>

        fd = open("/dev/mem_notify", O_RDONLY);
        if (fd < 0) {
                exit(1);
        }
        pollfds.fd = fd;
        pollfds.events = POLLIN;
        pollfds.revents = 0;
	err = poll(&pollfds, 1, -1); // wake up at low memory

        ...
</usage example>

ChangeLog
     v5 -> v6:
         o improve number of wakeup tasks fomula when task is a few.



Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 Documentation/devices.txt  |    1
 drivers/char/mem.c         |    5 +
 include/linux/mem_notify.h |   42 +++++++++++++++
 include/linux/mmzone.h     |    1
 mm/Makefile                |    2
 mm/mem_notify.c            |  123 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |    1
 7 files changed, 174 insertions(+), 1 deletion(-)

Index: b/drivers/char/mem.c
===================================================================
--- a/drivers/char/mem.c	2008-02-03 20:59:43.000000000 +0900
+++ b/drivers/char/mem.c	2008-02-03 21:00:24.000000000 +0900
@@ -26,6 +26,7 @@
 #include <linux/bootmem.h>
 #include <linux/splice.h>
 #include <linux/pfn.h>
+#include <linux/mem_notify.h>

 #include <asm/uaccess.h>
 #include <asm/io.h>
@@ -869,6 +870,9 @@ static int memory_open(struct inode * in
 			filp->f_op = &oldmem_fops;
 			break;
 #endif
+		case 13:
+			filp->f_op = &mem_notify_fops;
+			break;
 		default:
 			return -ENXIO;
 	}
@@ -901,6 +905,7 @@ static const struct {
 #ifdef CONFIG_CRASH_DUMP
 	{12,"oldmem",    S_IRUSR | S_IWUSR | S_IRGRP, &oldmem_fops},
 #endif
+	{13, "mem_notify", S_IRUGO, &mem_notify_fops},
 };

 static struct class *mem_class;
Index: b/include/linux/mem_notify.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/include/linux/mem_notify.h	2008-02-03 21:01:41.000000000 +0900
@@ -0,0 +1,42 @@
+/*
+ * Notify applications of memory pressure via /dev/mem_notify
+ *
+ * Copyright (C) 2008 Marcelo Tosatti <marcelo@kvack.org>,
+ *                    KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
+ *
+ * Released under the GPL, see the file COPYING for details.
+ */
+
+#ifndef _LINUX_MEM_NOTIFY_H
+#define _LINUX_MEM_NOTIFY_H
+
+#define MEM_NOTIFY_FREQ (HZ/5)
+
+extern atomic_long_t last_mem_notify;
+extern struct file_operations mem_notify_fops;
+
+extern void __memory_pressure_notify(struct zone *zone, int pressure);
+
+static inline void memory_pressure_notify(struct zone *zone, int pressure)
+{
+	unsigned long target;
+	unsigned long pages_high, pages_free, pages_reserve;
+
+	if (pressure) {
+		target = atomic_long_read(&last_mem_notify) + MEM_NOTIFY_FREQ;
+		if (likely(time_before(jiffies, target)))
+			return;
+
+		pages_high = zone->pages_high;
+		pages_free = zone_page_state(zone, NR_FREE_PAGES);
+		pages_reserve = zone->lowmem_reserve[MAX_NR_ZONES-1];
+		if (unlikely(pages_free > (pages_high+pages_reserve)*2))
+			return;
+
+	} else if (likely(!zone->mem_notify_status))
+		return;
+
+	__memory_pressure_notify(zone, pressure);
+}
+
+#endif /* _LINUX_MEM_NOTIFY_H */
Index: b/include/linux/mmzone.h
===================================================================
--- a/include/linux/mmzone.h	2008-02-03 20:59:43.000000000 +0900
+++ b/include/linux/mmzone.h	2008-02-03 20:59:46.000000000 +0900
@@ -283,6 +283,7 @@ struct zone {
 	 */
 	int prev_priority;

+	int mem_notify_status;

 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
Index: b/mm/Makefile
===================================================================
--- a/mm/Makefile	2008-02-03 20:59:43.000000000 +0900
+++ b/mm/Makefile	2008-02-03 20:59:46.000000000 +0900
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o mem_notify.o $(mmu-y)

 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
Index: b/mm/mem_notify.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/mm/mem_notify.c	2008-02-03 21:02:30.000000000 +0900
@@ -0,0 +1,123 @@
+/*
+ * Notify applications of memory pressure via /dev/mem_notify
+ *
+ * Copyright (C) 2008 Marcelo Tosatti <marcelo@kvack.org>,
+ *                    KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
+ *
+ * Released under the GPL, see the file COPYING for details.
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/wait.h>
+#include <linux/poll.h>
+#include <linux/timer.h>
+#include <linux/spinlock.h>
+#include <linux/mm.h>
+#include <linux/vmstat.h>
+#include <linux/percpu.h>
+#include <linux/timer.h>
+#include <linux/mem_notify.h>
+
+#include <asm/atomic.h>
+
+#define MAX_PROC_WAKEUP_GUARD  (10*HZ)
+#define MAX_WAKEUP_TASKS (100)
+
+struct mem_notify_file_info {
+	unsigned long last_proc_notify;
+};
+
+static DECLARE_WAIT_QUEUE_HEAD(mem_wait);
+static atomic_long_t nr_under_memory_pressure_zones = ATOMIC_LONG_INIT(0);
+static atomic_t nr_watcher_task = ATOMIC_INIT(0);
+
+atomic_long_t last_mem_notify = ATOMIC_LONG_INIT(INITIAL_JIFFIES);
+
+void __memory_pressure_notify(struct zone *zone, int pressure)
+{
+	int nr_wakeup;
+	int flags;
+
+	spin_lock_irqsave(&mem_wait.lock, flags);
+
+	if (pressure != zone->mem_notify_status) {
+		long val = pressure ? 1 : -1;
+		atomic_long_add(val, &nr_under_memory_pressure_zones);
+		zone->mem_notify_status = pressure;
+	}
+
+	if (pressure) {
+		int nr_watcher = atomic_read(&nr_watcher_task);
+
+		atomic_long_set(&last_mem_notify, jiffies);
+		if (!nr_watcher)
+			goto out;
+
+		nr_wakeup = (nr_watcher >> 4) + 1;
+		if (unlikely(nr_wakeup > MAX_WAKEUP_TASKS))
+			nr_wakeup = MAX_WAKEUP_TASKS;
+
+		wake_up_locked_nr(&mem_wait, nr_wakeup);
+	}
+out:
+	spin_unlock_irqrestore(&mem_wait.lock, flags);
+}
+
+static int mem_notify_open(struct inode *inode, struct file *file)
+{
+	struct mem_notify_file_info *info;
+	int    err = 0;
+
+	info = kmalloc(sizeof(*info), GFP_KERNEL);
+	if (!info) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	info->last_proc_notify = INITIAL_JIFFIES;
+	file->private_data = info;
+	atomic_inc(&nr_watcher_task);
+out:
+	return err;
+}
+
+static int mem_notify_release(struct inode *inode, struct file *file)
+{
+	kfree(file->private_data);
+	atomic_dec(&nr_watcher_task);
+	return 0;
+}
+
+static unsigned int mem_notify_poll(struct file *file, poll_table *wait)
+{
+	struct mem_notify_file_info *info = file->private_data;
+	unsigned long now = jiffies;
+	unsigned long timeout;
+	unsigned int retval = 0;
+	unsigned long guard_time;
+
+	poll_wait_exclusive(file, &mem_wait, wait);
+
+	guard_time = min_t(unsigned long,
+			   MEM_NOTIFY_FREQ * atomic_read(&nr_watcher_task),
+			   MAX_PROC_WAKEUP_GUARD);
+	timeout = info->last_proc_notify + guard_time;
+	if (time_before(now, timeout))
+		goto out;
+
+	if (atomic_long_read(&nr_under_memory_pressure_zones) != 0) {
+		info->last_proc_notify = now;
+		retval = POLLIN;
+	}
+
+out:
+	return retval;
+}
+
+struct file_operations mem_notify_fops = {
+	.open = mem_notify_open,
+	.release = mem_notify_release,
+	.poll = mem_notify_poll,
+};
+EXPORT_SYMBOL(mem_notify_fops);
Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c	2008-02-03 20:59:43.000000000 +0900
+++ b/mm/page_alloc.c	2008-02-03 21:01:43.000000000 +0900
@@ -3458,6 +3458,7 @@ static void __meminit free_area_init_cor
 		zone->zone_pgdat = pgdat;

 		zone->prev_priority = DEF_PRIORITY;
+		zone->mem_notify_status = 0;

 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
Index: b/Documentation/devices.txt
===================================================================
--- a/Documentation/devices.txt	2008-02-03 20:59:43.000000000 +0900
+++ b/Documentation/devices.txt	2008-02-03 20:59:46.000000000 +0900
@@ -96,6 +96,7 @@ Your cooperation is appreciated.
 		 11 = /dev/kmsg		Writes to this come out as printk's
 		 12 = /dev/oldmem	Used by crashdump kernels to access
 					the memory of the kernel that crashed.
+		 13 = /dev/mem_notify   Low memory notification.

   1 block	RAM disk
 		  0 = /dev/ram0		First RAM disk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
