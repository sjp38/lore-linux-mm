Date: Mon, 14 Jul 2008 17:08:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH][resend][-mm] memcg: handle tmpfs' swapcache
Message-Id: <20080714170816.c34fdd30.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "xemul@openvz.org" <xemul@openvz.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

SwapCache handling fix.

shmem's swapcache behavior is a little different from anonymous's one and
memcg failed to handle it. This patch tries to fix it.

After this:

Any page marked as SwapCache is not uncharged. (delelte_from_swap_cache()
delete the flag.)

To check a page is alive shmem-page-cache or not we use
  page->mapping && !PageAnon(page)
 instead of
  pc->flags & PAGE_CGROUP_FLAG_CACHE. in current one.

This is a fix against memcg-handle-swap-cache.patch

After this, swapcache pages of tmpfs/shmem are handled by memcg.
(IOW, without this, swapcache used by tmpfs can occupy not-allowed memory.)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Index: linux-2.6.26-rc8-mm1/mm/memcontrol.c
===================================================================
--- linux-2.6.26-rc8-mm1.orig/mm/memcontrol.c
+++ linux-2.6.26-rc8-mm1/mm/memcontrol.c
@@ -687,11 +687,45 @@ __mem_cgroup_uncharge_common(struct page
 
 	VM_BUG_ON(pc->page != page);
 
-	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
-	    && ((pc->flags & PAGE_CGROUP_FLAG_CACHE)
-		|| page_mapped(page)
-		|| PageSwapCache(page)))
+	/*
+	 * File Cache
+	 * If called with MEM_CGROUP_CHARGE_TYPE_MAPPED, check page->mapping.
+	 * add_to_page_cache() .... charged before inserting radix-tree.
+	 * remove_from_page_cache() .... uncharged at removing from radix-tree.
+	 * page->mapping && !PageAnon(page) catches file cache.
+	 *
+	 * Anon/Shmem.....We check PageSwapCache(page).
+	 * Anon .... charged before mapped.
+	 * Shmem .... charged at add_to_page_cache() as usual File Cache.
+	 *
+	 * This page will be finally uncharged when removed from swap-cache
+	 *
+	 * we treat 2 cases here.
+	 * A. anonymous page  B. shmem.
+	 * We never uncharge if page is marked as SwapCache.
+	 * add_to_swap_cache() have nothing to do with charge/uncharge.
+	 * SwapCache flag is deleted before delete_from_swap_cache() calls this
+	 *
+	 * shmem's behavior is following. (see shmem.c/swap_state.c also)
+	 * at swap-out:
+	 * 	0. add_to_page_cache()//charged at page creation.
+	 * 	1. add_to_swap_cache() (marked as SwapCache)
+	 *	2. remove_from_page_cache().  (calls this.)
+	 *	(finally) delete_from_swap_cache(). (calls this.)
+	 * at swap-in:
+	 * 	3. add_to_swap_cache() (no charge here.)
+	 * 	4. add_to_page_cache() (charged here.)
+	 * 	5. delete_from_swap_cache() (calls this.)
+	 * PageSwapCache(page) catches "2".
+	 * page->mapping && !PageAnon() catches "5" and avoid uncharging.
+	 */
+	if (PageSwapCache(page))
 		goto unlock;
+	/* called from unmap or delete_from_swap_cache() ? */
+	if ((ctype == MEM_CGROUP_CHARGE_TYPE_MAPPED)
+		&& (page_mapped(page)
+		    || (page->mapping && !PageAnon(page))))/* alive cache ? */
+			goto unlock;
 
 	mz = page_cgroup_zoneinfo(pc);
 	spin_lock_irqsave(&mz->lru_lock, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
