Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mA60mAg6003211
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 6 Nov 2008 09:48:10 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C5FC545DD84
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:48:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F73445DD7B
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:48:08 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 08F311DB803E
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:48:08 +0900 (JST)
Received: from ml10.s.css.fujitsu.com (ml10.s.css.fujitsu.com [10.249.87.100])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F146E08007
	for <linux-mm@kvack.org>; Thu,  6 Nov 2008 09:48:07 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH] (cleanup) get rid of #ifdef CONFIG_MIGRATION
Message-Id: <20081106094458.0D32.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  6 Nov 2008 09:48:06 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

#ifdef in *.c file decrease source readability a bit.
removing is better.

this patch doesn't have any functional change.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 include/linux/migrate.h |    4 ++++
 mm/mprotect.c           |    6 ++----
 mm/rmap.c               |   10 +++-------
 3 files changed, 9 insertions(+), 11 deletions(-)

Index: b/include/linux/migrate.h
===================================================================
--- a/include/linux/migrate.h	2008-11-06 09:26:07.000000000 +0900
+++ b/include/linux/migrate.h	2008-11-06 09:34:47.000000000 +0900
@@ -7,6 +7,8 @@
 typedef struct page *new_page_t(struct page *, unsigned long private, int **);
 
 #ifdef CONFIG_MIGRATION
+#define PAGE_MIGRATION 1
+
 extern int putback_lru_pages(struct list_head *l);
 extern int migrate_page(struct address_space *,
 			struct page *, struct page *);
@@ -20,6 +22,8 @@ extern int migrate_vmas(struct mm_struct
 		const nodemask_t *from, const nodemask_t *to,
 		unsigned long flags);
 #else
+#define PAGE_MIGRATION 0
+
 static inline int putback_lru_pages(struct list_head *l) { return 0; }
 static inline int migrate_pages(struct list_head *l, new_page_t x,
 		unsigned long private) { return -ENOSYS; }
Index: b/mm/mprotect.c
===================================================================
--- a/mm/mprotect.c	2008-11-06 09:26:11.000000000 +0900
+++ b/mm/mprotect.c	2008-11-06 09:37:43.000000000 +0900
@@ -22,6 +22,7 @@
 #include <linux/swap.h>
 #include <linux/swapops.h>
 #include <linux/mmu_notifier.h>
+#include <linux/migrate.h>
 #include <asm/uaccess.h>
 #include <asm/pgtable.h>
 #include <asm/cacheflush.h>
@@ -59,8 +60,7 @@ static void change_pte_range(struct mm_s
 				ptent = pte_mkwrite(ptent);
 
 			ptep_modify_prot_commit(mm, addr, pte, ptent);
-#ifdef CONFIG_MIGRATION
-		} else if (!pte_file(oldpte)) {
+		} else if (PAGE_MIGRATION && !pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
 			if (is_write_migration_entry(entry)) {
@@ -72,9 +72,7 @@ static void change_pte_range(struct mm_s
 				set_pte_at(mm, addr, pte,
 					swp_entry_to_pte(entry));
 			}
-#endif
 		}
-
 	} while (pte++, addr += PAGE_SIZE, addr != end);
 	arch_leave_lazy_mmu_mode();
 	pte_unmap_unlock(pte - 1, ptl);
Index: b/mm/rmap.c
===================================================================
--- a/mm/rmap.c	2008-11-06 09:26:11.000000000 +0900
+++ b/mm/rmap.c	2008-11-06 09:38:35.000000000 +0900
@@ -50,6 +50,7 @@
 #include <linux/kallsyms.h>
 #include <linux/memcontrol.h>
 #include <linux/mmu_notifier.h>
+#include <linux/migrate.h>
 
 #include <asm/tlbflush.h>
 
@@ -818,8 +819,7 @@ static int try_to_unmap_one(struct page 
 				spin_unlock(&mmlist_lock);
 			}
 			dec_mm_counter(mm, anon_rss);
-#ifdef CONFIG_MIGRATION
-		} else {
+		} else if (PAGE_MIGRATION) {
 			/*
 			 * Store the pfn of the page in a special migration
 			 * pte. do_swap_page() will wait until the migration
@@ -827,19 +827,15 @@ static int try_to_unmap_one(struct page 
 			 */
 			BUG_ON(!migration);
 			entry = make_migration_entry(page, pte_write(pteval));
-#endif
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-	} else
-#ifdef CONFIG_MIGRATION
-	if (migration) {
+	} else if (PAGE_MIGRATION && migration) {
 		/* Establish migration entry for a file page */
 		swp_entry_t entry;
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 	} else
-#endif
 		dec_mm_counter(mm, file_rss);
 
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
