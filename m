Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 68C816B02A8
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 02:13:31 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o756DfK8012791
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 5 Aug 2010 15:13:41 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id E427245DE55
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id B2C5F45DE52
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:40 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 8C7FD1DB8019
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:40 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B66B1DB8013
	for <linux-mm@kvack.org>; Thu,  5 Aug 2010 15:13:40 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [PATCH 3/7] vmscan: synchrounous lumpy reclaim use lock_page() instead trylock_page()
In-Reply-To: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
References: <20100805150624.31B7.A69D9226@jp.fujitsu.com>
Message-Id: <20100805151304.31C0.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Thu,  5 Aug 2010 15:13:39 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Wu Fengguang <fengguang.wu@intel.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

When synchrounous lumpy reclaim, there is no reason to give up to
reclaim pages even if page is locked. We use lock_page() instead
trylock_page() in this case.

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
---
 mm/vmscan.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 1cdc3db..833b6ad 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -665,7 +665,9 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		page = lru_to_page(page_list);
 		list_del(&page->lru);
 
-		if (!trylock_page(page))
+		if (sync_writeback == PAGEOUT_IO_SYNC)
+			lock_page(page);
+		else if (!trylock_page(page))
 			goto keep;
 
 		VM_BUG_ON(PageActive(page));
-- 
1.6.5.2



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
