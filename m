Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 288FE6B0037
	for <linux-mm@kvack.org>; Sat, 11 May 2013 21:21:34 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 08/39] thp: compile-time and sysfs knob for thp pagecache
Date: Sun, 12 May 2013 04:23:05 +0300
Message-Id: <1368321816-17719-9-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1368321816-17719-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, Dave Hansen <dave@sr71.net>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

For now, TRANSPARENT_HUGEPAGE_PAGECACHE is only implemented for X86_64.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/huge_mm.h |    7 +++++++
 mm/Kconfig              |   10 ++++++++++
 mm/huge_memory.c        |   19 +++++++++++++++++++
 3 files changed, 36 insertions(+)

diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 6b4c9b2..88b44e2 100644
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
@@ -240,4 +241,10 @@ static inline int do_huge_pmd_numa_page(struct mm_struct *mm, struct vm_area_str
 
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
+static inline bool transparent_hugepage_pagecache(void)
+{
+	if (!IS_ENABLED(CONFIG_TRANSPARENT_HUGEPAGE_PAGECACHE))
+		return 0;
+	return transparent_hugepage_flags & (1<<TRANSPARENT_HUGEPAGE_PAGECACHE);
+}
 #endif /* _LINUX_HUGE_MM_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index e742d06..3a271b7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -420,6 +420,16 @@ choice
 	  benefit.
 endchoice
 
+config TRANSPARENT_HUGEPAGE_PAGECACHE
+	bool "Transparent Hugepage Support for page cache"
+	depends on X86_64 && TRANSPARENT_HUGEPAGE
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
index b39fa01..bd8ef7f 100644
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
@@ -357,6 +360,21 @@ static ssize_t defrag_store(struct kobject *kobj,
 static struct kobj_attribute defrag_attr =
 	__ATTR(defrag, 0644, defrag_show, defrag_store);
 
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
+
 static ssize_t use_zero_page_show(struct kobject *kobj,
 		struct kobj_attribute *attr, char *buf)
 {
@@ -392,6 +410,7 @@ static struct kobj_attribute debug_cow_attr =
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
+	&page_cache_attr.attr,
 	&use_zero_page_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
