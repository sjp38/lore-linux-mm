Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id C47796B005C
	for <linux-mm@kvack.org>; Fri, 29 May 2009 01:39:00 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4T5dYLj032716
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 May 2009 14:39:35 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 5BC5645DD77
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:39:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 2AC4145DD76
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:39:34 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1A4181DB801F
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:39:34 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id B0F7A1DB801B
	for <linux-mm@kvack.org>; Fri, 29 May 2009 14:39:33 +0900 (JST)
Date: Fri, 29 May 2009 14:37:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 1/4] add swap cache interface for swap reference v2
 (updated)
Message-Id: <20090529143758.4c3db3eb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090529140832.1f4b288b.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090528135455.0c83bedc.kamezawa.hiroyu@jp.fujitsu.com>
	<20090528141049.cc45a116.kamezawa.hiroyu@jp.fujitsu.com>
	<20090529132153.3a72f2c3.nishimura@mxp.nes.nec.co.jp>
	<20090529140832.1f4b288b.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, 29 May 2009 14:08:32 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > IIUC, swap_free() at the end of shmem_writepage() should also be changed to swapcache_free().
> > 
> Hmm!. Oh, yes. shmem_writepage()'s error path. Thank you. It will be fixed.
> 
here. 

==

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

In following patch, usage of swap cache will be recorded into swap_map.
This patch is for necessary interface changes to do that.

2 interfaces:
  - swapcache_prepare()
  - swapcache_free()
is added for allocating/freeing refcnt from swap-cache to existing
swap entries. But implementation itself is not changed under this patch.
At adding swapcache_free(), memcg's hook code is moved under swapcache_free().
This is better than using scattered hooks.

Changelog: v1->v2
 - fixed shmem_writepage() error path.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    7 +++++++
 mm/shmem.c           |    2 +-
 mm/swap_state.c      |   11 +++++------
 mm/swapfile.c        |   19 +++++++++++++++++++
 mm/vmscan.c          |    3 +--
 5 files changed, 33 insertions(+), 9 deletions(-)

Index: mmotm-2.6.30-May28/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May28.orig/include/linux/swap.h
+++ mmotm-2.6.30-May28/include/linux/swap.h
@@ -282,8 +282,10 @@ extern void si_swapinfo(struct sysinfo *
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
 extern int swap_duplicate(swp_entry_t);
+extern int swapcache_prepare(swp_entry_t);
 extern int valid_swaphandles(swp_entry_t, unsigned long *);
 extern void swap_free(swp_entry_t);
+extern void swapcache_free(swp_entry_t, struct page *page);
 extern int free_swap_and_cache(swp_entry_t);
 extern int swap_type_of(dev_t, sector_t, struct block_device **);
 extern unsigned int count_swap_pages(int, int);
@@ -352,11 +354,16 @@ static inline void show_swap_cache_info(
 
 #define free_swap_and_cache(swp)	is_migration_entry(swp)
 #define swap_duplicate(swp)		is_migration_entry(swp)
+#define swapcache_prepare(swp)		is_migration_entry(swp)
 
 static inline void swap_free(swp_entry_t swp)
 {
 }
 
+static inline void swapcache_free(swp_entry_t swp, struct page *page)
+{
+}
+
 static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
Index: mmotm-2.6.30-May28/mm/swap_state.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/swap_state.c
+++ mmotm-2.6.30-May28/mm/swap_state.c
@@ -162,11 +162,11 @@ int add_to_swap(struct page *page)
 			return 1;
 		case -EEXIST:
 			/* Raced with "speculative" read_swap_cache_async */
-			swap_free(entry);
+			swapcache_free(entry, NULL);
 			continue;
 		default:
 			/* -ENOMEM radix-tree allocation failure */
-			swap_free(entry);
+			swapcache_free(entry, NULL);
 			return 0;
 		}
 	}
@@ -188,8 +188,7 @@ void delete_from_swap_cache(struct page 
 	__delete_from_swap_cache(page);
 	spin_unlock_irq(&swapper_space.tree_lock);
 
-	mem_cgroup_uncharge_swapcache(page, entry);
-	swap_free(entry);
+	swapcache_free(entry, page);
 	page_cache_release(page);
 }
 
@@ -293,7 +292,7 @@ struct page *read_swap_cache_async(swp_e
 		/*
 		 * Swap entry may have been freed since our caller observed it.
 		 */
-		if (!swap_duplicate(entry))
+		if (!swapcache_prepare(entry))
 			break;
 
 		/*
@@ -317,7 +316,7 @@ struct page *read_swap_cache_async(swp_e
 		}
 		ClearPageSwapBacked(new_page);
 		__clear_page_locked(new_page);
-		swap_free(entry);
+		swapcache_free(entry, NULL);
 	} while (err != -ENOMEM);
 
 	if (new_page)
Index: mmotm-2.6.30-May28/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/swapfile.c
+++ mmotm-2.6.30-May28/mm/swapfile.c
@@ -510,6 +510,16 @@ void swap_free(swp_entry_t entry)
 }
 
 /*
+ * Called after dropping swapcache to decrease refcnt to swap entries.
+ */
+void swapcache_free(swp_entry_t entry, struct page *page)
+{
+	if (page)
+		mem_cgroup_uncharge_swapcache(page, entry);
+	return swap_free(entry);
+}
+
+/*
  * How many references to page are currently swapped out?
  */
 static inline int page_swapcount(struct page *page)
@@ -1979,6 +1989,15 @@ bad_file:
 	goto out;
 }
 
+/*
+ * Called when allocating swap cache for exising swap entry,
+ */
+int swapcache_prepare(swp_entry_t entry)
+{
+	return swap_duplicate(entry);
+}
+
+
 struct swap_info_struct *
 get_swap_info_struct(unsigned type)
 {
Index: mmotm-2.6.30-May28/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/vmscan.c
+++ mmotm-2.6.30-May28/mm/vmscan.c
@@ -477,8 +477,7 @@ static int __remove_mapping(struct addre
 		swp_entry_t swap = { .val = page_private(page) };
 		__delete_from_swap_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
-		mem_cgroup_uncharge_swapcache(page, swap);
-		swap_free(swap);
+		swapcache_free(swap, page);
 	} else {
 		__remove_from_page_cache(page);
 		spin_unlock_irq(&mapping->tree_lock);
Index: mmotm-2.6.30-May28/mm/shmem.c
===================================================================
--- mmotm-2.6.30-May28.orig/mm/shmem.c
+++ mmotm-2.6.30-May28/mm/shmem.c
@@ -1097,7 +1097,7 @@ static int shmem_writepage(struct page *
 	shmem_swp_unmap(entry);
 unlock:
 	spin_unlock(&info->lock);
-	swap_free(swap);
+	swapcache_free(swap, NULL);
 redirty:
 	set_page_dirty(page);
 	if (wbc->for_reclaim)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
