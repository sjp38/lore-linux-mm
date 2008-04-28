Date: Mon, 28 Apr 2008 20:24:18 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/8] memcg: swapcache handling retry
Message-Id: <20080428202418.a556553e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080428201900.ae25e086.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>
List-ID: <linux-mm.kvack.org>

Now swapcache is not accounted. (because it had some troubles.)

This is retrying account swap cache, based on remove-refcnt patch.

This does.
 * When a page is swap-cache,  mem_cgroup_uncharge_page() will *not*
   uncharge page even if page->mapcount == 0.
 * When a page is removed from swap-cache, mem_cgroup_uncharge_page()
   is called again.
 * A swapcache page is newly charged only when it's mapped.

Changelog:
 - adjusted to 2.6.25-mm1.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/migrate.c    |    3 ++-
 mm/swap_state.c |    1 +
 2 files changed, 3 insertions(+), 1 deletion(-)

Index: mm-2.6.25-mm1/mm/migrate.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/migrate.c
+++ mm-2.6.25-mm1/mm/migrate.c
@@ -359,7 +359,8 @@ static int migrate_page_move_mapping(str
 	write_unlock_irq(&mapping->tree_lock);
 	if (!PageSwapCache(newpage)) {
 		mem_cgroup_uncharge_cache_page(page);
-	}
+	} else
+		mem_cgroup_uncharge_page(page);
 
 	return 0;
 }
Index: mm-2.6.25-mm1/mm/swap_state.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/swap_state.c
+++ mm-2.6.25-mm1/mm/swap_state.c
@@ -110,6 +110,7 @@ void __delete_from_swap_cache(struct pag
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
+	mem_cgroup_uncharge_page(page);
 }
 
 /**
Index: mm-2.6.25-mm1/mm/memcontrol.c
===================================================================
--- mm-2.6.25-mm1.orig/mm/memcontrol.c
+++ mm-2.6.25-mm1/mm/memcontrol.c
@@ -675,7 +675,8 @@ void __mem_cgroup_uncharge_common(struct
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
 	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
-		|| page_mapped(page)))
+		|| page_mapped(page)
+		|| PageSwapCache(page)))
 		goto unlock;
 
 	mz = page_cgroup_zoneinfo(pc);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
