Subject: [PATCH] shrink_list skip anon pages if not may_swap
From: Lee Schermerhorn <lee.schermerhorn@hp.com>
Reply-To: lee.schermerhorn@hp.com
Content-Type: text/plain
Date: Mon, 12 Sep 2005 13:29:51 -0400
Message-Id: <1126546191.5182.29.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>
Cc: Martin Hicks <mort@sgi.com>, lhms-devel <lhms-devel@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

Martin Hicks' page cache reclaim patch added the 'may_swap' flag to the
scan_control struct; and modified shrink_list() not to add anon pages to
the swap cache if may_swap is not asserted. 

Ref:  http://marc.theaimsgroup.com/?l=linux-mm&m=111461480725322&w=4

However, further down, if the page is mapped, shrink_list() calls
try_to_unmap() which will call try_to_unmap_one() via try_to_unmap_anon
().  try_to_unmap_one() will BUG_ON() an anon page that is NOT in the
swap cache.  Martin says he never encountered this path in his testing,
but agrees that it might happen.  

This patch modifies shrink_list() to skip anon pages that are not
already in the swap cache when !may_swap, rather than just not adding
them to the cache.

Cc to lhms-devel because memory hotplug page migration also uses
shrink_list.

Signed-off-by:  Lee Schermerhorn <lee.schermerhorn@hp.com>
============================================================
--- shrink_list-skip-anon-pages-if-not-may_swap/mm/vmscan.c~original	2005-08-28 19:41:01.000000000 -0400
+++ shrink_list-skip-anon-pages-if-not-may_swap/mm/vmscan.c	2005-09-12 10:17:01.000000000 -0400
@@ -417,7 +417,9 @@ static int shrink_list(struct list_head 
 		 * Anonymous process memory has backing store?
 		 * Try to allocate it some swap space here.
 		 */
-		if (PageAnon(page) && !PageSwapCache(page) && sc->may_swap) {
+		if (PageAnon(page) && !PageSwapCache(page)) {
+			if (!sc->may_swap)
+				goto keep_locked;
 			if (!add_to_swap(page))
 				goto activate_locked;
 		}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
