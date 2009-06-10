Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C7B76B007E
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 01:27:58 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5A5SmUo017031
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 10 Jun 2009 14:28:48 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6660845DD7B
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:28:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26CD945DD78
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:28:48 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 053801DB8040
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:28:48 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 86EC41DB803C
	for <linux-mm@kvack.org>; Wed, 10 Jun 2009 14:28:47 +0900 (JST)
Date: Wed, 10 Jun 2009 14:27:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [PATCH 2/2] memcg: fix LRU rotation at __isolate_page
Message-Id: <20090610142717.09286cd2.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com>
References: <20090610142443.9370aff8.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>, apw@canonical.com, riel@redhat.com, minchan.kim@gmail.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

Depends on fix to lumpy reclaim, so, updated.

==
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch tries to fix memcg's lru rotation sanity...make memcg use
the same logic as global LRU does.

Now, at __isolate_lru_page() retruns -EBUSY, the page is rotated to
the tail of LRU in global LRU's isolate LRU pages. But in memcg,
it's not handled. This makes memcg do the same behavior as global LRU
and rotate LRU in the page is busy.

Acked-by: Balbir Singh <balbir@linux.vnet.ibm.com>
Reviewed-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 mm/memcontrol.c |   13 ++++++++++++-
 mm/vmscan.c     |    4 +++-
 2 files changed, 15 insertions(+), 2 deletions(-)

Index: mmotm-2.6.30-Jun10/mm/vmscan.c
===================================================================
--- mmotm-2.6.30-Jun10.orig/mm/vmscan.c
+++ mmotm-2.6.30-Jun10/mm/vmscan.c
@@ -844,7 +844,6 @@ int __isolate_lru_page(struct page *page
 		 */
 		ClearPageLRU(page);
 		ret = 0;
-		mem_cgroup_del_lru(page);
 	}
 
 	return ret;
@@ -898,6 +897,7 @@ try_lumpy_reclaim(struct page *page, str
 			/* we are always under ISOLATE_BOTH */
 			if (__isolate_lru_page(page, ISOLATE_BOTH, 0) == 0) {
 				list_move(&page->lru, dst);
+				mem_cgroup_del_lru(page);
 				nr++;
 			} else if (do_aggressive && !PageUnevictable(page))
 					continue;
@@ -951,12 +951,14 @@ static unsigned long isolate_lru_pages(u
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
Index: mmotm-2.6.30-Jun10/mm/memcontrol.c
===================================================================
--- mmotm-2.6.30-Jun10.orig/mm/memcontrol.c
+++ mmotm-2.6.30-Jun10/mm/memcontrol.c
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
