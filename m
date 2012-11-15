Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 4D2436B0070
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:26:02 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v6 12/12] thp: introduce sysfs knob to disable huge zero page
Date: Thu, 15 Nov 2012 21:27:02 +0200
Message-Id: <1353007622-18393-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

By default kernel tries to use huge zero page on read page fault.
It's possible to disable huge zero page by writing 0 or enable it
back by writing 1:

echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/use_zero_page
echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/use_zero_page

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 Documentation/vm/transhuge.txt |  7 +++++++
 include/linux/huge_mm.h        |  4 ++++
 mm/huge_memory.c               | 21 +++++++++++++++++++--
 3 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/Documentation/vm/transhuge.txt b/Documentation/vm/transhuge.txt
index 60aeedd..8785fb8 100644
--- a/Documentation/vm/transhuge.txt
+++ b/Documentation/vm/transhuge.txt
@@ -116,6 +116,13 @@ echo always >/sys/kernel/mm/transparent_hugepage/defrag
 echo madvise >/sys/kernel/mm/transparent_hugepage/defrag
 echo never >/sys/kernel/mm/transparent_hugepage/defrag
 
+By default kernel tries to use huge zero page on read page fault.
+It's possible to disable huge zero page by writing 0 or enable it
+back by writing 1:
+
+echo 0 >/sys/kernel/mm/transparent_hugepage/khugepaged/use_zero_page
+echo 1 >/sys/kernel/mm/transparent_hugepage/khugepaged/use_zero_page
+
 khugepaged will be automatically started when
 transparent_hugepage/enabled is set to "always" or "madvise, and it'll
 be automatically shutdown if it's set to "never".
diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
index 856f080..a9f5bd4 100644
--- a/include/linux/huge_mm.h
+++ b/include/linux/huge_mm.h
@@ -35,6 +35,7 @@ enum transparent_hugepage_flag {
 	TRANSPARENT_HUGEPAGE_DEFRAG_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG,
 	TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG,
+	TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG,
 #ifdef CONFIG_DEBUG_VM
 	TRANSPARENT_HUGEPAGE_DEBUG_COW_FLAG,
 #endif
@@ -74,6 +75,9 @@ extern bool is_vma_temporary_stack(struct vm_area_struct *vma);
 	 (transparent_hugepage_flags &					\
 	  (1<<TRANSPARENT_HUGEPAGE_DEFRAG_REQ_MADV_FLAG) &&		\
 	  (__vma)->vm_flags & VM_HUGEPAGE))
+#define transparent_hugepage_use_zero_page()				\
+	(transparent_hugepage_flags &					\
+	 (1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG))
 #ifdef CONFIG_DEBUG_VM
 #define transparent_hugepage_debug_cow()				\
 	(transparent_hugepage_flags &					\
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index b104718..1f6c6de 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -38,7 +38,8 @@ unsigned long transparent_hugepage_flags __read_mostly =
 	(1<<TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG)|
 #endif
 	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_FLAG)|
-	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG);
+	(1<<TRANSPARENT_HUGEPAGE_DEFRAG_KHUGEPAGED_FLAG)|
+	(1<<TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
 
 /* default scan 8*512 pte (or vmas) every 30 second */
 static unsigned int khugepaged_pages_to_scan __read_mostly = HPAGE_PMD_NR*8;
@@ -356,6 +357,20 @@ static ssize_t defrag_store(struct kobject *kobj,
 static struct kobj_attribute defrag_attr =
 	__ATTR(defrag, 0644, defrag_show, defrag_store);
 
+static ssize_t use_zero_page_show(struct kobject *kobj,
+		struct kobj_attribute *attr, char *buf)
+{
+	return single_flag_show(kobj, attr, buf,
+				TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
+}
+static ssize_t use_zero_page_store(struct kobject *kobj,
+		struct kobj_attribute *attr, const char *buf, size_t count)
+{
+	return single_flag_store(kobj, attr, buf, count,
+				 TRANSPARENT_HUGEPAGE_USE_ZERO_PAGE_FLAG);
+}
+static struct kobj_attribute use_zero_page_attr =
+	__ATTR(use_zero_page, 0644, use_zero_page_show, use_zero_page_store);
 #ifdef CONFIG_DEBUG_VM
 static ssize_t debug_cow_show(struct kobject *kobj,
 				struct kobj_attribute *attr, char *buf)
@@ -377,6 +392,7 @@ static struct kobj_attribute debug_cow_attr =
 static struct attribute *hugepage_attr[] = {
 	&enabled_attr.attr,
 	&defrag_attr.attr,
+	&use_zero_page_attr.attr,
 #ifdef CONFIG_DEBUG_VM
 	&debug_cow_attr.attr,
 #endif
@@ -771,7 +787,8 @@ int do_huge_pmd_anonymous_page(struct mm_struct *mm, struct vm_area_struct *vma,
 			return VM_FAULT_OOM;
 		if (unlikely(khugepaged_enter(vma)))
 			return VM_FAULT_OOM;
-		if (!(flags & FAULT_FLAG_WRITE)) {
+		if (!(flags & FAULT_FLAG_WRITE) &&
+				transparent_hugepage_use_zero_page()) {
 			pgtable_t pgtable;
 			unsigned long zero_pfn;
 			pgtable = pte_alloc_one(mm, haddr);
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
