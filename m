Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id B8C9A6B0055
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 11:48:31 -0500 (EST)
Received: by mail-ee0-f48.google.com with SMTP id e49so3005142eek.7
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 08:48:31 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s42si5349338eew.245.2013.12.17.08.48.30
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 08:48:31 -0800 (PST)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 6/6] mm: page_alloc: add vm.pagecache_interleave to control default mempolicy for page cache
Date: Tue, 17 Dec 2013 16:48:24 +0000
Message-Id: <1387298904-8824-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1387298904-8824-1-git-send-email-mgorman@suse.de>
References: <1387298904-8824-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This patch introduces a vm.pagecache_interleave sysctl that allows the
administrator to alter the default memory allocation policy for file-backed
pages. It removes a more configurable interface that is expected to be
too complex to expose to users and give an unnecessarily level of control.

By default it is disabled but there is strong evidence that users on NUMA
machines will want to enable this. The default is expected to change
once the documention is in sync. Ideally it would also be possible to
control on a per-process basis by allowing processes to select either an
MPOL_LOCAL or MPOL_INTERLEAVE_PAGECACHE memory policy as memory policies
are the traditional way for controlling allocation behaviour.

Signed-off-by: Mel Gorman <mgorman@suse.de>
---
 Documentation/sysctl/vm.txt | 61 +++++++++++++++++++++------------------------
 include/linux/mmzone.h      |  2 +-
 include/linux/swap.h        |  2 +-
 kernel/sysctl.c             |  8 +++---
 mm/page_alloc.c             | 18 +++++--------
 5 files changed, 41 insertions(+), 50 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 8eaa562..655ed0a 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -49,6 +49,7 @@ Currently, these files are in /proc/sys/vm:
 - oom_kill_allocating_task
 - overcommit_memory
 - overcommit_ratio
+- pagecache_interleave
 - page-cluster
 - panic_on_oom
 - percpu_pagelist_fraction
@@ -56,7 +57,6 @@ Currently, these files are in /proc/sys/vm:
 - swappiness
 - user_reserve_kbytes
 - vfs_cache_pressure
-- zone_distribute_mode
 - zone_reclaim_mode
 
 ==============================================================
@@ -608,6 +608,34 @@ of physical RAM.  See above.
 
 ==============================================================
 
+pagecache_interleave:
+
+This setting is only relevant to NUMA machines.
+
+Historically, the default behaviour of the system is to allocate memory
+local to the process. The behaviour is usually modified through the use
+of memory policies while zone_reclaim_mode controls how strict the local
+memory allocation policy is.
+
+Issues arise when the allocating process is frequently running on the same
+node. The kernels memory reclaim daemon runs one instance per NUMA node.
+A consequence is that relatively new memory may be reclaimed by kswapd when
+the allocating process is running on a specific node. The user-visible
+impact is that the system appears to do more IO than necessary when a
+workload is accessing files that are larger than a given NUMA node.
+
+One way of addressing this is to use the interleave memory policy but that
+is not always possible.
+
+Another option is to enable this setting. When enabled, the default
+memory allocation changes from MPOL_LOCAL to interleaving file-backed
+pages by default. The downside is that some file accesses will now be
+to remote memory even though the local node had available resources.
+The upside is that workloads working on files larger than a NUMA node
+will not reclaim active pages prematurely.
+
+==============================================================
+
 page-cluster
 
 page-cluster controls the number of pages up to which consecutive pages
@@ -725,37 +753,6 @@ causes the kernel to prefer to reclaim dentries and inodes.
 
 ==============================================================
 
-zone_distribute_mode
-
-Pages allocation and reclaim are managed on a per-zone basis. When the
-system needs to reclaim memory, candidate pages are selected from these
-per-zone lists.  Historically, a potential consequence was that recently
-allocated pages were considered reclaim candidates. From a zone-local
-perspective, page aging was preserved but from a system-wide perspective
-there was an age inversion problem.
-
-A similar problem occurs on a node level where young pages may be reclaimed
-from the local node instead of allocating remote memory. Unforuntately, the
-cost of accessing remote nodes is higher so the system must choose by default
-between favouring page aging or node locality. zone_distribute_mode controls
-how the system will distribute page ages between zones.
-
-0	= Never round-robin based on age
-
-Otherwise the values are ORed together
-
-1	= Distribute anon pages between zones local to the allocating node
-2	= Distribute file pages between zones local to the allocating node
-4	= Distribute slab pages between zones local to the allocating node
-
-The following three flags effectively alter MPOL_DEFAULT, be careful.
-
-8	= Distribute anon pages between zones remote to the allocating node
-16	= Distribute file pages between zones remote to the allocating node
-32	= Distribute slab pages between zones remote to the allocating node
-
-==============================================================
-
 zone_reclaim_mode:
 
 Zone_reclaim_mode allows someone to set more or less aggressive approaches to
diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 20a75e3..2fb9e2d 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -897,7 +897,7 @@ int sysctl_min_unmapped_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 int sysctl_min_slab_ratio_sysctl_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
-int sysctl_zone_distribute_mode_handler(struct ctl_table *, int,
+int sysctl_zone_pagecache_interleave_handler(struct ctl_table *, int,
 			void __user *, size_t *, loff_t *);
 
 extern int numa_zonelist_order_handler(struct ctl_table *, int,
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 44329b0..2b522cf 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -318,7 +318,7 @@ extern int vm_swappiness;
 extern int remove_mapping(struct address_space *mapping, struct page *page);
 extern unsigned long vm_total_pages;
 
-extern unsigned __bitwise__ zone_distribute_mode;
+extern unsigned int zone_pagecache_interleave;
 
 #ifdef CONFIG_NUMA
 extern int zone_reclaim_mode;
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index b75c08f..385d7cb 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1350,11 +1350,11 @@ static struct ctl_table vm_table[] = {
 	},
 #endif
 	{
-		.procname	= "zone_distribute_mode",
-		.data		= &zone_distribute_mode,
-		.maxlen		= sizeof(zone_distribute_mode),
+		.procname	= "pagecache_interleave",
+		.data		= &zone_pagecache_interleave,
+		.maxlen		= sizeof(zone_pagecache_interleave),
 		.mode		= 0644,
-		.proc_handler	= sysctl_zone_distribute_mode_handler,
+		.proc_handler	= sysctl_zone_pagecache_interleave_handler,
 		.extra1		= &zero,
 	},
 #ifdef CONFIG_NUMA
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c2a2229..b6c8e63 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1872,7 +1872,8 @@ static inline void init_zone_allows_reclaim(int nid)
 #endif	/* CONFIG_NUMA */
 
 /* Controls how page ages are distributed across zones automatically */
-unsigned __bitwise__ zone_distribute_mode __read_mostly;
+static unsigned __bitwise__ zone_distribute_mode __read_mostly;
+unsigned int zone_pagecache_interleave;
 
 /* See zone_distribute_mode docmentation in Documentation/sysctl/vm.txt */
 #define DISTRIBUTE_DISABLE	(0)
@@ -1891,7 +1892,7 @@ unsigned __bitwise__ zone_distribute_mode __read_mostly;
 /* Only these GFP flags are affected by the fair zone allocation policy */
 #define DISTRIBUTE_GFP_MASK	((GFP_MOVABLE_MASK|__GFP_PAGECACHE))
 
-int sysctl_zone_distribute_mode_handler(ctl_table *table, int write,
+int sysctl_zone_pagecache_interleave_handler(ctl_table *table, int write,
 	void __user *buffer, size_t *length, loff_t *ppos)
 {
 	int rc;
@@ -1900,16 +1901,9 @@ int sysctl_zone_distribute_mode_handler(ctl_table *table, int write,
 	if (rc)
 		return rc;
 
-	/* If you are an admin reading this comment, what were you thinking? */
-	if (WARN_ON_ONCE((zone_distribute_mode & DISTRIBUTE_STUPID_ANON) ==
-							DISTRIBUTE_STUPID_ANON))
-		zone_distribute_mode &= ~DISTRIBUTE_REMOTE_ANON;
-	if (WARN_ON_ONCE((zone_distribute_mode & DISTRIBUTE_STUPID_FILE) ==
-							DISTRIBUTE_STUPID_FILE))
-		zone_distribute_mode &= ~DISTRIBUTE_REMOTE_FILE;
-	if (WARN_ON_ONCE((zone_distribute_mode & DISTRIBUTE_STUPID_SLAB) ==
-							DISTRIBUTE_STUPID_SLAB))
-		zone_distribute_mode &= ~DISTRIBUTE_REMOTE_SLAB;
+	zone_distribute_mode = DISTRIBUTE_LOCAL_ANON|DISTRIBUTE_LOCAL_FILE|DISTRIBUTE_LOCAL_SLAB;
+	if (zone_pagecache_interleave)
+		zone_distribute_mode |= DISTRIBUTE_REMOTE_FILE;
 
 	return 0;
 }
-- 
1.8.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
