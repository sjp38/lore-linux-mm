Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7F56B02FA
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:28:49 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 13so44961975pgg.8
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:28:49 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id w12si10029841pld.138.2017.06.19.16.28.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:28:47 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 3/4] percpu: expose statistics about percpu memory via debugfs
Date: Mon, 19 Jun 2017 19:28:31 -0400
Message-ID: <20170619232832.27116-4-dennisz@fb.com>
In-Reply-To: <20170619232832.27116-1-dennisz@fb.com>
References: <20170619232832.27116-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Dennis Zhou <dennisz@fb.com>

There is limited visibility into the use of percpu memory leaving us
unable to reason about correctness of parameters and overall use of
percpu memory. These counters and statistics aim to help understand
basic statistics about percpu memory such as number of allocations over
the lifetime, allocation sizes, and fragmentation.

New Config: PERCPU_STATS

Signed-off-by: Dennis Zhou <dennisz@fb.com>
---
 mm/Kconfig           |   8 ++
 mm/Makefile          |   1 +
 mm/percpu-internal.h | 131 ++++++++++++++++++++++++++++++
 mm/percpu-km.c       |   4 +
 mm/percpu-stats.c    | 222 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/percpu-vm.c       |   5 ++
 mm/percpu.c          |   9 +++
 7 files changed, 380 insertions(+)
 create mode 100644 mm/percpu-stats.c

diff --git a/mm/Kconfig b/mm/Kconfig
index beb7a45..8fae426 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -706,3 +706,11 @@ config ARCH_USES_HIGH_VMA_FLAGS
 	bool
 config ARCH_HAS_PKEYS
 	bool
+
+config PERCPU_STATS
+	bool "Collect percpu memory statistics"
+	default n
+	help
+	  This feature collects and exposes statistics via debugfs. The
+	  information includes global and per chunk statistics, which can
+	  be used to help understand percpu memory usage.
diff --git a/mm/Makefile b/mm/Makefile
index 026f6a8..411bd24 100644
--- a/mm/Makefile
+++ b/mm/Makefile
@@ -103,3 +103,4 @@ obj-$(CONFIG_IDLE_PAGE_TRACKING) += page_idle.o
 obj-$(CONFIG_FRAME_VECTOR) += frame_vector.o
 obj-$(CONFIG_DEBUG_PAGE_REF) += debug_page_ref.o
 obj-$(CONFIG_HARDENED_USERCOPY) += usercopy.o
