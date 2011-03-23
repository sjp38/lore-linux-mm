Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 537E58D0040
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 00:35:52 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 783753EE0BC
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:35:48 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5721945DE58
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:35:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 388B845DE5B
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:35:48 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 28A171DB8042
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:35:48 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id DB60DE08001
	for <linux-mm@kvack.org>; Wed, 23 Mar 2011 13:35:47 +0900 (JST)
Date: Wed, 23 Mar 2011 13:29:19 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] forkbomb: forgetting useless information
Message-Id: <20110323132919.bb6929c7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110323132323.f223fc6d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110323132323.f223fc6d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "rientjes@google.com" <rientjes@google.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, avagin@openvz.org, kirill@shutemov.name

This patch adds a control knob for mm_record, forkbomb tracking.

/sys/kernel/mm/oom/mm_record_enable
is for controlling enable/disable tracking of mm_struct.

/sys/kernel/mm/oom/mm_record_reset_interval_msecs
is for controlling aging of mm_record.

enough old mm_records are freed when
 - nr_processes() doesn't increase.
 - no kswapd run.
 - no try_try_free_pages() run.

for 30secs (default).

Note: changes for Makefile is required for initcall for mm_kobj
      should be called befor initcall for oom.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 Documentation/vm/forkbomb.txt |   53 ++++++++++++++
 mm/Makefile                   |    4 -
 mm/oom_kill.c                 |  150 ++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 201 insertions(+), 6 deletions(-)

Index: mm-work/mm/oom_kill.c
===================================================================
--- mm-work.orig/mm/oom_kill.c
+++ mm-work/mm/oom_kill.c
@@ -32,6 +32,7 @@
 #include <linux/mempolicy.h>
 #include <linux/security.h>
 #include <linux/cpu.h>
+#include <linux/sysfs.h>
 
 int sysctl_panic_on_oom;
 int sysctl_oom_kill_allocating_task;
