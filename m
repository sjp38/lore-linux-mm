Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 945746B0069
	for <linux-mm@kvack.org>; Fri, 24 May 2013 05:37:33 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 3/4] mem-hotplug: Skip LOCAL_NODE_DATA pages in memory online procedure.
Date: Fri, 24 May 2013 17:30:06 +0800
Message-Id: <1369387807-17956-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1369387807-17956-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1369387807-17956-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mingo@redhat.com, hpa@zytor.com, minchan@kernel.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, yinghai@kernel.org, jiang.liu@huawei.com, tj@kernel.org, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Pages marked as LOCAL_NODE_DATA are skipped when we do memory offline.
So we have to skip them again when we do memory online.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 075d412..21d6fcb 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -825,12 +825,18 @@ static void generic_online_page(struct page *page)
 static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 			void *arg)
 {
-	unsigned long i;
+	unsigned long i, magic;
 	unsigned long onlined_pages = *(unsigned long *)arg;
 	struct page *page;
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+			magic = (unsigned long)page->lru.next;
+
+			/* Skip pages storing local node kernel data. */
+			if (magic == LOCAL_NODE_DATA)
+				continue;
+
 			(*online_page_callback)(page);
 			onlined_pages++;
 		}
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