+obj-$(CONFIG_PERCPU_STATS) += percpu-stats.o
diff --git a/mm/percpu-internal.h b/mm/percpu-internal.h
index 8b6cb2a..5509593 100644
--- a/mm/percpu-internal.h
+++ b/mm/percpu-internal.h
@@ -5,6 +5,11 @@
 #include <linux/percpu.h>
 
 struct pcpu_chunk {
+#ifdef CONFIG_PERCPU_STATS
+	int			nr_alloc;	/* # of allocations */
+	size_t			max_alloc_size; /* largest allocation size */
+#endif
+
 	struct list_head	list;		/* linked to pcpu_slot lists */
 	int			free_size;	/* free bytes in the chunk */
 	int			contig_hint;	/* max contiguous size hint */
@@ -18,6 +23,11 @@ struct pcpu_chunk {
 	void			*data;		/* chunk data */
 	int			first_free;	/* no free below this */
 	bool			immutable;	/* no [de]population allowed */
+	bool			has_reserved;	/* Indicates if chunk has reserved space
+						   at the beginning. Reserved chunk will
+						   contain reservation for static chunk.
+						   Dynamic chunk will contain reservation
+						   for static and reserved chunks. */
 	int			nr_populated;	/* # of populated pages */
 	unsigned long		populated[];	/* populated bitmap */
 };
@@ -30,4 +40,125 @@ extern int pcpu_nr_slots __read_mostly;
 extern struct pcpu_chunk *pcpu_first_chunk;
 extern struct pcpu_chunk *pcpu_reserved_chunk;
 
+#ifdef CONFIG_PERCPU_STATS
+
+#include <linux/spinlock.h>
+
+struct percpu_stats {
+	u64 nr_alloc;		/* lifetime # of allocations */
+	u64 nr_dealloc;		/* lifetime # of deallocations */
+	u64 nr_cur_alloc;	/* current # of allocations */
+	u64 nr_max_alloc;	/* max # of live allocations */
+	u32 nr_chunks;		/* current # of live chunks */
+	u32 nr_max_chunks;	/* max # of live chunks */
+	size_t min_alloc_size;	/* min allocaiton size */
+	size_t max_alloc_size;	/* max allocation size */
+};
+
+extern struct percpu_stats pcpu_stats;
+extern struct pcpu_alloc_info pcpu_stats_ai;
+
+/*
+ * For debug purposes. We don't care about the flexible array.
+ */
+static inline void pcpu_stats_save_ai(const struct pcpu_alloc_info *ai)
+{
+	memcpy(&pcpu_stats_ai, ai, sizeof(struct pcpu_alloc_info));
+
+	/* initialize min_alloc_size to unit_size */
+	pcpu_stats.min_alloc_size = pcpu_stats_ai.unit_size;
+}
+
+/*
+ * pcpu_stats_area_alloc - increment area allocation stats
+ * @chunk: the location of the area being allocated
+ * @size: size of area to allocate in bytes
+ *
+ * CONTEXT:
+ * pcpu_lock.
+ */
+static inline void pcpu_stats_area_alloc(struct pcpu_chunk *chunk, size_t size)
+{
+	lockdep_assert_held(&pcpu_lock);
+
+	pcpu_stats.nr_alloc++;
+	pcpu_stats.nr_cur_alloc++;
+	pcpu_stats.nr_max_alloc =
+		max(pcpu_stats.nr_max_alloc, pcpu_stats.nr_cur_alloc);
+	pcpu_stats.min_alloc_size =
+		min(pcpu_stats.min_alloc_size, size);
+	pcpu_stats.max_alloc_size =
+		max(pcpu_stats.max_alloc_size, size);
+
+	chunk->nr_alloc++;
+	chunk->max_alloc_size = max(chunk->max_alloc_size, size);
+}
+
+/*
+ * pcpu_stats_area_dealloc - decrement allocation stats
+ * @chunk: the location of the area being deallocated
+ *
+ * CONTEXT:
+ * pcpu_lock.
+ */
+static inline void pcpu_stats_area_dealloc(struct pcpu_chunk *chunk)
+{
+	lockdep_assert_held(&pcpu_lock);
+
+	pcpu_stats.nr_dealloc++;
+	pcpu_stats.nr_cur_alloc--;
+
+	chunk->nr_alloc--;
+}
+
+/*
+ * pcpu_stats_chunk_alloc - increment chunk stats
+ */
+static inline void pcpu_stats_chunk_alloc(void)
+{
+	spin_lock_irq(&pcpu_lock);
+
+	pcpu_stats.nr_chunks++;
+	pcpu_stats.nr_max_chunks =
+		max(pcpu_stats.nr_max_chunks, pcpu_stats.nr_chunks);
+
+	spin_unlock_irq(&pcpu_lock);
+}
+
+/*
+ * pcpu_stats_chunk_dealloc - decrement chunk stats
+ */
+static inline void pcpu_stats_chunk_dealloc(void)
+{
+	spin_lock_irq(&pcpu_lock);
+
+	pcpu_stats.nr_chunks--;
+
+	spin_unlock_irq(&pcpu_lock);
+}
+
+#else
+
+static inline void pcpu_stats_save_ai(const struct pcpu_alloc_info *ai)
+{
+}
+
+static inline void pcpu_stats_area_alloc(struct pcpu_chunk *chunk, size_t size)
+{
+}
+
+static inline void pcpu_stats_area_dealloc(struct pcpu_chunk *chunk)
+{
+}
+
+static inline void pcpu_stats_chunk_alloc(void)
+{
+}
+
+static inline void pcpu_stats_chunk_dealloc(void)
+{
+}
+
+#endif /* !CONFIG_PERCPU_STATS */
+
 #endif
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index d66911f..3bbfa0c 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -72,6 +72,8 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 	pcpu_chunk_populated(chunk, 0, nr_pages);
 	spin_unlock_irq(&pcpu_lock);
 
+	pcpu_stats_chunk_alloc();
+
 	return chunk;
 }
 
