Subject: [RFC] 3/4 Migration Cache - move migration cache page to swap cache
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Fri, 17 Feb 2006 10:37:23 -0500
Message-Id: <1140190643.5219.24.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Christoph Lameter <clameter@sgi.com>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>
List-ID: <linux-mm.kvack.org>

Migration Cache "V8" 3/4

This patch modifies the swapfile.c "unuse_*" stack to support
moving pages from migration cache to swap cache in case we have
to "fall back to swap".  This also allows vmscan.c:shrink_list()
to move migration cache pages to swap cache when/if it wants to
swap them out.  shrink_list() should only find anon pages in the
migration cache when/if we implement lazy page migration.

Because of the new usage, the patch renames the static "unuse_*"
functions in swapfile.c to "update_*".  In "update_pte_range",
if the entry arg matches the page's private data, we perform the
usual "unuse_pte()"; otherwise, this is an "update/move" operation
and we "update_pte()".

Then, this patch implements the __migration_move_to_swap() function
on top of the modified "update_*" stack.

Assumption:  because this facility is used only for removing swap
devices [sys_swapoff()] and direct page migration, it is not in
a critical/fast path.  Even so, this patch doesn't add significant
overhead to the stack [he says, glibly].

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>

Index: linux-2.6.16-rc3-mm1/include/linux/swap.h
===================================================================
--- linux-2.6.16-rc3-mm1.orig/include/linux/swap.h	2006-02-15 14:37:18.000000000 -0500
+++ linux-2.6.16-rc3-mm1/include/linux/swap.h	2006-02-15 14:37:18.000000000 -0500
@@ -197,6 +197,7 @@ extern int migrate_page_remove_reference
 extern unsigned long migrate_pages(struct list_head *l, struct list_head *t,
 		struct list_head *moved, struct list_head *failed);
 extern int fail_migrate_page(struct page *, struct page *);
+extern int remove_vma_swap(struct vm_area_struct *, struct page *);
 
 extern int add_to_migration_cache(struct page *, int);
 extern void migration_remove_entry(swp_entry_t, int);
