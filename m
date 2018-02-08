Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5911A6B0003
	for <linux-mm@kvack.org>; Wed,  7 Feb 2018 21:11:16 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id j69so1353776pfe.5
        for <linux-mm@kvack.org>; Wed, 07 Feb 2018 18:11:16 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id u13-v6si621804plq.435.2018.02.07.18.11.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Feb 2018 18:11:14 -0800 (PST)
Date: Wed, 7 Feb 2018 18:11:12 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: [RFC] Warn the user when they could overflow mapcount
Message-ID: <20180208021112.GB14918@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-hardening@lists.openwall.com, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>


Kirill and I were talking about trying to overflow page->_mapcount
the other day and realised that the default settings of pid_max and
max_map_count prevent it [1].  But there isn't even documentation to
warn a sysadmin that they've just opened themselves up to the possibility
that they've opened their system up to a sufficiently-determined attacker.

I'm not sufficiently wise in the ways of the MM to understand exactly
what goes wrong if we do wrap mapcount.  Kirill says:

  rmap depends on mapcount to decide when the page is not longer mapped.
  If it sees page_mapcount() == 0 due to 32-bit wrap we are screwed;
  data corruption, etc.

That seems pretty bad.  So here's a patch which adds documentation to the
two sysctls that a sysadmin could use to shoot themselves in the foot,
and adds a warning if they change either of them to a dangerous value.
It's possible to get into a dangerous situation without triggering this
warning (already have the file mapped a lot of times, then lower pid_max,
then raise max_map_count, then map the file a lot more times), but it's
unlikely to happen.

Comments?

[1] map_count counts the number of times that a page is mapped to
userspace; max_map_count restricts the number of times a process can
map a page and pid_max restricts the number of processes that can exist.
So map_count can never be larger than pid_max * max_map_count.

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 412314eebda6..ec90cd633e99 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -718,6 +718,8 @@ pid_max:
 PID allocation wrap value.  When the kernel's next PID value
 reaches this value, it wraps back to a minimum PID value.
 PIDs of value pid_max or larger are not allocated.
+Increasing this value without decreasing vm.max_map_count may
+allow a hostile user to corrupt kernel memory
 
 ==============================================================
 
diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index ff234d229cbb..0ab306ea8f80 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -379,7 +379,8 @@ While most applications need less than a thousand maps, certain
 programs, particularly malloc debuggers, may consume lots of them,
 e.g., up to one or two maps per allocation.
 
-The default value is 65536.
+The default value is 65530.  Increasing this value without decreasing
+pid_max may allow a hostile user to corrupt kernel memory.
 
 =============================================================
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 173d2484f6e3..ebc301b21589 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -123,8 +123,6 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #define MAPCOUNT_ELF_CORE_MARGIN	(5)
 #define DEFAULT_MAX_MAP_COUNT	(USHRT_MAX - MAPCOUNT_ELF_CORE_MARGIN)
 
-extern int sysctl_max_map_count;
-
 extern unsigned long sysctl_user_reserve_kbytes;
 extern unsigned long sysctl_admin_reserve_kbytes;
 
diff --git a/include/linux/pid.h b/include/linux/pid.h
index 7633d55d9a24..7bb10c1b3be3 100644
--- a/include/linux/pid.h
+++ b/include/linux/pid.h
@@ -4,6 +4,8 @@
 
 #include <linux/rculist.h>
 
