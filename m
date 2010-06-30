Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 316216B01B2
	for <linux-mm@kvack.org>; Wed, 30 Jun 2010 11:37:36 -0400 (EDT)
Date: Wed, 30 Jun 2010 11:37:10 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -mm] rmap: add exclusive page to private anon_vma on swapin
Message-ID: <20100630113710.3b376e6a@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: aarcange@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On swapin it is fairly common for a page to be owned exclusively
by one process.  In that case we want to add the page to the
anon_vma of that process's VMA, instead of to the root anon_vma.

This will reduce the amount of rmap searching that the swapout
code needs to do.

Signed-off-by: Rik van Riel <riel@redhat.com>

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 369bdb4..31b2fd7 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -162,6 +162,8 @@ static inline void anon_vma_merge(struct vm_area_struct *vma,
  */
 void page_move_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
+void do_page_add_anon_rmap(struct page *, struct vm_area_struct *,
+			   unsigned long, int);
 void page_add_new_anon_rmap(struct page *, struct vm_area_struct *, unsigned long);
 void page_add_file_rmap(struct page *);
 void page_remove_rmap(struct page *);
diff --git a/mm/memory.c b/mm/memory.c
index 119b7cc..c0d984c 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2620,6 +2620,7 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	swp_entry_t entry;
 	pte_t pte;
 	struct mem_cgroup *ptr = NULL;
+	int exclusive = 0;
 	int ret = 0;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
@@ -2714,10 +2715,11 @@ static int do_swap_page(struct mm_struct *mm, struct vm_area_struct *vma,
 	if ((flags & FAULT_FLAG_WRITE) && reuse_swap_page(page)) {
 		pte = maybe_mkwrite(pte_mkdirty(pte), vma);
 		flags &= ~FAULT_FLAG_WRITE;
+		exclusive = 1;
 	}
 	flush_icache_page(vma, page);
 	set_pte_at(mm, address, page_table, pte);
-	page_add_anon_rmap(page, vma, address);
+	do_page_add_anon_rmap(page, vma, address, exclusive);
 	/* It's better to call commit-charge after rmap is established */
 	mem_cgroup_commit_charge_swapin(page, ptr);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 73d497e..a129679 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -831,6 +831,17 @@ static void __page_check_anon_rmap(struct page *page,
 void page_add_anon_rmap(struct page *page,
 	struct vm_area_struct *vma, unsigned long address)
 {
+	do_page_add_anon_rmap(page, vma, address, 0);
+}
+
+/*
+ * Special version of the above for do_swap_page, which often runs
+ * into pages that are exclusively owned by the current process.
+ * Everybody else should continue to use page_add_anon_rmap above.
+ */
+void do_page_add_anon_rmap(struct page *page,
+	struct vm_area_struct *vma, unsigned long address, int exclusive)
+{
 	int first = atomic_inc_and_test(&page->_mapcount);
 	if (first)
 		__inc_zone_page_state(page, NR_ANON_PAGES);
@@ -840,7 +851,7 @@ void page_add_anon_rmap(struct page *page,
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(address < vma->vm_start || address >= vma->vm_end);
 	if (first)
-		__page_set_anon_rmap(page, vma, address, 0);
+		__page_set_anon_rmap(page, vma, address, exclusive);
 	else
 		__page_check_anon_rmap(page, vma, address);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
