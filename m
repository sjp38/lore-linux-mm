Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id C47746B00D8
	for <linux-mm@kvack.org>; Fri, 30 Nov 2012 12:56:19 -0500 (EST)
Message-ID: <50B8F313.4030707@parallels.com>
Date: Fri, 30 Nov 2012 21:55:31 +0400
From: Pavel Emelyanov <xemul@parallels.com>
MIME-Version: 1.0
Subject: [PATCH 1/2] mm: Mark VMA with VM_TRACE bit
References: <50B8F2F4.6000508@parallels.com>
In-Reply-To: <50B8F2F4.6000508@parallels.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>

When marked, mmu events on this vma will emit an event via
trace-events engine. For now only two events are added --
when the mark is set (on) and when it's unset or the marked
vma is unmapped (off). On fork() the mark is not inherited.

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 fs/proc/task_mmu.c                     |    1 +
 include/linux/mm.h                     |    1 +
 include/trace/events/mmu.h             |   48 ++++++++++++++++++++++++++++++++
 include/uapi/asm-generic/mman-common.h |    2 +
 kernel/fork.c                          |    2 +-
 mm/madvise.c                           |   12 ++++++++
 mm/memory.c                            |    3 ++
 mm/mmap.c                              |    3 ++
 8 files changed, 71 insertions(+), 1 deletions(-)
 create mode 100644 include/trace/events/mmu.h

diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index c0b4a04..3d43343 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -564,6 +564,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
 		[ilog2(VM_HUGEPAGE)]	= "hg",
 		[ilog2(VM_NOHUGEPAGE)]	= "nh",
 		[ilog2(VM_MERGEABLE)]	= "mg",
+		[ilog2(VM_TRACE)]	= "tr",
 	};
 	size_t i;
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcaab4e..c7fad8d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -84,6 +84,7 @@ extern unsigned int kobjsize(const void *objp);
 #define VM_MAYSHARE	0x00000080
 
 #define VM_GROWSDOWN	0x00000100	/* general info on the segment */
+#define VM_TRACE	0x00000200	/* generate trace events */
 #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
 #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
 
diff --git a/include/trace/events/mmu.h b/include/trace/events/mmu.h
new file mode 100644
index 0000000..71b1ba6
--- /dev/null
+++ b/include/trace/events/mmu.h
@@ -0,0 +1,48 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mmu
+
+#if !defined(_TRACE_MMU_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MMU_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT_CONDITION(mmu_trace_on,
+		TP_PROTO(struct vm_area_struct *vma),
+
+		TP_ARGS(vma),
+
+		TP_CONDITION(!(vma->vm_flags & VM_TRACE)),
+
+		TP_STRUCT__entry(
+			__field(unsigned long, start)
+		),
+
+		TP_fast_assign(
+			__entry->start = vma->vm_start;
+		),
+
+		TP_printk("start %#lx", __entry->start)
+);
+
+TRACE_EVENT_CONDITION(mmu_trace_off,
+		TP_PROTO(struct vm_area_struct *vma),
+
+		TP_ARGS(vma),
+
+		TP_CONDITION(vma->vm_flags & VM_TRACE),
+
+		TP_STRUCT__entry(
+			__field(unsigned long, start)
+		),
+
+		TP_fast_assign(
+			__entry->start = vma->vm_start;
+		),
+
+		TP_printk("start %#lx", __entry->start)
+);
+
+#endif /* _TRACE_MMU_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index d030d2c..c2b633d 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -51,6 +51,8 @@
 #define MADV_DONTDUMP   16		/* Explicity exclude from the core dump,
 					   overrides the coredump filter bits */
 #define MADV_DODUMP	17		/* Clear the MADV_NODUMP flag */
+#define MADV_DOTRACE	18		/* generate mmu: trace events */
+#define MADV_DONTTRACE	19		/* stop generating events */
 
 /* compatibility flags */
 #define MAP_FILE	0
diff --git a/kernel/fork.c b/kernel/fork.c
index 8b20ab7..068ec0d 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -408,7 +408,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
 		tmp->vm_mm = mm;
 		if (anon_vma_fork(tmp, mpnt))
 			goto fail_nomem_anon_vma_fork;
-		tmp->vm_flags &= ~VM_LOCKED;
+		tmp->vm_flags &= ~(VM_LOCKED | VM_TRACE);
 		tmp->vm_next = tmp->vm_prev = NULL;
 		file = tmp->vm_file;
 		if (file) {
diff --git a/mm/madvise.c b/mm/madvise.c
index 03dfa5c..65633e9 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -17,6 +17,8 @@
 #include <linux/fs.h>
 #include <linux/file.h>
 
+#include <trace/events/mmu.h>
+
 /*
  * Any behaviour which results in changes to the vma->vm_flags needs to
  * take mmap_sem for writing. Others, which simply traverse vmas, need
@@ -61,6 +63,14 @@ static long madvise_behavior(struct vm_area_struct * vma,
 	case MADV_DONTFORK:
 		new_flags |= VM_DONTCOPY;
 		break;
+	case MADV_DOTRACE:
+		trace_mmu_trace_on(vma);
+		new_flags |= VM_TRACE;
+		break;
+	case MADV_DONTTRACE:
+		trace_mmu_trace_off(vma);
+		new_flags &= ~VM_TRACE;
+		break;
 	case MADV_DOFORK:
 		if (vma->vm_flags & VM_IO) {
 			error = -EINVAL;
@@ -314,6 +324,8 @@ madvise_behavior_valid(int behavior)
 #endif
 	case MADV_DONTDUMP:
 	case MADV_DODUMP:
+	case MADV_DOTRACE:
+	case MADV_DONTTRACE:
 		return 1;
 
 	default:
diff --git a/mm/memory.c b/mm/memory.c
index 221fc9f..a6f5951 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -58,6 +58,9 @@
 #include <linux/elf.h>
 #include <linux/gfp.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/mmu.h>
+
 #include <asm/io.h>
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
diff --git a/mm/mmap.c b/mm/mmap.c
index 9a796c4..29c9e69 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -32,6 +32,8 @@
 #include <linux/khugepaged.h>
 #include <linux/uprobes.h>
 
+#include <trace/events/mmu.h>
+
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlb.h>
@@ -227,6 +229,7 @@ static struct vm_area_struct *remove_vma(struct vm_area_struct *vma)
 		vma->vm_ops->close(vma);
 	if (vma->vm_file)
 		fput(vma->vm_file);
+	trace_mmu_trace_off(vma);
 	mpol_put(vma_policy(vma));
 	kmem_cache_free(vm_area_cachep, vma);
 	return next;
-- 
1.7.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
