Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9024F6B004F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:54:05 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n599ORtP005060
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 9 Jun 2009 18:24:27 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 14FBD45DD7F
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:24:27 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id DF8B945DD7E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:24:26 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C73EA1DB8037
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:24:26 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F2B1DB8046
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 18:24:23 +0900 (JST)
Date: Tue, 9 Jun 2009 18:22:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH] memcg: fix mem_cgroup_isolate_lru_page to use the same
 rotate logic at busy path
Message-Id: <20090609182253.009c98a3.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090609181505.4083a213.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch tries to fix memcg's lru rotation sanity...make memcg use
the same logic as global LRU does.

Now, at __isolate_lru_page() retruns -EBUSY, the page is rotated to
the tail of LRU in global LRU's isolate LRU pages. But in memcg,
it's not handled. This makes memcg do the same behavior as global LRU
and rotate LRU in the page is busy.

Note: __isolate_lru_page() is not isolate_lru_page() and it's just used
in sc->isolate_pages() logic.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   13 ++++++++++++-
 mm/vmscan.c     |    4 +++-
 2 files changed, 15 insertions(+), 2 deletions(-)

Index: mmotm-2.6.30-Jun4/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-Jun4.orig/mm/vmscan.c
+++ mmotm-2.6.30-Jun4/mm/vmscan.c
@@ -842,7 +842,6 @@ int __isolate_lru_page(struct page *page
 		 */
 		ClearPageLRU(page);
 		ret = 0;
-		mem_cgroup_del_lru(page);
 	}
 
 	return ret;
@@ -890,12 +889,14 @@ static unsigned long isolate_lru_pages(u
 		switch (__isolate_lru_page(page, mode, file)) {
 		case 0:
 			list_move(&page->lru, dst);
+			mem_cgroup_del_lru(page);
 			nr_taken++;
 			break;
 
 		case -EBUSY:
 			/* else it is being freed elsewhere */
 			list_move(&page->lru, src);
+			mem_cgroup_rotate_lru_list(page, page_lru(page));
 			continue;
 
 		default:
@@ -937,6 +938,7 @@ static unsigned long isolate_lru_pages(u
 			switch (__isolate_lru_page(cursor_page, mode, file)) {
 			case 0:
 				list_move(&cursor_page->lru, dst);
+				mem_cgroup_del_lru(page);
 				nr_taken++;
 				scan++;
 				break;
Index: mmotm-2.6.30-Jun4/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-Jun4.orig/mm/memcontrol.c
+++ mmotm-2.6.30-Jun4/mm/memcontrol.c
@@ -649,6 +649,7 @@ unsigned long mem_cgroup_isolate_pages(u
 	int zid = zone_idx(z);
 	struct mem_cgroup_per_zone *mz;
 	int lru = LRU_FILE * !!file + !!active;
+	int ret;
 
 	BUG_ON(!mem_cont);
 	mz = mem_cgroup_zoneinfo(mem_cont, nid, zid);
@@ -666,9 +667,19 @@ unsigned long mem_cgroup_isolate_pages(u
 			continue;
 
 		scan++;
-		if (__isolate_lru_page(page, mode, file) == 0) {
+		ret = __isolate_lru_page(page, mode, file);
+		switch (ret) {
+		case 0:
 			list_move(&page->lru, dst);
+			mem_cgroup_del_lru(page);
 			nr_taken++;
+			break;
+		case -EBUSY:
+			/* we don't affect global LRU but rotate in our LRU */
+			mem_cgroup_rotate_lru_list(page, page_lru(page));
+			break;
+		default:
+			break;
 		}
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
