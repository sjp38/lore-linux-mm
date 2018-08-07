Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id EB9326B0005
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 20:59:33 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id a3-v6so6307918pgv.10
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 17:59:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f5-v6sor4111378pff.62.2018.08.06.17.59.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 17:59:32 -0700 (PDT)
From: Dennis Zhou <dennisszhou@gmail.com>
Subject: [PATCH] proc: add percpu populated pages count to meminfo
Date: Mon,  6 Aug 2018 17:56:07 -0700
Message-Id: <20180807005607.53950-1-dennisszhou@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Roman Gushchin <guro@fb.com>
Cc: kernel-team@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

From: "Dennis Zhou (Facebook)" <dennisszhou@gmail.com>

Currently, percpu memory only exposes allocation and utilization
information via debugfs. This more or less is only really useful for
understanding the fragmentation and allocation information at a
per-chunk level with a few global counters. This is also gated behind a
config. BPF and cgroup, for example, have seen an increase use causing
increased use of percpu memory. Let's make it easier for someone to
identify how much memory is being used.

This patch adds the PercpuPopulated stat to meminfo to more easily
look up how much percpu memory is in use. This new number includes the
cost for all backing pages and not just insight at the a unit, per
chunk level. This stat includes only pages used to back the chunks
themselves excluding metadata. I think excluding metadata is fair
because the backing memory scales with the number of cpus and can
quickly outweigh the metadata. It also makes this calculation light.

Signed-off-by: Dennis Zhou <dennisszhou@gmail.com>
---
 fs/proc/meminfo.c      |  2 ++
 include/linux/percpu.h |  2 ++
 mm/percpu.c            | 29 +++++++++++++++++++++++++++++
 3 files changed, 33 insertions(+)

diff --git a/fs/proc/meminfo.c b/fs/proc/meminfo.c
index 2fb04846ed11..ddd5249692e9 100644
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
+	show_val_kb(m, "PercpuPopulated:", pcpu_nr_populated_pages());
 
 #ifdef CONFIG_MEMORY_FAILURE
 	seq_printf(m, "HardwareCorrupted: %5lu kB\n",
diff --git a/include/linux/percpu.h b/include/linux/percpu.h
index 296bbe49d5d1..1c80be42822c 100644
--- a/include/linux/percpu.h
+++ b/include/linux/percpu.h
@@ -149,4 +149,6 @@ extern phys_addr_t per_cpu_ptr_to_phys(void *addr);
 	(typeof(type) __percpu *)__alloc_percpu(sizeof(type),		\
 						__alignof__(type))
 
+extern int pcpu_nr_populated_pages(void);
+
 #endif /* __LINUX_PERCPU_H */
diff --git a/mm/percpu.c b/mm/percpu.c
index 0b6480979ac7..08a4341f30c5 100644
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
+static int pcpu_nr_populated;
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
+ * pcpu_nr_populated_pages - calculate total number of populated backing pages
+ *
+ * This reflects the number of pages populated to back the chunks.
+ * Metadata is excluded in the number exposed in meminfo as the number of
+ * backing pages scales with the number of cpus and can quickly outweigh the
+ * memory used for metadata.  It also keeps this calculation nice and simple.
+ *
+ * RETURNS:
+ * Total number of populated backing pages in use by the allocator.
+ */
+int pcpu_nr_populated_pages(void)
+{
+	return pcpu_nr_populated * pcpu_nr_units;
+}
+
 /*
  * Percpu allocator is initialized early during boot when neither slab or
  * workqueue is available.  Plug async management until everything is up
-- 
2.17.1
