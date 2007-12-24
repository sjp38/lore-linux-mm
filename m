Date: Mon, 24 Dec 2007 15:32:50 -0500
From: Marcelo Tosatti <marcelo@kvack.org>
Subject: [PATCH] mem notifications v3
Message-ID: <20071224203250.GA23149@dmt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daniel =?iso-8859-1?Q?Sp=E5ng?= <daniel.spang@gmail.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Follows updated version of mem-notify.

This changes the notification point to happen whenever the VM moves an
anonymous page to the inactive list - this is a pretty good indication
that there are unused anonymous pages present which will be very likely
swapped out soon.

Since the notification happens at shrink_zone() which can be called very
often the wakeups are rate limited to 5 times per second (on each CPU).


Index: marcelo/dev/mm/linux-2.6.24-rc2-mm1/Documentation/devices.txt
===================================================================
--- marcelo.orig/dev/mm/linux-2.6.24-rc2-mm1/Documentation/devices.txt
+++ marcelo/dev/mm/linux-2.6.24-rc2-mm1/Documentation/devices.txt
@@ -96,6 +96,7 @@ Your cooperation is appreciated.
 		 11 = /dev/kmsg		Writes to this come out as printk's
 		 12 = /dev/oldmem	Used by crashdump kernels to access
 					the memory of the kernel that crashed.
+		 13 = /dev/mem_notify   Low memory notification.
 
   1 block	RAM disk
 		  0 = /dev/ram0		First RAM disk
