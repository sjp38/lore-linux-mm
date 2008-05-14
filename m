Date: Wed, 14 May 2008 17:08:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC/PATCH 3/6] memcg: handle swapcache.
Message-Id: <20080514170817.cf96f280.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080514170236.23c9ddd7.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "xemul@openvz.org" <xemul@openvz.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "hugh@veritas.com" <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Including changes in memory.stat file.

=
Now swapcache is not accounted. (because it had some troubles.)

This is retrying account swap cache, based on remove-refcnt patch.

 * If a page is swap-cache,  mem_cgroup_uncharge_page() will *not*
   uncharge a page even if page->mapcount == 0.
 * If a page is removed from swap-cache, mem_cgroup_uncharge_page()
   is called.
 * A new swapcache page is not charged until when it's mapped. By this
   we can avoid complicated read-ahead troubles.

 A file, memory.stat,"rss" member is changed to "anon/swapcache".
 (rss is not precise name here...)
 When all processes in cgroup exits, rss/swapcache counter can have some
 numbers because of lazy behavior of LRU. So the word "rss" is confusing.
 I can easily imagine a user says "Oh, there may be memory leak..."
 Precise counting of swapcache is too costly to be handled in memcg.

Change log: v2->v3
 - adjusted to 2.6.26-rc2+x
 - changed "rss" in stat to "rss/swapcache". (stat value includes swapcache)
Change log: v1->v2
 - adjusted to 2.6.25-mm1.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |    9 +++++----
 mm/migrate.c    |    3 ++-
 mm/swap_state.c |    1 +
 3 files changed, 8 insertions(+), 5 deletions(-)

Index: linux-2.6.26-rc2/mm/migrate.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/migrate.c
+++ linux-2.6.26-rc2/mm/migrate.c
@@ -359,7 +359,8 @@ static int migrate_page_move_mapping(str
 	write_unlock_irq(&mapping->tree_lock);
 	if (!PageSwapCache(newpage)) {
 		mem_cgroup_uncharge_cache_page(page);
-	}
+	} else
+		mem_cgroup_uncharge_page(page);
 
 	return 0;
 }
Index: linux-2.6.26-rc2/mm/swap_state.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/swap_state.c
+++ linux-2.6.26-rc2/mm/swap_state.c
@@ -110,6 +110,7 @@ void __delete_from_swap_cache(struct pag
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
+	mem_cgroup_uncharge_page(page);
 }
 
 /**
Index: linux-2.6.26-rc2/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc2.orig/mm/memcontrol.c
+++ linux-2.6.26-rc2/mm/memcontrol.c
@@ -44,10 +44,10 @@ static struct kmem_cache *page_cgroup_ca
  */
 enum mem_cgroup_stat_index {
 	/*
-	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss.
+	 * For MEM_CONTAINER_TYPE_ALL, usage = pagecache + rss/swapcache.
 	 */
 	MEM_CGROUP_STAT_CACHE, 	   /* # of pages charged as cache */
-	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as rss */
+	MEM_CGROUP_STAT_RSS,	   /* # of pages charged as anon/swapcache */
 	MEM_CGROUP_STAT_PGPGIN_COUNT,	/* # of pages paged in */
 	MEM_CGROUP_STAT_PGPGOUT_COUNT,	/* # of pages paged out */
 
@@ -696,7 +696,8 @@ void __mem_cgroup_uncharge_common(struct
 
 	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
 	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
-		|| page_mapped(page)))
+		|| page_mapped(page)
+		|| PageSwapCache(page)))
 		goto unlock;
 
 	mz = page_cgroup_zoneinfo(pc);
@@ -922,7 +923,7 @@ static const struct mem_cgroup_stat_desc
 	u64 unit;
 } mem_cgroup_stat_desc[] = {
 	[MEM_CGROUP_STAT_CACHE] = { "cache", PAGE_SIZE, },
-	[MEM_CGROUP_STAT_RSS] = { "rss", PAGE_SIZE, },
+	[MEM_CGROUP_STAT_RSS] = { "anon/swapcache", PAGE_SIZE, },
 	[MEM_CGROUP_STAT_PGPGIN_COUNT] = {"pgpgin", 1, },
 	[MEM_CGROUP_STAT_PGPGOUT_COUNT] = {"pgpgout", 1, },
 };

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
