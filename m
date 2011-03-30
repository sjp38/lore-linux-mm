Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6DCDD8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:17:32 -0400 (EDT)
Subject: [PATCH]mmap: improve scalability for updating vm_committed_as
From: Shaohua Li <shaohua.li@intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 30 Mar 2011 09:17:27 +0800
Message-ID: <1301447847.3981.49.camel@sli10-conroe>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>

In a workload with a lot of mmap/mumap, updating vm_committed_as is
a scalability issue, because the percpu_counter_batch is too small, and
the update needs hold percpu_counter lock.
On the other hand, vm_committed_as is only used in OVERCOMMIT_NEVER case,
which isn't the default setting.
We can make the batch bigger in other cases and then switch to small batch
in OVERCOMMIT_NEVER case, so that we will have no scalability issue with
default setting. We flush all CPUs' percpu counter when switching
sysctl_overcommit_memory, so there is no race the counter is incorrect.

Signed-off-by: Shaohua Li <shaohua.li@intel.com>

---
 fs/proc/meminfo.c    |    2 +-
 include/linux/mman.h |   10 +++++++++-
 kernel/sysctl.c      |    5 ++---
 mm/mmap.c            |   27 +++++++++++++++++++++++++++
 mm/nommu.c           |   27 +++++++++++++++++++++++++++
 5 files changed, 66 insertions(+), 5 deletions(-)

Index: linux/include/linux/mman.h
===================================================================
--- linux.orig/include/linux/mman.h	2011-03-29 16:28:57.000000000 +0800
+++ linux/include/linux/mman.h	2011-03-30 09:01:38.000000000 +0800
@@ -20,9 +20,17 @@ extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern struct percpu_counter vm_committed_as;
 
+extern int overcommit_memory_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *lenp, loff_t *ppos);
 static inline void vm_acct_memory(long pages)
 {
-	percpu_counter_add(&vm_committed_as, pages);
+	/* avoid overflow and the value is big enough */
+	int batch = INT_MAX/2;
+
+	if (sysctl_overcommit_memory == OVERCOMMIT_NEVER)
+		batch = percpu_counter_batch;
+
+	__percpu_counter_add(&vm_committed_as, pages, batch);
 }
 
 static inline void vm_unacct_memory(long pages)
Index: linux/fs/proc/meminfo.c
===================================================================
--- linux.orig/fs/proc/meminfo.c	2011-03-29 16:28:57.000000000 +0800
+++ linux/fs/proc/meminfo.c	2011-03-30 09:01:38.000000000 +0800
@@ -35,7 +35,7 @@ static int meminfo_proc_show(struct seq_
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	si_meminfo(&i);
 	si_swapinfo(&i);
-	committed = percpu_counter_read_positive(&vm_committed_as);
+	committed = percpu_counter_sum_positive(&vm_committed_as);
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
Index: linux/kernel/sysctl.c
===================================================================
--- linux.orig/kernel/sysctl.c	2011-03-29 16:28:57.000000000 +0800
+++ linux/kernel/sysctl.c	2011-03-30 09:01:38.000000000 +0800
@@ -56,6 +56,7 @@
 #include <linux/kprobes.h>
 #include <linux/pipe_fs_i.h>
 #include <linux/oom.h>
+#include <linux/mman.h>
 
 #include <asm/uaccess.h>
 #include <asm/processor.h>
@@ -86,8 +87,6 @@
 #if defined(CONFIG_SYSCTL)
 
 /* External variables not in a header file. */
-extern int sysctl_overcommit_memory;
-extern int sysctl_overcommit_ratio;
 extern int max_threads;
 extern int core_uses_pid;
 extern int suid_dumpable;
@@ -977,7 +976,7 @@ static struct ctl_table vm_table[] = {
 		.data		= &sysctl_overcommit_memory,
 		.maxlen		= sizeof(sysctl_overcommit_memory),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
+		.proc_handler	= overcommit_memory_handler,
 		.extra1		= &zero,
 		.extra2		= &two,
 	},
Index: linux/mm/mmap.c
===================================================================
--- linux.orig/mm/mmap.c	2011-03-30 08:59:23.000000000 +0800
+++ linux/mm/mmap.c	2011-03-30 09:01:38.000000000 +0800
@@ -93,6 +93,33 @@ int sysctl_max_map_count __read_mostly =
  */
 struct percpu_counter vm_committed_as ____cacheline_internodealigned_in_smp;
 
+static void overcommit_drain_counter(struct work_struct *dummy)
+{
+	/*
+	 * Flush percpu counter to global counter when batch is changed, see
+	 * vm_acct_memory for detail
+	 */
+	vm_acct_memory(0);
+}
+
+int overcommit_memory_handler(struct ctl_table *table, int write,
+                void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int error;
+
+	error = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	if (error)
+		return error;
+
+	if (write) {
+		/* Make sure each CPU sees the new sysctl_overcommit_memory */
+		smp_wmb();
+		schedule_on_each_cpu(overcommit_drain_counter);
+	}
+
+	return 0;
+}
+
 /*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to
Index: linux/mm/nommu.c
===================================================================
--- linux.orig/mm/nommu.c	2011-03-29 16:28:57.000000000 +0800
+++ linux/mm/nommu.c	2011-03-30 09:01:38.000000000 +0800
@@ -1859,6 +1859,33 @@ void unmap_mapping_range(struct address_
 }
 EXPORT_SYMBOL(unmap_mapping_range);
 
+static void overcommit_drain_counter(struct work_struct *dummy)
+{
+	/*
+	 * Flush percpu counter to global counter when batch is changed, see
+	 * vm_acct_memory for detail
+	 */
+	vm_acct_memory(0);
+}
+
+int overcommit_memory_handler(struct ctl_table *table, int write,
+                void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int error;
+
+	error = proc_dointvec_minmax(table, write, buffer, lenp, ppos);
+	if (error)
+		return error;
+
+	if (write) {
+		/* Make sure each CPU sees the new sysctl_overcommit_memory */
+		smp_wmb();
+		schedule_on_each_cpu(overcommit_drain_counter);
+	}
+
+	return 0;
+}
+
 /*
  * Check that a process has enough memory to allocate a new virtual
  * mapping. 0 means there is enough memory for the allocation to


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
