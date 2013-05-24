Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx163.postini.com [74.125.245.163])
	by kanga.kvack.org (Postfix) with SMTP id 03D9F6B0072
	for <linux-mm@kvack.org>; Fri, 24 May 2013 05:37:35 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 4/4] mem-hotplug: Do not free LOCAL_NODE_DATA pages to buddy system in hot-remove procedure.
Date: Fri, 24 May 2013 17:30:07 +0800
Message-Id: <1369387807-17956-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1369387807-17956-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1369387807-17956-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mgorman@suse.de, mingo@redhat.com, hpa@zytor.com, minchan@kernel.org, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, yinghai@kernel.org, jiang.liu@huawei.com, tj@kernel.org, liwanp@linux.vnet.ibm.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

In memory hot-remove procedure, we free pagetable pages to buddy system.
But for local pagetable pages, do not free them to buddy system because
they were skipped in offline procedure. The memory block they reside in
could have been offlined, and we won't offline it again.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index 21d6fcb..c30e819 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -119,6 +119,14 @@ void __ref put_page_bootmem(struct page *page)
 		INIT_LIST_HEAD(&page->lru);
 
 		/*
+		 * Do not free pages with local node kernel data (for now, just
+		 * local pagetables) to the buddy system because we skipped
+		 * these pages when offlining the corresponding block.
+		 */
+		if (type == LOCAL_NODE_DATA)
+			return;
+
+		/*
 		 * Please refer to comment for __free_pages_bootmem()
 		 * for why we serialize here.
 		 */
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
