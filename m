Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 12D4A6B0005
	for <linux-mm@kvack.org>; Fri,  1 Mar 2013 18:43:44 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id bg4so2105727pad.12
        for <linux-mm@kvack.org>; Fri, 01 Mar 2013 15:43:44 -0800 (PST)
Date: Fri, 1 Mar 2013 18:43:40 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v3 002/002] mm: replace hardcoded 3% with admin_reserve_pages
 knob
Message-ID: <20130301234340.GB1848@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Add an admin_reserve_pages knob to allow admins of large memory
systems running with overcommit disabled to change the hardcoded
memory reserve to something other than 3%.
    
admin_reserve_pages is initialized to min(3%, k) as Alan suggested.
k=2000 pages should allow the admin to spawn new sshd, bash, and top
to recover if necessary.

This affects OVERCOMMIT_GUESS and OVERCOMMIT_NEVER modes.

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

I changed the name of the knob from "rootuser" to "admin" 
because it better matches the cap_sys_admin conditional. 

 Documentation/sysctl/vm.txt | 16 +++++++++++++++
 include/linux/mm.h          |  2 ++
 kernel/sysctl.c             |  8 ++++++++
 mm/mmap.c                   | 50 +++++++++++++++++++++++++++++++++++++++++----
 4 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 078701f..2827800 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -18,6 +18,7 @@ files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
 
+- admin_reserve_pages
 - block_dump
 - compact_memory
 - dirty_background_bytes
@@ -628,6 +629,21 @@ the high water marks for each per cpu page list.
 
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
index 66e2f7c..fba5f9a 100644
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
index c88878d..33f99f6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -96,6 +96,7 @@
 /* External variables not in a header file. */
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
+extern int sysctl_admin_reserve_pages;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1413,6 +1414,13 @@ static struct ctl_table vm_table[] = {
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
index 6134b1d..e7e8889 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -32,6 +32,7 @@
 #include <linux/khugepaged.h>
 #include <linux/uprobes.h>
 #include <linux/rbtree_augmented.h>
+#include <linux/sysctl.h>
 
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
@@ -83,6 +84,7 @@ EXPORT_SYMBOL(vm_get_page_prot);
 int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic overcommit */
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
+int sysctl_admin_reserve_pages __read_mostly = 4096;
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -162,10 +164,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some 3% for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_pages;
 
 		if (free > pages)
 			return 0;
@@ -176,10 +178,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
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
@@ -3053,3 +3055,43 @@ void __init mmap_init(void)
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
+ * The sum RSS of sshd, bash, and top is about 8MB on x86_64, 
+ * so 2000 pages should be enough. However, systems with 
+ * less than 256MB will only reserve 3% of free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free;
+
+	free = global_page_state(NR_FREE_PAGES);
+
+	sysctl_admin_reserve_pages = min(free / 32, 2000UL);
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
