Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 61D6D6B0275
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 18:51:47 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id zm5so41725865pac.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 15:51:47 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id t71si7283607pfi.71.2016.04.06.15.51.31
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 15:51:31 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv6 05/30] rmap: support file thp
Date: Thu,  7 Apr 2016 01:50:55 +0300
Message-Id: <1459983080-106718-6-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1459983080-106718-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, Yang Shi <yang.shi@linaro.org>, Sasha Levin <sasha.levin@oracle.com>, Andres Lagar-Cavilla <andreslc@google.com>, Ning Qu <quning@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Naive approach: on mapping/unmapping the page as compound we update
->_mapcount on each 4k page. That's not efficient, but it's not obvious
how we can optimize this. We can look into optimization later.

PG_double_map optimization doesn't work for file pages since lifecycle
of file pages is different comparing to anon pages: file page can be
mapped again at any time.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  2 +-
 mm/huge_memory.c     | 10 +++++++---
 mm/memory.c          |  4 ++--
 mm/migrate.c         |  2 +-
 mm/rmap.c            | 48 +++++++++++++++++++++++++++++++++++-------------
 mm/util.c            |  6 ++++++
 6 files changed, 52 insertions(+), 20 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 49eb4f8ebac9..5704f101b52e 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -165,7 +165,7 @@ void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
 		unsigned long, bool);
-void page_add_file_rmap(struct page *);
+void page_add_file_rmap(struct page *, bool);
 void page_remove_rmap(struct page *, bool);
 
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 455e7a785c89..6d447ca95efa 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -3265,18 +3265,22 @@ static void __split_huge_page(struct page *page, struct list_head *list)
 
 int total_mapcount(struct page *page)
 {
-	int i, ret;
+	int i, compound, ret;
 
 	VM_BUG_ON_PAGE(PageTail(page), page);
 
 	if (likely(!PageCompound(page)))
 		return atomic_read(&page->_mapcount) + 1;
 
-	ret = compound_mapcount(page);
+	compound = compound_mapcount(page);
 	if (PageHuge(page))
-		return ret;
+		return compound;
+	ret = compound;
 	for (i = 0; i < HPAGE_PMD_NR; i++)
 		ret += atomic_read(&page[i]._mapcount) + 1;
+	/* File pages has compound_mapcount included in _mapcount */
+	if (!PageAnon(page))
+		return ret - compound * HPAGE_PMD_NR;
 	if (PageDoubleMap(page))
 		ret -= HPAGE_PMD_NR;
 	return ret;
diff --git a/mm/memory.c b/mm/memory.c
index da154b9b542a..095b210cafe9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1445,7 +1445,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
 	inc_mm_counter_fast(mm, mm_counter_file(page));
-	page_add_file_rmap(page);
+	page_add_file_rmap(page, false);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
 	retval = 0;
@@ -2908,7 +2908,7 @@ int alloc_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 		lru_cache_add_active_or_unevictable(page, vma);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, mm_counter_file(page));
-		page_add_file_rmap(page);
+		page_add_file_rmap(page, false);
 	}
 	set_pte_at(vma->vm_mm, fe->address, fe->pte, entry);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index 6c822a7b27e0..d20276fffce7 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -170,7 +170,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
-		page_add_file_rmap(new);
+		page_add_file_rmap(new, false);
 
 	if (vma->vm_flags & VM_LOCKED && !PageTransCompound(new))
 		mlock_vma_page(new);
diff --git a/mm/rmap.c b/mm/rmap.c
index 307b555024ef..96e183737ca9 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1271,18 +1271,34 @@ void page_add_new_anon_rmap(struct page *page,
  *
  * The caller needs to hold the pte lock.
  */
-void page_add_file_rmap(struct page *page)
+void page_add_file_rmap(struct page *page, bool compound)
 {
+	int i, nr = 1;
+
+	VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
 	lock_page_memcg(page);
-	if (atomic_inc_and_test(&page->_mapcount)) {
-		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+	if (compound && PageTransHuge(page)) {
+		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
+			if (atomic_inc_and_test(&page[i]._mapcount))
+				nr++;
+		}
+		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
+			goto out;
+	} else {
+		if (!atomic_inc_and_test(&page->_mapcount))
+			goto out;
 	}
+	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, nr);
+	mem_cgroup_inc_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
+out:
 	unlock_page_memcg(page);
 }
 
-static void page_remove_file_rmap(struct page *page)
+static void page_remove_file_rmap(struct page *page, bool compound)
 {
+	int i, nr = 1;
+
+	VM_BUG_ON_PAGE(compound && !PageTransHuge(page), page);
 	lock_page_memcg(page);
 
 	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
@@ -1293,15 +1309,24 @@ static void page_remove_file_rmap(struct page *page)
 	}
 
 	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
-		goto out;
+	if (compound && PageTransHuge(page)) {
+		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
+			if (atomic_add_negative(-1, &page[i]._mapcount))
+				nr++;
+		}
+		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+			goto out;
+	} else {
+		if (!atomic_add_negative(-1, &page->_mapcount))
+			goto out;
+	}
 
 	/*
 	 * We use the irq-unsafe __{inc|mod}_zone_page_stat because
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_FILE_MAPPED);
+	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, -nr);
 	mem_cgroup_dec_page_stat(page, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
@@ -1357,11 +1382,8 @@ static void page_remove_anon_compound_rmap(struct page *page)
  */
 void page_remove_rmap(struct page *page, bool compound)
 {
-	if (!PageAnon(page)) {
-		VM_BUG_ON_PAGE(compound && !PageHuge(page), page);
-		page_remove_file_rmap(page);
-		return;
-	}
+	if (!PageAnon(page))
+		return page_remove_file_rmap(page, compound);
 
 	if (compound)
 		return page_remove_anon_compound_rmap(page);
diff --git a/mm/util.c b/mm/util.c
index 6cc81e7b8705..b7ac1d708cb0 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -386,6 +386,12 @@ int __page_mapcount(struct page *page)
 	int ret;
 
 	ret = atomic_read(&page->_mapcount) + 1;
+	/*
+	 * For file THP page->_mapcount contains total number of mapping
+	 * of the page: no need to look into compound_mapcount.
+	 */
+	if (!PageAnon(page) && !PageHuge(page))
+		return ret;
 	page = compound_head(page);
 	ret += atomic_read(compound_mapcount_ptr(page)) + 1;
 	if (PageDoubleMap(page))
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
