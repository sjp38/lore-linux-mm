Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id C4A475F0001
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 05:09:47 -0400 (EDT)
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n3K8xdsf022150
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 04:59:39 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n3K99sP4183306
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 05:09:55 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n3K989Cq017208
	for <linux-mm@kvack.org>; Mon, 20 Apr 2009 05:08:09 -0400
From: Eric B Munson <ebmunson@us.ibm.com>
Subject: [PATCH V3] Fix Committed_AS underflow
Date: Mon, 20 Apr 2009 10:09:50 +0100
Message-Id: <1240218590-16714-1-git-send-email-ebmunson@us.ibm.com>
Sender: owner-linux-mm@kvack.org
To: kosaki.motohiro@jp.fujitsu.com
Cc: dave@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, mel@linux.vnet.ibm.com, cl@linux-foundation.org, Eric B Munson <ebmunson@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch makes a small change to an earlier patch by Kosaki Motohiro.
The threshold calculation was changed to avoid the overhead of calculating
the number of online cpus each time the threshold is needed.

As reported by Dave Hansen, the Committed_AS field can underflow in certain
situations:

>         # while true; do cat /proc/meminfo  | grep _AS; sleep 1; done | uniq -c
>               1 Committed_AS: 18446744073709323392 kB
>              11 Committed_AS: 18446744073709455488 kB
>               6 Committed_AS:    35136 kB
>               5 Committed_AS: 18446744073709454400 kB
>               7 Committed_AS:    35904 kB
>               3 Committed_AS: 18446744073709453248 kB
>               2 Committed_AS:    34752 kB
>               9 Committed_AS: 18446744073709453248 kB
>               8 Committed_AS:    34752 kB
>               3 Committed_AS: 18446744073709320960 kB
>               7 Committed_AS: 18446744073709454080 kB
>               3 Committed_AS: 18446744073709320960 kB
>               5 Committed_AS: 18446744073709454080 kB
>               6 Committed_AS: 18446744073709320960 kB

Because NR_CPUS can be greater than 1000 and meminfo_proc_show() does not check
for underflow.

This patch makes two changes:

1. Change NR_CPUS to min(64, NR_CPUS)
   This will limit the amount of possible skew on kernels compiled for very
   large SMP machines.  64 is an arbitrary number selected to limit the worst
   of the skew without using more cache lines.  min(64, NR_CPUS) is used
   instead of nr_online_cpus() because nr_online_cpus() requires a shared
   cache line and a call to hweight to make the calculation.  Its runtime
   overhead and keeping this counter accurate showed up in profiles and it's
   possible that nr_online_cpus() would also show.

2. Add an underflow check to meminfo_proc_show()
   Most fields in /proc/meminfo have an underflow check, Committed_AS should as
   well.  This adds the check.

Reported-by: Dave Hansen <dave@linux.vnet.ibm.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>

---
 fs/proc/meminfo.c |    4 +++-
 mm/swap.c         |    5 +++--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 74ea974..facb9fb 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -22,7 +22,7 @@ void __attribute__((weak)) arch_report_meminfo(struct seq_file *m)
 static int meminfo_proc_show(struct seq_file *m, void *v)
 {
 	struct sysinfo i;
-	unsigned long committed;
+	long committed;
 	unsigned long allowed;
 	struct vmalloc_info vmi;
 	long cached;
@@ -36,6 +36,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	si_meminfo(&i);
 	si_swapinfo(&i);
 	committed = atomic_long_read(&vm_committed_space);
+	if (committed < 0)
+		committed = 0;
 	allowed = ((totalram_pages - hugetlb_total_pages())
 		* sysctl_overcommit_ratio / 100) + total_swap_pages;
 
diff --git a/mm/swap.c b/mm/swap.c
index bede23c..f9a179f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -494,9 +494,10 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 #ifdef CONFIG_SMP
 /*
  * We tolerate a little inaccuracy to avoid ping-ponging the counter between
- * CPUs
+ * CPUs.  64 is an arbitrary constant chosen to limit skew in calculating
+ * Committed_AS without using more cache lines.
  */
-#define ACCT_THRESHOLD	max(16, NR_CPUS * 2)
+#define ACCT_THRESHOLD	max_t(long, 16, min(64, NR_CPUS) * 2)
 
 static DEFINE_PER_CPU(long, committed_space);
 
-- 
1.6.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
