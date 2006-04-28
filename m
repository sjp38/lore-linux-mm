Date: Fri, 28 Apr 2006 14:24:34 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060428212434.2737.43187.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/3] more page migration: Do not dec/inc rss counters
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

more page migration: Do not dec/inc rss counters

If we install a migration entry then the rss not really decreases
since the page is just moved somewhere else. We can save ourselves
the work of decrementing and later incrementing which will just
eventually cause cacheline bouncing.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/migrate.c	2006-04-28 08:26:29.893711598 -0700
+++ linux-2.6.17-rc2-mm1/mm/migrate.c	2006-04-28 11:21:51.877154899 -0700
@@ -166,7 +166,6 @@
 	if (!is_migration_entry(entry) || migration_entry_to_page(entry) != old)
 		goto out;
 
-	inc_mm_counter(mm, anon_rss);
 	get_page(new);
 	pte = pte_mkold(mk_pte(new, vma->vm_page_prot));
 	if (is_write_migration_entry(entry))
Index: linux-2.6.17-rc2-mm1/mm/rmap.c
===================================================================
--- linux-2.6.17-rc2-mm1.orig/mm/rmap.c	2006-04-28 08:14:27.583120481 -0700
+++ linux-2.6.17-rc2-mm1/mm/rmap.c	2006-04-28 11:21:30.310131304 -0700
@@ -595,6 +595,7 @@
 					list_add(&mm->mmlist, &init_mm.mmlist);
 				spin_unlock(&mmlist_lock);
 			}
+			dec_mm_counter(mm, anon_rss);
 		} else {
 			/*
 			 * Store the pfn of the page in a special migration
@@ -606,7 +607,6 @@
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));
-		dec_mm_counter(mm, anon_rss);
 	} else
 		dec_mm_counter(mm, file_rss);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
