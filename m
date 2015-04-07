Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id E57B26B0070
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 07:55:41 -0400 (EDT)
Received: by pdbnk13 with SMTP id nk13so76839519pdb.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 04:55:41 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id by8si11072354pdb.43.2015.04.07.04.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 04:55:40 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [RFC v2 3/3] proc: add kpageidle file
Date: Tue, 7 Apr 2015 14:55:13 +0300
Message-ID: <4dea8fbf08775c349779c99df3dbb3459f1c1036.1428401673.git.vdavydov@parallels.com>
In-Reply-To: <cover.1428401673.git.vdavydov@parallels.com>
References: <cover.1428401673.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Knowing the portion of memory that is not used by a certain application
or memory cgroup (idle memory) can be useful for partitioning the system
efficiently, e.g. by setting memory cgroup limits appropriately.
Currently, the only means to estimate the amount of idle memory provided
by the kernel is /proc/PID/{clear_refs,smaps}: the user can clear the
access bit for all pages mapped to a particular process by writing 1 to
clear_refs, wait for some time, and then count smaps:Referenced.
However, this method has two serious shortcomings:

 - it does not count unmapped file pages
 - it affects the reclaimer logic

To overcome these drawbacks, this patch introduces two new page flags,
Idle and Young, and a new proc file, /proc/kpageidle. A page's Idle flag
can only be set from userspace by writing to /proc/kpageidle at the
offset corresponding to the page, and it is cleared whenever the page is
accessed either through page tables (it is cleared in page_referenced()
in this case) or using the read(2) system call (mark_page_accessed()).
Thus by setting the Idle flag for pages of a particular workload, which
can be found e.g. by reading /proc/PID/pagemap, waiting for some time to
let the workload access its working set, and then reading the kpageidle
file, one can estimate the amount of pages that are not used by the
workload.

The Young page flag is used to avoid interference with the memory
reclaimer. A page's Young flag is set whenever the Access bit of a page
table entry pointing to the page is cleared by writing to kpageidle. If
page_referenced() is called on a Young page, it will add 1 to its return
value, therefore concealing the fact that the Access bit was cleared.

Since this new feature adds two extra page flags, it is made dependant
on 64BIT, where we have plenty of space for page flags. We could use
page_ext to accomodate new flags on 32BIT, but this is left for the
future work.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 Documentation/vm/pagemap.txt |   17 ++++-
 fs/proc/page.c               |  149 ++++++++++++++++++++++++++++++++++++++++++
 fs/proc/task_mmu.c           |    4 +-
 include/linux/page-flags.h   |   12 ++++
 mm/Kconfig                   |   12 ++++
 mm/debug.c                   |    4 ++
 mm/rmap.c                    |    7 ++
 mm/swap.c                    |    2 +
 8 files changed, 205 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index 1ddfa1367b03..2ab2d5b98e8d 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
 userspace programs to examine the page tables and related information by
 reading files in /proc.
 
-There are four components to pagemap:
+There are five components to pagemap:
 
  * /proc/pid/pagemap.  This file lets a userspace process find out which
    physical frame each virtual page is mapped to.  It contains one 64-bit
