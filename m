Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 57A4C6B02A5
	for <linux-mm@kvack.org>; Thu, 12 Aug 2010 04:02:04 -0400 (EDT)
Date: Thu, 12 Aug 2010 16:57:30 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [RFC] [PATCH 1/4] hugetlb: prepare exclusion control functions for
 hugepage
Message-ID: <20100812075730.GC6112@spritzera.linux.bs1.fc.nec.co.jp>
References: <1281432464-14833-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <alpine.DEB.2.00.1008110806070.673@router.home>
 <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Disposition: inline
In-Reply-To: <20100812075323.GA6112@spritzera.linux.bs1.fc.nec.co.jp>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Jun'ichi Nomura <j-nomura@ce.jp.nec.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch defines some helper functions to avoid race condition
on hugepage I/O. We assume that locking/unlocking subpages are
done in ascending/descending order in adderss to avoid deadlock.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 include/linux/hugetlb.h |   55 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/memory-failure.c     |   24 ++++++++++++++++++++
 2 files changed, 79 insertions(+), 0 deletions(-)

diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index c7b4dae..dabed89 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -312,6 +312,55 @@ static inline struct hstate *page_hstate(struct page *page)
 	return size_to_hstate(PAGE_SIZE << compound_order(page));
 }
 
+/*
+ * Locking functions for hugepage.
+ * We assume that locking/unlocking subpages are done
+ * in ascending/descending order in adderss to avoid deadlock.
+ */
+
+/* If no subpage is locked, return 1. Otherwise, return 0. */
+static inline int trylock_huge_page(struct page *page)
+{
+	int i;
+	int ret = 1;
+	int nr_pages = pages_per_huge_page(page_hstate(page));
+	for (i = 0; i < nr_pages; i++)
+		ret &= trylock_page(page + i);
+	return ret;
+}
+
+static inline void lock_huge_page(struct page *page)
+{
+	int i;
+	int nr_pages = pages_per_huge_page(page_hstate(page));
+	for (i = 0; i < nr_pages; i++)
+		lock_page(page + i);
+}
+
+static inline void lock_huge_page_nosync(struct page *page)
+{
+	int i;
+	int nr_pages = pages_per_huge_page(page_hstate(page));
+	for (i = 0; i < nr_pages; i++)
+		lock_page_nosync(page + i);
+}
+
+static inline void unlock_huge_page(struct page *page)
+{
+	int i;
+	int nr_pages = pages_per_huge_page(page_hstate(page));
+	for (i = nr_pages - 1; i >= 0; i--)
+		unlock_page(page + i);
+}
+
+static inline void wait_on_huge_page_writeback(struct page *page)
+{
+	int i;
+	int nr_pages = pages_per_huge_page(page_hstate(page));
+	for (i = 0; i < nr_pages; i++)
+		wait_on_page_writeback(page + i);
+}
+
 #else
 struct hstate {};
 #define alloc_huge_page_node(h, nid) NULL
@@ -329,6 +378,12 @@ static inline unsigned int pages_per_huge_page(struct hstate *h)
 {
 	return 1;
 }
+#define page_hstate(p) NULL
+#define trylock_huge_page(p) NULL
+#define lock_huge_page(p) NULL
+#define lock_huge_page_nosync(p) NULL
+#define unlock_huge_page(p) NULL
+#define wait_on_huge_page_writeback(p) NULL
 #endif
 
 #endif /* _LINUX_HUGETLB_H */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 1e9794d..e387098 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -950,6 +950,30 @@ static void clear_page_hwpoison_huge_page(struct page *hpage)
 	decrement_corrupted_huge_page(hpage);
 }
 
+static void lock_page_against_memory_failure(struct page *p)
+{
+	if (PageHuge(p))
+		lock_huge_page_nosync(p);
+	else
+		lock_page_nosync(p);
+}
+
+static void unlock_page_against_memory_failure(struct page *p)
+{
+	if (PageHuge(p))
+		unlock_huge_page(p);
+	else
+		unlock_page(p);
+}
+
+static void wait_on_pages_writeback_against_memory_failure(struct page *p)
+{
+	if (PageHuge(p))
+		wait_on_huge_page_writeback(p);
+	else
+		wait_on_page_writeback(p);
+}
+
 int __memory_failure(unsigned long pfn, int trapno, int flags)
 {
 	struct page_state *ps;
-- 
1.7.2.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
