Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 116976B0279
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 16:49:40 -0400 (EDT)
Received: by mail-pf0-f176.google.com with SMTP id c20so18001774pfc.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:49:40 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id u4si9880114par.185.2016.04.05.13.49.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 13:49:39 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id fe3so17726697pab.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 13:49:39 -0700 (PDT)
Date: Tue, 5 Apr 2016 13:49:36 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 06/10] mm: /proc/sys/vm/stat_refresh to force vmstat update
In-Reply-To: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1604051348010.5965@eggly.anvils>
References: <alpine.LSU.2.11.1604051329480.5965@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andres Lagar-Cavilla <andreslc@google.com>, Yang Shi <yang.shi@linaro.org>, Ning Qu <quning@gmail.com>, Christoph Lameter <cl@linux.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Provide /proc/sys/vm/stat_refresh to force an immediate update of
per-cpu into global vmstats: useful to avoid a sleep(2) or whatever
before checking counts when testing.  Originally added to work around
a bug which left counts stranded indefinitely on a cpu going idle
(an inaccuracy magnified when small below-batch numbers represent
"huge" amounts of memory), but I believe that bug is now fixed:
nonetheless, this is still a useful knob.

Its schedule_on_each_cpu() is probably too expensive just to fold
into reading /proc/meminfo itself: give this mode 0600 to prevent
abuse.  Allow a write or a read to do the same: nothing to read,
but "grep -h Shmem /proc/sys/vm/stat_refresh /proc/meminfo" is
convenient.  Oh, and since global_page_state() itself is careful
to disguise any underflow as 0, hack in an "Invalid argument" and
pr_warn() if a counter is negative after the refresh - this helped
to fix a misaccounting of NR_ISOLATED_FILE in my migration code.

But on recent kernels, I find that NR_ALLOC_BATCH and NR_PAGES_SCANNED
often go negative some of the time. I have not yet worked out why, but
have no evidence that it's actually harmful.  Punt for the moment by
just ignoring the anomaly on those.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 Documentation/sysctl/vm.txt |   14 ++++++++
 include/linux/vmstat.h      |    4 ++
 kernel/sysctl.c             |    7 ++++
 mm/vmstat.c                 |   58 ++++++++++++++++++++++++++++++++++
 4 files changed, 83 insertions(+)

--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -57,6 +57,7 @@ Currently, these files are in /proc/sys/
 - panic_on_oom
 - percpu_pagelist_fraction
 - stat_interval
+- stat_refresh
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
@@ -754,6 +755,19 @@ is 1 second.
 
 ==============================================================
 
+stat_refresh
+
+Any read or write (by root only) flushes all the per-cpu vm statistics
+into their global totals, for more accurate reports when testing
+e.g. cat /proc/sys/vm/stat_refresh /proc/meminfo
+
+As a side-effect, it also checks for negative totals (elsewhere reported
+as 0) and "fails" with EINVAL if any are found, with a warning in dmesg.
+(At time of writing, a few stats are known sometimes to be found negative,
+with no ill effects: errors and warnings on these stats are suppressed.)
+
+==============================================================
+
 swappiness
 
 This control is used to define how aggressive the kernel will swap
--- a/include/linux/vmstat.h
+++ b/include/linux/vmstat.h
@@ -193,6 +193,10 @@ void quiet_vmstat(void);
 void cpu_vm_stats_fold(int cpu);
 void refresh_zone_stat_thresholds(void);
 
+struct ctl_table;
+int vmstat_refresh(struct ctl_table *, int write,
+		   void __user *buffer, size_t *lenp, loff_t *ppos);
+
 void drain_zonestat(struct zone *zone, struct per_cpu_pageset *);
 
 int calculate_pressure_threshold(struct zone *zone);
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1509,6 +1509,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
+	{
+		.procname	= "stat_refresh",
+		.data		= NULL,
+		.maxlen		= 0,
+		.mode		= 0600,
+		.proc_handler	= vmstat_refresh,
+	},
 #endif
 #ifdef CONFIG_MMU
 	{
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -1378,6 +1378,64 @@ static DEFINE_PER_CPU(struct delayed_wor
 int sysctl_stat_interval __read_mostly = HZ;
 static cpumask_var_t cpu_stat_off;
 
+static void refresh_vm_stats(struct work_struct *work)
+{
+	refresh_cpu_vm_stats(true);
+}
+
+int vmstat_refresh(struct ctl_table *table, int write,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	long val;
+	int err;
+	int i;
+
+	/*
+	 * The regular update, every sysctl_stat_interval, may come later
+	 * than expected: leaving a significant amount in per_cpu buckets.
+	 * This is particularly misleading when checking a quantity of HUGE
+	 * pages, immediately after running a test.  /proc/sys/vm/stat_refresh,
+	 * which can equally be echo'ed to or cat'ted from (by root),
+	 * can be used to update the stats just before reading them.
+	 *
+	 * Oh, and since global_page_state() etc. are so careful to hide
+	 * transiently negative values, report an error here if any of
+	 * the stats is negative, so we know to go looking for imbalance.
+	 */
+	err = schedule_on_each_cpu(refresh_vm_stats);
+	if (err)
+		return err;
+	for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++) {
+		val = atomic_long_read(&vm_stat[i]);
+		if (val < 0) {
+			switch (i) {
+			case NR_ALLOC_BATCH:
+			case NR_PAGES_SCANNED:
+				/*
+				 * These are often seen to go negative in
+				 * recent kernels, but not to go permanently
+				 * negative.  Whilst it would be nicer not to
+				 * have exceptions, rooting them out would be
+				 * another task, of rather low priority.
+				 */
+				break;
+			default:
+				pr_warn("%s: %s %ld\n",
+					__func__, vmstat_text[i], val);
+				err = -EINVAL;
+				break;
+			}
+		}
+	}
+	if (err)
+		return err;
+	if (write)
+		*ppos += *lenp;
+	else
+		*lenp = 0;
+	return 0;
+}
+
 static void vmstat_update(struct work_struct *w)
 {
 	if (refresh_cpu_vm_stats(true)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
