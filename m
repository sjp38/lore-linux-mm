Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7366B0070
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 16:45:05 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so53066335pab.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 13:45:05 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id bh2si3388057pdb.234.2015.03.18.13.45.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Mar 2015 13:45:04 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 3/3] mm: idle memory tracking
Date: Wed, 18 Mar 2015 23:44:36 +0300
Message-ID: <0b70e70137aa5232cce44a69c0b5e320f2745f7d.1426706637.git.vdavydov@parallels.com>
In-Reply-To: <cover.1426706637.git.vdavydov@parallels.com>
References: <cover.1426706637.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Knowing the portion of memory that is not used by a certain application
or memory cgroup (idle memory) can be useful for partitioning the system
efficiently. Currently, the only means to estimate the amount of idle
memory provided by the kernel is /proc/PID/clear_refs. However, it has
two serious shortcomings:

 - it does not count unmapped file pages
 - it affects the reclaimer logic

This patch attempts to provide the userspace with the means to track
idle memory without the above mentioned limitations.

Usage:

 1. Write 1 to /proc/sys/vm/set_idle.

    This will set the IDLE flag for all user pages. The IDLE flag is cleared
    when the page is read or the ACCESS/YOUNG bit is cleared in any PTE pointing
    to the page. It is also cleared when the page is freed.

 2. Wait some time.

 3. Write 6 to /proc/PID/clear_refs for each PID of interest.

    This will clear the IDLE flag for recently accessed pages.

 4. Count the number of idle pages as reported by /proc/kpageflags. One may use
    /proc/PID/pagemap and/or /proc/kpagecgroup to filter pages that belong to a
    certain application/container.

To avoid interference with the memory reclaimer, this patch adds the
PG_young flag in addition to PG_idle. The PG_young flag is set if the
ACCESS/YOUNG bit is cleared at step 3. page_referenced() returns >= 1 if
the page has the PG_young flag set.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/filesystems/proc.txt     |    3 ++
 Documentation/vm/00-INDEX              |    2 ++
 Documentation/vm/idle_mem_tracking.txt |   23 ++++++++++++++
 Documentation/vm/pagemap.txt           |    4 +++
 fs/proc/page.c                         |   54 ++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c                     |   22 +++++++++++--
 include/linux/page-flags.h             |   12 +++++++
 include/uapi/linux/kernel-page-flags.h |    1 +
 kernel/sysctl.c                        |   14 +++++++++
 mm/Kconfig                             |   12 +++++++
 mm/debug.c                             |    4 +++
 mm/rmap.c                              |    7 +++++
 mm/swap.c                              |    2 ++
 13 files changed, 157 insertions(+), 3 deletions(-)
 create mode 100644 Documentation/vm/idle_mem_tracking.txt

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 8e36c7e3c345..9880ddb0383f 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -500,6 +500,9 @@ To reset the peak resident set size ("high water mark") to the process's
 current value:
     > echo 5 > /proc/PID/clear_refs
 
+To clear the idle bit (see Documentation/vm/idle_mem_tracking.txt)
+    > echo 6 > /proc/PID/clear_refs
+
 Any other value written to /proc/PID/clear_refs will have no effect.
 
 The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
diff --git a/Documentation/vm/00-INDEX b/Documentation/vm/00-INDEX
index 081c49777abb..bab92cf7e2e4 100644
--- a/Documentation/vm/00-INDEX
+++ b/Documentation/vm/00-INDEX
@@ -14,6 +14,8 @@ hugetlbpage.txt
 	- a brief summary of hugetlbpage support in the Linux kernel.
 hwpoison.txt
 	- explains what hwpoison is
+idle_memory_tracking.txt
+	- explains how to track idle memory
 ksm.txt
 	- how to use the Kernel Samepage Merging feature.
 numa
