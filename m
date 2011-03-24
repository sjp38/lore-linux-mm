Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id B8DAF8D0040
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 05:36:29 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id BDD783EE0BC
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:36:26 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A700F45DE4E
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:36:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 8F4C145DE4D
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:36:26 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 82D621DB803A
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:36:26 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 456431DB802C
	for <linux-mm@kvack.org>; Thu, 24 Mar 2011 18:36:26 +0900 (JST)
Date: Thu, 24 Mar 2011 18:29:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 4/5] forkbomb : periodic flushing mm history information
Message-Id: <20110324182959.ffbc6dd2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
References: <20110324182240.5fe56de2.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "rientjes@google.com" <rientjes@google.com>, Andrey Vagin <avagin@openvz.org>

At 1st, this patch adds a control knob for enable/disable mm_history
tracking.

2nd, at tracking mm's history for forkbomb detection, information of
processes which doesn't seem to be important for fork-bomb detection
is just a noise.

This patch adds a knob for forgetting information with a periodic
check routine.

At every 30secs (can be configured),
 1. check nr_procesess doesn't increase
 2. check kswapd doesn't run
 3. check allocstall doesn't occur.

If all don't happens, clear mm_history which is older than 30secs.

Note: reorder of objects in makefile was required because
      mm_kobj's initcall should be called before oom's...

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 mm/Makefile   |    4 -
 mm/oom_kill.c |  144 +++++++++++++++++++++++++++++++++++++++++++++++++++++++---
 2 files changed, 139 insertions(+), 9 deletions(-)

Index: mm-work2/mm/oom_kill.c
===================================================================
--- mm-work2.orig/mm/oom_kill.c
+++ mm-work2/mm/oom_kill.c
@@ -768,6 +768,7 @@ void pagefault_out_of_memory(void)
 static DEFINE_PER_CPU(unsigned long, pcpu_history_lock);
 static DECLARE_RWSEM(hist_rwsem);
 static int need_global_history_lock;
+static int mm_tracking_enabled = 1;
 
 static void update_history_lock(void)
 {
@@ -841,6 +842,9 @@ void track_mm_history(struct mm_struct *
 {
 	struct mm_history *hist, *phist;
 
+	if (!mm_tracking_enabled)
+		return;
+
 	hist = kmalloc(sizeof(*hist), GFP_KERNEL);
 	if (!hist)
 		return;
@@ -864,19 +868,19 @@ void track_mm_history(struct mm_struct *
 	return;
 }
 
-void delete_mm_history(struct mm_struct *mm)
+static void __delete_mm_history(struct mm_history *hist, bool check_ancestors)
 {
-	struct mm_history *hist, *phist;
+	struct mm_history *phist;
 	bool nochild;
 
-	if (!mm->history)
+	if (!hist)
 		return;
-	update_history_lock();
-	hist = mm->history;
 	spin_lock(&hist->lock);
 	nochild = list_empty(&hist->children);
-	mm->history = NULL;
-	hist->mm = NULL;
+	if (hist->mm) {
+		hist->mm->history = NULL;
+		hist->mm = NULL;
+	}
 	spin_unlock(&hist->lock);
 	/* delete if we have no child */
 	while (nochild && hist != &init_hist) {
@@ -887,8 +891,16 @@ void delete_mm_history(struct mm_struct 
 		nochild = (phist->mm == NULL && list_empty(&phist->children));
 		spin_unlock(&phist->lock);
 		kfree(hist);
+		if (!check_ancestors)
+			break;
 		hist = phist;
 	}
+}
+
+void delete_mm_history(struct mm_struct *mm)
+{
+	update_history_lock();
+	__delete_mm_history(mm->history, true);
 	update_history_unlock();
 }
 
@@ -951,4 +963,122 @@ static struct mm_history *mm_history_sca
 #define for_each_mm_history_safe(pos, tmp)\
 	for_each_mm_history_safe_under((pos), &init_hist, (tmp))
 
+static unsigned long reset_interval_jiffies = 30*HZ;
+unsigned long last_nr_procs;
+unsigned long last_pageout_run;
+unsigned long last_allocstall;
+static void reset_mm_tracking(struct work_struct *w);
+DECLARE_DELAYED_WORK(reset_mm_tracking_work, reset_mm_tracking);
+
+static void reset_mm_tracking(struct work_struct *w)
+{
+	struct mm_history *pos, *tmp;
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
+		scan_history_lock();
+		for_each_mm_history_safe(pos, tmp) {
+			if (time_before(pos->start_time, thresh))
+				__delete_mm_history(pos, false);
+		}
+		scan_history_unlock();
+	}
+	if (mm_tracking_enabled)
+		schedule_delayed_work(&reset_mm_tracking_work,
+			reset_interval_jiffies);
+	return;
+}
+
+#define OOM_ATTR(_name)\
+	static struct kobj_attribute _name##_attr =\
+		__ATTR(_name, 0644, _name##_show, _name##_store)
+
+static ssize_t mm_tracker_reset_interval_msecs_show(struct kobject *obj,
+		struct kobj_attribute *attr, char *buf)
+{
+	return sprintf(buf, "%u", jiffies_to_msecs(reset_interval_jiffies));
+}
+
+static ssize_t mm_tracker_reset_interval_msecs_store(struct kobject *obj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	unsigned long msecs;
+	int err;
+
+	err = strict_strtoul(buf, 10, &msecs);
+	if (err || msecs > UINT_MAX)
+		return -EINVAL;
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
+	if (mm_tracking_enabled
+		&& delayed_work_pending(&reset_mm_tracking_work))
+		schedule_delayed_work(&reset_mm_tracking_work,
+			reset_interval_jiffies);
+
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
+static int __init init_mm_history(void)
+{
+	int err = 0;
+
+#ifdef CONFIG_SYSFS
+	err = sysfs_create_group(mm_kobj, &oom_attr_group);
+	if (err)
+		printk(KERN_ERR
+			"failed to register mm history tracking for oom\n");
+#endif
+	schedule_delayed_work(&reset_mm_tracking_work, reset_interval_jiffies);
+	return 0;
+}
+module_init(init_mm_history);
 #endif
Index: mm-work2/mm/Makefile
===================================================================
--- mm-work2.orig/mm/Makefile
+++ mm-work2/mm/Makefile
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
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
