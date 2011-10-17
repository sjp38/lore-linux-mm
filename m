Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 1D51A6B0037
	for <linux-mm@kvack.org>; Mon, 17 Oct 2011 10:42:30 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/3] thp: share get_huge_page_tail()
Date: Mon, 17 Oct 2011 16:41:57 +0200
Message-Id: <1318862517-7042-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1318862517-7042-1-git-send-email-aarcange@redhat.com>
References: <1316793432.9084.47.camel@twins>
 <1318862517-7042-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan.kim@gmail.com>, Michel Lespinasse <walken@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Shaohua Li <shaohua.li@intel.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

This avoids duplicating the function in every arch gup_fast.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 arch/powerpc/mm/hugetlbpage.c |   11 -----------
 arch/s390/mm/gup.c            |   11 -----------
 arch/sparc/mm/gup.c           |   11 -----------
 arch/x86/mm/gup.c             |   11 -----------
 include/linux/mm.h            |   11 +++++++++++
 5 files changed, 11 insertions(+), 44 deletions(-)

diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index a618ef0..b400535 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -385,17 +385,6 @@ follow_huge_pmd(struct mm_struct *mm, unsigned long address,
 	return NULL;
 }
 
-static inline void get_huge_page_tail(struct page *page)
-{
-	/*
-	 * __split_huge_page_refcount() cannot run
-	 * from under us.
-	 */
-	VM_BUG_ON(page_mapcount(page) < 0);
-	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	atomic_inc(&page->_mapcount);
-}
-
 static noinline int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
 		       unsigned long end, int write, struct page **pages, int *nr)
 {
diff --git a/arch/s390/mm/gup.c b/arch/s390/mm/gup.c
index 668dda9..755f226 100644
--- a/arch/s390/mm/gup.c
+++ b/arch/s390/mm/gup.c
@@ -48,17 +48,6 @@ static inline int gup_pte_range(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 	return 1;
 }
 
-static inline void get_huge_page_tail(struct page *page)
-{
-	/*
-	 * __split_huge_page_refcount() cannot run
-	 * from under us.
-	 */
-	VM_BUG_ON(page_mapcount(page) < 0);
-	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	atomic_inc(&page->_mapcount);
-}
-
 static inline int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
index afcebac..42c55df 100644
--- a/arch/sparc/mm/gup.c
+++ b/arch/sparc/mm/gup.c
@@ -12,17 +12,6 @@
 #include <linux/rwsem.h>
 #include <asm/pgtable.h>
 
-static inline void get_huge_page_tail(struct page *page)
-{
-	/*
-	 * __split_huge_page_refcount() cannot run
-	 * from under us.
-	 */
-	VM_BUG_ON(page_mapcount(page) < 0);
-	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	atomic_inc(&page->_mapcount);
-}
-
 /*
  * The performance critical leaf functions are made noinline otherwise gcc
  * inlines everything into a single function which results in too much
diff --git a/arch/x86/mm/gup.c b/arch/x86/mm/gup.c
index 3b5032a..ea30585 100644
--- a/arch/x86/mm/gup.c
+++ b/arch/x86/mm/gup.c
@@ -108,17 +108,6 @@ static inline void get_head_page_multiple(struct page *page, int nr)
 	SetPageReferenced(page);
 }
 
-static inline void get_huge_page_tail(struct page *page)
-{
-	/*
-	 * __split_huge_page_refcount() cannot run
-	 * from under us.
-	 */
-	VM_BUG_ON(page_mapcount(page) < 0);
-	VM_BUG_ON(atomic_read(&page->_count) != 0);
-	atomic_inc(&page->_mapcount);
-}
-
 static noinline int gup_huge_pmd(pmd_t pmd, unsigned long addr,
 		unsigned long end, int write, struct page **pages, int *nr)
 {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index c1ce6c0..fedc5f0 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -376,6 +376,17 @@ static inline int page_count(struct page *page)
 	return atomic_read(&compound_head(page)->_count);
 }
 
+static inline void get_huge_page_tail(struct page *page)
+{
+	/*
+	 * __split_huge_page_refcount() cannot run
+	 * from under us.
+	 */
+	VM_BUG_ON(page_mapcount(page) < 0);
+	VM_BUG_ON(atomic_read(&page->_count) != 0);
+	atomic_inc(&page->_mapcount);
+}
+
 extern bool __get_page_tail(struct page *page);
 
 static inline void get_page(struct page *page)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
