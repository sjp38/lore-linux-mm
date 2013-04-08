Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 0F1AE6B0036
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 20:01:51 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id s35so3252353dak.20
        for <linux-mm@kvack.org>; Tue, 09 Apr 2013 17:01:51 -0700 (PDT)
Date: Mon, 8 Apr 2013 18:56:41 -0400
From: Andrew Shewmaker <agshew@gmail.com>
Subject: [PATCH v9 2/3] mm: replace hardcoded 3% with admin_reserve_pages knob
Message-ID: <20130408225641.GC3396@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, simon.jeons@gmail.com, ric.masonn@gmail.com

Add an admin_reserve_kbytes knob to allow admins to change the
hardcoded memory reserve to something other than 3%, which
may be multiple gigabytes on large memory systems. Only about
8MB is necessary to enable recovery in the default mode, and
only a few hundred MB are required even when overcommit is
disabled.

This affects OVERCOMMIT_GUESS and OVERCOMMIT_NEVER.

admin_reserve_kbytes is initialized to min(3% free pages, 8MB)

I arrived at 8MB by summing the RSS of sshd or login,
bash, and top.

Please see first patch in this series for full background,
motivation, testing, and full changelog.

Abbreviated Patch Changelog

v9:
 * Cleanup extern declarations - from Andrew Morton

 * Explanatory comments for magic numbers in memory notifier

 * Use new register_hotmemory_notifier() to avoid bloat - from Andrew Morton

 * Dropped accidental .gitignore change in v8

v8:
 * Rebased onto v3.9-rc4-mmotm-2013-03-26-15-09

 * Clarified reasoning between different calculations for
   overcommit 'guess' and 'never modes in FAQ entry
   "How do you calculate a minimum useful reserve?"
   in response to Simon Jeons.

 * Added third patch in series to handle hot-added or hot-swapped
   memory.

v7:
 * Rebased onto v3.9-rc3-mmotm-2013-03-22-15-21

 * Removed sysctl.h include. It wasn't needed since I removed my
   custom handler in v5

 * Ran checkpatch.pl and cleaned up whitespace errors
   A couple lines barely exceed 80 chars, but that seems common in
   nearby code.

 * Added future work section

 v7 discussion:

  * Simon Jeons asked for clarification of why reserves
    should be different between different overcommit modes.
    FAQ updated in v8.

  * Simon Jeons asked if other architectures had been tested.
    None have been.

v6:
 * Rebased onto v3.9-rc1-mmotm-2013-03-07-15-45

 * Replace user_reserve_pages with user_reserve_kbytes

 * Replace admin_reserve_pages with admin_reserve_kbytes

 * Increase verbosity of patch changelog

 * Add Alan Cox's example of sparse arrays to the
   documentation of the 'always' overcommit mode

 * Add note in overcommit_memory documentation that
   user_reserve_kbytes affects 'never' mode

 * Improve wording of user_reserve_kbytes documentation

 * Clearly document risk of root-cant-log-in
   in admin_reserve_kbytes documentation

 v6 discussion:

  * Andrew Morton pointed to a need to modify reserves
    when memory is hot-added or hot-removed

Signed-off-by: Andrew Shewmaker <agshew@gmail.com>
---
 Documentation/sysctl/vm.txt | 30 ++++++++++++++++++++++++++++++
 include/linux/mm.h          |  1 +
 kernel/sysctl.c             |  7 +++++++
 mm/mmap.c                   | 30 ++++++++++++++++++++++++++----
 mm/nommu.c                  | 30 ++++++++++++++++++++++++++----
 5 files changed, 90 insertions(+), 8 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index d49e41d..a5717c3 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -18,6 +18,7 @@ files can be found in mm/swap.c.
 
 Currently, these files are in /proc/sys/vm:
 
+- admin_reserve_kbytes
 - block_dump
 - compact_memory
 - dirty_background_bytes
@@ -59,6 +60,35 @@ Currently, these files are in /proc/sys/vm:
 
 ==============================================================
 
+admin_reserve_kbytes
+
+The amount of free memory in the system that should be reserved for users
+with the capability cap_sys_admin.
+
+admin_reserve_kbytes defaults to min(3% of free pages, 8MB)
+
+That should provide enough for the admin to log in and kill a process,
+if necessary, under the default overcommit 'guess' mode.
+
+Systems running under overcommit 'never' should increase this to account
+for the full Virtual Memory Size of programs used to recover. Otherwise,
+root may not be able to log in to recover the system.
+
+How do you calculate a minimum useful reserve?
+
+sshd or login + bash (or some other shell) + top (or ps, kill, etc.)
+
+For overcommit 'guess', we can sum resident set sizes (RSS).
+On x86_64 this is about 8MB.
+
+For overcommit 'never', we can take the max of their virtual sizes (VSZ)
+and add the sum of their RSS.
+On x86_64 this is about 128MB.
+
+Changing this takes effect whenever an application requests memory.
+
+==============================================================
+
 block_dump
 
 block_dump enables block I/O debugging when set to a nonzero value. More
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2af6db8..dc3693d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -45,6 +45,7 @@ extern int sysctl_legacy_va_layout;
 #include <asm/processor.h>
 
 extern unsigned long sysctl_user_reserve_kbytes;
