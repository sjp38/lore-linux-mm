Date: Mon, 22 Sep 2008 20:02:04 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 5/13] memcg: cleanup to make mapping null before unchage
Message-Id: <20080922200204.d2548297.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

This patch tries to make page->mapping to be NULL before
mem_cgroup_uncharge_cache_page() is called.

"page->mapping == NULL" is a good check for "whether the page is still
radix-tree or not".
This patch also adds BUG_ON() to mem_cgroup_uncharge_cache_page();


Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

 mm/filemap.c    |    2 +-
 mm/memcontrol.c |    1 +
 mm/migrate.c    |   12 +++++++++---
 3 files changed, 11 insertions(+), 4 deletions(-)

Index: mmotm-2.6.27-rc6+/mm/filemap.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/filemap.c
+++ mmotm-2.6.27-rc6+/mm/filemap.c
@@ -116,12 +116,12 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page->mapping;
 
-	mem_cgroup_uncharge_cache_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = NULL;
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	BUG_ON(page_mapped(page));
+	mem_cgroup_uncharge_cache_page(page);
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
Index: mmotm-2.6.27-rc6+/mm/memcontrol.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/memcontrol.c
+++ mmotm-2.6.27-rc6+/mm/memcontrol.c
@@ -859,6 +859,7 @@ void mem_cgroup_uncharge_page(struct pag
 void mem_cgroup_uncharge_cache_page(struct page *page)
 {
 	VM_BUG_ON(page_mapped(page));
+	VM_BUG_ON(page->mapping);
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
Index: mmotm-2.6.27-rc6+/mm/migrate.c
===================================================================
--- mmotm-2.6.27-rc6+.orig/mm/migrate.c
+++ mmotm-2.6.27-rc6+/mm/migrate.c
@@ -330,8 +330,6 @@ static int migrate_page_move_mapping(str
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 
 	spin_unlock_irq(&mapping->tree_lock);
-	if (!PageSwapCache(newpage))
-		mem_cgroup_uncharge_cache_page(page);
 
 	return 0;
 }
@@ -378,7 +376,15 @@ static void migrate_page_copy(struct pag
 #endif
 	ClearPagePrivate(page);
 	set_page_private(page, 0);
-	page->mapping = NULL;
+	/* page->mapping contains a flag for PageAnon() */
+	if (PageAnon(page)) {
+		/* This page is uncharged at try_to_unmap(). */
+		page->mapping = NULL;
+	} else {
+		/* Obsolete file cache should be uncharged */
+		page->mapping = NULL;
+		mem_cgroup_uncharge_cache_page(page);
+	}
 
 	/*
 	 * If any waiters have accumulated on the new page then

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
