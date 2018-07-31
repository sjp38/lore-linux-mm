Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 470436B0266
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 05:07:03 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id u13-v6so2916985pfm.8
        for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:07:03 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y92-v6si8601870plb.378.2018.07.31.02.07.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jul 2018 02:07:01 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 5/6] mm, proc: add KReclaimable to /proc/meminfo
Date: Tue, 31 Jul 2018 11:06:48 +0200
Message-Id: <20180731090649.16028-6-vbabka@suse.cz>
In-Reply-To: <20180731090649.16028-1-vbabka@suse.cz>
References: <20180731090649.16028-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Matthew Wilcox <willy@infradead.org>, Vlastimil Babka <vbabka@suse.cz>

The vmstat NR_KERNEL_MISC_RECLAIMABLE counter is for kernel non-slab
allocations that can be reclaimed via shrinker. In /proc/meminfo, we can show
the sum of all reclaimable kernel allocations (including slab) as
"KReclaimable". Add the same counter also to per-node meminfo under /sys

With this counter, users will have more complete information about
kernel memory usage. Non-slab reclaimable pages (currently just the ION
allocator) will not be missing from /proc/meminfo, making users wonder
where part of their memory went. More precisely, they already appear in
MemAvailable, but without the new counter, it's not obvious why the
value in MemAvailable doesn't fully correspond with the sum of other
counters participating in it.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Roman Gushchin <guro@fb.com>
---
 Documentation/filesystems/proc.txt |  4 ++++
 drivers/base/node.c                | 19 ++++++++++++-------
 fs/proc/meminfo.c                  | 16 ++++++++--------
 3 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 520f6a84cf50..6a255f960ab5 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -858,6 +858,7 @@ Writeback:           0 kB
 AnonPages:      861800 kB
 Mapped:         280372 kB
 Shmem:             644 kB
+KReclaimable:   168048 kB
 Slab:           284364 kB
 SReclaimable:   159856 kB
 SUnreclaim:     124508 kB
@@ -921,6 +922,9 @@ AnonHugePages: Non-file backed huge pages mapped into userspace page tables
 ShmemHugePages: Memory used by shared memory (shmem) and tmpfs allocated
               with huge pages
 ShmemPmdMapped: Shared memory mapped into userspace with huge pages
+KReclaimable: Kernel allocations that the kernel will attempt to reclaim
+              under memory pressure. Includes SReclaimable (below), and other
+              direct allocations with a shrinker.
         Slab: in-kernel data structures cache
 SReclaimable: Part of Slab, that might be reclaimed, such as caches
   SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
diff --git a/drivers/base/node.c b/drivers/base/node.c
index a5e821d09656..81cef8031eae 100644
--- a/drivers/base/node.c
+++ b/drivers/base/node.c
@@ -67,8 +67,11 @@ static ssize_t node_read_meminfo(struct device *dev,
 	int nid = dev->id;
 	struct pglist_data *pgdat = NODE_DATA(nid);
 	struct sysinfo i;
+	unsigned long sreclaimable, sunreclaimable;
 
 	si_meminfo_node(&i, nid);
+	sreclaimable = node_page_state(pgdat, NR_SLAB_RECLAIMABLE);
+	sunreclaimable = node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE);
 	n = sprintf(buf,
 		       "Node %d MemTotal:       %8lu kB\n"
 		       "Node %d MemFree:        %8lu kB\n"
@@ -118,6 +121,7 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       "Node %d NFS_Unstable:   %8lu kB\n"
 		       "Node %d Bounce:         %8lu kB\n"
 		       "Node %d WritebackTmp:   %8lu kB\n"
+		       "Node %d KReclaimable:   %8lu kB\n"
 		       "Node %d Slab:           %8lu kB\n"
 		       "Node %d SReclaimable:   %8lu kB\n"
 		       "Node %d SUnreclaim:     %8lu kB\n"
@@ -138,20 +142,21 @@ static ssize_t node_read_meminfo(struct device *dev,
 		       nid, K(node_page_state(pgdat, NR_UNSTABLE_NFS)),
 		       nid, K(sum_zone_node_page_state(nid, NR_BOUNCE)),
 		       nid, K(node_page_state(pgdat, NR_WRITEBACK_TEMP)),
-		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE) +
-			      node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
-		       nid, K(node_page_state(pgdat, NR_SLAB_RECLAIMABLE)),
+		       nid, K(sreclaimable +
+			      node_page_state(pgdat, NR_KERNEL_MISC_RECLAIMABLE)),
+		       nid, K(sreclaimable + sunreclaimable),
+		       nid, K(sreclaimable),
+		       nid, K(sunreclaimable)
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
-		       nid, K(node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)),
+		       ,
 		       nid, K(node_page_state(pgdat, NR_ANON_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_THPS) *
 				       HPAGE_PMD_NR),
 		       nid, K(node_page_state(pgdat, NR_SHMEM_PMDMAPPED) *
-				       HPAGE_PMD_NR));
-#else
-		       nid, K(node_page_state(pgdat, NR_SLAB_UNRECLAIMABLE)));
+				       HPAGE_PMD_NR)
 #endif
+		       );
 	n += hugetlb_report_node_meminfo(nid, buf + n);
 	return n;
 }
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 2fb04846ed11..61a18477bc07 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -37,6 +37,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	long cached;
 	long available;
 	unsigned long pages[NR_LRU_LISTS];
+	unsigned long sreclaimable, sunreclaim;
 	int lru;
 
 	si_meminfo(&i);
@@ -52,6 +53,8 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		pages[lru] = global_node_page_state(NR_LRU_BASE + lru);
 
 	available = si_mem_available();
+	sreclaimable = global_node_page_state(NR_SLAB_RECLAIMABLE);
+	sunreclaim = global_node_page_state(NR_SLAB_UNRECLAIMABLE);
 
 	show_val_kb(m, "MemTotal:       ", i.totalram);
 	show_val_kb(m, "MemFree:        ", i.freeram);
@@ -93,14 +96,11 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 	show_val_kb(m, "Mapped:         ",
 		    global_node_page_state(NR_FILE_MAPPED));
 	show_val_kb(m, "Shmem:          ", i.sharedram);
-	show_val_kb(m, "Slab:           ",
-		    global_node_page_state(NR_SLAB_RECLAIMABLE) +
-		    global_node_page_state(NR_SLAB_UNRECLAIMABLE));
-
-	show_val_kb(m, "SReclaimable:   ",
-		    global_node_page_state(NR_SLAB_RECLAIMABLE));
-	show_val_kb(m, "SUnreclaim:     ",
-		    global_node_page_state(NR_SLAB_UNRECLAIMABLE));
+	show_val_kb(m, "KReclaimable:   ", sreclaimable +
+		    global_node_page_state(NR_KERNEL_MISC_RECLAIMABLE));
+	show_val_kb(m, "Slab:           ", sreclaimable + sunreclaim);
+	show_val_kb(m, "SReclaimable:   ", sreclaimable);
+	show_val_kb(m, "SUnreclaim:     ", sunreclaim);
 	seq_printf(m, "KernelStack:    %8lu kB\n",
 		   global_zone_page_state(NR_KERNEL_STACK_KB));
 	show_val_kb(m, "PageTables:     ",
-- 
2.18.0
