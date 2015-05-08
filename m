Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 657186B0032
	for <linux-mm@kvack.org>; Fri,  8 May 2015 09:21:44 -0400 (EDT)
Received: by pdea3 with SMTP id a3so83548410pde.3
        for <linux-mm@kvack.org>; Fri, 08 May 2015 06:21:44 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id z2si7092021par.230.2015.05.08.06.20.51
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 May 2015 06:20:51 -0700 (PDT)
Date: Fri, 8 May 2015 16:20:34 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH v4 3/3] proc: add kpageidle file
Message-ID: <20150508132034.GP31732@esperanza>
References: <cover.1431002699.git.vdavydov@parallels.com>
 <6af563e62c4ab5fdfe336410ad5df9d6540267cc.1431002699.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <6af563e62c4ab5fdfe336410ad5df9d6540267cc.1431002699.git.vdavydov@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Oops, this patch is stale, the correct one is here:
---
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH] proc: add kpageidle file

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
can only be set from userspace by setting bit in /proc/kpageidle at the
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

Note, since there is no room for extra page flags on 32 bit, this
feature uses extended page flags when compiled on 32 bit.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>

diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
index a9b7afc8fbc6..c9266340852c 100644
--- a/Documentation/vm/pagemap.txt
+++ b/Documentation/vm/pagemap.txt
@@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
 userspace programs to examine the page tables and related information by
 reading files in /proc.
 
-There are four components to pagemap:
+There are five components to pagemap:
 
  * /proc/pid/pagemap.  This file lets a userspace process find out which
    physical frame each virtual page is mapped to.  It contains one 64-bit
@@ -69,6 +69,16 @@ There are four components to pagemap:
    memory cgroup each page is charged to, indexed by PFN. Only available when
    CONFIG_MEMCG is set.
 
+ * /proc/kpageidle.  This file implements a bitmap where each bit corresponds
+   to a page, indexed by PFN. When the bit is set, the corresponding page is
+   idle. A page is considered idle if it has not been accessed since it was
+   marked idle. To mark a page idle one should set the bit corresponding to the
+   page by writing to the file. A value written to the file is OR-ed with the
+   current bitmap value. Only user memory pages can be marked idle, for other
+   page types input is silently ignored. Writing to this file beyond max PFN
+   results in the ENXIO error. Only available when CONFIG_IDLE_PAGE_TRACKING is
+   set.
+
 Short descriptions to the page flags:
 
  0. LOCKED
diff --git a/fs/proc/page.c b/fs/proc/page.c
index 70d23245dd43..5c055a7eee54 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -16,6 +16,7 @@
 
 #define KPMSIZE sizeof(u64)
 #define KPMMASK (KPMSIZE - 1)