@@ -69,6 +69,21 @@ There are four components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
+ * /proc/kpageidle.  For each page this file contains a 64-bit number, which
+   equals 1 if the page is idle or 0 otherwise. The file is indexed by PFN. To
+   set or clear a page's Idle flag, one can write 1 or 0 respectively to this
+   file at the offset corresponding to the page. It is only possible to modify
+   the Idle flag for user pages (pages that are on an LRU list, to be more
+   exact). For other page types, the input is silently ignored. Writing to this
+   file beyond max PFN results in the ENXIO error.
+
+   A page's Idle flag is automatically cleared whenever the page is accessed
+   (via a page table entry or using the read(2) system call). This makes this
+   file useful for tracking a workload's working set, i.e. the set of pages
+   that are actively used by the workload.
+
+   The file is only available when CONFIG_IDLE_PAGE_TRACKING is set.
+
 Short descriptions to the page flags:
 
  0. LOCKED
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 70d23245dd43..974498a4c4b4 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -275,6 +275,151 @@ static const struct file_operations proc_kpagecgroup_operations = {
 };
 #endif /* CONFIG_MEMCG */
 
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+static struct page *kpageidle_get_page(struct page *page)
+{
+	if (!page || page_count(page) == 0 || !PageLRU(page))
+		return NULL;
+	if (!get_page_unless_zero(page))
+		return NULL;
+	if (unlikely(!PageLRU(page))) {
+		put_page(page);
+		return NULL;
+	}
+	return page;
+}
+
+static void kpageidle_clear_refs(struct page *page)
+{
+	unsigned long dummy;
+
+	if (page_referenced(page, 0, NULL, &dummy, NULL))
+		SetPageYoung(page);
+}
+
+static u64 kpageidle_read_page_state(struct page *page)
+{
+	u64 state = 0;
+
+	page = kpageidle_get_page(page);
+	if (!page)
+		return 0;
+	if (PageIdle(page)) {
+		kpageidle_clear_refs(page);
+		if (PageIdle(page))
+			state = 1;
+	}
+	put_page(page);
+	return state;
+}
+
+static int kpageidle_write_page_state(struct page *page, u64 state)
+{
+	if (state != 0 && state != 1)
+		return -EINVAL;
+	page = kpageidle_get_page(page);
+	if (!page)
+		return 0;
+	if (state && !PageIdle(page)) {
+		kpageidle_clear_refs(page);
+		SetPageIdle(page);
+	} else if (!state && PageIdle(page))
+		ClearPageIdle(page);
+	put_page(page);
+	return 0;
+}
+
+static ssize_t kpageidle_read(struct file *file, char __user *buf,
+			      size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	struct page *ppage;
+	unsigned long src = *ppos;
+	unsigned long pfn;
+	ssize_t ret = 0;
+	u64 val;
+
+	pfn = src / KPMSIZE;
+	count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
+	if (src & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	while (count > 0) {
+		if (pfn_valid(pfn))
+			ppage = pfn_to_page(pfn);
+		else
+			ppage = NULL;
+
+		val = kpageidle_read_page_state(ppage);
+
+		if (put_user(val, out)) {
+			ret = -EFAULT;
+			break;
+		}
+
+		pfn++;
+		out++;
+		count -= KPMSIZE;
+	}
+
+	*ppos += (char __user *)out - buf;
+	if (!ret)
+		ret = (char __user *)out - buf;
+	return ret;
+}
+
+static ssize_t kpageidle_write(struct file *file, const char __user *buf,
+			       size_t count, loff_t *ppos)
+{
+	const u64 __user *in = (u64 __user *)buf;
+	struct page *ppage;
+	unsigned long src = *ppos;
+	unsigned long pfn;
+	ssize_t ret = 0;
+	u64 val;
+
+	pfn = src / KPMSIZE;
+	if (src & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	while (count > 0) {
+		if (pfn >= max_pfn) {
+			if ((char __user *)in == buf)
+				ret = -ENXIO;
+			break;
+		}
+		if (pfn_valid(pfn))
+			ppage = pfn_to_page(pfn);
+		else
+			ppage = NULL;
+
+		if (get_user(val, in)) {
+			ret = -EFAULT;
+			break;
+		}
+
+		ret = kpageidle_write_page_state(ppage, val);
+		if (ret)
+			break;
+
+		pfn++;
+		in++;
+		count -= KPMSIZE;
+	}
+
+	*ppos += (char __user *)in - buf;
+	if (!ret)
+		ret = (char __user *)in - buf;
+	return ret;
+}
+
+static const struct file_operations proc_kpageidle_operations = {
+	.llseek = mem_lseek,
+	.read = kpageidle_read,
+	.write = kpageidle_write,
+};
+#endif /* CONFIG_IDLE_PAGE_TRACKING */
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
@@ -282,6 +427,10 @@ static int __init proc_page_init(void)
 #ifdef CONFIG_MEMCG
 	proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
 #endif
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+	proc_create("kpageidle", S_IRUSR | S_IWUSR, NULL,
+		    &proc_kpageidle_operations);
+#endif
 	return 0;
 }
 fs_initcall(proc_page_init);
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 6dee68d013ff..5ed5f707cac3 100644
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
@@ -808,6 +808,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 
 		/* Clear accessed and referenced bits. */
 		pmdp_test_and_clear_young(vma, addr, pmd);
+		ClearPageYoung(page);
 		ClearPageReferenced(page);
 out:
 		spin_unlock(ptl);
@@ -835,6 +836,7 @@ out:
 
 		/* Clear accessed and referenced bits. */
 		ptep_test_and_clear_young(vma, addr, pte);
+		ClearPageYoung(page);
 		ClearPageReferenced(page);
 	}
 	pte_unmap_unlock(pte - 1, ptl);
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 91b7f9b2b774..e53afb2738f8 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,10 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+	PG_young,
+	PG_idle,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -363,6 +367,14 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+PAGEFLAG(Young, young, PF_HEAD)
+PAGEFLAG(Idle, idle, PF_HEAD)
+#else
+PAGEFLAG_FALSE(Young)
+PAGEFLAG_FALSE(Idle)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/mm/Kconfig b/mm/Kconfig
index 390214da4546..880dffd9fce1 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config IDLE_PAGE_TRACKING
+	bool "Enable idle page tracking"
+	depends on 64BIT
+	select PROC_PAGE_MONITOR
+	help
+	  This feature allows to estimate the amount of user pages that have
+	  not been touched during a given period of time. This information can
+	  be useful to tune memory cgroup limits and/or for job placement
+	  within a compute cluster.
+
+	  See Documentation/vm/pagemap.txt for more details.
diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2fcee7..25d58478f59b 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -48,6 +48,10 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+	{1UL << PG_young,		"young"		},
+	{1UL << PG_idle,		"idle"		},
+#endif
 };
 
 static void dump_flags(unsigned long flags,
diff --git a/mm/rmap.c b/mm/rmap.c
index dad23a43e42c..b6ead8a13185 100644
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
index 8773de093171..bee91fab10fc 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -624,6 +624,8 @@ void mark_page_accessed(struct page *page)
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
