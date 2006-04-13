Date: Thu, 13 Apr 2006 16:54:21 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060413235421.15398.1374.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
References: <20060413235406.15398.42233.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 3/5] Swapless V2: Make try_to_unmap() create migration entries
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Hugh Dickins <hugh@veritas.com>, linux-kernel@vger.kernel.org, Lee Schermerhorn <lee.schermerhorn@hp.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Modify try_to_unmap to produce migration entries

If we are trying to unmap an entry and do not have an associated
swapcache entry but are doing migration then create a special
migration entry pointing to the pfn.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1-mm2/mm/rmap.c
===================================================================
--- linux-2.6.17-rc1-mm2.orig/mm/rmap.c	2006-04-13 12:56:10.000000000 -0700
+++ linux-2.6.17-rc1-mm2/mm/rmap.c	2006-04-13 15:18:45.000000000 -0700
@@ -620,17 +620,27 @@ static int try_to_unmap_one(struct page 
 
 	if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
-		/*
-		 * Store the swap location in the pte.
-		 * See handle_pte_fault() ...
-		 */
-		BUG_ON(!PageSwapCache(page));
-		swap_duplicate(entry);
-		if (list_empty(&mm->mmlist)) {
-			spin_lock(&mmlist_lock);
-			if (list_empty(&mm->mmlist))
-				list_add(&mm->mmlist, &init_mm.mmlist);
-			spin_unlock(&mmlist_lock);
+
+		if (PageSwapCache(page)) {
+			/*
+			 * Store the swap location in the pte.
+			 * See handle_pte_fault() ...
+			 */
+			swap_duplicate(entry);
+			if (list_empty(&mm->mmlist)) {
+				spin_lock(&mmlist_lock);
+				if (list_empty(&mm->mmlist))
+					list_add(&mm->mmlist, &init_mm.mmlist);
+				spin_unlock(&mmlist_lock);
+			}
+		} else {
+			/*
+			 * Store the pfn of the page in a special migration
+			 * pte. do_swap_page() will wait until the migration
+			 * pte is removed and then restart fault handling.
+			 */
+			BUG_ON(!migration);
+			entry = make_migration_entry(page);
 		}
 		set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
 		BUG_ON(pte_file(*pte));

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