@@ -51,6 +52,7 @@ struct mm_record_info {
 DEFINE_PER_CPU(struct mm_record_info, pcpu_rec_info);
 static DEFINE_MUTEX(oom_rec_scan_mutex);
 static DECLARE_WAIT_QUEUE_HEAD(oom_rec_scan_waitq);
+int mm_tracking_enabled = 1;
 
 /*
  * When running scan, it's better to have lock to disable
@@ -111,6 +113,10 @@ void record_mm(struct mm_struct *new, st
 {
 	struct mm_record *rec, *prec;
 
+	if (!mm_tracking_enabled) {
+		new->record = NULL;
+		return;
+	}
 	rec = kmalloc(sizeof(*rec), GFP_KERNEL);
 	if (!rec) {
 		new->record = NULL;
@@ -138,20 +144,23 @@ void record_mm(struct mm_struct *new, st
 	return;
 }
 
-void del_mm_record(struct mm_struct *mm)
+static void __del_mm_record(struct mm_record *rec, bool scan)
 {
-	struct mm_record *rec = mm->record;
 	bool nochild = false;
+	struct mm_struct *mm;
 
 	if (!rec) /* happens after exec() */
 		return;
-	mm_rec_lock();
+
 	spin_lock(&rec->lock);
+	mm = rec->mm;
 	rec->mm = NULL;
 	if (list_empty(&rec->children))
 		nochild = true;
-	mm->record = NULL;
+	if (mm)
+		mm->record = NULL;
 	spin_unlock(&rec->lock);
+
 	while (nochild && rec != &init_rec) {
 		struct mm_record *prec;
 
@@ -164,12 +173,22 @@ void del_mm_record(struct mm_struct *mm)
 		spin_unlock(&prec->lock);
 		kfree(rec);
 		rec = prec;
+		if (scan)
+			break;
 	}
+}
+
+void del_mm_record(struct mm_struct *mm)
+{
+	mm_rec_lock();
+	__del_mm_record(mm->record, false);
 	mm_rec_unlock();
 }
 
 void mm_record_exec(struct mm_struct *new, struct mm_struct *old)
 {
+	if (!mm_tracking_enabled)
+		return;
 	/*
 	 * This means there is a redundant link at exec because
 	 * "old" will be droppped after this.
@@ -236,6 +255,12 @@ static struct mm_record *mm_record_scan_
 		pos != root;\
 		pos = mm_record_scan_next(pos))
 
+#define for_each_mm_record_safe(pos, tmp)\
+	for (pos = mm_record_scan_start(&init_rec),\
+		tmp = mm_record_scan_next(pos);\
+		pos != &init_rec;\
+		pos = tmp, tmp = mm_record_scan_next(tmp))
+
 #endif
 
 #ifdef CONFIG_NUMA
@@ -962,3 +987,120 @@ void pagefault_out_of_memory(void)
 	if (!test_thread_flag(TIF_MEMDIE))
 		schedule_timeout_uninterruptible(1);
 }
+
+#ifdef CONFIG_FORKBOMB_KILLER
+
+static unsigned long reset_interval_jiffies = 30*HZ;
+unsigned long last_nr_procs;
+unsigned long last_pageout_run;
+unsigned long last_allocstall;
+static void reset_mm_tracking(struct work_struct *w);
+DECLARE_DELAYED_WORK(reset_mm_tracking_work, reset_mm_tracking);
+
+static void reset_mm_tracking(struct work_struct *w)
+{
+	struct mm_record *pos, *tmp;
+	unsigned long nr_procs;
+	unsigned long events[NR_VM_EVENT_ITEMS];
+	bool forget = true;
+
+	nr_procs = nr_processes();
+	if (nr_procs > last_nr_procs)
+		forget = false;
+	last_nr_procs = nr_procs;
+
+	all_vm_events(events);
+	if (last_pageout_run != events[PAGEOUTRUN])
+		forget = false;
+	last_pageout_run = events[PAGEOUTRUN];
+	if (last_allocstall != events[ALLOCSTALL])
+		forget = false;
+	last_allocstall = events[ALLOCSTALL];
+
+	if (forget) {
+		unsigned long thresh = jiffies - reset_interval_jiffies;
+		mm_rec_scan_lock();
+		for_each_mm_record_safe(pos, tmp) {
+			if (time_before(pos->start_time, thresh))
+				__del_mm_record(pos, true);
+		}
+		mm_rec_scan_unlock();
+	}
+	schedule_delayed_work(&reset_mm_tracking_work, reset_interval_jiffies);
+	return;
+}
+
+
+
+#define OOM_ATTR(_name)\
+	static struct kobj_attribute _name##_attr =\
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+
+static ssize_t mm_tracker_reset_interval_msecs_show(struct kobject *obj,
+		struct kobj_attribute *attr, char *buf)
+{
+       	return sprintf(buf, "%u", jiffies_to_msecs(reset_interval_jiffies));
+}
+
+static ssize_t mm_tracker_reset_interval_msecs_store(struct kobject *obj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	unsigned long msecs;
+	int err;
+
+        err = strict_strtoul(buf, 10, &msecs);
+        if (err || msecs > UINT_MAX)
+                return -EINVAL;
+
+	reset_interval_jiffies = msecs_to_jiffies(msecs);
+	return count;
+}
+OOM_ATTR(mm_tracker_reset_interval_msecs);
+
+static ssize_t mm_tracker_enable_show(struct kobject *obj,
+		struct kobj_attribute *attr, char *buf)
+{
+	if (mm_tracking_enabled)
+		return sprintf(buf, "enabled");
+	return sprintf(buf, "disabled");
+}
+
+static ssize_t mm_tracker_enable_store(struct kobject *obj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	if (!memcmp("disable", buf, min(sizeof("disable")-1, count)))
+		mm_tracking_enabled = 0;
+	else if (!memcmp("enable", buf, min(sizeof("enable")-1, count)))
+		mm_tracking_enabled = 1;
+	else
+		return -EINVAL;
+	return count;
+}
+OOM_ATTR(mm_tracker_enable);
+
+static struct attribute *oom_attrs[] = {
+	&mm_tracker_reset_interval_msecs_attr.attr,
+	&mm_tracker_enable_attr.attr,
+	NULL,
+};
+
+static struct attribute_group oom_attr_group = {
+	.attrs = oom_attrs,
+	.name  = "oom",
+};
+
+static int __init init_mm_record(void)
+{
+	int err = 0;
+
+#ifdef CONFIG_SYSFS
+	err = sysfs_create_group(mm_kobj, &oom_attr_group);
+	if (err)
+		printk("failed to register mm history tracking for oom \n");
+#endif
+	schedule_delayed_work(&reset_mm_tracking_work, reset_interval_jiffies);
+	return 0;
+}
+module_init(init_mm_record);
+#endif
Index: mm-work/mm/Makefile
===================================================================
--- mm-work.orig/mm/Makefile
+++ mm-work/mm/Makefile
@@ -7,11 +7,11 @@ mmu-$(CONFIG_MMU)	:= fremap.o highmem.o 
 			   mlock.o mmap.o mprotect.o mremap.o msync.o rmap.o \
 			   vmalloc.o pagewalk.o pgtable-generic.o
 
-obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
+obj-y			:= mm_init.o filemap.o mempool.o oom_kill.o fadvise.o \
 			   maccess.o page_alloc.o page-writeback.o \
 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
-			   page_isolation.o mm_init.o mmu_context.o percpu.o \
+			   page_isolation.o mmu_context.o percpu.o \
 			   $(mmu-y)
 obj-y += init-mm.o
 
Index: mm-work/Documentation/vm/forkbomb.txt
===================================================================
--- /dev/null
+++ mm-work/Documentation/vm/forkbomb.txt
@@ -0,0 +1,53 @@
+mm_record and FORKBOMB_KILLER.
+
+1. Introduction
+
+There are several types of forkbomb. If forkbomb happens, it sometimes
+hard to kill all threads by hand (with pkill or some.) In bad case,
+we cannot catch all process tree image of the forkbomb because parent
+tasks may exit before children. So, killing forkbombs by the kernel
+will be helpful.
+
+(example)
+# forkbomb(){ forkbomb|forkbomb & } ; forkbomb
+
+The kerenl provides a FORKBOMB_KILLER which uses its own task tracking system,
+which can chase tree of dead process.
+
+2. mm_record
+
+mm_record is a TAG to track process-tree. This is allocated when a new
+mm_struct is in_use. This mm_record will creates a tree which is similar
+to process tree.
+
+system's workqueue will remove enough old mm_record when
+  - nr_processes() doesn't seem to be changing.
+  - no alloc stall happens.
+  - no kswapd runs.
+
+So, size of mm_record will be very small in an idle system. Once someone
+starts some work, all new tasks's process tree will be tracked by
+mm_record.
+
+3. forkbomb detection
+
+forkbomb killer will kill processes which is under mm_record which has
+the worst badness score of oom_kill. If number of threads are very small,
+it will be a work for oom-kill rather than forkbomb-killer and forkbomb
+killer will do nothing.
+
+4. controls
+
+/sys/kernel/mm/oom/mm_tracker_enable
+	If enabled, forkbomb killer and mm_tracking will be enabled.
+	Default is enabled.
+
+/sys/kernel/mm/oom/mm_tracker_reset_interval_msecs
+	This is an interface to control aging of mm_records. At each interval
+	specified by this value, system status will be checked and system
+	will forget enough old mm_records. default is 30000 (30sec)
+
+
+
+
+

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