+#define KPMBITS (KPMSIZE * BITS_PER_BYTE)
 
 /* /proc/kpagecount - an array exposing page counts
  *
@@ -275,6 +276,173 @@ static const struct file_operations proc_kpagecgroup_operations = {
 };
 #endif /* CONFIG_MEMCG */
 
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+/*
+ * Idle page tracking only considers user memory pages, for other types of
+ * pages the idle flag is always unset and an attempt to set it is silently
+ * ignored.
+ *
+ * We treat a page as a user memory page if it has the LRU flag set, because it
+ * is always safe to pass such a page to page_referenced(), which is essential
+ * for idle page tracking. With such an indicator of user pages we can skip
+ * isolated pages, but since there are not usually many of them, it should not
+ * affect the overall result.
+ *
+ * This function tries to get a user memory page by pfn as described above.
+ */
+static struct page *kpageidle_get_page(unsigned long pfn)
+{
+	struct page *page;
+
+	if (!pfn_valid(pfn))
+		return NULL;
+	page = pfn_to_page(pfn);
+	if (!page || !PageLRU(page))
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
+/*
+ * This function calls page_referenced() to clear the referenced bit for all
+ * mappings to a page. Since the latter also clears the page idle flag if the
+ * page was referenced, it can be used to update the idle flag of a page.
+ */
+static void kpageidle_clear_pte_refs(struct page *page)
+{
+	unsigned long dummy;
+
+	if (page_referenced(page, 0, NULL, &dummy))
+		/*
+		 * We cleared the referenced bit in a mapping to this page. To
+		 * avoid interference with the reclaimer, mark it young so that
+		 * the next call to page_referenced() will also return > 0 (see
+		 * page_referenced_one())
+		 */
+		set_page_young(page);
+}
+
+static ssize_t kpageidle_read(struct file *file, char __user *buf,
+			      size_t count, loff_t *ppos)
+{
+	u64 __user *out = (u64 __user *)buf;
+	struct page *page;
+	unsigned long pfn, end_pfn;
+	ssize_t ret = 0;
+	u64 idle_bitmap = 0;
+	int bit;
+
+	if (*ppos & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	pfn = *ppos * BITS_PER_BYTE;
+	if (pfn >= max_pfn)
+		return 0;
+
+	end_pfn = pfn + count * BITS_PER_BYTE;
+	if (end_pfn > max_pfn)
+		end_pfn = ALIGN(max_pfn, KPMBITS);
+
+	for (; pfn < end_pfn; pfn++) {
+		bit = pfn % KPMBITS;
+		page = kpageidle_get_page(pfn);
+		if (page) {
+			if (page_is_idle(page)) {
+				/*
+				 * The page might have been referenced via a
+				 * pte, in which case it is not idle. Clear
+				 * refs and recheck.
+				 */
+				kpageidle_clear_pte_refs(page);
+				if (page_is_idle(page))
+					idle_bitmap |= 1ULL << bit;
+			}
+			put_page(page);
+		}
+		if (bit == KPMBITS - 1) {
+			if (put_user(idle_bitmap, out)) {
+				ret = -EFAULT;
+				break;
+			}
+			idle_bitmap = 0;
+			out++;
+		}
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
+	const u64 __user *in = (const u64 __user *)buf;
+	struct page *page;
+	unsigned long pfn, end_pfn;
+	ssize_t ret = 0;
+	u64 idle_bitmap = 0;
+	int bit;
+
+	if (*ppos & KPMMASK || count & KPMMASK)
+		return -EINVAL;
+
+	pfn = *ppos * BITS_PER_BYTE;
+	if (pfn >= max_pfn)
+		return -ENXIO;
+
+	end_pfn = pfn + count * BITS_PER_BYTE;
+	if (end_pfn > max_pfn)
+		end_pfn = ALIGN(max_pfn, KPMBITS);
+
+	for (; pfn < end_pfn; pfn++) {
+		bit = pfn % KPMBITS;
+		if (bit == 0) {
+			if (get_user(idle_bitmap, in)) {
+				ret = -EFAULT;
+				break;
+			}
+			in++;
+		}
+		if (idle_bitmap >> bit & 1) {
+			page = kpageidle_get_page(pfn);
+			if (page) {
+				kpageidle_clear_pte_refs(page);
+				set_page_idle(page);
+				put_page(page);
+			}
+		}
+	}
+
+	*ppos += (const char __user *)in - buf;
+	if (!ret)
+		ret = (const char __user *)in - buf;
+	return ret;
+}
+
+static const struct file_operations proc_kpageidle_operations = {
+	.llseek = mem_lseek,
+	.read = kpageidle_read,
+	.write = kpageidle_write,
+};
+
+#ifndef CONFIG_64BIT
+static bool need_page_idle(void)
+{
+	return true;
+}
+struct page_ext_operations page_idle_ops = {
+	.need = need_page_idle,
+};
+#endif
+#endif /* CONFIG_IDLE_PAGE_TRACKING */
+
 static int __init proc_page_init(void)
 {
 	proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
@@ -282,6 +450,10 @@ static int __init proc_page_init(void)
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
index 6dee68d013ff..ab04846f7dd5 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -458,7 +458,7 @@ static void smaps_account(struct mem_size_stats *mss, struct page *page,
 
 	mss->resident += size;
 	/* Accumulate the size in pages that have been accessed. */
-	if (young || PageReferenced(page))
+	if (young || page_is_young(page) || PageReferenced(page))
 		mss->referenced += size;
 	mapcount = page_mapcount(page);
 	if (mapcount >= 2) {
@@ -808,6 +808,7 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
 
 		/* Clear accessed and referenced bits. */
 		pmdp_test_and_clear_young(vma, addr, pmd);
+		clear_page_young(page);
 		ClearPageReferenced(page);
 out:
 		spin_unlock(ptl);
@@ -835,6 +836,7 @@ out:
 
 		/* Clear accessed and referenced bits. */
 		ptep_test_and_clear_young(vma, addr, pte);
+		clear_page_young(page);
 		ClearPageReferenced(page);
 	}
 	pte_unmap_unlock(pte - 1, ptl);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0755b9fd03a7..794d29aa2317 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2200,5 +2200,93 @@ void __init setup_nr_node_ids(void);
 static inline void setup_nr_node_ids(void) {}
 #endif
 
+#ifdef CONFIG_IDLE_PAGE_TRACKING
+#ifdef CONFIG_64BIT
+static inline bool page_is_young(struct page *page)
+{
+	return PageYoung(page);
+}
+
+static inline void set_page_young(struct page *page)
+{
+	SetPageYoung(page);
+}
+
+static inline void clear_page_young(struct page *page)
+{
+	ClearPageYoung(page);
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return PageIdle(page);
+}
+
+static inline void set_page_idle(struct page *page)
+{
+	SetPageIdle(page);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	ClearPageIdle(page);
+}
+#else /* !CONFIG_64BIT */
+/*
+ * If there is not enough space to store Idle and Young bits in page flags, use
+ * page ext flags instead.
+ */
+extern struct page_ext_operations page_idle_ops;
+
+static inline bool page_is_young(struct page *page)
+{
+	return test_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline void set_page_young(struct page *page)
+{
+	set_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline void clear_page_young(struct page *page)
+{
+	clear_bit(PAGE_EXT_YOUNG, &lookup_page_ext(page)->flags);
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return test_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+
+static inline void set_page_idle(struct page *page)
+{
+	set_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+	clear_bit(PAGE_EXT_IDLE, &lookup_page_ext(page)->flags);
+}
+#endif /* CONFIG_64BIT */
+#else /* !CONFIG_IDLE_PAGE_TRACKING */
+static inline bool page_is_young(struct page *page)
+{
+	return false;
+}
+
+static inline void clear_page_young(struct page *page)
+{
+}
+
+static inline bool page_is_idle(struct page *page)
+{
+	return false;
+}
+
+static inline void clear_page_idle(struct page *page)
+{
+}
+#endif /* CONFIG_IDLE_PAGE_TRACKING */
+
 #endif /* __KERNEL__ */
 #endif /* _LINUX_MM_H */
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index f34e040b34e9..5e7c4f50a644 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -109,6 +109,10 @@ enum pageflags {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	PG_compound_lock,
 #endif
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
+	PG_young,
+	PG_idle,
+#endif
 	__NR_PAGEFLAGS,
 
 	/* Filesystems */
@@ -289,6 +293,11 @@ PAGEFLAG_FALSE(HWPoison)
 #define __PG_HWPOISON 0
 #endif
 
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
+PAGEFLAG(Young, young)
+PAGEFLAG(Idle, idle)
+#endif
+
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
diff --git a/include/linux/page_ext.h b/include/linux/page_ext.h
index c42981cd99aa..17f118a82854 100644
--- a/include/linux/page_ext.h
+++ b/include/linux/page_ext.h
@@ -26,6 +26,10 @@ enum page_ext_flags {
 	PAGE_EXT_DEBUG_POISON,		/* Page is poisoned */
 	PAGE_EXT_DEBUG_GUARD,
 	PAGE_EXT_OWNER,
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
+	PAGE_EXT_YOUNG,
+	PAGE_EXT_IDLE,
+#endif
 };
 
 /*
diff --git a/mm/Kconfig b/mm/Kconfig
index 390214da4546..3600eace4774 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -635,3 +635,15 @@ config MAX_STACK_SIZE_MB
 	  changed to a smaller value in which case that is used.
 
 	  A sane initial value is 80 MB.
+
+config IDLE_PAGE_TRACKING
+	bool "Enable idle page tracking"
+	select PROC_PAGE_MONITOR
+	select PAGE_EXTENSION if !64BIT
+	help
+	  This feature allows to estimate the amount of user pages that have
+	  not been touched during a given period of time. This information can
+	  be useful to tune memory cgroup limits and/or for job placement
+	  within a compute cluster.
+
+	  See Documentation/vm/pagemap.txt for more details.
diff --git a/mm/debug.c b/mm/debug.c
index 3eb3ac2fcee7..bb66f9ccec03 100644
--- a/mm/debug.c
+++ b/mm/debug.c
@@ -48,6 +48,10 @@ static const struct trace_print_flags pageflag_names[] = {
 #ifdef CONFIG_TRANSPARENT_HUGEPAGE
 	{1UL << PG_compound_lock,	"compound_lock"	},
 #endif
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
+	{1UL << PG_young,		"young"		},
+	{1UL << PG_idle,		"idle"		},
+#endif
 };
 
 static void dump_flags(unsigned long flags,
diff --git a/mm/page_ext.c b/mm/page_ext.c
index d86fd2f5353f..e4b3af054bf2 100644
--- a/mm/page_ext.c
+++ b/mm/page_ext.c
@@ -59,6 +59,9 @@ static struct page_ext_operations *page_ext_ops[] = {
 #ifdef CONFIG_PAGE_OWNER
 	&page_owner_ops,
 #endif
+#if defined(CONFIG_IDLE_PAGE_TRACKING) && !defined(CONFIG_64BIT)
+	&page_idle_ops,
+#endif
 };
 
 static unsigned long total_usage;
diff --git a/mm/rmap.c b/mm/rmap.c
index 24dd3f9fee27..eca7416f55d7 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -781,6 +781,14 @@ static int page_referenced_one(struct page *page, struct vm_area_struct *vma,
 		pte_unmap_unlock(pte, ptl);
 	}
 
+	if (referenced && page_is_idle(page))
+		clear_page_idle(page);
+
+	if (page_is_young(page)) {
+		clear_page_young(page);
+		referenced++;
+	}
+
 	if (referenced) {
 		pra->referenced++;
 		pra->vm_flags |= vma->vm_flags;
diff --git a/mm/swap.c b/mm/swap.c
index a7251a8ed532..6bf6f293a9ea 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -623,6 +623,8 @@ void mark_page_accessed(struct page *page)
 	} else if (!PageReferenced(page)) {
 		SetPageReferenced(page);
 	}
+	if (page_is_idle(page))
+		clear_page_idle(page);
 }
 EXPORT_SYMBOL(mark_page_accessed);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