+extern int pid_max;
+
 enum pid_type
 {
 	PIDTYPE_PID,
diff --git a/include/linux/sysctl.h b/include/linux/sysctl.h
index 992bc9948232..c939f403ad08 100644
--- a/include/linux/sysctl.h
+++ b/include/linux/sysctl.h
@@ -235,5 +235,9 @@ static inline void setup_sysctl_set(struct ctl_table_set *p,
 
 int sysctl_max_threads(struct ctl_table *table, int write,
 		       void __user *buffer, size_t *lenp, loff_t *ppos);
+int sysctl_pid_max(struct ctl_table *table, int write,
+		   void __user *buffer, size_t *lenp, loff_t *ppos);
+int sysctl_max_map_count(struct ctl_table *table, int write,
+			 void __user *buffer, size_t *lenp, loff_t *ppos);
 
 #endif /* _LINUX_SYSCTL_H */
diff --git a/kernel/pid.c b/kernel/pid.c
index 5d30c87e3c42..9e230ae214c9 100644
--- a/kernel/pid.c
+++ b/kernel/pid.c
@@ -61,6 +61,27 @@ int pid_max = PID_MAX_DEFAULT;
 
 int pid_max_min = RESERVED_PIDS + 1;
 int pid_max_max = PID_MAX_LIMIT;
+extern int max_map_count;
+
+int sysctl_pid_max(struct ctl_table *table, int write,
+		   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table t;
+	int ret;
+
+	t = *table;
+	t.data = &pid_max;
+	t.extra1 = &pid_max_min;
+	t.extra2 = &pid_max_max;
+
+	ret = proc_douintvec_minmax(&t, write, buffer, lenp, ppos);
+	if (ret || !write)
+		return ret;
+
+	if ((INT_MAX / max_map_count) > pid_max)
+		pr_warn("pid_max is dangerously large\n");
+	return 0;
+}
 
 /*
  * PID-map pages start out as NULL, they get allocated upon
diff --git a/kernel/pid_namespace.c b/kernel/pid_namespace.c
index 0b53eef7d34b..e24becc39020 100644
--- a/kernel/pid_namespace.c
+++ b/kernel/pid_namespace.c
@@ -308,7 +308,6 @@ static int pid_ns_ctl_handler(struct ctl_table *table, int write,
 	return ret;
 }
 
-extern int pid_max;
 static int zero = 0;
 static struct ctl_table pid_ns_ctl_table[] = {
 	{
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 2fb4e27c636a..a137acc0971f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -105,8 +105,6 @@ extern int core_uses_pid;
 extern char core_pattern[];
 extern unsigned int core_pipe_limit;
 #endif
-extern int pid_max;
-extern int pid_max_min, pid_max_max;
 extern int percpu_pagelist_fraction;
 extern int latencytop_enabled;
 extern unsigned int sysctl_nr_open_min, sysctl_nr_open_max;
@@ -784,12 +782,10 @@ static struct ctl_table kern_table[] = {
 #endif
 	{
 		.procname	= "pid_max",
-		.data		= &pid_max,
-		.maxlen		= sizeof (int),
+		.data		= NULL,
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &pid_max_min,
-		.extra2		= &pid_max_max,
+		.proc_handler	= sysctl_pid_max,
 	},
 	{
 		.procname	= "panic_on_oops",
@@ -1454,11 +1450,10 @@ static struct ctl_table vm_table[] = {
 #ifdef CONFIG_MMU
 	{
 		.procname	= "max_map_count",
-		.data		= &sysctl_max_map_count,
-		.maxlen		= sizeof(sysctl_max_map_count),
+		.data		= NULL,
+		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec_minmax,
-		.extra1		= &zero,
+		.proc_handler	= sysctl_max_map_count,
 	},
 #else
 	{
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 2a6d0325a761..3e9d08a1416a 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -663,8 +663,6 @@ extern unsigned long tracing_thresh;
 
 /* PID filtering */
 
-extern int pid_max;
-
 bool trace_find_filtered_pid(struct trace_pid_list *filtered_pids,
 			     pid_t search_pid);
 bool trace_ignore_this_task(struct trace_pid_list *filtered_pids,
diff --git a/mm/internal.h b/mm/internal.h
index e6bd35182dae..23b014958eb9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -79,6 +79,7 @@ static inline void set_page_refcounted(struct page *page)
 }
 
 extern unsigned long highest_memmap_pfn;
+extern int max_map_count;
 
 /*
  * Maximum number of reclaim retries without progress before the OOM
diff --git a/mm/madvise.c b/mm/madvise.c
index 4d3c922ea1a1..5b66a4a48192 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -147,7 +147,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	*prev = vma;
 
 	if (start != vma->vm_start) {
-		if (unlikely(mm->map_count >= sysctl_max_map_count)) {
+		if (unlikely(mm->map_count >= max_map_count)) {
 			error = -ENOMEM;
 			goto out;
 		}
@@ -164,7 +164,7 @@ static long madvise_behavior(struct vm_area_struct *vma,
 	}
 
 	if (end != vma->vm_end) {
-		if (unlikely(mm->map_count >= sysctl_max_map_count)) {
+		if (unlikely(mm->map_count >= max_map_count)) {
 			error = -ENOMEM;
 			goto out;
 		}
diff --git a/mm/mmap.c b/mm/mmap.c
index 9efdc021ad22..9016dae43fee 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1355,7 +1355,7 @@ unsigned long do_mmap(struct file *file, unsigned long addr,
 		return -EOVERFLOW;
 
 	/* Too many mappings? */
-	if (mm->map_count > sysctl_max_map_count)
+	if (mm->map_count > max_map_count)
 		return -ENOMEM;
 
 	/* Obtain the address to map to. we verify (or select) it and ensure
@@ -2546,7 +2546,7 @@ detach_vmas_to_be_unmapped(struct mm_struct *mm, struct vm_area_struct *vma,
 }
 
 /*
- * __split_vma() bypasses sysctl_max_map_count checking.  We use this where it
+ * __split_vma() bypasses max_map_count checking.  We use this where it
  * has already been checked or doesn't make sense to fail.
  */
 int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
@@ -2621,7 +2621,7 @@ int __split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	      unsigned long addr, int new_below)
 {
-	if (mm->map_count >= sysctl_max_map_count)
+	if (mm->map_count >= max_map_count)
 		return -ENOMEM;
 
 	return __split_vma(mm, vma, addr, new_below);
@@ -2672,7 +2672,7 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
 		 * not exceed its limit; but let map_count go just above
 		 * its limit temporarily, to help free resources as expected.
 		 */
-		if (end < vma->vm_end && mm->map_count >= sysctl_max_map_count)
+		if (end < vma->vm_end && mm->map_count >= max_map_count)
 			return -ENOMEM;
 
 		error = __split_vma(mm, vma, start, 0);
@@ -2917,7 +2917,7 @@ static int do_brk_flags(unsigned long addr, unsigned long request, unsigned long
 	if (!may_expand_vm(mm, flags, len >> PAGE_SHIFT))
 		return -ENOMEM;
 
-	if (mm->map_count > sysctl_max_map_count)
+	if (mm->map_count > max_map_count)
 		return -ENOMEM;
 
 	if (security_vm_enough_memory_mm(mm, len >> PAGE_SHIFT))
@@ -3532,6 +3532,30 @@ void mm_drop_all_locks(struct mm_struct *mm)
 	mutex_unlock(&mm_all_locks_mutex);
 }
 
+int max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
+
+int sysctl_max_map_count(struct ctl_table *table, int write,
+			 void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	struct ctl_table t;
+	int ret;
+	int min = 0;
+	int max = ~0;
+
+	t = *table;
+	t.data = &max_map_count;
+	t.extra1 = &min;
+	t.extra2 = &max;
+
+	ret = proc_douintvec_minmax(&t, write, buffer, lenp, ppos);
+	if (ret || !write)
+		return ret;
+
+	if ((INT_MAX / max_map_count) > pid_max)
+		pr_warn("max_map_count is dangerously large\n");
+	return 0;
+}
+
 /*
  * initialise the percpu counter for VM
  */
diff --git a/mm/mremap.c b/mm/mremap.c
index 049470aa1e3e..fdb1d71ab2cc 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -281,7 +281,7 @@ static unsigned long move_vma(struct vm_area_struct *vma,
 	 * We'd prefer to avoid failure later on in do_munmap:
 	 * which may split one vma into three before unmapping.
 	 */
-	if (mm->map_count >= sysctl_max_map_count - 3)
+	if (mm->map_count >= max_map_count - 3)
 		return -ENOMEM;
 
 	/*
diff --git a/mm/nommu.c b/mm/nommu.c
index 4b9864b17cb0..4cd9d4b9f473 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -1487,7 +1487,7 @@ int split_vma(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (vma->vm_file)
 		return -ENOMEM;
 
-	if (mm->map_count >= sysctl_max_map_count)
+	if (mm->map_count >= max_map_count)
 		return -ENOMEM;
 
 	region = kmem_cache_alloc(vm_region_jar, GFP_KERNEL);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index c7dd9c86e353..9a2edf3925be 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -740,16 +740,14 @@ static inline void rmv_page_order(struct page *page)
 
 /*
  * This function checks whether a page is free && is the buddy
- * we can do coalesce a page and its buddy if
+ * we can coalesce a page and its buddy if
  * (a) the buddy is not in a hole (check before calling!) &&
  * (b) the buddy is in the buddy system &&
  * (c) a page and its buddy have the same order &&
  * (d) a page and its buddy are in the same zone.
  *
- * For recording whether a page is in the buddy system, we set ->_mapcount
- * PAGE_BUDDY_MAPCOUNT_VALUE.
- * Setting, clearing, and testing _mapcount PAGE_BUDDY_MAPCOUNT_VALUE is
- * serialized by zone->lock.
+ * For recording whether a page is in the buddy system, we set PG_buddy.
+ * Setting, clearing, and testing PG_buddy is serialized by zone->lock.
  *
  * For recording page's order, we use page_private(page).
  */
@@ -794,9 +792,8 @@ static inline int page_is_buddy(struct page *page, struct page *buddy,
  * as necessary, plus some accounting needed to play nicely with other
  * parts of the VM system.
  * At each level, we keep a list of pages, which are heads of continuous
- * free pages of length of (1 << order) and marked with _mapcount
- * PAGE_BUDDY_MAPCOUNT_VALUE. Page's order is recorded in page_private(page)
- * field.
+ * free pages of length of (1 << order) and marked with PageBuddy().
+ * Page's order is recorded in page_private(page) field.
  * So when we are allocating or freeing one, we can derive the state of the
  * other.  That is, if we allocate a small block, and both were
  * free, the remainder of the region must be split into blocks.
diff --git a/mm/util.c b/mm/util.c
index c1250501364f..2ac777548694 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -538,7 +538,6 @@ EXPORT_SYMBOL_GPL(__page_mapcount);
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;
 int sysctl_overcommit_ratio __read_mostly = 50;
 unsigned long sysctl_overcommit_kbytes __read_mostly;
-int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
 unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
