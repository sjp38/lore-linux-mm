Date: Tue, 30 Oct 2007 17:07:43 -0400
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: Re: [RFC] oom notifications via /dev/oom_notify
Message-ID: <20071030210743.GA304@dmt>
References: <20071030191827.GB31038@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20071030191827.GB31038@dmt>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: drepper@redhat.com, riel@redhat.com, akpm@linux-foundation.org, mbligh@mbligh.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, Oct 30, 2007 at 03:18:27PM -0400, Marcelo Tosatti wrote:
> Hi,
> 
> Following patch creates a /dev/oom_notify device which applications can
> select()/poll() to get informed of memory pressure.
> 
> The basic idea here is that applications can be part of the memory
> reclaim process. The notification is loosely defined as "please free
> some small percentage of your memory".
> 
> There is no easy way of finding whether the system is approaching a
> state where swapping is required in the reclaim paths, so a defensive
> approach is taken by using a timer with 1Hz frequency which verifies
> whether swapping has occurred.
> 
> For scenarios which require a "severe pressure notification" (please
> read Nokia's implementation at http://www.linuxjournal.com/article/8502 for
> more details), I believe the best solution is to create a separate
> /dev/oom_notify_critical device to avoid complication of the main device
> code paths. Take into account that such notification needs careful
> synchronization with the OOM killer.
> 
> Comments please...

changes:
- rearm timer (!)
- wake up one thread instead of all in swapout detection
- msecs_to_jiffies(1000) -> HZ

--- linux-2.6.orig/drivers/char/mem.c	2007-10-24 15:52:54.000000000 -0300
+++ linux-2.6/drivers/char/mem.c	2007-10-29 00:22:31.000000000 -0300
@@ -34,6 +34,8 @@
 # include <linux/efi.h>
 #endif
 