@@ -79,6 +81,8 @@ static void pcpu_destroy_chunk(struct pcpu_chunk *chunk)
 {
 	const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
 
+	pcpu_stats_chunk_dealloc();
+
 	if (chunk && chunk->data)
 		__free_pages(chunk->data, order_base_2(nr_pages));
 	pcpu_free_chunk(chunk);
diff --git a/mm/percpu-stats.c b/mm/percpu-stats.c
new file mode 100644
index 0000000..03524a5
--- /dev/null
+++ b/mm/percpu-stats.c
@@ -0,0 +1,222 @@
+/*
+ * mm/percpu-debug.c
+ *
+ * Copyright (C) 2017		Facebook Inc.
+ * Copyright (C) 2017		Dennis Zhou <dennisz@fb.com>
+ *
+ * This file is released under the GPLv2.
+ *
+ * Prints statistics about the percpu allocator and backing chunks.
+ */
+#include <linux/debugfs.h>
+#include <linux/list.h>
+#include <linux/percpu.h>
+#include <linux/seq_file.h>
+#include <linux/sort.h>
+#include <linux/vmalloc.h>
+
+#include "percpu-internal.h"
+
+#define P(X, Y) \
+	seq_printf(m, "  %-24s: %8lld\n", X, (long long int)Y)
+
+struct percpu_stats pcpu_stats;
+struct pcpu_alloc_info pcpu_stats_ai;
+
+static int cmpint(const void *a, const void *b)
+{
+	return *(int *)a - *(int *)b;
+}
+
+/*
+ * Iterates over all chunks to find the max # of map entries used.
+ */
+static int find_max_map_used(void)
+{
+	struct pcpu_chunk *chunk;
+	int slot, max_map_used;
+
+	max_map_used = 0;
+	for (slot = 0; slot < pcpu_nr_slots; slot++)
+		list_for_each_entry(chunk, &pcpu_slot[slot], list)
+			max_map_used = max(max_map_used, chunk->map_used);
+
+	return max_map_used;
+}
+
+/*
+ * Prints out chunk state. Fragmentation is considered between
+ * the beginning of the chunk to the last allocation.
+ */
+static void chunk_map_stats(struct seq_file *m, struct pcpu_chunk *chunk,
+			    void *buffer)
+{
+	int i, s_index, last_alloc, alloc_sign, as_len;
+	int *alloc_sizes, *p;
+	/* statistics */
+	int sum_frag = 0, max_frag = 0;
+	int cur_min_alloc = 0, cur_med_alloc = 0, cur_max_alloc = 0;
+
+	alloc_sizes = buffer;
+	s_index = chunk->has_reserved ? 1 : 0;
+
+	/* find last allocation */
+	last_alloc = -1;
+	for (i = chunk->map_used - 1; i >= s_index; i--) {
+		if (chunk->map[i] & 1) {
+			last_alloc = i;
+			break;
+		}
+	}
+
+	/* if the chunk is not empty - ignoring reserve */
+	if (last_alloc >= s_index) {
+		as_len = last_alloc + 1 - s_index;
+
+		/*
+		 * Iterate through chunk map computing size info.
+		 * The first bit is overloaded to be a used flag.
+		 * negative = free space, positive = allocated
+		 */
+		for (i = 0, p = chunk->map + s_index; i < as_len; i++, p++) {
+			alloc_sign = (*p & 1) ? 1 : -1;
+			alloc_sizes[i] = alloc_sign *
+				((p[1] & ~1) - (p[0] & ~1));
+		}
+
+		sort(alloc_sizes, as_len, sizeof(chunk->map[0]), cmpint, NULL);
+
+		/* Iterate through the unallocated fragements. */
+		for (i = 0, p = alloc_sizes; *p < 0 && i < as_len; i++, p++) {
+			sum_frag -= *p;
+			max_frag = max(max_frag, -1 * (*p));
+		}
+
+		cur_min_alloc = alloc_sizes[i];
+		cur_med_alloc = alloc_sizes[(i + as_len - 1) / 2];
+		cur_max_alloc = alloc_sizes[as_len - 1];
+	}
+
+	P("nr_alloc", chunk->nr_alloc);
+	P("max_alloc_size", chunk->max_alloc_size);
+	P("free_size", chunk->free_size);
+	P("contig_hint", chunk->contig_hint);
+	P("sum_frag", sum_frag);
+	P("max_frag", max_frag);
+	P("cur_min_alloc", cur_min_alloc);
+	P("cur_med_alloc", cur_med_alloc);
+	P("cur_max_alloc", cur_max_alloc);
+	seq_putc(m, '\n');
+}
+
+static int percpu_stats_show(struct seq_file *m, void *v)
+{
+	struct pcpu_chunk *chunk;
+	int slot, max_map_used;
+	void *buffer;
+
+alloc_buffer:
+	spin_lock_irq(&pcpu_lock);
+	max_map_used = find_max_map_used();
+	spin_unlock_irq(&pcpu_lock);
+
+	buffer = vmalloc(max_map_used * sizeof(pcpu_first_chunk->map[0]));
+	if (!buffer)
+		return -ENOMEM;
+
+	spin_lock_irq(&pcpu_lock);
+
+	/* if the buffer allocated earlier is too small */
+	if (max_map_used < find_max_map_used()) {
+		spin_unlock_irq(&pcpu_lock);
+		vfree(buffer);
+		goto alloc_buffer;
+	}
+
+#define PL(X) \
+	seq_printf(m, "  %-24s: %8lld\n", #X, (long long int)pcpu_stats_ai.X)
+
+	seq_printf(m,
+			"Percpu Memory Statistics\n"
+			"Allocation Info:\n"
+			"----------------------------------------\n");
+	PL(unit_size);
+	PL(static_size);
+	PL(reserved_size);
+	PL(dyn_size);
+	PL(atom_size);
+	PL(alloc_size);
+	seq_putc(m, '\n');
+
+#undef PL
+
+#define PU(X) \
+	seq_printf(m, "  %-18s: %14llu\n", #X, (unsigned long long)pcpu_stats.X)
+
+	seq_printf(m,
+			"Global Stats:\n"
+			"----------------------------------------\n");
+	PU(nr_alloc);
+	PU(nr_dealloc);
+	PU(nr_cur_alloc);
+	PU(nr_max_alloc);
+	PU(nr_chunks);
+	PU(nr_max_chunks);
+	PU(min_alloc_size);
+	PU(max_alloc_size);
+	seq_putc(m, '\n');
+
+#undef PU
+
+	seq_printf(m,
+			"Per Chunk Stats:\n"
+			"----------------------------------------\n");
+
+	if (pcpu_reserved_chunk) {
+		seq_puts(m, "Chunk: <- Reserved Chunk\n");
+		chunk_map_stats(m, pcpu_reserved_chunk, buffer);
+	}
+
+	for (slot = 0; slot < pcpu_nr_slots; slot++) {
+		list_for_each_entry(chunk, &pcpu_slot[slot], list) {
+			if (chunk == pcpu_first_chunk) {
+				seq_puts(m, "Chunk: <- First Chunk\n");
+				chunk_map_stats(m, chunk, buffer);
+
+
+			} else {
+				seq_puts(m, "Chunk:\n");
+				chunk_map_stats(m, chunk, buffer);
+			}
+
+		}
+	}
+
+	spin_unlock_irq(&pcpu_lock);
+
+	vfree(buffer);
+
+	return 0;
+}
+
+static int percpu_stats_open(struct inode *inode, struct file *filp)
+{
+	return single_open(filp, percpu_stats_show, NULL);
+}
+
+static const struct file_operations percpu_stats_fops = {
+	.open		= percpu_stats_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
+static int __init init_percpu_stats_debugfs(void)
+{
+	debugfs_create_file("percpu_stats", 0444, NULL, NULL,
+			&percpu_stats_fops);
+
+	return 0;
+}
+
+late_initcall(init_percpu_stats_debugfs);
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 9ac6394..5915a22 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -343,11 +343,16 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 
 	chunk->data = vms;
 	chunk->base_addr = vms[0]->addr - pcpu_group_offsets[0];
+
+	pcpu_stats_chunk_alloc();
+
 	return chunk;
 }
 
 static void pcpu_destroy_chunk(struct pcpu_chunk *chunk)
 {
+	pcpu_stats_chunk_dealloc();
+
 	if (chunk && chunk->data)
 		pcpu_free_vm_areas(chunk->data, pcpu_nr_groups);
 	pcpu_free_chunk(chunk);
diff --git a/mm/percpu.c b/mm/percpu.c
index 5cf7d73..25b4ba5 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -657,6 +657,7 @@ static void pcpu_free_area(struct pcpu_chunk *chunk, int freeme,
 	int *p;
 
 	lockdep_assert_held(&pcpu_lock);
+	pcpu_stats_area_dealloc(chunk);
 
 	freeme |= 1;	/* we are searching for <given offset, in use> pair */
 
@@ -721,6 +722,7 @@ static struct pcpu_chunk *pcpu_alloc_chunk(void)
 	chunk->map[0] = 0;
 	chunk->map[1] = pcpu_unit_size | 1;
 	chunk->map_used = 1;
+	chunk->has_reserved = false;
 
 	INIT_LIST_HEAD(&chunk->list);
 	INIT_LIST_HEAD(&chunk->map_extend_list);
@@ -970,6 +972,7 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 	goto restart;
 
 area_found:
+	pcpu_stats_area_alloc(chunk, size);
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 
 	/* populate if not all pages are already there */
@@ -1642,6 +1645,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	pcpu_chunk_struct_size = sizeof(struct pcpu_chunk) +
 		BITS_TO_LONGS(pcpu_unit_pages) * sizeof(unsigned long);
 
+	pcpu_stats_save_ai(ai);
+
 	/*
 	 * Allocate chunk slots.  The additional last slot is for
 	 * empty chunks.
@@ -1685,6 +1690,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	if (schunk->free_size)
 		schunk->map[++schunk->map_used] = ai->static_size + schunk->free_size;
 	schunk->map[schunk->map_used] |= 1;
+	schunk->has_reserved = true;
 
 	/* init dynamic chunk if necessary */
 	if (dyn_size) {
@@ -1703,6 +1709,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		dchunk->map[1] = pcpu_reserved_chunk_limit;
 		dchunk->map[2] = (pcpu_reserved_chunk_limit + dchunk->free_size) | 1;
 		dchunk->map_used = 2;
+		dchunk->has_reserved = true;
 	}
 
 	/* link the first chunk in */
@@ -1711,6 +1718,8 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 		pcpu_count_occupied_pages(pcpu_first_chunk, 1);
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
+	pcpu_stats_chunk_alloc();
+
 	/* we're done */
 	pcpu_base_addr = base_addr;
 	return 0;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