Index: marcelo/dev/mm/linux-2.6.24-rc2-mm1/drivers/char/mem.c
===================================================================
--- marcelo.orig/dev/mm/linux-2.6.24-rc2-mm1/drivers/char/mem.c
+++ marcelo/dev/mm/linux-2.6.24-rc2-mm1/drivers/char/mem.c
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
Index: marcelo/dev/mm/linux-2.6.24-rc2-mm1/include/linux/swap.h
===================================================================
--- marcelo.orig/dev/mm/linux-2.6.24-rc2-mm1/include/linux/swap.h
+++ marcelo/dev/mm/linux-2.6.24-rc2-mm1/include/linux/swap.h
@@ -213,6 +213,9 @@ extern int shmem_unuse(swp_entry_t entry
 
 extern void swap_unplug_io_fn(struct backing_dev_info *, struct page *);
 
+/* linux/mm/mem_notify.c */
+void mem_notify_userspace(void);
+
 #ifdef CONFIG_SWAP
 /* linux/mm/page_io.c */
 extern int swap_readpage(struct file *, struct page *);
Index: marcelo/dev/mm/linux-2.6.24-rc2-mm1/mm/Makefile
===================================================================
--- marcelo.orig/dev/mm/linux-2.6.24-rc2-mm1/mm/Makefile
+++ marcelo/dev/mm/linux-2.6.24-rc2-mm1/mm/Makefile
@@ -11,7 +11,7 @@ obj-y			:= bootmem.o filemap.o mempool.o
 			   page_alloc.o page-writeback.o pdflush.o \
 			   readahead.o swap.o truncate.o vmscan.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o $(mmu-y)
+			   page_isolation.o mem_notify.o $(mmu-y)
 
 obj-$(CONFIG_PROC_PAGE_MONITOR) += pagewalk.o
 obj-$(CONFIG_BOUNCE)	+= bounce.o
Index: marcelo/dev/mm/linux-2.6.24-rc2-mm1/mm/mem_notify.c
===================================================================
--- /dev/null
+++ marcelo/dev/mm/linux-2.6.24-rc2-mm1/mm/mem_notify.c
@@ -0,0 +1,80 @@
+/*
+ * Notify applications of memory pressure via /dev/mem_notify
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
+static unsigned long mem_notify_status = 0;
+
+static DECLARE_WAIT_QUEUE_HEAD(mem_wait);
+static DEFINE_PER_CPU(unsigned long, last_mem_notify) = INITIAL_JIFFIES;
+
+/* maximum 5 notifications per second per cpu */
+void mem_notify_userspace(void)
+{
+	unsigned long target;
+	unsigned long now = jiffies;
+
+	target = __get_cpu_var(last_mem_notify) + (HZ/5);
+
+	if (time_after(now, target)) {
+		__get_cpu_var(last_mem_notify) = now;
+		mem_notify_status = 1;
+		wake_up(&mem_wait);
+	}
+}
+
+static int mem_notify_open(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+
+static int mem_notify_release(struct inode *inode, struct file *file)
+{
+	return 0;
+}
+
+static unsigned int mem_notify_poll(struct file *file, poll_table *wait)
+{
+	unsigned int val = 0;
+
+	poll_wait(file, &mem_wait, wait);
+
+	if (mem_notify_status) {
+		struct zone *zone;
+		int pages_high, pages_free, pages_reserve;
+
+		mem_notify_status = 0;
+
+		/* check if its not a spurious/stale notification */
+		pages_high = pages_free = pages_reserve = 0;
+		for_each_zone(zone) { 
+			if (!populated_zone(zone) || is_highmem(zone))
+				continue;
+			pages_high += zone->pages_high;
+			pages_free += zone_page_state(zone, NR_FREE_PAGES);
+			pages_reserve += zone->lowmem_reserve[MAX_NR_ZONES-1];
+		}
+
+		if (pages_free < (pages_high+pages_reserve)*2) 
+			val = POLLIN;
+	}
+		
+	return val;
+}
+
+struct file_operations mem_notify_fops = {
+	.open = mem_notify_open,
+	.release = mem_notify_release,
+	.poll = mem_notify_poll,
+};
+EXPORT_SYMBOL(mem_notify_fops);
Index: marcelo/dev/mm/linux-2.6.24-rc2-mm1/mm/vmscan.c
===================================================================
--- marcelo.orig/dev/mm/linux-2.6.24-rc2-mm1/mm/vmscan.c
+++ marcelo/dev/mm/linux-2.6.24-rc2-mm1/mm/vmscan.c
@@ -960,7 +960,7 @@ static inline int zone_is_near_oom(struc
  * The downside is that we have to touch page->_count against each page.
  * But we had to alter page->flags anyway.
  */
-static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
+static bool shrink_active_list(unsigned long nr_pages, struct zone *zone,
 				struct scan_control *sc, int priority)
 {
 	unsigned long pgmoved;
@@ -972,6 +972,7 @@ static void shrink_active_list(unsigned 
 	struct page *page;
 	struct pagevec pvec;
 	int reclaim_mapped = 0;
+	bool inactivated_anon = 0;
 
 	if (sc->may_swap) {
 		long mapped_ratio;
@@ -1078,6 +1079,13 @@ force_reclaim_mapped:
 			if (!reclaim_mapped ||
 			    (total_swap_pages == 0 && PageAnon(page)) ||
 			    page_referenced(page, 0, sc->mem_cgroup)) {
+				/* deal with the case where there is no 
+ 				 * swap but an anonymous page would be
+ 				 * moved to the inactive list.
+ 				 */
+				if (!total_swap_pages && reclaim_mapped &&
+				    PageAnon(page))
+					inactivated_anon = 1;
 				list_add(&page->lru, &l_active);
 				continue;
 			}
@@ -1085,6 +1093,8 @@ force_reclaim_mapped:
 			list_add(&page->lru, &l_active);
 			continue;
 		}
+		if (PageAnon(page))
+			inactivated_anon = 1;
 		list_add(&page->lru, &l_inactive);
 	}
 
@@ -1146,6 +1156,7 @@ force_reclaim_mapped:
 	spin_unlock_irq(&zone->lru_lock);
 
 	pagevec_release(&pvec);
+	return inactivated_anon;
 }
 
 /*
@@ -1158,6 +1169,7 @@ static unsigned long shrink_zone(int pri
 	unsigned long nr_inactive;
 	unsigned long nr_to_scan;
 	unsigned long nr_reclaimed = 0;
+	bool inactivated_anon = 0;
 
 	/*
 	 * Add one to `nr_to_scan' just to make sure that the kernel will
@@ -1184,7 +1196,8 @@ static unsigned long shrink_zone(int pri
 			nr_to_scan = min(nr_active,
 					(unsigned long)sc->swap_cluster_max);
 			nr_active -= nr_to_scan;
-			shrink_active_list(nr_to_scan, zone, sc, priority);
+			if (shrink_active_list(nr_to_scan, zone, sc, priority))
+				inactivated_anon = 1;
 		}
 
 		if (nr_inactive) {
@@ -1196,6 +1209,9 @@ static unsigned long shrink_zone(int pri
 		}
 	}
 
+	if (inactivated_anon)
+		mem_notify_userspace();
+
 	throttle_vm_writeout(sc->gfp_mask);
 	return nr_reclaimed;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
