Date: Mon, 3 Apr 2006 23:57:55 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060404065755.24532.9710.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
References: <20060404065739.24532.95451.sendpatchset@schroedinger.engr.sgi.com>
Subject: [RFC 3/6] Swapless V1: try_to_unmap() - Create migration entries
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, lhms-devel@lists.sourceforge.net, Hirokazu Takahashi <taka@valinux.co.jp>, Marcelo Tosatti <marcelo.tosatti@cyclades.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Modify try_to_unmap to produce swap migration entries

If we are trying to unmap an entry and do not have an associated
swapcache entry but are doing migration then create a special
swap pte of type SWP_TYPE_MIGRATION pointing to the pfn.

Signed-off-by: Christoph Lameter <clameter@sgi.com>

Index: linux-2.6.17-rc1/mm/rmap.c
===================================================================
--- linux-2.6.17-rc1.orig/mm/rmap.c	2006-04-03 22:33:56.000000000 -0700
+++ linux-2.6.17-rc1/mm/rmap.c	2006-04-03 22:50:00.000000000 -0700
@@ -620,6 +620,17 @@ static int try_to_unmap_one(struct page 
 
 	if (PageAnon(page)) {
 		swp_entry_t entry = { .val = page_private(page) };
+
+		if (!PageSwapCache(page) && migration) {
+			/*
+			 * Store the pfn of the page in a special migration
+			 * pte. do_swap_page() will wait until the page is unlocked
+			 * and then restart the fault handling.
+			 */
+			entry = swp_entry(SWP_TYPE_MIGRATION, page_to_pfn(page));
+			set_pte_at(mm, address, pte, swp_entry_to_pte(entry));
+			goto finish;
+		}
 		/*
 		 * Store the swap location in the pte.
 		 * See handle_pte_fault() ...
@@ -638,6 +649,7 @@ static int try_to_unmap_one(struct page 
 	} else
 		dec_mm_counter(mm, file_rss);
 
+finish:
 	page_remove_rmap(page);
 	page_cache_release(page);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
