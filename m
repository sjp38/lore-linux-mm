Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f41.google.com (mail-ee0-f41.google.com [74.125.83.41])
	by kanga.kvack.org (Postfix) with ESMTP id DFB4C6B0031
	for <linux-mm@kvack.org>; Tue,  3 Dec 2013 08:33:39 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id t10so1553855eei.28
        for <linux-mm@kvack.org>; Tue, 03 Dec 2013 05:33:39 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e2si19927241eeg.219.2013.12.03.05.33.38
        for <linux-mm@kvack.org>;
        Tue, 03 Dec 2013 05:33:38 -0800 (PST)
Message-ID: <529DDDAF.1000202@redhat.com>
Date: Tue, 03 Dec 2013 14:33:35 +0100
From: Jerome Marchand <jmarchan@redhat.com>
MIME-Version: 1.0
Subject: [PATCH v5] mm: add overcommit_kbytes sysctl variable
References: <1382101019-23563-1-git-send-email-jmarchan@redhat.com> <1382101019-23563-2-git-send-email-jmarchan@redhat.com>
In-Reply-To: <1382101019-23563-2-git-send-email-jmarchan@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, dave.hansen@intel.com, Andrew Morton <akpm@linux-foundation.org>


Changes since v4:
 - revert to my initial overcommit_kbytes design as it is more
 consistent with current *_ratio/*_bytes implementation for other
 variables.

Some applications that run on HPC clusters are designed around the
availability of RAM and the overcommit ratio is fine tuned to get the
maximum usage of memory without swapping. With growing memory, the
1%-of-all-RAM grain provided by overcommit_ratio has become too coarse
for these workload (on a 2TB machine it represents no less than
20GB).

This patch adds the new overcommit_kbytes sysctl variable that allow a
much finer grain.

Signed-of-by: Jerome Marchand <jmarchan@redhat.com>
---
 Documentation/sysctl/vm.txt            |   12 ++++++++++++
 Documentation/vm/overcommit-accounting |    7 ++++---
 include/linux/mm.h                     |    5 +++++
 include/linux/mman.h                   |    1 +
 kernel/sysctl.c                        |   10 +++++++++-
 mm/mmap.c                              |   25 +++++++++++++++++++++++++
 mm/nommu.c                             |    1 +
 mm/util.c                              |   12 ++++++++++--
 8 files changed, 67 insertions(+), 6 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 1fbd4eb..739c21e 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -47,6 +47,7 @@ Currently, these files are in /proc/sys/vm:
 - numa_zonelist_order
 - oom_dump_tasks
 - oom_kill_allocating_task
+- overcommit_kbytes
 - overcommit_memory
 - overcommit_ratio
 - page-cluster
@@ -574,6 +575,17 @@ The default value is 0.
 
 ==============================================================
 
+overcommit_kbytes:
+
+When overcommit_memory is set to 2, the committed address space is not
+permitted to exceed swap plus this amount of physical RAM. See below.
+
+Note: overcommit_kbytes is the counterpart of overcommit_ratio. Only one
+of them may be specified at a time. Setting one disable the other (which
+then appears as 0 when read).
+
+==============================================================
+
 overcommit_memory:
 
 This value contains a flag that enables memory overcommitment.
diff --git a/Documentation/vm/overcommit-accounting b/Documentation/vm/overcommit-accounting
index 8eaa2fc..cbfaaa6 100644
--- a/Documentation/vm/overcommit-accounting
+++ b/Documentation/vm/overcommit-accounting
@@ -14,8 +14,8 @@ The Linux kernel supports the following overcommit handling modes
 
 2	-	Don't overcommit. The total address space commit
 		for the system is not permitted to exceed swap + a
-		configurable percentage (default is 50) of physical RAM.
-		Depending on the percentage you use, in most situations
+		configurable amount (default is 50%) of physical RAM.
+		Depending on the amount you use, in most situations
 		this means a process will not be killed while accessing
 		pages but will receive errors on memory allocation as
 		appropriate.
@@ -26,7 +26,8 @@ The Linux kernel supports the following overcommit handling modes
 
 The overcommit policy is set via the sysctl `vm.overcommit_memory'.
 
-The overcommit percentage is set via `vm.overcommit_ratio'.
+The overcommit amount can be set via `vm.overcommit_ratio' (percentage)
+or `vm.overcommit_kbytes' (absolute value).
 
 The current overcommit limit and amount committed are viewable in
 /proc/meminfo as CommitLimit and Committed_AS respectively.
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 1cedd00..8f17978 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -57,6 +57,11 @@ extern int sysctl_legacy_va_layout;
 extern unsigned long sysctl_user_reserve_kbytes;
 extern unsigned long sysctl_admin_reserve_kbytes;
 
+extern int overcommit_ratio_handler(struct ctl_table *, int, void __user *,
+				    size_t *, loff_t *);
+extern int overcommit_kbytes_handler(struct ctl_table *, int, void __user *,
+				    size_t *, loff_t *);
+
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
 /* to align the pointer to the (next) page boundary */
