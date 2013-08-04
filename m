Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id C42A26B0034
	for <linux-mm@kvack.org>; Sat,  3 Aug 2013 22:14:27 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 03/23] thp: compile-time and sysfs knob for thp pagecache
Date: Sun,  4 Aug 2013 05:17:05 +0300
Message-Id: <1375582645-29274-4-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1375582645-29274-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, Ning Qu <quning@google.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for x86_64.

Radix tree perload overhead can be significant on BASE_SMALL systems, so
let's add dependency on !BASE_SMALL.

/sys/kernel/mm/transparent_hugepage/page_cache is runtime knob for the
feature. It's enabled by default if TRANSPARENT_HUGEPAGE_PAGECACHE is
enabled.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt |  9 +++++++++
 include/linux/huge_mm.h        |  9 +++++++++
 mm/Kconfig                     | 12 ++++++++++++
 mm/huge_memory.c               | 23 +++++++++++++++++++++++
 4 files changed, 53 insertions(+)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 4a63953..4cc15c4 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -103,6 +103,15 @@ echo always >/sys/kernel/mm/transparent_hugepage/enabled
 echo madvise >/sys/kernel/mm/transparent_hugepage/enabled
 echo never >/sys/kernel/mm/transparent_hugepage/enabled
 
+If TRANSPARENT_HUGEPAGE_PAGECACHE is enabled kernel will use huge pages in
+page cache if possible. It can be disable and re-enabled via sysfs:
+
+echo 0 >/sys/kernel/mm/transparent_hugepage/page_cache
+echo 1 >/sys/kernel/mm/transparent_hugepage/page_cache
+
+If it's disabled kernel will not add new huge pages to page cache and
+split them on mapping, but already mapped pages will stay intakt.
+
 It's also possible to limit defrag efforts in the VM to generate
 hugepages in case they're not immediately free to madvise regions or
 to never try to defrag memory and simply fallback to regular pages
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 3935428..1534e1e 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -40,6 +40,7 @@ enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
+	TRANSPARENT_HUGEPAGE_PAGECACHE,
 	TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
@@ -229,4 +230,12 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline bool transparent_hugepage_pagecache(void)
+{
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
+		return false;
+	if (!(transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_FLAG)))
+		return false;
+	return transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_PAGECACHE);
+}
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index 256bfd0..1e30ee8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -420,6 +420,18 @@ choice
 	  benefit.
 endchoice
 
+config TRANSPARENT_HUGEPAGE_PAGECACHE
+	bool "Transparent Hugepage Support for page cache"
+	depends on X86_64 && TRANSPARENT_HUGEPAGE
+	# avoid radix tree preload overhead
+	depends on !BASE_SMALL
+	default y
+	help
+	  Enabling the option adds support hugepages for file-backed
+	  mappings. It requires transparent hugepage support from
+	  filesystem side. For now, the only filesystem which supports
+	  hugepages is ramfs.
+
 config CROSS_MEMORY_ATTACH
 	bool "Cross Memory Support"
 	depends on MMU
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index d96d921..523946c 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -42,6 +42,9 @@ unsigned long transparent_hugepage_flags __read_mostly =
 #endif
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+	(1<<TRANSPARENT_HUGEPAGE_PAGECACHE)|
+#endif
 	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
@@ -362,6 +365,23 @@ static ssize_t defrag_store(struct kobject *kobj,
 static struct kobj_attribute defrag_attr =
 	__ATTR(defrag, 0644, defrag_show, defrag_store);
 
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+static ssize_t page_cache_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	return single_flag_show(kobj, attr, buf,
+				TRANSPARENT_HUGEPAGE_PAGECACHE);
+}
+static ssize_t page_cache_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	return single_flag_store(kobj, attr, buf, count,
+				 TRANSPARENT_HUGEPAGE_PAGECACHE);
+}
+static struct kobj_attribute page_cache_attr =
+	__ATTR(page_cache, 0644, page_cache_show, page_cache_store);
+#endif
+
 static ssize_t use_zero_page_show(struct kobject *kobj,
 		struct kobj_attribute *attr, char *buf)
 {
@@ -397,6 +417,9 @@ static struct kobj_attribute debug_cow_attr =
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
+#ifdef CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE
+	&page_cache_attr.attr,
+#endif
 	&use_zero_page_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
-- 
1.8.3.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