+extern struct file_operations oom_notify_fops;
+
 /*
  * Architectures vary in how they handle caching for addresses
  * outside of main memory.
@@ -854,6 +856,9 @@
 			filp->f_op = &oldmem_fops;
 			break;
 #endif
+		case 13:
+			filp->f_op = &oom_notify_fops;
+			break;
 		default:
 			return -ENXIO;
 	}
@@ -886,6 +891,7 @@
 #ifdef CONFIG_CRASH_DUMP
 	{12,"oldmem",    S_IRUSR | S_IWUSR | S_IRGRP, &oldmem_fops},
 #endif
+	{13,"oom_notify", S_IRUGO, &oom_notify_fops},
 };
 
 static struct class *mem_class;
diff -Nur --exclude-from=linux-2.6/Documentation/dontdiff linux-2.6.orig/include/linux/vmstat.h linux-2.6/include/linux/vmstat.h
--- linux-2.6.orig/include/linux/vmstat.h	2007-10-24 15:55:30.000000000 -0300
+++ linux-2.6/include/linux/vmstat.h	2007-10-27 23:28:48.000000000 -0300
@@ -80,6 +80,7 @@
 }
 
 extern void all_vm_events(unsigned long *);
+extern unsigned int sum_vm_event(int);
 #ifdef CONFIG_HOTPLUG
 extern void vm_events_fold_cpu(int cpu);
 #else
diff -Nur --exclude-from=linux-2.6/Documentation/dontdiff linux-2.6.orig/mm/Kconfig linux-2.6/mm/Kconfig
--- linux-2.6.orig/mm/Kconfig	2007-10-24 15:53:02.000000000 -0300
+++ linux-2.6/mm/Kconfig	2007-10-25 13:58:38.000000000 -0300
@@ -170,6 +170,13 @@
 	  example on NUMA systems to put pages nearer to the processors accessing
 	  the page.
 
+config OOM_NOTIFY
+	bool "Memory notification"
+	def_bool n
+	help
+	  This option allows the kernel to notify applications of memory 
+	  shortage.
+
 config RESOURCES_64BIT
 	bool "64 bit Memory and IO resources (EXPERIMENTAL)" if (!64BIT && EXPERIMENTAL)
 	default 64BIT
diff -Nur --exclude-from=linux-2.6/Documentation/dontdiff linux-2.6.orig/mm/Makefile linux-2.6/mm/Makefile
--- linux-2.6.orig/mm/Makefile	2007-10-24 15:53:02.000000000 -0300
+++ linux-2.6/mm/Makefile	2007-10-25 13:54:34.000000000 -0300
@@ -30,4 +30,5 @@
 obj-$(CONFIG_MIGRATION) += migrate.o
 obj-$(CONFIG_SMP) += allocpercpu.o
 obj-$(CONFIG_QUICKLIST) += quicklist.o
+obj-$(CONFIG_OOM_NOTIFY) += oom_notify.o
 
diff -Nur --exclude-from=linux-2.6/Documentation/dontdiff linux-2.6.orig/mm/oom_notify.c linux-2.6/mm/oom_notify.c
--- linux-2.6.orig/mm/oom_notify.c	1969-12-31 21:00:00.000000000 -0300
+++ linux-2.6/mm/oom_notify.c	2007-10-30 16:02:29.000000000 -0300
@@ -0,0 +1,97 @@
+/*
+ * Notify applications of memory pressure via /dev/oom_notify
+ */
+
+#include <linux/module.h>
+#include <linux/fs.h>
+#include <linux/wait.h>
+#include <linux/poll.h>
+#include <linux/timer.h>
+#include <linux/spinlock.h>
+#include <linux/vmstat.h>
+
+static int oom_notify_users = 0;
+static bool oom_notify_status = 0;
+static unsigned int prev_swapped_pages = 0;
+
+static void oom_check_fn(unsigned long);
+
+DECLARE_WAIT_QUEUE_HEAD(oom_wait);
+DEFINE_SPINLOCK(oom_notify_lock);
+static struct timer_list oom_check_timer =
+		TIMER_INITIALIZER(oom_check_fn, 0, 0);
+
+void oom_check_fn(unsigned long unused)
+{
+	bool wake = 0;
+	unsigned int swapped_pages;
+
+	swapped_pages = sum_vm_event(PSWPOUT);
+	if (swapped_pages > prev_swapped_pages)
+		wake = 1;
+	prev_swapped_pages = swapped_pages;
+
+	oom_notify_status = wake;
+
+	if (wake)
+		wake_up(&oom_wait);
+
+	mod_timer(&oom_check_timer, jiffies+HZ);
+	return;
+}
+
+static int oom_notify_open(struct inode *inode, struct file *file)
+{
+	spin_lock(&oom_notify_lock);
+	if (!oom_notify_users) {
+		oom_notify_status = 0;
+		mod_timer(&oom_check_timer, jiffies+HZ);
+	}
+	oom_notify_users++;
+	spin_unlock(&oom_notify_lock);
+
+	return 0;
+}
+
+static int oom_notify_release(struct inode *inode, struct file *file)
+{
+	spin_lock(&oom_notify_lock);
+	oom_notify_users--;
+	if (!oom_notify_users) {
+		del_timer(&oom_check_timer);
+		oom_notify_status = 0;
+	}
+	spin_unlock(&oom_notify_lock);
+
+	return 0;
+}
+
+static unsigned int oom_notify_poll(struct file *file, poll_table *wait)
+{
+	unsigned int val = 0;
+	struct zone *zone;
+	int cz_idx = zone_idx(NODE_DATA(nid)->node_zonelists->zones[0]);
+
+	poll_wait(file, &oom_wait, wait);
+
+	if (oom_notify_status)
+		val = POLLIN;
+
+	for_each_zone(zone) {
+		if (!populated_zone(zone))
+			continue;	
+		if (!zone_watermark_ok(zone, 0, zone->pages_low, cz_idx, 0)) {
+			val = POLLIN;
+			break;
+		}
+	}
+
+	return val;
+}
+
+struct file_operations oom_notify_fops = {
+	.open = oom_notify_open,
+	.release = oom_notify_release,
+	.poll = oom_notify_poll,
+};
+EXPORT_SYMBOL(oom_notify_fops);
diff -Nur --exclude-from=linux-2.6/Documentation/dontdiff linux-2.6.orig/mm/vmstat.c linux-2.6/mm/vmstat.c
--- linux-2.6.orig/mm/vmstat.c	2007-10-24 15:53:02.000000000 -0300
+++ linux-2.6/mm/vmstat.c	2007-10-27 22:45:35.000000000 -0300
@@ -52,6 +52,28 @@
 }
 EXPORT_SYMBOL_GPL(all_vm_events);
 
+unsigned int sum_vm_event(int vm_event)
+{
+	int cpu = 0;
+	int i;
+	unsigned int ret = 0;
+	cpumask_t *cpumask = &cpu_online_map;
+
+	cpu = first_cpu(*cpumask);
+	while (cpu < NR_CPUS) {
+		struct vm_event_state *this = &per_cpu(vm_event_states, cpu);
+
+		cpu = next_cpu(cpu, *cpumask);
+
+		if (cpu < NR_CPUS)
+			prefetch(&per_cpu(vm_event_states, cpu));
+
+		ret += this->event[vm_event];
+	}
+	return ret;
+}
+EXPORT_SYMBOL(sum_vm_event);
+
 #ifdef CONFIG_HOTPLUG
 /*
  * Fold the foreign cpu events into our own.
diff -Nur --exclude-from=linux-2.6/Documentation/dontdiff linux-2.6.orig/include/linux/vmstat.h linux-2.6/include/linux/vmstat.h
--- linux-2.6.orig/include/linux/vmstat.h	2007-10-24 15:55:30.000000000 -0300
+++ linux-2.6/include/linux/vmstat.h	2007-10-27 23:28:48.000000000 -0300
@@ -80,6 +80,7 @@
 }
 
 extern void all_vm_events(unsigned long *);
+extern unsigned int sum_vm_event(int);
 #ifdef CONFIG_HOTPLUG
 extern void vm_events_fold_cpu(int cpu);
 #else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
