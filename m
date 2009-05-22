Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BE8316B005C
	for <linux-mm@kvack.org>; Fri, 22 May 2009 04:07:10 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4M87FmH021103
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 22 May 2009 17:07:15 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DCFB745DE51
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:07:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id BCEEB45DE4F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:07:14 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id A8573E08001
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:07:14 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 645251DB803F
	for <linux-mm@kvack.org>; Fri, 22 May 2009 17:07:14 +0900 (JST)
Date: Fri, 22 May 2009 17:05:41 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 3/3] count swap caches whose swp_entry can be freed.
Message-Id: <20090522170541.ae14df90.kamezawa.hiroyu@jp.fujitsu.com>
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

Count a swap entry which is just a swapcache.
i.e. swap entry can be freed immediately.

This counter tells us there is a chance to reclaim swap entries.
Maybe good for mem+swap controller.
(Freeing routine itself is a homework...)

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    1 +
 mm/swapfile.c        |   15 ++++++++++++---
 2 files changed, 13 insertions(+), 3 deletions(-)

Index: mmotm-2.6.30-May17/include/linux/swap.h
===================================================================
--- mmotm-2.6.30-May17.orig/include/linux/swap.h
+++ mmotm-2.6.30-May17/include/linux/swap.h
@@ -156,6 +156,7 @@ struct swap_info_struct {
 	unsigned int max;
 	unsigned int inuse_pages;
 	unsigned int old_block_size;
+	unsigned int orphan_swap_cache;
 };
 
 struct swap_list_t {
Index: mmotm-2.6.30-May17/mm/swapfile.c
===================================================================
--- mmotm-2.6.30-May17.orig/mm/swapfile.c
+++ mmotm-2.6.30-May17/mm/swapfile.c
@@ -291,9 +291,10 @@ checks:
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
 	}
-	if (cache)
+	if (cache) {
 		si->swap_map[offset] = SWAP_HAS_CACHE; /* via get_swap_page() */
-	else
+		si->orphan_swap_cache++;
+	} else
 		si->swap_map[offset] = 1; /* via alloc_swap_block()  */
 
 	si->cluster_next = offset + 1;
@@ -521,9 +522,14 @@ static int swap_entry_free(struct swap_i
 			swap_list.next = p - swap_info;
 		nr_swap_pages++;
 		p->inuse_pages--;
+		if (cache)
+			p->orphan_swap_cache--;
 	}
-	if (!swap_has_ref(count))
+	if (!swap_has_ref(count)) {
 		mem_cgroup_uncharge_swap(ent);
+		if (count & SWAP_HAS_CACHE)
+			p->orphan_swap_cache++;
+	}
 	return count;
 }
 
@@ -2022,6 +2028,9 @@ int swap_duplicate(swp_entry_t entry)
 		goto out_unlock;
 
 	count = p->swap_map[offset] & SWAP_MAP_MASK;
+	if (!count && (p->swap_map[offset] & SWAP_HAS_CACHE))
+		p->orphan_swap_cache++;
+
 	if (count < SWAP_MAP_MAX - 1) {
 		p->swap_map[offset] += 1;
 		result = 1;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
