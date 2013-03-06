Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 7780A6B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 18:52:06 -0500 (EST)
Received: by mail-pb0-f44.google.com with SMTP id wz12so6799311pbc.3
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 15:52:05 -0800 (PST)
Date: Wed, 6 Mar 2013 18:52:01 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v5 1/2] mm: limit growth of 3% hardcoded other user reserve 
Message-ID: <20130306235201.GA1421@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Add user_reserve_pages knob.

Limit the growth of the memory reserved for other user
processes to min(3% current process, user_reserve_pages).

user_reserve_pages defaults to min(3% free pages, 128MB)
I arrived at 128MB by taking that max VSZ of sshd, login, 
bash, and top ... then adding the RSS of each.

This only affects OVERCOMMIT_NEVER mode.

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

v5:
 * Change k in min(3% process size, k) into user_reserve_pages knob
 * user_reserve_pages defaults to min(3% free pages, 128MB)
   previous k=8MB wasn't enough for OVERCOMMIT_NEVER mode
   and 128MB worked when I tested it

v4:
 * Rebased onto v3.8-mmotm-2013-03-01-15-50
 * No longer assumes 4kb pages
 * Code duplicated for nommu

v3:
 * New patch summary because it wasn't unique
   New is "mm: limit growth of 3% hardcoded other user reserve"
   Old was "mm: tuning hardcoded reserve memory"
 * Limits growth to min(3% process size, k)
   as Alan Cox suggested. I chose k=2000 pages to allow
   recovery with sshd or login, bash, and top or kill

v2:
 * Rebased onto v3.8-mmotm-2013-02-19-17-20

v1:
 * Based on 3.8
 * Remove hardcoded 3% other user reserve in OVERCOMMIT_NEVER mode


 Documentation/sysctl/vm.txt | 19 +++++++++++++++++++
 include/linux/mm.h          |  2 ++
 kernel/sysctl.c             |  8 ++++++++
 mm/mmap.c                   | 29 ++++++++++++++++++++++++++---
 mm/nommu.c                  | 28 ++++++++++++++++++++++++++--
 5 files changed, 81 insertions(+), 5 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 21ad181..40c2a49 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -53,6 +53,7 @@ Currently, these files are in /proc/sys/vm:
 - percpu_pagelist_fraction
 - stat_interval
 - swappiness
+- user_reserve_pages
 - vfs_cache_pressure
 - zone_reclaim_mode
 
@@ -666,6 +667,24 @@ The default value is 60.
 
 ==============================================================
 
+- user_reserve_pages
+
+This only affects OVERCOMMIT_NEVER mode.
+
+This reserve prevents a single process from being so large that 
+a user cannot kill it. The default value is the smaller of 3% of 
+the current process size or 128MB. That should provide enough for 
+the user to recover.
+
+If this is reduced to zero, then the user will be allowed to allocate 
+all free memory with a single process, minus admin_reserve_pages.
+Any subsequent attempts to execute a command will result in
+"fork: Cannot allocate memory". 
+
+Changing this takes effect whenever an application requests memory.
+
+==============================================================
+
 vfs_cache_pressure
 ------------------
 
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3393114..3956d3d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1677,6 +1677,8 @@ int in_gate_area_no_mm(unsigned long addr);
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int reserve_pages_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(struct shrink_control *shrink,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index afc1dc6..dbb7b93 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -97,6 +97,7 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern unsigned long sysctl_user_reserve_pages;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1430,6 +1431,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "user_reserve_pages",
+		.data		= &sysctl_user_reserve_pages,
+		.maxlen		= sizeof(sysctl_user_reserve_pages),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 49dc7d5..aeaf83f 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -33,6 +33,7 @@
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
 #include <linux/sched/sysctl.h>
+#include <linux/sysctl.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -84,6 +85,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
+unsigned long sysctl_user_reserve_pages __read_mostly = 1UL << (27 - PAGE_SHIFT); /* 128MB */
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -183,10 +185,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 		allowed -= allowed / 32;
 	allowed += total_swap_pages;
 
-	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
+	/*
+ 	 * Don't let a single process grow so big a user can't recover
+         */
 	if (mm)
-		allowed -= mm->total_vm / 32;
+		allowed -= min(mm->total_vm / 32, sysctl_user_reserve_pages);
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
@@ -3067,3 +3070,23 @@ void __init mmap_init(void)
 	ret = percpu_counter_init(&vm_committed_as, 0);
 	VM_BUG_ON(ret);
 }
+
+/*
+ * Initialise sysctl_user_reserve_pages.
+ *
+ * The purpose of sysctl_user_reserve_pages is to prevent a single 
+ * process from allocating all free memory in OVERCOMMIT_NEVER mode.
+ *
+ * The default value is min(3% of free memory, 128MB) 
+ * 128MB is enough to recover with sshd/login, bash, and top/kill.
+ */
+int __meminit init_user_reserve(void)
+{
+	unsigned long free;
+
+	free = global_page_state(NR_FREE_PAGES);
+
+	sysctl_user_reserve_pages = min(free / 32, 1UL << (27 - PAGE_SHIFT));
+	return 0;
+}
+module_init(init_user_reserve)
diff --git a/mm/nommu.c b/mm/nommu.c
index f5d57a3..0137ab2 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -30,6 +30,7 @@
 #include <linux/syscalls.h>
 #include <linux/audit.h>
 #include <linux/sched/sysctl.h>
+#include <linux/sysctl.h>
 
 #include <asm/uaccess.h>
 #include <asm/tlb.h>
@@ -63,6 +64,7 @@ int sysctl_overcommit_memory = OVERCOMMIT_GUESS; /* heuristic overcommit */
 int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
+unsigned long sysctl_user_reserve_pages __read_mostly = 1UL << (27 - PAGE_SHIFT); /* 128MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
@@ -1945,9 +1947,11 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	allowed += total_swap_pages;
 
 	/* Don't let a single process grow too big:
-	   leave 3% of the size of this process for other processes */
+	 * leave the smaller of 3% of the size of this process 
+         * or 8MB for other processes
+         */
 	if (mm)
-		allowed -= mm->total_vm / 32;
+		allowed -= min(mm->total_vm / 32, sysctl_user_reserve_pages);
 
 	if (percpu_counter_read_positive(&vm_committed_as) < allowed)
 		return 0;
@@ -2109,3 +2113,23 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	up_write(&nommu_region_sem);
 	return 0;
 }
+
+/*
+ * Initialise sysctl_user_reserve_pages.
+ *
+ * The purpose of sysctl_user_reserve_pages is to prevent a single 
+ * process from allocating all free memory in OVERCOMMIT_NEVER mode.
+ *
+ * The default value is min(3% of free memory, 128MB) 
+ * 128MB is enough to recover with sshd/login, bash, and top/kill.
+ */
+int __meminit init_user_reserve(void)
+{
+	unsigned long free;
+
+	free = global_page_state(NR_FREE_PAGES);
+
+	sysctl_user_reserve_pages = min(free / 32, 1UL << (27 - PAGE_SHIFT));
+	return 0;
+}
+module_init(init_user_reserve)
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
