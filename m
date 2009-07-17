Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 75FC66B006A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 13:28:24 -0400 (EDT)
From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 06/10] ksm: identify PageKsm pages
Date: Fri, 17 Jul 2009 20:30:46 +0300
Message-Id: <1247851850-4298-7-git-send-email-ieidus@redhat.com>
In-Reply-To: <1247851850-4298-6-git-send-email-ieidus@redhat.com>
References: <1247851850-4298-1-git-send-email-ieidus@redhat.com>
 <1247851850-4298-2-git-send-email-ieidus@redhat.com>
 <1247851850-4298-3-git-send-email-ieidus@redhat.com>
 <1247851850-4298-4-git-send-email-ieidus@redhat.com>
 <1247851850-4298-5-git-send-email-ieidus@redhat.com>
 <1247851850-4298-6-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: hugh.dickins@tiscali.co.uk, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, nickpiggin@yahoo.com.au, ieidus@redhat.com, Wu Fengguang <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

From: Hugh Dickins <hugh.dickins@tiscali.co.uk>

KSM will need to identify its kernel merged pages unambiguously,
and /proc/kpageflags will probably like to do so too.

Since KSM will only be substituting anonymous pages, statistics are
best preserved by making a PageKsm page a special PageAnon page:
one with no anon_vma.

But KSM then needs its own page_add_ksm_rmap() - keep it in ksm.h near
PageKsm; and do_wp_page() must COW them, unlike singly mapped PageAnons.

Signed-off-by: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Signed-off-by: Chris Wright <chrisw@redhat.com>
Signed-off-by: Izik Eidus <ieidus@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
---
 fs/proc/page.c      |    5 +++++
 include/linux/ksm.h |   29 +++++++++++++++++++++++++++++
 mm/memory.c         |    3 ++-
 3 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 2707c6c..2281c2c 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -2,6 +2,7 @@
 #include <linux/compiler.h>
 #include <linux/fs.h>
 #include <linux/init.h>
+#include <linux/ksm.h>
 #include <linux/mm.h>
 #include <linux/mmzone.h>
 #include <linux/proc_fs.h>
@@ -95,6 +96,8 @@ static const struct file_operations proc_kpagecount_operations = {
 #define KPF_UNEVICTABLE		18
 #define KPF_NOPAGE		20
 
+#define KPF_KSM			21
+
 /* kernel hacking assistances
  * WARNING: subject to change, never rely on them!
  */
@@ -137,6 +140,8 @@ static u64 get_uflags(struct page *page)
 		u |= 1 << KPF_MMAP;
 	if (PageAnon(page))
 		u |= 1 << KPF_ANON;
+	if (PageKsm(page))
+		u |= 1 << KPF_KSM;
 
 	/*
 	 * compound pages: export both head/tail info
diff --git a/include/linux/ksm.h b/include/linux/ksm.h
index eb2a448..a485c14 100644
--- a/include/linux/ksm.h
+++ b/include/linux/ksm.h
@@ -10,6 +10,7 @@
 #include <linux/bitops.h>
 #include <linux/mm.h>
 #include <linux/sched.h>
+#include <linux/vmstat.h>
 
 #ifdef CONFIG_KSM
 int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
@@ -29,6 +30,27 @@ static inline void ksm_exit(struct mm_struct *mm)
 	if (test_bit(MMF_VM_MERGEABLE, &mm->flags))
 		__ksm_exit(mm);
 }
+
+/*
+ * A KSM page is one of those write-protected "shared pages" or "merged pages"
+ * which KSM maps into multiple mms, wherever identical anonymous page content
+ * is found in VM_MERGEABLE vmas.  It's a PageAnon page, with NULL anon_vma.
+ */
+static inline int PageKsm(struct page *page)
+{
+	return ((unsigned long)page->mapping == PAGE_MAPPING_ANON);
+}
+
+/*
+ * But we have to avoid the checking which page_add_anon_rmap() performs.
+ */
+static inline void page_add_ksm_rmap(struct page *page)
+{
+	if (atomic_inc_and_test(&page->_mapcount)) {
+		page->mapping = (void *) PAGE_MAPPING_ANON;
+		__inc_zone_page_state(page, NR_ANON_PAGES);
+	}
+}
 #else  /* !CONFIG_KSM */
 
 static inline int ksm_madvise(struct vm_area_struct *vma, unsigned long start,
@@ -45,6 +67,13 @@ static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
 static inline void ksm_exit(struct mm_struct *mm)
 {
 }
+
+static inline int PageKsm(struct page *page)
+{
+	return 0;
+}
+
+/* No stub required for page_add_ksm_rmap(page) */
 #endif /* !CONFIG_KSM */
 
 #endif
diff --git a/mm/memory.c b/mm/memory.c
index 8b1922c..6707072 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -45,6 +45,7 @@
 #include <linux/swap.h>
 #include <linux/highmem.h>
 #include <linux/pagemap.h>
+#include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/delayacct.h>
@@ -1972,7 +1973,7 @@ static int do_wp_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	 * Take out anonymous pages first, anonymous shared vmas are
 	 * not dirty accountable.
 	 */
-	if (PageAnon(old_page)) {
+	if (PageAnon(old_page) && !PageKsm(old_page)) {
 		if (!trylock_page(old_page)) {
 			page_cache_get(old_page);
 			pte_unmap_unlock(page_table, ptl);
-- 
1.5.6.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