diff --git a/include/linux/mman.h b/include/linux/mman.h
index 7f7f8da..16373c8 100644
--- a/include/linux/mman.h
+++ b/include/linux/mman.h
@@ -9,6 +9,7 @@
 
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern unsigned long sysctl_overcommit_kbytes;
 extern struct percpu_counter vm_committed_as;
 
 #ifdef CONFIG_SMP
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 34a6047..7877929 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -97,6 +97,7 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern unsigned long sysctl_overcommit_kbytes;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1128,7 +1129,14 @@ static struct ctl_table vm_table[] = {
 		.data		= &sysctl_overcommit_ratio,
 		.maxlen		= sizeof(sysctl_overcommit_ratio),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= overcommit_ratio_handler,
+	},
+	{
+		.procname	= "overcommit_kbytes",
+		.data		= &sysctl_overcommit_kbytes,
+		.maxlen		= sizeof(sysctl_overcommit_kbytes),
+		.mode		= 0644,
+		.proc_handler	= overcommit_kbytes_handler,
 	},
 	{
 		.procname	= "page-cluster", 
diff --git a/mm/mmap.c b/mm/mmap.c
index 834b2d7..b25167d 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -86,6 +86,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
 
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
+unsigned long sysctl_overcommit_kbytes __read_mostly = 0;
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
@@ -95,6 +96,30 @@ unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
  */
 struct percpu_counter vm_committed_as ____cacheline_aligned_in_smp;
 
+int overcommit_ratio_handler(struct ctl_table *table, int write,
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_dointvec(table, write, buffer, lenp, ppos);
+	if (ret == 0 && write)
+		sysctl_overcommit_kbytes = 0;
+	return ret;
+}
+
+int overcommit_kbytes_handler(struct ctl_table *table, int write,
+			     void __user *buffer, size_t *lenp,
+			     loff_t *ppos)
+{
+	int ret;
+
+	ret = proc_doulongvec_minmax(table, write, buffer, lenp, ppos);
+	if (ret == 0 && write)
+		sysctl_overcommit_ratio = 0;
+	return ret;
+}
+
 /*
  * The global memory commitment made in the system can be a metric
  * that can be used to drive ballooning decisions when Linux is hosted
diff --git a/mm/nommu.c b/mm/nommu.c
index fec093a..319ab8f 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -60,6 +60,7 @@ unsigned long highest_memmap_pfn;
 struct percpu_counter vm_committed_as;
 int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50; /* default is 50% */
+unsigned long sysctl_overcommit_kbytes __read_mostly = 0;
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
diff --git a/mm/util.c b/mm/util.c
index f7bc209..73cf802 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -406,8 +406,16 @@ struct address_space *page_mapping(struct page *page)
  */
 unsigned long vm_commit_limit(void)
 {
-	return ((totalram_pages - hugetlb_total_pages())
-		* sysctl_overcommit_ratio / 100) + total_swap_pages;
+	unsigned long allowed;
+
+	if (sysctl_overcommit_kbytes)
+		allowed = sysctl_overcommit_kbytes >> (PAGE_SHIFT - 10);
+	else
+		allowed = ((totalram_pages - hugetlb_total_pages())
+			   * sysctl_overcommit_ratio / 100);
+	allowed += total_swap_pages;
+
+	return allowed;
 }
 
 
-- 
1.7.7.6



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
