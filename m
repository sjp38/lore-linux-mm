Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 383D46B0070
	for <linux-mm@kvack.org>; Mon, 20 Aug 2012 09:52:45 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v4 8/8] mm: implement vm.clear_huge_page_nocache sysctl
Date: Mon, 20 Aug 2012 16:52:37 +0300
Message-Id: <1345470757-12005-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1345470757-12005-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1345470757-12005-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, Andi Kleen <ak@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Alex Shi <alex.shu@intel.com>, Jan Beulich <jbeulich@novell.com>, Robert Richter <robert.richter@amd.com>, Andy Lutomirski <luto@amacapital.net>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mips@linux-mips.org, linux-sh@vger.kernel.org, sparclinux@vger.kernel.org

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

In some cases cache avoiding clearing huge page may slow down workload.
Let's provide an sysctl handle to disable it.

We use static_key here to avoid extra work on fast path.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/sysctl/vm.txt |   13 ++++++++++++
 include/linux/mm.h          |    5 ++++
 kernel/sysctl.c             |   12 +++++++++++
 mm/memory.c                 |   44 +++++++++++++++++++++++++++++++++++++-----
 4 files changed, 68 insertions(+), 6 deletions(-)

diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
index 078701f..9559a97 100644
--- a/Documentation/sysctl/vm.txt
+++ b/Documentation/sysctl/vm.txt
@@ -19,6 +19,7 @@ files can be found in mm/swap.c.
 Currently, these files are in /proc/sys/vm:
 
 - block_dump
+- clear_huge_page_nocache
 - compact_memory
 - dirty_background_bytes
 - dirty_background_ratio
@@ -74,6 +75,18 @@ huge pages although processes will also directly compact memory as required.
 
 ==============================================================
 
+clear_huge_page_nocache
+
+Available only when the architecture provides ARCH_HAS_USER_NOCACHE and
+CONFIG_TRANSPARENT_HUGEPAGE or CONFIG_HUGETLBFS is set.
+
+When set to 1 (default) kernel will use cache avoiding clear routine for
+clearing huge pages. This minimize cache pollution.
+When set to 0 kernel will clear huge pages through cache. This may speed
+up some workloads. Also it's useful for benchmarking propose.
+
+==============================================================
+
 dirty_background_bytes
 
 Contains the amount of dirty memory at which the background kernel
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 2858723..9b48f43 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1643,6 +1643,11 @@ extern void clear_huge_page(struct page *page,
 extern void copy_user_huge_page(struct page *dst, struct page *src,
 				unsigned long addr, struct vm_area_struct *vma,
 				unsigned int pages_per_huge_page);
+#ifdef ARCH_HAS_USER_NOCACHE
+extern int sysctl_clear_huge_page_nocache;
+extern int clear_huge_page_nocache_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos);
+#endif
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE || CONFIG_HUGETLBFS */
 
 #ifdef CONFIG_DEBUG_PAGEALLOC
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 87174ef..80ccc67 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1366,6 +1366,18 @@ static struct ctl_table vm_table[] = {
 		.extra2		= &one,
 	},
 #endif
+#if defined(ARCH_HAS_USER_NOCACHE) && \
+	(defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS))
+	{
+		.procname	= "clear_huge_page_nocache",
+		.data		= &sysctl_clear_huge_page_nocache,
+		.maxlen		= sizeof(sysctl_clear_huge_page_nocache),
+		.mode		= 0644,
+		.proc_handler	= clear_huge_page_nocache_handler,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+#endif
 	{ }
 };
 
diff --git a/mm/memory.c b/mm/memory.c
index 625ca33..395d574 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -57,6 +57,7 @@
 #include <linux/swapops.h>
 #include <linux/elf.h>
 #include <linux/gfp.h>
+#include <linux/static_key.h>
 
 #include <asm/io.h>
 #include <asm/pgalloc.h>
@@ -3970,12 +3971,43 @@ EXPORT_SYMBOL(might_fault);
 
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) || defined(CONFIG_HUGETLBFS)
 
-#ifndef ARCH_HAS_USER_NOCACHE
-#define ARCH_HAS_USER_NOCACHE 0
-#endif
+#ifdef ARCH_HAS_USER_NOCACHE
+int sysctl_clear_huge_page_nocache = 1;
+static DEFINE_MUTEX(sysctl_clear_huge_page_nocache_lock);
+static struct static_key clear_huge_page_nocache __read_mostly =
+	STATIC_KEY_INIT_TRUE;
 
-#if ARCH_HAS_USER_NOCACHE == 0
+static inline int is_nocache_enabled(void)
+{
+	return static_key_true(&clear_huge_page_nocache);
+}
+
+int clear_huge_page_nocache_handler(struct ctl_table *table, int write,
+		void __user *buffer, size_t *length, loff_t *ppos)
+{
+	int orig_value = sysctl_clear_huge_page_nocache;
+	int ret;
+
+	mutex_lock(&sysctl_clear_huge_page_nocache_lock);
+	orig_value = sysctl_clear_huge_page_nocache;
+	ret = proc_dointvec_minmax(table, write, buffer, length, ppos);
+	if (!ret && write && sysctl_clear_huge_page_nocache != orig_value) {
+		if (sysctl_clear_huge_page_nocache)
+			static_key_slow_inc(&clear_huge_page_nocache);
+		else
+			static_key_slow_dec(&clear_huge_page_nocache);
+	}
+	mutex_unlock(&sysctl_clear_huge_page_nocache_lock);
+
+	return ret;
+}
+#else
 #define clear_user_highpage_nocache clear_user_highpage
+
+static inline int is_nocache_enabled(void)
+{
+	return 0;
+}
 #endif
 
 static void clear_gigantic_page(struct page *page,
@@ -3991,7 +4023,7 @@ static void clear_gigantic_page(struct page *page,
 	for (i = 0, vaddr = haddr; i < pages_per_huge_page;
 			i++, p = mem_map_next(p, page, i), vaddr += PAGE_SIZE) {
 		cond_resched();
-		if (!ARCH_HAS_USER_NOCACHE  || i == target)
+		if (!is_nocache_enabled() || i == target)
 			clear_user_highpage(p, vaddr);
 		else
 			clear_user_highpage_nocache(p, vaddr);
@@ -4015,7 +4047,7 @@ void clear_huge_page(struct page *page,
 	for (i = 0, vaddr = haddr; i < pages_per_huge_page;
 			i++, page++, vaddr += PAGE_SIZE) {
 		cond_resched();
-		if (!ARCH_HAS_USER_NOCACHE || i == target)
+		if (!is_nocache_enabled() || i == target)
 			clear_user_highpage(page, vaddr);
 		else
 			clear_user_highpage_nocache(page, vaddr);
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
