Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C46296B0038
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 17:36:52 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id kq14so1585858pab.23
        for <linux-mm@kvack.org>; Mon, 02 Jun 2014 14:36:52 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id ub1si3789334pac.41.2014.06.02.14.36.51
        for <linux-mm@kvack.org>;
        Mon, 02 Jun 2014 14:36:52 -0700 (PDT)
Subject: [PATCH 05/10] mm: mincore: clean up hugetlbfs handling (part 1)
From: Dave Hansen <dave@sr71.net>
Date: Mon, 02 Jun 2014 14:36:51 -0700
References: <20140602213644.925A26D0@viggo.jf.intel.com>
In-Reply-To: <20140602213644.925A26D0@viggo.jf.intel.com>
Message-Id: <20140602213651.1D4268DB@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, Dave Hansen <dave@sr71.net>


From: Dave Hansen <dave.hansen@linux.intel.com>

The page walker functions are only called _via_ the page
walker.  I don't see this changing any time soon.  The
page walker only calls walk->hugetlb_entry() under an
#ifdef CONFIG_HUGETLB_PAGE.

With this in place, I think putting BUG()s in the
->hugetlb_entry handlers is a bit like wearing a belt and
suspenders.

This axes the BUG() from the mincore ->hugetlb_entry along
with the #ifdef.  The compiler is more than smart enough
to do the right thing when it sees:

	if (1)
		return;
	// unreachable

The only downside here is that we now need some header stubs
for huge_pte_none() / huge_pte_get().

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/include/linux/hugetlb.h |   10 ++++++++++
 b/mm/mincore.c            |    9 +++++----
 2 files changed, 15 insertions(+), 4 deletions(-)

diff -puN include/linux/hugetlb.h~cleanup-hugetlbfs-mincore-1 include/linux/hugetlb.h
--- a/include/linux/hugetlb.h~cleanup-hugetlbfs-mincore-1	2014-06-02 14:20:20.144845525 -0700
+++ b/include/linux/hugetlb.h	2014-06-02 14:20:20.149845750 -0700
@@ -458,6 +458,16 @@ static inline spinlock_t *huge_pte_lockp
 {
 	return &mm->page_table_lock;
 }
+static inline int huge_pte_none(pte_t pte)
+{
+	WARN_ONCE(1, "%s() called when hugetlbfs disabled", __func__);
+	return 1;
+}
+static inline pte_t huge_ptep_get(pte_t *pte)
+{
+	WARN_ONCE(1, "%s() called when hugetlbfs disabled", __func__);
+	return __pte(0);
+}
 #endif	/* CONFIG_HUGETLB_PAGE */
 
 static inline spinlock_t *huge_pte_lock(struct hstate *h,
diff -puN mm/mincore.c~cleanup-hugetlbfs-mincore-1 mm/mincore.c
--- a/mm/mincore.c~cleanup-hugetlbfs-mincore-1	2014-06-02 14:20:20.146845615 -0700
+++ b/mm/mincore.c	2014-06-02 14:20:20.149845750 -0700
@@ -23,8 +23,12 @@ static int mincore_hugetlb_page_range(pt
 					unsigned long addr, unsigned long end,
 					struct mm_walk *walk)
 {
-#ifdef CONFIG_HUGETLB_PAGE
 	unsigned char *vec = walk->private;
+
+	/* This is as good as an explicit ifdef */
+	if (!is_vm_hugetlb_page(walk->vma))
+		return 0;
+
 	while (1) {
 		int present = !huge_pte_none(huge_ptep_get(ptep));
 		while (1) {
@@ -38,9 +42,6 @@ static int mincore_hugetlb_page_range(pt
 				break;
 		}
 	}
-#else
-	BUG();
-#endif
 	return 0;
 }
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
