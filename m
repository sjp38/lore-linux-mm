Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 716AC6B02FD
	for <linux-mm@kvack.org>; Mon, 19 Jun 2017 19:28:50 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id h21so114767083pfk.13
        for <linux-mm@kvack.org>; Mon, 19 Jun 2017 16:28:50 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id y40si1832313pla.629.2017.06.19.16.28.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Jun 2017 16:28:49 -0700 (PDT)
From: Dennis Zhou <dennisz@fb.com>
Subject: [PATCH 4/4] percpu: add tracepoint support for percpu memory
Date: Mon, 19 Jun 2017 19:28:32 -0400
Message-ID: <20170619232832.27116-5-dennisz@fb.com>
In-Reply-To: <20170619232832.27116-1-dennisz@fb.com>
References: <20170619232832.27116-1-dennisz@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com, Dennis Zhou <dennisz@fb.com>

Add support for tracepoints to the following events: chunk allocation,
chunk free, area allocation, area free, and area allocation failure.
This should let us replay percpu memory requests and evaluate
corresponding decisions.

Signed-off-by: Dennis Zhou <dennisz@fb.com>
---
 include/trace/events/percpu.h | 125 ++++++++++++++++++++++++++++++++++++++++++
 mm/percpu-km.c                |   2 +
 mm/percpu-vm.c                |   2 +
 mm/percpu.c                   |  12 ++++
 4 files changed, 141 insertions(+)
 create mode 100644 include/trace/events/percpu.h

diff --git a/include/trace/events/percpu.h b/include/trace/events/percpu.h
new file mode 100644
index 0000000..ad34b1b
--- /dev/null
+++ b/include/trace/events/percpu.h
@@ -0,0 +1,125 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM percpu
+
+#if !defined(_TRACE_PERCPU_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_PERCPU_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(percpu_alloc_percpu,
+
+	TP_PROTO(bool reserved, bool is_atomic, size_t size,
+		 size_t align, void *base_addr, int off, void __percpu *ptr),
+
+	TP_ARGS(reserved, is_atomic, size, align, base_addr, off, ptr),
+
+	TP_STRUCT__entry(
+		__field(	bool,			reserved	)
+		__field(	bool,			is_atomic	)
+		__field(	size_t,			size		)
+		__field(	size_t,			align		)
+		__field(	void *,			base_addr	)
+		__field(	int,			off		)
+		__field(	void __percpu *,	ptr		)
+	),
+
+	TP_fast_assign(
+		__entry->reserved	= reserved;
+		__entry->is_atomic	= is_atomic;
+		__entry->size		= size;
+		__entry->align		= align;
+		__entry->base_addr	= base_addr;
+		__entry->off		= off;
+		__entry->ptr		= ptr;
+	),
+
+	TP_printk("reserved=%d is_atomic=%d size=%zu align=%zu base_addr=%p off=%d ptr=%p",
+		  __entry->reserved, __entry->is_atomic,
+		  __entry->size, __entry->align,
+		  __entry->base_addr, __entry->off, __entry->ptr)
+);
+
+TRACE_EVENT(percpu_free_percpu,
+
+	TP_PROTO(void *base_addr, int off, void __percpu *ptr),
+
+	TP_ARGS(base_addr, off, ptr),
+
+	TP_STRUCT__entry(
+		__field(	void *,			base_addr	)
+		__field(	int,			off		)
+		__field(	void __percpu *,	ptr		)
+	),
+
+	TP_fast_assign(
+		__entry->base_addr	= base_addr;
+		__entry->off		= off;
+		__entry->ptr		= ptr;
+	),
+
+	TP_printk("base_addr=%p off=%d ptr=%p",
+		__entry->base_addr, __entry->off, __entry->ptr)
+);
+
+TRACE_EVENT(percpu_alloc_percpu_fail,
+
+	TP_PROTO(bool reserved, bool is_atomic, size_t size, size_t align),
+
+	TP_ARGS(reserved, is_atomic, size, align),
+
+	TP_STRUCT__entry(
+		__field(	bool,	reserved	)
+		__field(	bool,	is_atomic	)
+		__field(	size_t,	size		)
+		__field(	size_t, align		)
+	),
+
+	TP_fast_assign(
+		__entry->reserved	= reserved;
+		__entry->is_atomic	= is_atomic;
+		__entry->size		= size;
+		__entry->align		= align;
+	),
+
+	TP_printk("reserved=%d is_atomic=%d size=%zu align=%zu",
+		  __entry->reserved, __entry->is_atomic,
+		  __entry->size, __entry->align)
+);
+
+TRACE_EVENT(percpu_create_chunk,
+
+	TP_PROTO(void *base_addr),
+
+	TP_ARGS(base_addr),
+
+	TP_STRUCT__entry(
+		__field(	void *, base_addr	)
+	),
+
+	TP_fast_assign(
+		__entry->base_addr	= base_addr;
+	),
+
+	TP_printk("base_addr=%p", __entry->base_addr)
+);
+
+TRACE_EVENT(percpu_destroy_chunk,
+
+	TP_PROTO(void *base_addr),
+
+	TP_ARGS(base_addr),
+
+	TP_STRUCT__entry(
+		__field(	void *,	base_addr	)
+	),
+
+	TP_fast_assign(
+		__entry->base_addr	= base_addr;
+	),
+
+	TP_printk("base_addr=%p", __entry->base_addr)
+);
+
+#endif /* _TRACE_PERCPU_H */
+
+#include <trace/define_trace.h>
diff --git a/mm/percpu-km.c b/mm/percpu-km.c
index 3bbfa0c..2b79e43 100644
--- a/mm/percpu-km.c
+++ b/mm/percpu-km.c
@@ -73,6 +73,7 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 	spin_unlock_irq(&pcpu_lock);
 
 	pcpu_stats_chunk_alloc();
