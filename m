Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 05FEA6B0033
	for <linux-mm@kvack.org>; Thu, 13 Jun 2013 09:27:54 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [Part3 PATCH v2 3/4] mem-hotplug: Skip LOCAL_NODE_DATA pages in memory online procedure.
Date: Thu, 13 Jun 2013 21:03:55 +0800
Message-Id: <1371128636-9027-4-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
References: <1371128636-9027-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com
Cc: x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Pages marked as LOCAL_NODE_DATA are skipped when we do memory offline.
So we have to skip them again when we do memory online.

Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
---
 mm/memory_hotplug.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index c2017eb..3561048 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -843,6 +843,11 @@ static int online_pages_range(unsigned long start_pfn, unsigned long nr_pages,
 	if (PageReserved(pfn_to_page(start_pfn)))
 		for (i = 0; i < nr_pages; i++) {
 			page = pfn_to_page(start_pfn + i);
+
+			/* Skip pages storing local node kernel data. */
+			if (is_local_node_data(page))
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
