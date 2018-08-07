Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 125CD6B000A
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 14:47:45 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id v15-v6so2923570ply.20
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 11:47:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g34-v6sor581234pld.68.2018.08.07.11.47.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 07 Aug 2018 11:47:43 -0700 (PDT)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH v2] proc: add percpu populated pages count to meminfo
Date: Tue,  7 Aug 2018 11:47:23 -0700
Message-Id: <20180807184723.74919-1-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>, Vlastimil Babka <vbabka@suse.cz>
Cc: kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Linux API <linux-api@vger.kernel.org>, "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Currently, percpu memory only exposes allocation and utilization
information via debugfs. This more or less is only really useful for
understanding the fragmentation and allocation information at a
per-chunk level with a few global counters. This is also gated behind a
config. BPF and cgroup, for example, have seen an increase use causing
increased use of percpu memory. Let's make it easier for someone to
identify how much memory is being used.

This patch adds the "Percpu" stat to meminfo to more easily look up how
much percpu memory is in use. This number includes the cost for all
allocated backing pages and not just isnight at the a unit, per chunk
level. Metadata is excluded. I think excluding metadata is fair because
the backing memory scales with the numbere of cpus and can quickly
outweigh the metadata. It also makes this calculation light.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 Documentation/filesystems/proc.txt |  3 +++
 fs/proc/meminfo.c                  |  2 ++
 include/linux/percpu.h             |  2 ++
 mm/percpu.c                        | 29 +++++++++++++++++++++++++++++
 4 files changed, 36 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 520f6a84cf50..490f803be1ec 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -870,6 +870,7 @@ Committed_AS:   100056 kB
 VmallocTotal:   112216 kB
 VmallocUsed:       428 kB
 VmallocChunk:   111088 kB
+Percpu:          62080 kB
 AnonHugePages:   49152 kB
 ShmemHugePages:      0 kB
 ShmemPmdMapped:      0 kB
@@ -959,6 +960,8 @@ Committed_AS: The amount of memory presently allocated on the system.
 VmallocTotal: total size of vmalloc memory area
  VmallocUsed: amount of vmalloc area which is used
 VmallocChunk: largest contiguous block of vmalloc area which is free
+      Percpu: Memory allocated to the percpu allocator used to back percpu
+              allocations. This stat excludes the cost of metadata.
 
 ..............................................................................
 
diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 2fb04846ed11..edda898714eb 100644
--- a/fs/proc/meminfo.c
+++ b/fs/proc/meminfo.c
@@ -7,6 +7,7 @@
 #include <linux/mman.h>
 #include <linux/mmzone.h>
 #include <linux/proc_fs.h>
+#include <linux/percpu.h>
 #include <linux/quicklist.h>
 #include <linux/seq_file.h>
 #include <linux/swap.h>
@@ -121,6 +122,7 @@ static int meminfo_proc_show(struct seq_file *m, void *v)
 		   (unsigned long)VMALLOC_TOTAL >> 10);
 	show_val_kb(m, "VmallocUsed:    ", 0ul);
 	show_val_kb(m, "VmallocChunk:   ", 0ul);
+	show_val_kb(m, "Percpu:         ", pcpu_nr_pages());
 
 #ifdef CONFIG_MEMORY_FAILURE
 	seq_printf(m, "HardwareCorrupted: %5lu kB\n",
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 296bbe49d5d1..70b7123f38c7 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -149,4 +149,6 @@ extern phys_addr_t per_cpu_ptr_to_phys(void *addr);
 	(typeof(type) __percpu *)__alloc_percpu(sizeof(type),		\
 						__alignof__(type))
 
+extern unsigned long pcpu_nr_pages(void);
+
 #endif /* __LINUX_PERCPU_H */
diff --git a/mm/percpu.c b/mm/percpu.c
index 0b6480979ac7..a749d4d96e3e 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -169,6 +169,14 @@ static LIST_HEAD(pcpu_map_extend_chunks);
  */
 int pcpu_nr_empty_pop_pages;
 
+/*
+ * The number of populated pages in use by the allocator, protected by
+ * pcpu_lock.  This number is kept per a unit per chunk (i.e. when a page gets
+ * allocated/deallocated, it is allocated/deallocated in all units of a chunk
+ * and increments/decrements this count by 1).
+ */
+static unsigned long pcpu_nr_populated;
+
 /*
  * Balance work is used to populate or destroy chunks asynchronously.  We
  * try to keep the number of populated free pages between
@@ -1232,6 +1240,7 @@ static void pcpu_chunk_populated(struct pcpu_chunk *chunk, int page_start,
 
 	bitmap_set(chunk->populated, page_start, nr);
 	chunk->nr_populated += nr;
+	pcpu_nr_populated += nr;
 
 	if (!for_alloc) {
 		chunk->nr_empty_pop_pages += nr;
@@ -1260,6 +1269,7 @@ static void pcpu_chunk_depopulated(struct pcpu_chunk *chunk,
 	chunk->nr_populated -= nr;
 	chunk->nr_empty_pop_pages -= nr;
 	pcpu_nr_empty_pop_pages -= nr;
+	pcpu_nr_populated -= nr;
 }
 
 /*
@@ -2176,6 +2186,9 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	pcpu_nr_empty_pop_pages = pcpu_first_chunk->nr_empty_pop_pages;
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
+	/* include all regions of the first chunk */
+	pcpu_nr_populated += PFN_DOWN(size_sum);
+
 	pcpu_stats_chunk_alloc();
 	trace_percpu_create_chunk(base_addr);
 
@@ -2745,6 +2758,22 @@ void __init setup_per_cpu_areas(void)
 
 #endif	/* CONFIG_SMP */
 
+/*
+ * pcpu_nr_pages - calculate total number of populated backing pages
+ *
+ * This reflects the number of pages populated to back chunks.  Metadata is
+ * excluded in the number exposed in meminfo as the number of backing pages
+ * scales with the number of cpus and can quickly outweigh the memory used for
+ * metadata.  It also keeps this calculation nice and simple.
+ *
+ * RETURNS:
+ * Total number of populated backing pages in use by the allocator.
+ */
+unsigned long pcpu_nr_pages(void)
+{
+	return pcpu_nr_populated * pcpu_nr_units;
+}
+
 /*
  * Percpu allocator is initialized early during boot when neither slab or
  * workqueue is available.  Plug async management until everything is up
-- 
2.17.1