@@ -206,6 +207,8 @@ extern void migration_remove_reference(s
 extern void __migration_remove_reference(struct page *, swp_entry_t,
 		 int);
 extern struct page *lookup_migration_cache(swp_entry_t);
+extern int __migration_move_to_swap(struct vm_area_struct *, struct page *,
+		swp_entry_t);
 #else
 static inline int isolate_lru_page(struct page *p) { return -ENOSYS; }
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
@@ -279,7 +282,6 @@ extern int remove_exclusive_swap_page(st
 struct backing_dev_info;
 
 extern spinlock_t swap_lock;
-extern int remove_vma_swap(struct vm_area_struct *vma, struct page *page);
 
 /* linux/mm/thrash.c */
 extern struct mm_struct * swap_token_mm;
Index: linux-2.6.16-rc3-mm1/mm/swapfile.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/swapfile.c	2006-02-15 14:37:18.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/swapfile.c	2006-02-16 10:40:25.000000000 -0500
@@ -503,6 +503,30 @@ unsigned int count_swap_pages(int type, 
 #endif
 
 /*
+ * replace [migration cache] pte with swap pte built from swp_entry_t
+ * value in page's private data.  Free [decrement ref count] previous
+ * [migration cache] entry
+ */
+static void update_pte(struct vm_area_struct *vma, pte_t *pte,
+		unsigned long addr, swp_entry_t entry, struct page *page)
+{
+#ifdef CONFIG_MIGRATION
+	swp_entry_t new_entry;
+	pte_t new_pte;
+
+	BUG_ON(!migration_type(swp_type(entry)));
+
+	new_entry.val = page_private(page);
+	new_pte       = swp_entry_to_pte(new_entry);
+	set_pte_at(vma->vm_mm, addr, pte, new_pte);
+
+	__migration_remove_reference(NULL, entry, 1);
+#else
+	BUG();	/* shouldn't get here */
+#endif
+}
+
+/*
  * No need to decide whether this PTE shares the swap entry with others,
  * just let do_wp_page work it out if a write is requested later - to
  * force COW, vm_page_prot omits write permission from any private vma.
@@ -523,7 +547,14 @@ static void unuse_pte(struct vm_area_str
 	activate_page(page);
 }
 
-static int unuse_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
+/*
+ * @entry contains pte to replace in *pmd
+ * if @entry == page_private(page), "unuse" the swap pte--i.e.,
+ *	replace it with a real anon page pte
+ * else replace the pte with the swap entry in page_private(@page)
+ *	[for moving migration cache pages to swap cache]
+ */
+static int update_pte_range(struct vm_area_struct *vma, pmd_t *pmd,
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
 {
@@ -539,7 +570,10 @@ static int unuse_pte_range(struct vm_are
 		 * Test inline before going to call unuse_pte.
 		 */
 		if (unlikely(pte_same(*pte, swp_pte))) {
-			unuse_pte(vma, pte++, addr, entry, page);
+			if (entry.val == page_private(page))
+				unuse_pte(vma, pte++, addr, entry, page);
+			else
+				update_pte(vma, pte++, addr, entry, page);
 			found = 1;
 			break;
 		}
@@ -548,7 +582,7 @@ static int unuse_pte_range(struct vm_are
 	return found;
 }
 
-static inline int unuse_pmd_range(struct vm_area_struct *vma, pud_t *pud,
+static inline int update_pmd_range(struct vm_area_struct *vma, pud_t *pud,
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
 {
@@ -560,13 +594,13 @@ static inline int unuse_pmd_range(struct
 		next = pmd_addr_end(addr, end);
 		if (pmd_none_or_clear_bad(pmd))
 			continue;
-		if (unuse_pte_range(vma, pmd, addr, next, entry, page))
+		if (update_pte_range(vma, pmd, addr, next, entry, page))
 			return 1;
 	} while (pmd++, addr = next, addr != end);
 	return 0;
 }
 
-static inline int unuse_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
+static inline int update_pud_range(struct vm_area_struct *vma, pgd_t *pgd,
 				unsigned long addr, unsigned long end,
 				swp_entry_t entry, struct page *page)
 {
@@ -578,13 +612,13 @@ static inline int unuse_pud_range(struct
 		next = pud_addr_end(addr, end);
 		if (pud_none_or_clear_bad(pud))
 			continue;
-		if (unuse_pmd_range(vma, pud, addr, next, entry, page))
+		if (update_pmd_range(vma, pud, addr, next, entry, page))
 			return 1;
 	} while (pud++, addr = next, addr != end);
 	return 0;
 }
 
-static int unuse_vma(struct vm_area_struct *vma,
+static int update_vma(struct vm_area_struct *vma,
 				swp_entry_t entry, struct page *page)
 {
 	pgd_t *pgd;
@@ -606,7 +640,7 @@ static int unuse_vma(struct vm_area_stru
 		next = pgd_addr_end(addr, end);
 		if (pgd_none_or_clear_bad(pgd))
 			continue;
-		if (unuse_pud_range(vma, pgd, addr, next, entry, page))
+		if (update_pud_range(vma, pgd, addr, next, entry, page))
 			return 1;
 	} while (pgd++, addr = next, addr != end);
 	return 0;
@@ -628,7 +662,7 @@ static int unuse_mm(struct mm_struct *mm
 		lock_page(page);
 	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
-		if (vma->anon_vma && unuse_vma(vma, entry, page))
+		if (vma->anon_vma && update_vma(vma, entry, page))
 			break;
 	}
 	up_read(&mm->mmap_sem);
@@ -640,11 +674,26 @@ static int unuse_mm(struct mm_struct *mm
 }
 
 #ifdef CONFIG_MIGRATION
+/*
+ * replace swap cache pte for page with "real" anon page pte
+ * i.e., "unuse" the swap entry
+ */
 int remove_vma_swap(struct vm_area_struct *vma, struct page *page)
 {
 	swp_entry_t entry = { .val = page_private(page) };
 
-	return unuse_vma(vma, entry, page);
+	return update_vma(vma, entry, page);
+}
+
+/*
+ * replace migration cache pte for page with swap pte built
+ * from page_private(page).
+ */
+int __migration_move_to_swap(struct vm_area_struct *vma,
+		struct page *page, swp_entry_t entry)
+{
+	return update_vma(vma, entry, page);
+
 }
 #endif
 
Index: linux-2.6.16-rc3-mm1/include/linux/rmap.h
===================================================================
--- linux-2.6.16-rc3-mm1.orig/include/linux/rmap.h	2006-02-15 11:59:28.000000000 -0500
+++ linux-2.6.16-rc3-mm1/include/linux/rmap.h	2006-02-15 14:37:18.000000000 -0500
@@ -93,6 +93,7 @@ static inline void page_dup_rmap(struct 
 int page_referenced(struct page *, int is_locked);
 int try_to_unmap(struct page *, int ignore_refs);
 void remove_from_swap(struct page *page);
+int migration_move_to_swap(struct page *);
 
 /*
  * Called from mm/filemap_xip.c to unmap empty zero page
Index: linux-2.6.16-rc3-mm1/mm/rmap.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/rmap.c	2006-02-15 14:37:18.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/rmap.c	2006-02-15 14:37:18.000000000 -0500
@@ -241,6 +241,72 @@ void remove_from_swap(struct page *page)
 	 */
 }
 EXPORT_SYMBOL(remove_from_swap);
+
+/*
+ * Move a page in the migration cache to the swap cache when
+ * direct migration falls back to swap.
+ * Return !0 on success; 0 otherwise
+ *
+ * Must hold page lock.
+ */
+int migration_move_to_swap(struct page *page)
+{
+	struct anon_vma *anon_vma;
+	struct vm_area_struct *vma;
+	swp_entry_t entry;
+	int moved = 0;
+
+//TODO:  should be BUG_ON()?
+	if (!page_is_migration(page))
+		return 0;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return 0; /* nothing to move */
+
+//TODO:  before locking anon_vma?  backout if !anon_vma?
+	entry.val = page_private(page);	/* save for move */
+	set_page_private(page, 0);	/* prepare for add_to_swap() */
+	ClearPageSwapCache(page);
+	if (!add_to_swap(page, GFP_KERNEL)) {
+		set_page_private(page, entry.val);
+		SetPageSwapCache(page);
+		return 0;
+	}
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
+		if (!__migration_move_to_swap(vma, page, entry)) {
+			/*
+			 * move failed.  try to remove from swap
+			 * and fail this page.
+			 */
+			spin_unlock(&anon_vma->lock);
+			WARN_ON(1);
+			printk (KERN_WARNING
+				 "%s failed after moving %d entries\n",
+				__FUNCTION__, moved);
+			/*
+			 * should remove swap AND migration cache
+			 * refs on page.
+			 */
+			remove_from_swap(page);
+			return 0;
+		}
+		++moved;
+	}
+
+	spin_unlock(&anon_vma->lock);
+
+	/*
+	 * add_to_swap() added another ref to page.
+	 * __migration_move_to_swap() did NOT remove the migration
+	 * cache's ref on the page, so drop it here, after replacing
+	 * all migration ptes.
+	 */
+	page_cache_release(page);
+
+	return 1;
+}
 #endif
 
 /*
Index: linux-2.6.16-rc3-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.16-rc3-mm1.orig/mm/vmscan.c	2006-02-15 14:37:18.000000000 -0500
+++ linux-2.6.16-rc3-mm1/mm/vmscan.c	2006-02-16 10:36:28.000000000 -0500
@@ -464,11 +464,8 @@ static unsigned long shrink_page_list(st
 				if (!add_to_swap(page, GFP_ATOMIC))
 					goto activate_locked;
 			} else if (page_is_migration(page)) {
-				/*
-				 * For now, skip migration cache pages.
-				 * TODO:  move to swap cache [difficult?]
-				 */
-				goto keep_locked;
+				if (!migration_move_to_swap(page))
+					goto keep_locked;
 			}
 		}
 #endif /* CONFIG_SWAP */


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
