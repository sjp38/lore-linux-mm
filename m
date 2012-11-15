Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id 039166B004D
	for <linux-mm@kvack.org>; Thu, 15 Nov 2012 14:25:56 -0500 (EST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH v6 01/12] thp: huge zero page: basic preparation
Date: Thu, 15 Nov 2012 21:26:51 +0200
Message-Id: <1353007622-18393-2-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1353007622-18393-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Andi Kleen <ak@linux.intel.com>, "H. Peter Anvin" <hpa@linux.intel.com>, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill@shutemov.name>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Huge zero page (hzp) is a non-movable huge page (2M on x86-64) filled
with zeros.

For now let's allocate the page on hugepage_init(). We'll switch to lazy
allocation later.

We are not going to map the huge zero page until we can handle it
properly on all code paths.

is_huge_zero_{pfn,pmd}() functions will be used by following patches to
check whether the pfn/pmd is huge zero page.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: David Rientjes <rientjes@google.com>
---
 mm/huge_memory.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 40f17c3..8d7a54b 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -47,6 +47,7 @@ static unsigned int khugepaged_scan_sleep_millisecs __read_mostly = 10000;
 /* during fragmentation poll the hugepage allocator once every minute */
 static unsigned int khugepaged_alloc_sleep_millisecs __read_mostly = 60000;
 static struct task_struct *khugepaged_thread __read_mostly;
+static unsigned long huge_zero_pfn __read_mostly;
 static DEFINE_MUTEX(khugepaged_mutex);
 static DEFINE_SPINLOCK(khugepaged_mm_lock);
 static DECLARE_WAIT_QUEUE_HEAD(khugepaged_wait);
@@ -159,6 +160,29 @@ static int start_khugepaged(void)
 	return err;
 }
 
+static int __init init_huge_zero_page(void)
+{
+	struct page *hpage;
+
+	hpage = alloc_pages((GFP_TRANSHUGE | __GFP_ZERO) & ~__GFP_MOVABLE,
+			HPAGE_PMD_ORDER);
+	if (!hpage)
+		return -ENOMEM;
+
+	huge_zero_pfn = page_to_pfn(hpage);
+	return 0;
+}
+
+static inline bool is_huge_zero_pfn(unsigned long pfn)
+{
+	return pfn == huge_zero_pfn;
+}
+
+static inline bool is_huge_zero_pmd(pmd_t pmd)
+{
+	return is_huge_zero_pfn(pmd_pfn(pmd));
+}
+
 #ifdef CONFIG_SYSFS
 
 static ssize_t double_flag_show(struct kobject *kobj,
@@ -540,6 +564,10 @@ static int __init hugepage_init(void)
 	if (err)
 		return err;
 
+	err = init_huge_zero_page();
+	if (err)
+		goto out;
+
 	err = khugepaged_slab_init();
 	if (err)
 		goto out;
@@ -562,6 +590,8 @@ static int __init hugepage_init(void)
 
 	return 0;
 out:
+	if (huge_zero_pfn)
+		__free_page(pfn_to_page(huge_zero_pfn));
 	hugepage_exit_sysfs(hugepage_kobj);
 	return err;
 }
-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
