Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1E1A66B0031
	for <linux-mm@kvack.org>; Mon, 18 Nov 2013 19:50:38 -0500 (EST)
Received: by mail-pb0-f42.google.com with SMTP id uo5so7567825pbc.15
        for <linux-mm@kvack.org>; Mon, 18 Nov 2013 16:50:37 -0800 (PST)
Received: from psmtp.com ([74.125.245.107])
        by mx.google.com with SMTP id ob10si10808398pbb.307.2013.11.18.16.50.35
        for <linux-mm@kvack.org>;
        Mon, 18 Nov 2013 16:50:36 -0800 (PST)
From: Andi Kleen <andi@firstfloor.org>
Subject: [PATCH] Expose sysctls for enabling slab/file_cache interleaving
Date: Mon, 18 Nov 2013 16:50:22 -0800
Message-Id: <1384822222-28795-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>

From: Andi Kleen <ak@linux.intel.com>

cpusets has settings per cpu sets to enable NUMA node
interleaving for the slab cache or for the file cache.
These are quite useful, especially the setting for interleaving
the file page cache. This avoids the problem that some
program doing IO fills up a node completely and prevents
other programs from getting local memory. File IO
is often slow enough that the small NUMA differences do
not matter. In some cases doing the same for slab
is also useful.

This was always available using cpusets, but setting up
cpusets just for these two settings was always awkward
and complicated for many system administrators.

Add two sysctls that expose these settings directly.
When the sysctl is set it overrides the default choice
from cpusets. The default is still no interleaving,
so no defaults change.

One of the past SLES version had a sysctl similar
to spread_file_cache (with a different name)

There is basically no new code, we just use the existing
cpuset hooks/code. Right now the sysctls are only
active when cpusets are compiled in, but that
could be easily relaxed by changing a few
ifdefs and move the function to do it outside
cpuset.c

Signed-off-by: Andi Kleen <ak@linux.intel.com>
---
 Documentation/sysctl/vm.txt | 16 ++++++++++++++++
 include/linux/cpuset.h      | 10 ++++++----
 include/linux/mm.h          |  2 ++
 kernel/sysctl.c             | 16 ++++++++++++++++
 mm/memory.c                 |  5 +++++
 5 files changed, 45 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 1fbd4eb..4249fef 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -53,6 +53,8 @@ Currently, these files are in /proc/sys/vm:
 - panic_on_oom
 - percpu_pagelist_fraction
 - stat_interval
+- spread_file_cache
+- spread_slab
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
@@ -680,6 +682,20 @@ is 1 second.
 
 ==============================================================
 
+spread_slab
+
+When not 0 interleave the slab cache over all NUMA nodes, instead of 
+allocating on the current node. Only works for SLAB. Default 0.
+
+==============================================================
+
+spread_file_cache
+
+When not 0 interleave the file cache over all NUMA nodes, instead
+of following the policy of the current process. Default 0.
+
+==============================================================
+
 swappiness
 
 This control is used to define how aggressive the kernel will swap
diff --git a/include/linux/cpuset.h b/include/linux/cpuset.h
index cc1b01c..10966f5 100644
--- a/include/linux/cpuset.h
+++ b/include/linux/cpuset.h
@@ -72,12 +72,14 @@ extern int cpuset_slab_spread_node(void);
 
 static inline int cpuset_do_page_mem_spread(void)
 {
-	return current->flags & PF_SPREAD_PAGE;
+	return (current->flags & PF_SPREAD_PAGE) ||
+		sysctl_spread_file_cache;
 }
 
 static inline int cpuset_do_slab_mem_spread(void)
 {
-	return current->flags & PF_SPREAD_SLAB;
+	return (current->flags & PF_SPREAD_SLAB) || 
+		sysctl_spread_slab;
 }
 
 extern int current_cpuset_is_being_rebound(void);
@@ -195,12 +197,12 @@ static inline int cpuset_slab_spread_node(void)
 
 static inline int cpuset_do_page_mem_spread(void)
 {
-	return 0;
+	return sysctl_spread_file_cache;
 }
 
 static inline int cpuset_do_slab_mem_spread(void)
 {
-	return 0;
+	return sysctl_spread_slab;
 }
 
 static inline int current_cpuset_is_being_rebound(void)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 42a35d9..e26b26a 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1921,5 +1921,7 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+extern int sysctl_spread_slab, sysctl_spread_file_cache;
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index d37d9dd..7995ba6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1375,6 +1375,22 @@ static struct ctl_table vm_table[] = {
 		.extra1		= &zero,
 		.extra2		= &one_hundred,
 	},
+#ifdef CONFIG_CPUSETS
+	{
+		.procname	= "spread_slab",
+		.data		= &sysctl_spread_slab,
+		.maxlen		= sizeof(sysctl_spread_slab),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+	{
+		.procname	= "spread_file_cache",
+		.data		= &sysctl_spread_file_cache,
+		.maxlen		= sizeof(sysctl_spread_file_cache),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec,
+	},
+#endif
 #endif
 #ifdef CONFIG_SMP
 	{
diff --git a/mm/memory.c b/mm/memory.c
index bf86658..b6b8fcb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -69,6 +69,11 @@
 
 #include "internal.h"
 
+#ifdef CONFIG_NUMA
+int __read_mostly sysctl_spread_file_cache;	/* Interleave file cache */ 
+int __read_mostly sysctl_spread_slab;		/* Interleave slab */ 
+#endif
+
 #ifdef LAST_CPUPID_NOT_IN_PAGE_FLAGS
 #warning Unfortunate NUMA and NUMA Balancing config, growing page-frame for last_cpupid.
 #endif
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