+extern unsigned long sysctl_admin_reserve_kbytes;
 
 #define nth_page(page,n) pfn_to_page(page_to_pfn((page)) + (n))
 
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6daabb7..9edcf45 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1436,6 +1436,13 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+	{
+		.procname	= "admin_reserve_kbytes",
+		.data		= &sysctl_admin_reserve_kbytes,
+		.maxlen		= sizeof(sysctl_admin_reserve_kbytes),
+		.mode		= 0644,
+		.proc_handler	= proc_doulongvec_minmax,
+	},
 	{ }
 };
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 6f983cc..5d63c9e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -85,6 +85,7 @@ int sysctl_overcommit_memory __read_mostly = OVERCOMMIT_GUESS;  /* heuristic ove
 int sysctl_overcommit_ratio __read_mostly = 50;	/* default is 50% */
 int sysctl_max_map_count __read_mostly = DEFAULT_MAX_MAP_COUNT;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
+unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 /*
  * Make sure vm_committed_as in one cacheline and not cacheline shared with
  * other variables. It can be updated by several CPUs frequently.
@@ -164,10 +165,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
 
 		if (free > pages)
 			return 0;
@@ -178,10 +179,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 	allowed = (totalram_pages - hugetlb_total_pages())
 	       	* sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * Reserve some for root
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
 	allowed += total_swap_pages;
 
 	/*
@@ -3089,3 +3090,24 @@ int __meminit init_user_reserve(void)
 	return 0;
 }
 module_init(init_user_reserve)
+
+/*
+ * Initialise sysctl_admin_reserve_kbytes.
+ *
+ * The purpose of sysctl_admin_reserve_kbytes is to allow the sys admin
+ * to log in and kill a memory hogging process.
+ *
+ * Systems with more than 256MB will reserve 8MB, enough to recover
+ * with sshd, bash, and top in OVERCOMMIT_GUESS. Smaller systems will
+ * only reserve 3% of free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free_kbytes;
+
+	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
+	return 0;
+}
+module_init(init_admin_reserve)
diff --git a/mm/nommu.c b/mm/nommu.c
index 0018362..fdba7132 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -64,6 +64,7 @@ int sysctl_overcommit_ratio = 50; /* default is 50% */
 int sysctl_max_map_count = DEFAULT_MAX_MAP_COUNT;
 int sysctl_nr_trim_pages = CONFIG_NOMMU_INITIAL_TRIM_EXCESS;
 unsigned long sysctl_user_reserve_kbytes __read_mostly = 1UL << 17; /* 128MB */
+unsigned long sysctl_admin_reserve_kbytes __read_mostly = 1UL << 13; /* 8MB */
 int heap_stack_gap = 0;
 
 atomic_long_t mmap_pages_allocated;
@@ -1924,10 +1925,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 			free -= totalreserve_pages;
 
 		/*
-		 * Leave the last 3% for root
+		 * Reserve some for root
 		 */
 		if (!cap_sys_admin)
-			free -= free / 32;
+			free -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
 
 		if (free > pages)
 			return 0;
@@ -1937,10 +1938,10 @@ int __vm_enough_memory(struct mm_struct *mm, long pages, int cap_sys_admin)
 
 	allowed = totalram_pages * sysctl_overcommit_ratio / 100;
 	/*
-	 * Leave the last 3% for root
+	 * Reserve some 3% for root
 	 */
 	if (!cap_sys_admin)
-		allowed -= allowed / 32;
+		allowed -= sysctl_admin_reserve_kbytes >> (PAGE_SHIFT - 10);
 	allowed += total_swap_pages;
 
 	/*
@@ -2132,3 +2133,24 @@ int __meminit init_user_reserve(void)
 	return 0;
 }
 module_init(init_user_reserve)
+
+/*
+ * Initialise sysctl_admin_reserve_kbytes.
+ *
+ * The purpose of sysctl_admin_reserve_kbytes is to allow the sys admin
+ * to log in and kill a memory hogging process.
+ *
+ * Systems with more than 256MB will reserve 8MB, enough to recover
+ * with sshd, bash, and top in OVERCOMMIT_GUESS. Smaller systems will
+ * only reserve 3% of free pages by default.
+ */
+int __meminit init_admin_reserve(void)
+{
+	unsigned long free_kbytes;
+
+	free_kbytes = global_page_state(NR_FREE_PAGES) << (PAGE_SHIFT - 10);
+
+	sysctl_admin_reserve_kbytes = min(free_kbytes / 32, 1UL << 13);
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
