Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id ECC0C6B003B
	for <linux-mm@kvack.org>; Mon, 29 Sep 2014 21:54:52 -0400 (EDT)
Received: by mail-ob0-f178.google.com with SMTP id uy5so3263290obc.37
        for <linux-mm@kvack.org>; Mon, 29 Sep 2014 18:54:52 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id kf7si21645782oeb.98.2014.09.29.18.54.50
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 29 Sep 2014 18:54:50 -0700 (PDT)
From: Sasha Levin <sasha.levin@oracle.com>
Subject: [PATCH 3/5] mm: poison mm_struct
Date: Mon, 29 Sep 2014 21:47:17 -0400
Message-Id: <1412041639-23617-4-git-send-email-sasha.levin@oracle.com>
In-Reply-To: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
References: <1412041639-23617-1-git-send-email-sasha.levin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hughd@google.com, mgorman@suse.de, Sasha Levin <sasha.levin@oracle.com>

Add poisoning to mm_struct to catch corruption at either the beginning or the
end of the struct.

Signed-off-by: Sasha Levin <sasha.levin@oracle.com>
---
 include/linux/mm_types.h |  6 ++++++
 include/linux/mmdebug.h  |  8 ++++++++
 kernel/fork.c            | 11 +++++++++++
 mm/debug.c               |  7 +++++++
 mm/mmap.c                |  2 ++
 mm/vmacache.c            |  2 ++
 6 files changed, 36 insertions(+)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 6e0b286..0b0d324 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -343,6 +343,9 @@ struct mm_rss_stat {
 
 struct kioctx_table;
 struct mm_struct {
+#ifdef CONFIG_DEBUG_VM_POISON
+	u32 poison_start;
+#endif
 	struct vm_area_struct *mmap;		/* list of VMAs */
 	struct rb_root mm_rb;
 	u32 vmacache_seqnum;                   /* per-thread vmacache */
@@ -454,6 +457,9 @@ struct mm_struct {
 	bool tlb_flush_pending;
 #endif
 	struct uprobes_state uprobes_state;
+#ifdef CONFIG_DEBUG_VM_POISON
+	u32 poison_end;
+#endif
 };
 
 static inline void mm_init_cpumask(struct mm_struct *mm)
diff --git a/include/linux/mmdebug.h b/include/linux/mmdebug.h
index 7d05557..339e40f 100644
--- a/include/linux/mmdebug.h
+++ b/include/linux/mmdebug.h
@@ -39,6 +39,13 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ON(cond) WARN_ON(cond)
 #define VM_WARN_ON_ONCE(cond) WARN_ON_ONCE(cond)
 #define VM_WARN_ONCE(cond, format...) WARN_ONCE(cond, format)
+#ifdef CONFIG_DEBUG_VM_POISON
+#define VM_CHECK_POISON_MM(mm)						\
+	do {								\
+		VM_BUG_ON_MM((mm)->poison_start != MM_POISON_BEGIN, (mm));\
+		VM_BUG_ON_MM((mm)->poison_end != MM_POISON_END, (mm));	\
+	} while (0)
+#endif
 #else
 #define VM_BUG_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_BUG_ON_PAGE(cond, page) VM_BUG_ON(cond)
@@ -47,6 +54,7 @@ void dump_mm(const struct mm_struct *mm);
 #define VM_WARN_ON(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ON_ONCE(cond) BUILD_BUG_ON_INVALID(cond)
 #define VM_WARN_ONCE(cond, format...) BUILD_BUG_ON_INVALID(cond)
+#define VM_CHECK_POISON_MM(mm) do { } while(0)
 #endif
 
 #ifdef CONFIG_DEBUG_VIRTUAL
diff --git a/kernel/fork.c b/kernel/fork.c
index 807633f..26bedfa 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -600,6 +600,8 @@ static void check_mm(struct mm_struct *mm)
 {
 	int i;
 
+	VM_CHECK_POISON_MM(mm);
+
 	for (i = 0; i < NR_MM_COUNTERS; i++) {
 		long x = atomic_long_read(&mm->rss_stat.count[i]);
 
@@ -624,6 +626,12 @@ struct mm_struct *mm_alloc(void)
 		return NULL;
 
 	memset(mm, 0, sizeof(*mm));
+
+#ifdef CONFIG_DEBUG_VM_POISON
+	mm->poison_start = MM_POISON_BEGIN;
+	mm->poison_end = MM_POISON_END;
+#endif
+
 	return mm_init(mm, current);
 }
 
@@ -650,6 +658,8 @@ void mmput(struct mm_struct *mm)
 {
 	might_sleep();
 
+	VM_CHECK_POISON_MM(mm);
+
 	if (atomic_dec_and_test(&mm->mm_users)) {
 		uprobe_clear_state(mm);
 		exit_aio(mm);
@@ -714,6 +724,7 @@ struct mm_struct *get_task_mm(struct task_struct *task)
 	task_lock(task);
 	mm = task->mm;
 	if (mm) {
+		VM_CHECK_POISON_MM(mm);
 		if (task->flags & PF_KTHREAD)
 			mm = NULL;
 		else
diff --git a/mm/debug.c b/mm/debug.c
index d699471..a1ebc5e 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -167,6 +167,9 @@ EXPORT_SYMBOL(dump_vma);
 void dump_mm(const struct mm_struct *mm)
 {
 	pr_emerg("mm %p mmap %p seqnum %d task_size %lu\n"
+#ifdef CONFIG_DEBUG_VM_POISON
+		"start poison: %s end poison: %s\n"
+#endif
 #ifdef CONFIG_MMU
 		"get_unmapped_area %p\n"
 #endif
@@ -197,6 +200,10 @@ void dump_mm(const struct mm_struct *mm)
 		"%s",	/* This is here to hold the comma */
 
 		mm, mm->mmap, mm->vmacache_seqnum, mm->task_size,
+#ifdef CONFIG_DEBUG_VM_POISON
+		(mm->poison_start == MM_POISON_BEGIN) ? "valid" : "invalid",
+		(mm->poison_end == MM_POISON_END) ? "valid" : "invalid",
+#endif
 #ifdef CONFIG_MMU
 		mm->get_unmapped_area,
 #endif
diff --git a/mm/mmap.c b/mm/mmap.c
index 9156612..3240bbc 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -469,6 +469,8 @@ static void validate_mm(struct mm_struct *mm)
 		bug = 1;
 	}
 	VM_BUG_ON_MM(bug, mm);
+
+	VM_CHECK_POISON_MM(mm);
 }
 #else
 #define validate_mm_rb(root, ignore) do { } while (0)
diff --git a/mm/vmacache.c b/mm/vmacache.c
index 9f25af8..d507caa 100644
--- a/mm/vmacache.c
+++ b/mm/vmacache.c
@@ -52,6 +52,8 @@ void vmacache_flush_all(struct mm_struct *mm)
  */
 static bool vmacache_valid_mm(struct mm_struct *mm)
 {
+	VM_CHECK_POISON_MM(mm);
+
 	return current->mm == mm && !(current->flags & PF_KTHREAD);
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
