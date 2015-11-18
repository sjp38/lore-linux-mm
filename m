Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 8CFD76B0259
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 18:25:47 -0500 (EST)
Received: by padhx2 with SMTP id hx2so59430804pad.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 15:25:47 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id tq4si7233407pab.243.2015.11.18.15.25.46
        for <linux-mm@kvack.org>;
        Wed, 18 Nov 2015 15:25:46 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 6/9] rmap: support file THP
Date: Thu, 19 Nov 2015 01:25:33 +0200
Message-Id: <1447889136-6928-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1447889136-6928-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jerome Marchand <jmarchan@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Naive approach: on mapping/unmapping the page as compound we update
->_mapcount on each 4k page. That's not efficient, but it's not obvious
how we can optimize this. We can look into optimization later.

PG_double_map optimization doesn't work for file pages since lifecycle
of file pages is different comparing to anon pages: file page can be
mapped again at any time.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 include/linux/rmap.h |  2 +-
 mm/memory.c          |  4 ++--
 mm/migrate.c         |  2 +-
 mm/rmap.c            | 51 +++++++++++++++++++++++++++++++++------------------
 mm/util.c            |  6 ++++++
 5 files changed, 43 insertions(+), 22 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index ebf3750e42b2..03dde08ba963 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -175,7 +175,7 @@ void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
 			   unsigned long, int);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *,
 		unsigned long, bool);
-void page_add_file_rmap(struct page *);
+void page_add_file_rmap(struct page *, bool);
 void page_remove_rmap(struct page *, bool);
 
 void hugepage_add_anon_rmap(struct page *, struct vm_area_struct *,
diff --git a/mm/memory.c b/mm/memory.c
index 522279922946..3f6f1e2f7afb 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -1456,7 +1456,7 @@ static int insert_page(struct vm_area_struct *vma, unsigned long addr,
 	/* Ok, finally just insert the thing.. */
 	get_page(page);
 	inc_mm_counter_fast(mm, MM_FILEPAGES);
-	page_add_file_rmap(page);
+	page_add_file_rmap(page, false);
 	set_pte_at(mm, addr, pte, mk_pte(page, prot));
 
 	retval = 0;
@@ -2925,7 +2925,7 @@ int do_set_pte(struct fault_env *fe, struct mem_cgroup *memcg,
 		lru_cache_add_active_or_unevictable(page, vma);
 	} else {
 		inc_mm_counter_fast(vma->vm_mm, MM_FILEPAGES);
-		page_add_file_rmap(page);
+		page_add_file_rmap(page, false);
 	}
 	set_pte_at(vma->vm_mm, fe->address, fe->pte, entry);
 
diff --git a/mm/migrate.c b/mm/migrate.c
index b1034f9c77e7..004adee21c61 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -169,7 +169,7 @@ static int remove_migration_pte(struct page *new, struct vm_area_struct *vma,
 	} else if (PageAnon(new))
 		page_add_anon_rmap(new, vma, addr, false);
 	else
-		page_add_file_rmap(new);
+		page_add_file_rmap(new, false);
 
 	if (vma->vm_flags & VM_LOCKED)
 		mlock_vma_page(new);
diff --git a/mm/rmap.c b/mm/rmap.c
index e90b81ff306d..7a04cbb5d953 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1255,33 +1255,51 @@ void page_add_new_anon_rmap(struct page *page,
  *
  * The caller needs to hold the pte lock.
  */
-void page_add_file_rmap(struct page *page)
+void page_add_file_rmap(struct page *page, bool compound)
 {
 	struct mem_cgroup *memcg;
+	int i, nr = 1;
 
 	memcg = mem_cgroup_begin_page_stat(page);
-	if (atomic_inc_and_test(&page->_mapcount)) {
-		__inc_zone_page_state(page, NR_FILE_MAPPED);
-		mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
+	if (compound) {
+		if (!atomic_inc_and_test(compound_mapcount_ptr(page)))
+			goto out;
+		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
+			if (atomic_inc_and_test(&page[i]._mapcount))
+				nr++;
+		}
+	} else {
+		if (!atomic_inc_and_test(&page->_mapcount))
+			goto out;
 	}
+	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, nr);
+	mem_cgroup_inc_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
+out:
 	mem_cgroup_end_page_stat(memcg);
 }
 
-static void page_remove_file_rmap(struct page *page)
+static void page_remove_file_rmap(struct page *page, bool compound)
 {
 	struct mem_cgroup *memcg;
+	int i, nr = 1;
 
 	memcg = mem_cgroup_begin_page_stat(page);
 
-	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
-	if (unlikely(PageHuge(page))) {
-		/* hugetlb pages are always mapped with pmds */
-		atomic_dec(compound_mapcount_ptr(page));
-		goto out;
+	/* page still mapped by someone else? */
+	if (compound) {
+		if (!atomic_add_negative(-1, compound_mapcount_ptr(page)))
+			goto out;
+		for (i = 0, nr = 0; i < HPAGE_PMD_NR; i++) {
+			if (atomic_add_negative(-1, &page[i]._mapcount))
+				nr++;
+		}
+	} else {
+		if (!atomic_add_negative(-1, &page->_mapcount))
+			goto out;
 	}
 
-	/* page still mapped by someone else? */
-	if (!atomic_add_negative(-1, &page->_mapcount))
+	/* Hugepages are not counted in NR_FILE_MAPPED for now. */
+	if (unlikely(PageHuge(page)))
 		goto out;
 
 	/*
@@ -1289,7 +1307,7 @@ static void page_remove_file_rmap(struct page *page)
 	 * these counters are not modified in interrupt context, and
 	 * pte lock(a spinlock) is held, which implies preemption disabled.
 	 */
-	__dec_zone_page_state(page, NR_FILE_MAPPED);
+	__mod_zone_page_state(page_zone(page), NR_FILE_MAPPED, -nr);
 	mem_cgroup_dec_page_stat(memcg, MEM_CGROUP_STAT_FILE_MAPPED);
 
 	if (unlikely(PageMlocked(page)))
@@ -1342,11 +1360,8 @@ static void page_remove_anon_compound_rmap(struct page *page)
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
index 5be2a4bdf76b..6d318731e2fc 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -412,6 +412,12 @@ int __page_mapcount(struct page *page)
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
2.6.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