diff --git a/Documentation/vm/idle_mem_tracking.txt b/Documentation/vm/idle_mem_tracking.txt
new file mode 100644
index 000000000000..4ca9bfafc560
--- /dev/null
+++ b/Documentation/vm/idle_mem_tracking.txt
@@ -0,0 +1,23 @@
+Idle memory tracking
+--------------------
+
+Knowing the portion of user memory that has not been touched for a given period
+of time can be useful to tune memory cgroup limits and/or for job placement
+within a compute cluster. CONFIG_IDLE_MEM_TRACKING provides the userspace with
+the means to estimate the amount of idle memory. In order to do this one should
+
+ 1. Write 1 to /proc/sys/vm/set_idle.
+
+    This will set the IDLE flag for all user pages. The IDLE flag is cleared
+    when the page is read or the ACCESS/YOUNG bit is cleared in any PTE pointing
+    to the page. It is also cleared when the page is freed.
+
+ 2. Wait some time.
+
+ 3. Write 6 to /proc/PID/clear_refs for each PID of interest.
+
+    This will clear the IDLE flag for recently accessed pages.
+
+ 4. Count the number of idle pages as reported by /proc/kpageflags. One may use
+    /proc/PID/pagemap and/or /proc/kpagecgroup to filter pages that belong to a
+    certain application/container.
diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 1ddfa1367b03..4202e1d57d8c 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -64,6 +64,7 @@ There are four components to pagemap:
     22. THP
     23. BALLOON
     24. ZERO_PAGE
+    25. IDLE
 
  * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
    memory cgroup each page is charged to, indexed by PFN. Only available when
@@ -114,6 +115,9 @@ Short descriptions to the page flags:
 24. ZERO_PAGE
     zero page for pfn_zero or huge_zero page
 
+25. IDLE
+    page is idle (see Documentation/vm/idle_mem_tracking.txt)
+
     [IO related page flags]
  1. ERROR     IO error occurred
  3. UPTODATE  page has up-to-date data
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 70d23245dd43..766478d66458 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -182,6 +182,10 @@ u64 stable_page_flags(struct page *page)
 	u |= kpf_copy_bit(k, KPF_OWNER_PRIVATE,	PG_owner_priv_1);
 	u |= kpf_copy_bit(k, KPF_ARCH,		PG_arch_1);
 
+#ifdef CONFIG_IDLE_MEM_TRACKING
+	u |= kpf_copy_bit(k, KPF_IDLE,		PG_idle);
+#endif
+
 	return u;
 };
 
@@ -275,6 +279,56 @@ static const struct file_operations proc_kpagecgroup_operations = {
 };
 #endif /* CONFIG_MEMCG */
 