+	trace_percpu_create_chunk(chunk->base_addr);
 
 	return chunk;
 }
@@ -82,6 +83,7 @@ static void pcpu_destroy_chunk(struct pcpu_chunk *chunk)
 	const int nr_pages = pcpu_group_sizes[0] >> PAGE_SHIFT;
 
 	pcpu_stats_chunk_dealloc();
+	trace_percpu_destroy_chunk(chunk->base_addr);
 
 	if (chunk && chunk->data)
 		__free_pages(chunk->data, order_base_2(nr_pages));
diff --git a/mm/percpu-vm.c b/mm/percpu-vm.c
index 5915a22..7ad9d94 100644
--- a/mm/percpu-vm.c
+++ b/mm/percpu-vm.c
@@ -345,6 +345,7 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 	chunk->base_addr = vms[0]->addr - pcpu_group_offsets[0];
 
 	pcpu_stats_chunk_alloc();
+	trace_percpu_create_chunk(chunk->base_addr);
 
 	return chunk;
 }
@@ -352,6 +353,7 @@ static struct pcpu_chunk *pcpu_create_chunk(void)
 static void pcpu_destroy_chunk(struct pcpu_chunk *chunk)
 {
 	pcpu_stats_chunk_dealloc();
+	trace_percpu_destroy_chunk(chunk->base_addr);
 
 	if (chunk && chunk->data)
 		pcpu_free_vm_areas(chunk->data, pcpu_nr_groups);
diff --git a/mm/percpu.c b/mm/percpu.c
index 25b4ba5..7a1707a 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -76,6 +76,9 @@
 #include <asm/tlbflush.h>
 #include <asm/io.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/percpu.h>
+
 #include "percpu-internal.h"
 
 #define PCPU_SLOT_BASE_SHIFT		5	/* 1-31 shares the same slot */
@@ -1015,11 +1018,17 @@ static void __percpu *pcpu_alloc(size_t size, size_t align, bool reserved,
 
 	ptr = __addr_to_pcpu_ptr(chunk->base_addr + off);
 	kmemleak_alloc_percpu(ptr, size, gfp);
+
+	trace_percpu_alloc_percpu(reserved, is_atomic, size, align,
+			chunk->base_addr, off, ptr);
+
 	return ptr;
 
 fail_unlock:
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 fail:
+	trace_percpu_alloc_percpu_fail(reserved, is_atomic, size, align);
+
 	if (!is_atomic && warn_limit) {
 		pr_warn("allocation failed, size=%zu align=%zu atomic=%d, %s\n",
 			size, align, is_atomic, err);
@@ -1269,6 +1278,8 @@ void free_percpu(void __percpu *ptr)
 			}
 	}
 
+	trace_percpu_free_percpu(chunk->base_addr, off, ptr);
+
 	spin_unlock_irqrestore(&pcpu_lock, flags);
 }
 EXPORT_SYMBOL_GPL(free_percpu);
@@ -1719,6 +1730,7 @@ int __init pcpu_setup_first_chunk(const struct pcpu_alloc_info *ai,
 	pcpu_chunk_relocate(pcpu_first_chunk, -1);
 
 	pcpu_stats_chunk_alloc();
+	trace_percpu_create_chunk(base_addr);
 
 	/* we're done */
 	pcpu_base_addr = base_addr;
-- 
2.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
