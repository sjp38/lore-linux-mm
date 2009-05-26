Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1711C6B006A
	for <linux-mm@kvack.org>; Mon, 25 May 2009 23:17:57 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4Q3IC43021184
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 26 May 2009 12:18:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 04E2745DE51
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:18:12 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D938B45DD79
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:18:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B1997E18001
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:18:11 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 595381DB803C
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:18:11 +0900 (JST)
Date: Tue, 26 May 2009 12:16:38 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/5] count cache-only swaps
Message-Id: <20090526121638.398c6951.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090526121259.b91b3e9d.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch adds a counter for unused swap caches.
Maybe useful to see "we're really under shortage of swap".

The value can be seen as kernel message at Sysrq-m etc.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    3 +++
 mm/swap_state.c      |    2 ++
 mm/swapfile.c        |   23 ++++++++++++++++++++---
 3 files changed, 25 insertions(+), 3 deletions(-)

Index: new-trial-swapcount/include/linux/swap.h
===================================================================
--- new-trial-swapcount.orig/include/linux/swap.h
+++ new-trial-swapcount/include/linux/swap.h
@@ -155,6 +155,7 @@ struct swap_info_struct {
 	unsigned int max;
 	unsigned int inuse_pages;
 	unsigned int old_block_size;
+	unsigned int cache_only;
 };
 
 struct swap_list_t {
@@ -298,6 +299,7 @@ extern struct page *swapin_readahead(swp
 /* linux/mm/swapfile.c */
 extern long nr_swap_pages;
 extern long total_swap_pages;
+extern long nr_cache_only_swaps;
 extern void si_swapinfo(struct sysinfo *);
 extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
@@ -358,6 +360,7 @@ static inline void mem_cgroup_uncharge_s
 #define nr_swap_pages				0L
 #define total_swap_pages			0L
 #define total_swapcache_pages			0UL
+#define nr_cache_only_swaps			0UL
 
 #define si_swapinfo(val) \
 	do { (val)->freeswap = (val)->totalswap = 0; } while (0)
Index: new-trial-swapcount/mm/swapfile.c
===================================================================
--- new-trial-swapcount.orig/mm/swapfile.c
+++ new-trial-swapcount/mm/swapfile.c
@@ -39,6 +39,7 @@ static DEFINE_SPINLOCK(swap_lock);
 static unsigned int nr_swapfiles;
 long nr_swap_pages;
 long total_swap_pages;
+long nr_cache_only_swaps;
 static int swap_overflow;
 static int least_priority;
 
@@ -306,9 +307,11 @@ checks:
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
 	}
-	if (cache) /* at usual swap-out via vmscan.c */
+	if (cache) {/* at usual swap-out via vmscan.c */
 		si->swap_map[offset] = make_swap_count(0, 1);
-	else /* at suspend */
+		si->cache_only++;
+		nr_cache_only_swaps++;
+	} else /* at suspend */
 		si->swap_map[offset] = make_swap_count(1, 0);
 	si->cluster_next = offset + 1;
 	si->flags -= SWP_SCANNING;
@@ -513,7 +516,10 @@ static int swap_entry_free(struct swap_i
 	} else { /* dropping swap cache flag */
 		VM_BUG_ON(!has_cache);
 		p->swap_map[offset] = make_swap_count(count, 0);
-
+		if (!count) {
+			p->cache_only--;
+			nr_cache_only_swaps--;
+		}
 	}
 	/* return code. */
 	count = p->swap_map[offset];
@@ -529,6 +535,11 @@ static int swap_entry_free(struct swap_i
 		p->inuse_pages--;
 		mem_cgroup_uncharge_swap(ent);
 	}
+	if (swap_has_cache(count) && !swap_count(count)) {
+		nr_cache_only_swaps++;
+		p->cache_only++;
+	}
+
 	return count;
 }
 
@@ -1128,6 +1139,8 @@ static int try_to_unuse(unsigned int typ
 		if (swap_count(*swap_map) == SWAP_MAP_MAX) {
 			spin_lock(&swap_lock);
 			*swap_map = make_swap_count(0, 1);
+			si->cache_only++;
+			nr_cache_only_swaps++;
 			spin_unlock(&swap_lock);
 			reset_overflow = 1;
 		}
@@ -2033,6 +2046,10 @@ static int __swap_duplicate(swp_entry_t 
 		if (count < SWAP_MAP_MAX - 1) {
 			p->swap_map[offset] = make_swap_count(count + 1,
 							      has_cache);
+			if (has_cache && !count) {
+				p->cache_only--;
+				nr_cache_only_swaps--;
+			}
 			result = 1;
 		} else if (count <= SWAP_MAP_MAX) {
 			if (swap_overflow++ < 5)
Index: new-trial-swapcount/mm/swap_state.c
===================================================================
--- new-trial-swapcount.orig/mm/swap_state.c
+++ new-trial-swapcount/mm/swap_state.c
@@ -63,6 +63,8 @@ void show_swap_cache_info(void)
 		swap_cache_info.find_success, swap_cache_info.find_total);
 	printk("Free swap  = %ldkB\n", nr_swap_pages << (PAGE_SHIFT - 10));
 	printk("Total swap = %lukB\n", total_swap_pages << (PAGE_SHIFT - 10));
+	printk("Cache only swap = %lukB\n",
+	       nr_cache_only_swaps << (PAGE_SHIFT - 10));
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
