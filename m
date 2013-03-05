Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id 0B9FC6B0002
	for <linux-mm@kvack.org>; Tue,  5 Mar 2013 18:39:29 -0500 (EST)
Received: by mail-ie0-f171.google.com with SMTP id 10so8586094ied.2
        for <linux-mm@kvack.org>; Tue, 05 Mar 2013 15:39:29 -0800 (PST)
Date: Tue, 5 Mar 2013 18:39:25 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v4 002/002] mm: replace hardcoded 3% with admin_reserve_pages
 knob
Message-ID: <20130305233925.GB1948@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Add an admin_reserve_pages knob to allow admins of large memory systems 
to change the hardcoded memory reserve to something other than 3%.
This affects OVERCOMMIT_GUESS and OVERCOMMIT_NEVER.
    
admin_reserve_pages is initialized to min(3% free pages, 8MB)

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

Rebased onto v3.8-mmotm-2013-03-01-15-50
Code duplicated for nommu.

 Documentation/sysctl/vm.txt |   16 ++++++++++++++
 include/linux/mm.h          |    2 +
 kernel/sysctl.c             |    8 +++++++
 mm/mmap.c                   |   50 ++++++++++++++++++++++++++++++++++++++++----
 mm/nommu.c                  |   50 ++++++++++++++++++++++++++++++++++++++++----

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 21ad181..d638952 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -18,6 +18,7 @@ files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
 
+- admin_reserve_pages
 - block_dump
 - compact_memory
 - dirty_background_bytes
@@ -649,6 +650,21 @@ the high water marks for each per cpu page list.
 
 ==============================================================
 
+admin_reserve_pages
+
+The number of free pages in the system that should be reserved for users
+with the capability cap_sys_admin. The default value is the smaller of 3% 
+of free pages or 2000 pages (8MB with 4k pages). 8MB should provide 
+enough for the admin to log in and kill a process if necessary. 
+
+Systems running with overcommit disabled should consider increasing this 
+to account for the full Virtual Memory Size of programs used to recover 
+a system.
+
+Changing this takes effect whenever an application requests memory.
+
+==============================================================
+
 stat_interval
 
 The time interval between which vm statistics are updated.  The default
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 3393114..2ec7feb 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1677,6 +1677,8 @@ int in_gate_area_no_mm(unsigned long addr);
 
 int drop_caches_sysctl_handler(struct ctl_table *, int,
 					void __user *, size_t *, loff_t *);
+int admin_reserve_pages_sysctl_handler(struct ctl_table *, int,
+					void __user *, size_t *, loff_t *);
 unsigned long shrink_slab(struct shrink_control *shrink,
 			  unsigned long nr_pages_scanned,
 			  unsigned long lru_pages);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index afc1dc6..eb2cb45 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -97,6 +97,7 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern int sysctl_admin_reserve_pages;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1430,6 +1431,13 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "admin_reserve_pages",
+		.data		= &sysctl_admin_reserve_pages,
+		.maxlen		= sizeof(sysctl_admin_reserve_pages),
+		.mode		= 0644,
+		.proc_handler	= admin_reserve_pages_sysctl_handler,
+	},
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 49dc7d5..01a2590 100644
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
+int sysctl_admin_reserve_pages __read_mostly = 1 << (23 - PAGE_SHIFT); /* default is 8MB */
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -163,10 +165,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_pages;
 
 		if (free > pages)
 			return 0;
@@ -177,10 +179,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	allowed = (totalram_pages - hugetlb_total_pages())
 	       	* sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * Reserve some for root
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= sysctl_admin_reserve_pages;
 	allowed += total_swap_pages;
 
 	/* Don't let a single process grow too big:
@@ -3069,3 +3073,43 @@ void __init mmap_init(void)
 	ret = percpu_counter_init(&vm_committed_as, 0);
 	VM_BUG_ON(ret);
 }
+
+/*
+ * Initialise sysctl_admin_reserve_pages.
+ *
+ * The purpose of sysctl_admin_reserve_pages is to allow the sys admin
+ * to log in and kill a memory hogging process.
+ *
+ * Systems with more than 256MB will reserve 8MB, enough to recover 
+ * with sshd, bash, and top. Smaller systems will only reserve 3% of 
+ * free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free;
+
+	free = global_page_state(NR_FREE_PAGES);
+
+	sysctl_admin_reserve_pages = min(free / 32, 1 << (23 - PAGE_SHIFT));
+	return 0;
+}
+module_init(init_admin_reserve)
+
+/*
+ * admin_reserve_pages_sysctl_handler - just a wrapper around proc_dointvec_minmax() so 
+ *	that we can cap the number of pages to the current number of free pages.
+ */
+int admin_reserve_pages_sysctl_handler(ctl_table *table, int write, 
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	unsigned long free;
+
+	proc_dointvec(table, write, buffer, length, ppos);
+
+	if (write) {
+		free = global_page_state(NR_FREE_PAGES);
+		if (sysctl_admin_reserve_pages > free)
+			sysctl_admin_reserve_pages = free;
+	}
+	return 0;
+}
diff --git a/mm/nommu.c b/mm/nommu.c
index f5d57a3..87d7533 100644
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
+int sysctl_admin_reserve_pages __read_mostly = 1 << (23 - PAGE_SHIFT); /* default is 8MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
@@ -1925,10 +1927,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_pages;
 
 		if (free > pages)
 			return 0;
@@ -1938,10 +1940,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * Reserve some 3% for root
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= sysctl_admin_reserve_pages;
 	allowed += total_swap_pages;
 
 	/* Don't let a single process grow too big:
@@ -2111,3 +2115,43 @@ int nommu_shrink_inode_mappings(struct inode *inode, size_t size,
 	up_write(&nommu_region_sem);
 	return 0;
 }
+
+/*
+ * Initialise sysctl_admin_reserve_pages.
+ *
+ * The purpose of sysctl_admin_reserve_pages is to allow the sys admin
+ * to log in and kill a memory hogging process.
+ *
+ * Systems with more than 256MB will reserve 8MB, enough to recover 
+ * with sshd, bash, and top. Smaller systems will only reserve 3% of 
+ * free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free;
+
+	free = global_page_state(NR_FREE_PAGES);
+
+	sysctl_admin_reserve_pages = min(free / 32, 1 << (23 - PAGE_SHIFT));
+	return 0;
+}
+module_init(init_admin_reserve)
+
+/*
+ * admin_reserve_pages_sysctl_handler - just a wrapper around proc_dointvec_minmax() so 
+ *	that we can cap the number of pages to the current number of free pages.
+ */
+int admin_reserve_pages_sysctl_handler(ctl_table *table, int write, 
+	void __user *buffer, size_t *length, loff_t *ppos)
+{
+	unsigned long free;
+
+	proc_dointvec(table, write, buffer, length, ppos);
+
+	if (write) {
+		free = global_page_state(NR_FREE_PAGES);
+		if (sysctl_admin_reserve_pages > free)
+			sysctl_admin_reserve_pages = free;
+	}
+	return 0;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
