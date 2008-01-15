Date: Tue, 15 Jan 2008 10:01:21 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH 3/5] add /dev/mem_notify device
In-Reply-To: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080115092828.116F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080115100029.1178.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com, Marcelo Tosatti <marcelo@kvack.org>, Daniel Spang <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
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

Signed-off-by: Marcelo Tosatti <marcelo@kvack.org>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 drivers/char/mem.c         |    6 ++
 include/linux/mem_notify.h |   41 ++++++++++++++++
 include/linux/mmzone.h     |    1 
 mm/Makefile                |    2 
 mm/mem_notify.c            |  109 +++++++++++++++++++++++++++++++++++++++++++++
 mm/page_alloc.c            |    1 
 6 files changed, 159 insertions(+), 1 deletion(-)

Index: linux-2.6.24-rc6-mm1-memnotify/drivers/char/mem.c
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/drivers/char/mem.c	2008-01-13 16:56:54.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/drivers/char/mem.c	2008-01-13 16:57:10.000000000 +0900
@@ -34,6 +34,8 @@
 # include <linux/efi.h>
 #endif
 
+extern struct file_operations mem_notify_fops;
+
 /*
  * Architectures vary in how they handle caching for addresses
  * outside of main memory.
@@ -854,6 +856,9 @@ static int memory_open(struct inode * in
 			filp->f_op = &oldmem_fops;
 			break;
 #endif
+		case 13:
+			filp->f_op = &mem_notify_fops;
+			break;
 		default:
 			return -ENXIO;
 	}
@@ -886,6 +891,7 @@ static const struct {
 #ifdef CONFIG_CRASH_DUMP
 	{12,"oldmem",    S_IRUSR | S_IWUSR | S_IRGRP, &oldmem_fops},
 #endif
+	{13,"mem_notify", S_IRUGO, &mem_notify_fops},
 };
 
 static struct class *mem_class;
Index: linux-2.6.24-rc6-mm1-memnotify/include/linux/mem_notify.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.24-rc6-mm1-memnotify/include/linux/mem_notify.h	2008-01-13 16:57:10.000000000 +0900
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
+
+extern void __memory_pressure_notify(struct zone *zone, int pressure);
+
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
Index: linux-2.6.24-rc6-mm1-memnotify/include/linux/mmzone.h
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/include/linux/mmzone.h	2008-01-13 16:56:54.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/include/linux/mmzone.h	2008-01-13 16:57:10.000000000 +0900
@@ -283,6 +283,7 @@ struct zone {
 	 */
 	int prev_priority;
 
+	int mem_notify_status;
 
 	ZONE_PADDING(_pad2_)
 	/* Rarely used or read-mostly fields */
Index: linux-2.6.24-rc6-mm1-memnotify/mm/Makefile
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/mm/Makefile	2008-01-13 16:56:54.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/mm/Makefile	2008-01-13 16:57:10.000000000 +0900
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o mem_notify.o $(mmu-y)
 
 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
Index: linux-2.6.24-rc6-mm1-memnotify/mm/mem_notify.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.24-rc6-mm1-memnotify/mm/mem_notify.c	2008-01-13 17:25:39.000000000 +0900
@@ -0,0 +1,109 @@
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
+
+#include <asm/atomic.h>
+
+#define PROC_WAKEUP_GUARD  (10*HZ)
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
+void __memory_pressure_notify(struct zone* zone, int pressure)
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
+		nr_wakeup = max_t(int, atomic_read(&nr_watcher_task)>>4, 100);
+		atomic_long_set(&last_mem_notify, jiffies);
+		wake_up_locked_nr(&mem_wait, nr_wakeup);
+	}
+
+	spin_unlock_irqrestore(&mem_wait.lock, flags);
+}
+
+static int mem_notify_open(struct inode *inode, struct file *file)
+{
+	struct mem_notify_file_info *info;
+	int    err = 0;
+
+	info = kmalloc(sizeof(*info), GFP_KERNEL);
+        if (!info) {
+		err = -ENOMEM;
+		goto out;
+	}
+
+	info->last_proc_notify = INITIAL_JIFFIES;
+	file->private_data = info;
+	atomic_inc(&nr_watcher_task);
+out:
+        return err;
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
+
+	poll_wait_exclusive(file, &mem_wait, wait);
+
+	timeout = info->last_proc_notify + PROC_WAKEUP_GUARD;
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
Index: linux-2.6.24-rc6-mm1-memnotify/mm/page_alloc.c
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/mm/page_alloc.c	2008-01-13 16:56:54.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/mm/page_alloc.c	2008-01-13 17:25:15.000000000 +0900
@@ -3456,6 +3456,7 @@ static void __meminit free_area_init_cor
 		zone->zone_pgdat = pgdat;
 
 		zone->prev_priority = DEF_PRIORITY;
+		zone->mem_notify_status = 0;
 
 		zone_pcp_init(zone);
 		INIT_LIST_HEAD(&zone->active_list);
Index: linux-2.6.24-rc6-mm1-memnotify/Documentation/devices.txt
===================================================================
--- linux-2.6.24-rc6-mm1-memnotify.orig/Documentation/devices.txt	2008-01-13 16:42:57.000000000 +0900
+++ linux-2.6.24-rc6-mm1-memnotify/Documentation/devices.txt	2008-01-13 17:07:05.000000000 +0900
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
