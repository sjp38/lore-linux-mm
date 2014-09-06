Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 0240D6B0037
	for <linux-mm@kvack.org>; Sat,  6 Sep 2014 15:39:40 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id at20so15943985iec.33
        for <linux-mm@kvack.org>; Sat, 06 Sep 2014 12:39:40 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id lq8si5739173igb.35.2014.09.06.12.39.39
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 06 Sep 2014 12:39:39 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 2/3] mm: introduce VM_BUG_ON_MM
Date: Sat,  6 Sep 2014 15:38:45 -0400
Message-Id: <1410032326-4380-2-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1410032326-4380-1-git-send-email-sasha.levin@oracle.com>
References: <1410032326-4380-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: kirill.shutemov@linux.intel.com, khlebnikov@openvz.org, riel@redhat.com, mgorman@suse.de, n-horiguchi@ah.jp.nec.com, mhocko@suse.cz, hughd@google.com, vbabka@suse.cz, walken@google.com, minchan@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Sasha Levin <sasha.levin@oracle.com>

Very similar to VM_BUG_ON_PAGE and VM_BUG_ON_VMA, dump struct_mm
when the bug is hit.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mmdebug.h |   10 +++++++
 mm/debug.c              |   69 +++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 79 insertions(+)

diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 569e4c8..5116d4b 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -5,11 +5,13 @@
 
 struct page;
 struct vm_area_struct;
+struct mm_struct;
 
 extern void dump_page(struct page *page, const char *reason);
 extern void dump_page_badflags(struct page *page, const char *reason,
 			       unsigned long badflags);
 void dump_vma(const struct vm_area_struct *vma);
+void dump_mm(const struct mm_struct *mm);
 
 #ifdef CONFIG_DEBUG_VM
 #define VM_BUG_ON(cond) BUG_ON(cond)
@@ -27,6 +29,13 @@ void dump_vma(const struct vm_area_struct *vma);
 			BUG();						\
 		}							\
 	} while (0)
+#define VM_BUG_ON_MM(cond, mm)						\
+        do {								\
+                if (unlikely(cond)) {					\
+                        dump_mm(mm);					\
+                        BUG();						\
+                }							\
+        } while (0)
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
@@ -34,6 +43,7 @@ void dump_vma(const struct vm_area_struct *vma);
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
 #define VM_BUG_ON_VMA(cond, vma) VM_BUG_ON(cond)
+#define VM_BUG_ON_MM(cond, mm) VM_BUG_ON(cond)
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
diff --git a/mm/debug.c b/mm/debug.c
index c19af12..8418893 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -1,3 +1,10 @@
+/*
+ * mm/debug.c
+ *
+ * mm/ specific debug routines.
+ *
+ */
+
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/ftrace_event.h>
@@ -158,4 +165,66 @@ void dump_vma(const struct vm_area_struct *vma)
 }
 EXPORT_SYMBOL(dump_vma);
 
+void dump_mm(const struct mm_struct *mm)
+{
+	printk(KERN_ALERT
+		"mm %p mmap %p seqnum %d task_size %lu\n"
+#ifdef CONFIG_MMU
+		"get_unmapped_area %p\n"
+#endif
+		"mmap_base %lu mmap_legacy_base %lu highest_vm_end %lu\n"
+		"pgd %p mm_users %d mm_count %d nr_ptes %lu map_count %d\n"
+		"hiwater_rss %lx hiwater_vm %lx total_vm %lx locked_vm %lx\n"
+		"pinned_vm %lx shared_vm %lx exec_vm %lx stack_vm %lx\n"
+		"start_code %lx end_code %lx start_data %lx end_data %lx\n"
+		"start_brk %lx brk %lx start_stack %lx\n"
+		"arg_start %lx arg_end %lx env_start %lx env_end %lx\n"
+		"binfmt %p flags %lx core_state %p\n"
+#ifdef CONFIG_AIO
+		"ioctx_table %p\n"
+#endif
+		"owner %p exe_file %p\n"
+#ifdef CONFIG_MMU_NOTIFIER
+		"mmu_notifier_mm %p\n"
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+		"numa_next_scan %lu numa_scan_offset %lu numa_scan_seq %d\n"
+#endif
+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+		"tlb_flush_pending %d\n",
+#endif
+		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
+#ifdef CONFIG_MMU
+		mm->get_unmapped_area,
+#endif
+		mm->mmap_base, mm->mmap_legacy_base, mm->highest_vm_end,
+		mm->pgd, atomic_read(&mm->mm_users),
+		atomic_read(&mm->mm_count),
+		atomic_long_read((atomic_long_t *)&mm->nr_ptes),
+		mm->map_count,
+		mm->hiwater_rss, mm->hiwater_vm, mm->total_vm, mm->locked_vm,
+		mm->pinned_vm, mm->shared_vm, mm->exec_vm, mm->stack_vm,
+		mm->start_code, mm->end_code, mm->start_data, mm->end_data,
+		mm->start_brk, mm->brk, mm->start_stack,
+		mm->arg_start, mm->arg_end, mm->env_start, mm->env_end,
+		mm->binfmt, mm->flags, mm->core_state,
+#ifdef CONFIG_AIO
+		mm->ioctx_table,
+#endif
+		mm->owner, mm->exe_file,
+#ifdef CONFIG_MMU_NOTIFIER
+		mm->mmu_notifier_mm,
+#endif
+#ifdef CONFIG_NUMA_BALANCING
+		mm->numa_next_scan, mm->numa_scan_offset, mm->numa_scan_seq,
+#endif
+#if defined(CONFIG_NUMA_BALANCING) || defined(CONFIG_COMPACTION)
+		mm->tlb_flush_pending
+#endif
+		);
+
+		dump_flags(mm->def_flags, vmaflags_names,
+				ARRAY_SIZE(vmaflags_names));
+}
+
 #endif		/* CONFIG_DEBUG_VM */
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