+#ifdef CONFIG_IDLE_MEM_TRACKING
+static void set_mem_idle_node(int nid)
+{
+	unsigned long start_pfn, end_pfn, pfn;
+	struct page *page;
+
+	start_pfn = node_start_pfn(nid);
+	end_pfn = node_end_pfn(nid);
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		if (need_resched())
+			cond_resched();
+
+		if (!pfn_valid(pfn))
+			continue;
+
+		page = pfn_to_page(pfn);
+		if (page_count(page) == 0 || !PageLRU(page))
+			continue;
+
+		if (unlikely(!get_page_unless_zero(page)))
+			continue;
+		if (unlikely(!PageLRU(page)))
+			goto next;
+
+		SetPageIdle(page);
+next:
+		put_page(page);
+	}
+}
+
+static void set_mem_idle(void)
+{
+	int nid;
+
+	for_each_online_node(nid)
+		set_mem_idle_node(nid);
+}
+
+int sysctl_set_mem_idle; /* unused */
+
+int sysctl_set_mem_idle_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	if (write)
+		set_mem_idle();
+	return 0;
+}
+#endif /* CONFIG_IDLE_MEM_TRACKING */
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 956b75d61809..b2b5ed1e10bb 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -458,7 +458,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
-	if (young || PageReferenced(page))
+	if (young || PageYoung(page) || PageReferenced(page))
 		mss->referenced += size;
 	mapcount = page_mapcount(page);
 	if (mapcount >= 2) {
@@ -733,6 +733,7 @@ enum clear_refs_types {
 	CLEAR_REFS_MAPPED,
 	CLEAR_REFS_SOFT_DIRTY,
 	CLEAR_REFS_MM_HIWATER_RSS,
+	CLEAR_REFS_IDLE,
 	CLEAR_REFS_LAST,
 };
 
@@ -806,6 +807,14 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 
 		page = pmd_page(*pmd);
 
+		if (cp->type == CLEAR_REFS_IDLE) {
+			if (pmdp_test_and_clear_young(vma, addr, pmd)) {
+				ClearPageIdle(page);
+				SetPageYoung(page);
+			}
+			goto out;
+		}
+
 		/* Clear accessed and referenced bits. */
 		pmdp_test_and_clear_young(vma, addr, pmd);
 		ClearPageReferenced(page);
@@ -833,6 +842,14 @@ out:
 		if (!page)
 			continue;
 
+		if (cp->type == CLEAR_REFS_IDLE) {
+			if (ptep_test_and_clear_young(vma, addr, pte)) {
+				ClearPageIdle(page);
+				SetPageYoung(page);
+			}
+			continue;
+		}
+
 		/* Clear accessed and referenced bits. */
 		ptep_test_and_clear_young(vma, addr, pte);
 		ClearPageReferenced(page);
@@ -852,10 +869,9 @@ static int clear_refs_test_walk(unsigned long start, unsigned long end,
 		return 1;
 
 	/*
-	 * Writing 1 to /proc/pid/clear_refs affects all pages.
+	 * Writing 1, 4, or 6 to /proc/pid/clear_refs affects all pages.
 	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
 	 * Writing 3 to /proc/pid/clear_refs only affects file mapped pages.
-	 * Writing 4 to /proc/pid/clear_refs affects all pages.
 	 */
 	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
 		return 1;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index c851ff92d5b3..8e06d11eb723 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,10 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_IDLE_MEM_TRACKING
+	PG_young,
+	PG_idle,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -289,6 +293,14 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+#ifdef CONFIG_IDLE_MEM_TRACKING
+PAGEFLAG(Young, young)
+PAGEFLAG(Idle, idle)
+#else
+PAGEFLAG_FALSE(Young)
+PAGEFLAG_FALSE(Idle)
+#endif
+
 u64 stable_page_flags(struct page *page);
 
 static inline int PageUptodate(struct page *page)
diff --git a/include/uapi/linux/kernel-page-flags.h b/include/uapi/linux/kernel-page-flags.h
index a6c4962e5d46..5da5f8751ce7 100644
--- a/include/uapi/linux/kernel-page-flags.h
+++ b/include/uapi/linux/kernel-page-flags.h
@@ -33,6 +33,7 @@
 #define KPF_THP			22
 #define KPF_BALLOON		23
 #define KPF_ZERO_PAGE		24
+#define KPF_IDLE		25
 
 
 #endif /* _UAPILINUX_KERNEL_PAGE_FLAGS_H */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index c1552633e159..54b9a0aa290f 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -112,6 +112,11 @@ extern int sysctl_nr_open_min, sysctl_nr_open_max;
 #ifndef CONFIG_MMU
 extern int sysctl_nr_trim_pages;
 #endif
+#ifdef CONFIG_IDLE_MEM_TRACKING
+extern int sysctl_set_mem_idle;
+extern int sysctl_set_mem_idle_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos);
+#endif
 
 /* Constants used for minimum and  maximum */
 #ifdef CONFIG_LOCKUP_DETECTOR
@@ -1512,6 +1517,15 @@ static struct ctl_table vm_table[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_doulongvec_minmax,
 	},
+#ifdef CONFIG_IDLE_MEM_TRACKING
+	{
+		.procname	= "set_idle",
+		.data		= &sysctl_set_mem_idle,
+		.maxlen		= sizeof(int),
+		.mode		= 0200,
+		.proc_handler	= sysctl_set_mem_idle_handler,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 390214da4546..c6d5e931f62c 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config IDLE_MEM_TRACKING
+	bool "Enable idle memory tracking"
+	depends on 64BIT
+	select PROC_PAGE_MONITOR
+	help
+	  This feature allows a userspace process to estimate the size of user
+	  memory that has not been touched during a given period of time. This
+	  information can be useful to tune memory cgroup limits and/or for job
+	  placement within a compute cluster.
+
+	  See Documentation/vm/idle_mem_tracking.txt for more details.
diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2fcee7..88468485a1f3 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -48,6 +48,10 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#ifdef CONFIG_IDLE_MEM_TRACKING
+	{1UL << PG_young,		"young"		},
+	{1UL << PG_idle,		"idle"		},
+#endif
 };
 
 static void dump_flags(unsigned long flags,
diff --git a/mm/rmap.c b/mm/rmap.c
index 8030382bbf5f..1afcc4db31e0 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -799,6 +799,13 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 	if (referenced) {
 		pra->referenced++;
 		pra->vm_flags |= vma->vm_flags;
+		if (PageIdle(page))
+			ClearPageIdle(page);
+	}
+
+	if (PageYoung(page)) {
+		ClearPageYoung(page);
+		pra->referenced++;
 	}
 
 	if (dirty)
diff --git a/mm/swap.c b/mm/swap.c
index cd3a5e64cea9..94e591ecd64b 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -615,6 +615,8 @@ void mark_page_accessed(struct page *page)
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
+	if (PageIdle(page))
+		ClearPageIdle(page);
 }
 EXPORT_SYMBOL(mark_page_accessed);
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
