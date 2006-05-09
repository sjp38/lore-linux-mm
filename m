Date: Mon, 8 May 2006 23:51:46 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060509065146.24194.47401.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/5] page migration: ifdef out code
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

ifdef around migration codeClean up various minor things.

Put #ifdef CONFIG_MIGRATION around two locations that would
generate code for the non migration case.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc3-mm1/mm/mprotect.c
===================================================================
--- linux-2.6.17-rc3-mm1.orig/mm/mprotect.c	2006-05-01 09:48:43.582547283 -0700
+++ linux-2.6.17-rc3-mm1/mm/mprotect.c	2006-05-04 22:55:27.738093185 -0700
@@ -45,6 +45,7 @@ static void change_pte_range(struct mm_s
 			ptent = pte_modify(ptep_get_and_clear(mm, addr, pte), newprot);
 			set_pte_at(mm, addr, pte, ptent);
 			lazy_mmu_prot_update(ptent);
+#ifdef CONFIG_MIGRATION
 		} else if (!pte_file(oldpte)) {
 			swp_entry_t entry = pte_to_swp_entry(oldpte);
 
@@ -57,6 +58,7 @@ static void change_pte_range(struct mm_s
 				set_pte_at(mm, addr, pte,
 					swp_entry_to_pte(entry));
 			}
+#endif
 		}
 
 	} while (pte++, addr += PAGE_SIZE, addr != end);
Index: linux-2.6.17-rc3-mm1/mm/rmap.c
===================================================================
--- linux-2.6.17-rc3-mm1.orig/mm/rmap.c	2006-05-01 09:48:43.606959827 -0700
+++ linux-2.6.17-rc3-mm1/mm/rmap.c	2006-05-04 22:55:27.739069687 -0700
@@ -596,6 +596,7 @@ static int try_to_unmap_one(struct page 
 				spin_unlock(&mmlist_lock);
 			}
 			dec_mm_counter(mm, anon_rss);
+#ifdef CONFIG_MIGRATION
 		} else {
 			/*
 			 * Store the pfn of the page in a special migration
@@ -604,17 +605,21 @@ static int try_to_unmap_one(struct page 
 			 */
 			BUG_ON(!migration);
 			entry = make_migration_entry(page, pte_write(pteval));
+#endif
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-	} else if (!migration)
-		dec_mm_counter(mm, file_rss);
-	else {
+	} else
+#ifdef CONFIG_MIGRATION
+	if (migration) {
 		/* Establish migration entry for a file page */
 		swp_entry_t entry;
 		entry = make_migration_entry(page, pte_write(pteval));
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
-	}
+	} else
+#endif
+		dec_mm_counter(mm, file_rss);
+
 
 	page_remove_rmap(page);
 	page_cache_release(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
