Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 261ED6B0039
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:27:57 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part3 PATCH v2 4/4] mem-hotplug: Do not free LOCAL_NODE_DATA pages to buddy system in hot-remove procedure.
Date: Thu, 13 Jun 2013 21:03:56 +0800
Message-Id: <1371128636-9027-5-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

In memory hot-remove procedure, we free pagetable pages to buddy system.
But for local pagetable pages, do not free them to buddy system because
they were skipped in offline procedure. The memory block they reside in
could have been offlined, and we won't offline it again.

v1 -> v2: Prevent freeing LOCAL_NODE_DATA pages in free_pagetable() instead
	  of in put_page_bootmem().

Suggested-by: Wu Jianguo <wujianguo@huawei.com>
Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 arch/x86/mm/init_64.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 25de304..ffaf24a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -726,7 +726,13 @@ static void __meminit free_pagetable(struct page *page, int order)
 		if (magic == SECTION_INFO || magic == MIX_SECTION_INFO) {
 			while (nr_pages--)
 				put_page_bootmem(page++);
-		} else
+		} else if (!is_local_node_data(page))
+			/*
+			 * Do not free pages with local node kernel data
+			 * (for now, just local pagetables) to the buddy
+			 * system because we skipped these pages when
+			 * offlining the corresponding block.
+			 */
 			__free_pages_bootmem(page, order);
 	} else
 		free_pages((unsigned long)page_address(page), order);
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
