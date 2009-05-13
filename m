Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 127F76B00BF
	for <linux-mm@kvack.org>; Wed, 13 May 2009 00:34:29 -0400 (EDT)
Date: Wed, 13 May 2009 13:30:31 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][PATCH] memcg: fix deadlock between lock_page_cgroup and
 mapping tree_lock
Message-Id: <20090513133031.f4be15a8.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@in.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

mapping->tree_lock can be aquired from interrupt context.
Then, following dead lock can occur.

Assume "A" as a page.

 CPU0:
       lock_page_cgroup(A)
		interrupted
			-> take mapping->tree_lock.
 CPU1:
       take mapping->tree_lock
		-> lock_page_cgroup(A)

This patch tries to fix above deadlock by moving memcg's hook to out of
mapping->tree_lock.
charge/uncharge of pagecache/swapcache is protected by page lock, not tree_lock.

After this patch, lock_page_cgroup() is not called under mapping->tree_lock.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 include/linux/swap.h |    5 +++++
 mm/filemap.c         |    6 +++---
 mm/memcontrol.c      |    4 +++-
 mm/swap_state.c      |    4 +---
 mm/truncate.c        |    1 +
 mm/vmscan.c          |    2 ++
 6 files changed, 15 insertions(+), 7 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index caf0767..6ea541d 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -431,6 +431,11 @@ static inline swp_entry_t get_swap_page(void)
 #define has_swap_token(x) 0
 #define disable_swap_token() do { } while(0)
 
+static inline void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+{
+}
+
 #endif /* CONFIG_SWAP */
 #endif /* __KERNEL__*/
 #endif /* _LINUX_SWAP_H */
diff --git a/mm/filemap.c b/mm/filemap.c
index 379ff0b..1b60f30 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -121,7 +121,6 @@ void __remove_from_page_cache(struct page *page)
 	mapping->nrpages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	BUG_ON(page_mapped(page));
-	mem_cgroup_uncharge_cache_page(page);
 
 	/*
 	 * Some filesystems seem to re-dirty the page even after
@@ -145,6 +144,7 @@ void remove_from_page_cache(struct page *page)
 	spin_lock_irq(&mapping->tree_lock);
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
+	mem_cgroup_uncharge_cache_page(page);
 }
 
 static int sync_page(void *word)
@@ -476,13 +476,13 @@ int add_to_page_cache_locked(struct page *page, struct address_space *mapping,
 		if (likely(!error)) {
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
+			spin_unlock_irq(&mapping->tree_lock);
 		} else {
 			page->mapping = NULL;
+			spin_unlock_irq(&mapping->tree_lock);
 			mem_cgroup_uncharge_cache_page(page);
 			page_cache_release(page);
 		}
-
-		spin_unlock_irq(&mapping->tree_lock);
 		radix_tree_preload_end();
 	} else
 		mem_cgroup_uncharge_cache_page(page);
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 0c9c1ad..89523cf 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1488,8 +1488,9 @@ void mem_cgroup_uncharge_cache_page(struct page *page)
 	__mem_cgroup_uncharge_common(page, MEM_CGROUP_CHARGE_TYPE_CACHE);
 }
 
+#ifdef CONFIG_SWAP
 /*
- * called from __delete_from_swap_cache() and drop "page" account.
+ * called after __delete_from_swap_cache() and drop "page" account.
  * memcg information is recorded to swap_cgroup of "ent"
  */
 void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
@@ -1506,6 +1507,7 @@ void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
 	if (memcg)
 		css_put(&memcg->css);
 }
+#endif
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /*
diff --git a/mm/swap_state.c b/mm/swap_state.c
index e389ef2..7624c89 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -109,8 +109,6 @@ int add_to_swap_cache(struct page *page, swp_entry_t entry, gfp_t gfp_mask)
  */
 void __delete_from_swap_cache(struct page *page)
 {
-	swp_entry_t ent = {.val = page_private(page)};
-
 	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(!PageSwapCache(page));
 	VM_BUG_ON(PageWriteback(page));
@@ -121,7 +119,6 @@ void __delete_from_swap_cache(struct page *page)
 	total_swapcache_pages--;
 	__dec_zone_page_state(page, NR_FILE_PAGES);
 	INC_CACHE_INFO(del_total);
-	mem_cgroup_uncharge_swapcache(page, ent);
 }
 
 /**
@@ -191,6 +188,7 @@ void delete_from_swap_cache(struct page *page)
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&swapper_space.tree_lock);
 
+	mem_cgroup_uncharge_swapcache(page, entry);
 	swap_free(entry);
 	page_cache_release(page);
 }
diff --git a/mm/truncate.c b/mm/truncate.c
index 55206fa..12e1579 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -359,6 +359,7 @@ invalidate_complete_page2(struct address_space *mapping, struct page *page)
 	BUG_ON(page_has_private(page));
 	__remove_from_page_cache(page);
 	spin_unlock_irq(&mapping->tree_lock);
+	mem_cgroup_uncharge_cache_page(page);
 	page_cache_release(page);	/* pagecache ref */
 	return 1;
 failed:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 337be66..a7d7a06 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -470,10 +470,12 @@ static int __remove_mapping(struct address_space *mapping, struct page *page)
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
+		mem_cgroup_uncharge_swapcache(page, swap);
 		swap_free(swap);
 	} else {
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
+		mem_cgroup_uncharge_cache_page(page);
 	}
 
 	return 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
