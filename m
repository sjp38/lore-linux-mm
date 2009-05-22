Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 131CB6B0055
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:05:40 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M85ipr020335
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 17:05:44 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 342DE45DE66
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:05:44 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 394B445DE61
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:05:43 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id D9D441DB803B
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:05:42 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id A09DAE08009
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:05:41 +0900 (JST)
Date: Fri, 22 May 2009 17:04:08 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 2/3] fix memcg  swap account to handle swap ref itself
Message-Id: <20090522170408.9b9772b3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090522165730.8791c2dd.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090522165730.8791c2dd.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Now, memory cgroup's swap account is called when swap entry is
completely free. But that bahavior doesn't work well when
"swap is freed but there is still swap cache" case.
We have to wait until global LRU run and kick it out...

This patch modifes memcg's swap account to be uncharged when references to
swap goes down to 0 even if there is a swap cache. Then, account for swap
is effectively decremented.

To do this, I moved swapcache uncharge code  under swap_lock. 
(modified swapcache_free()).

In viewpoint of the system level (i.e. not cgroup level), swp_entry
itself is not freed until global LRU runs.
Then, some clever operation as vm_swap_full() may be necessary..
But, swap account information itself is uncharged and memcg will work fine.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    9 +++++----
 mm/memcontrol.c      |   16 ++++++++++------
 mm/shmem.c           |    2 +-
 mm/swap_state.c      |    8 ++++----
 mm/swapfile.c        |   14 +++++++++++---
 mm/vmscan.c          |    3 +--
 6 files changed, 32 insertions(+), 20 deletions(-)

Index: mmotm-2.6.30-May17/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swapfile.c
+++ mmotm-2.6.30-May17/mm/swapfile.c
@@ -521,8 +521,9 @@ static int swap_entry_free(struct swap_i
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
-		mem_cgroup_uncharge_swap(ent);
 	}
+	if (!swap_has_ref(count))
+		mem_cgroup_uncharge_swap(ent);
 	return count;
 }
 
@@ -542,13 +543,20 @@ void swap_free(swp_entry_t entry)
 }
 
 /* called at freeing swap cache */
-void swapcache_free(swp_entry_t entry)
+void swapcache_free(swp_entry_t entry, struct page *page)
 {
 	struct swap_info_struct *p;
+	int ret;
 
 	p = swap_info_get(entry);
 	if (p) {
-		swap_entry_free(p, entry, 1);
+		ret = swap_entry_free(p, entry, 1);
+		if (page) {
+			if (ret) /* swap still remains */
+				mem_cgroup_uncharge_swapcache(page, entry, 1);
+			else /* this was the last user of swap entry */
+				mem_cgroup_uncharge_swapcache(page, entry, 0);
+		}
 		spin_unlock(&swap_lock);
 	}
 }
Index: mmotm-2.6.30-May17/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May17.orig/include/linux/swap.h
+++ mmotm-2.6.30-May17/include/linux/swap.h
@@ -305,7 +305,7 @@ extern swp_entry_t get_swap_page_of_type
 extern int swap_duplicate(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
-extern void swapcache_free(swp_entry_t);
+extern void swapcache_free(swp_entry_t, struct page*);
 extern int swapcache_prepare(swp_entry_t);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
@@ -339,10 +339,11 @@ static inline void disable_swap_token(vo
 }
 
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR
-extern void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent);
+extern void
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, int swapout);
 #else
 static inline void
-mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent, int swapout)
 {
 }
 #endif
@@ -380,7 +381,7 @@ static inline void swap_free(swp_entry_t
 {
 }
 
-static inline void swapcache_free(swp_entry_t swp)
+static inline void swapcache_free(swp_entry_t swp, struct page *page)
 {
 }
 
Index: mmotm-2.6.30-May17/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/memcontrol.c
+++ mmotm-2.6.30-May17/mm/memcontrol.c
@@ -1564,18 +1564,22 @@ void mem_cgroup_uncharge_cache_page(stru
  * called after __delete_from_swap_cache() and drop "page" account.
  * memcg information is recorded to swap_cgroup of "ent"
  */
-void mem_cgroup_uncharge_swapcache(struct page *page, swp_entry_t ent)
+void mem_cgroup_uncharge_swapcache(struct page *page,
+				   swp_entry_t ent, int swapout)
 {
 	struct mem_cgroup *memcg;
+	int ctype = MEM_CGROUP_CHARGE_TYPE_SWAPOUT;
 
-	memcg = __mem_cgroup_uncharge_common(page,
-					MEM_CGROUP_CHARGE_TYPE_SWAPOUT);
+	/* swap_entry is freed ? */
+	if (!swapout)
+		ctype = MEM_CGROUP_CHARGE_TYPE_MAPPED;
+	memcg = __mem_cgroup_uncharge_common(page, ctype);
 	/* record memcg information */
-	if (do_swap_account && memcg) {
+	if (do_swap_account && swapout && memcg) {
 		swap_cgroup_record(ent, css_id(&memcg->css));
 		mem_cgroup_get(memcg);
 	}
-	if (memcg)
+	if (swapout && memcg)
 		css_put(&memcg->css);
 }
 #endif
@@ -1583,7 +1587,7 @@ void mem_cgroup_uncharge_swapcache(struc
 #ifdef CONFIG_CGROUP_MEM_RES_CTLR_SWAP
 /*
  * called from swap_entry_free(). remove record in swap_cgroup and
- * uncharge "memsw" account.
+ * uncharge "memsw" account. we are under swap_lock.
  */
 void mem_cgroup_uncharge_swap(swp_entry_t ent)
 {
Index: mmotm-2.6.30-May17/mm/shmem.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/shmem.c
+++ mmotm-2.6.30-May17/mm/shmem.c
@@ -1097,7 +1097,7 @@ static int shmem_writepage(struct page *
 	shmem_swp_unmap(entry);
 unlock:
 	spin_unlock(&info->lock);
-	swapcache_free(swap);
+	swapcache_free(swap, page);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)
Index: mmotm-2.6.30-May17/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swap_state.c
+++ mmotm-2.6.30-May17/mm/swap_state.c
@@ -162,11 +162,11 @@ int add_to_swap(struct page *page)
 			return 1;
 		case -EEXIST:
 			/* Raced with "speculative" read_swap_cache_async */
-			swapcache_free(entry);
+			swapcache_free(entry, page);
 			continue;
 		default:
 			/* -ENOMEM radix-tree allocation failure */
-			swapcache_free(entry);
+			swapcache_free(entry, page);
 			return 0;
 		}
 	}
@@ -188,7 +188,7 @@ void delete_from_swap_cache(struct page 
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&swapper_space.tree_lock);
 
-	swapcache_free(entry);
+	swapcache_free(entry, page);
 	page_cache_release(page);
 }
 
@@ -318,7 +318,7 @@ struct page *read_swap_cache_async(swp_e
 		}
 		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
-		swapcache_free(entry);
+		swapcache_free(entry, new_page);
 	} while (err != -ENOMEM);
 
 	if (new_page)
Index: mmotm-2.6.30-May17/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/vmscan.c
+++ mmotm-2.6.30-May17/mm/vmscan.c
@@ -477,8 +477,7 @@ static int __remove_mapping(struct addre
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
-		mem_cgroup_uncharge_swapcache(page, swap);
-		swapcache_free(swap);
+		swapcache_free(swap, page);
 	} else {
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
