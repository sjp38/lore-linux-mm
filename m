Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F93F6B0085
	for <linux-mm@kvack.org>; Mon, 25 May 2009 23:19:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4Q3KCm7000916
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 26 May 2009 12:20:12 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CBEB345DE57
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:20:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AAF1045DE55
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:20:11 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7F5761DB803B
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:20:11 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B44481DB803F
	for <linux-mm@kvack.org>; Tue, 26 May 2009 12:20:06 +0900 (JST)
Date: Tue, 26 May 2009 12:18:34 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH 5/5] (experimental) chase and free cache only swap
Message-Id: <20090526121834.dd9a4193.kamezawa.hiroyu@jp.fujitsu.com>
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

Just a trial/example patch.
I'd like to consider more. Better implementation idea is welcome.

When the system does swap-in/swap-out repeatedly, there are 
cache-only swaps in general.
Typically,
 - swapped out in past but on memory now while vm_swap_full() returns true
pages are cache-only swaps. (swap_map has no references.)

This cache-only swaps can be an obstacles for smooth page reclaiming.
Current implemantation is very naive, just scan & free.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/swap.h |    1 
 mm/swapfile.c        |   88 +++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 89 insertions(+)

Index: new-trial-swapcount/mm/swapfile.c
===================================================================
--- new-trial-swapcount.orig/mm/swapfile.c
+++ new-trial-swapcount/mm/swapfile.c
@@ -74,6 +74,8 @@ static inline unsigned short make_swap_c
 	return ret;
 }
 
+static void call_gc_cache_only_swap(void);
+
 /*
  * We need this because the bdev->unplug_fn can sleep and we cannot
  * hold swap_lock while calling the unplug_fn. And swap_lock
@@ -432,6 +434,8 @@ swp_entry_t get_swap_page(void)
 		offset = scan_swap_map(si, 1);
 		if (offset) {
 			spin_unlock(&swap_lock);
+			/* reclaim cache-only swaps if vm_swap_full() */
+			call_gc_cache_only_swap();
 			return swp_entry(type, offset);
 		}
 		next = swap_list.next;
@@ -2147,3 +2151,87 @@ int valid_swaphandles(swp_entry_t entry,
 	*offset = ++toff;
 	return nr_pages? ++nr_pages: 0;
 }
+
+/*
+ * Following code is for freeing Cache-only swap entries. These are calle in
+ * vm_swap_full() situation, and freeing cache-only swap and make some swap
+ * entries usable.
+ */
+
+static int find_free_cache_only_swap(int type)
+{
+	unsigned long buf[SWAP_CLUSTER_MAX];
+	int nr, offset, i;
+	unsigned short count;
+	struct swap_info_struct *si = swap_info + type;
+	int ret = 0;
+
+	spin_lock(&swap_lock);
+	nr = 0;
+	if (!(si->flags & SWP_WRITEOK) || si->cache_only == 0) {
+		ret = 1;
+		goto unlock;
+	}
+	offset = si->garbage_scan_offset;
+	/* Scan 2048 entries at most and free up to 32 entries per scan.*/
+	for (i = 2048; i > 0 && nr < 32; i--, offset++) {
+		if (offset >= si->max) {
+			offset = 0;
+			ret = 1;
+			break;
+		}
+		count = si->swap_map[offset];
+		if (count == SWAP_HAS_CACHE)
+			buf[nr++] = offset;
+	}
+	si->garbage_scan_offset = offset;
+unlock:
+	spin_unlock(&swap_lock);
+
+	for (i = 0; i < nr; i++) {
+		swp_entry_t ent;
+		struct page *page;
+
+		ent = swp_entry(type, buf[i]);
+
+		page = find_get_page(&swapper_space, ent.val);
+		if (page) {
+			lock_page(page);
+			try_to_free_swap(page);
+			unlock_page(page);
+		}
+	}
+	return ret;
+}
+
+#define SWAP_GC_THRESH	(4096)
+static void scan_and_free_cache_only_swap_work(struct work_struct *work);
+DECLARE_DELAYED_WORK(swap_gc_work, scan_and_free_cache_only_swap_work);
+static int swap_gc_last_scan;
+
+static void scan_and_free_cache_only_swap_work(struct work_struct *work)
+{
+	int type = swap_gc_last_scan;
+	int i;
+
+	spin_lock(&swap_lock);
+	for (i = type; i < MAX_SWAPFILES; i++) {
+		if (swap_info[i].flags & SWP_WRITEOK)
+			break;
+	}
+	if (i >= MAX_SWAPFILES)
+		i = 0;
+	spin_unlock(&swap_lock);
+	if (find_free_cache_only_swap(i))
+		swap_gc_last_scan = i + 1;
+
+	if (vm_swap_full() && (nr_cache_only_swaps > SWAP_GC_THRESH))
+		schedule_delayed_work(&swap_gc_work, HZ/10);
+}
+
+static void call_gc_cache_only_swap(void)
+{
+	if (vm_swap_full()  && (nr_cache_only_swaps > SWAP_GC_THRESH))
+		schedule_delayed_work(&swap_gc_work, HZ/10);
+}
+
Index: new-trial-swapcount/include/linux/swap.h
===================================================================
--- new-trial-swapcount.orig/include/linux/swap.h
+++ new-trial-swapcount/include/linux/swap.h
@@ -156,6 +156,7 @@ struct swap_info_struct {
 	unsigned int inuse_pages;
 	unsigned int old_block_size;
 	unsigned int cache_only;
+	unsigned int garbage_scan_offset;
 };
 
 struct swap_list_t {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
