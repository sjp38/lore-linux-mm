Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id EFE8C6B0005
	for <linux-mm@kvack.org>; Wed,  6 Mar 2013 18:54:35 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id c11so10360793ieb.1
        for <linux-mm@kvack.org>; Wed, 06 Mar 2013 15:54:35 -0800 (PST)
Date: Wed, 6 Mar 2013 18:54:31 -0500
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v5 2/2] mm: replace hardcoded 3% with admin_reserve_pages knob
Message-ID: <20130306235431.GB1421@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Add an admin_reserve_pages knob to allow admins to change the
hardcoded memory reserve to something other than 3%, which
may be multiple gigabytes on large memory systems.

This affects OVERCOMMIT_GUESS and OVERCOMMIT_NEVER.

admin_reserve_pages is initialized to min(3% free pages, 8MB)

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>

---

v5:
 * Custom sysctl handler was unnecessary
   now using proc_doulongvec_minmax()

v4:
 * Rebased onto v3.8-mmotm-2013-03-01-15-50
 * No longer assumes 4kb pages
 * Code duplicated for nommu

v3:
 * New patch summary because it wasn't unique
   New is "mm: replace hardcoded 3% with admin_reserve_pages knob"
   Old was "mm: tuning hardcoded reserve memory"
 * Limits growth to min(3% process size, k)
   as Alan Cox suggested. I chose k=2000 pages to allow
   recovery with sshd or login, bash, and top or kill

v2:
 * Based onto v3.8-mmotm-2013-02-19-17-20
 * Simple tunable added that initialized to 1000 pages

v1:
 * I asked for comments concerning this idea when submitting v1
   of the patch to remove the user reserve
---
 Documentation/sysctl/vm.txt | 15 +++++++++++++++
 kernel/sysctl.c             |  8 ++++++++
 mm/mmap.c                   | 30 ++++++++++++++++++++++++++----
 mm/nommu.c                  | 30 ++++++++++++++++++++++++++----
 4 files changed, 75 insertions(+), 8 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 40c2a49..60b9aba 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -18,6 +18,7 @@ files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
 
+- admin_reserve_pages
 - block_dump
 - compact_memory
 - dirty_background_bytes
@@ -59,6 +60,20 @@ Currently, these files are in /proc/sys/vm:
 
 ==============================================================
 
+admin_reserve_pages
+
+The number of free pages in the system that should be reserved for users
+with the capability cap_sys_admin. The default value is the smaller of 3%
+of free pages or 8MB (2048 pages). That should provide enough for the 
+admin to log in and kill a process if necessary.
+
+Systems running with overcommit disabled should consider increasing this
+to account for the full Virtual Memory Size of programs used to recover.
+
+Changing this takes effect whenever an application requests memory.
+
+==============================================================
+
 block_dump
 
 block_dump enables block I/O debugging when set to a nonzero value. More
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index dbb7b93..9c5aae6 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -98,6 +98,7 @@
 extern int sysctl_overcommit_memory;
 extern int sysctl_overcommit_ratio;
 extern unsigned long sysctl_user_reserve_pages;
+extern unsigned long sysctl_admin_reserve_pages;
 extern int max_threads;
 extern int suid_dumpable;
 #ifdef CONFIG_COREDUMP
@@ -1438,6 +1439,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname	= "admin_reserve_pages",
+		.data		= &sysctl_admin_reserve_pages,
+		.maxlen		= sizeof(sysctl_admin_reserve_pages),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index aeaf83f..78743ab 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -86,6 +86,7 @@ int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic ove
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_pages __read_mostly = 1UL << (27 - PAGE_SHIFT); /* 128MB */
+unsigned long sysctl_admin_reserve_pages __read_mostly = 1UL << (23 - PAGE_SHIFT); /* 8MB */
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -165,10 +166,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
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
@@ -179,10 +180,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
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
 
 	/*
@@ -3090,3 +3091,24 @@ int __meminit init_user_reserve(void)
 	return 0;
 }
 module_init(init_user_reserve)
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
+	sysctl_admin_reserve_pages = min(free / 32, 1UL << (23 - PAGE_SHIFT));
+	return 0;
+}
+module_init(init_admin_reserve)
diff --git a/mm/nommu.c b/mm/nommu.c
index 0137ab2..70282a1 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -65,6 +65,7 @@ int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 unsigned long sysctl_user_reserve_pages __read_mostly = 1UL << (27 - PAGE_SHIFT); /* 128MB */
+unsigned long sysctl_admin_reserve_pages __read_mostly = 1UL << (23 - PAGE_SHIFT); /* 8MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
@@ -1927,10 +1928,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
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
@@ -1940,10 +1941,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
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
@@ -2133,3 +2134,24 @@ int __meminit init_user_reserve(void)
 	return 0;
 }
 module_init(init_user_reserve)
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
+	sysctl_admin_reserve_pages = min(free / 32, 1UL << (23 - PAGE_SHIFT));
+	return 0;
+}
+module_init(init_admin_reserve)
-- 
1.8.0.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
