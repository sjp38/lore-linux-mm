Received: from m6.gw.fujitsu.co.jp ([10.0.50.76]) by fgwmail6.fujitsu.co.jp (8.12.10/Fujitsu Gateway)
	id i7QCA5wH012741 for <linux-mm@kvack.org>; Thu, 26 Aug 2004 21:10:05 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m6.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id i7QCA4qA020810 for <linux-mm@kvack.org>; Thu, 26 Aug 2004 21:10:05 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from fjmail501.fjmail.jp.fujitsu.com (fjmail501-0.fjmail.jp.fujitsu.com [10.59.80.96]) by s6.gw.fujitsu.co.jp (8.12.11)
	id i7QCA4wT000786 for <linux-mm@kvack.org>; Thu, 26 Aug 2004 21:10:04 +0900
	(envelope-from kamezawa.hiroyu@jp.fujitsu.com)
Received: from jp.fujitsu.com
 (fjscan503-0.fjmail.jp.fujitsu.com [10.59.80.124]) by
 fjmail501.fjmail.jp.fujitsu.com
 (Sun Internet Mail Server sims.4.0.2001.07.26.11.50.p9)
 with ESMTP id <0I3100DNVZ4R9U@fjmail501.fjmail.jp.fujitsu.com> for
 linux-mm@kvack.org; Thu, 26 Aug 2004 21:10:04 +0900 (JST)
Date: Thu, 26 Aug 2004 21:15:14 +0900
From: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC] buddy allocator without bitmap [4/4]
Message-id: <412DD452.1090703@jp.fujitsu.com>
MIME-version: 1.0
Content-type: text/plain; charset=us-ascii; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel ML <linux-kernel@vger.kernel.org>
Cc: LHMS <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, William Lee Irwin III <wli@holomorphy.com>, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This patch 5th inserts prefetch().
I think These prefetch are reasonable and helpful.

-- Kame
====================================================================



---

  linux-2.6.8.1-mm4-kame-kamezawa/mm/page_alloc.c |    2 ++
  1 files changed, 2 insertions(+)

diff -puN mm/page_alloc.c~eliminate-bitmap-prefetch mm/page_alloc.c
--- linux-2.6.8.1-mm4-kame/mm/page_alloc.c~eliminate-bitmap-prefetch	2004-08-26 19:32:01.598461736 +0900
+++ linux-2.6.8.1-mm4-kame-kamezawa/mm/page_alloc.c	2004-08-26 19:32:01.602461128 +0900
@@ -257,6 +257,7 @@ static inline void __free_pages_bulk (st
  		order++;
  		mask <<= 1;
  		page_idx &= mask;
+		prefetch(base + (page_idx ^ (1 << order)));
  		list_del(&buddy->lru);
  		/* for propriety of PG_private bit, we clear it */
  		buddy->flags &= ~(1 << PG_private);
@@ -360,6 +361,7 @@ expand(struct zone *zone, struct page *p
  		area--;
  		high--;
  		size >>= 1;
+		prefetch(&page[size >> 1]);
  		BUG_ON(bad_range(zone, &page[size]));
  		list_add(&page[size].lru, &area->free_list);
  		page[size].flags |= (1 << PG_private);

_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
