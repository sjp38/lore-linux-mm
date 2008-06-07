Date: Sat, 7 Jun 2008 15:23:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg fix handle swap cache (was Re: memcg: bad page at
 page migration)
Message-Id: <20080607152309.a003b181.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
References: <20080606221124.623847aa.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: akpm@linux-foundation.org, balbir@linux.vnet.ibm.com, xemul@openvz.org, lizf@cn.fujitsu.com, yamamoto@valinux.co.jp, hugh@veritas.com, minchan.kim@gmail.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Nishimura-san, thank you for your precise report!.

I think this is a fix. could you try ?

Andrew, this is a fix on memcg-handle-swap-cache.patch

Tested on my x86-64 box and fixes the bug.
==
Now (-mm queue), SwapCache is handled by memcg.
But Handling migration of swap-cache was wrong.

Fix to call uncharge() after ClearPageSwapCache() as
__delete_from_swap_cache()(swap_state.c) does.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtsu.com.

Index: linux-2.6.26-rc2-mm1/mm/migrate.c
===================================================================
--- linux-2.6.26-rc2-mm1.orig/mm/migrate.c
+++ linux-2.6.26-rc2-mm1/mm/migrate.c
@@ -358,10 +358,8 @@ static int migrate_page_move_mapping(str
 	__inc_zone_page_state(newpage, NR_FILE_PAGES);
 
 	write_unlock_irq(&mapping->tree_lock);
-	if (!PageSwapCache(newpage)) {
+	if (!PageSwapCache(newpage))
 		mem_cgroup_uncharge_cache_page(page);
-	} else
-		mem_cgroup_uncharge_page(page);
 
 	return 0;
 }
@@ -399,7 +397,15 @@ static void migrate_page_copy(struct pag
  	}
 
 #ifdef CONFIG_SWAP
-	ClearPageSwapCache(page);
+	if (PageSwapCache(page)) {
+		ClearPageSwapCache(page);
+		/*
+		 * SwapCache is removed implicitly. Uncharge against swapcache
+		 * should be called after ClearPageSwapCache() because
+		 * mem_cgroup_uncharge_page checks the flag.
+		 */
+		mem_cgroup_uncharge_page(page);
+	}
 #endif
 	ClearPageActive(page);
 	ClearPagePrivate(page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
