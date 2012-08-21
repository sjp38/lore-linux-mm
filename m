Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id D31616B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 08:12:14 -0400 (EDT)
Received: by dadi14 with SMTP id i14so617322dad.14
        for <linux-mm@kvack.org>; Tue, 21 Aug 2012 05:12:14 -0700 (PDT)
Message-ID: <50337B15.2090701@gmail.com>
Date: Tue, 21 Aug 2012 20:12:05 +0800
From: qiuxishi <qiuxishi@gmail.com>
MIME-Version: 1.0
Subject: [PATCH] memory-hotplug: fix a drain pcp bug when offline pages
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, lliubbo@gmail.com, jiang.liu@huawei.com
Cc: mgorman@suse.de, kamezawa.hiroyu@jp.fujitsu.com, mhocko@suse.cz, linux-mm@kvack.org, linux-kernel@vger.kernel.org, qiuxishi@huawei.com, wujianguo@huawei.com, bessel.wang@huawei.com, guohanjun@huawei.com, chenkeping@huawei.com, yinghai@kernel.org, wency@cn.fujitsu.com

From: Xishi Qiu <qiuxishi@huawei.com>

When offline a section, we move all the free pages and pcp into MIGRATE_ISOLATE list first.
start_isolate_page_range()
	set_migratetype_isolate()
		drain_all_pages(),

Here is a problem, it is not sure that pcp will be moved into MIGRATE_ISOLATE list. They may
be moved into MIGRATE_MOVABLE list because page_private() maybe 2. So when finish migrating
pages, the free pages from pcp may be allocated again, and faild in check_pages_isolated().
drain_all_pages()
	drain_local_pages()
		drain_pages()
			free_pcppages_bulk()
				__free_one_page(page, zone, 0, page_private(page));

If we add move_freepages_block() after drain_all_pages(), it can not sure that all the pcp
will be moved into MIGRATE_ISOLATE list when the system works on high load. The free pages
which from pcp may immediately be allocated again.

I think the similar bug described in http://marc.info/?t=134250882300003&r=1&w=2


Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
---
 mm/page_alloc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index d0723b2..501f6de 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -673,7 +673,8 @@ static void free_pcppages_bulk(struct zone *zone, int count,
 			/* must delete as __free_one_page list manipulates */
 			list_del(&page->lru);
 			/* MIGRATE_MOVABLE list may include MIGRATE_RESERVEs */
-			__free_one_page(page, zone, 0, page_private(page));
+			__free_one_page(page, zone, 0,
+					get_pageblock_migratetype(page));
 			trace_mm_page_pcpu_drain(page, 0, page_private(page));
 		} while (--to_free && --batch_free && !list_empty(list));
 	}
-- 1.7.6.1 .



.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
