Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 1446B6B002C
	for <linux-mm@kvack.org>; Mon, 10 Oct 2011 09:59:11 -0400 (EDT)
Received: by vcbfo14 with SMTP id fo14so6350093vcb.14
        for <linux-mm@kvack.org>; Mon, 10 Oct 2011 06:59:08 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RFC PATCH] mm: thp: make swap configurable
Date: Mon, 10 Oct 2011 21:58:06 +0800
Message-Id: <1318255086-7393-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aarcange@redhat.com
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, hannes@cmpxchg.org, riel@redhat.com, Bob Liu <lliubbo@gmail.com>

Currently THP do swap by default, user has no control of it.
But some applications are swap sensitive, this patch add a boot param
and sys file to make it configurable.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 Documentation/vm/transhuge.txt |    9 +++++++++
 include/linux/huge_mm.h        |    5 +++++
 mm/huge_memory.c               |   26 ++++++++++++++++++++++++++
 mm/swap_state.c                |   10 ++++++----
 4 files changed, 46 insertions(+), 4 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 29bdf62..1c7d8e9 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -116,6 +116,12 @@ echo always >/sys/kernel/mm/transparent_hugepage/defrag
 echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
 echo never >/sys/kernel/mm/transparent_hugepage/defrag
 
+Swap for Transparent Hugepage default is enabled, you can disable it
+by:
+echo 1 > /sys/kernel/mm/transparent_hugepage/disable_swap
+and reenable by:
+echo 0 > /sys/kernel/mm/transparent_hugepage/disable_swap
+
 khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
 be automatically shutdown if it's set to "never".
@@ -159,6 +165,9 @@ Support by passing the parameter "transparent_hugepage=always" or
 "transparent_hugepage=madvise" or "transparent_hugepage=never"
 (without "") to the kernel command line.
 
+You can disable swap for Transparent Hugepage by passing parameter
+"disable_transparent_hugepage_swap".
+
 == Need of application restart ==
 
 The transparent_hugepage/enabled values only affect future
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 48c32eb..229ef7b 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -31,6 +31,7 @@ enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
+	TRANSPARENT_HUGEPAGE_SWAP_DISABLE_FLAG,
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
 #endif
@@ -65,6 +66,9 @@ extern pmd_t *page_check_address_pmd(struct page *page,
 	 (transparent_hugepage_flags &					\
 	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG) &&		\
 	  (__vma)->vm_flags & VM_HUGEPAGE))
+#define transparent_hugepage_swap_disable()				\
+	(transparent_hugepage_flags &					\
+	 (1<<TRANSPARENT_HUGEPAGE_SWAP_DISABLE_FLAG))
 #ifdef CONFIG_DEBUG_VM
 #define transparent_hugepage_debug_cow()				\
 	(transparent_hugepage_flags &					\
@@ -148,6 +152,7 @@ static inline struct page *compound_trans_head(struct page *page)
 #define hpage_nr_pages(x) 1
 
 #define transparent_hugepage_enabled(__vma) 0
+#define transparent_hugepage_swap_disable() 0
 
 #define transparent_hugepage_flags 0UL
 static inline int split_huge_page(struct page *page)
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index e2d1587..31aba4b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -293,6 +293,22 @@ static ssize_t defrag_store(struct kobject *kobj,
 static struct kobj_attribute defrag_attr =
 	__ATTR(defrag, 0644, defrag_show, defrag_store);
 
+static ssize_t disable_swap_show(struct kobject *kobj,
+			struct kobj_attribute *attr, char *buf)
+{
+	return single_flag_show(kobj, attr, buf,
+				TRANSPARENT_HUGEPAGE_SWAP_DISABLE_FLAG);
+}
+static ssize_t disable_swap_store(struct kobject *kobj,
+			struct kobj_attribute *attr,
+			const char *buf, size_t count)
+{
+	return single_flag_store(kobj, attr, buf, count,
+				TRANSPARENT_HUGEPAGE_SWAP_DISABLE_FLAG);
+}
+static struct kobj_attribute swap_attr =
+	__ATTR(disable_swap, 0644, disable_swap_show, disable_swap_store);
+
 #ifdef CONFIG_DEBUG_VM
 static ssize_t debug_cow_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf)
@@ -314,6 +330,7 @@ static struct kobj_attribute debug_cow_attr =
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
+	&swap_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
 #endif
@@ -1408,6 +1425,15 @@ out:
 	return ret;
 }
 
+static __init int disable_transparent_hugepage_swap(char *str)
+{
+	set_bit(TRANSPARENT_HUGEPAGE_SWAP_DISABLE_FLAG, &transparent_hugepage_flags);
+	printk(KERN_INFO "disable swap for transparent hugepage.\n");
+
+	return 0;
+}
+early_param("disable_transparent_hugepage_swap", disable_transparent_hugepage_swap);
+
 #define VM_NO_THP (VM_SPECIAL|VM_INSERTPAGE|VM_MIXEDMAP|VM_SAO| \
 		   VM_HUGETLB|VM_SHARED|VM_MAYSHARE)
 
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 4668046..3dfc4be 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -18,6 +18,7 @@
 #include <linux/backing-dev.h>
 #include <linux/pagevec.h>
 #include <linux/migrate.h>
+#include <linux/mm_inline.h>
 #include <linux/page_cgroup.h>
 
 #include <asm/pgtable.h>
@@ -155,10 +156,11 @@ int add_to_swap(struct page *page)
 		return 0;
 
 	if (unlikely(PageTransHuge(page)))
-		if (unlikely(split_huge_page(page))) {
-			swapcache_free(entry, NULL);
-			return 0;
-		}
+		if(!transparent_hugepage_swap_disable())
+			if (unlikely(split_huge_page(page))) {
+				swapcache_free(entry, NULL);
+				return 0;
+			}
 
 	/*
 	 * Radix-tree node allocations from PF_MEMALLOC contexts could
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
