Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 13DEF6B003D
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 02:32:51 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBA7Wnjv024254
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 10 Dec 2009 16:32:49 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6F24845DE52
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4338D45DE4F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2B0BC1DB8038
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id D17A41DB803F
	for <linux-mm@kvack.org>; Thu, 10 Dec 2009 16:32:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH v2  5/8] Don't deactivate the page if trylock_page() is failed.
In-Reply-To: <20091210154822.2550.A69D9226@jp.fujitsu.com>
References: <20091210154822.2550.A69D9226@jp.fujitsu.com>
Message-Id: <20091210163204.255F.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu, 10 Dec 2009 16:32:48 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Larry Woodman <lwoodman@redhat.com>
List-ID: <linux-mm.kvack.org>

Currently, wipe_page_reference() increment refctx->referenced variable
if trylock_page() is failed. but it is meaningless at all.
shrink_active_list() deactivate the page although the page was
referenced. The page shouldn't be deactivated with young bit. it
break reclaim basic theory and decrease reclaim throughput.

This patch introduce new SWAP_AGAIN return value to
wipe_page_reference().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Reviewed-by: Rik van Riel <riel@redhat.com>
---
 mm/rmap.c   |    5 ++++-
 mm/vmscan.c |   15 +++++++++++++--
 2 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/mm/rmap.c b/mm/rmap.c
index 2f4451b..b84f350 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -539,6 +539,9 @@ static int wipe_page_reference_file(struct page *page,
  *
  * Quick test_and_clear_referenced for all mappings to a page,
  * returns the number of ptes which referenced the page.
+ *
+ * SWAP_SUCCESS  - success to wipe all ptes
+ * SWAP_AGAIN    - temporary busy, try again later
  */
 int wipe_page_reference(struct page *page,
 			struct mem_cgroup *memcg,
@@ -555,7 +558,7 @@ int wipe_page_reference(struct page *page,
 		    (!PageAnon(page) || PageKsm(page))) {
 			we_locked = trylock_page(page);
 			if (!we_locked) {
-				refctx->referenced++;
+				ret = SWAP_AGAIN;
 				goto out;
 			}
 		}
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c59baa9..a01cf5e 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -577,6 +577,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		struct address_space *mapping;
 		struct page *page;
 		int may_enter_fs;
+		int ret;
 		struct page_reference_context refctx = {
 			.is_page_locked = 1,
 		};
@@ -621,7 +622,11 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 				goto keep_locked;
 		}
 
-		wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		ret = wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		if (ret == SWAP_AGAIN)
+			goto keep_locked;
+		VM_BUG_ON(ret != SWAP_SUCCESS);
+
 		/*
 		 * In active use or really unfreeable?  Activate it.
 		 * If page which have PG_mlocked lost isoltation race,
@@ -1321,6 +1326,7 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {
+		int ret;
 		struct page_reference_context refctx = {
 			.is_page_locked = 0,
 		};
@@ -1340,7 +1346,12 @@ static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			continue;
 		}
 
-		wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		ret = wipe_page_reference(page, sc->mem_cgroup, &refctx);
+		if (ret == SWAP_AGAIN) {
+			list_add(&page->lru, &l_active);
+			continue;
+		}
+		VM_BUG_ON(ret != SWAP_SUCCESS);
 
 		if (refctx.referenced)
 			nr_rotated++;
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
