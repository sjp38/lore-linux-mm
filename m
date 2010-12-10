Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8676B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 21:49:39 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 2/2] Add per cpuset meminfo
Date: Thu,  9 Dec 2010 18:49:05 -0800
Message-Id: <1291949345-13892-3-git-send-email-yinghan@google.com>
In-Reply-To: <1291949345-13892-1-git-send-email-yinghan@google.com>
References: <1291949345-13892-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This exports accumulated memory information through cpuset.meminfo
for each cpuset. This is a useful extention which userspace program
doesn't have to perform the aggregation itself.

Signed-off-by: Ying Han <yinghan@google.com>
---
 kernel/cpuset.c |  118 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 118 insertions(+), 0 deletions(-)

diff --git a/kernel/cpuset.c b/kernel/cpuset.c
index 51b143e..815c375 100644
--- a/kernel/cpuset.c
+++ b/kernel/cpuset.c
@@ -53,6 +53,7 @@
 #include <linux/time.h>
 #include <linux/backing-dev.h>
 #include <linux/sort.h>
+#include <linux/hugetlb.h>
 
 #include <asm/uaccess.h>
 #include <asm/atomic.h>
@@ -1720,6 +1721,118 @@ static s64 cpuset_read_s64(struct cgroup *cont, struct cftype *cft)
 	return 0;
 }
 
+#define K(x) ((x) << (PAGE_SHIFT - 10))
+static int cpuset_read_meminfo(struct cgroup *cont, struct cftype *cft,
+			       struct seq_file *m)
+{
+	struct cpuset *cs = cgroup_cs(cont);
+	struct sysinfo si_accum;
+	unsigned long *node_info;
+	int nid;
+	NODEMASK_ALLOC(nodemask_t, mask, GFP_KERNEL);
+
+	if (mask == NULL)
+		return -ENOMEM;
+	node_info = kzalloc(sizeof(*node_info) * NR_VM_ZONE_STAT_ITEMS,
+			    GFP_KERNEL);
+	if (node_info == NULL) {
+		NODEMASK_FREE(mask);
+		return -ENOMEM;
+	}
+
+	mutex_lock(&callback_mutex);
+	*mask = cs->mems_allowed;
+	mutex_unlock(&callback_mutex);
+
+	memset(&si_accum, 0, sizeof(si_accum));
+	for_each_node_mask(nid, *mask) {
+		int i;
+		struct sysinfo si_node;
+
+		si_meminfo_node(&si_node, nid);
+		si_accum.totalram += si_node.totalram;
+		si_accum.freeram += si_node.freeram;
+#ifdef CONFIG_HIGHMEM
+		si_accum.totalhigh += si_node.totalhigh;
+		si_accum.freehigh += si_node.freehigh;
+#endif
+
+		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
+			node_info[i] += node_page_state(nid, i);
+	}
+
+	seq_printf(m,
+		   "MemTotal:       %8lu kB\n"
+		   "MemFree:        %8lu kB\n"
+		   "MemUsed:        %8lu kB\n"
+		   "Active:         %8lu kB\n"
+		   "Inactive:       %8lu kB\n"
+		   "Active(anon):   %8lu kB\n"
+		   "Inactive(anon): %8lu kB\n"
+		   "Active(file):   %8lu kB\n"
+		   "Inactive(file): %8lu kB\n"
+		   "Unevictable:    %8lu kB\n"
+		   "Mlock:          %8lu kB\n"
+#ifdef CONFIG_HIGHMEM
+		   "HighTotal:      %8lu kB\n"
+		   "HighFree:       %8lu kB\n"
+		   "LowTotal:       %8lu kB\n"
+		   "LowFree:        %8lu kB\n"
+#endif
+		   "Dirty:          %8lu kB\n"
+		   "Writeback:      %8lu kB\n"
+		   "FilePages:      %8lu kB\n"
+		   "Mapped:         %8lu kB\n"
+		   "AnonPages:      %8lu kB\n"
+		   "Shmem:          %8lu kB\n"
+		   "KernelStack:    %8lu kB\n"
+		   "PageTables:     %8lu kB\n"
+		   "NFS_Unstable:   %8lu kB\n"
+		   "Bounce:         %8lu kB\n"
+		   "WritebackTmp:   %8lu kB\n"
+		   "Slab:           %8lu kB\n"
+		   "SReclaimable:   %8lu kB\n"
+		   "SUnreclaim:     %8lu kB\n",
+		   K(si_accum.totalram),
+		   K(si_accum.freeram),
+		   K(si_accum.totalram - si_accum.freeram),
+		   K(node_info[NR_ACTIVE_ANON] + node_info[NR_ACTIVE_FILE]),
+		   K(node_info[NR_INACTIVE_ANON] +
+			node_info[NR_INACTIVE_FILE]),
+		   K(node_info[NR_ACTIVE_ANON]),
+		   K(node_info[NR_INACTIVE_ANON]),
+		   K(node_info[NR_ACTIVE_FILE]),
+		   K(node_info[NR_INACTIVE_FILE]),
+		   K(node_info[NR_UNEVICTABLE]),
+		   K(node_info[NR_MLOCK]),
+#ifdef CONFIG_HIGHMEM
+		   K(si_accum.totalhigh),
+		   K(si_accum.freehigh),
+		   K(si_accum.totalram - si_accum.totalhigh),
+		   K(si_accum.freeram - si_accum.freehigh),
+#endif
+		   K(node_info[NR_FILE_DIRTY]),
+		   K(node_info[NR_WRITEBACK]),
+		   K(node_info[NR_FILE_PAGES]),
+		   K(node_info[NR_FILE_MAPPED]),
+		   K(node_info[NR_ANON_PAGES]),
+		   K(node_info[NR_SHMEM]),
+			node_info[NR_KERNEL_STACK] * THREAD_SIZE / 1024,
+		   K(node_info[NR_PAGETABLE]),
+		   K(node_info[NR_UNSTABLE_NFS]),
+		   K(node_info[NR_BOUNCE]),
+		   K(node_info[NR_WRITEBACK_TEMP]),
+		   K(node_info[NR_SLAB_RECLAIMABLE] +
+			node_info[NR_SLAB_UNRECLAIMABLE]),
+		   K(node_info[NR_SLAB_RECLAIMABLE]),
+		   K(node_info[NR_SLAB_UNRECLAIMABLE]));
+	hugetlb_report_nodemask_meminfo(mask, m);
+
+	kfree(node_info);
+	NODEMASK_FREE(mask);
+
+	return 0;
+}
 
 /*
  * for the common functions, 'private' gives the type of file
@@ -1805,6 +1918,11 @@ static struct cftype files[] = {
 		.write_u64 = cpuset_write_u64,
 		.private = FILE_SPREAD_SLAB,
 	},
+
+	{
+		.name = "meminfo",
+		.read_seq_string = cpuset_read_meminfo,
+	},
 };
 
 static struct cftype cft_memory_pressure_enabled = {
-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
